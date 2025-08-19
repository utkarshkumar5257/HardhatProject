// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/********************************************** RawMatrials ******************************************/
/// @title RawMatrials
/// @notice
/// @dev Create new instance of RawMatrials package
contract RawMatrials {
    /// @notice
    address Owner;

    enum packageStatus { atcreator, picked, delivered }

    event ShippmentUpdate(
        address indexed BatchID,
        address indexed Shipper,
        address indexed Manufacturer,
        uint TransporterType,
        uint Status
    );

    /// @notice
    address productid;
    /// @notice
    bytes32 description;
    /// @notice
    bytes32 farmer_name;
    /// @notice
    bytes32 location;
    /// @notice
    uint quantity;
    /// @notice
    address shipper;
    /// @notice
    address manufacturer;
    /// @notice
    address supplier;
    /// @notice
    packageStatus status;
    /// @notice
    bytes32 packageReceiverDescription;

    /// @notice
    /// @dev Intiate New Package of RawMatrials by Supplier
    /// @param Splr Supplier Ethereum Network Address
    /// @param Des Description of RawMatrials
    /// @param FN Farmer Name
    /// @param Loc Farm Location
    /// @param Quant Number of units in a package
    /// @param Shpr Transporter Ethereum Network Address
    /// @param Rcvr Manufacturer Ethereum Network Address
    constructor(
        address Splr,
        bytes32 Des,
        bytes32 FN,
        bytes32 Loc,
        uint Quant,
        address Shpr,
        address Rcvr
    ) {
        Owner = Splr;
        productid = address(this);
        description = Des;
        farmer_name = FN;
        location = Loc;
        quantity = Quant;
        shipper = Shpr;
        manufacturer = Rcvr;
        supplier = Splr;
        status = packageStatus.atcreator;
    }

    /// @notice Get RawMatrials Package Details
    /// @dev Get RawMatrials Package Details
    /// @return Des Description of RawMatrials
    /// @return FN Farmer Name
    /// @return Loc Farm Location
    /// @return Quant Number of units in a package
    /// @return Shpr Transporter Ethereum Network Address
    /// @return Rcvr Manufacturer Ethereum Network Address
    /// @return Splr Supplier Ethereum Network Address
    function getSuppliedRawMatrials() public view returns (
        bytes32 Des,
        bytes32 FN,
        bytes32 Loc,
        uint Quant,
        address Shpr,
        address Rcvr,
        address Splr
    ) {
        return (
            description,
            farmer_name,
            location,
            quantity,
            shipper,
            manufacturer,
            supplier
        );
    }

    /// @notice Get Package Transaction Status
    /// @dev Get Package Transaction Status
    /// @return Status Package Status
    function getRawMatrialsStatus() public view returns (uint) {
        return uint(status);
    }

    /// @notice Pick Package by Associate Transporter
    /// @dev Pick Package by Associate Transporter
    /// @param shpr Transporter Ethereum Network Address
    function pickPackage(address shpr) public {
        require(
            shpr == shipper,
            "Only Associate Shipper can call this function"
        );
        require(
            status == packageStatus.atcreator,
            "Package must be at Supplier."
        );
        status = packageStatus.picked;
        emit ShippmentUpdate(address(this), shipper, manufacturer, 1, 1);
    }

    /// @notice Received Package Status Update By Associated Manufacturer
    /// @dev Received Package Status Update By Associated Manufacturer
    /// @param manu Manufacturer Ethereum Network Address
    function receivedPackage(address manu) public {
        require(
            manu == manufacturer,
            "Only Associate Manufacturer can call this function"
        );

        require(
            status == packageStatus.picked,
            "Product not picked up yet"
        );
        status = packageStatus.delivered;
        emit ShippmentUpdate(address(this), shipper, manufacturer, 1, 2);
    }
}