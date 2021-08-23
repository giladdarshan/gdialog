# gDialog
Display macOS dialogs from terminal and scripts, capable of displaying advanced dialogs and forms using the different templates.
<br />

gDialog is using the system color scheme, if the Mac has Dark Mode turned on, the background will be dark, if Dark Mode is turned off, the background will be bright.
| Light Mode | Dark Mode |
| --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-light-mode.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-dark-mode.png?raw=true"> |

Supported on:
* macOS Catalina (10.15.x)
* macOS Big Sur (11.x) - Intel or M1 with Rosetta

### Current Status
gDialog is available as a standalone application and as a [Node.js module](https://github.com/giladdarshan/gdialog/blob/main/README-NPM.md).

### Downloading gDialog
[Download gDialog v1.0.1](https://github.com/giladdarshan/gdialog/releases/download/v1.0.1/gDialog_v1.0.1.pkg)

### Installing gDialog
Download and install the package from the release page or from the link above.\
gDialog will be installed to `/usr/local/gDialog/`\
Application Name: `gDialog.app`\
Bundle Identifier: `com.gilad.gDialog`\
Executable Path: `/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog`

### Executing gDialog
gDialog is executed in the following format:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog template_name options
```
The "template_name" parameter is always required in order to specify which dialog template to use.\
If the option "--buttons" is not provided, an "OK" button will be added by default.\
Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog msgbox --title "Dialog Title" --header "Dialog Header" --text "Dialog Text" --icon_file "/path/to/logo.png"
```

### Return Values / Output
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-yesno.png?raw=true">

The return values will be printed to stdout.\
The return values will contain which button number was clicked (Right to Left) and each value will be separated by a new line.
<br /><br />


Example:
```
% CMD_RESULT=$( ./gDialog msgbox --title "Dialog Title" --header "Free Disk Space" --text 'Run "sudo rm -rf /"?' --icon_file "./assets/GD-Logo.png" --buttons '["Yes", "No"]' )
% echo "${CMD_RESULT}"
1
```

### Table of Contents
- [Global Options](#global-options)
- [Message Box](#message-box)
- [Input Box](#input-box)
- [Secure Input Box](#secure-input-box)
- [Text Box](#text-box)
- [Credentials Box](#credentials-box)
- [HTML Box](#html-box)
- [Progress Bar](#progress-bar)
- [Picker Box](#picker-box)
- [File Select](#file-select)
- [File Save](#file-save)
- [Banner Box](#banner-box)
- [Notification](#notification)


### Global Options
| Option | Description |
| --- | --- |
| --title "Dialog Title" | Text for the dialog's title, if the title option is not provided, the title bar will not be displayed |
| --header "Dialog Header" | Text for the dialog's header |
| --text "Text" | Text for the dialog's main text area |
| --scrollable_text | In case of long text, allow the text box to have a (vertical) scrollbar instead of the text getting trimmed |
| --icon_file "/path/to/logo.png" | Path to your logo image, the dialog will constraint the image to width of 75 pixels, for best results it is recommended to use a 75x75 pixels PNG image |
| --system_icon "NSImageNameInfo" | Name of macOS's System Image to use, see full list of System Images at [Apple's website](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/system-icons/), use the names in the "API" column |
| --width 700 | Sets the width of the dialog window to 700 |
| --height 350 | Sets the height of the dialog window to 350 |
| --window_size 700x350 | Sets the size of the dialog window to 700x350 |
| --buttons '["Yes", "No"]' | Sets the dialog buttons from right to left. The buttons string must be with a single quote (') on the outside and the button names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\\), for example: "[\\"Yes\\", \\"No\\"]" |
| --allow_quit | Allows the user to close the dialog with CMD+Q, if the user closes the dialog with CMD+Q the dialog will return "-1" as the output to stdout |
| --no_return | Suppress the dialog's output to stdout |
| --focus | Makes the dialog window take focus and become the active window |
| --timeout 300 | Sets the dialog timeout to 300 seconds (5 minutes) |
| --static | Prevents the user from being able to move / drag the dialog window |

<br /><br />
## Message Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-msgbox.png?raw=true">

Template Name is ***msgbox***.\
Displays a message box.
<br /><br /><br />

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog msgbox --title "Dialog Title" --header "Dialog Header" --text "Dialog Text" --icon_file "/path/to/logo.png" --focus
```
<br /><br />

## Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-inputbox.png?raw=true">

Template Name is ***inputbox***.\
Displays an input box with one field.
<br /><br /><br />

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog inputbox --title "Title" --header "Header" --text "Enter your name:" --background_text "Full Name" --icon_file "/path/to/logo.png" --focus
```

| Option | Description |
| --- | --- |
| --background_text "Background Text" | Background text for the input box |
| --initial_text "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |
| --encode_text | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Secure Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-secure-inputbox.png?raw=true">

Template Name is ***secure-inputbox***.\
Displays an input box with one secured field, input is masked for use cases like passwords, output is still in plain text.
<br /><br />

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog secure-inputbox --title "Title" --header "Header" --text "Enter your password:" --icon_file "/path/to/logo.png" --focus
```

| Option | Description |
| --- | --- |
| --background_text "Background Text" | Background text for the input box |
| --initial_text "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |
| --encode_text | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Text Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-textbox.png?raw=true">

Template Name is ***textbox***.\
Displays a text box.
<br /><br /><br /><br /><br /><br /><br />

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog textbox --title "Title" --header "Header" --text "Do you agree to the T&C?" --icon_file "/path/to/logo.png" --buttons '["Agree", "Cancel"]' --initial_text "Lorem ipsum dolor sit amet, ...lacinia. Cras." --window_size 500x300 --focus
```

| Option | Description |
| --- | --- |
| --initial_text "Initial Text" | Initial text for the text box, can be used to prepopulate the text box with text |
| --encode_text | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Credentials Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-credentialsbox.png?raw=true">

Template Name is ***credentialsbox***.\
Displays an input box with 2-3 fields, a plain input field, secured input field and an extra (optional) input field.
<br /><br /><br />

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog credentialsbox --title "Title" --header "Header" --text "Enter your corporate credentials:" --icon_file "/path/to/logo.png" --focus
```

| Option | Description |
| --- | --- |
| --user_label "First Field:" | First input field's label, defaults to "Username:" if option is not provided |
| --user_initial_text "Initial Text" | Initial text for the first input field |
| --user_background_text "Background Text" | Background text for the first input field, defaults to "Enter your username" if option is not provided |
| --pass_label "Second Field:" | Second input field's label, defaults to "Password:" if option is not provided |
| --pass_initial_text "Initial Text" | Initial text for the second input field |
| --pass_background_text "Background Text" | Background text for the second input field, defaults to "Enter your password" if option is not provided |
| --extra_field_label "Extra Field:" | Extra input field's label, if option is not provided, the extra field will not be shown |
| --extra_field_initial_text "Initial Text" | Initial text for the extra input field |
| --extra_field_background_text "Background Text" | Background text for the extra input field |
| --extra_field_secured | Toggles the extra input field from plain text to secured input field |
| --encode_text | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## HTML Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-htmlbox.png?raw=true">

Template Name is ***htmlbox***.\
Displays a window which allows to load HTML for advanced forms and GUI.\
The following global options are not available in this template:\
header, text, icon_file, system_icon, buttons and scrollable_text.

To return text from the dialog, use the javascript function print("text").
To close the dialog, use the javascript function quit().

Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog htmlbox --title "gDialog - HTML Box" --file "/path/to/html_file.html" --focus
```

HTML Page Example:
```
<form action="" id="sampleForm">
 <h2>Hello World</h2>
 <label>Enter your name:</label>
 <input type="text" name="username">
 <button type="submit" id="btnSubmit">Submit</button>
</form>
<script type="text/javascript">
 var sampleForm = document.querySelector("#sampleForm");
 if (sampleForm) {
  sampleForm.addEventListener("submit", function(e) {
   e.preventDefault();
   var btnSubmit = document.getElementById("btnSubmit");
   btnSubmit.disabled = true;
   var jsonData = {};
   for (var pair of new FormData(this)) {
    jsonData[pair[0]] = pair[1];
   }
   console.log(jsonData);
   print(JSON.stringify(jsonData));
   quit();
  });
 }
</script>
```

| Option | Description |
| --- | --- |
| --html_b64 "HTML file in Base64" | HTML page encoded in a Base64 string |
| --file "/path/to/html_file.html" | Path to the HTML file |
| --base_path "/path/to/folder" | Base path of the running HTML, useful when using dynamic links to local files and images |
| --url "https://github.com/giladdarshan/gdialog" | Displays the provided URL |
| --kiosk | Displays the HTML dialog in a full screen kiosk mode, preventing the user from moving away or closing the dialog |
| --normal_window | Displays the HTML dialog as a normal window with a menu bar, quit/resize/minimize buttons and a dock icon |

<br /><br />
## Progress Bar
Template Name is ***progressbar***.\
Displays a progress bar, depends on the options used, can display a progress bar that fills up, or, an indeterminate progress bar.\
The following global options are not available in this template:\
header, scrollable_text and buttons.

| Regular Progress Bar | Indeterminate Progress Bar |
| --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-progressbar.gif?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-progressbar-indeterminate.gif?raw=true"> |

#### Regular Progress Bar Example:
```
# Variables
PIPE_PATH="/private/tmp/apipe"
GDIALOG_PID=""

# Create a named pipe
rm -f "${PIPE_PATH}"
mkfifo "${PIPE_PATH}"

# Start gDialog in the background which takes the input (stdin) from the named pipe
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog progressbar --icon_file "/path/to/logo.png" --title "Death Star Construction" --text "Please wait..." --focus < "${PIPE_PATH}" &
GDIALOG_PID=$!
# Associate file descriptor 3 with the pipe and start the progress bar
exec 3<> "${PIPE_PATH}"


# Do stuff
sleep 1
# Send progress to the progress bar, the line must start with the progress percentage and then the text separated by a space, if only the progress percentage is provided, the initial text will not change
echo "60 Building The Death Star" >&3
sleep 2
echo "100 The Death Star construction is completed" >&3

# Close the progress bar by sending an "EOF" message and then closing file descriptor 3
echo "EOF" >&3
exec 3>&-

# Wait for the background job to exit, or, kill the process saved in the variable "GDIALOG_PID"
wait

# Delete the named pipe
rm -f "${PIPE_PATH}"

# Exit
exit 0
```

#### Indeterminate Progress Bar Example:
```
# Variables
GDIALOG_PID=""

# Start gDialog in the background, if you would like to update the text, use the example of the regular progress bar and add the "--indeterminate"
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog progressbar --icon_file "/path/to/logo.png" --title "Attack" --text "Attacking The Death Star" --indeterminate --focus 2>&1 > /dev/null &
GDIALOG_PID=$!

# Do stuff
sleep 15

# Kill the process saved in the variable "GDIALOG_PID"
kill $GDIALOG_PID

# Exit
exit 0
```
<br />

| Option | Description |
| --- | --- |
| --indeterminate | Displays an indeterminate progress bar |
| --stoppable | Adds a "Stop" button to the progress bar |

<br /><br />
## Picker Box
Template Name is ***pickerbox***.\
Displays a dialog window with either a drop down menu (default), radio buttons or segmented buttons, depends on the options used.

| Drop Down Menu | Radio Buttons | Segmented Buttons |
| --- | --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-dropdown.gif?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-radio.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-segmented.gif?raw=true"> |
 
Command Example:
```
GDIALOG_BIN="/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog"
# Drop Down Menu
"${GDIALOG_BIN}" pickerbox --icon_file "/path/to/logo.png" --title "Title" --header "Header" --text "Select a number:" --items '["1", "2", "3"]' --buttons '["OK", "Cancel"]' --focus

# Radio Buttons
"${GDIALOG_BIN}" pickerbox --icon_file "/path/to/logo.png" --title "Title" --header "Header" --text "Select a number:" --items '["1", "2"]' --buttons '["OK", "Cancel"]' --style radio --focus

# Segmented Buttons
"${GDIALOG_BIN}" pickerbox --icon_file "/path/to/logo.png" --title "Title" --header "Header" --text "Select a number:" --items '["1", "2"]' --buttons '["OK", "Cancel"]' --style segmented --focus
```

| Option | Description |
| --- | --- |
| --items '["Item 1","Item 2"]' | The items to display in the picker box. The string must be with a single quote (') on the outside and the item names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\\), for example: "[\\"Item 1\\", \\"Item 2\\"]" |
| --style "style" | Defines the style of the picker box, options are *default*, *radio* and *segmented*. "default" style is the drop down menu |

<br /><br />
## File Select
<img align="right" width="340" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-fileselect.png?raw=true">

Template Name is ***fileselect***.\
Displays a dialog window with an input field and a button to open the file select dialog.<br />
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-fileselect-2.png?raw=true">
<br /><br />
 
Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog fileselect --icon_file "/path/to/logo.png" --title "Title" --header "Header" --text "Please select a file" --buttons '["OK", "Cancel"]' --focus
```

| Option | Description |
| --- | --- |
| --with_file "/starting/path" | Starts the file select dialog with the specified file alrady selected |
| --with_directory "/starting/directory" | Starts the file select dialog showing the specified directory |
| --with_extensions '["jpg", "png"]' | Limits file selection to specified file extensions. The string must be with a single quote (') on the outside and the file extension names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\\), for example: "[\\"jpg\\", \\"png\\"]" |
| --packages_as_directories | Treats installation packages as directories |
| --select_directories | Allows the user to select directories |
| --select_only_directories | Allows the user to select **only** directories |
| --select_multiple | Allows the user to select multiple files |

<br /><br />
## File Save
<img align="right" width="340" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-filesave.png?raw=true">

Template Name is ***filesave***.\
Displays a dialog window with an input field and a button to open the file save dialog.<br />
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-filesave-2.png?raw=true">
<br /><br />
 
Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog filesave --icon_file "/path/to/logo.png" --title "Title" --header "Header" --text "Please select where to save the file" --buttons '["OK", "Cancel"]' --focus
```

| Option | Description |
| --- | --- |
| --with_file "/starting/path" | Starts the file select dialog with the specified file alrady selected |
| --with_directory "/starting/directory" | Starts the file select dialog showing the specified directory |
| --with_extensions '["jpg", "png"]' | Limits file selection to specified file extensions. The string must be with a single quote (') on the outside and the file extension names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\\), for example: "[\\"jpg\\", \\"png\\"]" |
| --packages_as_directories | Treats installation packages as directories |
| --dont_create_directories | Prevents the user from creating directories |

<br /><br />
## Banner Box
Template Name is ***bannerbox***.\
Displays a banner dialog window in the top right corner of the screen with up to two buttons.\
**NOTE:** This template is not utilizing macOS's notification center.

| Banner Box | Banner Box with one button | Banner Box with two buttons |
| --- | --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-bannerbox.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-bannerbox-one-button.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-bannerbox-two-buttons.png?raw=true"> |
 
Command Example:
```
/usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog bannerbox --icon_file "/path/to/logo.png" --header "Header" --text "Banner Box with two buttons" --buttons '["OK", "Cancel"]' --focus
```

| Option | Description |
| --- | --- |
| --background_color "#000000" | Specify a background color in [hex color code](https://htmlcolorcodes.com/) |

<br /><br />
## Notification
Template Name is ***notification***.\
Sends a notification to macOS's notification center.\
The notification must be sent as the user, to do so, you can use the `launchctl asuser` command as shown in the example below.\
Unless gDialog is pre-approved for notifications via the [MDM notifications payload](https://support.apple.com/guide/mdm/notifications-payload-settings-mdm46b6547ba/web), the user will get a notification asking to approve gDialog to present notifications:\
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-request.png?raw=true">
<br />
The following global options are not available in this template:\
icon_file, system_icon,  buttons, width, height, window_size, allow_quit, no_return, focus and scrollable_text.\

| macOS Big Sur | macOS Catalina |
| --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-bigsur.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-catalina.png?raw=true"> |
 
Command Example:
```
USER_UID=$(id -u $(stat -f%Su /dev/console))
launchctl asuser $USER_UID /usr/local/gDialog/gDialog.app/Contents/MacOS/gDialog notification --title "Title" --header "Header" --text "Notification Text"
```

| Option | Description |
| --- | --- |
| --dont_wait | Don't wait for for the notification to be seen by the user |
