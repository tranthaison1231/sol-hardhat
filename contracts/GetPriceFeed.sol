//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

contract GetPriceFeed {
  AggregatorV3Interface internal priceFeed;

  constructor() {
    priceFeed = AggregatorV3Interface(
      0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
    );
  }

  function getPrice() public view returns (int256) {
    (, int256 price, , , ) = priceFeed.latestRoundData();
    return price;
  }
}
