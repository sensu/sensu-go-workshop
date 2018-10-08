# Add the Sensu Core YUM repository
echo '[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/
gpgcheck=0
enabled=1' | tee /etc/yum.repos.d/sensu.repo

# Add the Sensu Enterprise YUM repository
echo "[sensu-enterprise]
name=sensu-enterprise
baseurl=http://$SE_USER:$SE_PASS@enterprise.sensuapp.com/yum/noarch/
gpgcheck=0
enabled=1" | tee /etc/yum.repos.d/sensu-enterprise.repo

# Add the Sensu Enterprise Dashboard YUM repository
echo "[sensu-enterprise-dashboard]
name=sensu-enterprise-dashboard
baseurl=http://$SE_USER:$SE_PASS@enterprise.sensuapp.com/yum/\$basearch/
gpgcheck=0
enabled=1" | tee /etc/yum.repos.d/sensu-enterprise-dashboard.repo

# Add the InfluxDB YUM repository
echo "[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key" | tee /etc/yum.repos.d/influxdb.repo

# Add the Grafana YUM repository
echo "[grafana]
name=grafana
baseurl=https://packagecloud.io/grafana/stable/el/7/\$basearch
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt" | tee /etc/yum.repos.d/grafana.repo

# Add the EPEL repositories (for installing Redis)
rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

# Import GPG keys
# curl -O https://repos.influxdata.com/influxdb.key
# curl -O https://packagecloud.io/gpg.key
# curl -O https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana
# cp influxdb.key gpg.key RPM-GPG-KEY-grafana /etc/pki/rpm-gpg/

# Install our packages
yum update
yum install -y yum-utils curl jq nc vim ntp redis sensu-enterprise sensu-enterprise-dashboard influxdb grafana
systemctl stop firewalld
systemctl disable firewalld

# Update Redis "bind" and "protected-mode" configs to allow external connections
sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis.conf
sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis.conf
sed -i 's/^;http_port = 3000/http_port = 4000/' /etc/grafana/grafana.ini

# Copy Sensu configuration files
cp -r /vagrant/files/etc/* /etc/
chmod +x /etc/sensu/plugins/*
chown -R sensu:sensu /etc/sensu
chown -R grafana:grafana /etc/grafana
cp -r /vagrant/files/var/* /var/

# Configure the shell
echo 'export PS1="demo $ "' >> ~/.bash_profile
echo 'alias l="pwd"' >> ~/.bashrc
echo 'alias ll="ls -Flag --color=auto"' >> ~/.bashrc

# Enable services to start on boot
systemctl start ntpd
systemctl enable ntpd
systemctl start redis
systemctl enable redis
systemctl start sensu-enterprise
chkconfig sensu-enterprise on
systemctl start sensu-enterprise-dashboard
chkconfig sensu-enterprise-dashboard on
systemctl start influxdb
chkconfig influxdb on
systemctl start grafana-server
systemctl enable grafana-server.service

# Create the InfluxDB database
influx -execute "CREATE DATABASE sensu;"

# Just in case, download the other packages we'll need for offline installation
yumdownloader sensu nginx nagios-plugins-http

# Print the VM IP Address and exit
echo
echo "This demo VM is up and running with the following network interfaces:"
ip address
echo "Happy Sensu-ing!"
