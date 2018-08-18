################ records bash output ######################
record() {
        bash ~/.bash_output_history/bash_output_history.sh
}

isrecord() {
        if pgrep -x "script" > /dev/null
        then
                echo "Running"
        else
                echo "Stopped"
        fi
}

recloc() {
        cd ~/.bash_output_history/
}
###########################################################

