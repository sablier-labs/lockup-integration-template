// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18 } from "@prb/math/src/UD60x18.sol";
import { ISablierLockup } from "@sablier/lockup/src/interfaces/ISablierLockup.sol";
import { Broker, Lockup, LockupLinear } from "@sablier/lockup/src/types/DataTypes.sol";

/// @title LockupStreamCreator
/// @dev This contract allows users to create Sablier lockup streams using the Lockup contract.
contract LockupStreamCreator {
    IERC20 public constant DAI = IERC20(0x68194a729C2450ad26072b3D33ADaCbcef39D574);

    // Get the latest deployment address from the docs: https://docs.sablier.com/guides/lockup/deployments
    ISablierLockup public constant LOCKUP = ISablierLockup(0xC2Da366fD67423b500cDF4712BdB41d0995b0794);

    /// @dev Before calling this function, the user must first approve this contract to spend the tokens from the user's
    /// address.
    function createLinearStream(uint256 totalAmount) external returns (uint256 streamId) {
        // Transfer the provided amount of DAI tokens to this contract
        DAI.transferFrom(msg.sender, address(this), totalAmount);

        // Approve the Lockup contract to spend DAI
        DAI.approve(address(LOCKUP), totalAmount);

        // Declare the params struct
        Lockup.CreateWithDurations memory params;

        // Declare the umlockAmounts and durations structs
        LockupLinear.UnlockAmounts memory unlockAmounts = LockupLinear.UnlockAmounts({
            start: 1e18, // The amount to unlock at the start of the stream.
            cliff: 10e18 // The amount to unlock after cliff period.
         });
        LockupLinear.Durations memory durations = LockupLinear.Durations({
            cliff: 4 weeks, // Cliff tokens will be unlocked after 4 weeks
            total: 52 weeks // Setting a total duration of ~1 year
         });

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = address(0xcafe); // The recipient of the streamed tokens
        params.totalAmount = uint128(totalAmount); // Total amount includes unlock amounts as well as the fees, if any
        params.token = DAI; // The streaming token
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not
        params.shape = "cliff linear"; // Optional parameter for the shape of the stream
        params.broker = Broker(address(0), ud60x18(0)); // Optional parameter for charging a fee

        // Create the lockup linear stream using a function that sets the start time to `block.timestamp`
        streamId = LOCKUP.createWithDurationsLL(params, unlockAmounts, durations);
    }
}
