// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract EVAToken is IERC20 {
  string public name = 'Enouva';
  string public symbol = 'EVA';
  uint256 public decimals = 0;
  uint256 public override totalSupply;

  address public founder;
  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;

  constructor() {
    totalSupply = 1000000;
    founder = msg.sender;
    balances[founder] = totalSupply;
  }

  function balanceOf(address tokenOwner)
    public
    view
    override
    returns (uint256 balance)
  {
    return balances[tokenOwner];
  }

  function transfer(address to, uint256 tokens)
    public
    virtual
    override
    returns (bool success)
  {
    require(balances[msg.sender] >= tokens);

    balances[to] += tokens;
    balances[msg.sender] -= tokens;

    emit Transfer(msg.sender, to, tokens);

    return true;
  }

  function allowance(address tokenOwner, address spender)
    public
    view
    override
    returns (uint256)
  {
    return allowed[tokenOwner][spender];
  }

  function approve(address spender, uint256 tokens)
    public
    override
    returns (bool success)
  {
    require(balances[msg.sender] >= tokens);
    require(tokens > 0);

    allowed[msg.sender][spender] = tokens;

    emit Approval(msg.sender, spender, tokens);

    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokens
  ) public virtual override returns (bool success) {
    require(allowed[from][msg.sender] >= tokens);
    require(balances[from] >= tokens);

    balances[from] -= tokens;
    balances[to] += tokens;
    allowed[from][msg.sender] -= tokens;

    emit Transfer(from, to, tokens);

    return true;
  }
}

contract EVAICO is EVAToken {
  address public admin;
  address payable public deposit;
  uint256 tokenPrice = 0.001 ether; // 1 ETH = 1000 EVA, 1 EVA = 0.001 ETH
  uint256 public hardCap = 400 ether;
  uint256 public raisedAmount;
  uint256 public saleStart = block.timestamp;
  uint256 public saleEnd = block.timestamp + 86400 * 7; // ICO ends in one week
  uint256 public tokenTradeStart = saleEnd + 86400 * 7; // transeferable in a week after sale end
  uint256 public minInvestment = 0.1 ether;
  uint256 public maxInvestment = 10 ether;
  enum State {
    beforeStart,
    running,
    afterEnd,
    halted
  }
  State public icoState;

  constructor(address payable _deposit) {
    deposit = _deposit;
    admin = msg.sender;
    icoState = State.beforeStart;
  }

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function halt() public onlyAdmin {
    icoState = State.halted;
  }

  function resume() public onlyAdmin {
    icoState = State.running;
  }

  function changeDeposit(address payable _newDeposit) public onlyAdmin {
    deposit = _newDeposit;
  }

  function getCurrentState() public view returns (State) {
    if (icoState == State.halted) {
      return State.halted;
    } else if (block.timestamp < saleStart) {
      return State.beforeStart;
    } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
      return State.running;
    } else {
      return State.afterEnd;
    }
  }

  event Invest(address investor, uint256 value, uint256 tokens);

  function invest() public payable returns (bool) {
    icoState = getCurrentState();
    require(icoState == State.running);
    require(msg.value >= minInvestment && msg.value <= maxInvestment);

    raisedAmount += msg.value;
    require(raisedAmount <= hardCap);

    uint256 tokens = msg.value / tokenPrice;
    balances[msg.sender] += tokens;
    balances[founder] -= tokens;

    deposit.transfer(msg.value);

    emit Invest(msg.sender, msg.value, tokens);

    return true;
  }

  receive() external payable {
    invest();
  }

  function transfer(address to, uint256 tokens)
    public
    override
    returns (bool success)
  {
    require(block.timestamp > tokenTradeStart);
    EVAToken.transfer(to, tokens);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokens
  ) public override returns (bool success) {
    require(block.timestamp > tokenTradeStart);
    EVAToken.transferFrom(from, to, tokens);
    return true;
  }

  function burn() public returns (bool) {
    icoState = getCurrentState();
    require(icoState == State.afterEnd);
    balances[founder] = 0;

    return true;
  }
}
