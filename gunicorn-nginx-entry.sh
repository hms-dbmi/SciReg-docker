#!/bin/bash

/vault/vault auth $ONETIME_TOKEN

DJANGO_SECRET=$(/vault/vault read -field=value $VAULT_PATH/django_secret)
AUTH0_DOMAIN_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_domain)
AUTH0_CLIENT_ID_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_client_id)
AUTH0_SECRET_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_secret)
AUTH0_SUCCESS_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/auth0_success_url)
ACCOUNT_SERVER_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/account_server_url)
PERMISSION_SERVER_URL_VAULT=$(/vault/vault read -field=value $VAULT_PATH/permission_server_url)

export SECRET_KEY=$DJANGO_SECRET
export AUTH0_DOMAIN=$AUTH0_DOMAIN_VAULT
export AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID_VAULT
export AUTH0_SECRET=$AUTH0_SECRET_VAULT
export AUTH0_SUCCESS_URL=$AUTH0_SUCCESS_URL_VAULT
export ACCOUNT_SERVER_URL=$ACCOUNT_SERVER_URL_VAULT
export PERMISSION_SERVER_URL=$PERMISSION_SERVER_URL_VAULT

cd /SciReg/

python manage.py migrate
python manage.py collectstatic --no-input

/etc/init.d/nginx restart

gunicorn SciReg.wsgi:application -b 0.0.0.0:8006