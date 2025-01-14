const NFT_CONTRACT_ADDRESS = "YOUR_NFT_CONTRACT_ADDRESS";
const MARKETPLACE_ADDRESS = "YOUR_MARKETPLACE_ADDRESS";
const CHAIN_ID = "0xaa36a7"; // Sepolia testnet

// Contract ABIs
const nftABI = [...]; // Import your NFT contract ABI
const marketplaceABI = [...]; // Import your marketplace ABI

let web3;
let nftContract;
let marketplaceContract;
let userAccount;

// Initialize Web3
async function initWeb3() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            web3 = new Web3(window.ethereum);
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            userAccount = (await web3.eth.getAccounts())[0];

            nftContract = new web3.eth.Contract(nftABI, NFT_CONTRACT_ADDRESS);
            marketplaceContract = new web3.eth.Contract(marketplaceABI, MARKETPLACE_ADDRESS);

            initializeApp();
        } catch (error) {
            console.error("Web3 initialization failed:", error);
        }
    } else {
        alert("Please install MetaMask!");
    }
}

// Initialize app functions
async function initializeApp() {
    await loadUserNFTs();
    await loadMarketplaceListings();
    setupEventListeners();
}

// Load user's NFTs
async function loadUserNFTs() {
    try {
        const balance = await nftContract.methods.balanceOf(userAccount).call();
        const nfts = [];

        for (let i = 0; i < balance; i++) {
            const tokenId = await nftContract.methods.tokenOfOwnerByIndex(userAccount, i).call();
            const tokenURI = await nftContract.methods.tokenURI(tokenId).call();
            const metadata = await fetch(tokenURI).then(res => res.json());

            nfts.push({
                tokenId,
                metadata
            });
        }

        updateNFTDisplay(nfts);
    } catch (error) {
        console.error("Error loading NFTs:", error);
    }
}

// Load marketplace listings
async function loadMarketplaceListings() {
    try {
        const listingCount = await marketplaceContract.methods.getListingCount().call();
        const listings = [];

        for (let i = 1; i <= listingCount; i++) {
            const listing = await marketplaceContract.methods.getListing(i).call();
            if (listing.isActive) {
                listings.push(listing);
            }
        }

        updateListingsDisplay(listings);
    } catch (error) {
        console.error("Error loading listings:", error);
    }
}

// List NFT on marketplace
async function listNFT(tokenId, price) {
    try {
        await nftContract.methods.approve(MARKETPLACE_ADDRESS, tokenId).send({ from: userAccount });
        await marketplaceContract.methods.listNFT(NFT_CONTRACT_ADDRESS, tokenId, price)
            .send({ from: userAccount });
    } catch (error) {
        console.error("Error listing NFT:", error);
    }
}

// Buy NFT from marketplace
async function buyNFT(listingId, price) {
    try {
        await marketplaceContract.methods.buyNFT(listingId)
            .send({ from: userAccount, value: price });
    } catch (error) {
        console.error("Error buying NFT:", error);
    }
}

// Setup event listeners
function setupEventListeners() {
    marketplaceContract.events.Listed()
        .on('data', event => handleListingEvent(event))
        .on('error', console.error);

    marketplaceContract.events.Sale()
        .on('data', event => handleSaleEvent(event))
        .on('error', console.error);
}

// Event handlers
function handleListingEvent(event) {
    loadMarketplaceListings();
}

function handleSaleEvent(event) {
    loadMarketplaceListings();
    loadUserNFTs();
}

// UI update functions
function updateNFTDisplay(nfts) {
    const container = document.getElementById('nft-container');
    container.innerHTML = nfts.map(nft => `
        <div class="nft-card">
            <img src="${nft.metadata.image}" alt="${nft.metadata.name}">
            <h3>${nft.metadata.name}</h3>
            <button onclick="listNFT(${nft.tokenId})">List for Sale</button>
        </div>
    `).join('');
}

function updateListingsDisplay(listings) {
    const container = document.getElementById('listings-container');
    container.innerHTML = listings.map(listing => `
        <div class="listing-card">
            <p>Token ID: ${listing.tokenId}</p>
            <p>Price: ${web3.utils.fromWei(listing.price)} ETH</p>
            <button onclick="buyNFT(${listing.listingId}, '${listing.price}')">Buy</button>
        </div>
    `).join('');
}

// Initialize app
window.addEventListener('load', initWeb3);
