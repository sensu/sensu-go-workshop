export SENSU_BACKEND_URL=http://localhost:8080
export SENSU_USER=admin
export SENSU_PASS=P@ssw0rd!
export SENSU_NAMESPACE=default
export SENSU_TOKEN=`curl -XGET -u "$SENSU_USER:$SENSU_PASS" -s $SENSU_BACKEND_URL/auth | jq -r ".access_token"`
sensuctl configure -n --username $SENSU_USER --password $SENSU_PASS --namespace $SENSU_NAMESPACE
