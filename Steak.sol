pragma solidity ^0.4.19;

contract ERC20 {

    string public constant name = "Steak";
    string public constant symbol = "STEAK";
    uint8 public constant decimals = 18;

    uint public claimBlock;


    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event StakeOn(address staker);
    event Claimed(address staker);
    event Burned(address staker);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    address[] private addresses;
    
    uint256 public _totalSupply;

    using SafeMath for uint256;

    constructor(uint256 startSupply) public {  
	    _totalSupply = startSupply;
	    balances[msg.sender] = _totalSupply;
        claimBlock = block.number;
        addresses.push(msg.sender)-1;
    }  

    function totalSupply() public view returns (uint256) {
	    return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);
    
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function stake() public {
        for (uint i = 0; i < addresses.length; i++) {
            address x = addresses[i];
            if (x == msg.sender) {
                revert();
            }
        }
        
        addresses.push(msg.sender)-1;
        emit StakeOn(msg.sender);
    }
    
    function isStaking(address account) public view returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            address x = addresses[i];
            if (x == account) {
                return true;
            }
        }
        
        return false;
    }
    
    function claim() public {
        uint token = (block.number - claimBlock) * 1000000000000000000;
        for (uint i = 0; i < addresses.length; i++) {
            address x = addresses[i];
            balances[x] = balances[x] + (token * balances[x] / _totalSupply);
            emit Claimed(x);
        }

        renewTotalSupply();
        claimBlock = block.number;
    }
    
    function burn(uint token) public {
        if (balances[msg.sender] >= token) {
            balances[msg.sender] = balances[msg.sender] - token;
            renewTotalSupply();
            emit Burned(msg.sender);
        }
        else {
            revert();
        }
    }
    
    function renewTotalSupply() private {
        uint supply = 0;
        for (uint j = 0; j < addresses.length; j++) {
            address y = addresses[j];
            supply = supply + balances[y];
        }
        
        _totalSupply = supply;
    }
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}