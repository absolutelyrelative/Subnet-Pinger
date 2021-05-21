# Subnet Pinger
 My own implementation of an active-device finder.
 It launches multiple processes for each ping to speed up the process.
 Watch out, you might DOS your own subnet! I'm not responsible for damages if so, consider yourselves warned! :D

# Usage
./pinger.sh [-n netmask -i IP]

Example:
./pinger.sh -n 255.255.255.0 -i 192.168.2.1


# Files
IPTools.sh -> contains the function to convert from quadruple-dotted-decimal to integer
pinger.sh -> contains the actual code to ping
