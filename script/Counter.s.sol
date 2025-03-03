// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import "../src/Marketplace.sol";
import "../src/MarketPlaceNftItem.sol";
import "../src/Profile.sol";
import "../src/interfaces/IERC6551Registry.sol";
import {IAccountProxy} from "../src/interfaces/IImplementation.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Deploy marketplace contract
        MarketPlace marketplace = new MarketPlace(payable(msg.sender));
        console.log("Marketplace deployed at:", address(marketplace));

        // Deploy NFT contract
        MarketPlaceItemNft nft = new MarketPlaceItemNft(
            msg.sender,
            "SmartzNFT",
            "SNFT"
        );
        console.log("NFT contract deployed at:", address(nft));

        // Deploy Profile contract
        Profile profile = new Profile(address(marketplace));
        console.log("Profile contract deployed at:", address(profile));

        vm.stopBroadcast();
    }
}
