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

    // constructor
    function Lottery(string name, address creator) public {
        manager = creator;
        lotteryName = name;
        steak = Steak(0xEe80b739b1d2ADec66AB567D53Cf10eB1985bE81);
    }

    // Let users participate by sending eth directly to contract address
    function () public payable {
        // player name will be unknown
        participate("Unknown");
    }

    function participate(string playerName) public payable {
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
        PlayerParticipated(players[msg.sender].name, players[msg.sender].entryCount);
    }

    function activateLottery(uint maxEntries, uint steakRequired) public restricted {
        isLotteryLive = true;
        maxEntriesForPlayer = maxEntries == 0 ? 1: maxEntries;
        steakToParticipate = steakRequired == 0 ? 1: steakRequired;
    }

    function declareWinner() public restricted {
        require(lotteryBag.length > 0);

        uint index = generateRandomNumber() % lotteryBag.length;
        steak.transfer(lotteryBag[index], steak.balanceOf(address(this)));
         
        winner.name = players[lotteryBag[index]].name;
        winner.entryCount = players[lotteryBag[index]].entryCount;

        // empty the lottery bag and indexAddresses
        lotteryBag = new address[](0);
        addressIndexes = new address[](0);

        // Mark the lottery inactive
        isLotteryLive = false;
    
        // event
        WinnerDeclared(winner.name, winner.entryCount);
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
        return this.balance;
    }

    // Private functions
    function isNewPlayer(address playerAddress) private view returns(bool) {
        if (addressIndexes.length == 0) {
            return true;
        }
        return (addressIndexes[players[playerAddress].index] != playerAddress);
    }

    // NOTE: This should not be used for generating random number in real world
    function generateRandomNumber() private view returns(uint) {
        return uint(keccak256(block.difficulty, now, lotteryBag));
    }

    // Modifiers
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    // Events
    event WinnerDeclared( string name, uint entryCount );
    event PlayerParticipated( string name, uint entryCount );
}