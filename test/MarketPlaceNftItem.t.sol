// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {MarketPlaceItemNft} from "../src/MarketPlaceNftItem.sol";

contract MarketPlaceItemNftTest is Test {
    MarketPlaceItemNft private nft;
    address private owner = address(1);
    address private user = address(2); // Another user

    function setUp() public {
        // Deploy the Nft contract with the initial owner
        vm.prank(owner);
        nft = new MarketPlaceItemNft(owner, "MarketPlaceNFT", "MPN");
        assertEq(nft.owner(), owner);
        vm.stopPrank();
    }

    function testInitialMinting() public {
        assertEq(nft.ownerOf(0), owner);
        assertEq(nft.balanceOf(owner), 1);
    }

    function testSafeMint() public {
        // Prank the owner to print a new token for the user
        vm.prank(owner);
        nft.safeMint(owner);

        assertEq(nft.ownerOf(1), owner);
        assertEq(nft.balanceOf(owner), 2);
        vm.stopPrank();
    }

    function testNonOwnerCannotMint() public {
        // Non-owner tries to mint a token - should revert
        vm.prank(user);
        vm.expectRevert();
        nft.safeMint(user);
        assertEq(nft.balanceOf(user), 0);
        vm.stopPrank();
    }
}
