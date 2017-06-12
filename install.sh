#!/bin/bash


do_wifi() {

	#check si interface wifi existe
	wifi=$(sudo iwconfig 2>/dev/null | grep 802.11 | cut -f1 -d' ')
	if [ ! -z "$wifi" ]; then
		    sleep 1
        	echo -e "\033[33m\nIndiquez maintenant le SSID du principal reseau préféré (attention à la casse)\033[0m"
        	read -r box
        	sleep 1
        	echo -e "\033[33mya t'il un autre reseau préféré ? o/n\033[0m"
        	read -r oui

        	if [ "x$oui" = "xo" ]; then
            	# cas de deux SSID
            	sleep 1
            	echo -e "\033[33mindiquer le SSID du second réseau\033[0m"
            	read -r box1

            		# on supprime les eventuelle lignes existente contenant les deux ssid indiqués
	        	line0=$(sudo cat hosts.sh | grep -o -n "SSID\" = " | cut -d : -f 1 | uniq)

	        	if [ "$line0" != "" ]; then
	            	sudo sed -i "$line0"'d' hosts.sh

	        	fi

            	# on integre dans le if les deux SSID indiqués
            	sudo sed -i '/#connexions/ a\if [ \"x$SSID\" = \"x'$box'\" ] || [ \"x$SSID\" = \"x'$box1'\" ]' hosts.sh
            	sleep 1
            	echo -e "\033[32mVos réseaux ont bien été enregistré \n"

        	# cas d'un seul SSID

		else

	        	# on supprime les eventuelles lignes existentes contenants le ssid indiqué
	        	line1=$(sudo cat hosts.sh | grep -o -n "SSID\" = " | cut -d : -f 1 | uniq)

	        	if [ "$line1" != "" ]; then
	            	sudo sed -i "$line1"'d' hosts.sh

	        	fi

            	#on integre dans le if le SSID unique indiqué
            	sudo sed -i '/#connexions/ a\if [ \"x$SSID\" = \"x'$box'\" ]' hosts.sh 
            	sleep 1
            	echo -e "\033[32mVos réseaux ont bien été enregistrés \n"

        	fi



	else
    		echo -e "Aucune interface wifi sur cet appareil \n"

	fi
}
#fin de fonction do_wifi







do_eth() {

	sleep 1
	#integrer l'interface filaire pour les cas de connexions filaires
	echo -e "\033[33mSouhaitez vous enregistrer votre interface filaire ? o/n" 
	echo -e "(vous aurez besoin d'être connecté via un cable reseau)\033[0m"

	read -r oui1

	if [ "x$oui1" = "xo" ]; then
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
echo -e "\033[32mVous pouvez enregistrer jusqu'à 2 SSID wifi que vous utilisez regulierement \n"
sleep 1
echo -e "Ci-dessous les réseaux disponibles actuellement \n"
sleep 1




nmclis dev wifi list &> .nm.log
sudo iwlists scan &> .iw.log
nm=$(< .nm.log sed 's/.* //')
iw=$(< .iw.log sed 's/.* //')

if [ "x$nm" = "xintrouvable" ] || [ "x$nm" = "xfound" ];then

    case "x$iw" in
        "xintrouvable" | "xfound")

        echo -e "\033[31mcertaines dépendances ne sont pas satisfaites \nl'installation necessite le paquet network-manager ou wireless-tools \n" ;;

        *)

        sudo iwlist scan 2> /dev/null | grep ESSID | cut -d : -f 2
        do_wifi ;;

    esac


else

    nmcli dev wifi list
    do_wifi

fi



sudo rm .iw.log 2> /dev/null
sudo rm .nm.log 2> /dev/null




sudo mii-tool &> .cab.log
cab=$(< .cab.log sed 's/.* //')

if [ "x$cab" = "xintrouvable" ] || [ "x$cab" = "xfound" ];then

    echo -e "\033[31mcertaines dépendances ne sont pas satisfaites \nle paramétrage de la liaison filaire necessite le paquet ethtool \n\033[0m"

else

    do_eth

fi


sudo rm .cab.log 2> /dev/null


do_couple


do_startup_config






#deplacement des fichiers telechargés
user=$(logname)
if test ! -d /home/"$user"/hosts; then
    mkdir /home/"$user"/hosts
	mv Readme.md /home/"$user"/hosts/Readme.md
	mv hosts.sh /home/"$user"/hosts/hosts.sh
	mv hosts.service /home/"$user"/hosts/hosts.service
fi

sleep 1

echo -e "Vos réecritures de domaines sont désormais configurées, \nvous pouvez retrouver les fichiers dans le dossier 'hosts' situé dans votre 'home'\n"
sleep 1
echo -e "\033[31mun redémarrage de la session est nécessaire \n\033[31mAprès redemarrage assurez vous que /etc/hosts ai bien été écrit comme voulu \n \n\033[32mENJOY !!\033[0m"

if test ! -f /home/"$user"/hosts/install.sh; then
    	mv install.sh /home/"$user"/hosts/install.sh

fi



exit

