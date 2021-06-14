const Healthcare = artifacts.require("./Healthcare.sol");
const User = artifacts.require("./User.sol");

module.exports = function (deployer) {
  deployer.deploy(Healthcare);
  deployer.deploy(User);
};
