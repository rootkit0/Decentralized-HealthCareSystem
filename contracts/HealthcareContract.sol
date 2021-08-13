//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract HealthcareContract {
    uint private treatmentId;
    uint private randomInt;
    constructor() public {
        treatmentId = 0;
        randomInt = 256;
    }

    struct Patient {
        address patientId;
        string name;
        uint dateOfBirth;
        string email;
        string phone;
        string homeAddress;
        string city;
        string postalCode;
        address assignedDoctorId;
    }
    mapping(address => Patient) private patientList;
    address[] private patientAddresses;

    struct Doctor {
        address doctorId;
        string name;
        string email;
        string phone;
        string homeAddress;
        string city;
        string postalCode;
        string medicalSpeciality;
        string assignedHospital;
        address[] assignedPatientsIds;
    }
    mapping(address => Doctor) private doctorList;
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
    mapping(address => MedicalRecord) private medicalRecordList;

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
    mapping(uint => Treatment) private treatmentList;
    
    function createPatient() public {
        require(patientList[msg.sender].patientId == address(0), "Patient already exist!");
        require(doctorList[msg.sender].doctorId == address(0), "This address is assigned to a doctor!");
        //Set address and add to the list
        patientList[msg.sender].patientId = msg.sender;
        patientAddresses.push(msg.sender);
        //Create the patient medical record
        createMedicalRecord();
        //Assign random doctor to the new patient
        address _assignedDoctorId = getRandomDoctor();
        patientList[msg.sender].assignedDoctorId = _assignedDoctorId;
        //Add the new patient to the doctor list of assigned patients
        doctorList[_assignedDoctorId].assignedPatientsIds.push(msg.sender);
    }

    function readPatient(string memory patientId) public view returns(  string memory name,
                                                                        uint dateOfBirth,
                                                                        string memory email,
                                                                        string memory phone,
                                                                        string memory homeAddress,
                                                                        string memory city,
                                                                        string memory postalCode,
                                                                        address assignedDoctorId) {
        //Parse given string to address
        address patientIdAddr = parseAddr(patientId);
        require(patientList[patientIdAddr].patientId != address(0), "Patient don't exist!");
        return (patientList[patientIdAddr].name, patientList[patientIdAddr].dateOfBirth, patientList[patientIdAddr].email, patientList[patientIdAddr].phone, patientList[patientIdAddr].homeAddress, patientList[patientIdAddr].city, patientList[patientIdAddr].postalCode, patientList[patientIdAddr].assignedDoctorId);
    }

    function updatePatient( string memory patientId,
                            string memory name,
                            uint dateOfBirth,
                            string memory email,
                            string memory phone,
                            string memory homeAddress,
                            string memory city,
                            string memory postalCode) public {
        //Parse given string to address
        address patientIdAddr = parseAddr(patientId);
        require(patientList[patientIdAddr].patientId != address(0), "Patient don't exist!");
        //Set patient data
        patientList[patientIdAddr].name = name;
        patientList[patientIdAddr].dateOfBirth = dateOfBirth;
        patientList[patientIdAddr].email = email;
        patientList[patientIdAddr].phone = phone;
        patientList[patientIdAddr].homeAddress = homeAddress;
        patientList[patientIdAddr].city = city;
        patientList[patientIdAddr].postalCode = postalCode;
    }
    
    function createDoctor() public {
        require(doctorList[msg.sender].doctorId == address(0), "Doctor already exist!");
        require(patientList[msg.sender].patientId == address(0), "This address is assigned to a patient!");
        //Set address and add to the list
        doctorList[msg.sender].doctorId = msg.sender;
        doctorAddresses.push(msg.sender);
        //Create the doctor medical record
        createMedicalRecord();
    }

    function readDoctor(string memory doctorId) public view returns(string memory name,
                                                                    string memory email,
                                                                    string memory phone,
                                                                    string memory homeAddress,
                                                                    string memory city,
                                                                    string memory postalCode,
                                                                    string memory medicalSpeciality,
                                                                    string memory assignedHospital,
                                                                    address[] memory assignedPatientsIds) {
        //Parse given string to address
        address doctorIdAddr = parseAddr(doctorId);                                                                   
        require(doctorList[doctorIdAddr].doctorId != address(0), "Doctor don't exist!");
        return (doctorList[doctorIdAddr].name, doctorList[doctorIdAddr].email, doctorList[doctorIdAddr].phone, doctorList[doctorIdAddr].homeAddress, doctorList[doctorIdAddr].city, doctorList[doctorIdAddr].postalCode, doctorList[doctorIdAddr].medicalSpeciality, doctorList[doctorIdAddr].assignedHospital, doctorList[doctorIdAddr].assignedPatientsIds);
    }

    function updateDoctor(  string memory doctorId,
                            string memory name,
                            string memory email,
                            string memory phone,
                            string memory homeAddress,
                            string memory city,
                            string memory postalCode,
                            string memory medicalSpeciality,
                            string memory assignedHospital) public {
        //Parse given string to address
        address doctorIdAddr = parseAddr(doctorId);
        require(doctorList[doctorIdAddr].doctorId != address(0), "Doctor don't exist!");
        //Set doctor data
        doctorList[doctorIdAddr].name = name;
        doctorList[doctorIdAddr].email = email;
        doctorList[doctorIdAddr].phone = phone;
        doctorList[doctorIdAddr].homeAddress = homeAddress;
        doctorList[doctorIdAddr].city = city;
        doctorList[doctorIdAddr].postalCode = postalCode;
        doctorList[doctorIdAddr].medicalSpeciality = medicalSpeciality;
        doctorList[doctorIdAddr].assignedHospital = assignedHospital;
    }

    function createMedicalRecord() private {
        require(medicalRecordList[msg.sender].medicalRecordId == address(0), "Medical record already exist!");
        medicalRecordList[msg.sender].medicalRecordId = msg.sender;
    }

    function readMedicalRecord(string memory medicalRecordId) public view returns ( string memory medications,
                                                                                    string memory allergies,
                                                                                    string memory illnesses,
                                                                                    string memory immunizations,
                                                                                    string memory bloodType,
                                                                                    bool hasInsurance,
                                                                                    uint[] memory treatmentsIds) {
        //Parse given string to address
        address medicalRecordIdAddr = parseAddr(medicalRecordId);
        require(medicalRecordList[medicalRecordIdAddr].medicalRecordId != address(0), "Medical record don't exist!");
        return (medicalRecordList[medicalRecordIdAddr].medications, medicalRecordList[medicalRecordIdAddr].allergies, medicalRecordList[medicalRecordIdAddr].illnesses, medicalRecordList[medicalRecordIdAddr].immunizations, medicalRecordList[medicalRecordIdAddr].bloodType, medicalRecordList[medicalRecordIdAddr].hasInsurance, medicalRecordList[medicalRecordIdAddr].treatmentsIds);
    }

    function updateMedicalRecord(   string memory medicalRecordId,
                                    string memory medications,
                                    string memory allergies,
                                    string memory illnesses,
                                    string memory immunizations,
                                    string memory bloodType,
                                    bool hasInsurance,
                                    uint[] memory treatmentsIds) public {
        //Parse given string to address
        address medicalRecordIdAddr = parseAddr(medicalRecordId);
        require(medicalRecordList[medicalRecordIdAddr].medicalRecordId != address(0), "Medical record don't exist!");
        //Set medical record data
        medicalRecordList[medicalRecordIdAddr].medications = medications;
        medicalRecordList[medicalRecordIdAddr].allergies = allergies;
        medicalRecordList[medicalRecordIdAddr].illnesses = illnesses;
        medicalRecordList[medicalRecordIdAddr].immunizations = immunizations;
        medicalRecordList[medicalRecordIdAddr].bloodType = bloodType;
        medicalRecordList[medicalRecordIdAddr].hasInsurance = hasInsurance;
        medicalRecordList[medicalRecordIdAddr].treatmentsIds = treatmentsIds;
    }

    function createTreatment(   string memory patientId,
                                string memory doctorId,
                                string memory diagnosis,
                                string memory medicine,
                                uint fromDate,
                                uint toDate,
                                uint bill) public {
        treatmentId += 1;
        require(treatmentList[treatmentId].treatmentId == 0, "Treatment already exist!");
        //Parse given strings to addresses
        address patientIdAddr = parseAddr(patientId);
        address doctorIdAddr = parseAddr(doctorId);
        //Set treatment data
        treatmentList[treatmentId].treatmentId = treatmentId;
        treatmentList[treatmentId].patientId = patientIdAddr;
        treatmentList[treatmentId].doctorId = doctorIdAddr;
        treatmentList[treatmentId].diagnosis = diagnosis;
        treatmentList[treatmentId].medicine = medicine;
        treatmentList[treatmentId].fromDate = fromDate;
        treatmentList[treatmentId].toDate = toDate;
        treatmentList[treatmentId].bill = bill;
        //Add treatment to corresponding medical record
        medicalRecordList[patientIdAddr].treatmentsIds.push(treatmentId);
    }

    function readTreatment(uint _treatmentId) public view returns ( address patientId,
                                                                    address doctorId,
                                                                    string memory diagnosis,
                                                                    string memory medicine,
                                                                    uint fromDate,
                                                                    uint toDate,
                                                                    uint bill) {
        require(treatmentList[_treatmentId].treatmentId != 0, "Treatment don't exist!");
        return (treatmentList[_treatmentId].patientId, treatmentList[_treatmentId].doctorId, treatmentList[_treatmentId].diagnosis, treatmentList[_treatmentId].medicine, treatmentList[_treatmentId].fromDate, treatmentList[_treatmentId].toDate, treatmentList[_treatmentId].bill);
    }

    function updateTreatment(   uint treatmentIde,
                                string memory patientId,
                                string memory doctorId,
                                string memory diagnosis,
                                string memory medicine,
                                uint fromDate,
                                uint toDate,
                                uint bill) public {
        require(treatmentList[treatmentIde].treatmentId != 0, "Treatment don't exist!");
        //Parse given strings to addresses
        //address patientIdAddr = parseAddr(patientId);
        address doctorIdAddr = parseAddr(doctorId);
        //Set treatment data
        //treatmentList[treatmentId].treatmentId = treatmentId;
        //treatmentList[treatmentId].patientId = patientIdAddr;
        treatmentList[treatmentIde].doctorId = doctorIdAddr;
        treatmentList[treatmentIde].diagnosis = diagnosis;
        treatmentList[treatmentIde].medicine = medicine;
        treatmentList[treatmentIde].fromDate = fromDate;
        treatmentList[treatmentIde].toDate = toDate;
        treatmentList[treatmentIde].bill = bill;
    }

    function getPatientAddresses() public view returns (address[] memory) {
        return patientAddresses;
    }

    function getDoctorAddresses() public view returns (address[] memory) {
        return doctorAddresses;
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function randNumber(uint modulus) private view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomInt))) % modulus;
    }

    function getRandomDoctor() private view returns(address) {
        require(doctorAddresses.length >= 1, "There is no doctor registered in the system!");
        uint randomPosition = randNumber(doctorAddresses.length);
        require(doctorList[doctorAddresses[randomPosition]].doctorId != address(0), "Doctor don't exist!");
        return doctorAddresses[randomPosition];
    }

    function parseAddr(string memory _a) private pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}
