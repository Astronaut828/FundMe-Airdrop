// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/FundMe.sol";


contract DeployFundMe is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        
        FundMe fundMe = new FundMe();
        console.log("FundMe contract deployed at address: ", address(fundMe));
        
        vm.stopBroadcast();
    }
}
