FROM ubuntu:18.04

# Install OpenLDAP
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y slapd ldap-utils openssl ca-certificates net-tools

# Copy project files
COPY resources /app
RUN mkdir -p /etc/ldap
COPY resources/ldap.conf /etc/ldap/ldap.conf

# Change to /app/
WORKDIR /app/

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Run your program under Tini
CMD ["/app/entrypoint.sh"]
