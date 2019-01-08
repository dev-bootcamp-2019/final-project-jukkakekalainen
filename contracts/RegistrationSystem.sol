pragma solidity ^0.5.0;

/// @title A general use event registration demo for ConsenSys Academy
/// @author Jukka Kekalainen 

contract RegistrationSystem {
    
    /* Modifiers to halt execution if conditions are not met */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner.");
        _;
    }
    
    /* Registration time needs to be earlier than expiration */
    modifier notExpired(uint _eventNum) {
        require(now <= events[_eventNum].expiresOn, "Expired event.");
        _;
    }
    
    /* Checking for full event, indexing start from zero */
    modifier notFull(uint _eventNum) {
        require(getParticipantCount(_eventNum) <= events[_eventNum].maxParticipants - 1, "Event is full.");
        _;
    }
    
    /* Event must be open for registration */
    modifier notClosed(uint _eventNum) {
        require(uint(events[_eventNum].state) == 0, "Event is closed.");
        _;
    }
    
    modifier onlyOrganizer(uint _eventNum) {
        require(msg.sender == events[_eventNum].organizer, "Only organizer.");
        _;
    }
    
    /* Events for logging actions */

    event eventCreated(uint _num);
    event userRegistered(uint _num);
    event eventClosed(uint _num);
    event eventOpened(uint _num);


    /* Contract owner */
    address payable owner;

    /* Number of events, also used as ID for event-variable  */
    uint eventCount;
    
    /* The contract cumulates a small fee on event creation */
    uint eventCreationFee = 0.01 ether;
    
    /* An event can be open or closed*/
    enum State {Open, Closed}

    /* A struct defines properties of an single event  */

    struct Event {
        string name;
        uint eventNum;    
        uint price; //in wei
        uint expiresOn;
        uint maxParticipants;
        State state;
        address payable organizer;
    }

    /* All events */
    Event[] public events;
    mapping (uint => address payable[]) public participants;
    mapping (address => uint[]) public eventsByCreator;
  
    /* A constructor function to iniate the contract */
    constructor() public payable {
        owner = msg.sender;
        eventCount = 0;
    }
  
    function createEvent (string memory _name,uint _price, uint _timeOpen, uint _maxParticipants)
        public 
        payable
        returns (bool) 
    { 

        require(msg.value == eventCreationFee);

        uint expires = now + _timeOpen; 
        
        events.push(Event(
            {
             name: _name,
             eventNum: eventCount,
             price: _price,
             expiresOn: expires,
             maxParticipants: _maxParticipants,
             state: State.Open,
             organizer:  msg.sender
            }
        ));
        eventsByCreator[msg.sender].push(eventCount);

        /* Trigger event */
        emit eventCreated(eventCount);

        eventCount = eventCount + 1;
        return true;
    }
  
    function registerForEvent (uint _eventNum) 
        public
        payable
        notExpired(_eventNum)
        notFull(_eventNum)
        notClosed(_eventNum)
        returns (bool) 
    {

        // Checking the amount is no less or more than the price
        require(msg.value == events[_eventNum].price, "Wrong amount.");
        events[_eventNum].organizer.transfer(events[_eventNum].price);       
        participants[_eventNum].push(msg.sender);
        
        /* Trigger event */
        emit userRegistered(_eventNum);

        return true;
    }

    /* Organizer can close the event */  
    function closeEvent (uint _eventNum) public onlyOrganizer(_eventNum)  {
        events[_eventNum].state = State(1);
        emit eventClosed(_eventNum);
    } 
    
     /* Organizer can open the event */  
    function openEvent (uint _eventNum) public onlyOrganizer(_eventNum)  {
        events[_eventNum].state = State(0);
        emit eventOpened(_eventNum);
    } 
    
    
    function getEventsByCreator(address _creator) external view returns (uint[] memory) {
        return eventsByCreator[_creator];
    }
    
    function getParticipantCount(uint _eventNum) public view returns (uint) {
        return participants[_eventNum].length;
    }

    function withdrawFees() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    /* Set fee in Wei, initial 0.01 ETH equals 10 000 000 000 000 000 Wei */
    function setCreationFee(uint _fee) external onlyOwner {
        eventCreationFee = _fee;
    }
    
    /* Reads current fee in Wei */
    function getCreationFee() external view returns(uint) {
        return eventCreationFee;  
    }
    
 }