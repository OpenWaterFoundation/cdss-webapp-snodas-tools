#!/bin/sh

# Update the GCP static website bucket CORS settings.
# - this is necessary to avoid CORS errors of web browser doing requests
# - see:  https://cloud.google.com/storage/docs/configuring-cors

# List CORS configuration
snodasBucket="snodas.cdss.state.co.us"
snodasBucketUrl="gs://${snodasBucket}"
echo "SNODAS bucket: ${snodasBucketUrl}" 

# Check setting before.
echo "CORS settings before set:" 
gsutil.cmd cors get ${snodasBucketUrl}

# Set the CORS setting.
echo "Settings CORS with: gsutil.cmd cors set set-gcp-cors.json ${snodasBucketUrl}"
gsutil.cmd cors set set-gcp-cors.json ${snodasBucketUrl}

# Check setting after.
echo "CORS settings after set:" 
gsutil.cmd cors get ${snodasBucketUrl}
