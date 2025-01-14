// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarketplace is ReentrancyGuard, Pausable, Ownable {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isActive;
    }

    // State variables
    uint256 public marketplaceFee = 250; // 2.5% fee (basis points)
    mapping(uint256 => Listing) public listings;
    uint256 private _listingCounter;

    // Events
    event Listed(
        uint256 indexed listingId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 price
    );
    event Sale(
        uint256 indexed listingId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );
    event ListingCanceled(uint256 indexed listingId);
    event FeeUpdated(uint256 newFee);

    constructor() {
        _listingCounter = 0;
    }

    function listNFT(
        address _nftContract,
        uint256 _tokenId,
        uint256 _price
    ) external whenNotPaused nonReentrant returns (uint256) {
        require(_price > 0, "Price must be greater than 0");
        require(
            IERC721(_nftContract).ownerOf(_tokenId) == msg.sender,
            "Not token owner"
        );
        require(
            IERC721(_nftContract).getApproved(_tokenId) == address(this),
            "Marketplace not approved"
        );

        _listingCounter++;
        listings[_listingCounter] = Listing({
            seller: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            price: _price,
            isActive: true
        });

        emit Listed(
            _listingCounter,
            msg.sender,
            _nftContract,
            _tokenId,
            _price
        );

        return _listingCounter;
    }

    function buyNFT(
        uint256 _listingId
    ) external payable whenNotPaused nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.isActive, "Listing not active");
        require(msg.value == listing.price, "Incorrect payment amount");
        require(msg.sender != listing.seller, "Seller cannot buy");

        listing.isActive = false;

        uint256 feeAmount = (listing.price * marketplaceFee) / 10000;
        uint256 sellerAmount = listing.price - feeAmount;

        // Transfer NFT to buyer
        IERC721(listing.nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            listing.tokenId
        );

        // Transfer payment to seller
        (bool success, ) = payable(listing.seller).call{value: sellerAmount}(
            ""
        );
        require(success, "Failed to send ETH to seller");

        emit Sale(_listingId, msg.sender, listing.seller, listing.price);
    }

    function cancelListing(uint256 _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        require(listing.seller == msg.sender, "Not seller");
        require(listing.isActive, "Listing not active");

        listing.isActive = false;
        emit ListingCanceled(_listingId);
    }

    function updateMarketplaceFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 1000, "Fee too high"); // Max 10%
        marketplaceFee = _newFee;
        emit FeeUpdated(_newFee);
    }

    function getListing(
        uint256 _listingId
    ) external view returns (Listing memory) {
        return listings[_listingId];
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    receive() external payable {}

    fallback() external payable {}
}
