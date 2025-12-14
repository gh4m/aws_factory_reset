#!/usr/bin/env bash
set -euo pipefail

# Validate S3 bucket name argument
if [[ -z "${1:-}" ]]; then
  echo "Error: S3 bucket name argument is required"
  echo "Usage: $0 <bucket-name>"
  exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BUCKET_NAME=$1

# # List of regions you want Config in (add/remove as needed)
# REGIONS=(
#   us-east-1
#   us-west-2
#   eu-central-1
#   ap-southeast-2
# )

# for REGION in "${REGIONS[@]}"; do
for REGION in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
do
  
  echo ""
  echo "=== Enabling Config in $REGION ..."
  echo ""

  aws configservice put-configuration-recorder \
      --region "$REGION" \
      --configuration-recorder name=default,roleARN="arn:aws:iam::$ACCOUNT_ID:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig" \
      --recording-group allSupported=true

  aws configservice put-delivery-channel \
      --region "$REGION" \
      --delivery-channel name=default,s3BucketName="$BUCKET_NAME"

  aws configservice start-configuration-recorder \
      --region "$REGION" \
      --configuration-recorder-name default

  # Wait a couple of seconds for the service‑linked role to be created
  sleep 5

  echo "✅ Config is recording in $REGION"
    
done

echo "✅  Config is now recording in all listed regions."