const ethers = require('ethers');
const { MerkleTree } = require('merkletreejs');

const args = process.argv.slice(2);

if (args.length !== 2) {
    console.log(`please supply the correct parameters:
    addresses[]: addresses to whitelist - transformed to bytes then bytes to string
    allocations[]: allocation per address - same as above
  `);
    process.exit(1);
}

const coder = ethers.utils.defaultAbiCoder;

async function main(addresses, allocations) {
    const addrArray = ethers.utils.arrayify(addresses);
    const allocationArray = ethers.utils.arrayify(allocations);

    const decodedAddrs = coder.decode(['address[]'], addrArray);
    const decodedAllocation = coder.decode(['uint256[]'], allocationArray);

    let leaves = [];
    for (let i = 0; i < decodedAddrs[0].length; ++i) {
        leaves.push(
            ethers.utils.solidityKeccak256(
                ['address', 'uint256'],
                [decodedAddrs[0][i], decodedAllocation[0][i]]
            )
        );
    }

    const coded = coder.encode(['bytes32[]'], [leaves]);

    process.stdout.write(coded);
}

// Pattern recommended to be able to use async/await everywhere
// and properly handle errors.
main(args[0], args[1])
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
