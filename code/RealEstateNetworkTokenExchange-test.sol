pragma solidity ^0.5.0;

import "./RealEstateNetworkTokenOG.sol";

// Contract to serve as the marketplace for 
// RENTs (RealEstateTokenNetwork)
contract RealEstateTokenExchangeOG is RealEstateNetworkToken {
    
    // Setting the initial owner of the contract
    address payable OWNER = msg.sender;
    
    // Function to accept gas and commission fees
    // Fix: OWNER has to call, but the _to has to pay OWNER for this to happen
    function mintNewRent(address _to, uint256 _tokenId) private {
    }
    
    // Function that transfers the
    // minting fee to contract OWNER.
    function mintFeeTransfer() private {
        OWNER.transfer(msg.value);
    }
    
    // Function to initiate minting transaction called by
    // person wanting the minting.
    function payMintingFee(uint256 _tokenId) public payable {
        // Function to be called by person
        // looking to mint new tokens
        require(msg.value >= 0.01 ether, "You have either paid too much or too little to mint new tokens.");
    }
    
    
    
    
    // Below this line, I will add code inspired by Mastering Ethereum
    
    
    // Completed: Can create a new listing
    // and bid on existing listing.
    
    
    // Array with all auctions
    Listing[] public listings;
    
    // Mapping from listing index to user bids
    mapping(uint256 => Bid[]) public listingBids;
    
    // Mapping from owner to a list of owned auctions
    mapping(address => uint[]) public listingOwner;
    
    // Bid struct to hold bidder and amount
    struct Bid {
        address from;
        uint256 amount;
    }
    
    // Sale struct which holds all the required info
    struct Listing {
        uint256 saleClosingDate;
        uint256 price;
        uint256 realEstateId;
        // This syncs with the token contract?
        //address deedRepositoryAddress;
        address owner;
        bool active;
        bool finalized;
    }
    
    
    /**
    * @dev Creates a listing with the given parameters
    * @param _realEstateId uint256 as the unique identifier for each listing
    * @param _price uint256 price of the listing
    * @param _saleClosingDate uint date at which the listing will be taken down
    * @return bool whether the listing is created
    */
    function createListing(uint256 _realEstateId, uint256 _price, uint _saleClosingDate) public returns(bool) {
        uint listingId = listings.length;
        Listing memory newListing;
        newListing.saleClosingDate = _saleClosingDate;
        newListing.price = _price;
        newListing.realEstateIdId = _realEstateIdId;
        // This syncs with the token contract?
        //newAuction.deedRepositoryAddress = _deedRepositoryAddress;
        newListing.owner = msg.sender;
        newListing.active = true;
        newListing.finalized = false;
        
        listings.push(newListing);        
        listingOwner[msg.sender].push(listingId);
        
        emit ListingCreated(msg.sender, auctionId);
        return true;
    
    
    /**
    * @dev Bidder sends bid on an auction
    * @dev Listing should be active and not ended
    * @dev Refund previous bidder if a new bid is valid and placed.
    * @param _listingId uint ID of the created auction
    */
    function bidOnListing(uint _listingId) external payable {
        uint256 newBidAmount = msg.value;

        // Owner should be unable to bid on listing
        Listing memory myListing = listings[_listingId];
        if(myListing.owner == msg.sender) revert();

        // Verify the listing has not closed
        if(now > saleClosingDate) revert();

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
        emit BidSuccess(msg.sender, _auctionId);
    }
    
    // BidSuccess is fired when a new bid is created
    event BidSuccess(address _from, uint _auctionId);
    
    // SaleCreated is fired when an sale is created
    event AuctionCreated(address _owner, uint _auctionId);
    }
}