var RegistrationSystem = artifacts.require('RegistrationSystem')

contract('RegistrationSystem', function(accounts) {

    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const jack = accounts[3]
    const julia = accounts[4]
    const lisa = accounts[5]

    // Test 1: Creating an event for a free tennis practice, only 4 people fits the court. 
    it("should create an free to participate event", async() => {

        const registrationSystem = await RegistrationSystem.deployed()
        var eventEmitted = false

        const name = "Tennis_Practice"
        const price = 0
        const closesInThreeH = 10800
        const maxParticipants = 4
        const eventCreationFee = 10000000000000000
     
        const tx = await registrationSystem.createEvent(name, price, closesInThreeH, maxParticipants, {from: alice, value: eventCreationFee})
        if (tx.logs[0].event === "eventCreated") {

                eventEmitted = true
        }

        assert.equal(eventEmitted, true, 'should emit event creation')
    })

    // Test 2: Creating an event for collecting 1 ETH priced concert tickets.
    it("should create an priced event", async() => {

        const registrationSystem = await RegistrationSystem.deployed()

        var eventEmitted = false

        const name = "Concert_Tickets"
        const amount = 1 
        const price = web3.utils.toWei(amount.toString(), "ether")
        const closesInTwoDays = 172800 // 60 x 60 x 24 x 2 172 800 sec = 48 h = 2 days  
        const maxParticipants = 10
        const eventCreationFee = 10000000000000000
     
        const tx = await registrationSystem.createEvent(name, price, closesInTwoDays, maxParticipants, {from: bob, value: eventCreationFee})
        if (tx.logs[0].event === "eventCreated") {

                eventEmitted = true
        }

        assert.equal(eventEmitted, true, 'should emit event creation')
    })

    // Test 3: Alice registering and paying for the concert event. 
    it("should allow registering", async() => {

        const registrationSystem = await RegistrationSystem.deployed()

        var eventEmitted = false
        const eventNum = 1

        const tx = await registrationSystem.registerForEvent(eventNum, {from: alice, value: 1000000000000000000})
        if (tx.logs[0].event === "userRegistered") {

                eventEmitted = true
        }

        assert.equal(eventEmitted, true, 'should emit user registration')
    })

    // Test 4: Jack trying to register for the concert with wrong payment. Contract reverts. 
    it("should revert due wrong amount", async function() {

        const registrationSystem = await RegistrationSystem.deployed()

        var catchError = false
        const eventNum = 1

        try{
            // Jack trying to pay wrong price
            const tx = await registrationSystem.registerForEvent(eventNum, {from: jack, value: 500}); 
        } catch(e) {
            catchError = true
            // Test passes
            assert.equal(catchError, true, 'should catch contract revert'); 
        }

        // If the contract is not reverting, the error is not catched and test fails.
        assert.equal(catchError, true, 'should catch contract revert'); 

    })

    // Test 5: Lisa tries to register for an already full event. Contract reverts. 
    it("should fail due too many participants", async function() {

        const registrationSystem = await RegistrationSystem.deployed()

        var catchError = false
        const eventNum = 0

        try{
            await registrationSystem.registerForEvent(eventNum, {from: alice, value: 0}); 
            await registrationSystem.registerForEvent(eventNum, {from: bob, value: 0}); 
            await registrationSystem.registerForEvent(eventNum, {from: jack, value: 0}); 
            await registrationSystem.registerForEvent(eventNum, {from: julia, value: 0}); 

            // Lisa causes conracts to revert due participant cap of 4.
            await registrationSystem.registerForEvent(eventNum, {from: lisa, value: 0}); 

        } catch(e) {
            catchError = true
            assert.equal(catchError, true, 'should catch contract revert');
        }

        // If the contract is not reverting, the error is not catched and test fails.
        assert.equal(catchError, true, 'meni läpi'); 

    })


 
});