// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {OurToken} from "src/OurToken.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";

contract FundMeTest is Test {
    OurToken ourToken;
    DeployOurToken deployOurToken;

    address steph = makeAddr("steph");
    address dera = makeAddr("dera");
    address john = makeAddr("john");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(msg.sender);
        ourToken.transfer(steph, STARTING_BALANCE);
    }

    function testStephBalance() public {
        assert(STARTING_BALANCE == ourToken.balanceOf(steph));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        vm.prank(steph);
        ourToken.approve(dera, initialAllowance);

        uint256 smallAllowance = 500;

        vm.prank(dera);
        ourToken.transferFrom(steph, dera, smallAllowance);

        assertEq(ourToken.balanceOf(steph), STARTING_BALANCE - smallAllowance);
        assertEq(ourToken.balanceOf(dera), smallAllowance);
    }

    function testTransfer() public {
        uint256 transferAmount = 10 ether;

        vm.prank(steph);
        ourToken.transfer(dera, transferAmount);

        assertEq(ourToken.balanceOf(steph), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(dera), transferAmount);
    }

    function testTransferInsufficientBalance() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether;

        vm.prank(steph);
        vm.expectRevert();
        ourToken.transfer(dera, transferAmount);
    }

    function testTransferFromExceedsAllowance() public {
        uint256 initialAllowance = 500;
        uint256 transferAmount = 600;

        vm.prank(steph);
        ourToken.approve(dera, initialAllowance);

        vm.prank(dera);
        vm.expectRevert();
        ourToken.transferFrom(steph, dera, transferAmount);
    }

    function testMintFunction() public {
        uint256 mintAmount = 50 ether;

        // Ensure only the deployer can mint
        vm.prank(steph);
        vm.expectRevert();
        ourToken.mint(steph, mintAmount);

        // Mint tokens as the deployer
        vm.prank(msg.sender);
        ourToken.mint(john, mintAmount);

        assertEq(ourToken.balanceOf(john), mintAmount);
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }
}
