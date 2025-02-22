#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Variable to track if there was an error
error_occurred=false
error_message=""

# Check if Git is installed
if ! command_exists git; then
    echo "Git is not installed."

    # Ask the user if they'd like to install Git, default is 'Yes'
    read -r -p "Would you like to install Git? (Y/n): " response
    response=${response:-Y}  # Default to 'Y' if no response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing Git..."
        sudo apt update && sudo apt install -y git
    if [[ $? -ne 0 ]]; then
        error_occurred=true
        error_message+="Error: Failed to install Git.\n"
    fi
    else
        echo "Git installation aborted. Please install Git manually to continue."
        exit 1
    fi
fi

# Navigate to the ThiccPaper directory
cd thiccpaper || { 
    error_occurred=true
    error_message+="Error: Failed to navigate to 'thiccpaper' directory.\n"
}

# Check if this is a valid git repository
if [[ $error_occurred == false ]] && [[ ! -d .git ]]; then
    error_occurred=true
    error_message+="Error: This directory is not a valid git repository.\n"
fi

# Pull the latest changes from GitHub
if [[ $error_occurred == false ]]; then
    echo "Pulling the latest changes from the GitHub repository..."
    git pull origin main
    if [[ $? -ne 0 ]]; then
        error_occurred=true
        error_message+="Error: Failed to pull the latest changes from GitHub.\n"
    fi
fi

# Check for any npm package updates
if [[ $error_occurred == false ]]; then
    echo "Checking for npm package updates..."
    sudo npm install
    if [[ $? -ne 0 ]]; then
        error_occurred=true
        error_message+="Error: Failed to update npm packages.\n"
    fi
fi

# Display completion message based on success or failure
if [[ $error_occurred == false ]]; then
    echo "Update complete. ThiccPaper is up-to-date!"
else
    echo -e "There was an issue with the update:\n$error_message"
fi
