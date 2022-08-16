// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import './GLDToken.sol';

// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import '@openzeppelin/contracts/access/Ownable.sol';

contract Vendor is Ownable {
  // Our Token Contract
  GLDToken token;

  // token price for ETH
  uint256 public tokensPerEth = 100;

  // Event that log buy operation
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    token = GLDToken(tokenAddress);
  }

  /**
   * @notice Allow users to buy token for ETH
   */
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, 'Send ETH to buy some tokens');

    uint256 amountToBuy = msg.value * tokensPerEth;

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = token.balanceOf(address(this));
    require(
      vendorBalance >= amountToBuy,
      'Vendor contract has not enough tokens in its balance'
    );

    // Transfer token to the msg.sender
    bool sent = token.transfer(msg.sender, amountToBuy);
    require(sent, 'Failed to transfer token to user');

    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  /**
   * @notice Allow the owner of the contract to withdraw ETH
   */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, 'Owner has not balance to withdraw');

    (bool sent, ) = msg.sender.call{ value: address(this).balance }('');
    require(sent, 'Failed to send user balance back to the owner');
  }
}
