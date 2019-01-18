## Avoiding common attacks

### Access restriction

Restricting access is a common pattern for contracts and on this contract modifiers are used to set some functions to only allow contract owner or an event organizer to use them. If error happens, all changes to the contract state are reverted. For example a random participant can not close someone else's event. Another use of modifiers is to check that participants can not register for an full event and is the payment amount is correct. 

### Integer Overflow and Underflow

The contract uses [OpenZeppelin SafeMath library](https://github.com/OpenZeppelin/openzeppelin-solidity) to safety check math operations for overflow and underflows. 

### Security tools

Using [Slither](https://github.com/trailofbits/slither), the Solidity source analyzer, helped to indentify some unnecessary public function visibilities, when declaring external function was a more appropriate choice.

### Conract lifecycle

Owner of the contract can terminate the contract using Kill-function, that removes the code from blockchain and return funds. 