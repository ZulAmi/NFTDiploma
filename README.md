# NFTDiploma 🎓

A decentralized platform for issuing and verifying academic credentials using NFTs and Chainlink oracles.

## Features ✨

- Mint verifiable academic credentials as NFTs
- Chainlink oracle integration for credential verification
- NFT marketplace for credential trading
- Smart contract based ownership and transfer
- Automated verification system

## Tech Stack 🛠

- Solidity ^0.8.0
- OpenZeppelin Contracts
- Chainlink Oracles
- Hardhat
- ethers.js
- React.js
- Web3.js

## Prerequisites 📋

- Node.js >= 14
- npm >= 6
- MetaMask wallet
- Sepolia testnet ETH
- Sepolia testnet LINK

## Installation 🚀

```bash
# Clone the repository
git clone https://github.com/yourusername/NFTDiploma.git

# Install dependencies
cd NFTDiploma
npm install

# Create .env file
cp .env.example .env
```
```
Usage 💡

# Start local hardhat node
npx hardhat node

# Deploy contracts
npx hardhat run scripts/deploy.js --network sepolia

# Run frontend
npm run dev
