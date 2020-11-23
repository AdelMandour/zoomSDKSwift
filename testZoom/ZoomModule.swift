//
//  ZoomModule.swift
//  testZoom
//
//  Created by Adel Mohy on 22/11/2020.
//

import Foundation
import MobileRTC
class ZoomModule:NSObject,MobileRTCMeetingServiceDelegate,MobileRTCPremeetingDelegate{
    var meetService:MobileRTCMeetingService!
    var viewController:UIViewController!
    var join = false
    var time = 59
    var timer:Timer!
    var label:UILabel!
    var date:Date!
    var userEmail:String = ""
    var userPassword:String = ""
    var meetingNumber:String = ""
    var meetingPassword:String = ""
    func setZoom(viewController:UIViewController) {
        self.viewController = viewController
        if let navController = viewController.navigationController{
            MobileRTC.shared().setMobileRTCRootController(navController)
        }
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    }
   private func presentLogInAlert(){
        let alertController = UIAlertController(title: "Log in", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.keyboardType = .asciiCapable
            textField.isSecureTextEntry = true
        }
        let logInAction = UIAlertAction(title: "Log in", style: .default) { (action) in
            let email = alertController.textFields?[0].text
            let password = alertController.textFields?[1].text
            if (email != nil) && (password != nil){
                self.logIn(email: email!, password: password!)
            }
        }
        alertController.addAction(logInAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    func putASchedule(date:Date){
        let authService = MobileRTC.shared().getAuthService()
        if (authService != nil){
            let isLoggedIn = authService?.isLoggedIn()
            if isLoggedIn!{
                self.scheduleMeeting(date: date)
            }else{
                UserDefaults.standard.setValue(false, forKey: "stratInstanse")
                UserDefaults.standard.setValue(true, forKey: "userPutSchedule")
                self.logIn(email: self.userEmail, password: self.userPassword)
            }
        }
    }
   private func scheduleMeeting(date:Date!) {
        if let service:MobileRTCPremeetingService = MobileRTC.shared().getPreMeetingService(){
            service.delegate = self
            if let item = service.createMeetingItem(){
                item.setMeetingTopic("topic")
                item.setStartTime(date)
                item.setTimeZoneID(NSTimeZone.default.identifier)
                item.setDurationInMinutes(30)
                item.setAllowJoinBeforeHost(true)
                if service.scheduleMeeting(item, withScheduleFor: "meeting"){
                    service.destroy(item)
                    service.listMeeting()
                }
            }
        }
    }
    func sinkSchedultMeeting(_ result: PreMeetingError, meetingUniquedID uniquedID: UInt64) {
        print("sinkSchedultMeeting result: \(result)")
    }
    
    func sinkEditMeeting(_ result: PreMeetingError, meetingUniquedID uniquedID: UInt64) {
        print("sinkEditMeeting result: \(result)")
    }
    
    func sinkDeleteMeeting(_ result: PreMeetingError) {
        print("sinkDeleteMeeting result: \(result)")
    }
    
    func sinkListMeeting(_ result: PreMeetingError, withMeetingItems array: [Any]) {
        if let item = array.first as? MobileRTCMeetingItem{
            UserDefaults.standard.setValue(item.getMeetingNumber(), forKey: "meetingNumber")
            UserDefaults.standard.setValue(item.getMeetingPassword(), forKey: "meetingPassword")
            print("sinkSchedultMeeting result: \(result) items: \(item.getMeetingNumber())")
            let center = UNUserNotificationCenter.current()
            let component = NSCalendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    print("Yay!")
                    self.scheduleNotification(year: component.year, month: component.month, day: component.day, hour: component.hour, minute: component.minute)
                } else {
                    print("D'oh")
                }
            }
        }
    }
    func joinMeeting(){
        if !meetingNumber.isEmpty{
            joinMeeting(self.meetingNumber, self.meetingPassword)
        }else{
            self.presentJoinMeetingAlert()
        }
    }
    func starInstantMeeting(){
        let authService = MobileRTC.shared().getAuthService()
        if (authService != nil){
            let isLoggedIn = authService?.isLoggedIn()
            if isLoggedIn!{
                self.startMeeting()
            }else{
                UserDefaults.standard.setValue(false, forKey: "userPutSchedule")
                UserDefaults.standard.setValue(true, forKey: "stratInstanse")
                self.presentLogInAlert()
            }
        }
    }
  private  func joinMeeting(_ meetingNumber:String,_ meetingPassword:String){
        meetService = MobileRTC.shared().getMeetingService()
        if (meetService != nil) {
            meetService!.delegate = self
            let joinParams = MobileRTCMeetingJoinParam()
            joinParams.meetingNumber = meetingNumber
            joinParams.password = meetingPassword
            meetService?.joinMeeting(with: joinParams)
            if join{
                let authService = MobileRTC.shared().getAuthService()
                if (authService != nil){
                    authService?.logoutRTC()
                }
            }
        }
    }
  private  func  logIn(email:String, password:String){
        let authService = MobileRTC.shared().getAuthService()
        if (authService != nil){
            authService?.login(withEmail: email, password: password, rememberMe: false)
        }
    }
  private  func startMeeting(){
        meetService = MobileRTC.shared().getMeetingService()
        if (meetService != nil){
            meetService?.delegate = self
            let startParams = MobileRTCMeetingStartParam4LoginlUser()
            meetService?.startMeeting(with: startParams)
        }
    }
   private func presentJoinMeetingAlert(){
        let alertController = UIAlertController(title: "join meeting", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Meeting number"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Meeting password"
        }
        let joinMeetingAction = UIAlertAction(title: "Join meeting", style: .default) { (action) in
            let number = alertController.textFields?[0].text
            let password = alertController.textFields?[1].text
            if (number != nil) && (password != nil){
                self.joinMeeting(self.meetingNumber, self.meetingPassword)
            }
        }
        alertController.addAction(joinMeetingAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        switch error {
        case MobileRTCMeetError_PasswordError:
            print("Could not join or start meeting because the meeting password was incorrect.")
            break
        default:
            print("Could not join or start meeting with MobileRTCMeetError: \(error) \(message)")
            break
        }
    }
    func onJoinMeetingConfirmed() {
        print("Join meeting confirmed.")
    }
    @objc func updateCounter(){
        if time > 0{
            let id = MobileRTCInviteHelper().ongoingMeetingNumber
            let password = MobileRTCInviteHelper().meetingPassword
            print("id: ",id)
            print("password: ",password)
            print("Time: ",time)
            time -= 1
            if time <= 30{
                self.label.text = "\(time)"
                self.label.textColor = .white
                self.label.font = .systemFont(ofSize: 25.0)
                self.label.textAlignment = .center
//                (UIApplication.shared.delegate as! AppDelegate).labelWindow.isHidden = true
                self.label.show()
            }
        }else{
            let alert = UIAlertController(title: "end", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "end", style: .default) { (action) in
                (UIApplication.shared.delegate as! AppDelegate).alertWindow.isHidden = true
                if self.meetService.isMeetingHost(){
                    self.meetService?.leaveMeeting(with: LeaveMeetingCmd_End)
                }else{
                    self.meetService?.leaveMeeting(with: LeaveMeetingCmd_Leave)
                }
            }
            alert.addAction(action)
            timer.invalidate()
            alert.show()
        }
    }
    func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        print("Current meeting state: \(state)")
        if state.rawValue == 3{
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
    }
    func createUser(email:String){
        let headers = ["authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6IkhGcnE5d1RmVENXMUQxTXhfNF95UkEiLCJleHAiOjE2MDYyMjE3MjcsImlhdCI6MTYwNTYxNjkyOH0.MZD9AVY0vuMIFemF9xLUuyoFvq8k72plrqQ_rdJArsA",
                       "Accept":"application/json",
                       "Content-Type":"application/json"]
        let userinfo:[String:Any] = ["email":"adelmandour565@gmail.com",
                                     "type":1,
                                     "first_name":"adel",
                                     "last_name":"Mandour"]
        let json:[String : Any] = ["action":"create","user_info":userinfo]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.zoom.us/v2/users")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
        })
        
        dataTask.resume()
    }
    func scheduleNotification(year:Int?, month:Int?, day:Int?, hour:Int?, minute:Int?) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "alarm"
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        dateComponent.hour = hour
        dateComponent.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error == nil{
                DispatchQueue.main.async {
                    let authService = MobileRTC.shared().getAuthService()
                    if (authService != nil){
                        authService?.logoutRTC()
                    }
                }
            }else{
                print(error)
            }
        }
        
    }
}
public extension UIAlertController {
    func show() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.tintColor = .white
        appDelegate.alertWindow.rootViewController = vc
        appDelegate.alertWindow.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
public extension UILabel{
    func show(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = UIViewController()
        vc.view.frame = appDelegate.labelWindow.bounds
        vc.view.backgroundColor = .clear
        vc.view.tintColor = .white
        self.center = vc.view.center
        vc.view.addSubview(self)
        appDelegate.labelWindow.rootViewController = vc
        appDelegate.labelWindow.makeKeyAndVisible()
    }
}
