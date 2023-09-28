#!/usr/bin/env bash
#
# install_dbms_cloud.sql - installs DBMS_CLOUD to 23c Oracle DB

# Passwords needed for file - please update.
WALLET_PWD=PASSWORD_HERE
DB_PASS=PASSWORD_HERE

# File locations
DCI_FILE=/home/oracle/dbc/dbms_cloud_install.sql
CERTS_FILE=/home/oracle/dbc/dbc_certs.tar
ACES_FILE=/home/oracle/dbc/dbc_aces.sql
VERIFY_FILE=/home/oracle/dbc/verify.sql
DBC_DIR=/home/oracle/dbc/

# Check and download needed files
# Check if DBC directory exists
if [ ! -d "$DBC_DIR" ]; then
    echo "$DBC_DIR does not exist. Creating..."
    mkdir -p $DBC_DIR
fi

# Check if dbms_cloud_install.sql exists
if test -f "$DCI_FILE"; then
    echo "$DCI_FILE exist. Proceeding..."
else
    echo "$DCI_FILE is missing. Exiting..."
    exit 1
fi

# Check if dbc_certs.tar exists
if test -f "$CERTS_FILE"; then
    echo "$CERTS_FILE exist. Proceeding..."
else
    echo "$CERTS_FILE is missing. Downloading..."
    cd $DBC_DIR
    wget https://objectstorage.us-phoenix-1.oraclecloud.com/p/QsLX1mx9A-vnjjohcC7TIK6aTDFXVKr0Uogc2DAN-Rd7j6AagsmMaQ3D3Ti4a9yU/n/adwcdemo/b/CERTS/o/dbc_certs.tar
    
fi

# Check if dbc_aces.sql exists
if test -f "$ACES_FILE"; then
    echo "$ACES_FILE exist. Proceeding..."
else
    cd $DBC_DIR
    echo "$ACES_FILE is missing. Exiting..."
    exit 1
fi
# Check if verify.sql exists
if test -f "$VERIFY_FILE"; then
    echo "$VERIFY_FILE exist. Proceeding..."
else
    echo "$VERIFY_FILE is missing. Exiting..."
    exit 1
fi

# Make wallet directory
if [ ! -d "/home/oracle/dbc/commonstore/wallets/ssl" ]; then
    echo "/home/oracle/dbc/commonstore/wallets/ssl does not exist. Creating..."
    mkdir -p /home/oracle/dbc/commonstore/wallets/ssl
fi

echo "Calling dbms_cloud_install.sql..."

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl \
  -u sys/$DB_PASS \
  --force_pdb_mode 'READ WRITE' \
  -b dbms_cloud_install \
  -d /home/oracle/dbc \
  -l /home/oracle/dbc \
  dbms_cloud_install.sql

echo "Extracting $CERTS_FILE"

cd /home/oracle/dbc/commonstore/wallets/ssl
tar -xvf $CERTS_FILE

echo "Creating wallets..."

orapki wallet create -wallet . -pwd $WALLET_PWD -auto_login
orapki wallet add -wallet . -trusted_cert -cert ./VeriSign.cer -pwd $WALLET_PWD
orapki wallet add -wallet . -trusted_cert -cert ./BaltimoreCyberTrust.cer -pwd $WALLET_PWD
orapki wallet add -wallet . -trusted_cert -cert ./DigiCert.cer -pwd $WALLET_PWD

echo "Updating sqlnet.ora"
SQLNET_STRING="WALLET_LOCATION=
  (SOURCE=(METHOD=FILE)(METHOD_DATA=
  (DIRECTORY=/home/oracle/dbc/commonstore/wallets/ssl)))"

SQLNET_FILE=$ORACLE_HOME/network/admin/sqlnet.ora

if grep -Fxq "$SQLNET_STRING" $SQLNET_FILE
then
    	echo "Wallet string already exists in $SQLNET_FILE"
else
    	echo "Wallet does not exist in $SQLNET_FILE. Adding..."
      echo "WALLET_LOCATION=
        (SOURCE=(METHOD=FILE)(METHOD_DATA=
        (DIRECTORY=/home/oracle/dbc/commonstore/wallets/ssl)))" >> $ORACLE_HOME/network/admin/sqlnet.ora
fi

echo "Done, please execute $ACES_FILE"
echo "Run script in the root container as:"
echo "conn / as sysdba
@@/home/oracle/dbc/dbc_aces.sql"

echo "Then run $VERIFY_FILE as:"
echo "conn / as sysdba
@/home/oracle/dbc/verify.sql"