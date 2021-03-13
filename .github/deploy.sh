#!/usr/bin/env bash
set -e
BUCKET_NAME=gitactivity.com
BUCKET_REGION=eu-west-2
# Create bucket if not exists already
if aws s3 ls s3://${BUCKET_NAME} 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb s3://${BUCKET_NAME}
fi
# Deploy new web client and remove old files
# 1. move static sources with appropriate cache headers, existing index.html requests will pull cached versions at the time of copy
aws s3 sync _site/assets "s3://${BUCKET_NAME}/assets" --region $BUCKET_REGION --cache-control max-age=1296000,public --acl public-read --delete
# 2. sync remaining non-cacheable files and remove old ones
aws s3 sync _site "s3://${BUCKET_NAME}" --region $BUCKET_REGION --cache-control max-age=0 --acl public-read --delete
# 3. Set the index and error html files, error points to the same index for it to work with html5 navigation
aws s3 website "s3://${BUCKET_NAME}" --index-document index.html --error-document 500.html
