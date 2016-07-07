var express = require('express');
var path = require('path');
var app = express();

var gameStart = false;
var TGame = require("./TTTGame.js");

app.use(express.static(path.join(__dirname, './client')));

var game1 = new TGame();
var game2 = new TGame();

game1.init();
game2.init();

var game = game1;

var server = app.listen(5000, function(){
	console.log("Start listening: 5000");
});


var io = require('socket.io').listen(server);
io.sockets.on('connection', function(socket){
	console.log('SERVER: we are using Socekts!', socket.id);

	//give roomsize to who just connect
	socket.emit("updateRoomSize", {room1: game1.roomSize, room2: game2.roomSize});

	socket.on("addPlayer", function(data){
		console.log("addPlayer is called!", data);
		if(data.room == "Room1"){
			game = game1;
		}else{
			game = game2;
		}
		game.roomSize++;
		socket.room = data.room;
		socket.join(data.room);

		if(game.player1 == ""){
			game.player1 = data.player;
			if(game.roomSize == 1){
				io.sockets.in(socket.room).emit("showPlayer1", game.player1);
			}else{
				io.sockets.in(socket.room).emit("showPlayer2", {player1: game.player1, player2: game.player2});
			}
		}else{
			game.player2 = data.player;
			io.sockets.in(socket.room).emit("showPlayer2", {player1: game.player1, player2: game.player2});
		}
        
        if(game.roomSize == 2) {
        	game.currentTurn= game.player1;
            io.sockets.in(socket.room).emit("gameStart", game.currentTurn);
        }

		io.sockets.emit("updateRoomSize", {room1: game1.roomSize, room2: game2.roomSize});
	});


	socket.on("played", function(data){
		console.log("playing: ", socket.room, data.name, data.place);
		game = (socket.room == 'Room1')? game1: game2;
		game.updateGameBoardAt(data.place, data.name);
		img = (data.name == game.player1)? "img1" : "img2";
		io.sockets.in(socket.room).emit("changeBoard", {image:img, place: data.place+1});
		game.checkGame();
		if(game.gameOver){
			io.sockets.in(socket.room).emit("gameOver", game.winner);
		}else{
			if(game.currentTurn == game.player1){
				game.currentTurn = game.player2;
			}else{
				game.currentTurn = game.player1;
			}
			io.sockets.in(socket.room).emit("takeTurn", game.currentTurn);
		}
	});


	socket.on("requestExit", function(data){
		console.log("exit request from ", data, socket.room);
		if(socket.room == "Room1"){
			game = game1;
		}else{
			game = game2;
		}
		if(data == game.player1){
			console.log("player1 exit");
			game.player1 = "";
		}else{
			console.log("player2 exit");
			game.player2 = "";
		}
		game.roomSize--;
		io.sockets.emit("updateRoomSize", {room1: game1.roomSize, room2: game2.roomSize});
		io.sockets.in(socket.room).emit("exitPlayer", data);
		socket.leave(socket.room);
	});

	socket.on('playAgain', function(){
		game = (socket.room == "Room1")? game1:game2
        game.resetGame();
        io.sockets.in(socket.room).emit('resetGame');
        io.sockets.in(socket.room).emit("takeTurn", game.player1);
    });

	socket.on("resetMyGame", function(remainPlayer){
		console.log("resetGame for remainPlayer", remainPlayer);
		if(socket.room == "Room1"){
			game = game1;
		}else{
			game = game2;
		}
		game.resetGame();
		socket.emit("clearBoard");
	});
})

