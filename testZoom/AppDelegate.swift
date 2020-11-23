//
//  AppDelegate.swift
//  testZoom
//
//  Created by Adel Mohy on 11/15/20.
//

import UIKit
import MobileRTC
import MobileCoreServices
import UserNotifications
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MobileRTCAuthDelegate {

    var window: UIWindow?
    var schedule = false
    let alertWindow: UIWindow = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.windowLevel = UIWindow.Level.alert + 1
        return win
    }()
    let labelWindow: UIWindow = {
        let win = UIWindow(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: UIScreen.main.bounds.width, height: 60))
        win.windowLevel = UIWindow.Level.alert + 1
        return win
    }()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        application.registerForRemoteNotifications()
        let mainSDK = MobileRTCSDKInitContext()
        mainSDK.domain = "zoom.us"
        mainSDK.enableLog = true
        let sdkInitSuc = MobileRTC.shared().initialize(mainSDK)
        if sdkInitSuc{
            let authService = MobileRTC.shared().getAuthService()
            if (authService != nil){
                authService!.clientKey       = "goGBWmfXpXfmHFyyjonpRnAwlaIWiHAMZylC"
                authService!.clientSecret    = "lS5RYyGXLL6w9q4lN3YtoP8zMzU4k94FiCGY"
                authService!.delegate        = self
                authService!.sdkAuth()
            }
        }
        if(launchOptions?[.remoteNotification] != nil){
              // your code here
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if  let mainVC = storyboard.instantiateViewController(withIdentifier: "mainView") as? ViewController {
                mainVC.userStartSchedule = true
                let navigationController = UINavigationController(rootViewController: mainVC)
                self.window?.rootViewController = navigationController
            }
          }
        return true
    }
    func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
        print(returnValue)
        if (returnValue != MobileRTCAuthError_Success)
        {
            switch (returnValue) {
                    case MobileRTCAuthError_Success:
                        print("SDK successfully initialized.")
                        break;
                    case MobileRTCAuthError_KeyOrSecretEmpty:
                        print("SDK key/secret was not provided. Replace sdkKey and sdkSecret at the top of this file with your SDK key/secret.")
                        break;
                    case MobileRTCAuthError_KeyOrSecretWrong:
                        print("SDK key/secret is not valid.")
                        break;
                    case MobileRTCAuthError_Unknown:
                        print("SDK key/secret is not valid.");
                        break;
                    default:
                        print("SDK Authorization failed with MobileRTCAuthError: \(returnValue)")
                        break
         }
      }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        let authService = MobileRTC.shared().getAuthService()
        if (authService != nil){
            authService?.logoutRTC()
        }
    }
    func onMobileRTCLoginReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged in")
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "userLoggedIn"), object: self, userInfo: nil))
            break
        case 1002:
            print("Password incorrect")
            break
        default:
            print("Could not log in. Error code: \(returnValue)")
            break
        }
    }
    func onMobileRTCLogoutReturn(_ returnValue: Int) {
        switch returnValue {
        case 0:
            print("Successfully logged out")
            break
        case 1002:
            print("Password incorrect")
            break
        default:
            print("Could not log out. Error code: \(returnValue)")
            break
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
  // This function will be called when the app receive notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
    // show the notification alert (banner), and with sound
    completionHandler([.banner, .sound])
  }
    
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      
    // tell the app that we have finished processing the user’s action / response
    let application = UIApplication.shared
      
      if(application.applicationState == .active){
        print("user tapped the notification bar when the app is in foreground")
        NotificationCenter.default.post(name: .didRecieveNotification, object: nil)
      }
      
      if(application.applicationState == .inactive)
      {
        print("user tapped the notification bar when the app is in background")
        NotificationCenter.default.post(name: .didRecieveNotification, object: nil)
      }
    completionHandler()
  }
}
extension Notification.Name {
    static let didRecieveNotification = Notification.Name("didRecieveNotification")
}
