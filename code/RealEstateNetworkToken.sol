pragma solidity ^0.5.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721Mintable.sol";

/**
 * @title RealEstateNetworkToken
 * Contract to create new non-fungible ERC721 RENT (RealEstateNetworkToken) 
 * to then be used in a decentralized marketplace,
 * RealEstateNetworkTokenExchange
 */
contract RealEstateNetworkTokenContract is ERC721Full {

    /**
    * @dev constructor to create a RealEstateNetworkToken
    * @param _name string represents the name of the token
    * @param _symbol string represents the symbol of the token
    */
    constructor() public ERC721Full("RealEstateNetworkToken", "RENT") {}
    
    /**
    * @dev Public function to add metadata to a deed
    * @param _tokenId represents a specific deed
    * @param _uri text which describes the characteristics of a given deed
    * @return whether the deed metadata was added to the repository
    *
    function addDeedMetadata(uint256 _tokenId, string _uri) public returns(bool){
        _setTokenURI(_tokenId, _uri);
        return true;
    }
    */
    
    /**
    * @dev Public function to register a new deed
    * @dev Call the ERC721Token minter
    * @param _tokenId uint256 represents a specific deed
    * @param _uri string containing metadata/uri
    */
    function mintRent(uint256 _tokenId/*, string memory _uri*/) public {
        _mint(msg.sender, _tokenId);
        //addDeedMetadata(_tokenId, _uri);
        emit TokenMinted(msg.sender, _tokenId);
    }

    /**
    * @dev Event is triggered if deed/token is registered
    * @param _by address of the registrar
    * @param _tokenId uint256 represents a specific deed
    */
    event TokenMinted(address _by, uint256 _tokenId);
}