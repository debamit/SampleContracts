// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

contract CrowdFund {
    event Launch(
        uint256 id,
        address indexed creator,
        uint256 goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint256 id);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 id, address indexed caller, uint256 amount);

    struct Campaign {
        // Creator of campaign
        address creator;
        // Amount of tokens to raise
        uint256 goal;
        // Total amount pledged
        uint256 pledged;
        // Timestamp of start of campaign
        uint32 startAt;
        // Timestamp of end of campaign
        uint32 endAt;
        // True if goal was reached and creator has claimed the tokens.
        bool claimed;
    }

    IERC20 public immutable token;
    uint256 public count;
    // Mapping from id to Campaign
    mapping(uint256 => Campaign) public campaigns;
    // Mapping from campaign id => pledger => amount pledged
    mapping(uint256 => mapping(address => uint256)) public pledgedAmount;

    constructor(address _tokenAddres) {
        token = IERC20(_tokenAddres);
    }

    error StartTimeAfterEnd();
    error AmountZero();
    error NotCampaignOwner();
    error CampaignNotStarted();
    error InsufficientAmount();
    error CampaignClaimed();
    error IncompleteCampaign();

    function launch(
        uint256 _goalAmount,
        uint32 _startTs,
        uint32 _endTs
    ) public {
        if (_startTs > _endTs) revert StartTimeAfterEnd();
        if (_goalAmount <= 0) revert AmountZero();

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goalAmount,
            pledged: 0,
            startAt: _startTs,
            endAt: _endTs,
            claimed: false
        });

        emit Launch(count, msg.sender, _goalAmount, _startTs, _endTs);
    }

    function cancel(uint256 _campaignId) public {
        Campaign memory campaign = campaigns[_campaignId];
        if (campaign.creator != msg.sender) revert NotCampaignOwner();
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_campaignId];
        emit Cancel(_campaignId);
    }

    function pledge(uint256 _campaignId, uint256 _pledgeAmount) public {
        Campaign memory campaign = campaigns[_campaignId];
        if (_pledgeAmount <= 0) revert AmountZero();
        if (block.timestamp < campaign.startAt) revert CampaignNotStarted();
        if (!campaign.claimed) revert CampaignNotStarted();
        campaign.pledged += _pledgeAmount;
        pledgedAmount[_campaignId][msg.sender] += _pledgeAmount;
        token.transferFrom(msg.sender, address(this), _pledgeAmount);
        emit Pledge(_campaignId, msg.sender, _pledgeAmount);
    }

    function unpledge(uint256 _campaignId, uint256 _unpledgeAmount) public {
        Campaign memory campaign = campaigns[_campaignId];
        if (_unpledgeAmount <= 0) revert AmountZero();
        if (_unpledgeAmount > campaign.pledged) revert InsufficientAmount();
        if (block.timestamp < campaign.startAt) revert CampaignNotStarted();
        campaign.pledged -= _unpledgeAmount;
        pledgedAmount[_campaignId][msg.sender] -= _unpledgeAmount;
        token.transfer(msg.sender, _unpledgeAmount);
        emit Unpledge(_campaignId, msg.sender, _unpledgeAmount);
    }

    function claim(uint256 _campaignId) public {
        Campaign memory campaign = campaigns[_campaignId];
        if (!campaign.claimed) revert CampaignClaimed();
        if (campaign.pledged < campaign.goal) revert IncompleteCampaign();
        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claim(_campaignId);
    }
}
