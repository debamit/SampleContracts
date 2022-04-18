// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "ds-test/test.sol";
import "../DutchAuction.sol";
import "forge-std/Vm.sol";
// import "forge-std/stdlib.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "forge-std/console.sol";

contract DutchAuctionTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    DutchAuction auction;
    MockERC20 token;
    address nft = address(0x133709);

    // function setUp() public {
    //     auction = new DutchAuction(100 ether, 0.1, nft, 1);
    // }

    // function test_NftPrice() public {
    //     assertEq(auction.getPrice(), 100 ether);
    // }

    // function testConstructor_WithZeroPrice() public {
    //     vm.label(nft, "NFT address");
    //     console.log("inside consturctor");
    //     vm.expectRevert(stdError.assertionError.selector);
    //     auction = new DutchAuction(100 ether, 0.1, nft, 1);
    // }
}
