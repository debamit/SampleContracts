// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";

contract Contract {
    ERC20 public immutable damnValuableToken;
    uint256 public poolBalance;
    address owner;

    error TokenAddressCannotBeZero();

    constructor(address tokenAddress) {
        if (tokenAddress == address(0)) revert TokenAddressCannotBeZero();
        damnValuableToken = ERC20(tokenAddress);
        owner = msg.sender;
    }

    error MustDepositOneTokenMinimum();

    function depositTokens(uint256 amount) external {
        if (amount == 0) revert MustDepositOneTokenMinimum();
        // Transfer token from sender. Sender must have first approved them.
        damnValuableToken.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance + amount;
    }

    receive() external payable {}

    function withdraw(uint256 _amount) external {
        payable(msg.sender).transfer(_amount);
    }
}
