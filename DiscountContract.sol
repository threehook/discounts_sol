pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract DiscountContract {

    // event Inserted(address indexed owner, address indexed partner);
    // event Updated(address indexed owner, address indexed partner);
    // event Deleted(address indexed owner, address indexed partner);

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
    enum AgreementStateType {AgreementPending, AgreementActive, AgreementExpired}
    

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
        address owner;
        address partner;
        string name;
        string description;
        AgreementStateType state;
        uint256 startDate;
        uint256 endDate;
        bool exists;
    }

    // map(partner, agreement)
    mapping(address => mapping(address => DiscountAgreement)) public owner_agreements;
    // map(partner, (owner, agreement))
    mapping(address => mapping(address => DiscountAgreement)) partner_agreements;


    // The constructor
    constructor() public {
    }    

    function Insert(address _partner, DiscountAgreement memory _agreement) public {
        // Create a discount agreement for an agreement owner with a partner discount map
        _agreement.state = AgreementStateType.AgreementPending;
        _agreement.exists = true;
        owner_agreements[msg.sender][_partner] = _agreement;
        // emit Inserted(msg.sender, _partner);
    }

    // Check if partner address is in owner_agreements
    function Exists(address _owner, address _partner) public view returns(bool exists) {
        return owner_agreements[_owner][_partner].exists;
    }

    function Update(DiscountAgreement memory _agreement) public returns(bool success) {
        address _partner = _agreement.partner;
        require(Exists(msg.sender, _partner));
        owner_agreements[msg.sender][_partner] = _agreement;
        partner_agreements[_partner][msg.sender] = _agreement;
        // emit Updated(msg.sender, _partner);
        return true;
    }

    function GetOwnerAgreement(address _partner) public view returns(DiscountAgreement memory agreement) {
      require(Exists(msg.sender, _partner));
      return (owner_agreements[msg.sender][_partner]);
    }
    
    function GetPartnerAgreement(address _owner) public view returns(DiscountAgreement memory agreement) {
      require(Exists(_owner, msg.sender));
      return (partner_agreements[msg.sender][_owner]);
    }    
    
    // Approve - Approves given agreement
    function Approve(address _owner) public view returns(bool success) {
        bool ok = false;
        require(Exists(_owner, msg.sender));
        DiscountAgreement memory agreement = GetPartnerAgreement(_owner);
        if (agreement.state == AgreementStateType.AgreementPending) {
            agreement.state = AgreementStateType.AgreementActive;
            ok = true;
        }
        return ok;
    }

}
