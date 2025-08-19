// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/********************************************** Madicine ******************************************/
/// @title Madicine
/// @notice
/// @dev
contract Madicine {

    /// @notice
    address Owner;

    enum madicineStatus {
        atcreator,
        picked4W,
        picked4D,
        deliveredatW,
        deliveredatD,
        picked4P,
        deliveredatP
    }

    // address batchid;
    bytes32 description;
    /// @notice
    bytes32 rawmatriales;
    /// @notice
    uint quantity;
    /// @notice
    address shipper;
    /// @notice
    address manufacturer;
    /// @notice
    address wholesaler;
    /// @notice
    address distributer;
    /// @notice
    address pharma;
    /// @notice
    madicineStatus status;

    event ShippmentUpdate(
        address indexed BatchID,
        address indexed Shipper,
        address indexed Receiver,
        uint TransporterType,
        uint Status
    );

    /// @notice
    /// @dev Create new Madicine Batch by Manufacturer
    /// @param Manu Manufacturer Ethereum Network Address
    /// @param Des Description of Madicine Batch
    /// @param RM Raw Materials for Madicine
    /// @param Quant Number of units
    /// @param Shpr Transporter Ethereum Network Address
    /// @param Rcvr Receiver Ethereum Network Address
    /// @param RcvrType Receiver Type either Wholesaler(1) or Distributer(2)
    constructor(
        address Manu,
        bytes32 Des,
        bytes32 RM,
        uint Quant,
        address Shpr,
        address Rcvr,
        uint RcvrType
    ) {
        Owner = Manu;
        manufacturer = Manu;
        description = Des;
        rawmatriales = RM;
        quantity = Quant;
        shipper = Shpr;
        if (RcvrType == 1) {
            wholesaler = Rcvr;
        } else if (RcvrType == 2) {
            distributer = Rcvr;
        }
    }

    /// @notice Get Madicine Batch basic Details
    /// @dev Get Madicine Batch basic Details
    /// @return Manu Manufacturer Ethereum Network Address
    /// @return Des Description of Madicine Batch
    /// @return RM Raw Materials for Madicine
    /// @return Quant Number of units
    /// @return Shpr Transporter Ethereum Network Address
    function getMadicineInfo() public view returns (
        address Manu,
        bytes32 Des,
        bytes32 RM,
        uint Quant,
        address Shpr
    ) {
        return (
            manufacturer,
            description,
            rawmatriales,
            quantity,
            shipper
        );
    }

    /// @notice Get address Wholesaler, Distributer and Pharma
    /// @dev Get address Wholesaler, Distributer and Pharma
    /// @return WDP Address Array
    function getWDP() public view returns (address[3] memory WDP) {
        return (
            [wholesaler, distributer, pharma]
        );
    }

    /// @notice Get Madicine Batch Transaction Status
    /// @dev Get Madicine Batch Transaction Status
    /// @return Status Madicine Transaction Status
    function getBatchIDStatus() public view returns (uint) {
        return uint(status);
    }

    /// @notice Pick Madicine Batch by Associate Transporter
    /// @dev Pick Madicine Batch by Associate Transporter
    /// @param shpr Transporter Ethereum Network Address
    function pickPackage(address shpr) public {
        require(
            shpr == shipper,
            "Only Associate Shipper can call this function"
        );
        require(
            status == madicineStatus(0),
            "Package must be at Supplier."
        );

        if (wholesaler != address(0x0)) {
            status = madicineStatus(1);
            emit ShippmentUpdate(address(this), shipper, wholesaler, 1, 1);
        } else {
            status = madicineStatus(2);
            emit ShippmentUpdate(address(this), shipper, distributer, 1, 1);
        }
    }

    /// @notice Received Madicine Batch by Associated Wholesaler or Distributer
    /// @dev Received Madicine Batch by Associated Wholesaler or Distributer
    /// @param Rcvr Wholesaler or Distributer
    /// @return rcvtype Receiver Type
    function receivedPackage(address Rcvr) public returns (uint rcvtype) {
        require(
            Rcvr == wholesaler || Rcvr == distributer,
            "Only Associate Wholesaler or Distributor can call this function"
        );

        require(
            uint(status) >= 1,
            "Product not picked up yet"
        );

        if (Rcvr == wholesaler && status == madicineStatus(1)) {
            status = madicineStatus(3);
            emit ShippmentUpdate(address(this), shipper, wholesaler, 2, 3);
            return 1;
        } else if (Rcvr == distributer && status == madicineStatus(2)) {
            status = madicineStatus(4);
            emit ShippmentUpdate(address(this), shipper, distributer, 3, 4);
            return 2;
        }
    }

    /// @notice Update Madicine Batch transaction Status(Pick) in between Wholesaler and Distributer
    /// @dev Update Madicine Batch transaction Status(Pick) in between Wholesaler and Distributer
    /// @param receiver Distributer Ethereum Network Address
    /// @param sender Wholesaler Ethereum Network Address
    function sendWD(address receiver, address sender) public {
        require(
            wholesaler == sender,
            "This Wholesaler is not Associated."
        );
        distributer = receiver;
        status = madicineStatus(2);
    }

    /// @notice Update Madicine Batch transaction Status(Received) in between Wholesaler and Distributer
    /// @dev Update Madicine Batch transaction Status(Received) in between Wholesaler and Distributer
    /// @param receiver Distributer Ethereum Network Address
    function recievedWD(address receiver) public {
        require(
            distributer == receiver,
            "This Distributor is not Associated."
        );
        status = madicineStatus(4);
    }

    /// @notice Update Madicine Batch transaction Status(Pick) in between Distributer and Pharma
    /// @dev Update Madicine Batch transaction Status(Pick) in between Distributer and Pharma
    /// @param receiver Pharma Ethereum Network Address
    /// @param sender Distributer Ethereum Network Address
    function sendDP(address receiver, address sender) public {
        require(
            distributer == sender,
            "This Distributor is not Associated."
        );
        pharma = receiver;
        status = madicineStatus(5);
    }

    /// @notice Update Madicine Batch transaction Status(Received) in between Distributer and Pharma
    /// @dev Update Madicine Batch transaction Status(Received) in between Distributer and Pharma
    /// @param receiver Pharma Ethereum Network Address
    function recievedDP(address receiver) public {
        require(
            pharma == receiver,
            "This Pharma is not Associated."
        );
        status = madicineStatus(6);
    }
}