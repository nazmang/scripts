#!/bin/bash.old
#
#	Created 08/22/2017
#
echo "User adding script v 1.0"
if [ `/bin/hostname` != "starsdev2" ]
then 
	echo -e "This version of script works only for STAR environment!\nPlease run it on starsdev2 host"
	exit 1
fi

PASSWORD=`cat /dev/urandom | tr -dc 'A-HJKMNP-Za-hjkmnp-z2-9!@#$%^&' | fold -w 8 | head -n 1`
GID=210
read -p "Firstname: " FNAME
read -p "Lastname: " LNAME
cd /etc/yp
NEWUSERNAME=`echo "$LNAME" | tr '[:upper:]' '[:lower:]'`
EXISTS="`ypmatch $NEWUSERNAME passwd`"

while [ -n "$EXISTS" ]
do
	echo -e "\nUsername exists: $EXISTS"
	read -p "Add username manually: " NEWUSERNAME
	EXISTS="`ypmatch $NEWUSERNAME passwd`"
done
	# Username doesn't exist
	read -p "Shell [/bin/tcsh]: " USERSHELL
	if [ -z "$USERSHELL" ] 
	then 
		USERSHELL="/bin/tcsh"
	fi
	
	read -p "Home directory [/home/$NEWUSERNAME]: "	USERDIR
	if [ -z "$USERDIR" ] 
	then
		USERDIR="/home/$NEWUSERNAME"
	fi
	cd /etc/yp
	NEWUID="`getent passwd | nawk -v max=4999 -v min=4000 'BEGIN{FS=":"}{if($3<max&&$3>min){want=$3;min=$3}}END{print want+1}'`"
	
	echo -e "\nUser $NEWUSERNAME will be added with:\nID: $NEWUID\nShell: $USERSHELL\nHome directory: $USERDIR"
	read -p "Is it correct? [y/n]: " RESULT
	case "$RESULT" in
		"y" | "Y" )
		cd /etc/yp
		echo "auto.home passwd security/passwd.adjunct" | xargs /systems/bin/yparchive-starsdev2
		echo "$NEWUSERNAME:##$NEWUSERNAME:$NEWUID:$GID:$FNAME $LNAME:$USERDIR:$USERSHELL" >> passwd
		#adduser -s /usr/bin/tcsh -c "$LNAME $FNAME" $NEWUSERNAME
		HASH="`openssl passwd -1 $PASSWORD`"
		echo "$NEWUSERNAME:$HASH:::::::" >> security/passwd.adjunct
		echo -e "$NEWUSERNAME\t star-vnx:/homedirs_star/$NEWUSERNAME" >> auto.home
		cd /var/yp
		make
		cd /etc/yp/security
		#echo -e "$PASSWORD" | (passwd "$LNAME" --stdin)
		#echo -e "Type this password: $PASSWORD manually below: \n"
		#passwd "$LNAME"
		;;
		* )
		exit 3
		;;
	esac

echo "User: $LNAME added with password: $PASSWORD"
#unset PASSWORD NEWUSERNAME LNAME FNAME USERSHELL USERDIR EXISTS
exit 0
