#!/usr/bin/env bash

# Needed files
DCI_FILE=/home/oracle/dbc/dbms_cloud_install.sql
CERTS_FILE=/home/oracle/dbc/dbc_certs.tar
ACES_FILE=/home/oracle/dbc/dbc_aces.sql
VERIFY_FILE=/home/oracle/dbc/verify.sql

DBC_DIR=/home/oracle/dbc/

# Check if DBC directory exists
if [ ! -d "$DBC_DIR" ]; then
    echo "$DBC_DIR does not exist. Creating..."
    mkdir -p $DBC_DIR
fi


# Check if dbms_cloud_install.sql exists
if test -f "$DCI_FILE"; then
    echo "$DCI_FILE exist. Proceeding..."
else
    cd $DBC_DIR
    echo "$DCI_FILE is missing. downloading..."
    wget https://raw.githubusercontent.com/wsanders00/DBMS_CLOUD/main/assets/dbms_cloud_install.sql
fi

# Check if dbc_certs.tar exists
if test -f "$CERTS_FILE"; then
    echo "$CERTS_FILE exist. Proceeding..."
else
    cd $DBC_DIR
    echo "$CERTS_FILE is missing. downloading..."
    wget https://objectstorage.us-phoenix-1.oraclecloud.com/p/QsLX1mx9A-vnjjohcC7TIK6aTDFXVKr0Uogc2DAN-Rd7j6AagsmMaQ3D3Ti4a9yU/n/adwcdemo/b/CERTS/o/dbc_certs.tar
fi

# Check if dbc_aces.sql exists
if test -f "$ACES_FILE"; then
    echo "$ACES_FILE exist. Proceeding..."
else
    cd $DBC_DIR
    echo "$ACES_FILE is missing. downloading..."
    wget https://raw.githubusercontent.com/wsanders00/DBMS_CLOUD/main/assets/dbc_aces.sql
fi
# Check if verify.sql exists
if test -f "$VERIFY_FILE"; then
    echo "$VERIFY_FILE exist. Proceeding..."
else
    cd $DBC_DIR
    echo "$VERIFY_FILE is missing. downloading..."
    wget https://raw.githubusercontent.com/wsanders00/DBMS_CLOUD/main/assets/verify.sql
fi