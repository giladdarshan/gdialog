// swift build --package-path ./src/htmlbox -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
import SwiftUI
import Combine 
import WebKit

// Variables - Defaults
var gdialog_type = "htmlbox";
public typealias `func` = @convention(c) (UnsafePointer<CChar>) -> Void
var callbackHolder: `func`?
var options: [String: Any] = [
    "async": false,
    "html_b64": "",
    "file": "",
    "base_path": "",
    "url": "",
    "fullscreen": false,
    "kiosk": false,
    "allow_quit": false,
    "width": 0,
    "height": 0,
    "window_size": CGSize(width: 500, height: 150),
    "title": "",
    "focus": false,
    "static": false,
    "normal_window": false
];

let html_prefix = """
<html>
    <head>
        <style type="text/css">
        body, div, p, form, table, td, tr, th {
            padding: 0;
            margin: 0;
        }
        </style>
        <script type="text/javascript">
            function quit() {
                window.webkit.messageHandlers.quit.postMessage(null);
            }
            function print(text) {
                window.webkit.messageHandlers.print.postMessage(text);
            }
        </script>
    </head>
    <body>
""";
let html_suffix = """
    </body>
</html>
""";

///////////////////////////////
// TEMPLATE BEGIN - EDIT HERE//
///////////////////////////////

// HTML Box UI
// HTML Box UI
class ViewModel: ObservableObject {
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
}

enum WebViewNavigation {
    case backward, forward
}

class GDWebView : WKWebView {
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        if (options["kiosk"] as! Bool) {
            for menuItem in menu.items {
                menuItem.isHidden = true
            }
        }
    }
}

struct WebView: NSViewRepresentable {
    // Viewmodel object
    @ObservedObject var viewModel: ViewModel
    let scriptHandler = ScriptHandler()
    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<Self>) -> WKWebView {
        // Enable javascript in WKWebView to interact with the web app
        // let preferences = WKWebpagePreferences()
        // preferences.allowsContentJavaScript = true

        let contentController = WKUserContentController();
        contentController.add(scriptHandler, name: "print")
        contentController.add(scriptHandler, name: "quit")

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        // configuration.defaultWebpagePreferences = preferences

        let webView = GDWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<Self>) {
        if (options["url"] as! String != "") {
            webView.load(URLRequest(url: URL(string: options["url"] as! String)!))
        }
        else {
            webView.loadHTMLString(getHTMLString(), baseURL: (options["base_path"] as! String) != "" ? URL(string: options["base_path"] as! String) : nil) // baseURL is the root path
        }
    }

    class ScriptHandler: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // print(message)
            if message.name == "print" {
                if (options["async"] as! Bool) {
                    dialogInteraction(message.body as! String)
                }
                else {
                    print(message.body)
                }
            }
            if message.name == "quit" {
                dialogInteraction("0")
                // app.stop("button");
            }
        }
    }

    class Coordinator : NSObject, WKNavigationDelegate {
        var parent: WebView
        var webViewNavigationSubscriber: AnyCancellable? = nil
        
        init(_ uiWebView: WebView) {
            self.parent = uiWebView
        }
        
        deinit {
            webViewNavigationSubscriber?.cancel()
        }
        
        // This function is essential for intercepting every navigation in the webview
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // var urlString = navigationAction.request.url!.absoluteString
            // if (urlString != "about:blank") {
            if (options["url"] as! String != "") {
                decisionHandler(.allow)
                return
            }
            if navigationAction.request.url?.host != nil {
                decisionHandler(.cancel)
                NSWorkspace.shared.open(navigationAction.request.url!)
                return
            }
            decisionHandler(.allow)
        }
    }
}




struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack(spacing: 0) {
            WebView(viewModel: viewModel)
        }
    }
}

func getHTMLString() -> String {
    do {
        if (options["file"] as! String == "") {
                return html_prefix + String(data: Data(base64Encoded: options["html_b64"] as! String)!, encoding: .utf8)! + html_suffix;
        }
        else {
            let html_string = try String(contentsOfFile: options["file"] as! String)
            return html_prefix + html_string + html_suffix;
        }
    }
    catch {
        return "";
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
        let mainMenu = NSMenu(title: options["title"] as! String)
        
        if (options["normal_window"] as! Bool) {
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.title = options["title"] as! String
            NSApp.setActivationPolicy(.regular)
            options["allow_quit"] = true
            options["kiosk"] = false
        }
        else {
            if (options["title"] as? String ?? "" == "") {
                window.styleMask = []
            }
            else {
                window.styleMask = [.titled]
                window.title = options["title"] as! String
            }
            NSApp.setActivationPolicy(.accessory)
        }

        if (options["allow_quit"] as! Bool) {
            let appMenu = NSMenuItem()
            appMenu.submenu = NSMenu()
            appMenu.submenu?.addItem(NSMenuItem(title: "Quit", action: #selector(app.stop(_:)), keyEquivalent: "q"))
            // let mainMenu = NSMenu(title: options["title"] as! String)

            mainMenu.addItem(appMenu)
            // NSApplication.shared.mainMenu = mainMenu
        }

        let editMenu = NSMenuItem()
        editMenu.submenu = NSMenu(title: "Edit")
        editMenu.submenu?.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "y"))
        editMenu.submenu?.addItem(NSMenuItem.separator())
        editMenu.submenu?.addItem(NSMenuItem(title: "Cut", action: Selector("cut:"), keyEquivalent: "x"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Copy", action: Selector("copy:"), keyEquivalent: "c"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Paste", action: Selector("paste:"), keyEquivalent: "v"))
        editMenu.submenu?.addItem(NSMenuItem(title: "Select All", action: #selector(NSStandardKeyBindingResponding.selectAll(_:)), keyEquivalent: "a"))
        mainMenu.addItem(editMenu)
        NSApplication.shared.mainMenu = mainMenu
        window.delegate = windowDelegate
        

        // if (options["title"] as? String ?? "" == "") {
        //     window.styleMask = []
        //     if (options["normal_window"] as! Bool) {
        //         window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullScreen]
        //     }
        //     else {
        //         window.styleMask = []
        //     }
        // }
        // else {
        //     if (options["normal_window"] as! Bool) {
        //         window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullScreen]
        //     }
        //     else {
        //         window.styleMask = [.titled]
        //     }
        //     window.title = options["title"] as! String
        // }

        if ((options["fullscreen"] as! Bool) || (options["kiosk"] as! Bool)) {
            window.collectionBehavior = NSWindow.CollectionBehavior.fullScreenPrimary
            window.setFrame(screenFrame, display: true)
            window.toggleFullScreen(window)
            options["window_size"] = CGSize(width: screenFrame.width, height: screenFrame.height)
        }

        window.setContentSize(options["window_size"] as! CGSize)

        let view = NSHostingView(rootView: ContentView())
        view.frame = CGRect(origin: .zero, size: options["window_size"] as! CGSize)
        view.autoresizingMask = [.height, .width]
        window.contentView!.addSubview(view)
        window.isMovableByWindowBackground = true
        window.isMovable = true
        window.center()
        window.makeKeyAndOrderFront(window)

        
        // NSApp.setActivationPolicy(.accessory)
        if (options["focus"] as! Bool) {
            NSApp.activate(ignoringOtherApps: true) // Makes the window take focus
        }

        if (options["kiosk"] as! Bool) {
            let presOptions: NSApplication.PresentationOptions = [
                .disableForceQuit          ,   // Cmd+Opt+Esc panel is disabled
                .disableMenuBarTransparency,   // Menu Bar's transparent appearance is disabled
    //            .disableQuit               ,
                .fullScreen                ,   // Application is in fullscreen mode
                .hideDock                  ,   // Dock is entirely unavailable. Spotlight menu is disabled.
                .hideMenuBar               ,   // Menu Bar is Disabled
                .disableAppleMenu          ,   // All Apple menu items are disabled.
                .disableProcessSwitching   ,   // Cmd+Tab UI is disabled. All Exposé functionality is also disabled.
                .disableSessionTermination ,   // PowerKey panel and Restart/Shut Down/Log Out are disabled.
                .disableHideApplication    ,   // Application "Hide" menu item is disabled.
                .autoHideToolbar
                
            ]
            let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeAllScreens : NSNumber(value: presOptions.rawValue)]
            // let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions : NSNumber(value: presOptions.rawValue)]
            view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
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