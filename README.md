# <h1 align="center"> Foundryx Hardhat Template </h1>

Contract to use for normal & VPR IGO but also any other extra cases where a project wants to allow people to buy tokens at a set price.

More details on [Confluence](https://seedifymetastudios.atlassian.net/l/cp/bcc1Xhfr)

# Tests

-   Run without fuzz testing, use `forge test -vvv --nmc Differential`
-   Run with fuzz testing, use `forge test -vvv --ffi` (takes more time as it produced random data)

## Generate Coverage Report

If `lcov` is not installed, run `brew install lcov`.
Then run: `forge coverage --report lcov --ffi --nmc Differential && genhtml lcov.info --branch-coverage --output-dir coverage`

## Coverage Screenshot

<img width="1501" alt="igo-coverage" src="https://user-images.githubusercontent.com/37904797/234664715-e7806581-c14c-4ac2-91c4-224d8724a2f1.png">
