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

