// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";
import "../src/MarketPlaceNftItem.sol";
import "./MockNft.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MarketPlaceTest is Test {
    MarketPlace marketPlace;
    MockNFT nft;

    address owner;
    address seller;
    address buyer;

    uint256 listingPrice = 0.01 ether;
    uint256 nftPrice = 1 ether;

    function setUp() public {
        owner = address(this);
        seller = vm.addr(1);
        buyer = vm.addr(2);

        marketPlace = new MarketPlace(payable(owner));

        nft = new MockNFT();

        nft.mint(seller, 1);
    }

    function testListItemForSale() public {
        vm.prank(seller);

        string memory tokenURI = "https://example.com/token/1";

        marketPlace.listItemForSale(
            "Test NFT",
            nftPrice,
            tokenURI,
            "Test NFT description",
            1
        );

        vm.stopPrank();

        (
            uint256 itemId,
            address nftContract,
            string memory name,
            uint16 creatorId,
            bool isForSale,
            uint256 price,
            uint256 tokenId,
            address payable itemSeller,
            string memory description,
            uint256 createdAt
        ) = marketPlace.idToMarketPlaceItem(1);

        assertEq(itemId, 1);
        assertEq(nftContract, address(marketPlace));
        assertEq(name, "Test NFT");
        assertEq(price, nftPrice);
        assertTrue(isForSale);
        assertEq(itemSeller, seller);
    }

    function testFetchMarketItems() public {
        // First list an item
        vm.startPrank(seller);

        string memory tokenURI = "https://example.com/token/1";

        marketPlace.listItemForSale(
            "Test NFT",
            nftPrice,
            tokenURI,
            "Test NFT Description",
            1
        );

        vm.stopPrank();

        // Fetch all market items
        MarketPlace.MarketPlaceItem[] memory items = marketPlace
            .fetchMarketItems();

        // Verify results
        assertEq(items.length, 1);
        assertEq(items[0].itemId, 1);
        assertEq(items[0].name, "Test NFT");
    }

    function testFetchMarketItem() public {
        // First list an item
        vm.startPrank(seller);

        marketPlace.listItemForSale(
            "Test NFT",
            nftPrice,
            "https://example.com/token/1",
            "Test NFT Description",
            1
        );

        vm.stopPrank();

        // Fetch the specific market item
        MarketPlace.MarketPlaceItem memory item = marketPlace.fetchMarketItem(
            1
        );

        // Verify results
        assertEq(item.itemId, 1);
        assertEq(item.nftContract, address(marketPlace));
        assertEq(item.name, "Test NFT");
        assertEq(item.price, nftPrice);
        assertTrue(item.isForSale);
        assertEq(item.seller, seller);
    }

    function testFetchMarketItemInvalidId() public {
        // Try to fetch a non-existent item
        vm.expectRevert("NFT not found");
        marketPlace.fetchMarketItem(999);
    }

    function testFetchMarketItemZeroId() public {
        // Try to fetch with ID 0 which should be invalid
        vm.expectRevert("NFT not found");
        marketPlace.fetchMarketItem(0);
    }
}
