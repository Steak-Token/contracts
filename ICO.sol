pragma solidity ^0.4.19;

contract Steak {
    function transfer(address, uint) public returns (bool) {}
    function balanceOf(address) public view returns (uint) {}
}

contract SteakMarket {
    Steak steak;

    address owner;
    uint steakPerBnb;
    
    constructor(address _owner, uint _steakPerBnb) public {  
        owner = _owner;
        steakPerBnb = _steakPerBnb;
        steak = Steak(0xcd5b20d5Ad5104C4CC2Fa3eC8c797349152F3989);
    }

    function setSteakPerBnb(uint _steakPerBnb) public {
        require(msg.sender == owner);
        steakPerBnb = _steakPerBnb;
    }

    function exchange() external payable {
        uint out = msg.value * steakPerBnb;
        steak.transfer(msg.sender, out);
    }
    
    function cashoutBNB() public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }

    function cashoutSTEAK() public {
        require(msg.sender == owner);
        steak.transfer(owner, steak.balanceOf(address(this)));
    }
    
    function getBalanceBNB() public view returns (uint) {
        return address(this).balance;
    }
    
    function getBalanceSTEAK() public view returns (uint) {
        return steak.balanceOf(address(this));
    }
    
    function () public payable {}
}