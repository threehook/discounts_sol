pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { Structs as str } from './Structs.sol';
import { Validations as val } from './Validations.sol';
import { Utils as utils } from './Utils.sol';

contract DiscountContract {

    // event Inserted(address indexed owner, address indexed partner);
    // event Updated(address indexed owner, address indexed partner);
    // event Deleted(address indexed owner, address indexed partner);

    // All owner agreements
    mapping(bytes20 => str.DiscountAgreement) private allAgreements;

    mapping(address => str.DiscountAgreement[]) private pendingOwnerAgreements;

    mapping(address => str.DiscountAgreement[]) private approvedOwnerAgreements;

    mapping(address => str.DiscountAgreement[]) private activeOwnerAgreements;

    mapping(address => str.DiscountAgreement[]) private expiredOwnerAgreements;

    mapping(address => str.DiscountAgreement[]) pendingPartnerAgreements;    

    mapping(address => str.DiscountAgreement[]) approvedPartnerAgreements;
    
    mapping(address => str.DiscountAgreement[]) expiredPartnerAgreements;

    // The constructor
    constructor() public {
    }    

    function insertAgreement(address partnerAddress, str.DiscountAgreement memory agreement) public returns (bytes20){
        // First check if agreement already exists or overlaps
        // uint[] memory result = new uint[](n);
        str.AgreementStateType[] memory stateTypes = new str.AgreementStateType[](2);
        stateTypes[0] = str.AgreementStateType.AgreementPending;
        stateTypes[1] = str.AgreementStateType.AgreementApproved;
        require(val.agreementIsValid(agreement, allAgreements[msg.sender], stateTypes), "Invalid agreement received.");

        // Add a unique id
        // TODO: Think of address being a better id instead of bytes20
        agreement.id = utils.createUniqueId();

        // Add new pending discount agreement in owner map
        // bytes memory id = abi.encode(str.DiscountAgreementKey({owner: msg.sender, partner: agreement.partner, startDate: agreement.startDate, endDate: agreement.endDate}));
        agreement.state = str.AgreementStateType.AgreementPending;
        agreement.index = pendingOwnerAgreements[msg.sender].length;
        pendingOwnerAgreements[msg.sender].push(agreement);
        allAgreements[agreement.id] = agreement;
        
        // Also add this new pending discount agreement in partner map
        pendingPartnerAgreements[partnerAddress].push(agreement);

        // emit Inserted(msg.sender, _partner);

        return agreement.id;
    }
    
    // function deleteAgreement(address partnerAddress) private {
        
    // }

    // Check if partner address is in pending owner agreements
    function isPendingAgreement(bytes20 id) private view returns (bool) {
        require(allAgreements[id].owner != address(0), "Agreement not found");
        return (allAgreements[id].state == str.AgreementStateType.AgreementPending);
    }    

    // Check if partner address is in approved owner agreements
    function isApprovedAgreement(bytes20 id) private view returns (bool) {
        require(allAgreements[id].owner != address(0), "Agreement not found");
        return (allAgreements[id].state == str.AgreementStateType.AgreementApproved);        
    }

    function updateAgreement(str.DiscountAgreement memory agreement) public returns(bool) {
        // TODO: Check if the id is owned by msg.sender
        require(bytes20(agreement.id).length == 20, "Invalid agreement id.");
        require(isPendingAgreement(agreement.id), "Agreement not found (in state pending).");
        checkIdIndexPair(agreement);

        // Check if agreement already exists or overlaps
        str.DiscountAgreement[] memory mergedAgreements = concatenateArrays(pendingOwnerAgreements[msg.sender], approvedOwnerAgreements[msg.sender]);
        val.agreementIsValid(agreement, mergedAgreements);

        // Delete the updated agreement
        str.DiscountAgreement memory agreementToBeDeleted = allAgreements[agreement.id];
        deletePendingAgreement(agreementToBeDeleted);
        
        // Insert the changed discount agreement as if it were a new one
        insertAgreement(agreement.partner, agreement);
        // emit Updated(msg.sender, partner);

        return true;
    }

    // Delete a pending agreement because it will be updated
    function deletePendingAgreement(str.DiscountAgreement memory agreement) private {
        uint rowToDelete = agreement.index;
        // str.DiscountAgreement memory keyToMove = pendingOwnerAgreementIndex[pendingOwnerAgreementIndex.length-1];
        bytes20 keyToMove = pendingOwnerAgreements[msg.sender][pendingOwnerAgreements[msg.sender].length-1].id;
        allAgreements[keyToMove].index = rowToDelete;
        pendingOwnerAgreements[msg.sender][rowToDelete] = allAgreements[keyToMove];
        pendingOwnerAgreements[msg.sender].length--;
    }

    function getExistingAgreements() public view returns(str.DiscountAgreement[] memory) {
         return concatenateArrays(getPendingOwnerAgreements(), getApprovedOwnerAgreements());
    }

    function getAllOwnersAgreements() public view returns(str.DiscountAgreement[] memory) {
         return concatenateArrays(concatenateArrays(getPendingOwnerAgreements(), getApprovedOwnerAgreements()), getExpiredOwnerAgreements());
    }

    function getPendingOwnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return pendingOwnerAgreements[msg.sender];
    }

   function getApprovedOwnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return approvedOwnerAgreements[msg.sender];
    }

   function getExpiredOwnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return expiredOwnerAgreements[msg.sender];
    }

    function getAllPartnerAgreements() public view returns(str.DiscountAgreement[] memory) {
         return concatenateArrays( concatenateArrays(getPendingPartnerAgreements(), getApprovedPartnerAgreements()), getExpiredPartnerAgreements());
    }

    function getPendingPartnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return pendingPartnerAgreements[msg.sender];
    }

   function getApprovedPartnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return approvedPartnerAgreements[msg.sender];
    }

   function getExpiredPartnerAgreements() public view returns(str.DiscountAgreement[] memory) {
        return expiredPartnerAgreements[msg.sender];
    }

    // Approve - Approves given agreement
    function approve(bytes20 id) public returns (bool) {
        bool success = false;
        str.DiscountAgreement memory agreement = allAgreements[id];
        require(agreement.owner != address(0), "Agreement not found.");
        require(isPendingAgreement(agreement.id), "Agreement to be approved not found (in state pending).");
        agreement.state = str.AgreementStateType.AgreementActive;
        allAgreements[id] = agreement;
        pendingOwnerAgreements[msg.sender][agreement.index] = agreement;
        success = true;
        return success;
    }
    
    function checkIdIndexPair(str.DiscountAgreement memory agreement) private view {
        require(allAgreements[agreement.id].index == agreement.index, "Agreement id and index do not pair.");        
    }
    

    // function pruneExpired() public view returns(bool success) {
    // 
    // }


    // TODO: Check if this can be simpler
    function concatenateArrays(str.DiscountAgreement[] memory agrs1, str.DiscountAgreement[] memory agrs2)  private pure returns(str.DiscountAgreement[] memory) {
        str.DiscountAgreement[] memory returnAgrs = new str.DiscountAgreement[](agrs1.length + agrs2.length);
    
        uint i=0;
        for (; i < agrs1.length; i++) {
            returnAgrs[i] = agrs1[i];
        }
    
        uint j=0;
        while (j < agrs1.length) {
            returnAgrs[i++] = agrs2[j++];
        }
    
        return returnAgrs;
    } 
}



    

