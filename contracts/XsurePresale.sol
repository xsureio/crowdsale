pragma solidity ^0.4.18;

import './XsureToken.sol';
import './Whitelist.sol';
import './zeppelin/lifecycle/Pausable.sol';
import './zeppelin/crowdsale/CappedCrowdsale.sol';

/// @title Xsure Token - Token code for our Xsure.io Project
/// @author Geru Marius, inspired from Blockport
//  Version 0.1, February 2018
//  Based on Openzeppelin with an aye on the Pillarproject code.
//
//  There will be a predefined presale cap of XSR Tokens
//  Unsold presale tokens will be burnt
//  Presale rate has a 33% bonus to the crowdsale to compensate the extra risk. This is implemented by setting the rate on the presale and Crowdsale contacts.
//  Minimum presale investment will be 0.5 ether


contract XsurePresale is CappedCrowdsale, Pausable, Whitelist {
    address public tokenAddress;
    uint256 public minimalInvestmentInWei = 0.5 ether;       // Is to be set when setting the rate

    XsureToken public xsr;

    event InitialRateChange(uint256 rate, uint256 cap, uint256 minimalInvestment);

    // Initialise contract with parameters
    // @notice Function to initialise the token with configurable parameters. 
    // @param ` _cap - max number ot tokens available for the presale
    // @param ' _startTime - set the presale start time
    // @param ` _endTime - set the presale end time
    // @param ` rate - initial presale rate
    // @param ` _wallet - multisig wallet the investments are being send to during presale
    // @param ` _tokenAddress - token to be used, created outside the presale contract
    function XsurePresale(
        uint256 _cap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _tokenAddress
    ) 
        CappedCrowdsale(_cap) 
        Crowdsale(_startTime, _endTime, _rate, _wallet) public {
            tokenAddress = _tokenAddress;
            token = createTokenContract();
        }

    // @notice Function to cast the Capped (&mintable) token provided with the constructor to a Xsure token that is mintabletoken.
    // This is a workaround to surpass an issue that Mintabletoken functions are not accessible in this contract.
    // We did not want to change the Openzeppelin code.
    function createTokenContract() internal returns (MintableToken) {
        xsr = XsureToken(tokenAddress);
        return XsureToken(tokenAddress);
    }

    // overriding Crowdsale#validPurchase to add extra cap logic
    // @return true if minimal investment amount is reached
    function validPurchase() internal returns (bool) {
        bool minimalInvested = msg.value >= minimalInvestmentInWei;
        bool whitelisted = addressIsWhitelisted(msg.sender);

        return super.validPurchase() && minimalInvested && !paused && whitelisted;
    }

    // @notice Function sets the token conversion rate in this contract
    // @param ` __rateInWei - Price of 1 Xsure token in Wei. 
    // @param ` __capInWei - Cap of the presale in Wei. 
    // @param ` __minimalInvestmentInWei - Minimal investment in Wei. 
    function setRate(uint256 _rateInWei, uint256 _capInWei, uint256 _minimalInvestmentInWei) 
        public
        onlyOwner
        returns (bool)
    { 
        require(startTime >= block.timestamp); // can't update anymore if sale already started
        require(_rateInWei > 0);
        require(_capInWei > 0);
        require(_minimalInvestmentInWei > 0);

        rate = _rateInWei;
        cap = _capInWei;
        minimalInvestmentInWei = _minimalInvestmentInWei;

        InitialRateChange(rate, cap, minimalInvestmentInWei);
        return true;
    }

    // @notice Function transfer ownership of the tokens to contract owner
    function resetTokenOwnership() onlyOwner public { 
        xsr.transferOwnership(owner);
    }
}