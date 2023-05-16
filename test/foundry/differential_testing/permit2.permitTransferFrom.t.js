const { ethers } = require('ethers');
require('dotenv').config();
const { permit2 } = require('../../../scripts/permit2.permitTransferFrom');

const coder = ethers.utils.defaultAbiCoder;

const args = process.argv.slice(2);

if (args.length !== 4) {
    console.log('please supply rewards contract address as argument');
    process.exit(1);
}

async function permit2Test(
    chainId,
    contractAddr,
    permitCaller,
    permitTransferFrom
) {
    const permitArray = ethers.utils.arrayify(permitTransferFrom);
    const decodedPermit_ = coder.decode(
        [
            'PermitTransferFrom(TokenPermissions(address token,uint256 amount) permitted,uint256 nonce,uint256 deadline)',
        ],
        permitArray
    );
    const permitTransferFrom_ = decodedPermit_[0];
    // console.log('permitTransferFrom_:', permitTransferFrom_);

    const wallet = new ethers.Wallet.fromMnemonic(process.env.SEED);

    const domain = {
        name: 'Permit2',
        chainId: chainId,
        verifyingContract: contractAddr,
    };

    const signature = await permit2(
        wallet,
        domain,
        permitCaller,
        permitTransferFrom_
    );

    process.stdout.write(signature);
}

permit2Test(args[0], args[1], args[2], args[3])
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
