pragma solidity 0.8.15;
pragma abicoder v2;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../LbStorage.sol";

contract StableVault is LbStorage, ERC20 {
    address proxy;

    constructor(address _proxy) ERC20("Stable-LP", "stable-lp") {
        require(_proxy != address(0), "Invalid Address");
        proxy = _proxy;
    }

    modifier onlyContract() {
        require(msg.sender == proxy, "Not Contract");
        _;
    }

    function deposit(
        address _to,
        uint256 _value,
        address _asset
    ) public onlyContract {
        IERC20(_asset).safeTransferFrom(_to, address(this), _value);
        amounts[_to][asset] += _value;
        assetSupply[_asset] += _value;
        _mint(_to, _value);
    }

    function withdraw(
        address _to,
        uint256 _value,
        address _asset
    ) public onlyContract returns (uint256 _amount) {
        (uint256 fee, uint256 userShare) = calculateFeeAndShares(_to, _asset);
        require(userShare != 0, "User Does'nt exists");
        require(_value <= userShare, "Invalid Amount");
        amounts[_to][_asset] -= _value;
        assetSupply[_asset] -= _value;
        _burn(_to, _value);
        IERC20(_asset).safeTransfer(_to, _value);
        _amount = _value;
    }

    function calculateFeeAndShares(address user, address asset)
        internal
        view
        returns (uint256 _fee, uint256 _shares)
    {
        uint256 userShare = amounts[user][asset];
        uint256 multiplier = IERC20(asset).balanceOf(address(this)) -
            assetSupply[asset];
        if (multiplier != 0) {
            _fee = (userShare / assetSupply[asset]) * multiplier;
            _shares = userShare;
        } else {
            _fee = 0;
            _shares = userShare;
        }
    }

    function claimFee(address user, address asset)
        external
        onlyContract
        returns (uint256 fee)
    {
        (fee, ) = calculateFeeAndShares(_to, _asset);
        if (fee != 0) {
            IERC20(asset).safeTransfer(user, fee);
        }
    }
}
