// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/Profile.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IAccountProxy} from "../src/interfaces/IImplementation.sol";

contract ProfileTest is Test {
    Profile profile;
    address public creator;
    address public collector;
    IAccountProxy public mockAccountProxy;

    function setUp() public {
        string memory url = vm.rpcUrl("edu_chain");
        uint forkId = vm.createFork(url);

        vm.selectFork(forkId);

        mockAccountProxy = IAccountProxy(
            0x55266d75D1a14E4572138116aF39863Ed6596E7F
        );

        profile = new Profile(address(mockAccountProxy));

        creator = vm.addr(1);
        collector = vm.addr(2);
    }

    function testOnboardCreator() public {
        // Impersonate the creator to test `onboardCreator`
        vm.startPrank(creator);

        string memory username = "utee";
        string memory _img = "https://example.com/mypics.png";

        (string memory name, uint16 id) = profile.onboardCreator(
            creator,
            username,
            _img
        );

        assertEq(name, username, "Username should match");

        Profile.CreatorProfileDetails memory creatorProfile = profile
            .fetchCreatorProfile(id);

        assertEq(creatorProfile.img, _img, "Image should match");

        assertEq(
            creatorProfile.accountType,
            "creator",
            "Account Type should be 'creator'"
        );

        vm.stopPrank();
    }

    function testOnboardCollector() public {
        // Impersonate the collector to test `onboardCollector`

        vm.startPrank(collector);

        string memory username = "akan";
        string memory _img = "https://example.com/mypics.png";

        (string memory name, uint16 id) = profile.onboardCollector(
            collector,
            username,
            _img
        );

        assertEq(name, username, "Username should match");

        Profile.CollectorProfileDetails memory collectorProfile = profile
            .fetchCollectorProfile(id);

        assertEq(collectorProfile.img, _img, "image should match");

        assertEq(
            collectorProfile.accountType,
            "collector",
            "Account Type should be 'collector' "
        );
    }

    function testUpdateCreatorProfile() public {
        vm.startPrank(creator);

        string memory _username = "uteee";
        string memory _img = "https://example.com/img.jpeg";

        string memory _updated_img = "https://example.com/img2.jpeg";

        (string memory name, uint16 id) = profile.onboardCreator(
            creator,
            _username,
            _img
        );

        profile.updateCreatorProfile(_updated_img, id);

        Profile.CreatorProfileDetails memory updatedProfile = profile
            .fetchCreatorProfile(id);

        assertEq(_updated_img, updatedProfile.img, "Image should be updated");
        assertEq(
            _username,
            updatedProfile.username,
            "Username should not change"
        );

        vm.stopPrank();
    }

    function testUpdateCollectorProfile() public {
        vm.startPrank(collector);

        string memory _username = "akann";
        string memory _img = "https://example.com/img.jpeg";

        string memory _updated_img = "https://example.com/img2.jpeg";

        (string memory name, uint16 id) = profile.onboardCollector(
            collector,
            _username,
            _img
        );

        profile.updateCollectorProfile(_updated_img, id);

        Profile.CollectorProfileDetails memory updatedProfile = profile
            .fetchCollectorProfile(id);

        assertEq(_updated_img, updatedProfile.img, "Image should be updated");
        assertEq(
            _username,
            updatedProfile.username,
            "Username should not change"
        );

        vm.stopPrank();
    }

    function testFetchAllCreatorProfiles() public {
        // Onboard multiple creators

        address secondCreator = vm.addr(3);

        vm.startPrank(creator);

        (string memory name1, uint16 id1) = profile.onboardCreator(
            creator,
            "tee",
            "https://example.com/img2.png"
        );
        vm.stopPrank();

        vm.startPrank(secondCreator);

        (string memory name2, uint16 id2) = profile.onboardCreator(
            secondCreator,
            "teee",
            "https://example.com/img3.jpg"
        );

        vm.stopPrank();

        Profile.CreatorProfileDetails memory creatorProfile1 = profile
            .fetchCreatorProfile(id1);
        Profile.CreatorProfileDetails memory creatorProfile2 = profile
            .fetchCreatorProfile(id2);

        assertEq(
            creatorProfile1.username,
            name1,
            "First creator's name should match"
        );
        assertEq(
            creatorProfile2.username,
            name2,
            "Second creator's name should match"
        );
    }
}
