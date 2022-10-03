pragma solidity 0.8.15;
pragma abicoder v2;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import "./Interfaces/IEthVault.sol";
import "./Interfaces/IStableVault.sol";
import "./Interfaces/ILbPool.sol";

contract LBPool is ReentrancyGuard, Pausable, ILBPool {
    //variables
    address private owner;
    address private ethPool;
    address private stablePool;

    //constants
    address private constant usdt = 0x1;
    address private constant usdc = 0x2;
    address private constant dai = 0x3;

    enum tokenType {
        eth,
        usdt,
        usdc,
        dai
    }

    //events
    event Deposit(address, uint256, address); //sender , amount, token
    event Withdraw(address, uint256, address); //to , amount, token
    event UpdatePool(string, address); //pool name, pool address
    event FeeClaimed(address, uint256); //if user claim fee

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    function pauseContract() external onlyOwner {
        if (!paused()) _pause();
    }

    function unPauseContract() external onlyOwner {
        if (paused()) _unpause();
    }

    function initPool(address poolAddress, tokenType) external onlyOwner {
        require(poolAddress != address(0), "invalid Address");
        if (tokenType == 0) {
            ethPool = poolAddress;
            emit UpdatePool(EthPool, poolAddress);
        } else {
            stablePool = poolAddress;
            emit UpdatePool(StablePool, poolAddress);
        }
    }

    function deposit(
        uint256 amount,
        tokenType
    ) external payable whenNotPaused nonReentrant {
        if (tokenType == 0) {
            require(msg.value != 0 && msg.value >= amount, "0 ETH");
            IEthValut(ethPool).deposit.call{value: msg.value}(
                msg.sender,
                amount
            );
            // IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        } else if (tokenType == 1) {
            _deposit(msg.sender, amount, usdt);
        } else if (tokenType == 2) {
            _deposit(msg.sender, amount, usdc);
        } else if (tokenType == 3) {
            _deposit(msg.sender, amount, dai);
        } else {
            revert("Invalid Selection");
        }
    }

    function _deposit(
        address from,
        uint256 amount,
        address asset
    ) internal {
        require(asset != address(0) && amount >= 0, "invalid input");
        IStableVault(stablePool).deposit(from, amount, asset);
        emit Deposit(from, amount, asset);
    }

    function withdraw(
        uint256 amount,
        tokenType,
        bool fee
    ) external whenNotPaused nonReentrant {
      //  require(to != address(0), "Invalid Address");
        if (tokenType == 0) {
            _withdrawEth(amount);
        } else if (tokenType == 1) {
            _withdraw(amount, usdt, fee);
        } else if (tokenType == 2) {
            _withdraw(amount, usdc, fee);
        } else if (tokenType == 3) {
            _withdraw(amount, dai, fee);
        } else {
            revert("Invalid Selection");
        }
    }

    function _withdraw(
        uint256 amount,
        address asset,
        bool fee
    ) internal {
        //can be private
        uint256 amountToWithdraw = amount;
        uint256 userBalance = IStableVault(stablePool).balanceOf(msg.sender);
        require(userBalance >= amount, "Insufficient Balance");
        if (amount == type(uint256).max) {
            amountToWithdraw = userBalance;
        }
        (uint256 _amount) = IStableValut(stablePool).withdraw(
            msg.sender,
            amountToWithdraw,
            asset
        );
        if(fee){
            uint256 feeAmount = (stablePool).claimFee(msg.sender, asset);
            emit FeeClaimed(msg.sender, null);
        }
        emit Withdraw(msg.sender, _amount, feeAmount);
    }

    function _withdrawEth(uint256 amount) internal {
        uint256 amountToWithdraw = amount;
        uint256 userBalance = IEthVault(ethPool).balanceOf(msg.sender);
        require(userBalance >= amount, "Insufficient Balance");
        if (amount == type(uint256).max) {
            amountToWithdraw = userBalance;
        }
        uint256 _amount = IEthValut(ethPool).withdraw(msg.sender, amountToWithdraw);
        emit Withdraw(msg.sender, _amount, asset);
    }

    function borrow() external {

    }

    function repay() external {

    }

    function liquidate() external {

    }

    function flashLoan() external {

    }
}
