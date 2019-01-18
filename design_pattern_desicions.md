### Design patterns and desicions

With the rapid pace, in which the development tools are progressing on Ethereum, the recently released Solidity version 5 was clear choice over the version 4 to use.

The the contract structure follows https://solidity.readthedocs.io/en/v0.5.2/style-guide.html style guide. Some part of the code could have been broken into separate contracts, and have the main contract to inhererit functions, but I felt a structure to have a single main contract to be more lean, than a several smaller contracts.  

The user interface is quite bare-bones, using a single HTML-file and Javascript libraries to manage inputs and outputs for the smart contract. Given the smart contract centric focus of the course, the simple-as-possible approach to build the user interface was a conscious choice. For a more complex project some Javascript framework like React could also be a good choice to build an user interface.

Tools used building the user interface:

- [web3.js Ethereum JavaScript API](https://web3js.readthedocs.io/en/1.0/)
- [jQuery](https://jquery.com)
- [Bootstrap](https://getbootstrap.com) 
- [Notify.js](https://notifyjs.jpillora.com)
- [DataTables](https://datatables.net)      

Things to improve

-Adding more functionality like Early bird discounts and late fees.
-Tokenization on registrations to allow participants to transfer and sell their signups.
-Uport integration