#!/usr/bin/env bash
#
# run-ords.sh: configure and start ORDS listener
# test

WALLET_PWD=PASSWORD_HERE
DB_PASS=PASSWORD_HERE


DCI_FILE=/home/oracle/dbc/dbms_cloud_install.sql
CERTS_FILE=/home/oracle/dbc/dbc_certs.tar
ACES_FILE=/home/oracle/dbc/dbc_aces.sql
VERIFY_FILE=/home/oracle/dbc/verify.sql

if test -f "$DCI_FILE" && test -f "$CERTS_FILE" && test -f "$ACES_FILE" && test -f "$VERIFY_FILE"; then
    echo "All files exist. Proceeding..."
else
    echo "Ensure the following files exist:"
    echo "$DCI_FILE"
    echo "$CERTS_FILE"
    echo "$ACES_FILE"
    echo "$VERIFY_FILE"
fi


mkdir -p /home/oracle/dbc/commonstore/wallets/ssl

echo "Calling dbms_cloud_install.sql..."

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl \
  -u sys/$DB_PASS \
  --force_pdb_mode 'READ WRITE' \
  -b dbms_cloud_install \
  -d /home/oracle/dbc \
  -l /home/oracle/dbc \
  dbms_cloud_install.sql

echo "Extracting dbc_certs.tar"

mkdir -p /home/oracle/dbc/commonstore/wallets/ssl
cd /home/oracle/dbc/commonstore/wallets/ssl
tar -xvf /home/oracle/dbc/dbc_certs.tar

echo "Creating wallets..."

orapki wallet create -wallet . -pwd $WALLET_PWD -auto_login
orapki wallet add -wallet . -trusted_cert -cert ./VeriSign.cer -pwd $WALLET_PWD
orapki wallet add -wallet . -trusted_cert -cert ./BaltimoreCyberTrust.cer -pwd $WALLET_PWD
orapki wallet add -wallet . -trusted_cert -cert ./DigiCert.cer -pwd $WALLET_PWD

echo "Updating sqlnet.ora"

echo "WALLET_LOCATION=
  (SOURCE=(METHOD=FILE)(METHOD_DATA=
  (DIRECTORY=/home/oracle/dbc/commonstore/wallets/ssl)))" >> $ORACLE_HOME/network/admin/sqlnet.ora

echo "Calling dbc_aces.sql"

sqlplus -s /nolog << EOF
CONNECT sys as sysdba/$DB_PASS;
@@/home/oracle/dbc/dbc_aces.sql
exit;
EOF