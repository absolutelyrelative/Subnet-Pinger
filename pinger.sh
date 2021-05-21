#!/bin/bash
source IPTools.sh
usage() { echo "Usage: ./pinger.sh [-N netmask] [-I IP] "; exit; }

max_ip=$( dotted2int 255.255.255.255 )

#ARGUMENT CHECK
while getopts N: opts; do
	case ${opts} in
		N) CUSTOM_SUBNET=${OPTARG}
		if [ $WHICH_PRINT -gt $max_ip ]
		then
			usage
		fi
		if [ $WHICH_PRINT -lt 0 ]
		then
			usage
		fi
		;;
		I) CUSTOM_IP=${OPTARG}
		if [ $WHICH_PRINT -gt $max_ip ]
		then
			usage
		fi
		if [ $WHICH_PRINT -lt 0 ]
		then
			usage
		fi
		;;
    *)
    usage
    ;;
esac
done
#Bitwise operator: $(( $a & $b ))
#ifconfig | grep inet -w | grep -v 127.0.0.1
#        inet 192.168.176.91  netmask 255.255.255.0  broadcast 192.168.176.255

#ifconfig | grep inet -w | grep -v 127.0.0.1 | grep "[0-9]* netmask 255.255.255.0, check echo $?"
ifconfig | grep inet -w | grep -v 127.0.0.1 | tr ' ' '\t'  > temp.bin

if [ $? == 0 ] #SUCCESS
then
	raw_mask=$( cut -f13,13 temp.bin ) #Get Mask
	if [ $? == 0 ] #MASK SUCCESS
	then
		echo "Rilevata automaticamente Netmask: " $raw_mask
		mask=$( dotted2int $raw_mask )
		raw_ip=$( cut -f10,10 temp.bin )	#Get IP
		if [ $? == 0 ] #IP SUCCESS
		then
			echo "Rilevato automaticamente IP: " $raw_ip
			ip=$( dotted2int $raw_ip )
			ip_ctr=$(( $mask & $ip ))	#Bitwise AND
			echo "Inizio scan da $ip_ctr a $max_ip. I risultati sono stampati su output.txt automaticamente"
			for((ctr=$ip_ctr; ctr < $max_ip; ctr++))
			do
				#ping -4 -a -ttl 4 -c 1 $ctr
				#temp=$( (ping -a -c 1 -i 200 -b $ctr) ) #Indirizzi di broadcast sono inclusi, non sappiamo quante subnet ci siano
				#echo $temp >> temp2.txt
				ping -a -W 1 -c 1 -i 200 -b $ctr | grep "from" >> output.txt &
				#kill $!
				#ping -a -c 1 -i 200 -b $ctr | grep "from" & >> output.txt
			done
			echo "Completato, controlla output.txt"

		else
			echo "Impossibile estrarre Netnmask. Puoi specificarla con l'argomento -N [Netmask]"
		fi
	else
		echo "Impossibile estrarre IP. Puoi specificarlo con l'argomento -I [IP]"
	fi
	else
		echo "Impossibile estrarre Netnmask & IP automaticamente."
fi
