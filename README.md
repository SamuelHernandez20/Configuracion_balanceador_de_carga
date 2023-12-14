# Practica-01-11
En este Práctica había que implementar nuevamente un balanceador de carga, pero esta vez la arquitectura consta de las siguientes **máquinas virtuales**:

1. Balanceador.
2. Frontal Web 1.
3. Frontal Web 2.
4. Servidor NFS (Para la carpeta compartida del **/var/www/html**).
5. Servidor de Base de Datos MySQL.
   
La arquitectura de estas máquinas virtuales, se destinarán para los siguientes propositos:

1. Un **balanceador de carga**, implementado con un **Apache HTTP Server** configurado como **proxy inverso**.
2.  Una capa de **front-end**, formada por **dos servidores web** con **Apache HTTP Server**.
3.  La máquina virtual con el **NFS** destinado a la compartición del **/var/www/html** para que los frontales tengan acceso al mismo contenido.
4.  La capa destinada para la parte trasera (Backend).

 # Estructura de Directorios:

````
.
├── README.md
├── conf
│   ├── load-balancer.conf
│   └── 000-default.conf
├── exports
│   ├── exports
├── htaccess
│   ├── .htaccess
├── php
│   ├── index.php
└── scripts
    ├── .env
    ├── install_load_balancer.sh
    ├── install_lamp_frontend.sh
    ├── install_lamp_backend.sh
    ├── setup_letsencrypt_https.sh
    └── deployFrontend.sh
    └── deployBackend.sh
    └── servidor_nfs.sh
    └── cliente_nfs.sh

````

# 1. Configuración del Proxy inverso:

`Desde la el install_load_balancer.sh de la maquina balanceadora`


Incluiré las variables del **.env** variables que a continuación van a ser imprescindibles:

````
source .env
````

Se procede con la instalación del servidor de **Apache**:

````
apt install apache2 -y
````

Para poder configurarlo como **proxy inverso**, y que balancee, procedo con la **activación** de los módulos necesarios de Apache para configurarlo como **proxy inverso**

````
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
````

Seguidamente paso con la habilitación del algoritmo de balanceo de carga, el más común es el **Round Robin**:

````
a2enmod lbmethod_byrequests
````

Despues pasamos a copiar archivo el archivo de configuracion del balanceador hacia el **sites-available**

````
cp ../conf/load-balancer.conf /etc/apache2/sites-available
````
De manera automatizada haciendo referencia a las variables del **.env**, reemplazamos las variables de la plantilla con las **direcciones ip privada** de las
maquinas virtuales **frontales**:

````
sed -i "s/IP_HTTP_SERVER_1/$IP_HTTP_SERVER_1/" /etc/apache2/sites-available/load-balancer.conf
````
````
sed -i "s/IP_HTTP_SERVER_2/$IP_HTTP_SERVER_2/" /etc/apache2/sites-available/load-balancer.conf
````

Mediante el comando **a2ensite** procedo a habilitar el sitio del **virtualhost** actual:

````
a2ensite load-balancer.conf 
````
Luego procedo a deshabilitar el por defecto **000-default.conf**:

````
a2dissite 000-default.conf 
````

Reiniciamos:

````
systemctl restart apache2
````

