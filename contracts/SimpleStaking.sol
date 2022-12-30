// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeCast.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';

contract SimpleStakingPool is ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeCast for uint256;

  // ERC20 contract address
  IERC20 public immutable tokenAddress;

  // Staker info
  struct Staker {
    uint256 deposited;
    uint256 timeOfLastUpdate;
    uint256 unclaimedRewards;
  }

  uint256 public APR = 40; // 40% APR

  // Minimum amount to stake
  uint256 public minStake = 10 * 1e18;

  // Mapping of address to Staker info
  mapping(address => Staker) internal stakers;

  constructor(address _tokenAddress) {
    tokenAddress = IERC20(_tokenAddress);
  }

  // If address firstly stake, initiate one.
  // If address already stake,calculate unclaimedRewards, reset the last time of
  // deposit and then add _amount to the already deposited amount.
  function deposit(uint256 _amount) external nonReentrant {
    require(_amount >= minStake, 'Amount smaller than minimimum deposit');

    tokenAddress.safeTransferFrom(msg.sender, address(this), _amount);

    if (stakers[msg.sender].deposited == 0) {
      stakers[msg.sender].deposited = _amount;
      stakers[msg.sender].timeOfLastUpdate = block.timestamp;
      stakers[msg.sender].unclaimedRewards = 0;
    } else {
      uint256 rewards = calculateRewards(msg.sender);

      stakers[msg.sender].unclaimedRewards += rewards;
      stakers[msg.sender].deposited += _amount;
      stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    // TODO: Emit a staking event
  }

  // TODO: function stakeRewards() {}

  function claimRewards() external nonReentrant {
    uint256 rewards = calculateRewards(msg.sender) +
      stakers[msg.sender].unclaimedRewards;

    require(rewards > 0, 'You have no rewards');

    stakers[msg.sender].unclaimedRewards = 0;
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;

    tokenAddress.safeTransfer(msg.sender, rewards);

    // TODO: Emit a claim event
  }

  function withdraw(uint256 _amount) external nonReentrant {
    require(
      stakers[msg.sender].deposited >= _amount,
      'Can"t withdraw more than you have'
    );

    uint256 _rewards = calculateRewards(msg.sender);

    stakers[msg.sender].deposited -= _amount;
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    stakers[msg.sender].unclaimedRewards += _rewards;

    tokenAddress.safeTransfer(msg.sender, _amount);

    // TODO: Emit a withdraw event
  }

  function unstake() external nonReentrant {
    require(stakers[msg.sender].deposited > 0, 'You have no deposit');

    uint256 _rewards = calculateRewards(msg.sender) +
      stakers[msg.sender].unclaimedRewards;
    uint256 _deposit = stakers[msg.sender].deposited;

    stakers[msg.sender].deposited = 0;
    stakers[msg.sender].timeOfLastUpdate = 0;
    stakers[msg.sender].unclaimedRewards = 0;

    uint256 _amount = _rewards + _deposit;

    tokenAddress.safeTransfer(msg.sender, _amount);

    // TODO: Emit a unstake event
  }

  function getDepositInfo(address _user)
    public
    view
    returns (uint256 _stake, uint256 _rewards)
  {
    _stake = stakers[_user].deposited;
    _rewards = calculateRewards(_user) + stakers[msg.sender].unclaimedRewards;

    return (_stake, _rewards);
  }

  function calculateRewards(address _staker)
    internal
    view
    returns (uint256 rewards)
  {
    return
      ((block.timestamp - stakers[_staker].timeOfLastUpdate) *
        stakers[_staker].deposited *
        APR) / (365 * 24 * 3600 * 100);
  }
}
