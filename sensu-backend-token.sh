export SENSU_USER=admin
export SENSU_PASS=P@ssw0rd!
export SENSU_TOKEN=`curl -u "$SENSU_USER:$SENSU_PASS" -s http://localhost:8080/auth | jq -r ".access_token"`
