// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IGOSetUp} from "./setUp/IGOSetUp.t.sol";

contract RevertIGO_Test_reserveAllocation is IGOSetUp {
    uint256 constant amount = 10 ether;

    function testRevert_reserveAllocation_If_UserNotAddedToMerkleTreeAtAll()
        public
    {
        _setUpTestData();
        permission.deadline = defaultSigDeadline;

        // `alice` is not in any leaves of the tree so all allocation
        // containing msg.sender must fail
        for (uint256 i; i < leaves.length; ++i) {
            _generateMerkleRootAndProofForLeaf(i);

            (address alice, uint256 key) = makeAddrAndKey("alice");
            allocations[i].account = alice;
            privateKeyOf[alice] = key;

            bytes memory sig = _getPermitTransferSignature(
                _createPermit(
                    address(token),
                    allocations[i].maxAllocation,
                    uint256(bytes32(keccak256(abi.encode(allocations[i]))))
                ),
                address(instance),
                privateKeyOf[allocations[i].account]
            );
            permission.signature = sig;

            vm.prank(alice);
            // reverts wit "ALLOCATION_NOT_FOUND", but issue when using string
            vm.expectRevert();
            instance.reserveAllocation(
                amount,
                allocations[i],
                lastProof,
                permission
            );
        }
    }
}
