#!/bin/zsh
file=$1
cmd=$2
events=${3:-modify}


function run_cmd() {
	echo "------------EVENT---------------------"
	echo $1
	echo "--------------------------------------"
	echo "Running: $cmd"
	eval $cmd 
	echo "Completed: $cmd"
	echo "--------------------------------------"
}

function test_and_run_cmd(){
	rgx=$(echo "$events" | sed -E s/,/\|/g  )
	( echo $1 | grep -i -E $rgx ) && run_cmd $1
}


inotifywait $(echo $file) -m -r -e $events | while read -r fname event; do

 	echo $fname $event
	test_and_run_cmd "$fname $event"
done

