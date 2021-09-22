pragma solidity >= 0.7.0 < 0.9.0;

import "./uwese-coin.sol";



contract UweseLoyaltyContract{
    
    address private owner;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

	constructor() public {
		owner = msg.sender;
	}
	
	
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
        MyToken uwese; 
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
	

    // This function registers a business to the loyalty platform and they are able to create their tokens
	function regBusiness(bytes32 _minter, bytes32 _burner, string memory _bName, string memory _email, address _bAd, string memory _symbol, uint8 _decimal, uint totalSupply) public {
		require(msg.sender == owner);
		require(!customers[_bAd].isReg, "Customer Registered");
		require(!businesses[_bAd].isReg, "Business Registered");
		MyToken uweseCoin = new MyToken(_minter, _burner, _bAd, _email, _bName, _symbol, _decimal, totalSupply); //creates new crypto-token
		businesses[_bAd] = Business(_bAd, _bName , _email, true, uweseCoin);//creates new business
		businesses[_bAd].uweseCoin.mint(_bAd, 10000);//gives tokens for the business

	}
	
    
    // This function registers a customer to the loyalty program
	function regCustomer(string memory _firstName, string memory _lastName, string memory _email, address _cAd) public {
		require(msg.sender == owner);
		require(!customers[_cAd].isReg, "Customer Registered");
		require(!businesses[_cAd].isReg, "Business Registered");
		customers[_cAd] = Customer(_cAd, _firstName, _lastName, _email, true);
	}
	
	
     
     // This function enables a customer to join a business of choice to be able to earn loyalty points

	function joinBusiness(address _bAd) public{
		require(customers[msg.sender].isReg, "This is not a valid customer account");//customer only can call this function
		require(businesses[_bAd].isReg, "This is not a valid business account");
		businesses[_bAd].cus[msg.sender] = true;//putting customer in business's list and business in the customer's list.
		customers[msg.sender].bus[_bAd] = true;
	}
	
     
     // This function enables two businesses to go into an agreement and be able to exchange tokens. Both businesses must call this function and agree on an exchange rate for interbusiness transaction

	function connectBusiness(address _bAd, uint256 _rate) public{
		require(businesses[_bAd].isReg, "This is not a valid business account");
		require(businesses[msg.sender].isReg, "This is not a valid business account");
		businesses[msg.sender].bs[_bAd] = true;
		businesses[msg.sender].rate[_bAd] = _rate;
	}
	

    // This function enables a customer to send earned points to businesses

	function spend(address from_bus, address to_bus, uint256 _points) public {
		require(customers[msg.sender].isReg, "This is not a valid customer account");
		require(businesses[from_bus].isReg, "This is not a valid business account");
		require(businesses[to_bus].isReg, "This is not a valid business account");
		if(from_bus==to_bus){
			//transaction is with the same business
			businesses[to_bus].uweseCoin.transferFrom(msg.sender, to_bus, _points);
		}
		else{
			//requires both businesses to have agreed to the terms
			require(businesses[from_bus].bs[to_bus], "This is not a valid linked business account");
			require(businesses[to_bus].bs[from_bus], "This is not a valid linked business account");
			uint256 _r = businesses[from_bus].rate[to_bus];
			//burn from first account(customer) and mint into the reciever's businesses 
			businesses[from_bus].uweseCoin.burnFrom(msg.sender, _points);
			businesses[to_bus].uweseCoin.mint(to_bus, _r*_points);

		}

	}
	

    // This function is used by businesses to send points to customer account
	function reward(address _cAd, uint256 _points) public{
		require(businesses[msg.sender].isReg, "This is not a valid business account");
		require(customers[_cAd].isReg, "This is not a valid customer account");
		require(businesses[msg.sender].cus[_cAd], "This customer has not joined your business" );
		require(customers[_cAd].bus[msg.sender], "This customer has not joined your business" );
		businesses[msg.sender].uweseCoin.transferFrom(msg.sender, _cAd, _points);
	}
}