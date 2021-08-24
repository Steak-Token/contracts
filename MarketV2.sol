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
        
        addressSteak = 0xCc21403a1967e3C9Fd108D141A43ca36919B7B27;
        pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
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
        
        steak.approve(pancakeRouterAddress, out);
        pancake.addLiquidityETH{value: msg.value}(
            addressSteak,
            out,
            0,
            0,
            owner,
            block.timestamp + 360
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