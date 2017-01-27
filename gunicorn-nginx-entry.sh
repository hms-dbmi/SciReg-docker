#!/bin/bash

/vault/vault auth $ONETIME_TOKEN

DJANGO_SECRET=$(/vault/vault read -field=value $VAULT_PATH/django_secret)
AUTH0_DOMAIN_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_domain)
AUTH0_CLIENT_ID_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_client_id)
AUTH0_SECRET_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_secret)
AUTH0_SUCCESS_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_success_url)
ACCOUNT_SERVER_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/account_server_url)
PERMISSION_SERVER_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/permission_server_url)
CONFIRM_EMAIL_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/confirm_email_url)

MYSQL_USERNAME_VAULT=$(/vault/vault read -field=value $VAULT_PATH/mysql_username)
MYSQL_PASSWORD_VAULT=$(/vault/vault read -field=value $VAULT_PATH/mysql_pw)
MYSQL_HOST_VAULT=$(/vault/vault read -field=value $DB_VAULT_PATH/mysql_host)
MYSQL_PORT_VAULT=$(/vault/vault read -field=value $VAULT_PATH/mysql_port)

export SECRET_KEY=$DJANGO_SECRET
export AUTH0_DOMAIN=$AUTH0_DOMAIN_VAULT
export AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID_VAULT
export AUTH0_SECRET=$AUTH0_SECRET_VAULT
export AUTH0_SUCCESS_URL=$AUTH0_SUCCESS_URL_VAULT
export ACCOUNT_SERVER_URL=$ACCOUNT_SERVER_URL_VAULT
export PERMISSION_SERVER_URL=$PERMISSION_SERVER_URL_VAULT
export CONFIRM_EMAIL_URL=$CONFIRM_EMAIL_URL_VAULT

export MYSQL_USERNAME=$MYSQL_USERNAME_VAULT
export MYSQL_PASSWORD=$MYSQL_PASSWORD_VAULT
export MYSQL_HOST=$MYSQL_HOST_VAULT
export MYSQL_PORT=$MYSQL_PORT_VAULT

cd /SciReg/

python manage.py migrate
python manage.py collectstatic --no-input

/etc/init.d/nginx restart

cmd="python -m smtpd -n -c DebuggingServer localhost:1025"
nohup $cmd &

gunicorn SciReg.wsgi:application -b 0.0.0.0:8006

