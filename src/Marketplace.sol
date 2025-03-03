// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MarketPlace is ERC721URIStorage, ReentrancyGuard, IERC721Receiver {
    uint256 private tokenIds;
    uint256 private itemIds;
    uint256 private itemsSold;

    struct MarketPlaceItem {
        uint256 itemId;
        address nftContract;
        string name;
        uint16 creatorId;
        bool isForSale;
        uint256 price;
        uint256 tokenId;
        address payable seller;
        string description;
        uint256 createdAt;
    }

    address payable public owner;

    mapping(uint256 => MarketPlaceItem) public idToMarketPlaceItem;

    /**
     * Events
     */
    event MarketPlaceItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        string name,
        address seller,
        uint256 price,
        uint256 createdAt,
        string description,
        bool isForSale,
        uint16 creatorId
    );

    event MarketPlaceItemSold(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        string name,
        address seller,
        uint256 price,
        uint256 createdAt,
        string description,
        bool isForSale,
        uint16 creatorId
    );

    constructor(address payable marketOwner) ERC721("SmartzNFT", "SNFT") {
        owner = marketOwner;
    }

    // Implement onERC721Received to make the contract capable of receiving ERC721 tokens
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }

    function listItemForSale(
        string memory name,
        uint256 price,
        string memory tokenURI,
        string memory description,
        uint16 creatorId
    ) public payable nonReentrant {
        require(price > 0, "Price must be greater than 0");

        itemIds += 1;
        uint256 itemId = itemIds;

        tokenIds += 1;
        uint256 newTokenId = tokenIds;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        idToMarketPlaceItem[itemId] = MarketPlaceItem(
            itemId,
            address(this),
            name,
            creatorId,
            true,
            price,
            newTokenId,
            payable(msg.sender),
            description,
            block.timestamp
        );

        _transfer(msg.sender, address(this), newTokenId);

        emit MarketPlaceItemCreated(
            itemId, address(this), newTokenId, name, msg.sender, price, block.timestamp, description, true, creatorId
        );
    }

    function fetchMarketItems() public view returns (MarketPlaceItem[] memory) {
        uint256 itemCount = itemIds;
        uint256 unsoldItemsCount = itemIds - itemsSold;
        uint256 currentIndex = 0;

        MarketPlaceItem[] memory items = new MarketPlaceItem[](unsoldItemsCount);

        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketPlaceItem[i + 1].isForSale == true) {
                uint256 currentId = idToMarketPlaceItem[i + 1].itemId;
                MarketPlaceItem storage currentItem = idToMarketPlaceItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex++;
            }
        }

        return items;
    }

    function purchaseItem(uint256 itemId) public payable nonReentrant {
        MarketPlaceItem storage item = idToMarketPlaceItem[itemId];

        require(msg.value >= item.price, "Not enough funds to purchase this NFT");

        require(msg.sender != item.seller, "Seller cannot purchase their own NFT");

        (bool success,) = item.seller.call{value: item.price}("");
        require(success, "Transfer to creator failed");

        _transfer(address(this), msg.sender, item.tokenId);

        item.isForSale = false;

        itemsSold += 1;

        emit MarketPlaceItemSold(
            itemId,
            item.nftContract,
            item.tokenId,
            item.name,
            item.seller,
            item.price,
            block.timestamp,
            item.description,
            item.isForSale,
            item.creatorId
        );
    }

    function fetchMarketItem(uint256 itemId) public view returns (MarketPlaceItem memory) {
        require(itemId > 0 && itemId <= itemIds, "NFT not found");

        return idToMarketPlaceItem[itemId];
    }

    function totalSales() public view returns (uint256) {
        return itemsSold;
    }

    receive() external payable {}
}
