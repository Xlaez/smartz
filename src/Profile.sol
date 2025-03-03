// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

// import "./interfaces/IERC6551Registry.sol";

import {IAccountProxy} from "./interfaces/IImplementation.sol";

contract Profile is EIP712 {
    IAccountProxy public iAccountProxy;
    uint16 public creatorIdCount;
    uint16 public collectorIdCount;

    struct CreatorProfileDetails {
        string username;
        string img;
        string accountType;
        uint16 id;
        address owner;
        uint256 createdAt;
        uint256 totalCreatedNfts;
        uint256 totalSoldNfts;
    }

    struct CollectorProfileDetails {
        string username;
        string img;
        string accountType;
        uint16 id;
        address owner;
        uint256 createdAt;
        uint256 totalOwnedNfts;
    }

    mapping(address => bool) public isCreator;
    mapping(address => bool) public isCollector;
    mapping(uint16 => CreatorProfileDetails) public allCreatorProfiles;
    mapping(uint16 => CollectorProfileDetails) public allCollectorProfiles;

    event CollectorProfileCreated(address indexed collector);
    event CreatorProfileCreated(address indexed creator);
    event CollectorProfileUpdated(address indexed collector);
    event CreatorProfileUpdated(address indexed creator);

    constructor(address _accountProxy) EIP712("Profile", "1") {
        iAccountProxy = IAccountProxy(_accountProxy);
        collectorIdCount = 0;
        creatorIdCount = 0;
    }

    function onboardCreator(address creator, string memory username, string memory img)
        public
        returns (string memory _name, uint16 _id)
    {
        require(creator == msg.sender, "Not Authorized");
        require(isCreator[creator] == false, "Cannot onboard the same creator twice");
        creatorIdCount += 1;

        _name = username;

        _id = creatorIdCount;

        CreatorProfileDetails memory profileDetails =
            CreatorProfileDetails(_name, img, "creator", creatorIdCount, msg.sender, block.timestamp, 0, 0);

        allCreatorProfiles[creatorIdCount] = profileDetails;
        isCreator[creator] = true;
        emit CreatorProfileCreated(creator);
    }

    function onboardCollector(address collector, string memory username, string memory img)
        public
        returns (string memory _name, uint16 _id)
    {
        require(collector == msg.sender, "Not Authorized");

        require(isCollector[collector] == false, "Cannot onboard the same collector twice");
        collectorIdCount += 1;

        _name = username;
        _id = collectorIdCount;

        CollectorProfileDetails memory profileDetails =
            CollectorProfileDetails(_name, img, "collector", collectorIdCount, msg.sender, block.timestamp, 0);

        allCollectorProfiles[collectorIdCount] = profileDetails;
        isCollector[collector] = true;
        emit CollectorProfileCreated(collector);
    }

    function fetchCreatorProfile(uint16 _id) public view returns (CreatorProfileDetails memory) {
        require(_id > 0 && _id <= creatorIdCount, "Creator profile not found");
        return allCreatorProfiles[_id];
    }

    function fetchCollectorProfile(uint16 _id) public view returns (CollectorProfileDetails memory) {
        require(_id > 0 && _id <= collectorIdCount, "Collector profile not found");
        return allCollectorProfiles[_id];
    }

    function updateCollectorProfile(string memory _img, uint16 _id) public {
        require(isCollector[msg.sender], "Not a registered collector");

        CollectorProfileDetails storage profile = allCollectorProfiles[_id];

        require(profile.owner == msg.sender, "Not authorized");

        profile.img = _img;

        emit CollectorProfileUpdated(msg.sender);
    }

    function updateCreatorProfile(string memory _img, uint16 _id) public {
        require(isCreator[msg.sender], "Not a registered creator");

        CreatorProfileDetails storage profile = allCreatorProfiles[_id];

        require(profile.owner == msg.sender, "Not authorized");

        profile.img = _img;

        emit CreatorProfileUpdated(msg.sender);
    }

    function fetchAllCreators() public view returns (CreatorProfileDetails[] memory) {
        CreatorProfileDetails[] memory profiles = new CreatorProfileDetails[](creatorIdCount);

        for (uint16 i = 1; i <= creatorIdCount; i++) {
            profiles[i - 1] = allCreatorProfiles[i];
        }

        return profiles;
    }
}
