#!/bin/bash
. /app/common.sh

#
# Functions
#

# Requires OPENLDAP_ORG_NAME, CERT_DIR
gen_certs(){

  [[ openssl ]] || fatal "OpenSSL not installed."

  mkdir -p $CERT_DIR || fatal 'Could not create certificate directories'

  # Change into working directory
  cd $CERT_DIR

    # Generate key
    openssl genrsa -out server.key 2048
    openssl rsa -in server.key -out server.key

    # Generate certificate
    openssl req -new -subj '/C=US/ST=New York/L=New York/O=Example Company/CN=example.com' -days 3650 -key server.key -out server.csr
    openssl x509 -days 3650 -in server.csr -out server.crt -req -signkey server.key
    rm server.csr

    cp /etc/ssl/certs/ca-certificates.crt .
    chown -R openldap:openldap *
  
  cd -
}

# Requires OPENLDAP_ORG_NAME, OPENLDAP_ORG_DNS, OPENLDAP_ORG_DN, OPENLDAP_ADMIN_PASSWORD
gen_init_schema(){

  # Hash password before adding it
  ROOT_HASH=$(slappasswd -s $OPENLDAP_ADMIN_PASSWORD) || fatal 'Invalid password input!'

  # Initialize configuration
  cat << EOF > /tmp/ldap-init.ldif
# OpenLDAP Initalization
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: $OPENLDAP_ORG_DN
-
replace: olcRootDN
olcRootDN: cn=admin,$OPENLDAP_ORG_DN
-
replace: olcRootPW
olcRootPW: $ROOT_HASH

dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootDN
olcRootDN: cn=admin,cn=config
-
add: olcRootPW
olcRootPW: $ROOT_HASH

EOF
  
  # Initialize DIT
  cat << EOF > /tmp/org-init.ldif
# Organization Initalization
dn: $OPENLDAP_ORG_DN
objectclass: organization
objectclass: dcObject
o: $OPENLDAP_ORG_NAME
EOF

  cat << EOF > /tmp/users-ou.ldif
# Users Organizational Unit
dn: ou=Users,$OPENLDAP_ORG_DN
objectClass: organizationalUnit
ou: Users
EOF

  cat << EOF > /tmp/sensu-workshop-group.ldif
dn: cn=sensu-workshop,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-workshop
objectClass: groupOfNames
member:
EOF

  cat << EOF > /tmp/sensu-engineering-group.ldif
dn: cn=sensu-engineering,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-engineering
objectClass: groupOfNames
member:
EOF

  cat << EOF > /tmp/sensu-operations-group.ldif
dn: cn=sensu-operations,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-operations
objectClass: groupOfNames
member:
EOF

  cat << EOF > /tmp/sensu-sales-group.ldif
dn: cn=sensu-sales,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-sales
objectClass: groupOfNames
member:
EOF
  cat << EOF > /tmp/sensu-trainees-group.ldif
dn: cn=sensu-trainees,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-trainees
objectClass: groupOfNames
member:
EOF

  cat << EOF > /tmp/sensu-cluster-admins-group.ldif
dn: cn=sensu-cluster-admins,ou=Users,$OPENLDAP_ORG_DN
cn: sensu-cluster-admins
objectClass: groupOfNames
member:
EOF
}

#
# Main
#

# Variables
[[ -z ${OPENLDAP_ORG_NAME} ]] && fatal "Environment variable OPENLDAP_ORG_NAME must be set."
[[ -z ${OPENLDAP_ORG_DNS} ]] && fatal "Environment variable OPENLDAP_ORG_DNS must be set."
[[ -z ${OPENLDAP_ORG_DN} ]] && fatal "Environment variable OPENLDAP_ORG_DN must be set."
[[ -z ${OPENLDAP_ADMIN_PASSWORD} ]] && fatal "Environment variable OPENLDAP_ADMIN_PASSWORD must be set."
CERT_DIR='/config/certs'

# Generate certificates
info 'Generating self-signed certificates'
gen_certs && info 'Certificates generated'

# Configure slapd
info 'Initializing LDAP'
dpkg-reconfigure -f noninteractive slapd
gen_init_schema

# Move configuration to persistent location
cp -r /etc/ldap/slapd.d /config/ &&\
chown -R openldap:openldap /config ||\
fatal 'Could not save configuration'

# Apply schemas
start_ldap
sleep 1
LDAP_PID=`pgrep slapd`

info 'Importing LDAP configuration'
ldapmodify -a -Y EXTERNAL -H ldapi:/// -f /tmp/ldap-init.ldif || fatal 'Could not initialize server configuration!'

info 'Importing LDAP organization'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/org-init.ldif || fatal 'Could not create organization!'

info 'Importing LDAP User Organizational Unit'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/users-ou.ldif || fatal 'Could not create users organizational unit!'

info 'Importing LDAP engineering Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-engineering-group.ldif || fatal 'Could not create engineering group!'

info 'Importing LDAP workshop Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-workshop-group.ldif || fatal 'Could not create workshop group!'

info 'Importing LDAP operations Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-operations-group.ldif || fatal 'Could not create operations group!'

info 'Importing LDAP trainees Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-trainees-group.ldif || fatal 'Could not create operations group!'

info 'Importing LDAP cluster-admins Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-cluster-admins-group.ldif || fatal 'Could not create operations group!'

info 'Importing LDAP sales Group Definition'
ldapadd -H ldapi:/// -D cn=admin,$OPENLDAP_ORG_DN -w $OPENLDAP_ADMIN_PASSWORD -f /tmp/sensu-sales-group.ldif || fatal 'Could not create sales group!'

info 'Importing schemas'
for schema in /app/schema/*.ldif; do
    info "Applying $schema"
    ldapmodify -a -Y EXTERNAL -H ldapi:/// -f $schema || fatal "Could not apply ${schema}!"
done

sleep 1
kill -s SIGINT $LDAP_PID

# Mark service as configured
touch /config/.configured.flag

# Cleanup
rm -rf /tmp/*
#rm -rf /etc/ldap
