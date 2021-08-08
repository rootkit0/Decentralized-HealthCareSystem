const AuthContract = artifacts.require("./AuthContract.sol");
const HealthcareContract = artifacts.require("./HealthcareContract.sol");

module.exports = function (deployer) {
  deployer.deploy(AuthContract);
  deployer.deploy(HealthcareContract);
};
