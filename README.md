# macos-authentication-log-checker

A bash script for checking various macOS login and authentication logs. This tool helps system administrators and security professionals monitor authentication events on macOS systems.

## Features

- Monitor password change attempts (success/failure)
- Track login window authentication events
- Monitor TouchID authentication attempts
- Track Apple Watch authentication events
- Export logs to text files for further analysis

## Requirements

- macOS 10.12 or later
- Administrative privileges (for accessing system logs)

## Usage

1. Clone this repository
2. Make the script executable: `chmod +x check_logs.sh`
3. Run the script: `./check_logs.sh`

## Log Types Available

1. Local User Password Change Failure
2. Local User Password Change Success
3. Lock Screen Unlock Failure
4. Login through LoginWindow with Password Failure
5. Login through LoginWindow with Apple Watch Success
6. Login through LoginWindow with Password Success
7. Login through LoginWindow with TouchID Failure
8. Login through LoginWindow with TouchID Success
