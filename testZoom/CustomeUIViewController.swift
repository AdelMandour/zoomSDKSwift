//
//  CustomeUIViewController.swift
//  testZoom
//
//  Created by Adel Mohy on 18/11/2020.
//

import UIKit
import MobileRTC
class CustomeUIViewController: UIViewController {
    
    var meetingNumber:String!
    var time:Timer! = nil
    var counter = 180
    var label:UILabel! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = .green
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y
        self.view.addSubview(label)
        let time = Timer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: false)
    }
    @objc func updateTime(){
        counter -= 1
        self.label.text = "\(counter)"
    }
}
