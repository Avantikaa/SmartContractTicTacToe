pragma solidity ^0.4.18;
contract TicTacToe {

    address public player1;
    uint movesCounter;
    address public player2;
    address activePlayer;
    address[3][3] board;
    uint public boardsize = 3;
    bool gameActive;
    address thisAddress = this;
    uint withdrawToPlayer1;
    uint withdrawToPlayer2;
    uint gameCost = 1 ether;
    uint timeToReact = 3 minutes;
    uint gameValidUntil;

    event PlayerJoined(address player);
    event NextPlayer(address player);
    event GameOverWithWin(address player);
    event GameOverWithDraw();
    event PaymentSuccess(address receiver, uint AmtTransferred);


    function TicTacToe() public payable {
        require(msg.value == gameCost);
        player1 = msg.sender;
    //    activePlayer = player1;
    //    NextPlayer(activePlayer);
        gameValidUntil = now + timeToReact;
    }

    function joinGame() public payable {
        require(msg.value == gameCost);
        gameActive = true;
        assert (player2 == address(0));// && msg.sender != player1);
        player2 = msg.sender;
        PlayerJoined(player2);
        if(block.number%2 == 0){
          activePlayer = player2;
        }else{
          activePlayer= player1;
        }
        //activePlayer = player2;
        gameValidUntil = now + timeToReact;
        NextPlayer(activePlayer);
    }

    function setWinner(address winner) public {
        gameActive = false;
        GameOverWithWin(winner);
        uint balanceToPayOut = thisAddress.balance;
        if (winner.send(balanceToPayOut) == false){
            if (winner == player1){
                withdrawToPlayer1 = balanceToPayOut;
            }
            else{
                withdrawToPlayer2 = balanceToPayOut;
            }
        }
        else{
            PaymentSuccess(winner, balanceToPayOut);
        }
    }


    function withdraw() public {
        if (msg.sender == player1){
            require(withdrawToPlayer1>0);
            player1.transfer(withdrawToPlayer1);
            //withdrawToPlayer1 = 0;
            PaymentSuccess(player1, withdrawToPlayer1);
            withdrawToPlayer1 = 0;
        }
        else{
            require(withdrawToPlayer2>0);
            player2.transfer(withdrawToPlayer2);
            //withdrawToPlayer2 = 0;
            PaymentSuccess(player2, withdrawToPlayer2);
            withdrawToPlayer2 = 0;
        }
    }

    function setDraw() private {
        gameActive = false;
        GameOverWithDraw();
        uint balanceToPayOut = thisAddress.balance/2;
        if (player1.send(balanceToPayOut) == false){
            withdrawToPlayer1 = balanceToPayOut;
        }
        else{
            PaymentSuccess(player1, balanceToPayOut);
        }

        if (player2.send(balanceToPayOut) == false){
            withdrawToPlayer2 = balanceToPayOut;
        }
        else{
            PaymentSuccess(player2, balanceToPayOut);
        }
    }


    function emergencyCashOut() public {
        require(gameValidUntil < now);
        require(gameActive);
        setDraw();
    }
    function viewBoard() public view returns (address[3][3]){
        return board;
    }

    function whoIsActive() public view returns(address){
        return activePlayer;
    }
    function setStone(uint x, uint y) public {
        require(gameValidUntil > now);
        require(board[x][y] == address(0));
        assert(gameActive);
        assert(x < boardsize);
        assert(y < boardsize);
        assert (msg.sender == activePlayer);
        board[x][y] = msg.sender;
        gameValidUntil = now + timeToReact;
        movesCounter++;
        for (uint i =0; i < boardsize; i++){
            if (board[x][i] != activePlayer){
                break;
            }
            if (i == boardsize-1){
                setWinner(activePlayer);
                return;
            }
        }
        for (i=0; i < boardsize; i++){
            if (board[i][y] != activePlayer){
                break;
            }
            if (i == boardsize-1){
                setWinner(activePlayer);
                return;
            }
        }
        //diagonal

        if (x == y){
            for(i=0;i<boardsize;i++){
                if (board[i][i] != activePlayer){
                    break;
                }
                if (i == boardsize-1){
                    setWinner(activePlayer);
                    return;
                }
            }
        }
        //anti-diagonal
        if(x+y == boardsize-1){
            for(i=0;i<boardsize-1;i++){
                if(board[i][(boardsize-1) - i] != activePlayer){
                    break;
                }
                if ( i == boardsize-1){
                    setWinner(activePlayer);
                    return;
                }
            }
        }

        if (movesCounter == boardsize**2){
            setDraw();
            return;
        }

        if (activePlayer == player1){
            activePlayer = player2;
        }else{
            activePlayer = player1;
        }

        NextPlayer(activePlayer);
    }
}
