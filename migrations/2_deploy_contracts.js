var MetaCoin = artifacts.require("./MetaCoin.sol");
var TicTacToe = artifacts.require("./TicTacToe.sol");

module.exports = function(deployer) {
  deployer.deploy(TicTacToe);

};
