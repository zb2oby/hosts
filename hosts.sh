#!/bin/bash

####ATTENTION !! NE SUPPRIMER AUCUN COMMENTAIRES
####AUQUEL CAS LE FICHIER DE PARAMETRAGE NE SERA PLUS CAPABLE DE SE REPERER


do_start()  {
      #suppression des domaines
      sudo sed -i '/#mesdomainesdebut/,/#mesdomainesfin/d' /etc/hosts
      #suppression des balises
      sudo sed -i '/domaines/d' /etc/hosts
      #remise en place des balises dans /etc/hosts
      sudo echo '#mesdomainesdebut' | sudo tee --append /etc/hosts > /dev/null
      sudo echo '#mesdomainesfin' | sudo tee --append /etc/hosts > /dev/null

      ETH0=$(sudo arp -a | grep eth0 | cut -d " " -f 1)
      #var2
      SSID=$(sudo iwconfig 2> /dev/null | grep -o 'ESSID:.*' | cut -d '"' -f 2)

      #connexions
      if [ "x$SSID" = "xmabox1" ]
      then
        #couplesdebut
        sudo sed -i '/#mesdomainesdebut/ a\$ip1 $domaine1' /etc/hosts | sudo tee --append /etc/hosts > /dev/null
        sudo sed -i '/#mesdomainesdebut/ a\$ip2 $domaine2' /etc/hosts | sudo tee --append /etc/hosts > /dev/null
        #couplesfin
      fi

 }


do_stop()   {

  sudo killall hosts

}


case "$1" in
  start)
      do_start
      exit 0
      ;;
  stop)
      do_stop
      exit 0
      ;;

  *)

      echo -e "Usage : {start|stop}"

      ;;

esac

exit


