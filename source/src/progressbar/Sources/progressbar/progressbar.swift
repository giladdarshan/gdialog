// swift build --package-path ./src/progressbar -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
import SwiftUI


// Variables - Defaults
var gdialog_type = "progressbar";
public typealias `func` = @convention(c) (UnsafePointer<CChar>) -> Void
var callbackHolder: `func`?
var options: [String: Any] = [
    "async": false,
    "stoppable": false,
    "indeterminate": false,
    "allow_quit": false,
    "width": 0,
    "height": 0,
    "window_size": CGSize(width: 500, height: 100),
    "icon_file": "", // NSImage
    "system_icon": "",
    "icon_type": "none",
    "title": "",
    "text": "",
    "focus": false,
    "timeout": 0,
    "timeout_text": "Time Remaining",
    "static": false
];
var input_progress: Double = 0.0;
var input_progress_text: String = "";

// Progress Bar UI
struct ContentView: View {
    var body: some View {
        HStack(alignment: .center) {
            if (options["icon_type"] as! String != "none") {
                IconView()
            }
            MainView()
            if (options["stoppable"] as! Bool) {
                StopButtonView()
            }
        }
        .frame(maxHeight: .infinity)
        .padding(5)
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
    var body: some View {
        VStack {
            ProgressBarView()
            if (options["timeout"] as! Int > 0) {
                TimerView()
            }
        }
        .padding(.leading, 5)
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

struct StopButtonView: View {
    var body: some View {
        HStack {
            Button(action: buttonClicked, label: {
                Text("Stop")
                .frame(minWidth: 50)
            })
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
        }
        
    }
    func buttonClicked() {
        dialogInteraction("1");
        // app.stop("button");
    }
}

struct ProgressBarView: View {
    @State var progress: Double = 0.0
    @State var progress_text: String = options["text"] as? String ?? ""

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack(spacing: 0) {
            Text(progress_text)
            .frame(maxWidth: .infinity, alignment: .leading)
            ProgressIndicator(progress: $progress, minValue: 0.0, maxValue: 100.0)
        }
        .onReceive(timer) { _ in 
            if (options["indeterminate"] as! Bool) {
                if progress_text != input_progress_text {
                    progress_text = input_progress_text
                }
            }
            else {
                if progress != input_progress {
                    progress = input_progress;
                    if progress_text != input_progress_text {
                        progress_text = input_progress_text
                    }
                }
            }
        }
    }
}

struct ProgressIndicator: NSViewRepresentable {
    @Binding var progress: Double
    var minValue: Double
    var maxValue: Double
    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let result = NSProgressIndicator()
        if (options["indeterminate"] as! Bool) {
            result.isIndeterminate = true
        }
        else {
            result.isIndeterminate = false
        }
        result.minValue = minValue;
        result.maxValue = maxValue;
        result.startAnimation(nil)
        return result
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        if (progress != nsView.doubleValue) {
            nsView.doubleValue = progress;
        }
    }
}


func checkProgress() -> Void {
    input_progress_text = options["text"] as? String ?? ""
    DispatchQueue(label: "background").async {
        var str = ""
        repeat {
            str = readLine() ?? ""
            if (str != "EOF" && str != "") {
                if (options["indeterminate"] as! Bool) {
                    input_progress_text = str;
                }
                else {
                    let input_arr = str.split(separator: " ", maxSplits: 1)
                    if let new_prog = Double(input_arr[0]) {
                        if new_prog != input_progress {
                            input_progress = new_prog
                            if input_arr.count == 2 {
                                input_progress_text = String(input_arr[1])
                            }
                        }
                    }
                }
            }
        } while str != "EOF"
        NSApplication.shared.terminate(0)
    }
    
}

///////////////////////
// DO NOT EDIT BELOW //
///////////////////////

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
        if (options["allow_quit"] as! Bool) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(app.stop(_:)), keyEquivalent: "q"))
            let mainMenu = NSMenu(title: options["title"] as! String)
            mainMenu.addItem(appMenu)
            NSApplication.shared.mainMenu = mainMenu
        }
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
        checkProgress()
    }
}


func dialogInteraction(_ returnString: String) {
    if ((options["async"] as! Bool) && (returnString != "timeout")) {
        callbackHolder!((returnString as NSString).utf8String!);
    }
    else {
        dialogResult = returnString;
        app.stop("");
    }
}


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