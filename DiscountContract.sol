pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract DiscountContract {

    event Inserted(address _sender, address _partner);
    event Updated(address _sender, address _partner);
    event Deleted(address _sender, address _partner);

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
        // uint256 txHash;
        string name;
        string description;
        uint state;
        uint256 startDate;
        uint256 endDate;
        bool exists;
    }

    // map(owner, (partner, agreement))
    mapping(address => DiscountAgreement) public agreements;


    // The constructor
    constructor() public {
    }    

    
    function Insert(address _partner, DiscountAgreement memory _agreement) public {
        // Create a discount agreement for an agreement owner with a partner discount map
        _agreement.state = 0;
        _agreement.exists = true;
        agreements[_partner] = _agreement;
        emit Inserted(msg.sender, _partner);
    }

    // Check if partner addfress is in agreements
    function Exists(address _partner) public view returns(bool exists) {
        return agreements[_partner].exists;
    }

    function Update(address _partner, DiscountAgreement memory _agreement) public returns(bool success) {
        require(Exists(_partner));
        agreements[_partner] = _agreement;
        emit Updated(msg.sender, _partner);
        return true;
    }

    function GetByPartner(address _partner) public view returns(DiscountAgreement memory agreement) {
      require(Exists(_partner));
      return (agreements[_partner]);
    }
    
}



    

