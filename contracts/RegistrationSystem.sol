pragma solidity ^0.5.0;

/// @title A general use event registration demo for ConsenSys Academy
/// @author Jukka Kekalainen 

import './zeppelin/SafeMath.sol';

contract RegistrationSystem {

    // Using SafeMath library to mitigate overflows and underflows 
    using SafeMath for uint256;
    
    // Modifiers to halt execution if conditions are not met 

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner.");
        _;
    }
    
    // Registration time needs to be earlier than expiration 
    modifier notExpired(uint _eventNum) {
        require(now <= events[_eventNum].expiresOn, "Expired event.");
        _;
    }
    
    // Checking for full event, indexing start from zero
    modifier notFull(uint _eventNum) {
        require(getParticipantCount(_eventNum) <= events[_eventNum].maxParticipants.sub(1), "Event is full.");
        _;
    }
    
    // Event must be open for registration
    modifier notClosed(uint _eventNum) {
        require(uint(events[_eventNum].state) == 0, "Event is closed.");
        _;
    }
    
    // Checking sender to be event creator
    modifier onlyOrganizer(uint _eventNum) {
        require(msg.sender == events[_eventNum].organizer, "Only organizer.");
        _;
    }

    //Circuit breaker not active
    modifier notPaused(){
        require(contractPaused == false, "Paused.");
        _;
    }
    
    // Events for logging actions
    event eventCreated(uint _num);
    event userRegistered(uint _num);
    event eventClosed(uint _num);
    event eventOpened(uint _num);
    event eventExtented(uint _num);


    // Contract owner
    address payable owner;

    // Is contract paused
    bool contractPaused; 

    // Number of events, also used as ID for the events-variable 
    uint eventCount;
    
    // The contract can be set to cumulate a small fee on event creation
    uint eventCreationFee = 0.00 ether;
    
    // An event can be open or closed
    enum State {Open, Closed}

    // A struct defines properties of an single event 
    struct Event {
        string name;
        uint eventNum;    
        uint price; //in wei
        uint expiresOn;
        uint maxParticipants;
        State state;
        address payable organizer;
    }

    // All events
    Event[] public events;

    //Storing event creators and participants in mappings
    mapping (uint => address payable[]) public participants;
    mapping (address => uint[]) public eventsByCreator;
  
    // A constructor function to iniate the contract
    constructor() public payable {
        owner = msg.sender;
        eventCount = 0;
        contractPaused = false;
    }
  
    /**
    * @dev Orginizers can create events
    * @param _name for the event
    * @param _price price for the event in wei
    * @param _timeOpen time that registration remains open in seconds
    * @param _maxParticipants maximum participants for the event
    * @return true after complete operation
    */
    function createEvent (string memory _name,uint _price, uint _timeOpen, uint _maxParticipants)
        public 
        payable
        notPaused()
        returns (bool) 
    { 

        // Message value must match eventCreation fee
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

        // Trigger event
        emit eventCreated(eventCount);

        eventCount = eventCount.add(1);
        return true;
    }
  
    /**
    * @dev Participants can register for event
    * @param _eventNum event number to register for
    * @return true after complete operation
    */
    function registerForEvent (uint _eventNum) 
        external
        payable
        notExpired(_eventNum)
        notFull(_eventNum)
        notClosed(_eventNum)
        notPaused()
        returns (bool) 
    {

        // Checking the amount is no less or more than the price
        require(msg.value == events[_eventNum].price, "Wrong amount.");
        
        // Sending payment to the organizer
        events[_eventNum].organizer.transfer(events[_eventNum].price);  

        // Adding participant to the event     
        participants[_eventNum].push(msg.sender);
        
        // Trigger event
        emit userRegistered(_eventNum);

        return true;
    }

    /**
    * @dev Orginizers can close anevent
    * @param _eventNum event number to close
    */
    function closeEvent (uint _eventNum) external onlyOrganizer(_eventNum) notPaused()  {
        events[_eventNum].state = State(1);
        emit eventClosed(_eventNum);
    } 
    
    /**
    * @dev Orginizers can open closed event
    * @param _eventNum event number to open
    */
    function openEvent (uint _eventNum) external onlyOrganizer(_eventNum) notPaused()  {
        events[_eventNum].state = State(0);
        emit eventOpened(_eventNum);
    } 

    /**
    * @dev Orginizers can open closed event
    * @param _eventNum event number to extend
    * @param _seconds extented time on seconds
    */
    function extendEvent (uint _eventNum, uint _seconds) external onlyOrganizer(_eventNum) notPaused()  {
        events[_eventNum].expiresOn = events[_eventNum].expiresOn.add(_seconds);
        emit eventExtented(_eventNum);
    } 
    
    
    /**
    * @dev Read events created by an address
    * @param _creator Event creator
    * @return Event numbers created by an address 
    */
    function getEventsByCreator(address _creator) external view returns (uint[] memory) {
        return eventsByCreator[_creator];
    }
    
    /**
    * @dev Read participant addresses of an event
    * @param _eventNum Number of an event
    * @return Addresses of participants
    */
    function getRegisteredAddresses(uint _eventNum) external view returns (address payable[] memory) {
        return participants[_eventNum];
    }

    /**
    * @dev Read number participant count of single event 
    * @param _eventNum Number of an event
    * @return Number of participants
    */
    function getParticipantCount(uint _eventNum) public view returns (uint) {
        return participants[_eventNum].length;
    }

    /**
    * @dev Read event price
    * @param _eventNum Number of an event
    * @return Price in wei
    */
    function getEventPrice(uint _eventNum) public view returns (uint) {
        return  events[_eventNum].price;
    }

    /**
    * @dev Contract owner can withdraw fees cumulated by event creation
    */
    function withdrawFees() external onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    /**
    * @dev Set fee in Wei, initial 0.01 ETH equals 10 000 000 000 000 000 Wei
    */
    function setCreationFee(uint _fee) external onlyOwner {
        eventCreationFee = _fee;
    }
    
    /**
    * @dev Reads current fee in Wei
    */
    function getCreationFee() external view returns(uint) {
        return eventCreationFee;  
    }

    /**
    * @dev Returns the number of created events
    */
    function getEventCount() external view returns (uint) {
        return eventCount;
    }
    
    /**
    * @dev Returns the details of an single event form events-variable 
    * @param _eventNum Event number
    * @return output_name is a name of the event
    * @return output_eventNum is an ID integer of the event
    * @return output_price is price of the event in wei
    * @return output_expiresOn is a timestamp of the expiry of the event in seconds 
    * @return output_maxParticipants is the maximum amount of participants for the event  
    * @return output_registered is the number of registered participants fot the event
    */
    function getEventDetails (uint _eventNum) external view 
        returns (
            string memory output_name,
            uint output_eventNum,
            uint output_price,
            uint output_expiresOn,
            uint output_maxParticipants,
            uint output_registered
        ) 
    {
        output_name = events[_eventNum].name;  
        output_eventNum = events[_eventNum].eventNum; 
        output_price = events[_eventNum].price; 
        output_expiresOn = events[_eventNum].expiresOn; 
        output_maxParticipants = events[_eventNum].maxParticipants; 
        output_registered = getParticipantCount(_eventNum);
    }

    /**
    * @dev Circuit breaker pattern, owner can pause and unpause the contract 
    */
    function circuitBreaker() public onlyOwner {
        if (contractPaused == false) {
            contractPaused = true; 
        }
        else {
            contractPaused = false; 
        }
    }

    /**
    * @dev Destroy the contract, sending its funds to the contract owner
    */
    function kill () external onlyOwner {
        selfdestruct(owner);
    }
    
 }