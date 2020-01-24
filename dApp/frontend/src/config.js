var RealEstateNetworkTokenContract = require('../../code/RealEstateNetworkTokenContract.sol')
var RealEstateNetworkTokenExchange = require('../../code/RealEstateNetworkTokenExchange.sol')

module.exports = {
    JSONRPC_ENDPOINT: 'http://52.59.238.144:8545',
    JSONRPC_WS_ENDPOINT: 'ws://52.59.238.144:8546', //'ws://52.59.238.144:8546',
    BZZ_ENDPOINT: 'http://52.59.238.144:8500',
    SHH_ENDPOINT: 'ws://52.59.238.144:8546',

    REALESTATENETWORKTOKENCONTRACT_ADDRESS: '0xE048BCE0ec53179898e64b7ceE9083cd6433F2D3',
    REALESTATENETWORKTOKENEXCHANGE_ADDRESS: '0xdCbD989AC0ED112Fd3fF8281Ee63AF759E43A214',

    REALESTATENETWORKTOKENCONTRACT_ABI: RealEstateNetworkTokenContract.abi,
    REALESTATENETWORKTOKENEXCHANGE_ABI: RealEstateNetworkTokenExchange.abi,

    GAS_AMOUNT: 500000,

    //whisper settings
    WHISPER_SHARED_KEY: '0x8bda3abeb454847b515fa9b404cede50b1cc63cfdeddd4999d074284b4c21e15'

}

// web3.eth.sendTransaction({from: web3.eth.accounts[0], to: "0x6f0023D1CFe5A7A56F96e61E0169B775Ac97f90E" , value: web3.utils.toWei(1, 'ether'), gasLimit: 21000, gasPrice: 20000000000})
