//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
import "./User.sol";

contract Healthcare {
    mapping(address => bool) private admins;
    User private user;
    uint private treatmentId;
    uint private randSalt;
    constructor() public {
        //All users admins for testing purposes
        //For final version set specific addresses
        admins[msg.sender] = true;
        user = new User();
        treatmentId = 0;
        randSalt = 1;
    }
    function isAdmin() public view returns(bool) {
        return admins[msg.sender];
    }

    struct Patient {
        address patientId;
        string name;
        uint dateOfBirth;
        string email;
        string phone;
        string homeAddress;
        string gender;
        address assignedDoctor;
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
    address[] private doctorAddresses;

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
        address patientId;
        address doctorId;
        string diagnosis;
        string medicine;
        uint fromDate;
        uint toDate;
        uint bill;
    }
    mapping(uint => Treatment) public treatmentList;

    function createPatient( string memory name,
                            uint dateOfBirth,
                            string memory email,
                            string memory phone,
                            string memory homeAddress,
                            string memory gender) public {
        require(patientList[msg.sender].patientId == address(0), "Patient already exist!");
        require(doctorList[msg.sender].doctorId == address(0), "This address is assigned to a doctor!");
        //Set patient data
        patientList[msg.sender].patientId = msg.sender;
        patientList[msg.sender].name = name;
        patientList[msg.sender].dateOfBirth = dateOfBirth;
        patientList[msg.sender].email = email;
        patientList[msg.sender].phone = phone;
        patientList[msg.sender].homeAddress = homeAddress;
        patientList[msg.sender].gender = gender;
        //Create the patient medical record
        createMedicalRecord();
        //Assign random doctor to the new patient
        address _assignedDoctor = getRandomDoctor();
        patientList[msg.sender].assignedDoctor = _assignedDoctor;
        //Add the new patient to the assigned doctor patients list
        doctorList[_assignedDoctor].assignedPatients.push(msg.sender);
    }

    function readPatient(address patientAddress) public view returns(Patient memory) {
        require(patientList[patientAddress].patientId != address(0), "Patient don't exist!");
        return patientList[patientAddress];
    }

    function updatePatient( address patientAddress,
                            string memory name,
                            uint dateOfBirth,
                            string memory email,
                            string memory phone,
                            string memory homeAddress,
                            string memory gender) public {
        require(patientList[patientAddress].patientId != address(0), "Patient don't exist!");
        //Set patient data
        patientList[patientAddress].name = name;
        patientList[patientAddress].dateOfBirth = dateOfBirth;
        patientList[patientAddress].email = email;
        patientList[patientAddress].phone = phone;
        patientList[patientAddress].homeAddress = homeAddress;
        patientList[patientAddress].gender = gender;
    }
    
    function createDoctor(  string memory name,
                            string memory email,
                            string memory phone,
                            string memory assignedHospital,
                            string memory medicalSpeciality) public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(doctorList[msg.sender].doctorId == address(0), "Doctor already exist!");
        //Set doctor data
        doctorList[msg.sender].doctorId = msg.sender;
        doctorList[msg.sender].name = name;
        doctorList[msg.sender].email = email;
        doctorList[msg.sender].phone = phone;
        doctorList[msg.sender].assignedHospital = assignedHospital;
        doctorList[msg.sender].medicalSpeciality = medicalSpeciality;
        //Create the doctor medical record
        createMedicalRecord();
        //Push doctor to doctors list
        doctorAddresses.push(msg.sender);
    }

    function readDoctor(address doctorAddress) public view returns(Doctor memory) {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(doctorList[doctorAddress].doctorId != address(0), "Doctor don't exist!");
        return doctorList[doctorAddress];
    }

    function updateDoctor(  address doctorAddress,
                            string memory name,
                            string memory email,
                            string memory phone,
                            string memory assignedHospital,
                            string memory medicalSpeciality) public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(doctorList[doctorAddress].doctorId != address(0), "Doctor don't exist!");
        //Set doctor data
        doctorList[doctorAddress].name = name;
        doctorList[doctorAddress].email = email;
        doctorList[doctorAddress].phone = phone;
        doctorList[doctorAddress].assignedHospital = assignedHospital;
        doctorList[doctorAddress].medicalSpeciality = medicalSpeciality;
    }

    function upgradePatientToDoctor() public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(patientList[msg.sender].patientId != address(0), "Patient don't exist!");
        require(doctorList[msg.sender].doctorId == address(0), "Doctor already exist!");
        //Get patient data
        Patient memory patient = readPatient(msg.sender);
        //Create doctor with obtained data
        createDoctor(patient.name, patient.email, patient.phone, "", "");
        //Delete patient from mapping
        delete patientList[msg.sender];
    }

    function downgradeDoctorToPatient() public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(patientList[msg.sender].patientId == address(0), "Patient already exist!");
        require(doctorList[msg.sender].doctorId != address(0), "Doctor don't exist!");
        //Get doctors data
        Doctor memory doctor = readDoctor(msg.sender);
        //Create patient with obtained data
        createPatient(doctor.name, 0, doctor.email, doctor.phone, "", "");
        //Delete doctor from mapping
        delete doctorList[msg.sender];
    }

    function createMedicalRecord() public {
        require(medicalRecordList[msg.sender].medicalRecordId == address(0), "Medical record already exist!");
        medicalRecordList[msg.sender].medicalRecordId = msg.sender;
    }

    function readMedicalRecord(address medicalRecordId) public view returns (MedicalRecord memory) {
        require(medicalRecordList[medicalRecordId].medicalRecordId != address(0), "Medical record don't exist!");
        //A patient can only access his medical record
        if(compareStrings(user.getUserRole(), "patient")) {
            require(medicalRecordList[medicalRecordId].medicalRecordId == msg.sender, "You don't have permission to access this data!");
        }
        return medicalRecordList[medicalRecordId];
    }

    function updateMedicalRecord(   address medicalRecordId,
                                    string memory medications,
                                    string memory allergies,
                                    string memory illnesses,
                                    string memory immunizations,
                                    string memory bloodType,
                                    bool hasInsurance,
                                    uint[] memory treatmentsIds) public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(medicalRecordList[medicalRecordId].medicalRecordId != address(0), "Medical record don't exist!");
        //Set medical record data
        medicalRecordList[medicalRecordId].medications = medications;
        medicalRecordList[medicalRecordId].allergies = allergies;
        medicalRecordList[medicalRecordId].illnesses = illnesses;
        medicalRecordList[medicalRecordId].immunizations = immunizations;
        medicalRecordList[medicalRecordId].bloodType = bloodType;
        medicalRecordList[medicalRecordId].hasInsurance = hasInsurance;
        medicalRecordList[medicalRecordId].treatmentsIds = treatmentsIds;
    }

    function createTreatment(   address patientId,
                                address doctorId,
                                string memory diagnosis,
                                string memory medicine,
                                uint fromDate,
                                uint toDate,
                                uint bill) public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        treatmentId += 1;
        require(treatmentList[treatmentId].treatmentId == 0, "Treatment already exist!");
        //Set treatment data
        treatmentList[treatmentId].treatmentId = treatmentId;
        treatmentList[treatmentId].patientId = patientId;
        treatmentList[treatmentId].doctorId = doctorId;
        treatmentList[treatmentId].diagnosis = diagnosis;
        treatmentList[treatmentId].medicine = medicine;
        treatmentList[treatmentId].fromDate = fromDate;
        treatmentList[treatmentId].toDate = toDate;
        treatmentList[treatmentId].bill = bill;
    }

    function readTreatment(uint _treatmentId) public view returns (Treatment memory){
        require(treatmentList[_treatmentId].treatmentId != 0, "Treatment don't exist!");
        //A patient can only access his treatments
        if(compareStrings(user.getUserRole(), "patient")) {
            require(treatmentList[_treatmentId].patientId == msg.sender, "You don't have permission to access this data!");
        }
        return treatmentList[_treatmentId];
    }

    function updateTreatment(   uint _treatmentId,
                                address patientId,
                                address doctorId,
                                string memory diagnosis,
                                string memory medicine,
                                uint fromDate,
                                uint toDate,
                                uint bill) public {
        require(compareStrings(user.getUserRole(), "admin") || compareStrings(user.getUserRole(), "doctor"), "You don't have permission!");
        require(treatmentList[_treatmentId].treatmentId != 0, "Treatment don't exist!");
        //Set treatment data
        treatmentList[_treatmentId].patientId = patientId;
        treatmentList[_treatmentId].doctorId = doctorId;
        treatmentList[_treatmentId].diagnosis = diagnosis;
        treatmentList[_treatmentId].medicine = medicine;
        treatmentList[_treatmentId].fromDate = fromDate;
        treatmentList[_treatmentId].toDate = toDate;
        treatmentList[_treatmentId].bill = bill;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function randNumber(uint modulus) private returns(uint) {
        ++randSalt;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randSalt))) % modulus;
    }

    function getRandomDoctor() private returns(address) {
        require(doctorAddresses.length >= 1, "There is no doctor registrated in the system!");
        uint randomPosition = randNumber(doctorAddresses.length);
        require(doctorList[doctorAddresses[randomPosition]].doctorId != address(0), "Doctor don't exist!");
        return doctorAddresses[randomPosition];
    }
}