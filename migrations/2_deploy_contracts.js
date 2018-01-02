var CreditBureau = artifacts.require("./CreditBureau.sol");

module.exports = function(deployer) {
  deployer.deploy(CreditBureau);
};
