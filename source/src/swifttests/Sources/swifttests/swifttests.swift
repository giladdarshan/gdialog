// swift build --package-path ./src/msgbox -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.15" -Xlinker -rpath -Xlinker @executable_path/Frameworks

import AppKit
import SwiftUI
import UserNotifications

// Variables - Defaults
// var gdialog_type = "notificationcenter";
var gdialog_type = "swifttests";
var options: [String: Any] = [
    "header": "",
    "allow_quit": false,
    "width": 0,
    "height": 0,
    "window_size": CGSize(width: 500, height: 150),
    "icon_file": "", // NSImage
    "system_icon": "",
    "icon_type": "none",
    "title": "",
    "text": "",
    "buttons": [],
    "scrollable_text": false,
    "focus": false,
    "timeout": 0,
    "timeout_text": "Time Remaining",
    "authorize": false
];



///////////////////////////////
// TEMPLATE BEGIN - EDIT HERE//
///////////////////////////////

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
    center.getNotificationSettings(){ (settings) in

        switch settings.alertStyle{
            case .alert:                
                print("user prefers alert")                
            case .banner:                
                print("user prefers banner")                
            case .none:
                print("user disabled alerts")
        }
    }
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
    
    // Adding image attachment
    // let sourceFileUrl = URL(fileURLWithPath: "/Users/gilad.darshan/Documents/nodejs/gDialog/assets/GD-Logo.png")
    // // print("Ext: \(sourceFileUrl.pathExtension)")
    // let imageFileIdentifier = "\(UUID().uuidString).\(sourceFileUrl.pathExtension)"
    // let fileManager = FileManager.default
    // let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    // let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    // // let data = options["icon_file"] as! NSImage
    // do {
    //     try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
    //     let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
    //     do {
    //         try FileManager.default.copyItem(at: sourceFileUrl, to: fileURL!)
    //         if let attachment = try? UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL!) {
    //             // print(attachment)
    //             content.attachments = [attachment]
    //         }
    //     } catch _ { }
    // } catch let error {
    //     print("error \(error)")
    // }


    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    center.add(request) { (error) in
        if error != nil {
            print("Error adding request: \(String(describing: error))")
            NSApplication.shared.terminate(0)
        }
    }
}

// class NotificationView: NSViewController, UNNotificationContentExtension {
//     override func viewDidLoad() {
//         super.viewDidLoad()
        
//         let size = view.bounds.size
//         preferredContentSize = CGSize(width: size.width, height: size.width)
//     }
    
//     func didReceive(_ notification: UNNotification) {
//        self.title = "BLAAAA"
        
//         // if let attachment = notification.request.content.attachments.first {
//         //     if attachment.url.startAccessingSecurityScopedResource() {
//         //         if let data = NSData(contentsOfFile: attachment.url.path) as? Data {
//         //             picture.image = UIImage(data: data)
//         //             attachment.url.stopAccessingSecurityScopedResource()
//         //         }
//         //     }
//         // }
//     }
    
    
//     // func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
//     //     if response.actionIdentifier == "LIKE-1" {
//     //         //TODO: do something with the like / might be communicate to server
//     //     } else if response.actionIdentifier == "HATE-1" {
//     //         //TODO: do something with the "hate" / might be communicate to server
//     //         // Here we will suppose that we want more information from the user: why does he hate cats / dogs?
//     //         if let response = response as? UNTextInputNotificationResponse {
//     //             print(response.userText)
//     //         }
//     //         // Dismiss the notification
//     //         completion(.dismiss)
            
//     //     } else if response.actionIdentifier == "MORE-1" {
//     //         // Dismiss the notification and open the app
//     //         completion(.dismissAndForwardAction)
//     //     }
//     // }
// }
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    let window = CustomWindow()
    let windowDelegate = WindowDelegate()
    let buttons: [String] = options["buttons"] as! [String];
    var contentIdentifier = ""

    func applicationDidFinishLaunching(_ notification: Notification) {
        // print("Aloha4")
        // print(Bundle.main.bundleIdentifier as Any)
        // print(Bundle.main.bundleURL)
        let center = UNUserNotificationCenter.current()
        // if(options["authorize"] as! Bool == true) {
        center.requestAuthorization(options: [ .alert ]) { granted, error in
            if let error = error {
                print("Got an error while asking for permissions: \(error)")
                NSApplication.shared.terminate(0)
            }
            
            self.contentIdentifier = UUID().uuidString
            center.delegate = self;
            runNotification(identifier: self.contentIdentifier, buttons: self.buttons)
        }
        // }
        // else {
        //     center.getNotificationSettings { (settings) in
        //         guard settings.authorizationStatus == .authorized else { 
        //             print("gDialog is not authorized to send notifications")
        //             NSApplication.shared.terminate(0)
        //         }
        //          // ...
        //     }
        // }


        
        // window.setContentSize(options["window_size"] as! CGSize)
        // window.delegate = windowDelegate
        // if (options["title"] as? String ?? "" == "") {
        //     window.styleMask = []
        // }
        // else {
        //     window.styleMask = [.titled]
        //     window.title = options["title"] as! String
        // }

        // let view = NSHostingView(rootView: ContentView())
        // view.frame = CGRect(origin: .zero, size: options["window_size"] as! CGSize)
        // view.autoresizingMask = [.height, .width]
        // window.contentView!.addSubview(view)
        // window.isMovableByWindowBackground = true
        // window.isMovable = true
        // window.center()
        
        // window.makeKeyAndOrderFront(window)
        
        // NSApp.setActivationPolicy(.accessory)
        // if (options["focus"] as! Bool) {
        //     NSApp.activate(ignoringOtherApps: true) // Makes the window take focus
        // }




        
        
        // date.minute = 30 
        // print(type(of: center))
        
        // print("Did I??")
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
        // Get the meeting ID from the original notification.
        // if response.notification.request.content.categoryIdentifier == "FEEDBACK" // uuidString
        // let userInfo = response.notification.request.content.userInfo
        // let meetingID = userInfo["MEETING_ID"] as! String
        // let userID = userInfo["USER_ID"] as! String
                
        // Perform the task associated with the action.
        if response.notification.request.content.categoryIdentifier == self.contentIdentifier {
            print("Category Match")
            var sendNextEvent = false;
            switch response.actionIdentifier {
                // case self.buttons.contains(response.actionIdentifier):
                //     dialogResult = response.actionIdentifier
                // case "ACCEPT_ACTION":
                //     dialogResult = "ACCEPT"
                //     // print("accept")
                //     // sendNextEvent = true;
                // case "DECLINE_ACTION":
                //     dialogResult = "DECLINE"
                // Handle other actions…
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
            // print("??")
            // Always call the completion handler when done.    
            // print("!!")
            // print(dialogResult)
            print("a")
            app.stop("stop")
            // print(app.nextEvent(matching: NSEvent.EventTypeMask.any, until: nil, inMode: RunLoop.Mode.eventTracking, dequeue: false))
            if (sendNextEvent) {
                let dummyEvent = NSEvent.otherEvent(with: NSEvent.EventType.applicationDefined, location: NSZeroPoint, modifierFlags: NSEvent.ModifierFlags(rawValue: 0), timestamp: 0, windowNumber: 0, context: nil, subtype:0, data1:0, data2:0)!;
                NSApp.postEvent(dummyEvent, atStart: true);
            
            }
            print("b")
        }
        else {
            print("Category missmatch: \(response.notification.request.content.categoryIdentifier)")
        }
        completionHandler()
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@_cdecl("swift_run_dialog")
public func run_dialog() -> UnsafePointer<CChar> {
    options["buttons"] = [ "OK" ];
    options["icon_type"] = "file";
    options["icon_file"] = NSImage(contentsOfFile: "/Users/gilad.darshan/Documents/nodejs/gDialog/assets/GD-Logo.png");

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