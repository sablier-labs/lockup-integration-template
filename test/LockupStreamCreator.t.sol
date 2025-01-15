// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Test } from "forge-std/src/Test.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";

import { LockupStreamCreator } from "../src/LockupStreamCreator.sol";

contract LockupStreamCreatorTest is Test {
    // Get the latest deployment address from the docs: https://docs.sablier.com/guides/lockup/deployments
    address internal constant LOCKUP_ADDRESS = address(0xC2Da366fD67423b500cDF4712BdB41d0995b0794);

    // Test contracts
    LockupStreamCreator internal creator;
    ISablierLockup internal lockup;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet
        vm.createSelectFork({ blockNumber: 7_499_730, urlOrAlias: "sepolia" });

        // Load the lockup contract from Ethereum Sepolia
        lockup = ISablierLockup(LOCKUP_ADDRESS);

        // Deploy the stream creator contract
        creator = new LockupStreamCreator(lockup);

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user, which will be pulled by the creator contract. Make sure its more than
        // unlockAmounts.start + unlockAmounts.cliff
        deal({ token: address(creator.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });

        // Approve the creator contract to pull DAI tokens from the test user
        creator.DAI().approve({ spender: address(creator), value: 1337e18 });
    }

    function test_CreateLockupLinearStream() public {
        uint256 expectedStreamId = lockup.nextStreamId();
        uint256 actualStreamId = creator.createLinearStream(1337e18);

        // Check that creating linear stream works by checking the stream id
        assertEq(actualStreamId, expectedStreamId);
    }
}
