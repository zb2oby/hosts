#!/bin/bash


do_wifi() {
      sleep 1
      # recherche dans host.sh la ligne de if contenant les ssid
      line0=$(sudo cat testhosts.sh | grep -o -n "SSID\" = " | cut -d : -f 1 | uniq)

      #suppression de la ligne
      if [ "$line0" != "" ]; then
          sudo sed -i "$line0"'d' testhosts.sh
      fi

      #tableazu des SSID
      declare -a tableau_box

      #Tant qu'on desire ajouter des SSID on rempli le tableau
      while [ "x$oui" != "xn" ]; do

          oui="o"

          if [ "x$oui" = "xo" ]; then
              sleep 1
              echo -e "\033[33mindiquer le SSID du réseau\033[0m"
              read -r box
              tableau_box+=("$box")
          else
            break
          fi

          echo -e "\033[33mya t'il un autre reseau préféré ? o/n\033[0m"
          read -r oui

      done

      #construction de la commande sed pour générer le if du script hosts.sh
      ifClause="/#connexions/ a\if "
      #pour chaque SSID contenu dans le tableau on rajoute une clause au if
      for i in "${!tableau_box[@]}"; do
          ifClause+="[ \"x\$SSID\" = \"x${tableau_box[i]}\" ]"
          if [ "${tableau_box[i]}" != "${tableau_box[-1]}" ]; then
            ifClause+=' || '
          fi
      done
      # on integre dans le if les SSID indiqués
      sudo sed -i "$ifClause" testhosts.sh
      sleep 1
      echo -e "\033[32mVos réseaux ont bien été enregistrés \n"


}
#fin de fonction do_wifi







do_eth() {


    		echo -e "\033[31m2/ENREGISTREMENT DE LA CONNEXION FILAIRE \n"
    		sleep 1

    		while [ "$cable" != ok ]; do
        	cable=$(sudo mii-tool | sed 's/.* //')

        	if [ "$cable" != ok ]; then

          		echo -e "\033[31mVotre cable n'est pas ou est mal branché, verifiez le et validez par entrée \n"
          		echo -e "\033[33mSinon pour ignorer cette étape tapez n\033[0m"
          		read -r n

        	fi

        	if [ "$n" = n ]; then
          		break

        	fi

    		done

        	if [ "$n" != n ]; then
          		eth=$(sudo mii-tool | cut -d : -f 1)
          		sed -i 's/^\(if.*SSID\).*$/& || [ \"x$ETH0\" = \"x'$eth'\" ]/g' hosts.sh
          		echo -e "\033[32mParametrage de la connexion filaire terminé \n"

        	fi



}
#fin de fonction do_eth





do_couple() {

	sleep 2
	# Renseigner l'ip et le ou les domaines à reecrire dans le vhosts
	echo -e "\n\033[31m3/ ENREGISTREMENT DES COUPLES IP/DOMAINE"
	sleep 1
	echo -e "\033[32mVous pouvez renseigner deux couples IP/DOMAINE maximum \n"
	sleep 1
	echo -e "\033[33mIndiquer la premiere IP Locale\033[0m"
	read -r ip0
	sleep 1
	echo -e "\033[33mIndiquer le domaine relié à la premiere IP Locale\033[0m"
	read -r dom0
	sleep 1
	echo -e "\033[33mY aura t'il un autre couple IP/DOMAINE ? o/n\033[0m"
	read -r oui0

	if [ "x$oui0" != "xo" ]; then
    		#suppression et recreation des lignes existentes
    		sudo sed -i '/#couple1debut/,/#couple1fin/d' hosts.sh
    		sudo sed -i '/#couple2debut/,/#couple2fin/d' hosts.sh
    		sudo sed -i '/#coupledebut/ a\#couple1debut' hosts.sh
    		sudo sed -i '/#couple1debut/ a\#couple1fin' hosts.sh
    		sudo sed -i '/#couple1fin/ a\#couple2debut' hosts.sh
    		sudo sed -i '/#couple2debut/ a\#couple2fin' hosts.sh
    		#integration du nouveau couple
    		sudo sed -i '/#couple1debut/ a\sudo sed \-i '\''/#mesdomainesdebut/ a\\'$ip0'\ '$dom0''\'' /etc/hosts \| sudo tee \-\-append /etc/hosts \> \/dev\/null' hosts.sh
    		sleep 1
    		echo -e "\033[32mLe couple IP/DOMAINE à bien été paramétré \n"
	else
    		echo -e "\033[33mIndiquer la seconde IP Locale\033[0m"
    		read -r ip1
    		sleep 1
    		echo -e "\033[33mIndiquer le DOMAINE relié à la seconde IP Locale\033[0m"
    		read -r dom1
    		#suppression couple existant
    		sudo sed -i '/#couple1debut/,/#couple1fin/d' hosts.sh
    		sudo sed -i '/#couple2debut/,/#couple2fin/d' hosts.sh
    		sudo sed -i '/#coupledebut/ a\#couple1debut' hosts.sh
    		sudo sed -i '/#couple1debut/ a\#couple1fin' hosts.sh
    		sudo sed -i '/#couple1fin/ a\#couple2debut' hosts.sh
    		sudo sed -i '/#couple2debut/ a\#couple2fin' hosts.sh 
    		#integration nouveaux couples
    		sudo sed -i '/#couple1debut/ a\sudo sed \-i '\''/#mesdomainesdebut/ a\\'$ip0'\ '$dom0''\'' /etc/hosts \| sudo tee \-\-append /etc/hosts > /dev/null' hosts.sh
    		sudo sed -i '/#couple2debut/ a\sudo sed \-i '\''/#mesdomainesdebut/ a\\'$ip1'\ '$dom1''\'' /etc/hosts \| sudo tee \-\-append /etc/hosts > /dev/null' hosts.sh
    		sleep 1
    		echo -e "\033[32mLes deux couples IP/DOMAINES ont bien été paramétrés \n"

	fi


}
#fin de fonction do_couple





do_startup_config() {

	sleep 1
	echo -e "\033[31m3/ PARAMETRAGE DE L'APPLICATION AU DEMARRAGE \n"
	sleep 20
	#deplacement  de l'executable
	if test ! -f /usr/bin/hosts; then
    		chmod +x hosts.sh
        	sudo cp hosts.sh /usr/bin/hosts
	else
    		sudo rm /usr/bin/hosts
    		chmod +x hosts.sh
    		sudo cp hosts.sh /usr/bin/hosts

	fi


	#creation du service systemd

	if test ! -f /etc/systemd/system/hosts.service; then
    		sudo cp hosts.service /etc/systemd/system/hosts.service
    		sudo chmod +x /etc/systemd/system/hosts.service
    		sudo systemctl enable hosts.service > /dev/null
    	else
        	sudo systemctl stop hosts.service > /dev/null
        	sudo systemctl daemon-reload
    	fi

	sleep 1
	echo -e "\033[32mParamétrage Terminé\033[0m"
	echo -e "\033[31mPour supprimer ce parametrage executez la commande : sudo systemctl disable hosts.service\033[32m \n"


}
#fin de fonction config




# début de script


#on change les droits du fichier hosts
sudo chmod 0777 hosts.sh

#Renseigner les ssid des reseaux préférés afin de rendre le script facilement utilisable au départ
echo -e "\033[31m1/ ENREGISTREMENT DES RESEAUX WIFI PREFERES"
sleep 1
echo -e "\033[32mVous pouvez enregistrer tous les SSID wifi que vous utilisez regulierement \n"
sleep 1
echo -e "Recherche des réseaux disponibles actuellement \n"
sleep 1

nmcli dev wifi list &> .nm.log
sudo iwlists scan &> .iw.log
#recuperation des derniers caractere des sorties des commandes précédentes.
nm=$(< .nm.log sed 's/.* //')
iw=$(< .iw.log sed 's/.* //')
#si dernier caractere est 'introuvable' ou 'found'
if [ "x$nm" = "xintrouvable" ] || [ "x$nm" = "xfound" ];then

    case "x$iw" in
        #si la sortie de la commande iwlist est not found ou introuvable
        "xintrouvable" | "xfound")
            echo -e "\033[31mcertaines dépendances ne sont pas satisfaites \nLa recherche des SSID necessite le paquet network-manager ou wireless-tools \n"
            echo -e "\033[32mVous pouvez néanmoins renseigner des SSID manuellement \n"
            #on execute tout de meme do_wifi pour permettre l'enregistrement manuel des reseaux
            do_wifi
            ;;
        #sinon
        *)
            sudo iwlist scan 2> /dev/null | grep ESSID | cut -d : -f 2
            #check si interface wifi existe
            wifi=$(sudo iwconfig 2>/dev/null | grep 802.11 | cut -f1 -d' ')
            if [ -z "$wifi" ]; then
              echo -e "Aucune interface wifi sur cet appareil \n"
              echo -e "\033[31mVous pouvez néanmoins renseigner des SSID manuellement \n"
            fi
            do_wifi
            ;;

    esac
else

    nmcli dev wifi list
    do_wifi

fi



sudo rm .iw.log 2> /dev/null
sudo rm .nm.log 2> /dev/null



sleep 1
#integrer l'interface filaire pour les cas de connexions filaires
echo -e "\033[33mSouhaitez vous enregistrer votre interface filaire ? o/n"
echo -e "(vous aurez besoin d'être connecté via un cable reseau)\033[0m"
read -r oui1

if [ "x$oui1" = "xo" ]; then
    sudo mii-tool &> .cab.log
    cab=$(< .cab.log sed 's/.* //')

    if [ "x$cab" = "xintrouvable" ] || [ "x$cab" = "xfound" ];then

        echo -e "\033[31mcertaines dépendances ne sont pas satisfaites \nle paramétrage de la liaison filaire necessite le paquet ethtool ou net-tools \n\033[0m"

    else

        do_eth

    fi
fi


sudo rm .cab.log 2> /dev/null


do_couple


do_startup_config






#deplacement des fichiers telechargés
if test ! -d /opt/hosts; then
    sudo mkdir /opt/hosts
	sudo mv README.md /opt/hosts/README.md
	sudo mv hosts.sh /opt/hosts/hosts.sh
	sudo mv hosts.service /opt/hosts/hosts.service
fi

sleep 1

echo -e "Vos réecritures de domaines sont désormais configurées, \nvous pouvez retrouver les fichiers dans le dossier 'hosts' situé dans votre '/opt'\n"
sleep 1
echo -e "\033[31mun redémarrage de la session est nécessaire \n\033[31mAprès redemarrage assurez vous que /etc/hosts ai bien été écrit comme voulu \n \n\033[32mENJOY !!\033[0m"

if test ! -f /opt/hosts/install.sh; then
    	sudo mv install.sh /opt/hosts/install.sh

fi



exit