pragma solidity >= 0.7.0 < 0.9.0;

import "./uwese-coin.sol";



contract UweseLoyaltyContract{
    
    address private owner;
	constructor() {
		owner = msg.sender;
	}
	
	UweseToken private uweseCoin;
	
	
	// A struct complex data type holding Customer information
	struct Customer{
	    address customerAddress;
	    string firstName;
	    string lastName;
	    string emailAddress;
	    bool isRegistered;
	    // data type to check if customer is using a business
	    mapping(address => bool) business;
	    
	}
	
	
	// A struct comples data type holding Business information
	struct Business {
        address busAddress;
        string name;
        string email;
        bool isReg;
        //crypto token of the business
        UweseToken uwese; 
        //Check if customer is part of the loyalty program of the business
        mapping(address => bool) cust;
        //Check if business has an arrangement with other businesses
        mapping(address => bool) bus;
        //Rate of exchange between the two crypto-tokens
        mapping(address => uint256) rate;
	}
	
	//mapping an address to a customer and mapping an address to a Business
	mapping(address => Customer) public customers;
	mapping(address => Business) public businesses;
	address[] public businessAccounts;
	address[] public customerAccounts;
	

    // This function registers a business to the loyalty platform and they are able to create their tokens
	function registerBusiness(string memory _bName, string memory _email, address _bAd, string memory _symbol,  uint totalSupply) public {
		require(msg.sender == owner);
		require(!customers[_bAd].isRegistered, "Customer Registered");
		require(!businesses[_bAd].isReg, "Business Registered");
		uweseCoin = new UweseToken(totalSupply, _bAd, _bName, _symbol); //creates new crypto-token
		
		Business storage business = businesses[_bAd];
		
		business.busAddress = _bAd;
		business.name = _bName;
		business.email = _email;
		business.isReg = true;
		business.uwese = uweseCoin;
		
		businessAccounts.push(_bAd);
		uint businessAccSize = businessAccounts.length -1;
	
	}
	
	function getBusinesses() view public returns(address[] memory){
	    return businessAccounts;
	}
	
	
	function getBusiness(address busAdd) public view returns(string memory _bName, string memory _email, address _bAd, string memory _symbol,  uint totalSupply){
	    
	}
	
    
    // This function registers a customer to the loyalty program
	function regCustomer(string memory _firstName, string memory _lastName, string memory _email, address _cAd) public {
		require(msg.sender == owner);
		require(!customers[_cAd].isRegistered, "Customer Registered");
		require(!businesses[_cAd].isReg, "Business Registered");

		customers[msg.sender].customerAddress = _cAd;
		customers[msg.sender].firstName = _firstName;
		customers[msg.sender].lastName = _lastName;
		customers[msg.sender].emailAddress = _email;
		customers[msg.sender].isRegistered = true;
	}
	
	
     
     // This function enables a customer to join a business of choice to be able to earn loyalty points

	function joinBusiness(address _bAd) public{
		require(customers[msg.sender].isRegistered, "This is not a valid customer account");//customer only can call this function
		require(businesses[_bAd].isReg, "This is not a valid business account");
		businesses[_bAd].cust[msg.sender] = true;//putting customer in business's list and business in the customer's list.
		customers[msg.sender].business[_bAd] = true;
	}
	
     
     // This function enables two businesses to go into an agreement and be able to exchange tokens. Both businesses must call this function and agree on an exchange rate for interbusiness transaction

	function connectBusiness(address _bAd, uint256 _rate) public{
		require(businesses[_bAd].isReg, "This is not a valid business account");
		require(businesses[msg.sender].isReg, "This is not a valid business account");
		businesses[msg.sender].bus[_bAd] = true;
		businesses[msg.sender].rate[_bAd] = _rate;
	}
	

    // This function enables a customer to send earned points to businesses

	function spend(address from_bus, address to_bus, uint256 _points) public {
		require(customers[msg.sender].isRegistered, "This is not a valid customer account");
		require(businesses[from_bus].isReg, "This is not a valid business account");
		require(businesses[to_bus].isReg, "This is not a valid business account");
		if(from_bus==to_bus){
			//transaction is with the same business
			businesses[to_bus].uwese.transferFrom(msg.sender, to_bus, _points);
		}
		else{
			//requires both businesses to have agreed to the terms
			require(businesses[from_bus].bus[to_bus], "This is not a valid linked business account");
			require(businesses[to_bus].bus[from_bus], "This is not a valid linked business account");
			uint256 _r = businesses[from_bus].rate[to_bus];
			//burn from first account(customer) and mint into the reciever's businesses 
			
			businesses[from_bus].UweseToken.burnFrom(msg.sender, _points);
			businesses[to_bus].uweseCoin.mint(to_bus, _r*_points);

		}

	}
	

    // This function is used by businesses to send points to customer account
	function reward(address _cAd, uint256 _points) public{
		require(businesses[msg.sender].isReg, "This is not a valid business account");
		require(customers[_cAd].isRegistered, "This is not a valid customer account");
		require(businesses[msg.sender].cus[_cAd], "This customer has not joined your business" );
		require(customers[_cAd].bus[msg.sender], "This customer has not joined your business" );
		businesses[msg.sender].uweseCoin.transferFrom(msg.sender, _cAd, _points);
	}
}