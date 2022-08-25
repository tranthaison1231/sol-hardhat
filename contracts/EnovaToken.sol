// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';

contract EnouvaToken is ERC20, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
  bytes32 public constant BUNNER_ROLE = keccak256('BUNNER_ROLE');

  constructor(uint256 initialSupply, address[] memory minters, address[] memory burners) ERC20('ENOUVA', 'ENV') {
    _mint(msg.sender, initialSupply);

    for (uint256 i = 0; i < minters.length; ++i) {
      _setupRole(MINTER_ROLE, minters[i]);
    }

    for (uint256 i = 0; i < burners.length; ++i) {
      _setupRole(BUNNER_ROLE, minters[i]);
    }

  }

  function mint(address to, uint256 amount) public {
    // Only minters can mint
    require(hasRole(MINTER_ROLE, msg.sender), 'DOES_NOT_HAVE_MINTER_ROLE');

    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public {
    // Only burners can burn
    require(hasRole(BUNNER_ROLE, msg.sender), 'DOES_NOT_HAVE_BURNER_ROLE');

    _burn(from, amount);
  }
}
