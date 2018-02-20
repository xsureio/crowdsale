pragma solidity ^0.4.18;

import './zeppelin/token/CappedToken.sol';
import './zeppelin/token/PausableToken.sol';

/// @title Xsure Token - Token code for our Xsure.io Project
/// @author Geru Marius, inspired from Blockport
//  Version 0.1, February 2018
//  This is based on the Openzeppelin Solidity framework.
//
//  There will be a predefined presale cap of XSR Tokens
//  Unsold presale tokens will be burnt, implemented as mintbale token as such that only sold tokens are minted.
//  Presale rate has a 33% bonus to the crowdsale to compensate the extra risk
//  Minimum crowdsale investment will be 0.1 ether
//  There is no bonus scheme for the crowdsale
//  Unsold Crowsdale tokens will be burnt, implemented as mintbale token as such that only sold tokens are minted.
//  On the amount tokens sold an additional 40% will be minted; this will be allocated to the Xsure company(20%) and the Xsure team(20%)
//  XSR tokens will be tradable straigt after the finalization of the crowdsale. This is implemented by being a pausable token that is unpaused at Crowdsale finalisation.


contract XsureToken is CappedToken, PausableToken {

    string public constant name = "Xsure";
    string public constant symbol = "XSR";
    uint public constant decimals = 18;

    function XsureToken(uint256 _totalSupply) 
        CappedToken(_totalSupply) public {
            paused = true;
    }
}