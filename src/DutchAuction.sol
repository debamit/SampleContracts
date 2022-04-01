// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

contract DutchAuction {
    // Seller of NFT deploys this contract setting a starting price for the NFT.
    uint8 public constant duration = 7;
    uint256 public startTs;
    uint256 public price;
    uint256 public immutable discountRate;
    IERC721 public immutable nft;
    address seller;
    uint256 public nftId;

    constructor(
        uint256 _price,
        uint256 _discountRate,
        address _nftAddress,
        uint256 _nftId
    ) {
        require(_price > 0, "Price needs to be greater than 0.");
        require(_discountRate > 0, "Discount Rate needs to be greater than 0.");
        require(
            _nftAddress != address(0x00),
            "Discount Rate needs to be greater than 0."
        );
        price = _price;
        discountRate = _discountRate;
        startTs = block.timestamp;
        nft = IERC721(_nftAddress);
        seller = msg.sender;
        nftId = _nftId;
    }

    function getCurrentPrice() public view returns (uint256) {
        // uint256 timeElapsed = block.timestamp - startTs;
        uint256 daysElapsed = (block.timestamp - startTs) / 60 / 60 / 24;
        return price * (daysElapsed * discountRate);
    }

    function bid() public payable {
        if (msg.value < 0) revert();
        uint256 currentPrice = getCurrentPrice();
        if (msg.value < currentPrice) revert();
        nft.transferFrom(seller, msg.sender, nftId);
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    // Auction lasts for 7 days.
    // Price of NFT decreases over time.
    // Participants can buy by depositing ETH greater than the current price computed by the smart contract.
    // Auction ends when a buyer buys the NFT.
}
