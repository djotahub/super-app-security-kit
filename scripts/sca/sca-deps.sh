#!/bin/bash

# ==============================================================================
# Tarea T-13: SCA Wrapper (Software Composition Analysis)
# Herramienta: Trivy (Aqua Security)
# Propósito: Escanear dependencias generando reportes de auditoría para CI/CD.
# ==============================================================================

# Colores y Estilos
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración por Defecto
TARGET_DIR="."
REPORT_DIR="./reports"
SEVERITY="CRITICAL,HIGH"
EXIT_CODE_ON_FAIL=1

# Crear directorio de reportes si no existe
mkdir -p "$REPORT_DIR"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

install_trivy() {
    if ! command -v trivy &> /dev/null; then
        log_warn "Trivy no detectado en el PATH. Intentando instalación local..."
        if [ ! -f "./trivy" ]; then
            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b .
        fi
        TRIVY_CMD="./trivy"
    else
        TRIVY_CMD="trivy"
    fi
    log_info "Usando Trivy versión: $($TRIVY_CMD --version | head -n 1)"
}

run_scan() {
    local target=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_txt="$REPORT_DIR/sca_report_$timestamp.txt"
    local report_json="$REPORT_DIR/sca_report_$timestamp.json"

    log_info "Iniciando escaneo sobre: ${BOLD}$target${NC}"
    log_info "Buscando vulnerabilidades de nivel: ${BOLD}$SEVERITY${NC}"

    # 1. Escaneo en consola (Visual para el desarrollador)
    $TRIVY_CMD fs "$target" \
        --severity "$SEVERITY" \
        --ignore-unfixed \
        --scanners vuln \
        --exit-code 0 \
        --format table

    # 2. Generación de Reporte JSON (Para CI/CD, SonarQube, DefectDojo)
    log_info "Generando artefactos de auditoría en $REPORT_DIR..."
    $TRIVY_CMD fs "$target" \
        --severity "$SEVERITY" \
        --ignore-unfixed \
        --scanners vuln \
        --format json \
        --output "$report_json"

    # 3. Verificación de cumplimiento (Romper el build)
    # Ejecutamos de nuevo solo para obtener el exit code correcto sin re-procesar todo si fuera posible,
    # pero Trivy es rápido. Esta ejecución define si el script falla o pasa.
    $TRIVY_CMD fs "$target" \
        --severity "$SEVERITY" \
        --ignore-unfixed \
        --scanners vuln \
        --exit-code "$EXIT_CODE_ON_FAIL" \
        --format template \
        --template "@contrib/html.tpl" \
        --output "$REPORT_DIR/sca_report_$timestamp.html" > /dev/null 2>&1

    return $?
}

# --- Flujo Principal ---

install_trivy

# Ejecutar escaneo
if run_scan "$TARGET_DIR"; then
    log_success "✅ Auditoría SCA Aprobada. No se detectaron vulnerabilidades críticas."
    exit 0
else
    log_error "🚨 Auditoría SCA Fallida. Se detectaron vulnerabilidades críticas."
    log_warn "Revise el reporte detallado en: $REPORT_DIR"
    exit 1
fi
