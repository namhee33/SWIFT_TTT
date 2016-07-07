//
//  GameViewController.swift
//  OnlineTTT
//
//  Created by namhee kim on 2/8/16.
//  Copyright © 2016 namhee kim. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {


    @IBOutlet weak var player1Label: UILabel!
    
    
    @IBOutlet weak var player2Label: UILabel!
    
    
    @IBOutlet weak var turnTextField: UILabel!
    
    
    var socket: SocketIOClient?
    var myName: String?
    var myRoom: String?
    weak var exitDelegate: exitProtocol?
    var currentTurn: String?
    var gameStarted = false  //turn true when gameStarted. turn false when the player exits
    var gameOver = true  // turn true when gameOver. turn false when playAgain button pressed or gameStarted
  
    let img1 = UIImage(named: "o.png")! as UIImage
    let img2 = UIImage(named: "x.png")! as UIImage
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var msgLabel: UILabel!
    
    
    @IBOutlet weak var turnLabel: UILabel!
    
    
    @IBAction func exitBtnPressed(sender: UIButton) {
        if gameOver {
            socket!.emit("requestExit", myName!)
        }else{
            msgLabel.text = "You can not exit during Game!"
        }
    }
    
    
    @IBAction func againBtnPressed(sender: UIButton) {
        if gameStarted && gameOver {
            socket!.emit("playAgain")
        }else if gameStarted && !gameOver {
            msgLabel.text = "The game is not over, yet!"
        }
    }
    
    
    
    @IBAction func boardBtnPressed(sender: UIButton) {
        msgLabel.text = ""
        if(!gameStarted){
            msgLabel.text = "Wait for partner!"
        }else if(gameStarted && gameOver){
            msgLabel.text = "Press the button for Play Again"
        }else if(myName != currentTurn){
            msgLabel.text = "Wait for your turn!"
        }else{
            print("you are now playing!!!!")
            socket!.emit("played", ["name": myName!, "place": sender.tag-1])
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView1.layer.borderWidth = 0.5
        imageView1.layer.borderColor = UIColor.grayColor().CGColor
        imageView1.layer.cornerRadius = 1
        imageView2.layer.borderWidth = 0.5
        imageView2.layer.borderColor = UIColor.grayColor().CGColor
        imageView2.layer.cornerRadius = 1
        
        for var i=1;i<=9;i++ {
            let tmpBtn = self.view.viewWithTag(i) as? UIButton
            tmpBtn?.layer.borderColor = UIColor.grayColor().CGColor
            tmpBtn?.layer.cornerRadius = 2
            tmpBtn?.layer.borderWidth = 0.5
            tmpBtn?.backgroundColor = UIColor.whiteColor()
        }
     
        print("myRoom", myRoom)
        print("myName", myName)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        socket = SocketIOClient(socketURL: "http://localhost:5000", options: ["forceNew": true])
        if let _ = socket {
            print("new socket connection in GameRoom")
            socketHandler()
            
            
        }else{
            print("fail to connect to the socket!")
        }

    }
    
    func socketHandler(){
        socket!.connect()
        
        socket!.on("connect") { data, ack
            in print("Using Sockets in GameViewController")
            self.socket!.emit("addPlayer", ["room":self.myRoom!, "player": self.myName!])
            
        }
        
        socket!.on("showPlayer1") { data, ack
            in print("Player1 joined the game", data[0])
            let name = data[0] as! String
            self.player1Label.text = name
            
        }
        
        socket!.on("showPlayer2") { data, ack
            in print("Player2 joined the game", data[0])
            let names = data[0] as! NSDictionary
            self.player1Label.text = names["player1"] as? String
            self.player2Label.text = names["player2"] as? String
            
        }
        
        socket!.on("gameStart"){ data, ack in
            print("game Started!!!", data[0])
            self.currentTurn = data[0] as? String
            self.turnLabel.text = "Turn: \(self.currentTurn!)"
            self.gameStarted = true
            self.gameOver = false
            
        }
        
        //other player exits the game
        socket!.on("exitPlayer") { data, ack in
            print("\(data[0]) exits the gmae. Wait for another player.")
            let exitName = data[0] as! String
            if exitName == self.myName {
                self.exitDelegate?.exitGame(self)
                self.socket!.disconnect()
            }else{
                self.socket!.emit("resetMyGame", self.myName!)
            }
        }
        socket!.on("takeTurn"){ data, ack in
            print("current turn" , data[0])
            print("myName", self.myName!)
            
            self.currentTurn = data[0] as? String
            self.turnLabel.text = "Turn: \(self.currentTurn!)"
        }

        //data --> winner
        socket!.on("gameOver"){ data, ack in
            print("gaveOver")
            print(data[0])
            let winner = data[0] as! String
            self.turnLabel.text = "Game over! \(winner) won!"
            self.gameOver = true
        }
        
        socket!.on("changeBoard") { data, ack in
            print("board color changed")
            if let info = data[0] as? NSDictionary {
                print(info["image"], info["place"])
                let img = info["image"] as! String
                let place = info["place"] as! Int
                let tmpButton = self.view.viewWithTag(place) as? UIButton
                
                let imgPic = (img == "img1" ? self.img1 : self.img2)
               
                tmpButton!.setBackgroundImage(imgPic, forState: UIControlState.Normal)

            }
        }
        
        socket!.on("resetGame"){ data, ack in
            print("game reset!!")
            self.gameStarted = true
            self.gameOver = false
            self.resetBoard()
        }
        
        socket!.on("clearBoard"){ data, ack in
            print("one exit and wait")
            if self.myName == self.player1Label.text {
                self.player2Label.text = "Wait"
            }else{
                self.player1Label.text = "Wait"
            }
            self.gameStarted = false
            self.gameOver = true
            self.resetBoard()
        }

    }  // end of socketHandler

    
    func resetBoard(){
        
        for var i=1;i<=9;i++ {
            let tmpBtn = self.view.viewWithTag(i) as! UIButton
            tmpBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
        }
    }
}
