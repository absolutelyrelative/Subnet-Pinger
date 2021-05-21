#!/bin/bash
source IPTools.sh
usage() { echo "Usage: ./pinger.sh [-N netmask] [-I IP] "; exit; }

max_ip=$( dotted2int 255.255.255.255 )

#ARGUMENT CHECK
#TODO: *Actually* implement usage of arguments
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

#Attempt to load Netmask and local IP automatically
ifconfig | grep inet -w | grep -v 127.0.0.1 | tr ' ' '\t'  > temp.bin

if [ $? == 0 ] #SUCCESS
then
	raw_mask=$( cut -f13,13 temp.bin ) #Get Mask
	if [ $? == 0 ] #MASK SUCCESS
	then
		echo "Netmask automatically detected: " $raw_mask
		mask=$( dotted2int $raw_mask )
		raw_ip=$( cut -f10,10 temp.bin )	#Get IP
		if [ $? == 0 ] #IP SUCCESS
		then
			echo "Local IP automatically detected: " $raw_ip
			ip=$( dotted2int $raw_ip )
			ip_ctr=$(( $mask & $ip ))	#Bitwise AND
			echo "Starting scan from $ip_ctr to $max_ip. Results will be added to output.txt progressively."
			for((ctr=$ip_ctr; ctr < $max_ip; ctr++))
			do
				ping -a -W 1 -c 1 -i 200 -b $ctr | grep "from" >> output.txt &
				#kill $!
			done
			echo "Completed, check output.txt"

		else
			echo "Automatic extraction of Subnet Mask was not successful. Try manually specifying it with -N [Netmask]"
		fi
	else
		echo "Automatic extraction of Local IP address was not successful. Try manually specifying it with -I [IP]"
	fi
	else
		echo "Automatic extraction of Subnet Mask and Local IP unsuccessful. Try manually specifying them with -I [IP] -N [Netmask]"
fi
