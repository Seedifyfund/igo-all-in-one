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

### Manticore

1. Run Docker container:

```
docker run --rm -it --platform linux/amd64 \
-v $(pwd):/home/igo \
baolean/manticore:latest
```

2. Go to mounted volume location: `cd /home/igo`

3. Select Solidity version

```
solc-select install 0.8.17 && solc-select use 0.8.17
```

4. Run manticore:

```
manticore src/IGO.sol --contract IGO --solc-remaps="openzeppelin-contracts/=lib/openzeppelin-contracts/contracts/ permit2/=lib/permit2/src/"
```

### SuMo

After install yarn dependencies, run `yarn sumo test` to run mutation testing.

_Note: there issues as we can specificy `--ffi` parameter when compiling with forge_

### Gambit

1. Install it locally, [see GitHub](https://github.com/Certora/gambit?utm_campaign=Gambit%20Release&utm_source=Medium&utm_medium=Blog#installation)

2. Run: `gambit mutate --json gambit-conf.json`

_Note: gambit does not take into account specified remappings_

# Best Practices to Follow

## Generics

-   Code formatter & linter: prettier, solhint, husky, lint-staged & husky
-   [Foundry](https://book.getfoundry.sh/tutorials/best-practices)

## Security

-   [Solidity Patterns](https://github.com/fravoll/solidity-patterns)
-   [Solcurity Codes](https://github.com/transmissions11/solcurity)
-   Secureum posts _([101](https://secureum.substack.com/p/security-pitfalls-and-best-practices-101) & [101](https://secureum.substack.com/p/security-pitfalls-and-best-practices-201): Security Pitfalls & Best Practice)_
-   [Smart Contract Security Verification Standard](https://github.com/securing/SCSVS)
-   [SWC](https://swcregistry.io)

# Be Prepared For Audits

Must Do Checklist:

-   [x] Unit ([TDD](https://r-code.notion.site/TDDs-steps-cecba0a82ee6466f9f479ca553949be2)) & integration (BDD) tests (green)
-   [x] Well refactored & commented code
    -   _Use where needed: NatSpec comment, [PlantUML](https://plantuml.com/starting), [Sol2UML](https://github.com/naddison36/sol2uml) (UML for Solidity)_
-   Internal Audit - Tool Suite
    -   [x] Secureum articles
        -   [Audit Techniques & Tools 101](https://secureum.substack.com/p/audit-techniques-and-tools-101)
        -   [Audit Findings 101](https://secureum.substack.com/p/audit-findings-101)
        -   [Audit Findings 201](https://secureum.substack.com/p/audit-findings-201)
    -   [x] Built in Foundry:
        -   [x] fuzz testing: generate (semi-)random inputs
            -   _There is also echidna which can be used_
        -   [x] differential testing
        -   [x] invariant testing
    -   [x] Static analysers: **mythril**, **slither** (GitHub actions), securify, smartcheck, oyente
        -   _Note: solidity smt checker can be used on top for formal verification testing_
    -   [x] Symbolic execution: manticore
    -   [x] Mutation testing: SuMo, Gambit, universalmutator
    -   [ ] Audit report generator: MythX

_Note: For more complex contract **Paper code review** should be considered to check for conception & logic errors._

Other tools for a deeper analysis:

-   static binary EVM analysis: rattle
-   control flow graph: surya (integrated into VSCode extension), evm_cfg_builder
-   disassemble EVM code: ethersplay, pyevmasm
-   runtime verification: scribble (also done by: mythril, harvey, mythx)
-   JSON RPC multiplexer, analysis tool wrapper & test integration tool: etheno (Ethereum testing Swiss Army knife)
    -   _eliminates the complexity of tools like Echidna on large, multi-contract projects_
