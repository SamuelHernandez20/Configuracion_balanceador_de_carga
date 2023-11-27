#!/bin/bash

#Muestra comandos que se van ejecutando por si falla:
set -ex

# Actualizamos los repositorios:

apt update

# Actualizar paquetes:

#apt upgrade -y

# Importamos el archivo de variables:

source .env

# Instalamos snapd

snap install core
snap refresh core

# Borrar instalaciones previas de certbot con apt:

apt remove certbot

# Instalamos la app cliente de certbot con snap

snap install --classic certbot

# Creamos un alias para la app de cerbot para no tener que ir a la ruta completa y poder ejecutarlos

ln -fs /snap/bin/certbot /usr/bin/certbot

# Obtener el certificado respuestas de certbot de manera automatizada

certbot --apache -m $CORREO --agree-tos --no-eff-email -d $dominio --non-interactive




