#!/bin/bash

# Script to automatically create an application entry
# based on information given by the user

while true; do # Ask if entry is a game or application
    echo "Is it a Game or Application? (g,a)"
    read -r ENTRY_TYPE
    
    if [ "$ENTRY_TYPE" == "g" ] || [ "$ENTRY_TYPE" == "a" ]; then
        break
    else
        echo "Invalid Entry" # Continue Loop (No Break)
    fi
done

if [ "$ENTRY_TYPE" == "g" ]; then # Check if entry is a game
    while true; do # Check if game is native to linux
        echo "Is the game native to linux? (y,n)"
        read -r LINUX_NATIVE_GAME
        
        if [ "$LINUX_NATIVE_GAME" == "y" ]; then
            break # Stop Loop
        elif [ "$LINUX_NATIVE_GAME" == "n" ]; then # Prompt the user with instructions
            echo -e "Add the Game to Steam:\n\n1.  In Steam, click the + at the bottom left.\n2.  Click 'Add a Non-Steam Game... --> Browse...'\n3.  Select the Game Executable and Click 'Add Selected Programs'\n4.  Find and Open the Game Page in your Library.\n5.  Click the Gear Icon to the right, below the Game banner.\n6.  Click 'Properties...'\n7.  Re-Name the Game (Optional)\n8.  Add an Icon (Must be .png or .jpg)\n9. Click 'Compatibility'\n10. Enable 'Force the use of a specific Steam Play compatibility tool'\n11. Select the newest Proton version.\n12. Close the Properties window\n13. Select 'Gear Icon --> Manage --> Add desktop shortcut'"
            while true; do # Confirm shortcut is on desktop
                echo "Once completed, Is the shortcut on the Desktop? (y,n)"
                read -r DESKTOP
            
                if [ "$DESKTOP" == "y" ]; then # Move shortcut to $HOME/.local/share/applications
                    mv "$(find ~/Desktop -type f -name '*.desktop' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)" "$HOME/.local/share/applications"
                    echo "Your Game is now in Applications!"
                    exit 0 # End Script
                elif [ "$DESKTOP" == "n" ]; then
                    echo "Read the Instructions again" # Continue Loop (No Break)
                else
                    echo "Invalid Entry" # Continue Loop (No Break)
                fi
            done
        else
            echo "Invalid Entry"
        fi
    done
fi

if [ "$ENTRY_TYPE" == "a" ]; then # Check if entry is a game
    while true; do # Check if game is native to linux
        echo "Is the application native to linux? (y,n)"
        read -r LINUX_NATIVE_APP
        
        if [ "$LINUX_NATIVE_APP" == "y" ]; then
            break # Stop Loop
        elif [ "$LINUX_NATIVE_APP" == "n" ]; then # Prompt the user with instructions
            echo -e "Use Wine to Install the Application:\n\n1.  In the Store, Download 'Bottles'.\n2.  Click 'Create New Bottle...' or Click the + at the top left\n3.  Give the Bottle a name.\n4.  Keep 'Application' selected\n5.  Select a runner version (recommended: soda)\n6.  Click 'Create'\n7.  Wait for dependencies to install\n8.  Click the newly created Bottle\n9.  Click 'Run Executable...'\n10. Select the Application Installer and Click 'Run'\n11. Navigate through the Application Installer\n\nThe Application will appear under 'Programs'\n"
            while true; do # Confirm shortcut is on desktop
                echo "Once completed, Did the Application Start? (y,n)"
                read -r BOTTLES
            
                if [ "$BOTTLES" == "y" ]; then
                    echo "Your Application is installed!"
                    exit 0 # End Script
                elif [ "$BOTTLES" == "n" ]; then
                    echo -e "The Application may have dependencies that are not automatically installed.\n\nHow to Install Dependencies:\n\n1. Click the Bottle with the Application installed\n2. Scroll down to 'Options' and Click 'Dependencies'\n3. A list will populate with installers for dependencies\n\nIf you don't know which dependencies are required, search online"
                    exit 0 # End Script
                else
                    echo "Invalid Entry" # Continue Loop (No Break)
                fi
            done
        else
            echo "Invalid Entry"
        fi
    done
fi

ENTRY_LABEL="Application"
[ "$ENTRY_TYPE" == "g" ] && ENTRY_LABEL="Game"

echo "What is the name of the $ENTRY_LABEL?"
read -r ENTRY_NAME

# This strips all characters except letters, numbers, dashes, and underscores
FILE_NAME=$(echo "$ENTRY_NAME" | tr -dc 'a-zA-Z0-9_-')

APPLICATION="$HOME/.local/share/applications/$FILE_NAME.desktop"

echo "Add a comment to the $ENTRY_LABEL"
read -r COMMENT

echo "Enter the File Path to the $ENTRY_LABEL (Where the $ENTRY_LABEL is stored)"
read -r EXECUTABLE

echo "Give the app an icon (Enter File Path or 'd' for default)"
read -r ICON_PATH

echo "Does the $ENTRY_LABEL require access to the Terminal? (y,n)"
read -r TERMINAL_ACCESS

echo "What category do you want the $ENTRY_LABEL to be in? ('d' for default)"
read -r CATEGORY

touch "$APPLICATION"
chmod +x "$APPLICATION"

echo -e "[Desktop Entry]\nName=$ENTRY_NAME\nComment=$COMMENT\nExec=$EXECUTABLE\nPath=$(dirname "$EXECUTABLE")" > "$APPLICATION"

if [ "$ICON_PATH" == "d" ]; then
    echo "Icon=/usr/share/icons/hicolor/scalable/apps/com.system76.CosmicAppLibrary.svg" >> "$APPLICATION"
else
    echo "Icon=$ICON_PATH" >> "$APPLICATION"
fi

while true; do
    if [ "$TERMINAL_ACCESS" == "y" ]; then
        echo "Terminal=true" >> "$APPLICATION"
        break # Stop Loop
    elif [ "$TERMINAL_ACCESS" == "n" ]; then
        echo "Terminal=false" >> "$APPLICATION"
        break # Stop Loop
    else
        echo "Invalid Entry" # Continue Loop (No Break)
    fi
done

echo "Type=Application" >> "$APPLICATION"

if [ "$CATEGORY" == "d" ]; then
    echo "Categories=Application;" >> "$APPLICATION"
else
    echo "Categories=$CATEGORY" >> "$APPLICATION"
fi

while true; do
    echo "Do you want to launch the $ENTRY_LABEL using the Entry? (y,n)"
    read -r LAUNCH

    if [ "$LAUNCH" == "y" ]; then # Launch using gio or gtk and hide error messages
        if gio launch "$APPLICATION" &>/dev/null; then
            echo "Launching $ENTRY_NAME..."
        else
            echo "Could not launch automatically. Your environment might not be supported."
            echo "Your $ENTRY_LABEL entry was created!"
        fi
        break # Stop Loop
    elif [ "$LAUNCH" == "n" ]; then
        echo "Your $ENTRY_LABEL entry was created!"
        break # Stop Loop
    else
        echo "Invalid Entry" # Continue Loop (No Break)
    fi
done