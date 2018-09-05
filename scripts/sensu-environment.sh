export SENSU_USER=admin
export SENSU_PASS=P@ssw0rd!
export SENSU_ORG=default
export SENSU_ENV=default
export SENSU_TOKEN=`curl -XGET -u "$SENSU_USER:$SENSU_PASS" -s http://localhost:8080/auth | jq -r ".access_token"`
sensuctl configure -n --username $SENSU_USER --password $SENSU_PASS --organization $SENSU_ORG --environment $SENSU_ENV
