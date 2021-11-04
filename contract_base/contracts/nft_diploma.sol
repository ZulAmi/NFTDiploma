// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract MyNFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    using Chainlink for Chainlink.Request;

    Counters.Counter private _tokenIds;

    constructor() ERC721("MYNFT", "TNFT") {}

    X

    //address private oracle;
    //bytes32 private jobId;
   //uint256 private fee;
    
    //string public result;

    //No data providers from schools

    //constructor() {
        //setPublicChainlinkToken();
       //oracle = ;
        //jobId = "";
        //fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    /**
     * Initial request
     */
    //function requestStudentID(string memory _school) public {
        //Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillschoolID.selector);
        //req.add("school", _school);
        //sendChainlinkRequestTo(oracle, req, fee);
    }
    
    /**
     * Callback function
     */
    //function fulfillStudentID(bytes32 _requestId, uint256 _result) public recordChainlinkFulfillment(_requestId) {
        //result = _result;

    function mintToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;