// SPDX-License-Identifier: MIT

pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./win.sol";


contract MVPStake is ERC20("MVPS1 Stake", "ST-MVPS1") {
    using SafeMath for uint256;
    IERC20 public mvp;
    Win mvpp;

    uint256 public startDate = 1627948800;  //  Tuesday, August 3, 2021 7:00:00 AM GMT+07:00
    // uint256 public startDate = 1627443691;  // for test only
    uint256 public endDate = 1628812800;    // Friday, August 13, 2021 7:00:00 AM GMT+07:00
            
    uint256 private constant PRECISION = 1e18;

    constructor(IERC20 _mvp, Win _mvpp) public {
        mvp = _mvp;
        mvpp = _mvpp;
    }

    function currentTime() virtual internal view returns (uint256) {
        return now;
    }

    function calculateRewardPoint(uint256 _amount) internal view returns (uint256) {  
        uint256 reduceRatio = (currentTime() - startDate).mul(PRECISION * 2).div(1000 days);
        uint256 rewardRatio = PRECISION.div(20).sub(reduceRatio);        
        return _amount.mul(rewardRatio).div(PRECISION);
    }

    function enter(uint256 _amount) public {
        require(currentTime() >= startDate, "ERC20: Too soon");
        require(currentTime() <= endDate, "ERC20: Too late");

        uint256 totalMVP = mvp.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalMVP == 0) {
            _mint(msg.sender, _amount);
        } 
        else {
            uint256 what = _amount.mul(totalShares).div(totalMVP);
            _mint(msg.sender, what);
        }
        mvpp.mint(msg.sender, calculateRewardPoint(_amount));
        mvp.transferFrom(msg.sender, address(this), _amount);
    }

    function leave(uint256 _share) public {
        require(currentTime() >= endDate, "ERC20: Unlock on August 13, 2021 12:00:00 AM GMT+07:00");
        uint256 totalMVP = mvp.balanceOf(address(this));
        uint256 totalShares = totalSupply();        
        uint256 what = _share.mul(totalMVP).div(totalShares);
        _burn(msg.sender, _share);
        mvp.transfer(msg.sender, what);
    }
}