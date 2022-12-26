
var DipironaToken = artifacts.require("AspirinaToken");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(DipironaToken);
};