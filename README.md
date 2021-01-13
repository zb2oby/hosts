# hosts
Script in bash writing personal DNS resolutions in /etc/hosts 


DEPENDANCES ET DROITS : 
========================
Ce script necessite au minimum : 
- Wireless-tools ou network-manager
- ethtool ou net-tools

ce script execute des commandes nécessitant les droits superutilisateur. 
assurez vous d'avoir les droits suffisants avant de commencer.



PRESENTATION
=============
Le but de ce petit programme est de modifier la resolution DNS dans le /etc/hosts de votre machine afin d'acceder à vos serveurs avec la même adresse en interne et en externe
Finalement cela revient à realiser un NAT loopback (ou hairpinning) manuellement
Jusque là rien de nouveau et ecrire dans le /etc/hosts ne necessite pas un script me direz-vous

La force de ce petit outil reside dans le fait d'automatiser cette tâche en fonction du reseau sur lequel vous vous trouvez (tres pratique pour les ordinateurs portables donc)



Vous allez donc renseigner les ID de vos reseaux locaux préférés puis : 

- En interne (chez vous quoi) à l'ouverture de votre session le script va checker le réseau connu sur lequel vous ête connecté afin d'ecrire la resolution DNS dans /etc/hosts

- A l'inverse si vous êtes à l'exterieur le script ne reconnaitra pas le reseau et supprimera cette resolution du fichier /etc/hosts.

ainsi plus besoin de penser à modifier manuellement la resolution DNS

le script est donc livré avec un utilitaire d'installation lors de laquelle vous pourrez renseigner toute les informations necessaire à sa future bonne execution.

INSTALLATION
===============
1/Decompressez l'archive.

2/Placez vous dans le dossier où se trouvent les fichiers decompressés

3/Executez dans un terminal le script d'installation EN SUPERUTILISATEUR avec la commande :sudo bash install.sh

4/Suivez les instructions.






