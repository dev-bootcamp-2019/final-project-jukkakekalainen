# final-project-jukkakekalainen

The final project for the Consensys Academy demonstrates fully working Dapp (a decentralized application),
build on Ethereum blockchain, with Solidity smart contracts.

### General use registration Dapp

 - Allows the organizer to create free or priced events with wanted maximum participation cap and expiry time.
 - The user uses web interface to register on events.
 - Ethereum address is the registration ID for the user.
 - When user register on on priced event, the payment goes directly to the organizers Ethereum address.   

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