//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract HealthcareContract {
    uint private treatmentId;
    uint private randomInt;
    constructor() public {
        treatmentId = 0;
        randomInt = 0;
    }

    struct Patient {
        address patientId;
        string name;
        uint dateOfBirth;
        string email;
        string phone;
        string homeAddress;
        string gender;
        address assignedDoctorId;
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
        address[] assignedPatientsIds;
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

    function createPatient() public {
        require(patientList[msg.sender].patientId == address(0), "Patient already exist!");
        require(doctorList[msg.sender].doctorId == address(0), "This address is assigned to a doctor!");
        //Set address
        patientList[msg.sender].patientId = msg.sender;
        //Create the patient medical record
        createMedicalRecord();
        //Add address record to patientAddresses
        patientAddresses.push(msg.sender);
        //Assign random doctor to the new patient
        address _assignedDoctorId = getRandomDoctor();
        patientList[msg.sender].assignedDoctorId = _assignedDoctorId;
        //Add the new patient to the doctor list of assigned patients
        doctorList[_assignedDoctorId].assignedPatientsIds.push(msg.sender);
    }

    function readPatient(address patientAddress) public view returns(   string memory name,
                                                                        uint dateOfBirth,
                                                                        string memory email,
                                                                        string memory phone,
                                                                        string memory homeAddress,
                                                                        string memory gender) {
        require(patientList[patientAddress].patientId != address(0), "Patient don't exist!");
        return (patientList[patientAddress].name, patientList[patientAddress].dateOfBirth, patientList[patientAddress].email, patientList[patientAddress].phone, patientList[patientAddress].homeAddress, patientList[patientAddress].gender);
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
    
    function createDoctor() public {
        require(doctorList[msg.sender].doctorId == address(0), "Doctor already exist!");
        require(patientList[msg.sender].patientId == address(0), "This address is assigned to a patient!");
        //Set address
        doctorList[msg.sender].doctorId = msg.sender;
        //Create the doctor medical record
        createMedicalRecord();
        //Add address record to doctorAddresses
        doctorAddresses.push(msg.sender);
    }

    function readDoctor(address doctorAddress) public view returns( string memory name,
                                                                    string memory email,
                                                                    string memory phone,
                                                                    string memory assignedHospital,
                                                                    string memory medicalSpeciality) {
        require(doctorList[doctorAddress].doctorId != address(0), "Doctor don't exist!");
        return (doctorList[doctorAddress].name, doctorList[doctorAddress].email, doctorList[doctorAddress].phone, doctorList[doctorAddress].assignedHospital, doctorList[doctorAddress].medicalSpeciality);
    }

    function updateDoctor(  address doctorAddress,
                            string memory name,
                            string memory email,
                            string memory phone,
                            string memory assignedHospital,
                            string memory medicalSpeciality) public {
        require(doctorList[doctorAddress].doctorId != address(0), "Doctor don't exist!");
        //Set doctor data
        doctorList[doctorAddress].name = name;
        doctorList[doctorAddress].email = email;
        doctorList[doctorAddress].phone = phone;
        doctorList[doctorAddress].assignedHospital = assignedHospital;
        doctorList[doctorAddress].medicalSpeciality = medicalSpeciality;
    }

    function createMedicalRecord() public {
        require(medicalRecordList[msg.sender].medicalRecordId == address(0), "Medical record already exist!");
        medicalRecordList[msg.sender].medicalRecordId = msg.sender;
    }

    function readMedicalRecord(address medicalRecordId) public view returns (   string memory medications,
                                                                                string memory allergies,
                                                                                string memory illnesses,
                                                                                string memory immunizations,
                                                                                string memory bloodType,
                                                                                bool hasInsurance,
                                                                                uint[] memory treatmentsIds) {
        require(medicalRecordList[medicalRecordId].medicalRecordId != address(0), "Medical record don't exist!");
        return (medicalRecordList[medicalRecordId].medications, medicalRecordList[medicalRecordId].allergies, medicalRecordList[medicalRecordId].illnesses, medicalRecordList[medicalRecordId].immunizations, medicalRecordList[medicalRecordId].bloodType, medicalRecordList[medicalRecordId].hasInsurance, medicalRecordList[medicalRecordId].treatmentsIds);
    }

    function updateMedicalRecord(   address medicalRecordId,
                                    string memory medications,
                                    string memory allergies,
                                    string memory illnesses,
                                    string memory immunizations,
                                    string memory bloodType,
                                    bool hasInsurance,
                                    uint[] memory treatmentsIds) public {
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

    function updateTreatment(   uint _treatmentId,
                                address patientId,
                                address doctorId,
                                string memory diagnosis,
                                string memory medicine,
                                uint fromDate,
                                uint toDate,
                                uint bill) public {
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

    function getPatientAddresses() public view returns (address[] memory) {
        return patientAddresses;
    }

    function getDoctorAddresses() public view returns (address[] memory) {
        return doctorAddresses;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function randNumber(uint modulus) private returns(uint) {
        ++randomInt;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomInt))) % modulus;
    }

    function getRandomDoctor() private returns(address) {
        require(doctorAddresses.length >= 1, "There is no doctor registrated in the system!");
        uint randomPosition = randNumber(doctorAddresses.length);
        require(doctorList[doctorAddresses[randomPosition]].doctorId != address(0), "Doctor don't exist!");
        return doctorAddresses[randomPosition];
    }
}
