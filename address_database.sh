#!/bin/bash

#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/Database/"
database_file=database.csv
database_dir=$dir$database_file
red_color="\e[31m" #Red color for the text
reset_color="\e[0m" #Resetting the text back
num_of_fields=7 #Number of fields in csv file
alphabet_pattern="^[[:alpha:] ]+$" #Pattern for alphabet characters only
email_pattern="^[[:alnum:]_.]+@[[:alnum:]_.]+\.[[:alpha:]]+$" #Pattern for email
number_pattern="^[0-9]+$" #Pattern for numbers only

	if [ ! -d "$dir" ] #Checking whether the directory exists; if not, then it's created
	then
		mkdir -p "$dir"
	fi

	if [ ! -f "$database_dir" ] #Checking whether database file exists;if not, then it's created
	then
		touch "$database_dir"
	fi

function menu_header()
{
	clear
	echo "My database project"
}

function field_menu()
{
        menu_header
        echo "Please choose the option below"

        echo -e "\nAdd New Entry Screen:"
        echo "1: Name           :"
        echo "2: Email          :"
        echo "3: Tel No         :"
        echo "4: Mob No         :"
        echo "5: Place          :"
        echo "6: Message        :"
        echo -e "${red_color}x${reset_color}. Exit"
        echo ""

}

function add_new_entry()
{
	local csv_line=() #Line that will be added to the file
	for  ((i=1; i<num_of_fields; i++)) #Loop for clearing the array
	do
		csv_line["$i"]=""
	done

	while true #Loop for going back to field menu after the user writes the data
	do
		field_menu

		if read -n 1 -p "Please choose the field to be added: " field #Reading what field should be written
		then
			field_menu

			case "$field" in
			"1" )


				while true #Loop repeats the prompt if it's invalid
				do
					read -p "Please enter the Name: " name #Reading the name
					if [[ $name =~ $alphabet_pattern ]] #Checking whether the name has only letters and spaces
					then
						csv_line["$field"]="$name," #Assigning the name to the correct field
						break #Breaking out of the loop
					else
						echo -e "${red_color}Name can contain only letters and spaces${reset_color}"
					fi
				done
			;;
			"2")
				while true
				do
					read -p "Please enter the Email: " email
					if [[ $email =~ $email_pattern ]]
					then
						csv_line["$field"]="$email,"
						break
					else
						echo -e "${red_color}Invalid email${reset_color}"
					fi
				done
			;;
			"3")
				while true
				do
				        read -p "Please enter the Tel number: " tel
                                        if [ ${#tel} -eq 10 ] #Checking the number of the input numbers
                                        then
						if [[ $tel =~ $number_pattern ]]
						then
                                                	csv_line["$field"]="$tel,"
                                                	break
						else
							echo -e "${red_color}Tel number can contain only numbers${reset_color}"
						fi
                                        else
                                                echo -e "${red_color}Number must contain 10 characters${reset_color}"
                                        fi
                                done
                        ;;
			"4")
				while true
                                do
                                        read -p "Please enter the Mobile number: " mob
                                        if [ ${#mob} -eq 10 ]
                                        then
                                                if [[ $mob =~ $number_pattern ]]
                                                then
                                                        csv_line["$field"]="91+$mob,"
                                                        break
                                                else
                                                        echo -e "${red_color}Mobile number can contain only numbers${reset_color}"
                                                fi
                                        else
                                                echo -e "${red_color}Number must contain 10 characters${reset_color}"
                                        fi
                                done
                        ;;

			"5")
				while true
                                do
                                        read -p "Please enter the Place: " place
                                        if [[ $place =~ $alphabet_pattern ]]
                                        then
                                                csv_line["$field"]="$place,"
                                                break
                                        else
                                                echo -e "${red_color}Place can contain only letters and spaces${reset_color}"
                                        fi
                                done
                        ;;
			"6")
				read -p "Please enter the message: " message
				csv_line["$field"]="$message"
			;;
			"x")
				csv_line[0]="$(date '+%Y-%m-%d %H:%M:%S')," #Date and time when was data written
				for i in "${!csv_line[@]}" #Loop for going through the line
				do
				    	if [ "${csv_line[i]}" = "" ] #If the field in an array is empty then the comma is put in that place
					then
        					csv_line[i]=","
    					fi
				done

				echo "${csv_line[@]}" >> "$database_dir" #Writing to the file
				break #Breaking out of the field menu
			;;
			*)
				echo -e "${red_color}Invalid input!!!${reset_color}"
				;;
			esac
		fi
	done

}

function main()
{
	while true #Loop to repeat the prompt if the input is invalid
        do
                menu_header
                echo "Please choose the option below"

                echo ""
                echo "1. Add entry"
                echo "2. Search / Edit entry"
                echo -e "${red_color}x${reset_color}. Exit"

                echo -e "\nNote: Script Exit Timeout is set\n"

                if read -n 1 -s -p "Please choose your option: " -t 10 option #Reading the input at the start of the program; if it is not answered in 10 seconds, the program closes
                then

                        if [[ "$option" -eq 1 ]]
                        then
                                add_new_entry
                        elif [[ "$option" -eq 2 ]]
                        then
                                search_operation
                        elif [[ "$option" = "x" ]]
                        then
                                echo ""
                                exit 0
                        else
                                echo -e "\nInvalid input!\n"
                        fi
                else
                        echo ""
                        exit 1
                fi
        done

}

main
