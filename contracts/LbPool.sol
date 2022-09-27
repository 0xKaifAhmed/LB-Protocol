pragma solidity 0.8.10;

import {IERC20} from '../../dependencies/openzeppelin/contracts/IERC20.sol';
import {SafeERC20} from '../../dependencies/openzeppelin/contracts/SafeERC20.sol';
import "./ILB.sol";
import "LBToken.sol";


contract LBPool is ILBPool, LBToken {

    //variables
    address public owner;
    bool pause;

    //events
    event ContactPaused(bool);
    event Deposit(address,uint256,address); //sender , amount, token
    event Withdraw(address,uint256,address); //to , amount, token

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    modifier whenNotPaused() {
        require(!pause , "Contract is paused");
        _;
    }

    function pauseContract() external onlyOwner {
        pause = true;
        emit ContactPaused(pause);
    }

    function unPauseContract() external onlyOwner {
        pause = false;
        emit ContactPaused(pause);
    }

    function deposit(address asset, uint256 amount) external whenNotPaused {
        require(asset != 0x0 && amount >= 0 , "invalid input");
    }

    function withdraw() external whenNotPaused {

    }



}