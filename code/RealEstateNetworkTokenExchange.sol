pragma solidity ^0.5.0;

import "./RealEstateNetworkTokenOG2.sol";

// Contract to serve as the marketplace for 
// RENTs (RealEstateTokenNetwork) after importing
// RealEstateNetworkTokenContract
contract RealEstateNetworkTokenExchange is RealEstateNetworkTokenContract {
    
    // Array with all listings, which
    // are structs
    Listing[] public listings;
    
    // Mapping from listing index to user bids
    mapping(uint256 => Bid[]) public listingBids;
    
    // Mapping from owner to a list of owned listings
    mapping(address => uint[]) public listingOwner;
    
    // Bid struct to hold bidder and amount
    struct Bid {
        address payable from;
        uint256 amount;
    }
    
    // Listing struct which holds all the required info
    struct Listing {
        // need "name" property:
        uint256 saleClosingDate; // *FIGURE OUT HOW TO INPUT DATE FORMAT FOR USER
        uint256 price;
        // need "metadata" property?
        uint256 tokenId;
        address realEstateNetworkTokenContractAddress;
        address payable owner;
        bool active;
        bool finalized;
    }
    
    /**
    * @dev Guarantees this contract is owner of the given token
    * @param _realEstateNetworkTokenContractAddress address of the RENT contract to validate from
    * @param _tokenId uint256 ID of the token which has been registered in the RENT contract
    */
    modifier contractIsTokenOwner(address _realEstateNetworkTokenContractAddress, uint256 _tokenId) {
        address tokenOwner = RealEstateNetworkTokenContract(_realEstateNetworkTokenContractAddress).ownerOf(_tokenId);
        require(tokenOwner == address(this));
        _;
    }
    
    /**
    * @dev Guarantees msg.sender is owner of the given listing
    * @param _listingId uint ID of the listing to validate its ownership belongs to msg.sender
    */
    modifier isOwner(uint _listingId) {
        require(listings[_listingId].owner == msg.sender);
        _;
    }
    
    // BidSuccess is fired when a new bid is accepted
    event BidSuccess(address _from, uint _listingId);
    
    // ListingCreated is fired when an listing is created
    event ListingCreated(address _owner, uint _listingId);
    
    // AuctionCanceled is fired when an auction is canceled
    event ListingCanceled(address _owner, uint _listingId);
    
    // AuctionFinalized is fired when an auction is finalized
    event ListingFinalized(address _owner, uint _listingId);
    
    /**
    * @dev Disallow payments to this contract directly
    */
    function() external {
        revert();
    }
    
    /**
    * @dev Creates a listing with the given parameters
    * @param _realEstateNetworkTokenContractAddress address of RealEstateNetworkTokenContract
    * @param _tokenId uint256 of the token created in RealEstateNetworkTokenContract
    * @param _realEstateId uint256 as the unique identifier for each listing
    * @param _price uint256 price of the listing
    * @param _saleClosingDate uint date at which the listing will be taken down
    * @return bool whether the listing is created
    */
    function createListing(address _realEstateNetworkTokenContractAddress,
        uint256 _tokenId,
        uint256 _realEstateId,
        uint256 _price,
        uint _saleClosingDate
    ) public contractIsTokenOwner(_realEstateNetworkTokenContractAddress, _tokenId) returns(bool) {
        uint listingId = listings.length;
        Listing memory newListing;
        newListing.saleClosingDate = _saleClosingDate;
        newListing.price = _price;
        newListing.tokenId = _tokenId;
        newListing.realEstateNetworkTokenContractAddress = _realEstateNetworkTokenContractAddress;
        newListing.owner = msg.sender;
        newListing.active = true;
        newListing.finalized = false;
        
        listings.push(newListing);        
        listingOwner[msg.sender].push(listingId);
        
        emit ListingCreated(msg.sender, listingId);
        return true;
    }
    
    /**
    * @dev Approves and transfers
    * @dev token is transfered back to the listing owner
    * @dev Bidder is refunded with the initial amount
    * @param _from address of owner
    * @param _to address of recipient
    * @param _tokenId uint ID of the created token
    * @return bool whether the listing is approved
    */
    function approveAndTransfer(address _from, address _to, address _realEstateNetworkTokenContractAddress, uint256 _tokenId) internal returns(bool) {
        RealEstateNetworkTokenContract tempContract = RealEstateNetworkTokenContract(_realEstateNetworkTokenContractAddress);
        tempContract.approve(_to, _tokenId);
        tempContract.transferFrom(_from, _to, _tokenId);
        return true;
    }
    
    /**
    * @dev Cancels an ongoing listing by the owner
    * @dev RENT is transfered back to the listing owner
    * @dev Bidder is refunded with the initial amount
    * @param _listingId uint ID of the created listing
    */
    function cancelListing(uint _listingId) public isOwner(_listingId) {
        Listing memory myListing = listings[_listingId];
        uint bidsLength = listingBids[_listingId].length;

        // if there are bids refund the last bid
        if(bidsLength > 0) {
            Bid memory lastBid = listingBids[_listingId][bidsLength - 1];
            if(!lastBid.from.send(lastBid.amount)) {
                revert();
            }
        }

        // approve and transfer from this contract to auction owner
        if(approveAndTransfer(address(this), myListing.owner, myListing.realEstateNetworkTokenContractAddress, myListing.tokenId)){
            listings[_listingId].active = false;
            emit ListingCanceled(msg.sender, _listingId);
        }
    }
    
    /**
    * @dev Finalized the closing of a listing
    * @dev The listing should be completed, and there should be at least one bid
    * @dev On success, token is transfered to bidder and listing owner gets the amount
    * @param _listingId uint ID of the created listing
    */
    function finalizeListing(uint _listingId) public {
        Listing memory myListing = listings[_listingId];
        uint bidsLength = listingBids[_listingId].length;

        // 1. if auction not ended just revert
        if(now < myListing.saleClosingDate) revert();
        
        // if there are no bids cancel
        if(bidsLength == 0) {
            cancelListing(_listingId);
        }else{

            // 2. the money goes to the auction owner
            Bid memory lastBid = listingBids[_listingId][bidsLength - 1];
            if(!myListing.owner.send(lastBid.amount)) {
                revert();
            }

            // approve and transfer from this contract to the bid winner 
            if(approveAndTransfer(address(this), lastBid.from, myListing.realEstateNetworkTokenContractAddress, myListing.tokenId)){
                listings[_listingId].active = false;
                listings[_listingId].finalized = true;
                emit ListingFinalized(msg.sender, _listingId);
            }
        }
    }
    
    /**
    * @dev Bidder sends bid on an auction
    * @dev Listing should be active and not ended
    * @dev Refund previous bidder if a new bid is valid and placed.
    * @param _listingId uint ID of the created listing
    */
    function bidOnListing(uint _listingId) external payable {
        uint256 newBidAmount = msg.value;

        // Owner should be unable to bid on own listing
        Listing memory myListing = listings[_listingId];
        if(myListing.owner == msg.sender) revert();

        // Verify the listing has not closed
        if(now > myListing.saleClosingDate) revert();

        uint bidsLength = listingBids[_listingId].length;
        uint256 tempAmount = myListing.price;
        Bid memory lastBid;

        // If there are previous bids
        if(bidsLength > 0) {
            lastBid = listingBids[_listingId][bidsLength - 1];
            tempAmount = lastBid.amount;
        }

        // Check if amount is greater than previous amount  
        if(newBidAmount < tempAmount) revert(); 

        // Refund the last bidder
        if(bidsLength > 0) {
            if(!lastBid.from.send(lastBid.amount)) {
                revert();
            }  
        }

        // Insert new bid 
        Bid memory newBid;
        newBid.from = msg.sender;
        newBid.amount = newBidAmount;
        listingBids[_listingId].push(newBid);
        emit BidSuccess(msg.sender, _listingId);
    }
}