#!/bin/bash

##########################################################################
# Copyright: DELVILLE Thibaut
##########################################################################

##########################################################################
# Programme : petit script pour mes backups et synchronisations
##########################################################################

VERSION="0.1.5"; # <release>.<major change>.<minor change>
PROGRAMME="backup";
AUTHOR="DELVILLE Thibaut";

source /home/thibaut/scripts/backup/config.ini

##############################
# Déclaration des variables  #
##############################

DIALOG=${DIALOG=Xdialog}
CHEMIN="/home/thibaut/"

##############################
# Déclaration des fonctions  #
##############################

danger()
{
  tput blink; echo -e "\n\e[1m\e[91m$DANGER\n\e[0;m"; tput sgr0
  read -p "Appuyer sur entrer : "
}

rsync_fin()
{
  echo -e "\n"
  read -p "Synchronisation terminée appuyer sur entrer : "
}

backup_fin()
{
  echo -e "\n"
  read -p "Sauvegarde terminée appuyer enter: "
}

synchro()
{
  source="$1"
  destination="$2"
  exclude="$3"
  echo -e "\n\e[92m\e[4mSynchronisation du/des dossier(s) : $source :\e[0m\n"
  danger
  $RSYNC_CMD $exclude $source $destination
  rsync_fin
}

backup()
{
  source="$1"
  destination="$2"
  exclude="$3"
  echo -e "\n\e[92m\e[4mArchivage du/des dossier(s) : $source :\e[0m\n"
  danger
  sudo tar -cf - $source | sudo pv > $destination/$DEST_FILE_BACKUP
  #$BACKUP_CMD $destination/$DEST_FILE_BACKUP $source $exclude
  echo -e "\n\e[92m\e[4m$COMPRESSION de $DEST_FILE_BACKUP\e[0m\n"
  $PV_CMD $destination/$DEST_FILE_BACKUP | $GZIP_CMD > $destination/$DEST_FILE_BACKUP.gz
  #$PV_CMD $destination/$DEST_FILE_BACKUP | $GZIP_CMD > $destination/$DEST_FILE_BACKUP.gz
  sudo rm $destination/$DEST_FILE_BACKUP
  $FIND_CMD $destination -mtime +2 -exec rm {} \;
  backup_fin
}

choix_dossier()
{
  DEST_HDD=$($DIALOG --dselect / 0 0 2>&1 1>/dev/tty)
}
##########################################################################
# Début du programme:
##########################################################################

DEST_HDD=$($DIALOG --title "Emplacement du Disque de sauvegarde" --dselect / 0 0 2>&1 1>/dev/tty)

#################
# Debut du menu #
#################

menu()
  {
  HEIGHT=0
  WIDTH=0
  CHOICE_HEIGHT=0
  BACKTITLE=""
  TITLE="Rsync et Backup"
  MENU="Choissisez parmi les options suivantes:"
  
  OPTIONS=(1 "Rsync PC-FIXE Manjaro"
           2 "Backup PC-FIXE Manjaro"
           3 "Rsync PC Fixe Arras"
           4 "Backup PC Fixe Arras"
           5 "Info Disque de sauvegarde"
           6 "Quit")
  
  CHOICE=$($DIALOG --clear \
                  --backtitle "$BACKTITLE" \
                  --title "$TITLE" \
                  --menu "$MENU" \
                  $HEIGHT $WIDTH $CHOICE_HEIGHT \
                  "${OPTIONS[@]}" \
                  2>&1 >/dev/tty)
  
  clear
  case $CHOICE in
          1)
              synchro "$SOURCE_RSYNC_PCFIXE_MANJARO" "$DEST_HDD$DEST_RSYNC_PCFIXE_MANJARO" "$EXCLUDE_RSYNC_PCFIXE_MANJARO"
              menu
              ;;
          2)
              backup "$SOURCE_BACKUP_PCFIXE_MANJARO" "$DEST_HDD$DEST_BACKUP_PCFIXE_MANJARO" "$EXCLUDE_BACKUP_PCFIXE_MANJARO"
              menu
              ;;
          3)
              synchro "$SOURCE_RSYNC_MEDION_MANJARO" "$DEST_HDD$DEST_RSYNC_ARRAS_WINDOWS" "$EXCLUDE_RSYNC_PCFIXE_ARRAS"
              menu
              ;;
          4)
              backup "$SOURCE_BACKUP_PCFIXE_ARRAS" "$DEST_HDD$DEST_BACKUP_PCFIXE_ARRAS" "$EXCLUDE_BACKUP_PCFIXE_ARRAS"
              menu
              ;;
          5)
              UTILISE=$(df -h | grep thibaut/backup | awk '{print $3}')
              LIBRE=$(  df -h | grep thibaut/backup | awk '{print $4}')
              TAILLE=$( df -h | grep thibaut/backup | awk '{print $2}')
              $DIALOG --msgbox "Il reste $LIBRE/$TAILLE sur le support de stockage utilisé pour la sauvegarde." 0 0
              menu
              ;;
          6)
              exit
              ;;            
  esac
}  

menu