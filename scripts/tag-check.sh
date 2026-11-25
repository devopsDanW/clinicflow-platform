#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <env>" >&2
  exit 1
fi

ENV="$1"
case "$ENV" in
  dev|staging|prod) ;;
  *)
    echo "ERROR: ..." >&2
    exit 1
    ;;
esac

REGION="${AWS_REGION:-ap-southeast-2}"

aws resourcegroupstaggingapi get-resources \
  --region "$REGION" \
  --tag-filters "Key=Environment,Values=${ENV}" \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output text \
| tr '\t' '\n' \
| awk -F: '
{
  service = $3
  resource = $6
  for (i = 7; i <= NF; i++) { resource = resource ":" $i }

  if (index(resource, "/") > 0) {
    type = substr(resource, 1, index(resource, "/") - 1)
  } else if (index(resource, ":") > 0) {
    type = substr(resource, 1, index(resource, ":") - 1)
  } else {
    type = resource
  }
  print service ":" type
}' \
| sort \
| uniq -c \
| sort -rn
