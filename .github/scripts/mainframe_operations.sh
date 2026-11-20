#!/bin/bash

set -e

echo "Starting COBOL Check operations..."

cd "$(dirname "$0")/../.."

echo "Working directory: $(pwd)"

if ! command -v java >/dev/null 2>&1; then
    echo "ERROR: Java is not installed."
    exit 1
fi

if ! command -v cobc >/dev/null 2>&1; then
    echo "ERROR: GnuCOBOL is not installed."
    exit 1
fi

java -version
cobc --version

cd cobol-check

COBOL_CHECK_JAR="bin/cobol-check-0.2.19.jar"

if [ ! -f "$COBOL_CHECK_JAR" ]; then
    echo "ERROR: COBOL Check JAR not found."
    exit 1
fi

chmod +x scripts/linux_gnucobol_run_tests

for program in NUMBERS ALPHA; do
    echo "-----------------------------------"
    echo "Running COBOL Check for $program"

    java -jar "$COBOL_CHECK_JAR" -p "$program"
done

echo "-----------------------------------"
echo "COBOL Check operations completed."
