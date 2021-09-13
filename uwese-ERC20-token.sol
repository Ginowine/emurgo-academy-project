pragma solidity >= 0.7.0 < 0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.3.0/contracts/token/ERC20/ERC20.sol";

contract UweseCoin is Minter, IERC20{
    
    String public symbol;
    String public name;
    uint8 public decimals;
    uint public totalSupply;
    
    //address public minter;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) allowed;
    
    
    event Sent(address from, address to, uint amount);
    
    constructor()public{
        symbol = "UWA";
        name = "Uwese Coin";
        decimals = 18;
        totalSupply = 100000;
        
        balances[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = totalSupply;
        emit Transfer(address(0), 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, totalSupply);
    }
    
    // Total supply of Tokens
    function totalSupply() public view returns(uint){
        return totalSupply - balances[address(0)];
    }
    
    function balanceOf(address tokenOwner) public view returns(uint balance){
        return balances[tokenOwner];
    }
    
    // Transfer the balance from token owner's account to receiver's account
    // check if the total supply has the amount of token which needs to be allocated to a user.
    function transfer(address to, uint tokens) public returns(bool success){
        require(tokens <= _balances[msg.sender]);
        require(to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
        
    } 
    
    
    // Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    function approve(address spender, uint tokens) public returns(bool success){
        require(spender != address(0));
        allowed[msg.sender] [spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
     // Transfer tokens from the from account to the to account
     // Function transferFrom will facilitate the transfer of token between users
    function transferFrom(address from, address to, tokens) public returns(bool success){
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);
        require(to != address(0));
        
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    
    // Function to check the amount of tokens that an owner allowed to a spender.
    function allowance(address owner, address spender)public view returns (uint256){
        return allowed[owner][spender];
    }
    
    
    // Internal function that mints an amount of the token and assigns it to an account.
    function mint(address receiver, uint amount) internal{
        require(account != 0);
        totalSupply = totalSupply.add(amount);
        balances[receiver] = balances[receiver].add(amount);
        
        emit Transfer(address(0), receiver, amount);
    }
    
    
    // Internal function that burns an amount of the token of a given account.
    function burn(address account, uint256 amount) internal {
        require(account != 0);
        require(amount <= balances[account]);

        totalSupply = totalSupply.sub(amount);
        balances[account] = balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
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
    
    
    fallback () public payable {
        revert();
    }
}