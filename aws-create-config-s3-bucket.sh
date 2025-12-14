# Pick a bucket name that is globally unique
BUCKET_NAME=aws-config-history-$(date +%y%m%d%H%M%S)

# Choose a region for the bucket (e.g. us-east-1)
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region us-east-1 \

# (Optional) Enable versioning – helps protect the data
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Add bucket policy to allow Config service access
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy "{
      \"Version\": \"2012-10-17\",
      \"Statement\": [
        {
          \"Sid\": \"AWSConfigBucketPermissionsCheck\",
          \"Effect\": \"Allow\",
          \"Principal\": {
            \"Service\": \"config.amazonaws.com\"
          },
          \"Action\": [\"s3:GetBucketVersioning\", \"s3:GetBucketAcl\"],
          \"Resource\": \"arn:aws:s3:::$BUCKET_NAME\"
        },
        {
          \"Sid\": \"AWSConfigBucketDelivery\",
          \"Effect\": \"Allow\",
          \"Principal\": {
            \"Service\": \"config.amazonaws.com\"
          },
          \"Action\": \"s3:PutObject\",
          \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\"
        }
      ]
    }"

echo "✅ S3 bucket '$BUCKET_NAME' created with Config access policy"
