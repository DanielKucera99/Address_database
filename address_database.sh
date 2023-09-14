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
	mode="$1"
	data="$2"

	values=()
	IFS=','
	read -ra values <<< "$data"

	menu_header
        echo "Please choose the option below"
	if  [[ mode -eq 1 ]]
	then
		echo ""
		echo -e "${red_color}Search${reset_color} / Edit by: "
	elif [[ mode -eq 2 ]]
	then
		echo ""
		echo -e "Search / ${red_color}Edit${reset_color} by: "
	else
        echo -e "\nAdd New Entry Screen:"
	fi
        echo "1: Name           : ${values[1]}"
        echo "2: Email          : ${values[2]}"
        echo "3: Tel No         : ${values[3]}"
        echo "4: Mob No         : ${values[4]}"
        echo "5: Place          : ${values[5]}"
        echo "6: Message        : ${values[6]}"
	if [[ mode -eq 1 ]]
	then
		echo "7: All		  :"
	elif [[ mode -eq 2 ]]
	then
		echo -e "${red_color}7: Save${reset_color}"
	fi
        echo -e "${red_color}x${reset_color}. Exit"
        echo ""

}

function search_operation()
{
	searched_lines="$@" #Getting the lines with the found term
	edit=2 #Mode of the field_menu
	lines=() #Array of separate lines of the file where the term was found
	filtered_lines=() #Array that fixes the empty spaces of lines array

	IFS='©©©' #Delimeter not likely to be found in the lines
	read -ra lines <<< "$searched_lines" #Filling the lines array

	for((i=0; i<"${#lines[@]}"; i++)) #Loop for fixing the array -> getting rid of the empty spaces
	do
		if [[ -z "${lines[$i]}" ]] #If the element is empty, then it is skipped, otherwise is it assigned to the filtered_lines array
		then
			continue
		else
			line_value="${lines[$i]}"
			trimmed_line_value="${line_value# }" #Getting rid of the space at the beginning of the string
			filtered_lines+=("$trimmed_line_value")
		fi
	done

	result_index=0 #Index of the array that will be past to be displayed
 	if [[ "${#filtered_lines[@]}" -gt 1 ]] #If there is more than one result, then the user has a chance to choose which one to display
        then

	num=1 #Number for the display of options
	for line in ${filtered_lines[@]} #Loop for displaying the options
	do
		echo "[$num] $line"
		num=$((num + 1))
	done

		read -n 1 -p "Select the user number to be displayed: " user_number #Reading the chosen line
		result_index=$((user_number - 1)) #Upgrading the result index
	fi

	field_menu "$edit" "${filtered_lines[$result_index]}" #Displaying the menu with the correct data

	read -n 1 -p "Please choose your option: " field_to_edit #Reading the number of the field to edit

}

function search_and_edit()
{

	function searcher() #Function for searching the lines where the searched term is
	{
		lines_found=() #Array for the found lines
		IFS=$'\n' #Separating the values by the new line char
		file_lines=($(<"$database_dir")) #Passing the data into the array

		position="$1" #The index of the position where the search term should be
		searched_term="$2" #The searched term
		i=0 #Index of the file_lines that contains the searched term
		for line in "${file_lines[@]}" #Loop through the file lines
		do
			IFS=',' read -ra file_data <<< "$line" #Separating the values of the line with a comma
			if ! [ "$position" -eq "7" ] #If is position different from "7" than the search term is compared within chosen category, otherwise it is compared within the whole line
			then
				if [ "${file_data[$position]}" = "$searched_term" ] #If the term is found in the chosen category, then is it assigned to the lines_found array
				then
					lines_found+=("${file_lines[$i]}©©©") #©©© at the end is used for the future use as a delimeter
									     #it was chosen since the line can end with any character and this string is very unlikely to happen
				fi
				i=$((i + 1)) #Incrementing the index therefore moving to another line
			else
				if [[ "${file_data[@]}" =~ "$searched_term" ]] #If the term is found within the line, then is it assigned to the lines_found array
                                then
                                        lines_found+=("${file_lines[$i]}©©©")
                                fi
                                i=$((i + 1))
			fi
		done

		if [[ "${#lines_found[@]}" -eq 0 ]] #If the lines_found array is empty, then the term was not found, otherwise it proceeds to the search_operation function
		then
			echo -e "${red_color}The searched term not found!${reset_color}"
		else
			search_operation "${lines_found[@]}"
		fi
	}

	search=1 #Number of the mode used for the type of field menu

	menu_header

	while true #Loop for going back to field menu after the user writes the data
        do
                field_menu $search

                if read -n 1 -p "Please choose the field to be searched: " searched_field #Reading what field should be written
                then
                       field_menu $search

			while true #Loop repeats the prompt if it's invalid
			do
                        	case "$searched_field" in
                        	"1" )
                                	while true #Loop repeats the prompt if it's invalid
                                	do
                                        	read -p "Please enter the Name: " searched_name #Reading the name
                                        	if [[ $searched_name =~ $alphabet_pattern ]] #Checking whether the name has only letters and spaces
                                        	then
							searcher "1" "$searched_name"
							break
                                        	else
                                                	echo -e "${red_color}Name can contain only letters and spaces${reset_color}"
                                        	fi
                                	done
                        	;;
				"2")
                                	while true
                                	do
                                        	read -p "Please enter the Email: " searched_email
                                        	if [[ $searched_email =~ $email_pattern ]]
                                        	then
                                                	searcher "2" "$searched_email"
                                               	 	break
                                        	else
                                                	echo -e "${red_color}Invalid email${reset_color}"
                                        	fi
                                	done
                        	;;
                        	"3")
                                	while true
                                	do
                                        	read -p "Please enter the Tel number: " searched_tel
                                        	if [ ${#searched_tel} -eq 10 ] #Checking the number of the input numbers
                                        	then
                                                	if [[ $searched_tel =~ $number_pattern ]]
                                                	then
                                                        	searcher "3" "$searched_tel"
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
                                        	read -p "Please enter the Mobile number: " searched_mob
                                        	if [ ${#searched_mob} -eq 10 ]
                                        	then
                                                	if [[ $searched_mob =~ $number_pattern ]]
                                                	then
                                                        	searcher "4" "91+$searched_mob"
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
                                        	read -p "Please enter the Place: " searched_place
                                        	if [[ $searched_place =~ $alphabet_pattern ]]
                                        	then
                                                	searcher "5" "$searched_place"
                                                	break
                                        	else
                                                	echo -e "${red_color}Place can contain only letters and spaces${reset_color}"
                                       		fi
                                	done
                        	;;
                        	"6")
                                	read -p "Please enter the message: " searched_message
                               		searcher "6" "$searched_message"
					break
                        	;;
				"7")
					read -p "Please enter the text: "  searched_text
					searcher "7" "$searched_text"
					break
				;;
				*)
			        echo -e "${red_color}Invalid input!!!${reset_color}"
                                ;;

				esac
			done
		fi
	done
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
						csv_line["$field"]="$name" #Assigning the name to the correct field
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
						csv_line["$field"]="$email"
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
                                                	csv_line["$field"]="$tel"
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
                                                        csv_line["$field"]="91+$mob"
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
                                                csv_line["$field"]="$place"
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
				csv_line[0]="$(date '+%Y-%m-%d %H:%M:%S')" #Date and time when was data written
				IFS=','
				echo "${csv_line[*]}" >> "$database_dir" #Writing to the file
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
	menu_header
	while true #Loop to repeat the prompt if the input is invalid
        do
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
				if [ ! -s "$database_dir" ]
				then
					echo -e "\nThe database is empty! Data have to be entered first\n"
				else
                                	search_and_edit
				fi
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
