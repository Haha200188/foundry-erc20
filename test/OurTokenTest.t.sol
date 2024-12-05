//SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test, ZkSyncChainChecker {
    uint256 BOB_STATING_AMOUNT = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    OurToken public ourToken;
    DeployOurToken public deploer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeployOurToken();
        if (!isZkSyncChain()) {
            ourToken = deploer.run();
        } else {
            ourToken = new OurToken(INITIAL_SUPPLY);
            ourToken.transfer(msg.sender, INITIAL_SUPPLY);
        }

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        vm.prank(msg.sender);
        ourToken.transfer(bob, BOB_STATING_AMOUNT);
    }

    function testInitialSupply() public view {
        assertEq(ourToken.totalSupply(), deploer.INITIAL_SUPPLY());
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testAllowance() public {
        uint256 initialAllowance = 1000;
        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STATING_AMOUNT - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmountd);
    }
}
