const ethers = require('ethers');
const { MerkleTree } = require('merkletreejs');

const args = process.argv.slice(2);

if (args.length !== 1) {
    console.log(`please supply the correct parameters:
    allocations_: array of Allocation object/struct - transformed to bytes, then bytes to string
  `);
    process.exit(1);
}

const coder = ethers.utils.defaultAbiCoder;

async function main(allocations_) {
    const allocationArray = ethers.utils.arrayify(allocations_);

    const decodedAllocations = coder.decode(
        ['Allocation(string tagId,address account,uint256 amount)[]'],
        allocationArray
    );
    const allocations = decodedAllocations[0];

    // console.log(allocations);
    // console.log(allocations[0].tagId);
    // console.log(allocations[0].account);
    // console.log(parseInt(ethers.utils.formatEther(allocations[0].amount)) + '\n');

    let rawEncoded;
    let leaves = [];
    let length = allocations.length;

    for (let i = 0; i < length; ++i) {
        rawEncoded = coder.encode(
            ['Allocation(string tagId,address account,uint256 amount)'],
            [
                [
                    allocations[i].tagId,
                    allocations[i].account,
                    allocations[i].amount,
                ],
            ]
        );

        leaves.push(ethers.utils.keccak256(rawEncoded));
    }

    const coded = coder.encode(['bytes32[]'], [leaves]);

    process.stdout.write(coded);
}

// Pattern recommended to be able to use async/await everywhere
// and properly handle errors.
main(args[0])
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
