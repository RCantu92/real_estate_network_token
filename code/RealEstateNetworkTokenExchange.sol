pragma solidity ^0.5.0;

import "./RealEstateNetworkTokenContract.sol";

// Contract to serve as the marketplace for 
// RENTs (RealEstateTokenNetwork) after importing
// RealEstateNetworkTokenContract
contract RealEstateNetworkTokenExchange is RealEstateNetworkTokenContract {
    
    // Setting up the contract owner
    // upon contract creation
    address OWNER = msg.sender;
    
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
        uint256 saleClosingDate;
        uint256 price;
        string metadata;
        uint256 tokenId;
        address payable owner;
        bool active;
        bool finalized;
    }
    
    /**
    * @dev Guarantees msg.sender qualified to create listings
    */
    modifier isContractOwner() {
        require(OWNER == msg.sender);
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
    * @param _tokenId uint256 of the token created in RealEstateNetworkTokenContract
    * @param _price uint256 price of the listing
    * @return bool whether the listing is created
    */
    function createListing(uint256 _tokenId, uint256 _price) public isContractOwner() returns(bool) {
        uint listingId = listings.length;
        Listing memory newListing;
        newListing.saleClosingDate = now + 2 minutes;
        newListing.price = _price;
        newListing.tokenId = _tokenId;
        newListing.owner = msg.sender;
        newListing.active = true;
        newListing.finalized = false;
        
        listings.push(newListing);        
        listingOwner[msg.sender].push(listingId);
        
        emit ListingCreated(msg.sender, listingId);
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
        listings[_listingId].active = false;
        emit ListingCanceled(msg.sender, _listingId);
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

            // 2. the money goes to the listing owner
            Bid memory lastBid = listingBids[_listingId][bidsLength - 1];
            if(!myListing.owner.send(lastBid.amount)) {
                revert();
            }

            // 3. approve and transfer from this owner to the bid winner
            myListing.owner = lastBid.from;
            myListing.active = false;
            myListing.finalized = true;
            emit ListingFinalized(msg.sender, _listingId);
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
    
    /**
    * @dev Gets the address of the owner of the token
    * @param _tokenId ID of the token
    * @param _listingId the ID of the listing
    */
    function ownerOfToken(uint _tokenId, uint _listingId) view public returns(address) {
        Listing memory myListing = listings[_listingId];
        require(myListing.tokenId == _tokenId, "The provided token ID is incorrect.");
        address tokenOwner = myListing.owner;
        return tokenOwner;
    }
}