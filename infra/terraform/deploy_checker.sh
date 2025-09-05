#!/bin/bash
set -e  # exit immediately if a command fails

# Paths
CHECKER_DIR="/Users/sinmisolaakinjayeju/my-sre-devops-project/app/checker"
TERRAFORM_DIR="/Users/sinmisolaakinjayeju/my-sre-devops-project/infra/terraform"
ZIP_NAME="checker.zip"
PACKAGE_DIR="$CHECKER_DIR/package"

echo "🔹 Cleaning old build..."
rm -rf "$PACKAGE_DIR"
rm -f "$CHECKER_DIR/$ZIP_NAME"
rm -f "$TERRAFORM_DIR/$ZIP_NAME"

# Recreate package dir
mkdir -p "$PACKAGE_DIR"

echo "🔹 Installing dependencies..."
pip3 install -r "$CHECKER_DIR/requirements.txt" -t "$PACKAGE_DIR"

echo "🔹 Packaging Lambda code..."
cd "$PACKAGE_DIR"
zip -r "../$ZIP_NAME" .
cd ..
zip -g "$ZIP_NAME" main.py

echo "🔹 Moving package to Terraform dir..."
mv "$ZIP_NAME" "$TERRAFORM_DIR/$ZIP_NAME"

echo "🔹 Applying Terraform with variables.tfvars..."
cd "$TERRAFORM_DIR"
terraform apply -var-file=variables.tfvars -auto-approve

echo "✅ Deployment complete!"
