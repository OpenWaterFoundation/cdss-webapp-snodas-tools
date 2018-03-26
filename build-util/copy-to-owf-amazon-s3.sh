#!/bin/bash
#
# Copy the site/* contents to the projects.openwaterfoundation.org website.
# - replace all the files on the web with local files
# - location is projects.openwaterfoundation.org/owf-proj-co-cwcb-2016-snodas/prototype

# Set --dryrun to test before actually doing
dryrun=""
#dryrun="--dryrun"
s3Folder="s3://projects.openwaterfoundation.org/owf-proj-co-cwcb-2016-snodas/prototype"

if [ "$1" == "" ]
	then
	echo ""
	echo "Usage:  $0 AmazonConfigProfile"
	echo ""
	echo "Copy the site files to the Amazon S3 static website folder:  $s3Folder"
	echo ""
	exit 0
fi

awsProfile="$1"

aws s3 cp ../site/index.html ${s3Folder}/index.html ${dryrun} --profile "$awsProfile"
aws s3 sync ../site/css ${s3Folder}/css ${dryrun} --delete --profile "$awsProfile"
aws s3 sync ../site/fonts ${s3Folder}/fonts ${dryrun} --delete --profile "$awsProfile"
aws s3 sync ../site/images ${s3Folder}/images ${dryrun} --delete --profile "$awsProfile"
aws s3 sync ../site/javascript ${s3Folder}/javascript ${dryrun} --delete --profile "$awsProfile"
aws s3 sync ../site/json ${s3Folder}/json ${dryrun} --delete --profile "$awsProfile"
