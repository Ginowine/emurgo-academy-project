pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract Minter {
    
    address minter;
    uint public creationTime = block.timestamp;
    error Unauthorized();
    error TooEarly();
    error NotEnoughEther();
    
    constructor() public {
        minter = msg.sender;
    }
    
    
    modifier costs(uint price){
        if(msg.value < price){
            revert NotEnoughEther();
            
            _;
            
            if(msg.value > price){
                payable(msg.sender).transfer(msg.value - price);
            }
        }
    }
    
    
    modifier onlyBy(address _account) {
        //require(msg.sender == _account, 'Sender not authorized');
        //_;
        if (msg.sender != _account)
            revert Unauthorized();
        _;
        
    }
    
    modifier onlyAfter(uint _time){
        if(block.timestamp < _time){
            revert TooEarly();
            
            _;
        }
    }
}

contract UweseCoin is Minter, ERC20Interface, SafeMath{
    
    String public symbol;
    String public name;
    uint8 public decimals;
    uint public _totalSupply;
    
    //address public minter;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;

    
    // // address of contributors
    // address[] funders;
    // uint public contributedAmount;
    
    event Sent(address from, address to, uint amount);
    
    constructor()public{
        symbol = "UWA";
        name = "Uwese Coin";
        decimals = 18;
        _totalSupply = 100000;
        
        balances[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = _totalSupply;
        emit Transfer(address(0), 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, _totalSupply);
    }
    
    // Total supply of Tokens
    function totalSupply() public view returns(uint){
        return totalSupply - balances[address(0)];
    }
    
    function balanceOf(address tokenOwner) public view returns(uint balance){
        return balances[tokenOwner];
    }
    
    // Transfer the balance from token owner's account to receiver's account
    function transfer(address to, uint tokens) public returns(bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], tokens );
        balances[to] = safeAdd(balances[to], tokens);
        
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    } 
    
    
    function approve(address spender, uint tokens) public returns(bool success){
        allowed[msg.sender] [spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
     // Transfer tokens from the from account to the to account
    function transferFrom(address from, address to, tokens) public returns(bool success){
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    
    function allowance(address tokenOwner, address tokenSpender) public returns(bool success){
        return allowed[tokenOwner] [tokenSpender];
        
    }
    
    
    function mint(address receiver, uint amount) public onlyBy(minter){
        //require(msg.sender == minter);
        balance[receiver] += amount;
    }
    
    error insufficientBalance(uint requested, uint available);
    
    function send(address receiver, uint amount) public onlyBy(minter){
        if(amount > balance[msg.sender])
        revert insufficientBalance({
            requested: amount,
            available: balance[msg.sender]
        });
        
        balance[msg.sender] -= amount;
        balance[receiver] += amount;
        
        emit Sent(msg.sender, receiver, amount);
    }
    
    
    function withdrawFunds(uint amount) public onlyBy(minter) returns(bool success){
        require(balance[msg.sender] >= amount);
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        return true;
    } 
    
    function deleteCurrentMinter() public onlyBy(minter) onlyAfter(creationTime + 6 weeks){ 
        delete minter;

    }
    

    function forceMinterChange(address newMinter) public payable costs(200 ether){
        minter = newMinter;
        
            // returns excess money to sender 
        if(uint160 (minter) & 0 == 1){
            return;
        }
    }
}