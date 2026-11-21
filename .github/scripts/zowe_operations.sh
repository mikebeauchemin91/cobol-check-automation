
#!/bin/bash

set -e

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

# Mainframe COBOL Check directory
MAINFRAME_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

# Check whether the USS directory exists
if ! zowe zos-files list uss-files "$MAINFRAME_DIR" &>/dev/null; then
    echo "Directory does not exist. Creating it..."
    zowe zos-files create uss-directory "$MAINFRAME_DIR"
else
    echo "Directory already exists."
fi

# Remove the obsolete nested DEPTPAY test suite
echo "Removing obsolete DEPTPAY test suite..."
zowe zos-files delete uss-file "$MAINFRAME_DIR/src/test/cobol/DEPTPAY/DEPTPAY.cut" --force || true

# Upload COBOL Check files
echo "Uploading COBOL Check files..."
zowe zos-files upload dir-to-uss "./cobol-check" "$MAINFRAME_DIR" --recursive --binary-files "cobol-check-0.2.19.jar"

# Verify upload
echo "Verifying upload:"
zowe zos-files list uss-files "$MAINFRAME_DIR"
