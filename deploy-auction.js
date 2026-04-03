const hre = require("hardhat");

async function main() {
  const NFT_ADDR = "0x..."; // Target NFT contract
  
  const Auction = await hre.ethers.getContractFactory("AuctionHouse");
  const auction = await Auction.deploy(NFT_ADDR);

  await auction.waitForDeployment();
  console.log("Auction House deployed to:", await auction.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
