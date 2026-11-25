#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-ap-southeast-2}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="clinicflow-tfstate-${ACCOUNT_ID}"

if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  echo "Bucket $BUCKET already exists"
  exit 0
fi

aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket "$BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
  }'

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

POLICY_FILE=$(mktemp)
cat > "$POLICY_FILE" <<POLICY
{
"Version": "2012-10-17",
"Statement": [
{
"Sid": "DenyInsecureTransport",
"Effect": "Deny",
"Principal": "*",
"Action": "s3:*",
"Resource": ["arn:aws:s3:::${BUCKET}", "arn:aws:s3:::${BUCKET}/*"],
"Condition": {"Bool": {"aws:SecureTransport": "false"}}
}
]
}
POLICY

aws s3api put-bucket-policy --bucket "$BUCKET" --policy "file://$POLICY_FILE"
rm -f "$POLICY_FILE"

echo "Created bucket $BUCKET"