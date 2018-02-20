const expectedExceptionPromise = require("../utils/expectedException.js");
const XsureTokenAbi = artifacts.require('./XsureToken.sol')
const XsurePresaleAbi = artifacts.require('./XsurePresale.sol')

let settings = require('../tokenSettings.json');

contract('XsurePresale', function(accounts) {
    
    // Creating accounts to test with
    var admin = accounts[0];
    
    var user1 = accounts[3];
    var user2 = accounts[4];
    var user3 = accounts[5];
    
    describe("Deployment", function() {
        it ('should be possible to create a new Presale contract', async() => {
            XsureToken = await XsureTokenAbi.new(settings.maxTokenSupply);
            assert.isNotNull(XsureToken);

            XsurePresale = await XsurePresaleAbi.new(settings.presaleCap, settings.presaleStartTimestamp, settings.presaleEndTimestamp, settings.presaleRatio, settings.companyFundWallet, XsureToken.address);
            assert.isNotNull(XsurePresale);
        })
    })
    
    describe("Initial settings", function() {
        
        it ('should start on 3rd of February 2018 starting (first block after) 15:00 CET', async() => {
            // var startTime = await XsurePresale.startTime();
            // assert.strictEqual(startTime.toNumber(), settings.presaleStartTimestamp);
        })

        it ('should end on 17st of February 2018 starting (first block after) 15:00 CET', async() => {
            var endTime = await XsurePresale.endTime();
            assert.strictEqual(endTime.toNumber(), settings.presaleEndTimestamp);
        })
        
        it ('should have a hardcap of ' + settings.presaleCap / (1e18) + ' ETH (' + settings.presaleCap + ' wei) around €1.000.000 (depending on the rates)', async() => { 
            var cap = await XsurePresale.cap();
            assert.strictEqual(cap.toNumber(), settings.presaleCap);
        })      
    })

    describe("State changes", function() {
        it ('should be possible to pause the presale to disable purchases', async() => { 
            var pausedState = await XsurePresale.paused();
            console.log("to here..." + pausedState);
            assert.strictEqual(false, pausedState);

            var tx = await XsurePresale.pause();
            assert.strictEqual('Pause', tx.logs[0].event);
            
            pausedState = await XsurePresale.paused();
            assert.strictEqual(true, pausedState);
        })
        
        it ('should be possible to unpause the presale to re-enable purchases', async() => { 
            var pausedState = await XsurePresale.paused();
            assert.strictEqual(true, pausedState);

            var tx = await XsurePresale.unpause();
            assert.strictEqual('Unpause', tx.logs[0].event);
            
            pausedState = await XsurePresale.paused();
            assert.strictEqual(false, pausedState);
        })
        
        it ('should be possible to update the rate', async() => { 
            var currentRate = await XsurePresale.rate();
            var newRate                 = 3200;
            var newCap                  = 1500000000000000000000;
            var newMinimalInvestment    = 1500000000000000000;

            var tx = await XsurePresale.setRate(newRate, newCap, newMinimalInvestment);
            assert.strictEqual('InitialRateChange', tx.logs[0].event);
            console.log(tx.receipt.gasUsed);
            
            var updatedRate = await XsurePresale.rate();
            assert.strictEqual(newRate, updatedRate.toNumber());
        })

        it ('should NOT be possible to update the rate by anyone else but the owner', async() => { 
        //     var newRate = 1500;
        //     var tx = await XsurePresale.setRate(newRate);
        //     var currentRate = await XsurePresale.rate();
        //     newRate = 2000;
        //  //   expectedExceptionPromise(() => XsurePresale.setRate(newRate, {from: user1}));
        //     var reRate = await XsurePresale.rate();
        //     assert.strictEqual(currentRate.toNumber(), reRate.toNumber());
        })

        it ('should be possible to transfer token ownership to this contract address', async() => { 
            
            var tx = await XsureToken.transferOwnership(XsurePresale.address);
            var newOwner = await XsureToken.owner();
            assert.strictEqual('OwnershipTransferred', tx.logs[0].event);
            assert.strictEqual(newOwner, XsurePresale.address);
        })
        
        it ('should be possible to reset token ownership to the contract creator', async() => { 
            
            var tx = await XsurePresale.resetTokenOwnership();
            assert.strictEqual('OwnershipTransferred', tx.logs[0].event);
            var newOwner = await XsureToken.owner();
            assert.strictEqual(newOwner, admin);
        })

    })
    
    describe("Funding", function() { 
        // Untestable in presale so not tested here
        // 1- XSR2 should be locked until crowdsale contract is finished (so no transfer here )
        // 2- Pre-sale has NO softcap (minimum to be raised)
        it ('should be possible to purchase tokens during presale', async() => { 
            
        })

        // enable/disable token transfers
        it ('should not be possible to transfer tokens in the presale phase', async() => { 

        })

        it ('should not be possible to buy more than the hardcap', async() => { 

        })

        it ('should not be possible to buy with less then the minimal investment', async() => { 

        })

        it ('Sent ether must directly be received in the Team Account', async() => { 

        })

        it ('Tokens must directly be received in Account of the investor', async() => { 

        })

    })
})