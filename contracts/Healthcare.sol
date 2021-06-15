//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
import "./User.sol";

contract Healthcare {
    address private admin;
    User private user;
    string private userRole;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
        userRole = user.getUserRole();
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

    //CRUD operations for Patient
    function createPatient() public {
        require(compareStrings(userRole, "admin"));
    }

    function readPatient(address patientAddress) public view returns(Patient memory) {
        return patientList[patientAddress];
    }

    function updatePatient(Patient memory patient, address patientAddress) public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        Patient memory toUpdate = patientList[patientAddress];
        toUpdate.name = patient.name;
        toUpdate.age = patient.age;
        toUpdate.dateOfBirth = patient.dateOfBirth;
        toUpdate.email = patient.email;
        toUpdate.phone = patient.phone;
        toUpdate.homeAddress = patient.homeAddress;
        toUpdate.gender = patient.gender;
        toUpdate.assignedDoctor = patient.assignedDoctor;
        toUpdate.medicalRecordId = patient.medicalRecordId;
    }

    function deletePatient() public {
        require(compareStrings(userRole, "admin"));
    }

    //CRUD operations for Doctor
    function createDoctor() public {
        require(compareStrings(userRole, "admin"));
    }

    function readDoctor(address doctorAddress) public view returns(Doctor memory) {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        if(compareStrings(userRole, "doctor")) {
            return doctorList[msg.sender];
        }
        else {
            return doctorList[doctorAddress];
        }
    }

    function updateDoctor(Doctor memory doctor, address doctorAddress) public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        Doctor memory toUpdate;
        if(compareStrings(userRole, "doctor")) {
            toUpdate = doctorList[msg.sender];
        }
        else {
            toUpdate = doctorList[doctorAddress];           
        }
        toUpdate.name = doctor.name;
        toUpdate.email = doctor.email;
        toUpdate.phone = doctor.phone;
        toUpdate.assignedHospital = doctor.assignedHospital;
        toUpdate.medicalSpeciality = doctor.medicalSpeciality;
        toUpdate.assignedPatients = doctor.assignedPatients;
    }

    function deleteDoctor() public {
        require(compareStrings(userRole, "admin"));
    }

    //CRUD operations for MediacalRecord
    function createMedicalRecord() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function readMedicalRecord(address patientAddress) public view returns (MedicalRecord memory) {
        if(compareStrings(userRole, "patient")) {
            return medicalRecordList[patientList[msg.sender].medicalRecordId];
        }
        else {
            return medicalRecordList[patientList[patientAddress].medicalRecordId];
        }
    }

    function updateMedicalRecord() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function deleteMedicalRecord() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    //CRUD operations for Treatment
    function createTreatment() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function readTreatment() public {

    }

    function updateTreatment() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function deleteTreatment() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}