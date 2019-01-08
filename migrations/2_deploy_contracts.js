var RegistrationSystem = artifacts.require("./RegistrationSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(RegistrationSystem);
};
