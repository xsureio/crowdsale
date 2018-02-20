var Whitelist = artifacts.require("./Whitelist.sol");
var SafeMath = artifacts.require("./zeppelin/math/SafeMath.sol");
var RefundVault = artifacts.require("./zeppelin/crowdsale/RefundVault.sol");
var XsureToken = artifacts.require("./XsureToken.sol");
var XsurePresale = artifacts.require("./XsurePresale.sol");

let settings = require('../tokenSettings.json');

module.exports = function(deployer, network, accounts) {
    
    // Account & Wallet configuration
    var admin = accounts[0];
    var refundVault = accounts[0];

    // Deploying..
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, XsurePresale);
    var presaleRate = new web3.BigNumber(settings.presaleRatio);
    
    deployer.deploy(XsureToken, settings.maxTokenSupply).then(function() {
        return deployer.deploy(XsurePresale,
                               settings.presaleCap,
                               settings.presaleStartTimestamp,
                               settings.presaleEndTimestamp,
                               presaleRate,
                               settings.companyFundWallet,
                               XsureToken.address);
    });  
};