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


### Global Options
| Option | Description |
| --- | --- |
| --title "Dialog Title" | Text for the dialog's title, if the title option is not provided, the title bar will not be displayed |
| --header "Dialog Header" | Text for the dialog's header |
| --text "Text" | Text for the dialog's main text area |
| --scrollable_text | In case of long text, allow the text box to have a (vertical) scrollbar instead of the text getting trimmed |
| --icon_file "/path/to/logo.png" | Path to your logo image, the dialog will constraint the image to width of 75 pixels, for best results it is recommended to use a 75x75 pixels PNG image |
| --system_icon "NSImageNameInfo" | Name of macOS's System Image to use, see full list of System Images at <a href="https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/system-icons/">Apple's website</a>, use the names in the "API" column |
| --width 700 | Sets the width of the dialog window to 700 |
| --height 350 | Sets the height of the dialog window to 350 |
| --window_size 700x350 | Sets the size of the dialog window to 700x350 |
| --buttons '["Yes", "No"]' | Sets the dialog buttons from right to left, the buttons string must be with a single quote (') on the outside and the button names surrounded with double quotes ("), if you require to use double quotes on the outside, escape the internal double quotes with a backslash (\), for example: "[\"Yes\", \"No\"]" |
| --allow_quit | Allows the user to close the dialog with CMD+Q, if the user closes the dialog with CMD+Q the dialog will return "-1" as the output to stdout |
| --no_return | Suppress the dialog's output to stdout |
| --encode_text | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\n" for example) |

## Message Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-msgbox.png?raw=true">

Template Name is ***msgbox***.\
Displays a message box.
<br /><br /><br />

Command Example:
```
/path/to/gDialog msgbox --title "Dialog Title" --header "Dialog Header" --text "Dialog Text" --icon_file "/path/to/logo.png"
```

## Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-inputbox.png?raw=true">

Template Name is ***inputbox***.\
Displays an input box with one field.
<br /><br /><br />

Command Example:
```
/path/to/gDialog inputbox --title "Title" --header "Header" --text "Enter your name:" --background_text "Full Name" --icon_file "/path/to/logo.png"
```

| Option | Description |
| --- | --- |
| --background_text "Background Text" | Background text for the input box |
| --initial_text "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |

## Secure Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-secure-inputbox.png?raw=true">

Template Name is ***secure-inputbox***.\
Displays an input box with one secured field, input is masked for use cases like passwords, output is still in plain text.
<br /><br />

Command Example:
```
/path/to/gDialog secure-inputbox --title "Title" --header "Header" --text "Enter your password:" --icon_file "/path/to/logo.png"
```

| Option | Description |
| --- | --- |
| --background_text "Background Text" | Background text for the input box |
| --initial_text "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |

## Text Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-textbox.png?raw=true">

Template Name is ***textbox***.\
Displays a text box.
<br /><br /><br /><br /><br /><br /><br />

Command Example:
```
/path/to/gDialog textbox --title "Title" --header "Header" --text "Do you agree to the T&C?" --icon_file "/path/to/logo.png" --buttons '["Agree", "Cancel"]' --initial_text "Lorem ipsum dolor sit amet, ...lacinia. Cras." --window_size 500x300
```

| Option | Description |
| --- | --- |
| --initial_text "Initial Text" | Initial text for the text box, can be used to prepopulate the text box with text |

## Credentials Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-credentialsbox.png?raw=true">

Template Name is ***credentialsbox***.\
Displays an input box with 2-3 fields, a plain input field, secured input field and an extra (optional) input field.
<br /><br /><br />

Command Example:
```
/path/to/gDialog credentialsbox --title "Title" --header "Header" --text "Enter your corporate credentials:" --icon_file "/path/to/logo.png"
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
/path/to/gDialog htmlbox --title "gDialog - HTML Box" --file "/path/to/html_file.html"
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
