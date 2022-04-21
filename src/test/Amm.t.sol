// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "ds-test/test.sol";
import "../Amm.sol";
import "forge-std/Vm.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "forge-std/console.sol";

contract AmmTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);

    address alice = address(0x13390);
    address bob = address(0x133799);

    MockERC20 token0;
    MockERC20 token1;
    Amm amm;

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestContract");

        token0 = new MockERC20("TestToken0", "TTT", 18);
        vm.label(address(token0), "TestToken0");

        token1 = new MockERC20("TestToken1", "WWW", 18);
        vm.label(address(token1), "TestToken1");

        token0.mint(address(this), 1e18);
        token1.mint(address(this), 1e18);

        token0.approve(address(amm), 1e18);
        token1.approve(address(amm), 1e18);
        // fundMe.depositTokens(100);
        amm = new Amm(address(token0), address(token1));
    }

    function test_TokenAmountsNotValid() public {
        // Given: Existing pool
        token0.approve(address(amm), 10);
        token1.approve(address(amm), 1);
        amm.addLiquidity(10, 1);

        //When adding additional liquidity
        token0.approve(address(amm), 100);
        token1.approve(address(amm), 15);
        vm.expectRevert(Amm.TokenAmountsNotValid.selector);
        amm.addLiquidity(100, 15);
    }

    function test_AddLiquidityToNewPool() public {
        token0.approve(address(amm), 10);
        token1.approve(address(amm), 10);
        amm.addLiquidity(10, 1);
        (uint256 reserve0, uint256 reserve1) = amm.getReserves();
        assertEq(reserve0, 10);
        assertEq(reserve1, 1);
    }

    function test_AddLiquidityToExistingPool() public {
        token0.approve(address(amm), 10);
        token1.approve(address(amm), 1);
        amm.addLiquidity(10, 1);
        uint256 originalShares = amm.getShares(address(this));
        console.log("initial share count", originalShares);
        token0.approve(address(amm), 100);
        token1.approve(address(amm), 10);
        amm.addLiquidity(100, 10);
        (uint256 reserve0, uint256 reserve1) = amm.getReserves();
        uint256 shares = amm.getShares(address(this));
        console.log("shares after adding liquidity", shares);
        assertEq(reserve0, 110);
        assertEq(reserve1, 11);
    }

    function test_RemoveLiquidity() public {
        token0.approve(address(amm), 110);
        token1.approve(address(amm), 11);
        amm.addLiquidity(110, 11);
        uint256 originalShares = amm.getShares(address(this));
        console.log("initial share count", originalShares);
        amm.removeLiquidity(originalShares);
        (uint256 reserve0, uint256 reserve1) = amm.getReserves();
        assertEq(reserve0, 0);
        assertEq(reserve1, 0);
    }
}
