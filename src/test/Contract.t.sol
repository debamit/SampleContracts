// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "ds-test/test.sol";
import "../Contract.sol";
import "forge-std/Vm.sol";
import "solmate/test/utils/mocks/MockERC20.sol";

contract ContractTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);

    address alice = address(0x1337);
    address bob = address(0x133702);

    MockERC20 token;
    // Flashloaner loaner;
    Contract fundMe;

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestContract");

        token = new MockERC20("TestToken", "TT0", 18);
        vm.label(address(token), "TestToken");

        fundMe = new Contract(address(token));

        token.mint(address(this), 1e18);

        token.approve(address(fundMe), 100);
        fundMe.depositTokens(100);
        // fundMe = new Contract(address(1));
    }

    function testFuzzExample(uint96 _amount) public {
        payable(address(fundMe)).transfer(_amount);
        assertTrue(address(fundMe).balance == _amount);
    }

    function testDepositToken() public {
        assertTrue(true);
    }

    function test_ConstructNonZeroTokenRevert() public {
        vm.expectRevert(Contract.TokenAddressCannotBeZero.selector);
        new Contract(address(0x0));
    }

    function test_PoolBalance() public {
        token.approve(address(fundMe), 1);
        fundMe.depositTokens(1);
        assertEq(fundMe.poolBalance(), 101);
        assertEq(token.balanceOf(address(fundMe)), fundMe.poolBalance());
    }

    function test_DepositNonZeroAmtRevert() public {
        vm.expectRevert(Contract.MustDepositOneTokenMinimum.selector);
        fundMe.depositTokens(0);
    }

    function testFuzz_deposit(uint256 amount) public {
        vm.assume(type(uint256).max - amount >= token.totalSupply());
        vm.assume(amount > 0);

        token.mint(address(this), amount);
        token.approve(address(fundMe), amount);

        uint256 prebal = token.balanceOf(address(fundMe));
        fundMe.depositTokens(amount);

        assertEq(fundMe.poolBalance(), prebal + amount);
        assertEq(token.balanceOf(address(fundMe)), fundMe.poolBalance());
    }
}
