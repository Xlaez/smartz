// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import "../src/Marketplace.sol";
import "../src/MarketPlaceNftItem.sol";
import "../src/Profile.sol";
import "../src/interfaces/IERC6551Registry.sol";
import {IAccountProxy} from "../src/interfaces/IImplementation.sol";

contract CounterScript is Script {
    // constructor() {
    //     _transferOwnership(msg.sender);
    // }

    function setUp() public {}

    // function run() public {
    //     string memory privateKeyStr = vm.envString("PRIVATE_KEY");
    //     uint256 privateKey = vm.parseUint(privateKeyStr);

    //     vm.startBroadcast(privateKey);

    //     address deployer = vm.addr(privateKey);

    //     // Deploy marketplace contract
    //     MarketPlace marketplace = new MarketPlace(payable(deployer));
    //     console.log("Marketplace deployed at:", address(marketplace));

    //     console.log("Deploying from:", deployer);
    //     // Deploy NFT contract
    //     MarketPlaceItemNft nft = new MarketPlaceItemNft(
    //         deployer,
    //         "SmartzNFT",
    //         "SNFT"
    //     );
    //     console.log("NFT contract deployed at:", address(nft));

    //     // Deploy Profile contract
    //     Profile profile = new Profile(address(marketplace));
    //     console.log("Profile contract deployed at:", address(profile));

    //     vm.stopBroadcast();
    // }
    function run() public {
        string memory privateKeyStr = vm.envString("PRIVATE_KEY");
        uint256 privateKey = vm.parseUint(privateKeyStr);
        vm.startBroadcast(privateKey);

        address deployer = vm.addr(privateKey);

        // Deploy marketplace contract first
        MarketPlace marketplace = new MarketPlace(payable(deployer));
        console.log("Marketplace deployed at:", address(marketplace));

        vm.stopBroadcast(); // Stop broadcasting transaction

        vm.startBroadcast(privateKey);
        // Deploy NFT contract separately
        MarketPlaceItemNft nft = new MarketPlaceItemNft(
            deployer,
            "SmartzNFT",
            "SNFT"
        );
        console.log("NFT contract deployed at:", address(nft));

        vm.stopBroadcast();

        vm.startBroadcast(privateKey);
        // Deploy Profile contract separately
        Profile profile = new Profile(address(marketplace));
        console.log("Profile contract deployed at:", address(profile));

        vm.stopBroadcast();
    }
}
