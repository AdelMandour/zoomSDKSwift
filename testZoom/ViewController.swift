//
//  ViewController.swift
//  testZoom
//
//  Created by Adel Mohy on 11/15/20.
//

import UIKit
import MobileRTC
import UserNotifications

class ViewController: UIViewController{
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var userPutSchedule = false
    var userStartSchedule = false
    var stratInstanse = false
    var customMeetingVC:CustomeUIViewController!
    var zoomModule:ZoomModule!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedIn), name: NSNotification.Name(rawValue: "userLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StartSchedule), name: .didRecieveNotification, object: nil)
        zoomModule = ZoomModule()
        zoomModule.setZoom(viewController: self)
        //        createUser(email: "adel_m ohy@gmail.com")
    }
    override func viewWillAppear(_ animated: Bool) {
        userPutSchedule = UserDefaults.standard.bool(forKey: "userPutSchedule")
        stratInstanse = UserDefaults.standard.bool(forKey: "stratInstanse")
        if userStartSchedule{
            StartSchedule()
        }
    }
    @objc func userLoggedIn(){
        if userPutSchedule{
                zoomModule.putASchedule(date: datePicker.date)
        }else{
            if stratInstanse{
                zoomModule.starInstantMeeting()
            }
        }
    }
    @objc func StartSchedule(){
        if let number = UserDefaults.standard.string(forKey: ""){
            zoomModule.meetingNumber = number
            zoomModule.meetingPassword = UserDefaults.standard.string(forKey: "") ?? ""
            zoomModule.joinMeeting()
        }
    }
    @IBAction func scheduleAMeeting(_ sender: Any) {
        zoomModule.putASchedule(date: datePicker.date)
    }
    @IBAction func joinAMeetingButtonPressed(_ sender: UIButton) {
    }
    @IBAction func startAnInstantMeetingButtonPressed(_ sender: UIButton) {
        zoomModule.starInstantMeeting()
    }
    
}
