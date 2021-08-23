// swift build --package-path ./src/notification -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
// import SwiftUI
import UserNotifications

// Variables - Defaults
var gdialog_type = "notification";
public typealias `func` = @convention(c) (UnsafePointer<CChar>) -> Void
var callbackHolder: `func`?
var options: [String: Any] = [
    "async": false,
    "header": "",
    "title": "",
    "text": "",
    "buttons": [ "OK" ],
    "dont_wait": false
];


///////////////////////
// DO NOT EDIT BELOW //
///////////////////////

let app = NSApplication.shared
let delegate = AppDelegate()
var dialogResult = "-1";
var gotResponse = false;

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

func runNotification(identifier: String, buttons: [String]) -> Void {
    let center = UNUserNotificationCenter.current()
    var actionsArr: [UNNotificationAction] = []
    if (buttons.count > 0) {
        for button in buttons {
            actionsArr.append(UNNotificationAction(identifier: button, title: button, options: .foreground));
        }
    }
    
    let meetingInviteCategory = 
        UNNotificationCategory.init(identifier: identifier,
        actions: actionsArr, 
        intentIdentifiers: [], 
        hiddenPreviewsBodyPlaceholder: "",
        options: .customDismissAction)
    
    center.setNotificationCategories([meetingInviteCategory])
    
    let content = UNMutableNotificationContent()
    
    if options["title"] as! String != "" {
        content.title = options["title"] as! String
    }
    if options["header"] as! String != "" {
        content.subtitle = options["header"] as! String
    }
    if options["text"] as! String != "" {
        content.body = options["text"] as! String
    }
    
    content.categoryIdentifier = identifier
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    center.add(request) { (error) in
        if error != nil {
            print("Error adding request: \(String(describing: error))")
            NSApplication.shared.terminate(0)
        }
        if (options["dont_wait"] as! Bool) {
            dialogResult = ""
            app.stop("quite")
        }
    }
}
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let window = CustomWindow()
    let windowDelegate = WindowDelegate()
    let buttons: [String] = options["buttons"] as! [String];
    var contentIdentifier = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self;
        center.requestAuthorization(options: [ .alert, .sound, .badge ]) { granted, error in
            if let error = error {
                print("Got an error while asking for permissions: \(error)")
                NSApplication.shared.terminate(0)
            }
            
            self.contentIdentifier = UUID().uuidString
            runNotification(identifier: self.contentIdentifier, buttons: self.buttons)
        }
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // print("will present");
        // print(notification);
        completionHandler([.alert])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == self.contentIdentifier {
            var sendNextEvent = false;
            switch response.actionIdentifier {
                case "com.apple.UNNotificationDefaultActionIdentifier":
                    dialogResult = "clicked"
                case "com.apple.UNNotificationDismissActionIdentifier":
                    dialogResult = "dismissed"
                    sendNextEvent = true;
                default:
                    if self.buttons.contains(response.actionIdentifier) {
                        dialogResult = response.actionIdentifier
                    }
                    else {
                        dialogResult = "Default action: \(response.actionIdentifier)"
                    }
            }
            // print("a")
            app.stop("stop")
            // print(app.nextEvent(matching: NSEvent.EventTypeMask.any, until: nil, inMode: RunLoop.Mode.eventTracking, dequeue: false))
            if (sendNextEvent) {
                let dummyEvent = NSEvent.otherEvent(with: NSEvent.EventType.applicationDefined, location: NSZeroPoint, modifierFlags: NSEvent.ModifierFlags(rawValue: 0), timestamp: 0, windowNumber: 0, context: nil, subtype:0, data1:0, data2:0)!;
                NSApp.postEvent(dummyEvent, atStart: true);
            
            }
            // print("b")
        }
        // else {
        //     print("Category missmatch: \(response.notification.request.content.categoryIdentifier)")
        // }
        completionHandler()
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@_cdecl("swift_run_dialog")
public func run_dialog() -> UnsafePointer<CChar> {
    // options["buttons"] = [ "OK" ];
    
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
    // print("done running")
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