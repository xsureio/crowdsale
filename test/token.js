const expectedExceptionPromise = require("../utils/expectedException.js");
const XsureTokenAbi = artifacts.require('./XsureToken.sol')

let settings = require('../tokenSettings.json');

contract('XsureToken', function(accounts) {

    //Creating accounts for testing
    const admin = accounts[0];
    const user1 = accounts[1];
    const user2 = accounts[2];
    const user3 = accounts[3];
    const user4 = accounts[4];
    const user5 = accounts[5];

    describe("Initial settings", function() {

        it ('should be possible to create a new Xsure ("XSR") token', async() => {
            XsureToken = await XsureTokenAbi.new(settings.maxTokenSupply);
            assert.isNotNull(XsureToken);
        })

        it ('should have the correct token settings', async() => {
            var name = await XsureToken.name();
            assert.strictEqual(name, settings.name);
            var symbol = await XsureToken.symbol();
            assert.strictEqual(symbol, settings.symbol);
            var decimals = await XsureToken.decimals();
            assert.strictEqual(decimals.toNumber(), settings.decimals);            
            var cap = await XsureToken.cap();
            assert.strictEqual(cap.toNumber(), settings.maxTokenSupply);
            
            var paused = await XsureToken.paused();
            assert.strictEqual(true, paused);
        })

        it ('should be in paused and non-transfer mode', async() => {
            
            var paused = await XsureToken.paused();
            assert.strictEqual(true, paused);
        })
    })
    
    describe("State transfers", function() {

        it ('should NOT be possible to pause if it is already paused', async() => {
            expectedExceptionPromise(() => XsureToken.pause());

            var paused = await XsureToken.paused();
            assert.strictEqual(true, paused);
        })
        
        it ('should NOT be possible for anyone besides the owner to unpause', async() => {
            expectedExceptionPromise(() => XsureToken.unpause({from : user1}));
        })

        it ('should be possible to unpause if it is in paused', async() => {
            var tx = await XsureToken.unpause();

            assert.strictEqual("Unpause", tx.logs[0].event)
            var paused = await XsureToken.paused();
            assert.strictEqual(false, paused);
        })

        it ('should NOT be possible for anyone besides the owner to pause', async() => {
            expectedExceptionPromise(() => XsureToken.pause({from : user1}));
        })

        it ('should be possible to pause again if it un-paused', async() => {
            var tx = await XsureToken.pause();

            assert.strictEqual("Pause", tx.logs[0].event)
            var paused = await XsureToken.paused();
            assert.strictEqual(true, paused);
        })
    })

    describe("Funding", function() {

        // it ('should NOT be possible to purchase in non-funding mode', async() => { 
        //     expectedExceptionPromise(() => XsureToken.purchase({from : user1, value : 1000}));
        // })

        it ('should NOT be possible for anyone besides the owner to mint new tokens', async() => { 
            expectedExceptionPromise(() => XsureToken.mint(user1, 1000, {from : user1}));
        })
    })
})