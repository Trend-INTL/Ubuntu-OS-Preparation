#!/bin/bash
echo -e "\n
###############################################################################\n
# ############################################################################ #\n
# #                                                                          # #\n
# # ########  #####    ######  ###     ##  #####            #####      ##### # #\n
# #    ##     ##  ##   ##      ## #    ##  ##  ###         ### ###      # #  # #\n
# #    ##     ######   ## ##   ##  #   ##  ##   ###       ###   ###     # #  # #\n
# #    ##     ##  ##   ## ##   ##   #  ##  ##   ###      ###########    # #  # #\n
# #    ##     ##   ##  ##      ##    # ##  ##  ###      ###       ###   # #  # #\n
# #    ##     ##   ##  ######  ##     ###  #####       ####       #### ##### # #\n
# #                                                                          # #\n
# ############################################################################ #\n
################################################################################
"
# Script for installing Odoo 17.0 on Ubuntu 24.04
# Author: AHMED OUF
#-------------------------------------------------------------------------------
# This script will install Odoo on your Ubuntu server. It can install multiple Odoo instances
# in one Ubuntu because of the different xmlrpc_ports
#-------------------------------------------------------------------------------
# Do Not Forget to  Change xmlrpc_port
# cd
# sudo nano erp_install.sh
# Place this content in it and then make the file executable:
# sudo chmod +x erp_install.sh
# Execute the script to install Odoo 17.0:
# ./erp_install.sh
################################################################################

# Create PostgreSQL user for Odoo
sudo service erp stop
sudo -u postgres psql -c "drop database erpdb;"
sudo -u postgres psql -c "drop role erp;"
sudo -u postgres createuser -d -R -S $USER
sudo -u postgres psql -c "drop database erpdb;"
sudo service postgresql restart

# Create Odoo directory
sudo rm -rf /opt/odoo17/erp
sudo mkdir /opt/odoo17/erp
sudo chmod +x /opt/odoo17/erp
sudo chown $USER:$USER /opt/odoo17/erp

# Clone Odoo repository
git clone https://www.github.com/odoo/odoo --branch 17.0 --depth 1 /opt/odoo17/erp/odoo

# Change Odoo Directory Own and Conf:
sudo chmod +x /opt/odoo17/erp/odoo
sudo chown $USER:$USER /opt/odoo17/erp/odoo

# Create Python virtual environment in Odoo directory
python3.10 -m venv /opt/odoo17/erp/odoo/venv

# Activate the virtual environment
source /opt/odoo17/erp/odoo/venv/bin/activate

# Install required Python packages for Odoo
# pip install -r /opt/odoo17/erp/odoo/requirements.txt

sudo apt install python3-pip
sudo apt install python3-pip --reinstall
pip install --upgrade pip

# Install Python dependencies with resolved versions
pip install \
    Babel==2.9.1 \
    chardet==4.0.0 \
    cryptography==3.4.8 \
    decorator==4.4.2 \
    docutils==0.17 \
    ebaysdk==2.1.5 \
    freezegun==1.1.0 \
    geoip2==2.9.0 \
    gevent==22.10.2 \
    greenlet==2.0.2 \
    idna==2.10 \
    libsass==0.20.1 \
    lxml==5.2.1 \
    lxml_html_clean \
    Jinja2 \
    MarkupSafe==2.1.2 \
    num2words==0.5.10 \
    ofxparse==0.21 \
    passlib==1.7.4 \
    Pillow==9.4.0 \
    polib==1.1.1 \
    psutil==5.9.4 \
    psycopg2-binary \
    pydot==1.4.2 \
    pyopenssl==21.0.0 \
    PyPDF2 \
    pyserial==3.5 \
    python-dateutil==2.8.1 \
    python3-ldap \
    python-stdnum==1.17 \
    pyusb==1.2.1 \
    qrcode==7.3.1 \
    reportlab==3.6.12 \
    requests==2.25.1 \
    rjsmin==1.1.0 \
    urllib3==1.26.5 \
    vobject==0.9.6.1 \
    Werkzeug==2.0.2 \
    xlrd==1.2.0 \
    XlsxWriter==3.0.2 \
    xlwt==1.3.* \
    zeep==4.1.0 \
    html2text \
    boto3

# To Install Whatsapp you have to install html2text
pip install html2text

# Before installing this module, you need to install librariesboto3 :
pip3 install boto3

# Before installing this module auto_database_backup, you need to install dropbox:
# This module uses an external python dependency 'dropbox'. Before installing the module install the python package first. The required python package can be installed using the following command,
pip install dropbox
# This module uses an external python dependency 'nextcloud'. Before installing the module install the python package first. The required python package can be installed using the following command,
pip install pyncclient
# This module uses an external python dependency 'nextcloud-api-wrapper'. Before installing the module install the python package first. The required python package can be installed using the following command,
pip install nextcloud-api-wrapper
# This module uses an external python dependency 'Boto3'. Before installing the module install the python package first. The required python package can be installed using the following command,
pip install boto3
# This module uses an external python dependency 'paramiko'. Before installing the module install the python package first. The required python package can be installed using the following command,
pip install paramiko

# Deactivate the virtual environment
deactivate

# Remove Apache2 Service
sudo systemctl stop apache2
sudo apt purge apache2
sudo apt autoremove
sudo rm -rf /etc/apache2
sudo rm -rf /var/www/html
systemctl status apache2

# Create Odoo configuration file
sudo rm -rf /var/log/odoo17
sudo mkdir /var/log/odoo17
sudo chmod -p +x /var/log/odoo17
sudo chown -p erp:erp /var/log/odoo17
sudo rm -rf /etc/erp.conf
sudo tee /etc/erp.conf > /dev/null <<EOF
[options]
; This is the password that allows database operations:
; admin_passwd = 123456
db_host = False
db_port = False
; db_user = erp
db_password = False
addons_path = /opt/odoo17/erp/odoo/addons, /opt/odoo17/addons
logfile = /var/log/odoo17/erp.log
xmlrpc_port = 8099
worker = 5
proxy_mode = True
EOF

# Change Conf File Own and Conf:
sudo chmod +x /etc/erp.conf
sudo chown $USER:$USER /etc/erp.conf

# Create systemd service file for Odoo
sudo rm -rf /etc/systemd/system/erp.service
sudo tee /etc/systemd/system/erp.service > /dev/null <<EOF
[Unit]
Description=Odoo 17.0 for erp
Documentation=https://www.odoo.com
[Service]
# Ubuntu/Debian convention:
Type=simple
User=$USER
ExecStart=/opt/odoo17/erp/odoo/venv/bin/python3 /opt/odoo17/erp/odoo/odoo-bin -c /etc/erp.conf -l /var/log/odoo17/erp.log
[Install]
WantedBy=default.target
EOF

# Change Service File Own and Conf:
sudo chmod +x /etc/systemd/system/erp.service
sudo chown $USER:$USER /etc/systemd/system/erp.service

# Start and enable Odoo service
sudo systemctl daemon-reload
sudo systemctl start erp.service
sudo systemctl enable erp.service
sudo systemctl restart erp.service
sudo service erp restart

# Allow HTTP and HTTPS traffic through the firewall
#sudo ufw allow http
#sudo ufw allow https
echo "==========================================================================================================="
echo "	Odoo 17 installation for erp is complete. You can access it at http://your_server_ip:8079"
echo "	Do Not Forget to Add Certbot Certificate using command: /source odoo_env/bin/activate & sudo certbot"
echo "	Do Not Forget to Activate Firewall using command: sudo ufw allow 'Nginx Full' & sudo ufw delete allow 'Nginx HTTP'"
