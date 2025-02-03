// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Test } from "forge-std/src/Test.sol";

import { LockupStreamCreator } from "../src/LockupStreamCreator.sol";

contract LockupStreamCreatorTest is Test {
    // Test contracts
    LockupStreamCreator internal creator;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet
        vm.createSelectFork({ blockNumber: 7_499_730, urlOrAlias: "sepolia" });

        // Deploy the stream creator contract
        creator = new LockupStreamCreator();

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user, which will be pulled by the creator contract. Make sure its more than
        // `params.totalAmount`.
        deal({ token: address(creator.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });

        // Approve the creator contract to pull DAI tokens from the test user
        creator.DAI().approve({ spender: address(creator), value: 1337e18 });
    }

    function test_CreateLinearStream() public {
        uint256 expectedStreamId = creator.LOCKUP().nextStreamId();
        // Create a linear stream. The amount provided must be more than `unlockAmounts.start + unlockAmounts.cliff`.
        uint256 actualStreamId = creator.createLinearStream(1337e18);

        // Check that creating linear stream works by checking the stream id
        assertEq(actualStreamId, expectedStreamId);
    }
}
