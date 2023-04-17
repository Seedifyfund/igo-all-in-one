const hre = require('hardhat');

// npx hardhat run --network goerli scripts/deploy.js
async function main() {
    const IGO = await hre.ethers.getContractFactory('IGO');
    const igo = await IGO.deploy();

    await igo.deployed();

    console.log(`Deployed to ${igo.address}`);

    await hre.run('verify:verify', {
        address: igo.address,
        // see: https://hardhat.org/hardhat-runner/plugins/nomiclabs-hardhat-etherscan#using-programmatically
        constructorArguments: [],
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
