#!/bin/bash
source data.sh
echo ODOO_URL=$ODOO_URL
echo PGADMIN_URL=$PGADMIN_URL
#echo version=$version
/usr/local/bin/python ic-webapp-master/app.py

