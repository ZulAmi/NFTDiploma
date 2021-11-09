// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC721/ERC721.sol";

contract MarketPlace {
    event BalanceWithdrawn(address indexed beneficiary, uint256 amount);
    event OperatorChanged(address previousOperator, address newOperator);

    address operator;
    uint256 offeringNonce;

    struct offering {
        uint256 tokenId;
        uint256 price;
        bool closed;
    }

    mapping(bytes32 => offering) offeringRegistry;
    mapping(address => uint256) balances;

    constructor(address _operator) {
        operator = _operator;
    }

    function withdrawBalance() external {
        require(
            balances[msg.sender] > 0,
            "You don't have any balance to withdraw"
        );
        uint256 amount = balances[msg.sender];
        payable(msg.sender).transfer(amount);
        balances[msg.sender] = 0;
        emit BalanceWithdrawn(msg.sender, amount);
    }

    function changeOperator(address _newOperator) external {
        require(
            msg.sender == operator,
            "only the operator can change the current operator"
        );
        address previousOperator = operator;
        operator = msg.sender;
        emit OperatorChanged(previousOperator, operator);
    }

    function viewBalances(address _address) external view returns (uint256) {
        return (balances[_address]);
    }
}
