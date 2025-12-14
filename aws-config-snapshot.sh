#!/usr/bin/env bash
set -euo pipefail

# Same region list as before
REGIONS=(
eu-west-2
eu-west-1
ap-northeast-3
ap-northeast-2
ap-northeast-1
ca-central-1
sa-east-1
ap-southeast-1
ap-southeast-2
eu-central-1
us-east-1
us-east-2
us-west-1
us-west-2
)

# for REGION in $(aws ec2 describe-regions --query "Regions[].RegionName" --output text)
for REGION in "${REGIONS[@]}"
do

  echo "Creating snapshot in $REGION …"

  if [ "$REGION" = "ap-south-1" ]
  then
    echo "Skipping $REGION - snapshots not supported"
    continue
  fi
  
  RESULT=$(aws configservice deliver-config-snapshot \
      --region "$REGION" \
      --delivery-channel-name default)

  SNAP_ID=$(echo "$RESULT" | jq -r '.configSnapshotId')
  echo "✅ Snapshot $SNAP_ID created in $REGION."

done

echo "✅ Config snapshots completed in all regions."
