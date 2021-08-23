// swift build --package-path ./src/bannerbox -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
import SwiftUI


// Variables - Defaults
var gdialog_type = "bannerbox";
public typealias `func` = @convention(c) (UnsafePointer<CChar>) -> Void
var callbackHolder: `func`?
var options: [String: Any] = [
    "async": false,
    "background_color": "",
    "header": "",
    "allow_quit": false,
    "width": 0,
    "height": 0,
    "window_size": CGSize(width: 340, height: 60),
    "icon_file": "", // NSImage
    "system_icon": "",
    "icon_type": "none",
    "text": "",
    "buttons": [ ],
    "scrollable_text": false,
    "focus": false,
    "timeout": 10,
    "no_timeout": false
];

// Banner Box UI
struct ContentView: View {
    @State private var isDialogHovered: Bool = false;
    @State private var bgColor: Color = (options["background_color"] as! String == "") ? Color(NSColor.windowBackgroundColor) : Color(hex: options["background_color"] as! String);
    
    @State private var timeRemaining = options["timeout"] as! Int;
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 0) {
            BodyView()
            if ((options["buttons"] as! [String]).count > 0) {
                ButtonsView(bgColor: $bgColor, isDialogHovered: $isDialogHovered)
            }
        }
        .frame(maxHeight: .infinity)
        .foregroundColor(Color(NSColor.windowFrameTextColor))
        .background(bgColor)
        // .opacity(isDialogHovered ? 1.0 : 0.8)
        .opacity(0.9)
        .cornerRadius(8)
        .onReceive(timer) { time in
            if (options["no_timeout"] as! Bool == false) {
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
        .onTapGesture {
            if ((options["buttons"] as! [String]).count == 0) {
                dialogInteraction("0");
                // app.stop("tap");
            }
        }
        // .onHover { _ in
        //     self.isDialogHovered.toggle();
        // }
        .animation(.default)
    }
}


// https://stackoverflow.com/a/56874327
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}




struct BodyView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if (options["icon_type"] as! String != "none") {
                IconView()
            }
            MainView()
            .padding(.leading, 5)
            .padding(.top, 5)
        }
        .padding(.leading, 5)
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
                .frame(maxWidth: 50)
            }
            else {
                Image(nsImage: NSImage(named: (options["system_icon"] as! String).starts(with: "NSImageName") ? (options["system_icon"] as! String).replacingOccurrences(of: "NSImageName", with: "NS") : options["system_icon"] as! String)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct MainView: View {
    var body: some View {
        VStack(spacing: 0) {
            if (options["header"] as! String != "") {
                HeaderView()
            }
            if (options["scrollable_text"] as! Bool) {
                ScrollView {
                    TextView()
                }
            }
            else {
                TextView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack() {
            Text(options["header"] as! String).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 3)
    }
}

struct TextView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text(options["text"] as! String)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }
}

struct ButtonsView : View {
    let buttons = options["buttons"] as! [String];
    @State var maximumSubViewWidth: CGFloat = 0
    @Binding var bgColor: Color;
    @Binding var isDialogHovered: Bool;

    let borderColor: Color = Color(NSColor.separatorColor);
    var body: some View {
        VStack() {
            ButtonView(
                labelText: buttons[0],
                actionReturn: "1",
                maximumSubViewWidth: $maximumSubViewWidth,
                bgColor: $bgColor,
                isDialogHovered: $isDialogHovered
            )
            .border(width: 1, edges: [.leading], color: borderColor)
            if (buttons.count > 1) {
                ButtonView(
                    labelText: buttons[1],
                    actionReturn: "2",
                    maximumSubViewWidth: $maximumSubViewWidth,
                    bgColor: $bgColor,
                    isDialogHovered: $isDialogHovered
                )
                .border(width: 1, edges: [.leading, .top], color: borderColor)
            }
        }
        .frame(maxHeight: .infinity)
        .onPreferenceChange(DetermineWidth.Key.self) {
            maximumSubViewWidth = $0
        }
    }
}
struct ButtonView: View {
    var labelText: String = "Button";
    var actionReturn: String = "0";
    @Binding var maximumSubViewWidth: CGFloat;
    @Binding var bgColor: Color;
    @Binding var isDialogHovered: Bool;
    @State private var isHovering: Bool = false;
    @State private var isPressed: Bool = false;
    
    var body: some View {
        HStack {
            Text(labelText)
            .padding(.leading, 10)
            .padding(.trailing, 10)
            
        }
        .frame(maxHeight: .infinity)
        .frame(minWidth: maximumSubViewWidth)
        .overlay(DetermineWidth())
        .background(isPressed ? Color.accentColor : isHovering ? Color.secondary : bgColor)
        .contentShape(Rectangle()) // Makes whole view tappable
        // .opacity(isDialogHovered ? 1.0 : 0.8)
        .opacity(0.9)
        .onTapGesture {
            buttonClicked();
        }
        .onHover { _ in
            self.isHovering.toggle();
        }
        .onLongPressGesture(minimumDuration: 10, pressing: { _ in
            self.isPressed.toggle();
        }) {}
        
    }

    func buttonClicked() {
        dialogInteraction(actionReturn);
        // app.stop("button");
    }
}

var buttons_width: CGFloat = 0;
struct DetermineWidth: View {
    typealias Key = MaximumWidthPreferenceKey
    var body: some View {
        GeometryReader {
            proxy in
            Color.clear
                .anchorPreference(key: Key.self, value: .bounds) {
                    anchor in proxy[anchor].size.width
                }
        }
    }
}

struct MaximumWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
        buttons_width = value
    }
}


// Border with specific edge / side https://stackoverflow.com/a/58632759
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
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
        let screenFrame = NSScreen.main!.frame;
        if (options["allow_quit"] as! Bool) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(app.stop(_:)), keyEquivalent: "q"))
            let mainMenu = NSMenu(title: "")
            mainMenu.addItem(appMenu)
            NSApplication.shared.mainMenu = mainMenu
        }
        window.setContentSize(options["window_size"] as! CGSize)
        window.delegate = windowDelegate
        window.styleMask = []
        window.alphaValue = 0;
        window.backgroundColor = NSColor.clear;
        let view = NSHostingView(rootView: ContentView())
        view.frame = CGRect(origin: .zero, size: options["window_size"] as! CGSize)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.isMovableByWindowBackground = false
        window.isMovable = false
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(window)
        let size = options["window_size"] as! CGSize;
        window.setFrameOrigin(NSMakePoint(NSWidth(screenFrame) - size.width, NSHeight(screenFrame) - size.height))
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 1.0
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            window.animator().alphaValue = 1
        }, completionHandler: nil)

        NSApp.setActivationPolicy(.accessory)
        
        if (options["focus"] as! Bool) {
            NSApp.activate(ignoringOtherApps: true) // Makes the window take focus
        }
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