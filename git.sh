#!/bin/bash
read -e -p "please choice push(1) or pull(2):" choice
if [ $choice == 1 ]; then
	read -e -p "please cin your commit:" cm
	git add -A
	git commit -m "$cm"
	git push origin master
elif [ $choice == 2 ]; then
	git pull origin
else
	echo "wrong choice"
fi
