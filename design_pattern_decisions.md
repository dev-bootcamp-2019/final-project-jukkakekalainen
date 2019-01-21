### Design patterns and desicions

With the rapid pace, in which the development tools are progressing on Ethereum, the recently released Solidity version 5 was clear choice over the version 4 to use.

The the contract structure follows https://solidity.readthedocs.io/en/v0.5.2/style-guide.html style guide. Some part of the code could have been broken into separate contracts, and have the main contract to inhererit functions, but I felt a structure to have a single main contract to be more lean, than a several smaller contracts. 

Basic functionality of the dapp:

 - Allows the organizer to create free or priced events with wanted maximum participation cap and expiry time.
 - The user uses web interface to register on events.
 - Ethereum address is the registration ID for the user.
 - When user register on priced event, the payment goes directly to the organizers Ethereum address.  
 - A small fee could be taken from the organizer on event creation.
 - The event organizer can open and close the event temporarily or extend the expiry time.
 - The contract owner can pause the contract, withdraw fees and terminate the contract.   

The user interface is a single HTML-file that uses Javascript libraries to manage inputs and outputs for the smart contract. Given the smart contract centric focus of the course, the simplistic approach to build the user interface was a conscious choice. For a more complex project some Javascript framework like React could also be a good choice to build an user interface.

Tools used building the user interface:

- [web3.js Ethereum JavaScript API](https://web3js.readthedocs.io/en/1.0/)
- [jQuery](https://jquery.com)
- [Bootstrap](https://getbootstrap.com) 
- [Notify.js](https://notifyjs.jpillora.com)
- [DataTables](https://datatables.net)      

