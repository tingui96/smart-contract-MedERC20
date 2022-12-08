var DipironaToken = artifacts.require("DipironaToken");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(DipironaToken);
};