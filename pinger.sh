#!/bin/bash
source IPTools.sh
usage() { echo "Usage: ./pinger.sh [-n netmask -i IP] "; exit; }

max_ip=$( dotted2int 255.255.255.255 )
CUSTOM_SUBNET=0
CUSTOM_IP=0

#ARGUMENT CHECK
#TODO: *Actually* implement usage of arguments
while getopts "n:i:" opts; do
	case "${opts}" in
		n) CUSTOM_SUBNET=${OPTARG}
		TEMP1=$( dotted2int ${CUSTOM_SUBNET} )
		CUSTOM_SUBNET=${TEMP1}
		if [ ${CUSTOM_SUBNET} -gt ${max_ip} ] || [ ${CUSTOM_SUBNET} -lt 0 ]
		then
			usage
		fi
		;;
		i) CUSTOM_IP=${OPTARG}
		TEMP2=$( dotted2int ${CUSTOM_IP} )
		CUSTOM_IP=$TEMP2
		if [ $CUSTOM_IP -gt $max_ip ] || [ $CUSTOM_IP -lt 0 ]
		then
			usage
		fi
		;;
    *)
    usage
    ;;
esac
done
if [ $CUSTOM_SUBNET -eq 0 ] || [ $CUSTOM_IP -eq 0 ] #No custom rule set
then
	#Attempt to load Netmask and local IP automatically
	ifconfig | grep inet -w | grep -v 127.0.0.1 | tr ' ' '\t'  > temp.bin

	if [ $? -eq 0 ] #SUCCESS
	then
		raw_mask=$( cut -f13,13 temp.bin ) #Get Mask
		if [ $? -eq 0 ] #MASK SUCCESS
		then
			echo "Netmask automatically detected: " $raw_mask
			mask=$( dotted2int $raw_mask )
			raw_ip=$( cut -f10,10 temp.bin )	#Get IP
			if [ $? -eq 0 ] #IP SUCCESS
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
				echo "Automatic extraction of Subnet Mask was not successful. Try manually specifying it with -n [Netmask]"
			fi
		else
			echo "Automatic extraction of Local IP address was not successful. Try manually specifying it with -i [IP]"
		fi
		else
			echo "Automatic extraction of Subnet Mask and Local IP unsuccessful. Try manually specifying them with -i [IP] -n [Netmask]"
	fi
fi
if [ $CUSTOM_SUBNET -ne 0 ] && [ $CUSTOM_IP -eq 0 ]
then
	echo "You have to specify a Custom IP too."
	usage
fi
if [ $CUSTOM_SUBNET -eq 0 ] && [ $CUSTOM_IP -ne 0 ]
then
	echo "You have to specify a Custom Subnet too."
	usage
fi
if [ $CUSTOM_SUBNET -ne 0 ] && [ $CUSTOM_IP -ne 0 ]
then
	mask=$( dotted2int $CUSTOM_SUBNET )
	ip=$( dotted2int $CUSTOM_IP )
	ip_ctr=$(( $mask & $ip ))	#Bitwise AND
	echo "Starting scan from $ip_ctr to $max_ip. Results will be added to output.txt progressively."
	for((ctr=$ip_ctr; ctr < $max_ip; ctr++))
	do
		ping -a -W 1 -c 1 -i 200 -b $ctr | grep "from" >> output.txt &
		#kill $!
	done
	echo "Completed, check output.txt"
fi
