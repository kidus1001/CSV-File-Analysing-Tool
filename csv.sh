#!/bin/bash

function display ()
{
	echo "Column = "`head -n 1 $1 | tr -cd ',;\t' | wc -c | awk '{print $0+1}'`> file
	echo "Row = "`cat $1 | wc -l | awk '{print $1-1}'`>> file
	whiptail --textbox file 15 70
}

function list ()
{
	col=$(whiptail --inputbox "\n\nEnter the column you want to list " 15 70 --title "***** List Column *****"  3>&1 1>&2 2>&3)
	tail -n +2 $1 > tempFile.txt
	echo "Unique list on column #$col are: " > file1
	cat tempFile.txt | cut -f$col -d , | sort | uniq >> file1
	
	whiptail --textbox file1 35 70
}

function menu ()
{
	choice=$(whiptail --title "Menu" --menu "\n\nChoose an option" 21 70 11 \
	"1" "Display the number of rows and columns in the CSV file" \
	"2" "List unique values in a specified column" \
	"3" "Column names (header)" \
	"4" "Minimum and maximum values for numeric columns" \
	"5" "The most frequent value for categorical columns" \
	"6" "Calculate summary statistics (mean, median, standard deviation)" \
	"7" "Filtering and extracting rows and columns" \
	"8" "Sorting the CSV file based on a specific column" \
	"9" "Data analysis [Graph] & Save" \
	"10" "Exit" 3>&1 1>&2 2>&3)
}

function check ()
{
	checkVar="false"
	for x in *.csv
	do
		if [ -e $x ]
		then
			checkVar="true"
			break
		fi
	done
	
	
	if [ $checkVar == "true" ]
	then
		menu
	else
		whiptail --title "Failed" --msgbox "File doesn't exist!" 15 70
		exit 1
	fi
}

function header ()
{
	echo -n "\nHeader: " > file2
	head -n 1 $1 >> file2
	whiptail --textbox file2 15 70
}

function extreme ()
{
	column=$(whiptail --inputbox "\n\nEnter the numeric column you want to know the maximum and minimum value: " 15 70 --title "***** Extreme *****" 3>&1 1>&2 2>&3)

	tail -n +2 $1 > unsortedFile.txt
	sort unsortedFile.txt > tempFile.txt

	cat tempFile.txt | cut -f$column -d ',' | uniq > myfile

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
	echo "Min = $min" > file3
	echo "Max = $max" >> file3

	whiptail --textbox file3 15 70
}

function frequent ()
{
	column=$(whiptail --inputbox "\n\n\nEnter the column to find the most frequent value: " 15 70 --title "***** The most frequent *****" 3>&1 1>&2 2>&3)

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
		echo "There is no most frequent number!" > file4
	else
		echo "Frequent Value = "$result > file4
		echo "Occurence = "$max >> file4
	fi

	whiptail --textbox file4 15 70
}

function statistics ()
{
	column=$(whiptail --inputbox "\n\n\nEnter the column number to see the summary statistics: " 15 70 --title "***** Summary Statistics *****" 3>&1 1>&2 2>&3)

	tail -n +2 $1 > tempFile

	cat tempFile | cut -f$column -d ',' > myfile

	sort -n myfile > sortedfile

	sum=0
	count=0
	avr=0
	while read x
	do
		sum=$((sum+x))
		count=`expr $count + 1`
	done < <(cat myfile)
	avr=$((sum/count))
	echo -n "Average = " > file5
	echo "scale=2;$sum / $count" | bc >> file5
  	sum=0

	std_dev=$(awk -v mean=$avr '{ sum += ($1 - mean)^2 } END { print sqrt(sum / NR) }' sortedfile)
	echo "Standard Deviation: $std_dev" >> file5
	
	median=$(awk 'NF{ a[NR]=$1;c++} END { print(c%2==0)?((a[c/2]+a[(c/2)+1])/2):a[(c/2+1)] }' sortedfile)
	echo "Median: $median" >> file5
	
	whiptail --textbox file5 15 70
}

function userdefined ()
{
	row=$(whiptail --inputbox "\n\n\nEnter the row number you want to print: " 15 70 --title "***** User defined *****" 3>&1 1>&2 2>&3)
	echo -n "Row #$row = " > file6
	head -n $row $1 | tail -n +$row >> file6
	
	column=$(whiptail --inputbox "\n\n\nEnter the column number you want to print: " 15 70 --title "***** User defined *****" 3>&1 1>&2 2>&3)
	echo "\nColumn #$column: " >> file6
	tail -n +2 $1 > tempfile
	cat tempfile | cut -f$column -d ',' >> file6
	
	whiptail --textbox file6 15 70
}

function sorting ()
{
	column=$(whiptail --inputbox "\n\n\nEnter the column number for which you want to sort the CSV file: " 15 70 --title "***** Sorting *****" 3>&1 1>&2 2>&3)
	tail -n +2 $1 | sort -nt ',' -k $column > file7
	
	whiptail --textbox file7 32 70
}

function invalid ()
{
	whiptail --title "Invalid" --msgbox "Invalid Input! Try again!" 15 70
}

function dataAnalysis ()
{
	column=$(whiptail --inputbox "\n\n\nEnter column number 1 you want to plot graph with: " 15 70 --title "***** Column *****" 3>&1 1>&2 2>&3)
	column1=$(whiptail --inputbox "\n\n\nEnter column number 2 you want to plot graph with: " 15 70 --title "***** Column *****" 3>&1 1>&2 2>&3)
	
	tail -n +2 $1 > tempfile
	cat tempfile | cut -f$column -d ',' > file8
	
	cat tempfile | cut -f$column1 -d ',' > file9
	
	paste file8 file9 > merged_data
	
	gnuplot -p -e 'plot "merged_data" u 1:2 w l'
}

function saveFile ()
	{
	saveChoice=$(whiptail --title "***** Save Option *****" --menu "\n\nChoose the file format to save" 21 70 10 \
	"1" "HTML" \
	"2" "txt" 3>&1 1>&2 2>&3)
	
	if [ $saveChoice == 1 ]
	then
		$1 > savedFile.html
		$2 >> savedFile.html
		$3 >> savedFile.html
		$4 >> savedFile.html
		$5 >> savedFile.html
		$6 >> savedFile.html
		$7 >> savedFile.html
		$8 >> savedFile.html
		$9 >> savedFile.html
	else
		$1 >> savedFile.txt
		$2 >> savedFile.txt
		$3 >> savedFile.txt
		$4 >> savedFile.txt
		$5 >> savedFile.txt
		$6 >> savedFile.txt
		$7 >> savedFile.txt
		$8 >> savedFile.txt
		$9 >> savedFile.txt
	fi
	whiptail --title "***** Success *****" --msgbox "\nFile saved successfully!" 15 70
}



csvfile=$(whiptail --inputbox "\n\nWrite the CSV file to be analysed: " 15 70 --title "***** Welcome to CSV Data Analysis *****" 3>&1 1>&2 2>&3)

choice=0
check $csvfile $choice
while [[ $choice != 10 ]]
do
	if [ $choice == 1 ]
	then
		display $csvfile
	elif [ $choice == 2 ]
	then
		list $csvfile
	elif [ $choice == 3 ]
	then
		header $csvfile
	elif [ $choice == 4 ]
	then
		extreme $csvfile
	elif [ $choice == 5 ]
	then
		frequent $csvfile
	elif [ $choice == 6 ]
	then
		statistics $csvfile
	elif [ $choice == 7 ]
	then
		userdefined $csvfile
	elif [ $choice == 8 ]
	then
		sorting $csvfile
	elif [ $choice == 9 ]
	then
		dataAnalysis $csvfile
		saveFile $file $file1 $file2 $file3 $file4 $file5 $file6 $file7 $merged_data
	fi
	menu $choice
 done
