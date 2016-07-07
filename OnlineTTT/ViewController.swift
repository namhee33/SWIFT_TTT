//
//  ViewController.swift
//  OnlineTTT
//
//  Created by namhee kim on 2/8/16.
//  Copyright © 2016 namhee kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, exitProtocol {

    @IBOutlet weak var msgField: UILabel!
    
    @IBOutlet weak var playerName: UITextField!
    var roomName = ""
    
    
    
    @IBAction func room1BtnPressed(sender: UIButton) {
        let size1 = roomSize1Label.text!
        guard let text = playerName.text where !text.isEmpty else{
            msgField.text = "type in your name first!"
            return
        }
        
        if Int(size1) > 1 {
            msgField.text = "The room is already full!"
        }else{
            roomName = "Room1"
            performSegueWithIdentifier("GameInSegue", sender: self)
            // addPlayer
        }
    }
    
    
    @IBAction func room2BtnPressed(sender: UIButton) {
        let size2 = roomSize2Label.text!
        guard let text = playerName.text where !text.isEmpty else{
            msgField.text = "type in your name first!"
            return
        }
        
        if Int(size2) > 1 {
            msgField.text = "The room is already full!"
        }else{
            roomName = "Room2"
            performSegueWithIdentifier("GameInSegue", sender: self)
            // addPlayer
        }
    }
    
    @IBOutlet weak var roomSize1Label: UILabel!
    
    
    @IBOutlet weak var roomSize2Label: UILabel!
    
    
    var socket: SocketIOClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        socketHandler()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GameInSegue" {
            let controller = segue.destinationViewController as! GameViewController
            controller.exitDelegate = self
            controller.myName = playerName.text!
            controller.myRoom = self.roomName
        }
    }

    func exitGame(controller: GameViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func socketHandler(){
       
        socket = SocketIOClient(socketURL: "http://localhost:5000")
        if let _ = socket{
            print("new socket connection ######")
        }else{
            print("fail to connect to the socket!")
        }
        
        socket!.connect()
        socket!.on("connect"){ data, ack
            in print("Using Sockets in SignInView")
            

            self.socket!.on("updateRoomSize") { data, ack in
                let size1 = data[0]["room1"] as! Int
                let size2 = data[0]["room2"] as! Int
                self.roomSize1Label.text = String(size1)
                self.roomSize2Label.text = String(size2)

                print("room size from servr: ", data[0]["room1"])
                print("room size from servr: ", data[0]["room2"])
            }
            
        }
        
        
    }


}

