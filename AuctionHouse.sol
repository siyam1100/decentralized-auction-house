// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AuctionHouse
 * @dev Implements a Dutch Auction for NFTs.
 */
contract AuctionHouse is ReentrancyGuard {
    struct DutchAuction {
        address seller;
        uint256 nftId;
        uint256 startPrice;
        uint256 floorPrice;
        uint256 startTime;
        uint256 duration;
        bool active;
    }

    IERC721 public immutable nftCollection;
    mapping(uint256 => DutchAuction) public auctions;

    event AuctionCreated(uint256 indexed nftId, uint256 startPrice);
    event AuctionSettled(uint256 indexed nftId, address indexed winner, uint256 price);

    constructor(address _nftCollection) {
        nftCollection = IERC721(_nftCollection);
    }

    function createDutchAuction(
        uint256 _nftId,
        uint256 _startPrice,
        uint256 _floorPrice,
        uint256 _duration
    ) external {
        nftCollection.transferFrom(msg.sender, address(this), _nftId);
        
        auctions[_nftId] = DutchAuction({
            seller: msg.sender,
            nftId: _nftId,
            startPrice: _startPrice,
            floorPrice: _floorPrice,
            startTime: block.timestamp,
            duration: _duration,
            active: true
        });

        emit AuctionCreated(_nftId, _startPrice);
    }

    function getCurrentPrice(uint256 _nftId) public view returns (uint256) {
        DutchAuction memory auction = auctions[_nftId];
        if (block.timestamp >= auction.startTime + auction.duration) return auction.floorPrice;
        
        uint256 elapsed = block.timestamp - auction.startTime;
        uint256 decay = ((auction.startPrice - auction.floorPrice) * elapsed) / auction.duration;
        return auction.startPrice - decay;
    }

    function buy(uint256 _nftId) external payable nonReentrant {
        DutchAuction storage auction = auctions[_nftId];
        uint256 currentPrice = getCurrentPrice(_nftId);
        
        require(auction.active, "Auction not active");
        require(msg.value >= currentPrice, "Value below current price");

        auction.active = false;
        nftCollection.safeTransferFrom(address(this), msg.sender, _nftId);
        
        payable(auction.seller).transfer(currentPrice);
        if (msg.value > currentPrice) {
            payable(msg.sender).transfer(msg.value - currentPrice);
        }

        emit AuctionSettled(_nftId, msg.sender, currentPrice);
    }
}
