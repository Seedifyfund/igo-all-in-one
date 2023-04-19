const ethers = require('ethers');
const { MerkleTree } = require('merkletreejs');

const args = process.argv.slice(2);

if (args.length !== 2) {
    console.log(`please supply the correct parameters:
    leaves: the leaves of the merkle tree - transformed to bytes then bytes to string
    nodeIndex: the index of the node to generate a proof for
  `);
    process.exit(1);
}

const coder = ethers.utils.defaultAbiCoder;

async function main(leaves, nodeIndex) {
    const array = ethers.utils.arrayify(leaves);

    const decodedLeaves = coder.decode(['bytes32[]'], array);

    // console.log('decodedLeaves', decodedLeaves[0]);

    const tree = new MerkleTree(decodedLeaves[0], ethers.utils.keccak256, {
        sortPairs: true,
    });
    const root = tree.getHexRoot();

    const proof = tree.getHexProof(decodedLeaves[0][parseInt(nodeIndex)]);

    // console.log('root', root);
    // console.log('proof', proof);

    const coded = coder.encode(['bytes32', 'bytes32[]'], [root, proof]);

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
