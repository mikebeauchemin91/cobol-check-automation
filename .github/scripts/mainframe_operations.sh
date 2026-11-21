
#!/bin/bash

set -e

echo "Starting COBOL Check operations..."

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

if [ -z "$ZOWE_USERNAME" ] || [ -z "$ZOWE_PASSWORD" ]; then
    echo "ERROR: Zowe credentials are missing."
    exit 1
fi

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')
MAINFRAME_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

# Upload COBOL Check project to mainframe USS
echo "Uploading COBOL Check files to USS..."
chmod +x .github/scripts/zowe_operations.sh
.github/scripts/zowe_operations.sh

# Generate DEPTPAY test program on the mainframe
echo "Running COBOL Check for DEPTPAY..."

zowe zos-ssh issue command \
    "cd $MAINFRAME_DIR && java -jar bin/cobol-check-0.2.19.jar -p DEPTPAY && ls -l testruns/CC##99.CBL && cp testruns/CC##99.CBL CC##99.CBL && ls -l CC##99.CBL" \
    --host 204.90.115.200 \
    --port 22 \
    --user "$ZOWE_USERNAME" \
    --password "$ZOWE_PASSWORD" \
    --insecure

# Upload DEPTPAY JCL to the mainframe
echo "Uploading DEPTPAY JCL..."

zowe zos-files upload file-to-data-set \
    "$ROOT_DIR/DEPTPAY.JCL" \
    "$ZOWE_USERNAME.JCL(DEPTPAY)" \
    --encoding IBM-1047

# Submit JCL and display job output
echo "Submitting DEPTPAY JCL..."
echo "Checking uploaded JCL encoding..."

zowe zos-files download data-set \
    "$ZOWE_USERNAME.JCL(DEPTPAY)" \
    --binary \
    --file /tmp/DEPTPAY.jcl \
    --overwrite

od -An -tx1 -N 16 /tmp/DEPTPAY.jcl

zowe zos-jobs submit data-set \
    "$ZOWE_USERNAME.JCL(DEPTPAY)" \
    --view-all-spool-content

echo "DEPTPAY mainframe operations completed."


