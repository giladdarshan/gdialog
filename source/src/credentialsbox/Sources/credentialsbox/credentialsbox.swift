// swift build --package-path ./src/msgbox -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
import SwiftUI

// Variables - Defaults
var gdialog_type = "credentialsbox";
public typealias `func` = @convention(c) (UnsafePointer<CChar>) -> Void
var callbackHolder: `func`?
var options: [String: Any] = [
    "async": false,
    "user_label": "Username:",
    "user_initial_text": "",
    "user_background_text": "Enter your username",
    "pass_label": "Password:",
    "pass_initial_text": "",
    "pass_background_text": "Enter your password",
    "extra_field_label": "",
    "extra_field_initial_text": "",
    "extra_field_background_text": "",
    "extra_field_secured": false,
    "encode_text": false,
    "header": "",
    "allow_quit": false,
    "width": 0,
    "height": 0,
    "window_size": CGSize(width: 500, height: 180),
    "icon_file": "", // NSImage
    "system_icon": "",
    "icon_type": "none",
    "title": "",
    "text": "",
    "buttons": [ "OK" ],
    "scrollable_text": false,
    "focus": false,
    "timeout": 0,
    "timeout_text": "Time Remaining",
    "static": false
];

///////////////////////////////
// TEMPLATE BEGIN - EDIT HERE//
///////////////////////////////

// Credentials Box UI
struct ContentView: View {
    @State private var textField_user: String = options["user_initial_text"] as! String;
    @State private var textField_pass: String = options["pass_initial_text"] as! String;
    @State private var textField_extra: String = options["extra_field_initial_text"] as! String;
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            BodyView(textField_user: $textField_user, textField_pass: $textField_pass, textField_extra: $textField_extra)
            FooterView(textField_user: $textField_user, textField_pass: $textField_pass, textField_extra: $textField_extra)
        }
        .padding(5)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack() {
            Text(options["header"] as! String).font(.title)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 3)
    }
}

struct BodyView: View {
    @Binding var textField_user: String;
    @Binding var textField_pass: String;
    @Binding var textField_extra: String;
    
    var body: some View {
        HStack(alignment: .top) {
            if (options["icon_type"] as! String != "none") {
                IconView()
            }
            MainView(textField_user: $textField_user, textField_pass: $textField_pass, textField_extra: $textField_extra)
        }
        .frame(maxHeight: .infinity)
    }
}

struct IconView: View {
    var body: some View {
        VStack() {
            if options["icon_type"] as! String == "file" {
                Image(nsImage: options["icon_file"] as! NSImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 75)
            }
            else {
                Image(nsImage: NSImage(named: (options["system_icon"] as! String).starts(with: "NSImageName") ? (options["system_icon"] as! String).replacingOccurrences(of: "NSImageName", with: "NS") : options["system_icon"] as! String)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75)
                
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct MainView: View {
    @Binding var textField_user: String;
    @Binding var textField_pass: String;
    @Binding var textField_extra: String;

    @State var maximumSubViewWidth: CGFloat = 0
    
    var body: some View {
        VStack {
            if (options["scrollable_text"] as! Bool) {
                ScrollView {
                    TextView()
                }
            }
            else {
                TextView()
            }
            UserTextFieldView(textField_user: $textField_user, maximumSubViewWidth: $maximumSubViewWidth)
            PassTextFieldView(textField_pass: $textField_pass, maximumSubViewWidth: $maximumSubViewWidth)
            if (options["extra_field_label"] as! String != "") {
                ExtraTextFieldView(textField_extra: $textField_extra, maximumSubViewWidth: $maximumSubViewWidth)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.leading, 5)
    }
}


struct TextView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text(options["text"] as! String)
            .font(.body)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }
}

struct UserTextFieldView: View {
    @Binding var textField_user: String;
    @Binding var maximumSubViewWidth: CGFloat;

    var body: some View {
        HStack() {
            Text(options["user_label"] as! String)
            .frame(minWidth: maximumSubViewWidth, alignment: .leading)
            .overlay(DetermineWidth())
            TextField(options["user_background_text"] as! String, text: $textField_user) 
            .disableAutocorrection(true)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .onPreferenceChange(DetermineWidth.Key.self)
        {
            maximumSubViewWidth = $0
        }
    }
}
struct PassTextFieldView: View {
    @Binding var textField_pass: String;
    @Binding var maximumSubViewWidth: CGFloat;

    var body: some View {
        HStack() {
            Text(options["pass_label"] as! String)
            .frame(minWidth: maximumSubViewWidth, alignment: .leading)
            .overlay(DetermineWidth())
            SecureField(options["pass_background_text"] as! String, text: $textField_pass) 
            .disableAutocorrection(true)
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .onPreferenceChange(DetermineWidth.Key.self)
        {
            maximumSubViewWidth = $0
        }
    }
}
struct ExtraTextFieldView: View {
    @Binding var textField_extra: String;
    @Binding var maximumSubViewWidth: CGFloat;

    var body: some View {
        HStack() {
            Text(options["extra_field_label"] as! String)
            .frame(minWidth: maximumSubViewWidth, alignment: .leading)
            .overlay(DetermineWidth())
            if (options["extra_field_secured"] as! Bool) {
                SecureField(options["extra_field_background_text"] as! String, text: $textField_extra) 
                .disableAutocorrection(true)
            }
            else {
                TextField(options["extra_field_background_text"] as! String, text: $textField_extra) 
                .disableAutocorrection(true)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .onPreferenceChange(DetermineWidth.Key.self)
        {
            maximumSubViewWidth = $0
        }
    }
}

var labels_width: CGFloat = 0;
struct DetermineWidth: View
{
    typealias Key = MaximumWidthPreferenceKey
    var body: some View
    {
        GeometryReader
        {
            proxy in
            Color.clear
                .anchorPreference(key: Key.self, value: .bounds)
                {
                    anchor in proxy[anchor].size.width
                }
        }
    }
}

struct MaximumWidthPreferenceKey: PreferenceKey
{
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat)
    {
        value = max(value, labels_width)
        labels_width = value
        // print(value, labels_width)
    }
}

struct FooterView: View {
    @Binding var textField_user: String;
    @Binding var textField_pass: String;
    @Binding var textField_extra: String;
    
    var body: some View {
        HStack() {
            if (options["timeout"] as! Int > 0) {
                TimerView()
            }
            ButtonsView(textField_user: $textField_user, textField_pass: $textField_pass, textField_extra: $textField_extra)
        }
    }
}

struct TimerView: View {
    @State private var timeRemaining = options["timeout"] as! Int;
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    var body: some View {
        HStack() {
            Text("\(options["timeout_text"] as! String): \(buildRemainingTime(timeRemaining))")
        }
        .padding(.leading, 5)
        .onReceive(timer) { time in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            else {
                timer.upstream.connect().cancel()
                dialogResult = "";
                dialogInteraction("timeout");
                let dummyEvent = NSEvent.otherEvent(with: NSEvent.EventType.applicationDefined, location: NSZeroPoint, modifierFlags: NSEvent.ModifierFlags(rawValue: 0), timestamp: 0, windowNumber: 0, context: nil, subtype:0, data1:0, data2:0)!;
                NSApp.postEvent(dummyEvent, atStart: true);
            }
        }
    }
}

func buildRemainingTime(_ time: Int) -> String {
    var remainingTime: Int = time;
    var days = 0;
    var hours = 0;
    var minutes = 0;
    var seconds = 0;

    if (remainingTime > 59) {
        seconds = remainingTime % 60;
        remainingTime = remainingTime / 60;
        if (remainingTime > 59) {
            minutes = remainingTime % 60;
            remainingTime = remainingTime / 60;
            if (remainingTime > 23) {
                hours = remainingTime % 24;
                days = remainingTime / 24;
            }
            else {
                hours = remainingTime;
            }
        }
        else {
            minutes = remainingTime;
        }
    }
    else {
        seconds = remainingTime;
    }
    var result = days > 0 ? String(days) + " " : "";
    result += (hours < 10 ? "0" : "") + String(hours);
    result += ":" + (minutes < 10 ? "0" : "") + String(minutes);
    result += ":" + (seconds < 10 ? "0" : "") + String(seconds);

    return result;
}

var buttonCount: Int = 0;
func increaseButtonCount() -> Int {
    buttonCount += 1;
    return buttonCount;
}
struct ButtonsView : View {
    @Binding var textField_user: String;
    @Binding var textField_pass: String;
    @Binding var textField_extra: String;

    var body: some View {
        HStack {
            ForEach(options["buttons"] as! [String], id: \.self) {
                ButtonView(
                    textField_user: $textField_user,
                    textField_pass: $textField_pass,
                    textField_extra: $textField_extra,
                    labelText: "\($0)",
                    actionReturn: String(increaseButtonCount())
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.layoutDirection, .rightToLeft)
        .padding(.top, 3)
    }
}
struct ButtonView: View {
    @Binding var textField_user: String;
    @Binding var textField_pass: String;
    @Binding var textField_extra: String;

    var labelText: String = "Button";
    var actionReturn: String = "0";
    
    var body: some View {
        HStack {
            Button(action: buttonClicked, label: {
                Text(labelText)
                .frame(minWidth: 50)
            })
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
        }
        
    }
    func buttonClicked() {
        var returnText = "";
        if options["encode_text"] as! Bool {
            returnText = actionReturn + "\n" + Data(textField_user.utf8).base64EncodedString() + "\n" + Data(textField_pass.utf8).base64EncodedString();
            if (options["extra_field_label"] as! String != "") {
                returnText = returnText + "\n" + Data(textField_extra.utf8).base64EncodedString();
            }
        }
        else {
            returnText = actionReturn + "\n" + textField_user + "\n" + textField_pass;
            if (options["extra_field_label"] as! String != "") {
                returnText = returnText + "\n" + textField_extra;
            }
        }
        dialogInteraction(returnText);
        // app.stop("button");
    }
}

///////////////////////
// DO NOT EDIT BELOW //
///////////////////////

func dialogInteraction(_ returnString: String) {
    if ((options["async"] as! Bool) && (returnString != "timeout")) {
        callbackHolder!((returnString as NSString).utf8String!);
    }
    else {
        dialogResult = returnString;
        app.stop("");
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
var dialogResult = "-1";

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(0)
    }
}

class CustomWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let window = CustomWindow()
    let windowDelegate = WindowDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let mainMenu = NSMenu(title: options["title"] as! String)
        if (options["allow_quit"] as! Bool) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(app.stop(_:)), keyEquivalent: "q"))
            mainMenu.addItem(appMenu)
        }
        let editMenu = NSMenuItem()
        editMenu.submenu = NSMenu(title: "Edit")
        editMenu.submenu?.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "y"))
        editMenu.submenu?.addItem(NSMenuItem.separator())
        editMenu.submenu?.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Select All", action: #selector(NSStandardKeyBindingResponding.selectAll(_:)), keyEquivalent: "a"))
        mainMenu.addItem(editMenu)
        NSApplication.shared.mainMenu = mainMenu
        window.setContentSize(options["window_size"] as! CGSize)
        window.delegate = windowDelegate
        if (options["title"] as? String ?? "" == "") {
            window.styleMask = []
        }
        else {
            window.styleMask = [.titled]
            window.title = options["title"] as! String
        }

        let view = NSHostingView(rootView: ContentView())
        view.frame = CGRect(origin: .zero, size: options["window_size"] as! CGSize)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        if (options["static"] as! Bool) {
            window.isMovableByWindowBackground = false
            window.isMovable = false
        }
        else {
            window.isMovableByWindowBackground = true
            window.isMovable = true
        }
        window.center()
        window.makeKeyAndOrderFront(window)
        
        NSApp.setActivationPolicy(.accessory)
        if (options["focus"] as! Bool) {
            NSApp.activate(ignoringOtherApps: true) // Makes the window take focus
        }
    }
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@_cdecl("swift_run_dialog")
public func run_dialog(callBack:@escaping `func`) -> UnsafePointer<CChar> {
    callbackHolder = callBack;
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
    return (dialogResult as NSString).utf8String!;
}

@_cdecl("swift_set_options")
public func set_options(_options: UnsafePointer<CChar>) -> UnsafePointer<CChar> {
    var result_dict: [String: Any] = [
        "status" as String: "failed"
    ];
    
    if let options_dict = convertOptionsToDictionary(options: _options) {
        if let value = options_dict["type"] as? String {
            if gdialog_type != value {
                result_dict["error"] = "gDialog type does not match.";
                return convertDictToCReturn(dict: result_dict);
            }
        }
        

        if let option_types = options_dict["option_types"] as? [String: String] {
            options_dict.forEach { option in
                if (options[option.key] != nil) {
                    switch option_types[option.key] {
                        case "string":
                            options[option.key] = option.value as! String;
                        case "array":
                            options[option.key] = option.value as! [String];
                        case "bool-true":
                            options[option.key] = true;
                        case "bool-false":
                            options[option.key] = false;
                        case "float":
                            options[option.key] = option.value as! CGFloat;
                        case "int":
                            options[option.key] = option.value as! Int;
                        case "size":
                            if let size_value = option.value as? [String: CGFloat] {
                                options[option.key] = CGSize(width: size_value["width"]! as CGFloat, height: size_value["height"]! as CGFloat)
                            }
                        case "image":
                            options[option.key] = NSImage(contentsOfFile: option.value as! String);
                        default:
                            break;
                    }
                }
            }
            if (options["width"] as? CGFloat ?? 0 != 0) {
                options["window_size"] = CGSize(width: options["width"] as! CGFloat, height: (options["window_size"] as! CGSize).height)
            }
            if (options["height"] as? CGFloat ?? 0 != 0) {
                options["window_size"] = CGSize(width: (options["window_size"] as! CGSize).width, height: options["height"] as! CGFloat)
            }
        }    
        result_dict["status"] = "success";
    }
    
    return convertDictToCReturn(dict: result_dict);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {}
    }
    return nil
}
func convertDictToJsonString(dict: [String: Any]) -> String? {
    guard let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
        return nil
    }
    return String(data: theJSONData, encoding: .utf8)
}
func convertDictToCReturn(dict: [String: Any]) -> UnsafePointer<CChar> {
    let return_json = convertDictToJsonString(dict: dict);
    return (return_json! as NSString).utf8String!;
}
func convertOptionsToDictionary(options: UnsafePointer<CChar>) -> [String: Any]? {
    return convertToDictionary(text: String(cString: options));
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////