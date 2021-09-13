IMPROVED VERSION OF MY TOKEN

pragma solidity >= 0.7.0 < 0.9.0;


contract UweseCoin {
    
    address public minter;
    mapping(address => uint) public balances;
    
    // // address of contributors
    // address[] funders;
    // uint public contributedAmount;
    
    event Sent(address from, address to, uint amount);
    
    constructor(){
        minter = msg.sender;
    }
    
    function mint(address receiver, uint amount) public{
        require(msg.sender == minter);
        balances[receiver] += amount;
    }
    
    error insufficientBalance(uint requested, uint available);
    
    function send(address receiver, uint amount) public{
        if(amount > balances[msg.sender])
        revert insufficientBalance({
            requested: amount,
            available: balances[msg.sender]
        });
        
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        
        emit Sent(msg.sender, receiver, amount);
    }
    
    
    function withdrawFunds(uint amount) public returns(bool success){
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        payable (msg.sender.transfer(amount));
        return true;
    } 

}