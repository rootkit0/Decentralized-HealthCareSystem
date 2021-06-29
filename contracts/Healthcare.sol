//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
import "./User.sol";

contract Healthcare {
    address private admin;
    User private user;
    string private userRole;
    uint private treatmentId;
    uint private randSalt;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
        userRole = user.getUserRole();
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
    }
    mapping(address => Patient) public patientList;

    struct Doctor {
        address doctorId;
        string name;
        string email;
        string phone;
        string assignedHospital;
        string medicalSpeciality;
    }
    mapping(address => Doctor) public doctorList;

    struct MedicalRecord {
        address medicalRecordId;
        string medications;
        string allergies;
        string illnesses;
        string immunizations;
        string bloodType;
        bool hasInsurance;
        uint[] treatmentsIds;
    }
    mapping(address => MedicalRecord) public medicalRecordList;

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
        //Create the patient medical record
        createMedicalRecord();
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
    }
    
    function createDoctor() public {
        require(compareStrings(userRole, "admin") || compareStrings(userRole, "doctor"));
        require(doctorList[msg.sender].doctorId == address(0));
        //Set doctor address
        doctorList[msg.sender].doctorId = msg.sender;
        //Create the doctor medical record
        createMedicalRecord();
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
    }

    function createMedicalRecord() public {
        require(medicalRecordList[msg.sender].medicalRecordId == address(0));
        //Set medical record id
        medicalRecordList[msg.sender].medicalRecordId = msg.sender;
    }

    function readMedicalRecord(address personAddress) public view returns (MedicalRecord memory) {
        require(medicalRecordList[personAddress].medicalRecordId != address(0));
        return medicalRecordList[personAddress];
    }

    function updateMedicalRecord(MedicalRecord memory medicalRecord, address personAddress) public {
        require(medicalRecordList[personAddress].medicalRecordId != address(0));
        medicalRecordList[personAddress].medications = medicalRecord.medications;
        medicalRecordList[personAddress].allergies = medicalRecord.allergies;
        medicalRecordList[personAddress].illnesses = medicalRecord.illnesses;
        medicalRecordList[personAddress].immunizations = medicalRecord.immunizations;
        medicalRecordList[personAddress].bloodType = medicalRecord.bloodType;
        medicalRecordList[personAddress].hasInsurance = medicalRecord.hasInsurance;
        medicalRecordList[personAddress].treatmentsIds = medicalRecord.treatmentsIds;
    }

    function createTreatment() public {
        treatmentId += 1;
        require(treatmentList[treatmentId].treatmentId == 0);
        treatmentList[treatmentId].treatmentId = treatmentId;
    }

    function readTreatment(uint _treatmentId) public view returns (Treatment memory){
        require(treatmentList[_treatmentId].treatmentId != 0);
        return treatmentList[_treatmentId];
    }

    function updateTreatment(Treatment memory treatment, uint _treatmentId) public {
        require(treatmentList[_treatmentId].treatmentId != 0);
        treatmentList[_treatmentId].patientId = treatment.patientId;
        treatmentList[_treatmentId].doctorId = treatment.doctorId;
        treatmentList[_treatmentId].diagnosis = treatment.diagnosis;
        treatmentList[_treatmentId].medicine = treatment.medicine;
        treatmentList[_treatmentId].fromDate = treatment.fromDate;
        treatmentList[_treatmentId].toDate = treatment.toDate;
        treatmentList[_treatmentId].bill = treatment.bill;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function randNumber(uint modulus) internal returns(uint) {
        ++randSalt;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randSalt))) % modulus;
    }
}