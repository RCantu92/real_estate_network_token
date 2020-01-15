pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Mintable.sol";

contract RealEstateNetworkToken is ERC721Full, ERC721Mintable {
    
    // Constructor to set up RENT and
    // set the contract owner to the msg.sender
    constructor() ERC721Full("RealEstateNetworkToken", "RENT") public {
    }
    
    /* Function to mint new RENT
    /* It will require the msg.sender to be the owner of the contract.
    */
    mint(_to, _realEstateId);
}