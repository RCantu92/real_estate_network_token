pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Mintable.sol";

/**
 * @title RealEstateNetworkToken
 * Contract to create new non-fungible ERC721 RENT (RealEstateNetworkToken) 
 * to then be used in a decentralized marketplace,
 * RealEstateNetworkTokenExchange
 */
contract RealEstateNetworkTokenContract is ERC721Full, ERC721Mintable {

    /**
    * @dev constructor to create a RealEstateNetworkToken
    * Hardcoded "RealEstateNetworkToken" as name of the token
    * Hardcoded the "RENT" as the symbol of the token
    */
    constructor() public ERC721Full("RealEstateNetworkToken", "RENT") {}
    
    /**
    * @dev Event is triggered if deed/token is registered
    * @param _by address of the registrar
    * @param _tokenId uint256 represents a specific deed
    */
    event TokenRegistered(address _by, uint256 _tokenId);
    
    /**
    * @dev Public function to add metadata to a token
    * @param _tokenId represents a specific token
    * @param _uri text which describes the characteristics of a given token
    * @return whether the deed metadata was added to the repository
    */
    function addTokenMetadata(uint256 _tokenId, string memory _uri) public returns(bool){
        _setTokenURI(_tokenId, _uri);
        return true;
    }
    
    /**
    * @dev Public function to register a new token
    * @param _tokenId uint256 represents a specific token
    * @param _uri string containing metadata/uri
    */
    function registerToken(uint256 _tokenId, string memory _uri) public {
        safeMint(msg.sender, _tokenId);
        addTokenMetadata(_tokenId, _uri);
        emit TokenRegistered(msg.sender, _tokenId);
    }
}