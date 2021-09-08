pragma solidity ^0.4.20;

contract Steak {
    function transfer(address, uint) public returns (bool) {}
    function transferFrom(address sender, address receiver, uint numTokens) public returns (bool) {}
    function balanceOf(address) public view returns (uint) {}
}

contract Lottery {
    Steak steak;
    
    // name of the lottery
    string public lotteryName;
    // Creator of the lottery contract
    address public manager;

    // variables for players
    struct Player {
        string name;
        uint entryCount;
        uint index;
    }
    address[] public addressIndexes;
    mapping(address => Player) players;
    address[] public lotteryBag;

    // Variables for lottery information
    Player public winner;
    bool public isLotteryLive;
    uint public maxEntriesForPlayer;
    uint public steakToParticipate;
    uint public newPotBalance;
    
    uint public round;
    uint public startBlock;
    uint public roundLength;
    // Last lottery round
    string public lastWinner;
    uint public lastPrice;

    // constructor
    function Lottery(string name, address creator) public {
        manager = creator;
        lotteryName = name;
        steak = Steak(0xE41E245Aad4C3FeC76F04e95cBe4038E00F53AC8);
        round = 0;
        newPotBalance = 1000000000000000000000;
        maxEntriesForPlayer = 6000000000;
        steakToParticipate = 1000000000000000000000;
        roundLength = 10000;
        restart();
    }

    function participate(string playerName) public {
        require(bytes(playerName).length > 0);
        require(isLotteryLive);
        require(steak.balanceOf(msg.sender) >= steakToParticipate);
        require(players[msg.sender].entryCount < maxEntriesForPlayer);
        
        steak.transferFrom(msg.sender, address(this), steakToParticipate);

        if (isNewPlayer(msg.sender)) {
            players[msg.sender].entryCount = 1;
            players[msg.sender].name = playerName;
            players[msg.sender].index = addressIndexes.push(msg.sender) - 1;
        } else {
            players[msg.sender].entryCount += 1;
        }

        lotteryBag.push(msg.sender);
    
        // event
        emit PlayerParticipated(players[msg.sender].name, players[msg.sender].entryCount);
    }

    function declareWinner() public {
        require(lotteryBag.length > 0);
        require(isRoundOver());

        uint index = generateRandomNumber() % lotteryBag.length;
        uint price = steak.balanceOf(address(this)) - newPotBalance;
        steak.transfer(lotteryBag[index], price);
         
        winner.name = players[lotteryBag[index]].name;
        winner.entryCount = players[lotteryBag[index]].entryCount;

        // empty the lottery bag and indexAddresses
        lotteryBag = new address[](0);
        addressIndexes = new address[](0);

        // Mark the lottery inactive
        isLotteryLive = false;
    
        lastWinner = winner.name;
        lastPrice = price;
    
        // event
        emit WinnerDeclared(winner.name, winner.entryCount);
        restart();
    }

    function isRoundOver() public view returns (bool) {
        if (block.number > startBlock + roundLength) {
            return true;
        }
        
        return false;
    }

    function getPlayers() public view returns(address[]) {
        return addressIndexes;
    }

    function getPlayer(address playerAddress) public view returns (string, uint) {
        if (isNewPlayer(playerAddress)) {
            return ("", 0);
        }
        return (players[playerAddress].name, players[playerAddress].entryCount);
    }

    function getWinningPrice() public view returns (uint) {
        return steak.balanceOf(address(this)) - newPotBalance;
    }

    function setNewPotBalance(uint _newPotBalance) public {
        require(msg.sender == manager);
        newPotBalance = _newPotBalance;
    }
    
    function setMaxEntriesForPlayer(uint _maxEntriesForPlayer) public {
        require(msg.sender == manager);
        maxEntriesForPlayer = _maxEntriesForPlayer;
    }
    
    function setSteakToParticipate(uint _steakToParticipate) public {
        require(msg.sender == manager);
        steakToParticipate = _steakToParticipate;
    }
    
    function setRoundLength(uint _roundLength) public {
        require(msg.sender == manager);
        roundLength = _roundLength;
    }

    // Private functions
    function isNewPlayer(address playerAddress) private view returns(bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[players[playerAddress].index] != playerAddress);
    }

    function restart() private {
        activateLottery(maxEntriesForPlayer, steakToParticipate);
        emit NewRound(round);
    }

    function activateLottery(uint maxEntries, uint steakRequired) private {
        round += 1;
        startBlock = block.number;
        isLotteryLive = true;
        maxEntriesForPlayer = maxEntries == 0 ? 1: maxEntries;
        steakToParticipate = steakRequired == 0 ? 1: steakRequired;
    }

    // NOTE: This should not be used for generating random number in real world
    function generateRandomNumber() private view returns(uint) {
        return uint(keccak256(block.difficulty, now, lotteryBag));
    }

    // Events
    event WinnerDeclared(string name, uint entryCount);
    event PlayerParticipated(string name, uint entryCount);
    event NewRound(uint round);
}