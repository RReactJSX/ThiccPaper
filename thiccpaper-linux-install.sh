#!/bin/bash

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Variable to track if there was an error
error_occurred=false
error_message=""

# Check if Node.js and npm are installed
if ! command_exists node || ! command_exists npm; then
  echo "Node.js or npm is not installed."

  # Ask the user if they'd like to install Node.js and npm, default is 'Yes'
  read -r -p "Would you like to install Node.js and npm? (Y/n): " response
  response=${response:-Y}  # Default to 'Y' if no response

  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Node.js and npm..."
    sudo apt update && sudo apt install -y nodejs npm
    if [[ $? -ne 0 ]]; then
      error_occurred=true
      error_message+="Error: Failed to install Node.js and npm.\n"
    fi
  else
    echo "Node.js and npm installation aborted. Please install them manually to continue."
    exit 1
  fi
fi

# Check if Java is installed
if ! command_exists java; then
  echo "Java is not installed."

  # Ask the user if they'd like to install Java, default is 'Yes'
  read -r -p "Would you like to install Java? (Y/n): " response
  response=${response:-Y}  # Default to 'Y' if no response

  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Installing Java..."
    sudo apt update && sudo apt install -y default-jre
    if [[ $? -ne 0 ]]; then
      error_occurred=true
      error_message+="Error: Failed to install Java.\n"
    fi
  else
    echo "Java installation aborted. Please install Java manually to continue."
    exit 1
  fi
fi

# Navigate to the application directory
cd /srv/ThiccPaper/ || { 
  error_occurred=true
  error_message+="Error: Failed to navigate to 'thiccpaper' directory.\n"
}

# Install required npm packages
if [[ $error_occurred == false ]]; then
  echo "Installing npm packages..."
  sudo npm install
  if [[ $? -ne 0 ]]; then
    error_occurred=true
    error_message+="Error: Failed to install npm packages.\n"
  fi
fi

# Create directory for Paper installations if not exists
mkdir -p paper-installations || {
  error_occurred=true
  error_message+="Error: Failed to create 'paper-installations' directory.\n"
}

# Create symbolic link for main.js
if [[ $error_occurred == false ]]; then
  sudo ln -sf "/srv/ThiccPaper/main.js" /usr/local/bin/thiccpaper
  if [[ $? -ne 0 ]]; then
    error_occurred=true
    error_message+="Error: Failed to create symbolic link for 'main.js'.\n"
  else
    sudo chmod +x /usr/local/bin/thiccpaper
    if [[ $? -ne 0 ]]; then
      error_occurred=true
      error_message+="Error: Failed to make 'thiccpaper' executable.\n"
    fi
  fi
fi

# Display completion message based on success or failure
if [[ $error_occurred == false ]]; then
  echo "Installation complete. ThiccPaper is ready to use!"
else
  echo -e "There was an issue with the installation:\n$error_message"
fi
