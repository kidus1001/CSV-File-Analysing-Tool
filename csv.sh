#!/bin/bash

function open ()
{
	clear
	echo -e "************* Welcome to CSV Data analysis *************\n"
	echo "Enter the CSV file to be analysed: "
}

function menu ()
{
	clear
	echo -e "******************* MENU *******************\n"
	echo "1. Display the number of rows and columns in the CSV file"
	echo "2. List unique values in a specified column"
	echo "3. Column names (header)"
	echo "4. Minimum and maximum values for numeric columns"
	echo "5. The most frequent value for categorical columns"
	echo "6. Calculate summary statistics (mean, median, standard deviation) for numeric columns"
	echo "7. Filtering and extracting rows and columns based on user defined conditions"
	echo -e "8. Sorting the CSV file based on a specific column\n"
}

function check ()
{
	checkVar="false"
	if [ -e $1  ]
	then
		checkVar="true"
	fi

	if [ $checkVar == "true" ]
	then
		menu
  	else
		echo "File doesn't exist!"
		exit 1
  	fi
}

function display ()
{

	clear
	echo "Column = "`head -n 1 $1 | tr -cd ',;\t' | wc -c | awk '{print $1+1}'`
	echo "Row = "`cat $1 | wc -l`
}

function list ()
{	echo "Enter the column you want to list: "
	read column

	tail -n +2 $1 > unsortedFile.txt
	sort unsortedFile.txt > tempFile.txt

	clear
	echo "Unique list on column #$column are: "
	cat tempFile.txt | cut -f$column -d ',' | uniq
}

function header ()
{
	clear
	echo "Header: "
	head -n 1 $1
}

function extreme ()
{
	clear
	cat $1
	echo -e "\nEnter the numeric column you want to know the maximum and minimum value: "
	read column

	tail -n +2 $1 > unsortedFile.txt
	sort unsortedFile.txt > tempFile.txt

	cat tempFile.txt | cut -f$column -d ',' | uniq > myfile

	clear

	max=1
	min=1
	while read x
	do
		max=$x
		min=$x
		break
	done < <(cat myfile)

	while read x
	do
		if [ $x -gt $max ]
		then
			max=$x
		fi
		if [ $x -lt $min ]
		then
			min=$x
		fi
	done < <(cat myfile)
	echo "Max = $max"
	echo "Min = $min"
}

function frequent ()
{
	clear
	cat $1
	echo -e "\nEnter the column to find the most frequent value: "
	read column

	tail -n +2 $1 > tempFile

	cat tempFile | cut -f$column -d ',' > myfile

	count=0
	max=1
	result=1
	while read x
	do
		value=$x
		while read y
		do
			if [ $value == $y ]
			then
				count=$((count+1))
				if [ $count -gt $max ]
				then
					result=$value
					max=$count
				fi
			fi
		done < <(cat myfile)
		count=0
	done < <(cat myfile)

	if [ $max == 1 ]
	then
		echo "There is no most frequent number!"
	else
		echo "Frequent Value = "$result
		echo "Occurence = "$max
	fi
}

function statistics ()
{
	clear
	cat $1
	echo -e "\nEnter the column number to see the summary statistics: "
	read column

	tail -n +2 $1 > tempFile

	cat tempFile | cut -f$column -d ',' > myfile

	sort -n myfile > sortedfile

	sum=0
	count=0
	while read x
	do
		sum=$((sum+x))
		count=`expr $count + 1`
	done < <(cat myfile)
	avr=$((sum/count))

	count=0
	while read x
	do
		((count++))
	done < <(cat myfile)

	echo -n "Average = "
	echo "scale=2;$sum / $count" | bc
}

function userdefined ()
{
	clear
	echo "Enter the row number you want to print: "
	read row
	head -n $row $1 | tail -n +$row

	echo "\nEnter the column number you want to print"
	read column
	tail -n +2 $1 > tempfile
	cat tempfile | cut -f$column -d ','
}

function sorting ()
{
	clear
	echo "Enter the column number for which you want to sort the CSV file: "
	read column
	tail -n +2 $1 | sort -nt ',' -k $column
}

open

read csvfile

check $csvfile

echo "Enter your choice: "
read choice

while [[ $choice -le 8 && $choice -ge 1 ]]
do
	if [ $choice == 1 ]
	then
		display $csvfile
		echo "Enter to continue: "
		read enter
	elif [ $choice == 2 ]
	then
		list $csvfile
		echo "Enter to continue: "
		read enter
	elif [ $choice == 3 ]
	then
		header $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	elif [ $choice == 4 ]
	then
		extreme $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	elif [ $choice == 5 ]
	then
		frequent $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	elif [ $choice == 6 ]
	then
		statistics $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	elif [ $choice == 7 ]
	then
		userdefined $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	elif [ $choice == 8 ]
	then
		sorting $csvfile
		echo -e "\n\nEnter to continue: "
		read enter
	fi
	menu
	echo "Enter your choice: "
	read choice
done




