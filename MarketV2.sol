pragma solidity ^0.4.19;

contract Steak {
    function approve(address delegate, uint numTokens) public returns (bool) {}
    function transfer(address, uint) public returns (bool) {}
    function balanceOf(address) public view returns (uint) {}
}

contract PancakeRouter {
    function addLiquidityETH(
          address token,
          uint amountTokenDesired,
          uint amountTokenMin,
          uint amountETHMin,
          address to,
          uint deadline
        ) external payable returns (uint amountToken, uint amountETH, uint liquidity) {}
}

contract SteakMarket {
    address addressSteak;
    address pancakeRouterAddress;

    Steak steak;
    PancakeRouter pancake;

    address owner;
    uint exchangeValue;
    
    constructor(address _owner, uint _exchangeValue) public {  
        owner = _owner;
        exchangeValue = _exchangeValue;
        
        addressSteak = 0x68653a617b6E300a73Dedf6b6f0c972069F34FE1;
        pancakeRouterAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        
        pancake = PancakeRouter(pancakeRouterAddress);
        steak = Steak(addressSteak);
    }
    
    function getExchangeValue() public view returns (uint) {
        return exchangeValue;
    }

    function setExchangeValue(uint _exchangeValue) public {
        require(msg.sender == owner);
        exchangeValue = _exchangeValue;
    }
    
    function exchange() external payable {
        uint out = msg.value * exchangeValue;
        steak.transfer(msg.sender, out);
        
        pancake.addLiquidityETH(
            addressSteak,
            out,
            0, 
            0, 
            address(this), 
            block.timestamp
        );

    }
    
    function cashoutBNB() public {
        require(msg.sender == owner);
        owner.transfer(getBalanceBNB());
    }
    
    function cashoutSTEAK() public {
        require(msg.sender == owner);
        steak.transfer(owner, getBalanceSTEAK());
    }
    
    function getBalanceBNB() public view returns (uint) {
        return address(this).balance;
    }
    
    function getBalanceSTEAK() public view returns (uint) {
        return steak.balanceOf(address(this));
    }
    
    function () public payable {}
}