# gDialog
Display macOS dialogs from terminal and scripts.\
Supported on:
* macOS Catalina (10.15)
* macOS Big Sur (11.x)

### Current Status
gDialog is currently in final stages of development to ensure all the features are working properly.

### Executing gDialog
gDialog is executed in the following format:
```
/path/to/gDialog template_name options
```
The "template_name" parameter is always required in order to specify which dialog template to use.\
If the option "--buttons" is not provided, an "OK" button will be added by default.\
Example:
```
/path/to/gDialog msgbox --title "Dialog Title" --header "Dialog Header" --text "Dialog Text" --icon_file "/path/to/logo.png"
```

### Return Values / Output
The return values will be printed to stdout.\
The return values will contain which button number was clicked (Right to Left) and each value will be separated by a new line.\
Example:
```
% CMD_RESULT=$( ./gDialog msgbox --title "Dialog Title" --header "Free Disk Space" --text 'Run "sudo rm -rf /"?' --icon_file "./assets/GD-Logo.png" --buttons '["Yes", "No"]' )
% echo "${CMD_RESULT}"
1
```
