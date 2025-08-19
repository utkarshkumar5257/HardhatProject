// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import './Madicine.sol';

/********************************************** MadicineW_D ******************************************/
/// @title MadicineW_D
/// @notice
/// @dev Sub Contract for Madicine Transaction between Wholesaler and Distributer
contract MadicineW_D {
    /// @notice
    address Owner;

    enum packageStatus { at, picked }

    /// @notice
    address batchid;
    /// @notice
    address sender;
    /// @notice
    address shipper;
    /// @notice
    address receiver;
    /// @notice
    packageStatus status;

    /// @notice
    /// @dev Create SubContract for Madicine Transaction
    /// @param BatchID Madicine BatchID
    /// @param Sender Wholesaler Ethereum Network Address
    /// @param Shipper Transporter Ethereum Network Address
    /// @param Receiver Distributer Ethereum Network Address
    constructor(
        address BatchID,
        address Sender,
        address Shipper,
        address Receiver
    ) {
        Owner = Sender;
        batchid = BatchID;
        sender = Sender;
        shipper = Shipper;
        receiver = Receiver;
        status = packageStatus.at; // Corrected enum assignment
    }

    /// @notice
    /// @dev Pick Madicine Batch by Associated Transporter
    /// @param BatchID Madicine BatchID
    /// @param Shipper Transporter Ethereum Network Address
    function pickWD(
        address BatchID,
        address Shipper
    ) public {
        require(
            Shipper == shipper,
            "Only Associated shipper can call this function."
        );
        status = packageStatus.picked; // Corrected enum assignment

        Madicine(BatchID).sendWD(
            receiver,
            sender
        );
    }

    /// @notice
    /// @dev Received Madicine Batch by Associate Distributer
    /// @param BatchID Madicine BatchID
    /// @param Receiver Distributer Ethereum Network Address
    function recieveWD(
        address BatchID,
        address Receiver
    ) public {
        require(
            Receiver == receiver,
            "Only Associated receiver can call this function."
        );
        status = packageStatus.picked; // Corrected enum assignment

        Madicine(BatchID).recievedWD(Receiver);
    }

    /// @notice
    /// @dev Get Madicine Batch Transaction status in between Wholesaler and Distributer
    /// @return Transaction status
    function getBatchIDStatus() public view returns (uint) {
        return uint(status);
    }
}