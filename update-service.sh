#!/bin/sh
BASEDIR=$(dirname "$0")
CONF=$1
TAG=$2
VERSION=$3
REGION=$(grep region $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
REPO=$(grep repo $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
SERVICE=$(grep service $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
CLUSTER=$(grep cluster $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
FAMILY=$(grep family $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
TEMPLATE=$(grep template $BASEDIR/configs/$CONF.cfg | awk '{split($0,a,":"); print a[2]}')
FILE_TEMP="$BASEDIR/task-definition-$1.json"
TASK_DEF_FILE="$BASEDIR/task-definition-$TAG-$VERSION.json"
sed -e "s;<<tag>>;${TAG};g" ${BASEDIR}/templates/${TEMPLATE} > ${FILE_TEMP}
sed -e "s;<<repo>>;${REPO};g" ${FILE_TEMP} > ${FILE_TEMP}_1
sed -e "s;<<version>>;${VERSION};g" ${FILE_TEMP}_1 > ${TASK_DEF_FILE}
aws configure set region ${REGION}
aws ecs register-task-definition --family ${FAMILY} --cli-input-json file://${TASK_DEF_FILE}
TASK_REVISION=`aws ecs describe-task-definition --task-definition ${FAMILY}| egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//'`
aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE} --task-definition ${FAMILY}:${TASK_REVISION}
rm ${FILE_TEMP}
rm ${FILE_TEMP}_1
rm ${TASK_DEF_FILE}
