// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract Test_FundMe is Test {
    FundMe public fundMe;

    uint256 private _tokenId;
    address[] private funders;
    mapping(address => bool) private funderExists;
    uint256[] private amountsFunded;

    // Funding addresses
    address fundingAddress1 = address(0x1);
    address fundingAddress2 = address(0x2);
    address fundingAddress3 = address(0x3);
    address fundingAddress4 = address(0x4);

    function setUp() public {
        fundMe = new FundMe();

        // Provide Ether to the funding addresses
        vm.deal(fundingAddress1, 1 ether);
        vm.deal(fundingAddress2, 1 ether);
        vm.deal(fundingAddress3, 1 ether);
        vm.deal(fundingAddress4, 1 ether);

        // Populate the uniqueFunders array with 250 unique addresses for fuzz testing
        for (uint256 i = 0; i < 250; i++) {
            funders.push(address(uint160(i)));
        }
    }

    // receive() function allows test contract to receive Ether after the withdraw function is called
    receive() external payable {}

    // Test fallback function
    function test_fallback() public payable {
        uint256 balanceofContractBefore = address(fundMe).balance;

        (bool success,) = address(fundMe).call{value: 0.05 ether}(abi.encodeWithSignature("SendingETH"));
        require(success, "Sending ether to the contract fallback func.failed");

        uint256 balanceofContractAfter = address(fundMe).balance;
        assertEq(balanceofContractAfter - balanceofContractBefore, 0.05 ether);
    }

    // Test fund function
    function test_fund() public payable {
        uint256 balanceBefore = address(fundMe).balance;

        // simulate funding from different addresses
        vm.prank(fundingAddress1);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress2);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress3);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress4);
        fundMe.fund{value: 0.03 ether}();

        // assert the amount funded by all addresses
        uint256 balanceAfter = address(fundMe).balance;
        assertEq(balanceAfter - balanceBefore, 0.12 ether);
    }

    // Test withdraw function

    function test_withdraw() public {
        // fund the contract
        vm.prank(fundingAddress1);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress2);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress3);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress4);
        fundMe.fund{value: 0.03 ether}();

        // withdraw the funds
        vm.prank(address(this));
        fundMe.withdraw();

        // assert the contract balance is 0
        assertEq(address(fundMe).balance, 0, "Contract balance should be 0");
    }

    function test_withdrawWithAirdrop() public {
        // fund the contract
        vm.prank(fundingAddress1);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress2);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress3);
        fundMe.fund{value: 0.03 ether}();

        vm.prank(fundingAddress4);
        fundMe.fund{value: 0.03 ether}();

        // withdraw the funds
        vm.prank(address(this));
        fundMe.withdrawWithAirdrop();

        // assert the contract balance is 0
        assertEq(address(fundMe).balance, 0, "Contract balance should be 0");

        // URI log for styling
         string memory tokenURI = fundMe.tokenURI(0);
        // console.log(tokenURI);
    }

    // Fuzz test the FundMe contract
    // This test will fund the contract with 250 unique addresses
    function test_FuzzFundMe() public {
        uint256[] memory amounts = new uint256[](funders.length);

        // Populate the amounts array
        for (uint256 i = 0; i < funders.length; i++) {
            amounts[i] = 0.01 ether + i;

            // Ensure each address has enough Ether to fund the contract
            vm.deal(funders[i], amounts[i]);
        }

        // ensure the length of the funders and amounts are the same
        vm.assume(funders.length == amounts.length);

        // fund the contract with the uniqueFunders and amounts
        for (uint256 i = 0; i < funders.length; i++) {
            vm.assume(amounts[i] >= 0.01 ether && amounts[i] <= 10000000 ether);

            // Ensure each address has enough Ether to fund the contract
            vm.deal(funders[i], amounts[i]);

            vm.prank(funders[i]);
            // fund the contract (0.01 ether is added to insure the amount is greater than 0.01 ether)
            fundMe.fund{value: amounts[i]}();
        }
        // assert the amount funded by all addresses
        uint256 balanceAfter = address(fundMe).balance;
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        assertEq(balanceAfter, totalAmount);

        // assert the correct number of unique funders
        assertEq(funders.length, 250);
    }
}
