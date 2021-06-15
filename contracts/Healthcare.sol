//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
import "./User.sol";

contract Healthcare {
    address private admin;
    User private user;
    string private userRole;
    uint private medicalRecordId;
    uint private treatmentId;
    uint private randSalt;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
        userRole = user.getUserRole();
        medicalRecordId = 0;
        treatmentId = 0;
        randSalt = 0;
    }

    struct Patient {
        address patientId;
        string name;
        uint age;
        uint dateOfBirth;
        string email;
        string phone;
        string homeAddress;
        string gender;
        address assignedDoctor;
        uint medicalRecordId;
    }
    mapping(address => Patient) public patientList;
    address[] private patientAddresses;

    struct Doctor {
        address doctorId;
        string name;
        string email;
        string phone;
        string assignedHospital;
        string medicalSpeciality;
        address[] assignedPatients;
    }
    mapping(address => Doctor) public doctorList;
    address[] private doctorAddresses;

    struct MedicalRecord {
        uint medicalRecordId;
        string medications;
        string allergies;
        string illnesses;
        string immunizations;
        string bloodType;
        bool hasInsurance;
        uint[] treatmentsIds;
    }
    mapping(uint => MedicalRecord) public medicalRecordList;

    struct Treatment {
        uint treatmentId;
        uint patientId;
        uint doctorId;
        string diagnosis;
        string medicine;
        uint fromDate;
        uint toDate;
        uint bill;
    }
    mapping(uint => Treatment) public treatmentList;

    function createPatient() public {
        require(patientList[msg.sender].patientId == address(0));
        //Set patient address
        patientList[msg.sender].patientId = msg.sender;
        patientAddresses.push(msg.sender);
        //Assign random doctor to the patient
        patientList[msg.sender].assignedDoctor = assignRandomDoctor();
        //Assign patient to the obtained doctor
        doctorList[patientList[msg.sender].assignedDoctor].assignedPatients.push(msg.sender);
        //Get medicalRecordId and create the object
        medicalRecordId += 1;
        createMedicalRecord(medicalRecordId);
        patientList[msg.sender].medicalRecordId = medicalRecordId;
    }

    function readPatient(address patientAddress) public view returns(Patient memory) {
        require(patientList[patientAddress].patientId != address(0));
        return patientList[patientAddress];
    }

    function updatePatient(Patient memory patient, address patientAddress) public {
        require(patientList[patientAddress].patientId != address(0));
        patientList[patientAddress].name = patient.name;
        patientList[patientAddress].age = patient.age;
        patientList[patientAddress].dateOfBirth = patient.dateOfBirth;
        patientList[patientAddress].email = patient.email;
        patientList[patientAddress].phone = patient.phone;
        patientList[patientAddress].homeAddress = patient.homeAddress;
        patientList[patientAddress].gender = patient.gender;
        patientList[patientAddress].assignedDoctor = patient.assignedDoctor;
    }
    
    function createDoctor() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        require(doctorList[msg.sender].doctorId == address(0));
        //Set doctor address
        doctorList[msg.sender].doctorId = msg.sender;
    }

    function readDoctor(address doctorAddress) public view returns(Doctor memory) {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        require(doctorList[doctorAddress].doctorId != address(0));
        return doctorList[doctorAddress];
    }

    function updateDoctor(Doctor memory doctor, address doctorAddress) public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        require(doctorList[doctorAddress].doctorId != address(0));
        doctorList[doctorAddress].name = doctor.name;
        doctorList[doctorAddress].email = doctor.email;
        doctorList[doctorAddress].phone = doctor.phone;
        doctorList[doctorAddress].assignedHospital = doctor.assignedHospital;
        doctorList[doctorAddress].medicalSpeciality = doctor.medicalSpeciality;
        doctorList[doctorAddress].assignedPatients = doctor.assignedPatients;
    }

    function createMedicalRecord(uint _medicalRecordId) public {
        require(medicalRecordList[medicalRecordId].medicalRecordId == 0);
        //Set medicalRecordId
        medicalRecordList[_medicalRecordId].medicalRecordId = _medicalRecordId;
    }

    function readMedicalRecord(address patientAddress) public view returns (MedicalRecord memory) {
        require(patientList[patientAddress].patientId != address(0));
        return medicalRecordList[patientList[patientAddress].medicalRecordId];
    }

    function updateMedicalRecord() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function createTreatment() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function readTreatment() public {

    }

    function updateTreatment() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function assignRandomDoctor() public returns(address) {
        require(doctorAddresses.length >= 1);
        uint randomPosition = randMod(doctorAddresses.length);
        require(doctorList[doctorAddresses[randomPosition]].doctorId != address(0));
        return doctorAddresses[randomPosition];
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function randMod(uint modulus) internal returns(uint) {
        ++randSalt;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randSalt))) % modulus;
    }
}