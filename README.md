# Decentralized Auction House (English/Dutch style)

A professional-grade implementation for on-chain asset liquidation. This repository provides a robust framework for high-value NFT sales. It supports two primary modes:
* **English Auction:** The classic "highest bidder wins" model with a set end time.
* **Dutch Auction:** A price-discovery model where the price starts high and drops linearly over time until someone buys.

## Core Features
* **Escrow-less Bidding:** Uses a "Highest Bid" tracking system to prevent funds from being locked unnecessarily.
* **Linear Price Decay:** Mathematically sound logic for Dutch Auctions to ensure fair price discovery.
* **Time Buffer:** Optional "Anti-Sniping" feature that extends the auction if a bid is placed in the final minutes.
* **Flat Architecture:** Single-directory layout for the Auction logic, Payout manager, and Bid registry.

## Logic Flow (Dutch Auction)
1. **Initialize:** Seller sets a `startPrice`, `floorPrice`, and `duration`.
2. **Decay:** Every block, the contract calculates the current price based on the elapsed time.
3. **Purchase:** The first user to call `buy()` at the current price wins the asset immediately.

## Setup
1. `npm install`
2. Deploy `AuctionHouse.sol`.
