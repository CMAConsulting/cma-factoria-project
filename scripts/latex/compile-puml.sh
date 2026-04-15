#!/bin/bash
# SYN FactorIA - Compile PlantUML to PDF
# Description: Compila diagramas PlantUML a PDF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
UML_DIR="$PROJECT_ROOT/docs/uml"
OUTPUT_DIR="$PROJECT_ROOT/docs/latex/.tmp"

mkdir -p "$OUTPUT_DIR"

echo "Compilando diagramas PlantUML..."

for puml in "$UML_DIR"/*.puml; do
    if [[ -f "$puml" ]]; then
        filename=$(basename "$puml" .puml)
        echo "  Generando: $filename.png"
        plantuml -o "$OUTPUT_DIR" "$puml"
    fi
done

echo "Diagramas generados en: $OUTPUT_DIR"
