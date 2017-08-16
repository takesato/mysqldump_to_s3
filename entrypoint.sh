#!/bin/bash
set -e

d=`date +"%Y%m%d%H%M%S"`
DUMP_FILE=/dump_temp/dump${d}.sql.gz
mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -h ${MYSQL_HOST} --databases ${MYSQL_DATABASE} ${MYSQL_OPTIONS} |gzip> ${DUMP_FILE}

aws s3 cp ${DUMP_FILE} s3://${S3_BUCKET}/ --acl public-read

rm -f ${DUMP_FILE}

LOCATION=`aws s3api get-bucket-location --bucket ${S3_BUCKET} | jq -r .LocationConstraint`
if [ "${LOCATION}" = 'null' ]; then
  LOCATION='us-east-1'
fi
URL="https://s3-${LOCATION}.amazonaws.com/${S3_BUCKET}/dump${d}.sql.gz"
echo ${URL}

if [ -n "${SLACK_WEBHOOK_URL}" ]; then
  curl -s -X POST --data-urlencode "payload={'text': 'Upload completed to s3. \n${URL}'}" ${SLACK_WEBHOOK_URL}
fi;
