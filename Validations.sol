pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import { Structs as str } from './Structs.sol';

library Validations {

    function agreementIsValid(str.DiscountAgreement memory agreement, str.DiscountAgreement[] memory existingAgreements, str.AgreementStateType[] memory stateTypes) public view {
        // Check agreement dates
        checkDates(agreement);
        // Check if agreement already exists in pending or approved
        bytes memory agrBytes = abi.encode(str.DiscountAgreementKey({owner: agreement.owner, partner: agreement.partner, startDate: agreement.startDate, endDate: agreement.endDate}));
        for (uint i=0; i<existingAgreements.length; i++) {
            bool inStateTypes;
            for (uint j=0; j<stateTypes.length; j++) {
                inStateTypes = existingAgreements[i].state == stateTypes[j];
                if (inStateTypes) break;
            }
            if (!inStateTypes) continue;
            str.DiscountAgreement memory agreement2 = existingAgreements[i];
            bytes memory agr2Bytes = abi.encode(str.DiscountAgreementKey({owner: agreement2.owner, partner: agreement2.partner, startDate: agreement2.startDate, endDate: agreement2.endDate}));
            agreementsEqual(agrBytes, agr2Bytes);
        }
        // Check if agreement dates overlap
        for (uint i=0; i<existingAgreements.length; i++) {
            checkDateOverlap(agreement, existingAgreements[i]);
        }
    }    
    
    function checkDates(str.DiscountAgreement memory agreement) private view {
        uint256 startDate = agreement.startDate;
        uint256 endDate = agreement.endDate;
        // Start date before end date
        require(startDate <= endDate,  "Agreement startDate must be before or equal to endDate.");
        // No dates in the past
        require(startDate < now,  "Agreement startDate must not be in the past.");
    }    

    function agreementsEqual(bytes memory agr1Bytes, bytes memory agr2Bytes) private pure {
        // Just compare the output of hashing all fields
        require(keccak256(agr1Bytes) != keccak256(agr2Bytes), "Agreement already exists.");
    }    
    
    function checkDateOverlap(str.DiscountAgreement memory agreement1, str.DiscountAgreement memory agreement2) private pure {
        string memory overlapError = "agreement period (startDate-enddate) must not overlap with existing agreement.";
        // Compare the start- and enddates of both agreements
        require(agreement2.startDate > agreement1.startDate && agreement2.startDate < agreement1.endDate, overlapError);
        require(agreement1.startDate > agreement2.startDate && agreement1.startDate < agreement2.endDate, overlapError);
        require(agreement2.endDate > agreement1.startDate && agreement2.endDate < agreement1.endDate, overlapError);
        require(agreement1.endDate > agreement2.startDate && agreement1.endDate < agreement2.endDate, overlapError);
    }    
}