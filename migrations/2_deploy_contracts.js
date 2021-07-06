const User = artifacts.require("./User.sol");
const Healthcare = artifacts.require("./Healthcare.sol");

module.exports = function (deployer) {
  deployer.deploy(User);
  deployer.deploy(Healthcare);
};
