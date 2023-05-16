/**
 * Permit2.permitTransferFrom is a mix between EIP=712 sginature and ERC-20
 * transferFrom, like Dai.permit.
 */

/**
 * Off-chain signature to allow ERC20 transfer from user to Seedify wallet
 *
 * @param {ethers.Wallet} wallet - Wallet instance
 *
 * @param {Object} domain - Domain of `Permit2` deployed by Uniswap, see `test/foundry/differential_testing/permit2.permitTransferFrom.t.js`
 * @param {string} domain.name - Name of the contract passed in EIP712 constructor
 * @param {ethers.BigNumber} domain.chaindId - Chain id where the contract is deployed
 * @param {string} domain.contractAddr - Address of the contract
 *
 * @param {string} permitCaller - Contract calling permit2 (IGO contract in this case)
 *
 * @param {Object} permitTransferFrom - Defined by Uniswap {@link https://github.com/Uniswap/permit2/blob/main/src/interfaces/ISignatureTransfer.sol#L28|PermitransferFrom}
 */
async function permit2(signer, domain, permitCaller, permitTransferFrom) {
    const types = {
        TokenPermissions: [
            { type: 'address', name: 'token' },
            { type: 'uint256', name: 'amount' },
        ],
        PermitTransferFrom: [
            { type: 'TokenPermissions', name: 'permitted' },
            { type: 'address', name: 'spender' },
            { type: 'uint256', name: 'nonce' },
            { type: 'uint256', name: 'deadline' },
        ],
    };

    return await signer._signTypedData(domain, types, {
        permitted: permitTransferFrom.permitted,
        spender: permitCaller,
        nonce: permitTransferFrom.nonce,
        deadline: permitTransferFrom.deadline,
    });
}

module.exports = { permit2 };
