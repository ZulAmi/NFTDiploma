// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract MyNFT is ERC721URIStorage, ChainlinkClient {
    using Counters for Counters.Counter;
    using Chainlink for Chainlink.Request;

    Counters.Counter private _tokenIds;

    // Chainlink variables
    address private immutable oracle;
    bytes32 private immutable jobId;
    uint256 private immutable fee;

    mapping(bytes32 => address) private requestToSender;

    event DiplomaMinted(
        address indexed student,
        uint256 indexed tokenId,
        string school
    );
    event StudentVerificationRequested(
        bytes32 indexed requestId,
        address indexed student,
        string school
    );

    constructor(
        address _oracle,
        bytes32 _jobId,
        uint256 _fee
    ) ERC721("Academic Diploma NFT", "DIPLOMA") {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789); // Sepolia LINK address
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    /**
     * @dev Requests student verification from school through Chainlink
     * @param _school The school name to verify student credentials
     */
    function requestStudentVerification(
        string memory _school
    ) public returns (bytes32) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillStudentVerification.selector
        );

        req.add("school", _school);
        bytes32 requestId = sendChainlinkRequestTo(oracle, req, fee);
        requestToSender[requestId] = msg.sender;

        emit StudentVerificationRequested(requestId, msg.sender, _school);
        return requestId;
    }

    /**
     * @dev Callback function used by Chainlink node to fulfill verification
     * @param _requestId The request ID for verification
     * @param _verified Boolean indicating if student is verified
     */
    function fulfillStudentVerification(
        bytes32 _requestId,
        bool _verified
    ) public recordChainlinkFulfillment(_requestId) {
        address student = requestToSender[_requestId];
        require(student != address(0), "Request ID not found");

        if (_verified) {
            mintDiploma(student);
        }

        delete requestToSender[_requestId];
    }

    /**
     * @dev Internal function to mint diploma NFT
     * @param _to Address to mint the diploma to
     */
    function mintDiploma(address _to) private returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(_to, newTokenId);

        return newTokenId;
    }

    /**
     * @dev Sets the token URI for a given token ID
     * @param tokenId The token ID to set URI for
     * @param tokenURI The URI to set
     */
    function setDiplomaURI(uint256 tokenId, string memory tokenURI) public {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        _setTokenURI(tokenId, tokenURI);
    }

    /**
     * @dev Allows contract owner to withdraw LINK tokens
     */
    function withdrawLink() public {
        require(msg.sender == owner(), "Only owner can withdraw");
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
