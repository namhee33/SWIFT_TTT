function TGame(){
	this.player1 = "";
	this.player2 = "";
    this.roomSize = 0;
	this.gameBoard = [];
	this.currentTurn;
	this.gameOver;
	this.winner;
	this.gameStart;


	this.init = function(){
		this.gameBoard = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        this.gameOver = false;
        this.currentTurn = this.player1;
        this.gameStart = false; 
	}

	this.updateGameBoardAt = function(index, withName) {

        if(withName == this.player1) {
            this.gameBoard[index] = 1;
        } else {
            this.gameBoard[index] = 2;
        }
        console.log("updated gameboard: ", this.gameBoard);
    }

    //same with init 
    this.resetGame = function() {
        this.gameBoard = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        this.gameOver = false;
        this.currentTurn = this.player1;
        this.winner = "";
    }

    //gamer = {player1, "name"}
    this.exitGame = function(gamer){
    	if(this.player1 == gamer){
    		this.player1 = "";
    	}else{
    		this.player2 = "";
    	}
    	this.resetGame();
    }
    this.checkGame= function() {
        this.checkRows()
        this.checkColumns()
        this.checkDiagonals()
    }
    this.checkRows = function() {
        for(var i = 0; i <= 6; i += 3) {
            if(this.gameBoard[i] != 0 && (this.gameBoard[i] == this.gameBoard[i + 1] && this.gameBoard[i + 1] == this.gameBoard[i + 2])) {
                this.declareWinner(this.gameBoard[i])
            }
        }
    }
    this.checkColumns = function() {
        for(var i = 0; i <= 2; ++i){
            if(this.gameBoard[i] != 0 && (this.gameBoard[i] == this.gameBoard[i + 3] && this.gameBoard[i + 3] == this.gameBoard[i + 6])) {
                this.declareWinner(this.gameBoard[i])
            }
        }
    }
    this.checkDiagonals = function() {
        if(this.gameBoard[4] != 0 && (this.leftDiagonal() || this.rightDiagonal())) {
            this.declareWinner(this.gameBoard[4])
        }
    }
    this.leftDiagonal = function(){
        return this.gameBoard[0] == this.gameBoard[4] && this.gameBoard[4] == this.gameBoard[8]
    }
    this.rightDiagonal = function(){
        return this.gameBoard[2] == this.gameBoard[4] && this.gameBoard[4] == this.gameBoard[6]
    }
    this.declareWinner = function(winningIndex) {
        this.gameOver = true
        if(winningIndex == 1){
            this.winner = this.player1;
        } else {
            this.winner = this.player2;
        }
    }
}

module.exports = TGame;