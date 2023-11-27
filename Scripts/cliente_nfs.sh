# Instalación de paquetes necesarios en el cliente NFS:

apt install nfs-common -y

# Montaje de la carpeta estableciendo la ip del servidor NFS:

mount $IP_NFS:/var/www/html /var/www/html

