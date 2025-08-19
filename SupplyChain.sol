// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MedicineSupplyChain {
    enum Roles { NoRole, Manufacturer, Wholesaler, Distributor, Pharma }
    enum SaleStatus { AtManufacturer, AtWholesaler, AtDistributor, AtPharma, Sold }

    struct User {
        string name;
        Roles role;
    }

    struct Medicine {
        string name;
        uint256 mfgDate;
        uint256 expDate;
        address currentOwner;
    }

    mapping(address => User) public UsersDetails;

    // Manufacturer → their created batches
    mapping(address => address[]) public ManufacturedMedicineBatches;

    // Wholesaler → batches they hold
    mapping(address => address[]) public MedicineBatchesAtWholesaler;

    // Distributor → batches they hold
    mapping(address => address[]) public MedicineBatchesAtDistributor;

    // Pharma → batches they hold
    mapping(address => address[]) public MedicineBatchesAtPharma;

    // BatchID → SaleStatus
    mapping(address => SaleStatus) public sale;

    // BatchID → Medicine struct
    mapping(address => Medicine) public Medicines;

    // Events
    event UserRoleAssigned(address indexed user, string name, Roles role);
    event MedicineCreated(address indexed batchId, string name, address indexed manufacturer);
    event MedicineTransferred(address indexed batchId, address indexed from, address indexed to, Roles toRole, SaleStatus status);

    // Register user
    function registerUser(string memory _name, Roles _role) external {
        require(UsersDetails[msg.sender].role == Roles.NoRole, "Already registered");
        UsersDetails[msg.sender] = User(_name, _role);
        emit UserRoleAssigned(msg.sender, _name, _role);
    }

    // Manufacturer creates medicine
    function createMedicine(address batchId, string memory _name, uint256 _mfgDate, uint256 _expDate) external {
        require(UsersDetails[msg.sender].role == Roles.Manufacturer, "Only Manufacturer");
        require(Medicines[batchId].currentOwner == address(0), "Batch already exists");

        Medicines[batchId] = Medicine(_name, _mfgDate, _expDate, msg.sender);
        ManufacturedMedicineBatches[msg.sender].push(batchId);
        sale[batchId] = SaleStatus.AtManufacturer;

        emit MedicineCreated(batchId, _name, msg.sender);
    }

    // Transfer Medicine (Manufacturer → Wholesaler → Distributor → Pharma)
    function transferMedicine(address batchId, address to) external {
        Roles senderRole = UsersDetails[msg.sender].role;
        Roles receiverRole = UsersDetails[to].role;

        require(senderRole != Roles.NoRole, "Sender not registered");
        require(receiverRole != Roles.NoRole, "Receiver not registered");
        require(Medicines[batchId].currentOwner == msg.sender, "Not owner");

        if (senderRole == Roles.Manufacturer && receiverRole == Roles.Wholesaler) {
            MedicineBatchesAtWholesaler[to].push(batchId);
            sale[batchId] = SaleStatus.AtWholesaler;
        } else if (senderRole == Roles.Wholesaler && receiverRole == Roles.Distributor) {
            MedicineBatchesAtDistributor[to].push(batchId);
            sale[batchId] = SaleStatus.AtDistributor;
        } else if (senderRole == Roles.Distributor && receiverRole == Roles.Pharma) {
            MedicineBatchesAtPharma[to].push(batchId);
            sale[batchId] = SaleStatus.AtPharma;
        } else {
            revert("Invalid transfer flow");
        }

        Medicines[batchId].currentOwner = to;
        emit MedicineTransferred(batchId, msg.sender, to, receiverRole, sale[batchId]);
    }

    // Get Pharma batch count
    function getBatchesCountP() external view returns (uint) {
        require(UsersDetails[msg.sender].role == Roles.Pharma, "Only Pharma");
        return MedicineBatchesAtPharma[msg.sender].length;
    }

    // Get batch by index for Pharma
    function getBatchIdByIndexP(uint index) external view returns (address) {
        require(UsersDetails[msg.sender].role == Roles.Pharma, "Only Pharma");
        return MedicineBatchesAtPharma[msg.sender][index];
    }
}
