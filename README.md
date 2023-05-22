# <h1 align="center"> Foundryx Hardhat Template </h1>

Contract to use for normal & VPR IGO but also any other extra cases where a project wants to allow people to buy tokens at a set price.

More details on [Confluence](https://seedifymetastudios.atlassian.net/l/cp/bcc1Xhfr)

### Install

```bash
yarn install && forge install
```

Each time a new dependency is added in `lib/` run `forge install`.

## Tests

Since Permit 2 has been integrated ` --via-ir` compilation is compulsory to solve `stak too deep` issue.

-   Run without fuzz testing, use `forge test -vvv --nmc Differential --via-ir`
-   Run with fuzz testing, use `forge test -vvv --ffi --via-ir` (takes more time as it produced random data)

### Generate Coverage Report

If `lcov` is not installed, run `brew install lcov`.
Then run: `forge coverage --report lcov --ffi --nmc Differential && genhtml lcov.info --branch-coverage --output-dir coverage`

### Coverage Screenshot

<img width="1501" alt="igo-coverage" src="https://user-images.githubusercontent.com/37904797/235130979-e8b8c02c-927e-47be-bfb9-5603aa35f259.png">

### Run GitHub Actions Locally

1. Install [act](https://github.com/nektos/act)
2. Load env var `source .env`
3. Run a job: `act -j foundry -s SEED` (hit ENTER when asked `Provide value for 'SEED':`)

## Run Advanced Tests

### Slither

`slither .`

Note: Slither has been added to GitHub actions, so it will run automatically on every **push and pull requests**.

### Mythril

`myth a src/IGO.sol --solc-json mythril.config.json` (you can use both `myth a` and `mythril analyze`)
