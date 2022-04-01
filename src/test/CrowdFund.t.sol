// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;

import "ds-test/test.sol";
import "../CrowdFund.sol";
import "forge-std/Vm.sol";
import "solmate/test/utils/mocks/MockERC20.sol";

contract CrowdFundTest is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);
    CrowdFund fund;
    MockERC20 token;
    address alice = address(0x1337);
    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id);

    function setUp() public {
        // address creator = address(1234);
        vm.label(address(this), "CrowdFundTestContract");

        token = new MockERC20("CrowdTestToken", "TT1", 18);
        vm.label(address(token), "TestToken");

        fund = new CrowdFund(address(token));

        token.mint(address(this), 1e18);
    }

    function test_StartsBeforeEnds() public {
        vm.expectRevert(CrowdFund.StartTimeAfterEnd.selector);
        fund.launch(
            10 ether,
            uint32(block.timestamp + 1000),
            uint32(block.timestamp)
        );
    }

    function test_GoalAmountZero() public {
        vm.expectRevert(CrowdFund.AmountZero.selector);
        fund.launch(
            0 ether,
            uint32(block.timestamp),
            uint32(block.timestamp + 1000)
        );
    }

    function testEmit_launchCampaign() public {
        vm.expectEmit(true, true, true, true);
        emit Launch(1, address(this), 10000000000000000000, 0, 1000);
        fund.launch(
            10 ether,
            uint32(block.timestamp),
            uint32(block.timestamp + 1000)
        );
    }

    function test_CancelPrank() public {
        fund.launch(
            10 ether,
            uint32(block.timestamp),
            uint32(block.timestamp + 1000)
        );
        vm.expectRevert(CrowdFund.NotCampaignOwner.selector);
        vm.prank(alice);
        fund.cancel(1);
    }

    function testEmit_CancelCampaign() public {
        fund.launch(
            10 ether,
            uint32(block.timestamp + 2),
            uint32(block.timestamp + 1000)
        );
        vm.expectEmit(true, true, true, true);
        emit Cancel(1);
        fund.cancel(1);
    }

    function test_PledgeNonZero() public {
        fund.launch(
            10 ether,
            uint32(block.timestamp),
            uint32(block.timestamp + 1000)
        );
        vm.expectRevert(CrowdFund.AmountZero.selector);
        fund.pledge(1, 0 ether);
    }

    function test_CampaignNotStarted() public {
        fund.launch(
            10 ether,
            uint32(block.timestamp + 2),
            uint32(block.timestamp + 1000)
        );
        vm.expectRevert(CrowdFund.CampaignNotStarted.selector);
        fund.pledge(1, 2 ether);
    }

    function testEmit_Pledge() public {
        fund.launch(
            10 ether,
            uint32(block.timestamp + 2),
            uint32(block.timestamp + 1000)
        );
        vm.expectRevert(CrowdFund.CampaignNotStarted.selector);
        fund.pledge(1, 2 ether);
    }

    function testFuzz_launch(
        uint256 _goalAmount,
        uint32 _startTs,
        uint32 _endTs
    ) public {
        vm.assume(_goalAmount > 0);
        vm.assume(_startTs < _endTs);
        vm.expectEmit(true, true, true, true);
        emit Launch(1, address(this), _goalAmount, _startTs, _endTs);
        fund.launch(_goalAmount, _startTs, _endTs);
    }

    function testFuzz_amount(uint256 _amount) public {
        vm.assume(_amount == 0);
        assertEq(_amount, _amount);
    }
}
