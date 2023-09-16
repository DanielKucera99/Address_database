#!/bin/bash
#The project's directory
dir=~/"ECEP/LinuxSystems/Projects/Database/"
database_file=database.csv #The database file
database_dir=$dir$database_file
log_file=database.log #The log file
log_dir=$dir$log_file
red_color="\e[31m" #Red color for the text
reset_color="\e[0m" #Resetting the text back
num_of_fields=7 #Number of fields in csv file
alphabet_pattern="^[[:alpha:] ]+$" #Pattern for alphabet characters only
email_pattern="^[[:alnum:]_.]+@[[:alnum:]_.]+\.[[:alpha:]]+$" #Pattern for email
number_pattern="^[0-9]+$" #Pattern for numbers only
replacement="@@@" #String with the comma will be saved as @@@ instead as commas are essential for the code and @@@ is a string that's unlikely to happen
comma_char="," #String for replacing the @@@

	if [ ! -d "$dir" ] #Checking whether the directory exists; if not, then it's created
	then
		mkdir -p "$dir"
	fi
	if [ ! -f "$log_dir" ] #Checking  whether the log file exists; if not, then it's created
	then
		touch "$log_dir"
	fi

	if [ ! -f "$database_dir" ] #Checking whether database file exists; if not, then it's created
	then
		touch "$database_dir"
		echo "$(date '+%Y-%m-%d %H:%M:%S') - Created ${database_file}" >> "$log_dir"
	fi

function menu_header()
{
	clear
	echo "My database project"
}

function field_menu()
{
	mode="$1" #Mode in which the menu should be displayed
	data="$2" #The line that should be displayed

	values=()
	IFS=','
	read -ra values <<< "$data" #Separating the line to the inidividual values

		if [[ "${values[6]}" = *"$replacement"* ]] #Checking for replacing the replacement string with the comma
		then
			values[6]="${values[6]//$replacement/$comma_char}"
		fi
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
	elif [[ mode -eq 0 ]]
	then
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

function edit_operation()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Edit entered" >> "$log_dir"
	editting_line=$(grep -nF "$data" "$database_dir" | cut -d":" -f1) #Finding the line that will be changed in the file
	local invalid=false #Variable for the condition if the prompted character is invalid

	function editor() #Editting the line
	{
		values_string="" #Assigning the empty string
		field_num=$1 #The index of the values array
		new_data=$2 #The new data

		values[$field_num]="$new_data" #Assigning the new data to the array

		for((i=0;i<${#values[@]};i++))
		do
		if [[ "${values[6]}" = *"$comma_char"* ]] #If the new data contain a comma, then it is replaced with the replacement string
                then
                        values[6]="${values[6]//$comma_char/$replacement}"
                fi
			echo "Values string in the ediztor: $values_string"
			values_string="$values_string${values[$i]}," #Assigning the data into the string so it can be passed back into the field menu as an updated line
		done
	}

	while true #Loop for the choosing the option
	do
		if [ "$invalid" = false ] #If the user's input is not invalid, it will display the menu, otherwise only the prompt and the warning is displayed
		then
			if [ -z "$values_string" ]
                        	then
                                	field_menu "$edit" "${lines_found[$result_index]}"
                        	else
					echo "Values string: $values_string"
                                	field_menu "$edit" "$values_string"
                        	fi
		fi
		invalid=false #Assigning invalid back to false if it is true

			read -n 1 -p "Please choose your option: " field_to_edit #Reading the number of the field to edit

			if [ -z "$values_string" ]
			then
				field_menu "$edit" "${lines_found[$result_index]}"
			else
				field_menu "$edit" "$values_string"
			fi
				case "$field_to_edit" in
                                "1" )
                                        while true #Loop repeats the prompt if it's invalid
                                        do
                                                read -p "Please enter the new Name: " new_name #Reading the name
                                                if [[ $new_name =~ $alphabet_pattern ]] #Checking whether the name has only letters and spaces
                                                then
							editor "$field_to_edit" "$new_name" #Editing the value of the line
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The name was editted to $new_name" >> "$log_dir"
                                                        break #Breaking out of the name loop
                                                else
                                                        echo -e "${red_color}Name can contain only letters and spaces${reset_color}"
                                                fi
                                        done
                                ;;
                                "2")
                                        while true
                                        do
                                                read -p "Please enter the new Email: " new_email
                                                if [[ $new_email =~ $email_pattern ]]
                                                then
                                                        editor "$field_to_edit" "$new_email"
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The email was editted to $new_email" >> "$log_dir"
                                                        break
                                                else
                                                        echo -e "${red_color}Invalid email${reset_color}"
                                                fi
                                        done
                                ;;
                                "3")
                                        while true
                                        do
                                                read -p "Please enter the new Tel number: " new_tel
                                                if [ ${#new_tel} -eq 10 ] #Checking the number of the input numbers
                                                then
                                                        if [[ $new_tel =~ $number_pattern ]]
                                                        then
                                                                editor "field_to_edit" "$new_tel"
								echo "$(date '+%Y-%m-%d %H:%M:%S') - The tel was editted to $new_tel" >> "$log_dir"
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
                                                read -p "Please enter the new Mobile number: " new_mob
                                                if [ ${#new_mob} -eq 10 ]
                                                then
                                                        if [[ $new_mob =~ $number_pattern ]]
                                                        then
                                                                editor "field_to_edit" "91+$new_mob"
								echo "$(date '+%Y-%m-%d %H:%M:%S') - The mob was editted to 91+$new_mob" >> "$log_dir"
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
                                                read -p "Please enter the new Place: " new_place
                                                if [[ $new_place =~ $alphabet_pattern ]]
                                                then
                                                        editor "field_to_edit" "$new_place"
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The place was editted to $new_place" >> "$log_dir"
                                                        break
                                                else
                                                        echo -e "${red_color}Place can contain only letters and spaces${reset_color}"
                                                fi
                                        done
                                ;;
                                "6")
                                        read -p "Please enter the new message: " new_message
                                        editor "field_to_edit" "$new_message"
					echo "$(date '+%Y-%m-%d %H:%M:%S') - The message was editted to $new_message" >> "$log_dir"
                                ;;
                                "7")
					echo "Saving..."
					sleep 3 #Stopping the code so the user sees that it is saving
					IFS=$'\n' read -d '' -r -a file_contents < "$database_dir" #Reading the content of the database file
					file_contents["$editting_line-1"]="$values_string"  #Replacing the string; subtract 1 to match array indexing
					printf "%s\n" "${file_contents[@]}" > "$database_dir" #Writting the modified content into the file
					echo "$(date '+%Y-%m-%d %H:%M:%S') - The editted data were saved" >> "$log_dir"
					echo "Data were sucessfully saved!"
					sleep 3 #Same as above
                                ;;
				"x")
					values_string=""
					searched_field="x" #If the "x" is pressed then it goes back to the search_and_edit fn where it is also assigned "x" so the program goes at the start
					field_menu $search
					echo "$(date '+%Y-%m-%d %H:%M:%S') - Editor exited" >> "$log_dir"
					break
				;;
                                *)
                                	echo -e "${red_color}Invalid input!!!${reset_color}"
					invalid=true #If the input is invalid, then the var invalid is true and the menu is not displayed
                                ;;

                                esac

	done
}
function search_operation()
{
	edit=2 #Mode of the field_menu

	result_index=0 #Index of the array that will be past to be displayed
 	if [[ "${#lines_found[@]}" -gt 1 ]] #If there is more than one result, then the user has a chance to choose which one to display
        then

		num=1 #Number for the display of options
		for line in ${lines_found[@]} #Loop for displaying the options
		do
			if [[ "$line" = *"$replacement"* ]] #Replacing the replacement with the comma so it is displayed correctly
                	then
                        line="${line//$replacement/$comma_char}"
                	fi

			echo "[$num] $line" #Displaying the found lines for user to choose
			num=$((num + 1))
		done

		read -n 1 -p "Select the user number to be displayed: " user_number #Reading the chosen line
		result_index=$((user_number - 1)) #Upgrading the result index
	fi

	field_menu "$edit" "${lines_found[$result_index]}" #Displaying the menu with the correct data

	edit_operation
}

function search_and_edit()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Search entered" >> "$log_dir"
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
					lines_found+=("${file_lines[$i]}") #©©© at the end is used for the future use as a delimeter
									     #it was chosen since the line can end with any character and this string is very unlikely to happen
				fi
				i=$((i + 1)) #Incrementing the index therefore moving to another line
			else
				if [[ "${file_data[@]}" =~ "$searched_term" ]] #If the term is found within the line, then is it assigned to the lines_found array
                                then
                                        lines_found+=("${file_lines[$i]}")
                                fi
                                i=$((i + 1))
		    	fi
		done

		if [[ "${#lines_found[@]}" -eq 0 ]] #If the lines_found array is empty, then the term was not found, otherwise it proceeds to the search_operation function
		then
			echo -e "${red_color}The searched term not found!${reset_color}"
		else
			search_operation
		fi
	}

	search=1 #Number of the mode used for the type of field menu

	menu_header

       	field_menu $search
	while true #Loop for going back to field menu after the user writes the data
	do
                 read -n 1 -p "Please choose the field to be searched: " searched_field #Reading what field should be written
                       field_menu $search

                        	case "$searched_field" in
                        	"1" )
                                	while true #Loop repeats the prompt if it's invalid
                                	do
                                        	read -p "Please enter the Name: " searched_name #Reading the name
                                        	if [[ $searched_name =~ $alphabet_pattern ]] #Checking whether the name has only letters and spaces
                                        	then
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The name $searched_name was searched" >> "$log_dir"
							searcher "$searched_field" "$searched_name"
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
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The email $searched_email was searched" >> "$log_dir"
                                                	searcher "$searched_field" "$searched_email"
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
								echo "$(date '+%Y-%m-%d %H:%M:%S') - The tel $searched_tel was searched" >> "$log_dir"
                                                        	searcher "$searched_field" "$searched_tel"
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
								echo "$(date '+%Y-%m-%d %H:%M:%S') - The mob 91+$searched_mob was searched" >> "$log_dir"
                                                        	searcher "$searched_field" "91+$searched_mob"
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
							echo "$(date '+%Y-%m-%d %H:%M:%S') - The place $searched_place was searched" >> "$log_dir"
                                                	searcher "$searched_field" "$searched_place"
                                                	break
                                        	else
                                                	echo -e "${red_color}Place can contain only letters and spaces${reset_color}"
                                       		fi
                                	done
                        	;;
                        	"6")
                                	read -p "Please enter the message: " searched_message
					echo "$(date '+%Y-%m-%d %H:%M:%S') - The message $searched_message was searched" >> "$log_dir"
                               		searcher "$searched_field" "$searched_message"
                        	;;
				"7")
					read -p "Please enter the text: "  searched_text
					echo "$(date '+%Y-%m-%d %H:%M:%S') - The text $searched_text was searched" >> "$log_dir"
					searcher "$searched_field" "$searched_text"
				;;
				"x")
					echo "$(date '+%Y-%m-%d %H:%M:%S') - Search exited" >> "$log_dir"
					break
				;;
				*)
			        	echo -e "${red_color}Invalid input!!!${reset_color}"
                                ;;

				esac
	done
}


function add_new_entry()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') - New entry entered" >> "$log_dir"
	local new_entry=0
	local csv_line=() #Line that will be added to the file
	local changed=false
	for  ((i=1; i<num_of_fields; i++)) #Loop for clearing the array
	do
		csv_line["$i"]=""
	done
	local invalid=false

		while true
		do
			local element_string=","
			for element in ${csv_line[@]}
                	do
                        	element_string="$element_string$element," #Assigning the data into the string so it can be passed back into the field menu as an updated line
                	done

			if [ "$invalid" = false ]
			then
				echo "Element string: $element_string"
				field_menu "$new_entry" "$element_string"
			fi
			invalid=false

			read -n 1 -p "Please choose the field to be added: " field #Reading what field should be written

			field_menu "$new_entry" "$element_string"
					case "$field" in
					"1" )
						while true #Loop repeats the prompt if it's invalid
						do
							read -p "Please enter the Name: " name #Reading the name
							if [[ $name =~ $alphabet_pattern ]] #Checking whether the name has only letters and spaces
							then
								csv_line["$field"]="$name" #Assigning the name to the correct field
								echo "$(date '+%Y-%m-%d %H:%M:%S') - New name $name added" >> "$log_dir"
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
								echo "$(date '+%Y-%m-%d %H:%M:%S') - New email $email added" >> "$log_dir"
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
									echo "$(date '+%Y-%m-%d %H:%M:%S') - New tel $tel added" >> "$log_dir"
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
									echo "$(date '+%Y-%m-%d %H:%M:%S') - New mob 91+$mob added" >> "$log_dir"
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
								echo "$(date '+%Y-%m-%d %H:%M:%S') - New place $place added" >> "$log_dir"
                                                		break
                                        		else
                                                		echo -e "${red_color}Place can contain only letters and spaces${reset_color}"
                                        		fi
                                		done
                        		;;
					"6")
						read -p "Please enter the message: " message
						if [[ "$message" = *"$comma_char"* ]]
                				then
                        				message="${message//$comma_char/$replacement}"
                				fi
						csv_line["$field"]="$message"
						echo "$(date '+%Y-%m-%d %H:%M:%S') - New message $message added" >> "$log_dir"
					;;
					"x")
						for ((i=1; i<num_of_fields; i++))
						do
    							if [ "${csv_line[$i]}" != "" ]
							then
								# The array element is not empty, set the flag to true
        							changed=true
    							fi
						done
					if  [ "$changed" = true ]
					then
						csv_line[0]="$(date '+%Y-%m-%d %H:%M:%S')" #Date and time when was data written
						IFS=','
						echo "${csv_line[*]}" >> "$database_dir" #Writing to the file
						echo "$(date '+%Y-%m-%d %H:%M:%S') - New data added" >> "$log_dir"
					fi
						break #Breaking out of the field menu
					;;
					*)
						echo -e "${red_color}Invalid input!!!${reset_color}"
						invalid=true
					;;
					esac
	done

}

function main()
{
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Script invoked" >> "$log_dir"
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
				if [ ! -s "$database_dir" ]
				then
					echo -e "\nThe database is empty! Data have to be entered first\n"
				else
                                	search_and_edit
				fi
                        elif [[ "$option" = "x" ]]
                        then
				echo "$(date '+%Y-%m-%d %H:%M:%S') - Script exited" >> "$log_dir"
                                echo ""
                                exit 0
                        else
                                echo -e "\nInvalid input!\n"
                        fi
                else
			echo "$(date '+%Y-%m-%d %H:%M:%S') - Script timed out!!!" >> "$log_dir"
                        echo ""
                        exit 1
                fi
        done

}

main
