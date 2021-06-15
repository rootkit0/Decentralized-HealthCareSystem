//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
import "./User.sol";

contract Healthcare {
    address private admin;
    User private user;
    string private userRole;
    uint private medicalRecordId;
    uint private treatmentId;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
        userRole = user.getUserRole();
        medicalRecordId = 0;
        treatmentId = 0;
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
        uint assignedDoctor;
        uint medicalRecordId;
    }
    mapping(address => Patient) public patientList;

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

    struct MedicalRecord {
        uint medicalRecordId;
        string medications;
        string allergies;
        string illnesses;
        string immunizations;
        string bloodType;
        bool hasInsurance;
        Treatment[] treatments;
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

    function createPatient(Patient memory patient) public {
        patientList[msg.sender].patientId = msg.sender;
        patientList[msg.sender].name = patient.name;
        patientList[msg.sender].age = patient.age;
        patientList[msg.sender].dateOfBirth = patient.dateOfBirth;
        patientList[msg.sender].email = patient.email;
        patientList[msg.sender].phone = patient.phone;
        patientList[msg.sender].homeAddress = patient.homeAddress;
        patientList[msg.sender].gender = patient.gender;
        patientList[msg.sender].assignedDoctor = patient.assignedDoctor;
        medicalRecordId += 1;
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
    
    function createDoctor(Doctor memory doctor) public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        doctorList[msg.sender].doctorId = msg.sender;
        doctorList[msg.sender].name = doctor.name;
        doctorList[msg.sender].email = doctor.email;
        doctorList[msg.sender].phone = doctor.phone;
        doctorList[msg.sender].assignedHospital = doctor.assignedHospital;
        doctorList[msg.sender].medicalSpeciality = doctor.medicalSpeciality;
        doctorList[msg.sender].assignedPatients = doctor.assignedPatients;
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

    function createMedicalRecord() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
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

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}