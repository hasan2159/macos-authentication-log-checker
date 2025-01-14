#!/bin/bash

# Function to display date format information
show_date_info() {
   clear
   echo "================ DATE FORMAT INFORMATION ================"
   echo "Please use the following format for dates:"
   echo "Format: YYYY-MM-DD HH:MM:SS (24-hour time)"
   echo
   echo "Examples:"
   echo "• For January 10, 2025 at 9 AM:    2025-01-10 09:00:00"
   echo "• For December 31, 2024 at 11 PM:  2024-12-31 23:00:00"
   echo "• For March 15, 2025 at 2:30 PM:   2025-03-15 14:30:00"
   echo
   echo "Current time: $(date '+%Y-%m-%d %H:%M:%S')"
   echo "======================================================="
   echo
}

# Function to get date input in the correct format
get_date_input() {
   local prompt="$1"
   local is_required="$2"
   while true; do
       if [ "$is_required" = "false" ]; then
           read -p "$prompt (YYYY-MM-DD HH:MM:SS or press Enter for current time): " date_input
           # If empty input, return current timestamp
           if [ -z "$date_input" ]; then
               current_time=$(date '+%Y-%m-%d %H:%M:%S')
               echo "$current_time"
               return 0
           fi
       else
           read -p "$prompt (YYYY-MM-DD HH:MM:SS): " date_input
       fi

       if [[ $date_input =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
           echo "$date_input"
           return 0
       else
           echo "❌ Invalid date format. Please use YYYY-MM-DD HH:MM:SS"
       fi
   done
}

# Function to display menu and get selection
show_menu() {
   echo "==================== Log Filter Options ===================="
   echo "1) Local User Password Change Failure"
   echo "2) Local User Password Change Success"
   echo "3) Lock Screen Unlock Failure"
   echo "4) Login through LoginWindow with Password Failure"
   echo "5) Login through LoginWindow with Apple Watch Success"
   echo "6) Login through LoginWindow with Password Success"
   echo "7) Login through LoginWindow with TouchID Failure"
   echo "8) Login through LoginWindow with TouchID Success"
   echo "0) Exit"
   echo "========================================================"
}

# Function to handle continue/exit choice
handle_continuation() {
   while true; do
       echo
       echo "What would you like to do?"
       echo "1) Check more logs"
       echo "2) Exit"
       read -p "Enter your choice (1-2): " continue_choice
       
       case $continue_choice in
           1) return 0 ;;  # Continue
           2) echo "Exiting..."
              exit 0 ;;
           *) echo "❌ Invalid choice. Please enter 1 or 2." ;;
       esac
   done
}

# Main script
while true; do
   clear
   show_menu
   read -p "Enter your choice (0-8): " choice

   if [ "$choice" == "0" ]; then
       echo "Exiting..."
       exit 0
   fi

   if ! [[ "$choice" =~ ^[1-8]$ ]]; then
       echo "❌ Invalid choice. Press Enter to continue..."
       read
       continue
   fi

   # Show date format info before asking for dates
   show_date_info
   
   echo "📅 Please specify the time range for the logs:"
   start_date=$(get_date_input "Enter start date" "true")
   end_date=$(get_date_input "Enter end date (optional)" "false")

   # Array of predicates
   declare -a predicates=(
       ''  # Index 0 is empty to align with menu numbers
       'subsystem == "com.apple.opendirectoryd" AND process == "opendirectoryd" AND category == "auth" AND eventMessage CONTAINS "Failed to change password"'
       'subsystem == "com.apple.opendirectoryd" AND process == "opendirectoryd" AND category == "auth" AND eventMessage CONTAINS "Password changed for"'
       'processImagePath BEGINSWITH "/System/Library/CoreServices" AND process == "loginwindow" AND eventMessage CONTAINS[c] "INCORRECT"'
       'processImagePath BEGINSWITH "/System/" AND process == "SecurityAgent" AND subsystem == "com.apple.loginwindow" AND eventMessage CONTAINS "Authentication failure"'
       'processImagePath ENDSWITH[c] "loginwindow" and eventMessage contains[c] "LWScreenLockAuthentication" and eventMessage contains[c] "screensaver_aks"'
       'processImagePath BEGINSWITH "/System/Library/CoreServices" AND process == "loginwindow" AND subsystem == "com.apple.loginwindow.logging" AND eventMessage CONTAINS "[Login1 doLogin] | shortUsername"'
       'process == "loginwindow" AND eventMessage CONTAINS[c] "APEventTouchIDNoMatch"'
       'process == "loginwindow" AND eventMessage CONTAINS[c] "APEventTouchIDMatch"'
   )

   # Generate output filename based on selection and date range
   output_file="log_output_${choice}_$(date +%Y%m%d_%H%M%S).txt"

   echo "🔍 Fetching logs... This may take a moment."
   if [ -z "$end_date" ]; then
       log show --predicate "${predicates[$choice]}" --style compact --start "$start_date" > "$output_file"
   else
       log show --predicate "${predicates[$choice]}" --style compact --start "$start_date" --end "$end_date" > "$output_file"
   fi

   echo "✅ Logs have been saved to: $output_file"
   
   # Ask if user wants to continue or exit
   handle_continuation
done
