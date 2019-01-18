pragma solidity ^0.5.0;

/// @title A general use event registration demo for ConsenSys Academy
/// @author Jukka Kekalainen 

import './zeppelin/SafeMath.sol';

contract RegistrationSystem {

    /* Using SafeMath library to mitigate overflows and underflows */
    using SafeMath for uint256;
    
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
        require(getParticipantCount(_eventNum) <= events[_eventNum].maxParticipants.sub(1), "Event is full.");
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
    event eventExtented(uint _num);


    /* Contract owner */
    address payable owner;

    /* Number of events, also used as ID for the events-variable  */
    uint eventCount;
    
    /* The contract can be set to cumulate a small fee on event creation */
    uint eventCreationFee = 0.00 ether;
    
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
  
    /**
    * @notice Orginizers can create events
    * @param _name for the event
    * @param _price price for the event in wei
    * @param _timeOpen time that registration remains open in seconds
    * @param _maxParticipants maximum participants for the event
    * @return true after complete operation
    */
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

        eventCount = eventCount.add(1);
        return true;
    }
  
    /**
    * @notice Participants can register for event
    * @param _eventNum event number to register for
    * @return true after complete operation
    */
    function registerForEvent (uint _eventNum) 
        external
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

    /**
    * @notice Orginizers can close anevent
    * @param _eventNum event number to close
    */
    function closeEvent (uint _eventNum) external onlyOrganizer(_eventNum)  {
        events[_eventNum].state = State(1);
        emit eventClosed(_eventNum);
    } 
    
    /**
    * @notice Orginizers can open closed event
    * @param _eventNum event number to open
    */
    function openEvent (uint _eventNum) external onlyOrganizer(_eventNum)  {
        events[_eventNum].state = State(0);
        emit eventOpened(_eventNum);
    } 

    /**
    * @notice Orginizers can open closed event
    * @param _eventNum event number to extend
    * @param _seconds extented time on seconds
    */
    function extendEvent (uint _eventNum, uint _seconds) external onlyOrganizer(_eventNum)  {
        events[_eventNum].expiresOn = events[_eventNum].expiresOn.add(_seconds);
        emit eventExtented(_eventNum);
    } 
    
    
    /**
    * @notice Read events created by an address
    * @param _creator Event creator
    * @return Event numbers created by an address 
    */
    function getEventsByCreator(address _creator) external view returns (uint[] memory) {
        return eventsByCreator[_creator];
    }
    
    /**
    * @notice Read number participant count of single event 
    * @param _eventNum Number of an event
    * @return Number of participants
    */
    function getParticipantCount(uint _eventNum) public view returns (uint) {
        return participants[_eventNum].length;
    }

    /**
    * @notice Read event price
    * @param _eventNum Number of an event
    * @return Price in wei
    */
    function getEventPrice(uint _eventNum) public view returns (uint) {
        return  events[_eventNum].price;
    }

    /* @notice Contract owner can withdraw fees cumulated by event creation */
    function withdrawFees() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    /* @notice Set fee in Wei, initial 0.01 ETH equals 10 000 000 000 000 000 Wei */
    function setCreationFee(uint _fee) external onlyOwner {
        eventCreationFee = _fee;
    }
    
    /* @notice Reads current fee in Wei */
    function getCreationFee() external view returns(uint) {
        return eventCreationFee;  
    }

    /* @notice Returns the number of created events */
    function getEventCount() external view returns (uint) {
        return eventCount;
    }
    
    /**
    * @notice Returns the details of an single event form events-variable 
    * @param _eventNum Event number
    */
    function getEventDetails (uint _eventNum) external view 
        returns (
            string memory output_name,
            uint output_eventNum,
            uint output_price,
            uint output_expiresOn,
            uint output_maxParticipants
        ) 
    {
        output_name = events[_eventNum].name;  
        output_eventNum = events[_eventNum].eventNum; 
        output_price = events[_eventNum].price; 
        output_expiresOn = events[_eventNum].expiresOn; 
        output_maxParticipants = events[_eventNum].maxParticipants; 
        
    }

    /* Destroy the contract, sending its funds to the owner */
    function kill () external onlyOwner {
        selfdestruct(owner);
    }
    
 }