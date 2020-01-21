#!/bin/bash
set -e

APP_ROOT="$( cd "$( dirname "$(dirname "${BASH_SOURCE[0]}")" )" >/dev/null 2>&1 && pwd )"
CREDENTIALS_FILE=$APP_ROOT/ibm-credentials.env
ENV_FILE=$APP_ROOT/.env
PROPERTIES_FILE=$ENV_FILE
APP_NAME=${1:-'nlu-code-pattern'}

if test -f "$CREDENTIALS_FILE"; then
    echo "Loading parameters from: $CREDENTIALS_FILE"
    source $CREDENTIALS_FILE
    PROPERTIES_FILE=$CREDENTIALS_FILE
fi

if test -f "$ENV_FILE"; then
    echo "Loading parameters from: $ENV_FILE"
    source $ENV_FILE
    PROPERTIES_FILE=$ENV_FILE
fi

echo "Create or update template"
oc replace -f openshift/template.yaml


echo "Create $APP_NAME app"
oc new-app -f openshift/template.yaml \
  --ignore-unknown-parameters=true \
  --param-file $PROPERTIES_FILE \
  -p APP_NAME=$APP_NAME -o yaml | oc apply -f -

echo "\nGet status"
oc status

echo "\n Wait 20 seconds for build to start"
sleep 20

echo "\n Follow deployment"
oc start-build nlu-code-pattern --follow

echo "\n Application route"
oc get routes