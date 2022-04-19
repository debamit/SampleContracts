// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.12;

import {ERC20} from "solmate/tokens/ERC20.sol";
import "forge-std/console.sol";

contract Amm {
    ERC20 public token0;
    ERC20 public token1;
    uint256 public totalSupply;

    uint256 reserve0;
    uint256 reserve1;

    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
    }

    error TokenAmountCannotBeZero();
    error TokenAmountsNotValid();

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function addLiquidity(uint256 _token0Amount, uint256 _token1Amount) public {
        console.log("before transfer");
        token0.transferFrom(msg.sender, address(this), _token0Amount);
        token1.transferFrom(msg.sender, address(this), _token1Amount);

        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        uint256 d0 = bal0 - reserve0;
        uint256 d1 = bal1 - reserve1;

        /* 
        How much token0, token1 to add?
        xy = k 
         (x + dx ) * (y + dy)  = k

         Since adding liquidity should not cause any change in price
         x / y = (x + dx) / (y + dy)
         x(y + dy) = y(x + dx)
         xy + x*dy = yx + y*dx
         xdy = yx  - xy  + y*dx
         xdy = ydx  <<<< Require this condition to be meet to add liquidity
         */
        if (reserve0 > 0 || reserve1 > 0) {
            if (reserve0 * d1 != reserve1 * d0) revert TokenAmountsNotValid();
        }

        /*
        How much shares to mint?

        f(x, y) = value of liquidity
        We will define f(x, y) = sqrt(xy)

        L0 = f(x, y)
        L1 = f(x + dx, y + dy)
        T = total shares
        s = shares to mint

        Total shares should increase proportional to increase in liquidity
        L1 / L0 = (T + s) / T

        L1 * T = L0 * (T + s)

        (L1 - L0) * T / L0 = s 
        */
        uint256 shares = 0;

        if (totalSupply > 0) {
            shares = _min(
                (d0 * totalSupply) / reserve0,
                (d1 * totalSupply) / reserve1
            );
        } else {
            shares = _sqrt(d0 * d1);
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _update(bal0, bal1);
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }

    function getReserves() public returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    // function swap(
    //     address _fromToken,
    //     uint256 _amountInputToken,
    //     address _toToken
    // ) public returns (uint256) {
    //     return 42;
    // }
}
