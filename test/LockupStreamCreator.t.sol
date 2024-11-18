// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Test } from "forge-std/src/Test.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { LockupStreamCreator } from "../src/LockupStreamCreator.sol";

contract LockupStreamCreatorTest is Test {
    // Get the latest deployment address from the docs: https://docs.sablier.com/contracts/v2/deployments
    address internal constant LOCKUP_LINEAR_ADDRESS = address(0x3E435560fd0a03ddF70694b35b673C25c65aBB6C);

    // Test contracts
    LockupStreamCreator internal creator;
    ISablierV2LockupLinear internal lockup;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet
        vm.createSelectFork({ blockNumber: 6_239_031, urlOrAlias: "sepolia" });

        // Load the lockup linear contract from Ethereum Sepolia
        lockup = ISablierV2LockupLinear(LOCKUP_LINEAR_ADDRESS);

        // Deploy the stream creator contract
        creator = new LockupStreamCreator(lockup);

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user, which will be pulled by the creator contract
        deal({ token: address(creator.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });

        // Approve the creator contract to pull DAI tokens from the test user
        creator.DAI().approve({ spender: address(creator), value: 1337e18 });
    }

    function test_CreateLockupLinearStream() public {
        uint256 expectedStreamId = lockup.nextStreamId();
        uint256 actualStreamId = creator.createLockupLinearStream(1337e18);

        // Check that creating linear stream works by checking the stream id
        assertEq(actualStreamId, expectedStreamId);
    }
}
