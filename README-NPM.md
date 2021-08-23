# gDialog
Display macOS dialogs from Node.js projects, terminal and scripts, capable of displaying advanced dialogs and forms using the different templates.
<br />

gDialog is using the system color scheme, if the Mac has Dark Mode turned on, the background will be dark, if Dark Mode is turned off, the background will be bright.
| Light Mode | Dark Mode |
| --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-light-mode.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-dark-mode.png?raw=true"> |

Supported on:
* macOS Catalina (10.15.x)
* macOS Big Sur (11.x) - Intel or M1 with Rosetta

### Current Status
gDialog is available as a Node.js module and as a [standalone application](https://github.com/giladdarshan/gdialog).\
**NOTE:** NPM Package is currently pending publish to registry.

### Installing gDialog
Install the gDialog package with the command:
```
npm install -P gdialog
```
**NOTE:** If you have spaces in the project's folder path, node-gyp's build will fail.

### Usage
gDialog requires an `options` object, if the `options` object is not provided, gDialog will attempt to parse the command line arguments as the described in the [standalone application](https://github.com/giladdarshan/gdialog).\
The `options` object must contain a `type` key/value with the name of the template, if the `buttons` key is not provided, an "OK" button will be added by default.\
gDialog can be called in the following formats:
* Synchronous - Waits for the dialog to be closed before returning
```
const gDialog = require('gdialog');
let options = {
    type: 'msgbox',
    title: 'Dialog Title',
    header: 'Dialog Header',
    text: 'Dialog Text',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```
* Asynchronous - Returns a promise
```
const gDialog = require('gdialog');
let options = {
    type: 'msgbox',
    title: 'Dialog Title',
    header: 'Dialog Header',
    text: 'Dialog Text',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
dialog.run(options).then(result => {
    console.log("Run Result:", result);
}).catch(err => {
    console.log("Run Error:", err);
});
```
* Asynchronous with callback - All dialog interactions will be routed to the callback function, dialog will remain open until explicitly closed
```
const gDialog = require('gdialog');
function dialogCallback(returnString) {
    console.log("Callback:", returnString);
    dialog.close();
}
let options = {
    type: 'msgbox',
    title: 'Dialog Title',
    header: 'Dialog Header',
    text: 'Dialog Text',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
dialog.setCallback(dialogCallback);
dialog.run(options).then(result => {
    console.log("Run Result:", result);
}).catch(err => {
    console.log("Run Error:", err);
});
```

### Return Values / Output
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-yesno.png?raw=true">

The return values will be handled depends on which method gDialog was invoked with.\
The return values will contain which button number was clicked (Right to Left) and each value will be separated by a new line "\\n".
<br /><br />


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
| Key | Value (Example) | Description |
| --- | --- | --- |
| title | "Dialog Title" | Text for the dialog's title, if the title option is not provided, the title bar will not be displayed |
| header | "Dialog Header" | Text for the dialog's header |
| text | "Text" | Text for the dialog's main text area |
| scrollable_text | true | In case of long text, allow the text box to have a (vertical) scrollbar instead of the text getting trimmed |
| icon_file | "/path/to/logo.png" | Path to your logo image, the dialog will constraint the image to width of 75 pixels, for best results it is recommended to use a 75x75 pixels PNG image |
| system_icon | "NSImageNameInfo" | Name of macOS's System Image to use, see full list of System Images at [Apple's website](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/system-icons/), use the names in the "API" column |
| width | 700 | Sets the width of the dialog window to 700 |
| height | 350 | Sets the height of the dialog window to 350 |
| window_size | "700x350" | Sets the size of the dialog window to 700x350 |
| buttons | ["Yes", "No"] | Sets the dialog buttons from right to left. The buttons must be provided as an array |
| allow_quit | true | Allows the user to close the dialog with CMD+Q, if the user closes the dialog with CMD+Q the dialog will return "-1" as the output |
| no_return | false | Suppress the dialog's output text |
| focus | true | Makes the dialog window take focus and become the active window |
| timeout | 300 | Sets the dialog timeout to 300 seconds (5 minutes) |
| static | true | Prevents the user from being able to move / drag the dialog window |

<br /><br />
## Message Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-msgbox.png?raw=true">

Template Name is ***msgbox***.\
Displays a message box.
<br /><br /><br />

Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'msgbox',
    title: 'Dialog Title',
    header: 'Dialog Header',
    text: 'Dialog Text',
    icon_file: '/path/to/logo.png',
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```
<br /><br />

## Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-inputbox.png?raw=true">

Template Name is ***inputbox***.\
Displays an input box with one field.
<br /><br /><br />

Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'inputbox',
    title: 'Title',
    header: 'Header',
    text: 'Enter your name:',
    background_text: 'Full Name',
    icon_file: '/path/to/logo.png',
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| background_text | "Background Text" | Background text for the input box |
| initial_text | "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |
| encode_text | true | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Secure Input Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-secure-inputbox.png?raw=true">

Template Name is ***secure-inputbox***.\
Displays an input box with one secured field, input is masked for use cases like passwords, output is still in plain text.
<br /><br />

Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'secure-inputbox',
    title: 'Title',
    header: 'Header',
    text: 'Enter your password:',
    icon_file: '/path/to/logo.png',
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| background_text | "Background Text" | Background text for the input box |
| initial_text | "Initial Text" | Initial text for the input box, can be used to prepopulate the inputbox with text |
| encode_text | true | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Text Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-textbox.png?raw=true">

Template Name is ***textbox***.\
Displays a text box.
<br /><br /><br /><br /><br /><br /><br />

Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'textbox',
    title: 'Dialog Title',
    header: 'Dialog Header',
    text: 'Do you agree to the T&C?',
    initial_text: 'Lorem ipsum dolor sit amet, ...lacinia. Cras.',
    icon_file: '/path/to/logo.png',
    window_size: '500x300',
    buttons: [ 'Agree', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| initial_text | "Initial Text" | Initial text for the text box, can be used to prepopulate the text box with text |
| encode_text | true | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

<br /><br />
## Credentials Box
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-credentialsbox.png?raw=true">

Template Name is ***credentialsbox***.\
Displays an input box with 2-3 fields, a plain input field, secured input field and an extra (optional) input field.
<br /><br /><br />

Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'credentialsbox',
    title: 'Title',
    header: 'Header',
    text: 'Enter your corporate credentials:',
    icon_file: '/path/to/logo.png',
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| user_label | "First Field:" | First input field's label, defaults to "Username:" if option is not provided |
| user_initial_text | "Initial Text" | Initial text for the first input field |
| user_background_text | "Background Text" | Background text for the first input field, defaults to "Enter your username" if option is not provided |
| pass_label | "Second Field:" | Second input field's label, defaults to "Password:" if option is not provided |
| pass_initial_text | "Initial Text" | Initial text for the second input field |
| pass_background_text | "Background Text" | Background text for the second input field, defaults to "Enter your password" if option is not provided |
| extra_field_label | "Extra Field:" | Extra input field's label, if option is not provided, the extra field will not be shown |
| extra_field_initial_text | "Initial Text" | Initial text for the extra input field |
| extra_field_background_text | "Background Text" | Background text for the extra input field |
| extra_field_secured | true | Toggles the extra input field from plain text to secured input field |
| encode_text | true | Encodes returned values in Base64 to ensure environments like Bash won't interpet special characters and combinations ("\\n" for example) |

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
const gDialog = require('gdialog');
let options = {
    type: 'htmlbox',
    title: 'gDialog',
    file: '/path/to/html_file.html',
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
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
   print(JSON.stringify(jsonData));
   quit();
  });
 }
</script>
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| html_b64 | "HTML file in Base64" | HTML page encoded in a Base64 string |
| file | "/path/to/html_file.html" | Path to the HTML file |
| base_path | "/path/to/folder" | Base path of the running HTML, useful when using dynamic links to local files and images |
| url | "https://github.com/giladdarshan/gdialog" | Displays the provided URL |
| kiosk | true | Displays the HTML dialog in a full screen kiosk mode, preventing the user from moving away or closing the dialog |
| normal_window | true | Displays the HTML dialog as a normal window with a menu bar, quit/resize/minimize buttons and a dock icon |

<br /><br />
## Progress Bar
<img align="right" width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-progressbar-indeterminate.gif?raw=true">

Template Name is ***progressbar***.\
Displays an indeterminate progress bar.\
The following global options are not available in this template:\
header, scrollable_text and buttons.\
**NOTE:** Currently only the indeterminate progress bar is supported in the Node.js module.
#### Indeterminate Progress Bar Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'progressbar',
    title: 'Attack',
    header: 'App Header',
    text: 'Attacking The Death Star',
    indeterminate: true,
    icon_file: '/path/to/logo.png',
    focus: true
};
const dialog = new gDialog();
dialog.run(options).then(result => {
    console.log("Run Result:", result);
}).catch(err => {
    console.log("Run Error:", err);
});
// Do Stuff
setTimeout(() => {dialog.close()}, 5000);
```
<br />

| Key | Value (Example) | Description |
| --- | --- | --- |
| indeterminate | true | Displays an indeterminate progress bar |
| stoppable | true | Adds a "Stop" button to the progress bar |

<br /><br />
## Picker Box
Template Name is ***pickerbox***.\
Displays a dialog window with either a drop down menu (default), radio buttons or segmented buttons, depends on the options used.

| Drop Down Menu | Radio Buttons | Segmented Buttons |
| --- | --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-dropdown.gif?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-radio.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-pickerbox-segmented.gif?raw=true"> |
 
Command Example:
```
const gDialog = require('gdialog');
const dialog = new gDialog();
let options = {};

// Drop Down Menu
options = {
    type: 'pickerbox',
    title: 'Title',
    header: 'Header',
    text: 'Select a number:',
    items: ['1', '2', '3'],
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
console.log(dialog.runSync(options));

// Radio Buttons
options = {
    type: 'pickerbox',
    title: 'Title',
    header: 'Header',
    text: 'Select a number:',
    items: ['1', '2'],
    style: 'radio',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
console.log(dialog.runSync(options));

# Segmented Buttons
options = {
    type: 'pickerbox',
    title: 'Title',
    header: 'Header',
    text: 'Select a number:',
    items: ['1', '2'],
    style: 'segmented',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| items | ["Item 1", "Item 2"] | The items to display in the picker box. The value must be provided as an array |
| style | "style" | Defines the style of the picker box, options are *default*, *radio* and *segmented*. "default" style is the drop down menu |

<br /><br />
## File Select
<img align="right" width="340" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-fileselect.png?raw=true">

Template Name is ***fileselect***.\
Displays a dialog window with an input field and a button to open the file select dialog.<br />
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-fileselect-2.png?raw=true">
<br /><br />
 
Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'fileselect',
    title: 'Title',
    header: 'Header',
    text: 'Please select a file',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| with_file | "/starting/path" | Starts the file select dialog with the specified file alrady selected |
| with_directory | "/starting/directory" | Starts the file select dialog showing the specified directory |
| with_extensions | ["jpg", "png"] | Limits file selection to specified file extensions. The value must be provided as an array |
| packages_as_directories | true | Treats installation packages as directories |
| select_directories | true | Allows the user to select directories |
| select_only_directories | true | Allows the user to select **only** directories |
| select_multiple | true | Allows the user to select multiple files |

<br /><br />
## File Save
<img align="right" width="340" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-filesave.png?raw=true">

Template Name is ***filesave***.\
Displays a dialog window with an input field and a button to open the file save dialog.<br />
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-filesave-2.png?raw=true">
<br /><br />
 
Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'filesave',
    title: 'Title',
    header: 'Header',
    text: 'Please select where to save the file',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| with_file | "/starting/path" | Starts the file select dialog with the specified file alrady selected |
| with_directory | "/starting/directory" | Starts the file select dialog showing the specified directory |
| with_extensions | ["jpg", "png"] | Limits file selection to specified file extensions. The value must be provided as an array |
| packages_as_directories | true | Treats installation packages as directories |
| dont_create_directories | true | Prevents the user from creating directories |

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
const gDialog = require('gdialog');
let options = {
    type: 'bannerbox',
    header: 'Header',
    text: 'Banner Box with two buttons',
    icon_file: '/path/to/logo.png',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| background_color | "#000000" | Specify a background color in [hex color code](https://htmlcolorcodes.com/) |

<br /><br />
## Notification
Template Name is ***notification***.\
Sends a notification to macOS's notification center.\
**NOTE:** Notifications will not work from unsigned non-application bundles (.app), in order to use the notifications in a Node.js project, it must be compiled into a a signed application with a Bundle ID, it is recommended to use the gDialog app for [notifications](https://github.com/giladdarshan/gdialog#notification)\
**NOTE:** Unless node is pre-approved for notifications via the [MDM notifications payload](https://support.apple.com/guide/mdm/notifications-payload-settings-mdm46b6547ba/web), the user will get a notification asking to approve node to present notifications:\
<img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-request.png?raw=true">
<br />
The following global options are not available in this template:\
icon_file, system_icon,  buttons, width, height, window_size, allow_quit, no_return, focus and scrollable_text.

| macOS Big Sur | macOS Catalina |
| --- | --- |
| <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-bigsur.png?raw=true"> | <img width="350" src="https://github.com/giladdarshan/gdialog/blob/main/assets/gdialog-notification-catalina.png?raw=true"> |
 
Command Example:
```
const gDialog = require('gdialog');
let options = {
    type: 'notification',
    title: 'Title',
    header: 'Header',
    text: 'Notification Text',
    buttons: [ 'OK', 'Cancel' ],
    focus: true
};
const dialog = new gDialog();
console.log(dialog.runSync(options));
```

| Key | Value (Example) | Description |
| --- | --- | --- |
| dont_wait | true | Don't wait for for the notification to be seen by the user |
