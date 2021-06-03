const Doctor = artifacts.require("./Doctor.sol");
const MedicalRecord = artifacts.require("./MedicalRecord.sol");
const Patient = artifacts.require("./Patient.sol");

module.exports = function (deployer) {
  deployer.deploy(Doctor);
  deployer.deploy(MedicalRecord);
  deployer.deploy(Patient);
};
