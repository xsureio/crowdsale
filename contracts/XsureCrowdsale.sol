pragma solidity ^0.4.18;

import "./XsureToken.sol";
import "./CrowdsaleWhitelist.sol";
import "./zeppelin/lifecycle/Pausable.sol";
import "./zeppelin/crowdsale/CappedCrowdsale.sol";
import "./zeppelin/crowdsale/FinalizableCrowdsale.sol";
import "./zeppelin/crowdsale/RefundableCrowdsale.sol";


/// @title Xsure Token - Token code for our Xsure.io Project
/// @author Geru Marius, inspired from Blockport
//  Version 0.1, February 2018
//  Based on Openzeppelin framework
//
//  The Crowdsale will start after the presale which had a predefined cap of XSR Tokens
//  Unsold presale tokens will be burnt. Implemented by using MintedToken.
//  There is no bonus in the Crowdsale.
//  Minimum crowdsale investment will be 0.1 ether

interface ERC20I {
       function transfer(address _recipient, uint256 _amount) public returns (bool);
       function balanceOf(address _holder) public view returns (uint256);
}
contract XsureCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable {
    using SafeMath for uint256;

    address public tokenAddress;
    address public teamVault;
    address public companyVault;
    address public bountyVault;
    uint256 public minimalInvestmentInWei = 0.1 ether;
    uint256 public maxInvestmentInWei = 50 ether;
    
    mapping (address => uint256) internal invested;

    XsureToken public xsr;

    // Events for this contract
    event InitialRateChange(uint256 rate, uint256 cap);
    event InitialDateChange(uint256 startTime, uint256 endTime);

    // Initialise contract with parapametrs
    //@notice Function to initialise the token with configurable parameters. 
    //@param ` _cap - max number ot tokens available for the presale
    //@param ' _startTime - set the start time of presale
    //@param ` _endTime - set the endtime of presale
    //@param ` _rate - initial presale rate
    //@param ` _wallet - Multisig wallet the investments are being send to during presale
    //@param ` _tokenAddress - Token to be used, created outside the presale contract  
    //@param ` _teamVault - Ether send to this contract will be stored at this multisig wallet
    //@param ` _companyVault - set company wallet (at the end of crowdsale 20% more tokens will be minted and transfered to this wallet)
    function XsureCrowdsale(
        uint256 _cap,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet,
        address _tokenAddress,
        address _teamVault,
        address _companyVault,
        address _bountyVault
    )
        CappedCrowdsale(_cap)
        Crowdsale(_startTime, _endTime, _rate, _wallet) public {
        require(_tokenAddress != address(0));
        require(_teamVault != address(0));
        require(_companyVault != address(0));
        require(_bountyVault != address(0));
        
        tokenAddress = _tokenAddress;
        token = createTokenContract();
        teamVault = _teamVault;
        companyVault = _companyVault;
        bountyVault = _bountyVault;
    }

    //@notice Function to cast the Capped (&mintable) token provided with the constructor to a Xsure token that is mintabletoken.
    // This is a workaround to surpass an issue that Mintabletoken functions are not accessible in this contract.
    // We did not want to change the Openzeppelin code and we did not have the time for an extensive drill down.
    function createTokenContract() internal returns (MintableToken) {
        xsr = XsureToken(tokenAddress);
        return XsureToken(tokenAddress);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        invested[msg.sender] += msg.value;
        super.buyTokens(beneficiary);
    }

    // overriding Crowdsale#validPurchase to add extra cap logic
    // @return true if minimal investment amount is reached
    function validPurchase() internal returns (bool) {
        bool moreThanMinimalInvestment = msg.value >= minimalInvestmentInWei;
        //bool whitelisted = addressIsWhitelisted(msg.sender);
        bool lessThanMaxInvestment = invested[msg.sender] <= maxInvestmentInWei;

        return super.validPurchase() && moreThanMinimalInvestment && lessThanMaxInvestment && !paused; //&& whitelisted;
    }

    //@notice Function overidden function will finalise the Crowdsale
    // Additional tokens are allocated to the team and to the company, adding 40% in total to tokens already sold. 
    // After calling this function no more Xsure tokens will be minted.
    // From now on, the existing XSR can be tranfered or traded by the holders of this token.
    function finalization() internal {
        uint256 totalSupply = token.totalSupply();
        uint256 twentyPercentAllocation = totalSupply.div(5);
        uint256 tenPercentAllocation = totalSupply.div(10);

        // mint tokens for the foundation
        token.mint(teamVault, twentyPercentAllocation);
        token.mint(companyVault, twentyPercentAllocation);
        token.mint(bountyVault, tenPercentAllocation);

        token.finishMinting();              // No more tokens can be added from now
        xsr.unpause();                  // ERC20 transfer functions will work after this so trading can start.
        super.finalization();               // finalise up in the tree
        
        xsr.transferOwnership(owner);   // transfer token Ownership back to original owner
    }

    //@notice Function sets the token conversion rate in this contract
    //@param ` __rateInWei - Price of 1 Xsure token in Wei.
    //@param ` __capInWei - Price of 1 Xsure token in Wei.
    function setRate(uint256 _rateInWei, uint256 _capInWei) public onlyOwner returns (bool) {
        require(startTime > block.timestamp);
        require(_rateInWei > 0);
        require(_capInWei > 0);

        rate = _rateInWei;
        cap = _capInWei;

        InitialRateChange(rate, cap);
        return true;
    }

    //@notice Function sets start and end date/time for this Crowdsale. Can be called multiple times
    //@param ' _startTime - sets the crowdsale start date
    //@param ` _endTime - sets the crowdsale end date
    function setCrowdsaleDates(uint256 _startTime, uint256 _endTime) public onlyOwner returns (bool) { 
        require(startTime > block.timestamp); // current startTime in the future
        require(_startTime >= now);
        require(_endTime >= _startTime);

        startTime = _startTime;
        endTime = _endTime;

        InitialDateChange(startTime, endTime);
        return true;
    }

    //@notice Function sets the token owner to contract owner
    function resetTokenOwnership() onlyOwner public { 
        xsr.transferOwnership(owner);
    }

    function transferTokens(address _bountyVault, address _recipient, uint256 _amount) public onlyOwner returns (bool) {

        ERC20I e = ERC20I(_bountyVault);
        require(e.transfer(_recipient, _amount));
        return true;
    }
}