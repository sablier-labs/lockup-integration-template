// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18 } from "@prb/math/src/UD60x18.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";

/// @title StreamCreator
/// @dev This contract allows users to create Sablier streams using the Lockup Linear contract.
contract StreamCreator {
    IERC20 public constant DAI = IERC20(0x68194a729C2450ad26072b3D33ADaCbcef39D574);
    ISablierV2LockupLinear public immutable SABLIER;

    constructor(ISablierV2LockupLinear sablier) {
        SABLIER = sablier;
    }

    /// @dev Before calling this function, the user must first approve this contract to spend the tokens from the user's
    /// address.
    function createLockupLinearStream(uint256 totalAmount) external returns (uint256 streamId) {
        // Transfer the provided amount of DAI tokens to this contract
        DAI.transferFrom(msg.sender, address(this), totalAmount);

        // Approve the Sablier contract to spend DAI
        DAI.approve(address(SABLIER), totalAmount);

        // Declare the params struct
        LockupLinear.CreateWithDurations memory params;

        // Declare the function parameters
        params.sender = msg.sender; // The sender will be able to cancel the stream
        params.recipient = address(0xcafe); // The recipient of the streamed assets
        params.totalAmount = uint128(totalAmount); // Total amount is the amount inclusive of all fees
        params.asset = DAI; // The streaming asset
        params.cancelable = true; // Whether the stream will be cancelable or not
        params.transferable = true; // Whether the stream will be transferable or not
        params.durations = LockupLinear.Durations({
            cliff: 4 weeks, // Assets will be unlocked only after 4 weeks
            total: 52 weeks // Setting a total duration of ~1 year
         });
        params.broker = Broker(address(0), ud60x18(0)); // Optional parameter for charging a fee

        // Create the Sablier stream using a function that sets the start time to `block.timestamp`
        streamId = SABLIER.createWithDurations(params);
    }
}
