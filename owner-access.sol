pragma solidity >= 0.7.0 < 0.9.0;

contract Owner {
    
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    
    modifier onlyOwner{
        require(owner == msg.sender);
        _;
    }
    
    modifier costs(uint price){
        require(msg.value >= price);
        _;
    }
}