#!/bin/bash

echo "" > results.txt
work=0
fail=0

for i in html/*.html;
do
	konqueror $i

	# error, we didn't catch it :(
	if [ $? -ne 0 ] ; then
		echo $i >> results.txt
		fail=$fail+1
	else
		work=$work+1
	fi
done

echo "Success: $work"
echo "Failure: $fail"
