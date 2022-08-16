// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract StakingRewards {
  IERC20 public immutable stakingToken;
  IERC20 public immutable rewardsToken;

  address public owner;

  uint256 public duration;
  uint256 public finishAt;
  uint256 public updatedAt;
  uint256 public rewardRate;
  uint256 public rewardPerTokenStored;
  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;

  uint256 public totalSupply;
  mapping(address => uint256) public balanceOf;

  modifier onlyOwner() {
    require(msg.sender == owner, 'not owner');
    _;
  }

  modifier updateReward(address _account) {
    rewardPerTokenStored = rewardPerToken();
    updatedAt = lastTimeRewardApplicable();

    if (_account != address(0)) {
      rewards[_account] = earned(_account);
      userRewardPerTokenPaid[_account] = rewardPerTokenStored;
    }

    _;
  }

  constructor(address _stakingToken, address _rewardsToken) {
    owner = msg.sender;
    stakingToken = IERC20(_stakingToken);
    rewardsToken = IERC20(_rewardsToken);
  }

  function setRewardsDuration(uint256 _duration) external {
    require(finishAt < block.timestamp, 'reward duration not finished');
    duration = _duration;
  }

  function notifyRewardAmount(uint256 _amount)
    external
    onlyOwner
    updateReward(address(0))
  {
    if (block.timestamp >= finishAt) {
      rewardRate = _amount / duration;
    } else {
      uint256 remainingRewards = (finishAt - block.timestamp) * rewardRate;
      rewardRate = (_amount + remainingRewards) / duration;
    }

    require(rewardRate > 0, 'reward rate = 0');
    require(
      rewardRate * duration <= rewardsToken.balanceOf(address(this)),
      'reward amount > balance'
    );

    finishAt = block.timestamp + duration;
    updatedAt = block.timestamp;
  }

  function stake(uint256 _amount) external {
    require(_amount > 0, 'amount = 0');
    stakingToken.transferFrom(msg.sender, address(this), _amount);
    balanceOf[msg.sender] += _amount;
    totalSupply += _amount;
  }

  function withdraw(uint256 _amount) external updateReward(msg.sender) {
    require(_amount > 0, 'amount = 0');
    balanceOf[msg.sender] -= _amount;
    totalSupply -= _amount;
    stakingToken.transfer(msg.sender, _amount);
  }

  function _min(uint256 x, uint256 y) private pure returns (uint256) {
    return x <= y ? x : y;
  }

  function lastTimeRewardApplicable() public view returns (uint256) {
    return _min(finishAt, block.timestamp);
  }

  function rewardPerToken() public view returns (uint256) {
    if (totalSupply == 0) {
      return rewardPerTokenStored;
    }

    return
      rewardPerTokenStored +
      (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
      totalSupply;
  }

  function earned(address _account) public view returns (uint256) {
    return
      ((balanceOf[_account] *
        (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
      rewards[_account];
  }

  function getReward() external updateReward(msg.sender) {
    uint256 reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      rewardsToken.transfer(msg.sender, reward);
    }
  }
}
