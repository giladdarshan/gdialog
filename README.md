# gDialog
Display macOS dialogs from terminal and scripts.\
Supported on:
* macOS Catalina (10.15)
* macOS Big Sur (11.x)

### Current Status
gDialog is currently in final stages of development to ensure all the features are working properly.\
Syntax may change before production release.

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
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-yesno.png?raw=true">

The return values will be printed to stdout.\
The return values will contain which button number was clicked (Right to Left) and each value will be separated by a new line.


Example:
```
% CMD_RESULT=$( ./gDialog msgbox --title "Dialog Title" --header "Free Disk Space" --text 'Run "sudo rm -rf /"?' --icon_file "./assets/GD-Logo.png" --buttons '["Yes", "No"]' )
% echo "${CMD_RESULT}"
1
```

### Table of Contents
TBD

### Global Options
| Option | Description |
| --- | --- |
| --title "Dialog Title" | Text for the dialog's title, if the title option is not provided, the title bar will not be displayed |
| --header "Dialog Header" |	Text for the dialog's header |
| --text "Text" |	Text for the dialog's main text area |
| --scrollable_text	| In case of long text, allow the text box to have a (vertical) scrollbar instead of the text getting trimmed |
| --icon_file "/path/to/logo.png" |	Path to your logo image, the dialog will constraint the image to width of 75 pixels, for best results it is recommended to use a 75x75 pixels PNG image |
| --system_icon "NSImageNameInfo" |	Name of macOS's System Image to use, see full list of System Images at Apple's website, use the names in the "API" column |
| --width 700 |	Sets the width of the dialog window to 700 |
| --height 350 |	Sets the height of the dialog window to 350 |
| --window_size 700x350 |	Sets the size of the dialog window to 700x350 |
| --buttons '["Yes", "No"]' |	Sets the dialog buttons from right to left, the buttons string must be with a single quote (') on the outside and the button names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\), for example: "[\"Yes\", \"No\"]" |
| --allow_quit |	Allows the user to close the dialog with CMD+Q, if the user closes the dialog with CMD+Q the dialog will return "-1" as the output to stdout |
| --no_return |	Suppress the dialog's output to stdout |
| --encode_text |	Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\n" for example) |
