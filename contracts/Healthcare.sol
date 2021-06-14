//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract Healthcare {
    address public admin;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
    }

    struct Patient {
        uint patientId;
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
    mapping(uint => Patient) public patientList;

    struct Doctor {
        uint doctorId;
        string name;
        string email;
        string phone;
        string assignedHospital;
        string medicalSpeciality;
        uint[] assignedPatientIds;
    }
    mapping(uint => Doctor) public doctorList;

    struct MedicalRecord {
        uint medicalRecordId;
        string medications;
        string allergies;
        string illnesses;
        string immunizations;
        string bloodType;
        bool hasInsurance;
        uint[] treatmentIds;
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
}