pragma solidity ^0.5.0;

library Structs {

    struct LimitCondition {
        int256 value;
        int operator;
    }
    
    struct DiscountAction {
        int256 value;
        int discountType;
    }
    
    struct Condition {
        LimitCondition limitCondition;
    }
    
    struct Action {
        DiscountAction discountAction;
    }
    
    struct RuleResult {
        int256 rate;
        int256 volume;
        int256 amount;
    }
    
    struct Rule {
        Condition[] conditions;
        Action[2] actions;
    	RuleResult ruleResult;
    }
    
    struct Operator {
    	string tadig;
        string name;
    }
    
    enum CallType { CallTypeMOCall, CallTypeMTCall, CallTypeMOSMS, CallTypeMTSMS, CallTypeData}
    enum UnitType { UnitTypeKb, UnitTypeMb, UnitTypeMin, UnitTypeSec, UnitTypeEvent}
    enum AgreementStateType {AgreementPending, AgreementApproved, AgreementActive, AgreementExpired}
    

    struct Settlement {
        uint executionMoment;
        string name;
        Rule[] rules;
        uint[] callTypes;
    }
    
    struct SettlementGroup {
        Operator[] operators;
        string currency;
        Settlement[] settlements;
    }
    
    struct UndiscountedRate {
        CallType callType;
        int256 rate;
        UnitType unit;    
    }
    
    // DiscountAgreement defines the discount agreement model    
    struct DiscountAgreement {
        bytes20 id;
        address owner;
        address partner;
        string name;
        string description;
        AgreementStateType state;
        uint256 startDate;
        uint256 endDate;
        uint index;
    }

    struct DiscountAgreementKey {
        address owner;
        address partner;
        uint256 startDate;
        uint256 endDate;
    }
    
}
