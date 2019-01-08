# final-project-jukkakekalainen

The final project for the Consensys Academy demonstrates fully working Dapp (a decentralized application),
build on Ethereum blockchain, with Solidity smart contracts.

### General use registration Dapp

 - Allows the organizer to create free or priced events with wanted maximum participation cap and expiry time.
 - The user uses web interface to register on events.
 - Ethereum address is the registration ID for the user.
 - When user register on on priced event, the payment goes directly to the organizers Ethereum address.  
 - A small fee is taken from the organizer on event creation.

### Live on the Rinkeby Testnet 

[link](https://) Requires [MetaMask](https://metamask.io) browser extension.


### Installation on Ubuntu Linux environment

This project uses [Truffle](https://truffleframework.com), that includes Solidity compiler and [Ganache](https://github.com/trufflesuite/ganache-cli) to simulate blockchain. 

```sh
$ npm install truffle -g
$ npm install -g ganache-cli
$ git clone https://github.com/dev-bootcamp-2019/final-project-jukkakekalainen.git
$ cd final-project-jukkakekalainen
$ ganache-cli
$ truffle deploy
```

### Testing while ganache running on background 
```sh
$ truffle test
Using network 'development'.

  Contract: RegistrationSystem
    ✓ should create an free to participate event (133ms)
    ✓ should create an priced event (114ms)
    ✓ should allow registering (61ms)
    ✓ should revert due wrong amount (61ms)
    ✓ should fail due too many participants (285ms)

5 passing (701ms)
  
```