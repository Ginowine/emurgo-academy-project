// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract UweseToken is ERC20 {
    
	constructor(uint256 initialSupply, address busOwnerAddress, string memory _name, string memory _symbol) ERC20(_name, _symbol) {
		super._mint(busOwnerAddress, initialSupply);
	}
}