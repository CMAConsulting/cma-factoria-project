#!/bin/bash
# CMA Factoria - Compile LaTeX PDF
# Description: Compila el documento cma-factoria.tex a PDF

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LATEX_DIR="$PROJECT_ROOT/docs/latex"
OUTPUT_DIR="$PROJECT_ROOT/.tmp"

mkdir -p "$OUTPUT_DIR"

echo "Compilando documento LaTeX..."
cd "$LATEX_DIR"
pdflatex -interaction=nonstopmode -output-directory="$OUTPUT_DIR" cma-factoria.tex

echo "PDF generado en: $OUTPUT_DIR/cma-factoria.pdf"
