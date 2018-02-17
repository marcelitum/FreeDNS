# scp remote@192.168.1.102:sinapsis4.sh sinapsis4.sh
if [ -e /tmp/root/instala.xxx ]
then
  /usr/sbin/nvram unset id_rsa
  /usr/sbin/nvram unset known_hosts
  /usr/sbin/nvram unset sinapsis
  /usr/sbin/nvram unset cron_jobs
  /bin/rm /tmp/root/instala.xxx
fi
/usr/sbin/nvram set resetbutton_enable=0
/usr/sbin/nvram commit
ClienteNombre="your_client_Router"
WebLink="bit.do/your_page"
usuario="your_remote_user"

dia="$(date "+%y%m%d%H")"

ClienteNombre="$dia.$ClienteNombre"
/usr/sbin/nvram get wan_ipaddr > "/tmp/root/$ClienteNombre"
/usr/bin/wget -O /tmp/root/sinapsis $WebLink
SaleIP="$(grep "IP:" /tmp/root/sinapsis | sed 's/^.*\(IP:.*span\).*$/\1/' | sed -r 's/.{6}$//' | sed -r 's/.{4}//')"
/bin/rm /tmp/root/sinapsis

#  ojo
# SaleIP="192.168.1.100"

if [ "$(/usr/sbin/nvram get id_rsa)" = ""  ]
then
  if [ ! -e /tmp/root/.ssh/id_rsa ]
  then
    /usr/sbin/dropbearkey -t rsa -f /tmp/root/.ssh/id_rsa > /tmp/root/.ssh/authorized_keys
    /bin/cat /tmp/root/.ssh/authorized_keys  | grep "^ssh-rsa "  > /tmp/root/.ssh/authorized_keys2
    /bin/mv /tmp/root/.ssh/authorized_keys2 /tmp/root/.ssh/authorized_keys
    /usr/sbin/dropbearconvert dropbear openssh /tmp/root/.ssh/id_rsa /tmp/root/.ssh/id_rsa2
    /usr/sbin/nvram set id_rsa="$(/bin/cat /tmp/root/.ssh/id_rsa2)"
    /bin/rm /tmp/root/.ssh/id_rsa2
    /bin/rm /tmp/root/.ssh/id_rsa
    /bin/mv /tmp/root/.ssh/known_hosts /tmp/root/.ssh/known_hosts.old
    Orden3="/usr/bin/scp -P 22222 /tmp/root/.ssh/authorized_keys remote@$SaleIP:authorized_keys"
    /bin/echo "------------------------------------------------------------------"
    /bin/echo "Acepte el nuevo host y luego ingrese la clave del usuario $usuario"
    /bin/echo "------------------------------------------------------------------"
    /bin/echo "----------$Orden3-----------"
    $Orden3
    /usr/sbin/nvram set known_hosts="$(/bin/cat /tmp/root/.ssh/known_hosts | sed 's/^.*\(ssh-rsa .*\).*$/\1/' | sed -r 's/.{8}//')"
    /usr/sbin/nvram commit
    /bin/echo "---------------------------------------------------------------------------------------------"
    /bin/echo "La llave autorizada fue copiada al usuario $usuario AGREGUELA a $usuario/.ssh/authorized_keys"
    /bin/echo "---------------------------------------------------------------------------------------------"
    read -n1 -r -p "Presione espacio para continuar..." key
    /bin/rm /tmp/root/.ssh/known_hosts
    /bin/mv /tmp/root/.ssh/known_hosts.old /tmp/root/.ssh/known_hosts
    /bin/rm /tmp/root/.ssh/authorized_keys
  fi
fi
# Instalacion FIN

/usr/sbin/nvram get id_rsa > /tmp/root/.ssh/id_rsa1
/usr/sbin/dropbearconvert openssh dropbear /tmp/root/.ssh/id_rsa1 /tmp/root/.ssh/id_rsa
/bin/mv /tmp/root/.ssh/known_hosts /tmp/root/.ssh/known_hosts.res
/bin/echo "$SaleIP ssh-rsa" > /tmp/root/.ssh/known_hosts2
/usr/sbin/nvram get known_hosts >> /tmp/root/.ssh/known_hosts2
/bin/cat /tmp/root/.ssh/known_hosts2 | sed ':a;N;$!ba;s/\n/ /g' > /tmp/root/.ssh/known_hosts
/bin/rm /tmp/root/.ssh/known_hosts2
Orden4="/usr/bin/scp -P 22222 -i /tmp/root/.ssh/id_rsa /tmp/root/$ClienteNombre remote@$SaleIP:$ClienteNombre"
/bin/echo "----------$Orden4-----------"
$Orden4
/bin/rm /tmp/root/$ClienteNombre
/bin/rm /tmp/root/.ssh/known_hosts
/bin/mv /tmp/root/.ssh/known_hosts.res /tmp/root/.ssh/known_hosts
/bin/rm /tmp/root/.ssh/id_rsa1
/bin/rm /tmp/root/.ssh/id_rsa
if [ "$(/usr/sbin/nvram get sinapsis)" = ""  ]
then
  /usr/sbin/nvram set sinapsis="$(/bin/cat /tmp/root/sinapsis.sh)"
fi
if [ "$(/usr/sbin/nvram get cron_jobs)" = ""  ]
then
  /usr/sbin/nvram set cron_jobs="0 * * * * root nvram get FreeDNS > /tmp/root/FreeDNS.sh; chmod 700 /tmp/root/FreeDNS.sh; sh /tmp/root/FreeDNS.sh &"
  /usr/sbin/nvram commit
  stopservice cron && startservice cron
fi
/usr/sbin/nvram commit
