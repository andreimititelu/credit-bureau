pragma solidity ^0.4.11;

contract CreditBureau {
    // Custom Types
    struct Accounts {
        address creditOfficer;
        uint account;
    }

    struct Guarantee {
        bytes32 guarantees;
        uint guaranteesValue;
        bytes32 riskType;
    }

    struct CreditInformation {
        bytes32 awardTerm;
        bytes32 cardsAndLeasing;
        bytes32 creditBehavior;
        bytes32 latePayments;
        bytes32 currency;
        uint amount;
    }

    struct CreditSchedules {
        uint startDate;
        uint endDate;
        bytes32 paymentsInterval;
    }

    struct Credit {
        bytes32 beneficiary;
        bytes32 debtors;
        Guarantee guarantee;
        CreditInformation information;
        CreditSchedules schedules;
        bool isValue;
    }

    struct Payment {
        uint amount;
        uint date;
    }

    struct Debtor {
        bool isValue;
        bytes32 fullName;
        bytes32 identificationCode;
        bytes32 country;
        bytes32 activityCode;
        bytes32 specialSituation;
        bytes32 legalForm;
        bytes32 occupationStatus;
        bytes32 group;
        bytes32 groupID;
        uint accountsNo; 
        mapping(uint => Accounts) accounts;
        mapping(uint => Credit) credit;
        mapping(uint => Payment[]) payments;
    }

    // State Variables
    mapping (bytes32 => Debtor) public debtors;
    uint public account = 100000;
    uint public debtorsNo = 0;
    uint public creditsNo = 0;
    uint public queriesNo = 0;

/* ======================================================================================================================
    Constructor Functions
======================================================================================================================= */

    function addDebtor (
        bytes32 _fullName,
        bytes32 _identificationCode,
        bytes32 _country,
        bytes32 _activityCode,
        bytes32 _specialSituation,
        bytes32 _legalForm,
        bytes32 _occupationStatus,
        bytes32 _group,
        bytes32 _groupID
        ) public {
            if (debtors[_identificationCode].isValue) {
                // Debtor already exists, update values
                debtors[_identificationCode].fullName = _fullName;
                debtors[_identificationCode].country = _country;
                debtors[_identificationCode].activityCode = _activityCode;
                debtors[_identificationCode].specialSituation = _specialSituation;
                debtors[_identificationCode].legalForm = _legalForm;
                debtors[_identificationCode].occupationStatus = _occupationStatus;
                debtors[_identificationCode].group = _group;
                debtors[_identificationCode].groupID = _groupID;
            } else {
                // Debtor does not exist, create
                debtors[_identificationCode] = Debtor(
                    true,
                    _fullName,
                    _identificationCode,
                    _country,
                    _activityCode,
                    _specialSituation,
                    _legalForm,
                    _occupationStatus,
                    _group,
                    _groupID,
                    0
                );

                // Add new debtor
                debtorsNo++;
            }
        }

    function addAccount(bytes32 _identificationCode) public {
        require (debtors[_identificationCode].isValue == true); 

        // A new account 
        debtors[_identificationCode].accountsNo++; 

        // Create new account
        debtors[_identificationCode].accounts[debtors[_identificationCode].accountsNo] = Accounts(
                msg.sender,
                account
            );
        
        account++;
    }

    function addCredit(
        bytes32 _identificationCode, 
        uint _account,
        bytes32 _beneficiary,
        bytes32 _debtors
    ) public {
       require (debtors[_identificationCode].isValue == true); 

       // A new credit
       Guarantee memory _guarantee = Guarantee ("", 0, "");
       CreditInformation memory _information = CreditInformation("","","","","",0);
       CreditSchedules memory _schedules = CreditSchedules(0,0,"");

       debtors[_identificationCode].credit[_account] = Credit (
            _beneficiary,
            _debtors,
            _guarantee,
            _information,
            _schedules,
            true
       );

       creditsNo++;
    }

    function addCreditGuarantee(
        bytes32 _identificationCode, 
        uint _account,
        bytes32 _guarantees,
        uint _guaranteesValue,
        bytes32 _riskType
        ) public {
        
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        debtors[_identificationCode].credit[_account].guarantee.guarantees = _guarantees;
        debtors[_identificationCode].credit[_account].guarantee.guaranteesValue = _guaranteesValue;
        debtors[_identificationCode].credit[_account].guarantee.riskType = _riskType;

    }

    function addCreditInformation(
        bytes32 _identificationCode, 
        uint _account,
        bytes32 _awardTerm,
        bytes32 _cardsAndLeasing,
        bytes32 _creditBehavior,
        bytes32 _latePayments,
        bytes32 _currency,
        uint _amount   
    ) public {
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        debtors[_identificationCode].credit[_account].information.awardTerm = _awardTerm;
        debtors[_identificationCode].credit[_account].information.cardsAndLeasing = _cardsAndLeasing;
        debtors[_identificationCode].credit[_account].information.creditBehavior = _creditBehavior;
        debtors[_identificationCode].credit[_account].information.latePayments = _latePayments;
        debtors[_identificationCode].credit[_account].information.currency= _currency;
        debtors[_identificationCode].credit[_account].information.amount = _amount;

    }

    function addCreditSchedules(
        bytes32 _identificationCode, 
        uint _account,
        uint _startDate,
        uint _endDate,
        bytes32 _paymentsInterval
    ) public {
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        debtors[_identificationCode].credit[_account].schedules.startDate = _startDate;
        debtors[_identificationCode].credit[_account].schedules.endDate = _endDate;
        debtors[_identificationCode].credit[_account].schedules.paymentsInterval = _paymentsInterval;

    }

    function addPayment(
        bytes32 _identificationCode, 
        uint _account,
        uint _amount,
        uint _date
    ) public {
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        debtors[_identificationCode].payments[_account].push(Payment(
            _amount,
            _date
        ));

    }

/* ======================================================================================================================
    Stats
======================================================================================================================= */

function getStats() public constant returns (uint, uint, uint) {
    return (
        debtorsNo,
        creditsNo,
        queriesNo
    );
}

function getDebtorsNo() public constant returns (uint) {
    return(debtorsNo);
}

function getCreditsNo() public constant returns (uint) {
    return(creditsNo);
}

function getQueriesNo() public constant returns (uint) {
    return(queriesNo);
}

/* ======================================================================================================================
    Search
======================================================================================================================= */

function search (bytes32 _identificationCode) public constant 
    returns (uint[], address[], uint[], uint[], uint[]) {

    // Has debtor details
    require (debtors[_identificationCode].isValue == true); 

    // Variables
    uint recordsNo = debtors[_identificationCode].accountsNo;
    uint[] memory debtorAccounts = new uint[](recordsNo + 1);
    address[] memory  creditOfficers = new address[](recordsNo + 1);
    uint[] memory startDates = new uint[](recordsNo + 1);
    uint[] memory endDates = new uint[](recordsNo + 1);
    uint[] memory amounts = new uint[](recordsNo + 1);
    

    // Get Informations Numbers
    for (uint i = 0; i <= recordsNo; i++ ) {
            debtorAccounts[i] = debtors[_identificationCode].accounts[i].account;
            creditOfficers[i] = debtors[_identificationCode].accounts[i].creditOfficer;
            startDates[i] = debtors[_identificationCode].credit[debtorAccounts[i]].schedules.startDate;
            endDates[i] = debtors[_identificationCode].credit[debtorAccounts[i]].schedules.endDate;
            amounts[i] = debtors[_identificationCode].credit[debtorAccounts[i]].information.amount;
    } 

    return (
        debtorAccounts,
        creditOfficers,
        startDates,
        endDates,
        amounts
    );
    
    // debtors[_identificationCode]
}

function getAccounts (bytes32 _identificationCode) public constant 
    returns (uint[]) {

    // Has debtor details
    require (debtors[_identificationCode].isValue == true); 

    // Variables
    uint recordsNo = debtors[_identificationCode].accountsNo;
    uint[] memory debtorAccounts = new uint[](recordsNo + 1);

    // Get Informations Numbers
    for (uint i = 0; i <= recordsNo; i++ ) {
            debtorAccounts[i] = debtors[_identificationCode].accounts[i].account;
    } 

    return (debtorAccounts);
}

/* ======================================================================================================================
    Debtor Getters
======================================================================================================================= */

    function getDebtor (bytes32 _identificationCode) public constant 
        returns( string, string, string, string, string, string) {
            return (
                bytes32ToString(debtors[_identificationCode].fullName),
                bytes32ToString(debtors[_identificationCode].country),
                bytes32ToString(debtors[_identificationCode].activityCode),
                bytes32ToString(debtors[_identificationCode].specialSituation),
                bytes32ToString(debtors[_identificationCode].legalForm),
                bytes32ToString(debtors[_identificationCode].occupationStatus)
            );
    }

    function getFullName (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].fullName);
    }

    function getCountry (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].country);
    }

    function getActivityCode (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].activityCode);
    }

    function getSpecialSituation (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].specialSituation);
    }

    function getLegalForm (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].legalForm);
    }

    function getOccupationStatus (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].occupationStatus);
    }

    function getGroup (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].group);
    }

    function getGroupID (bytes32 _identificationCode) public constant returns(string) {
        return bytes32ToString(debtors[_identificationCode].groupID);
    }

/* ======================================================================================================================
    Account Getters
======================================================================================================================= */

    function getAccount (bytes32 _identificationCode, uint position) public constant returns (address, uint) {
        return (
            debtors[_identificationCode].accounts[position].creditOfficer,
            debtors[_identificationCode].accounts[position].account
        );
    }

    function getAccountsNumber (bytes32 _identificationCode) public constant returns(uint) {
        return debtors[_identificationCode].accountsNo;
    } 

/* ======================================================================================================================
    Credit Getters
======================================================================================================================= */

function getCredit(bytes32 _identificationCode, uint _account) public constant
    returns (string, string) {

        return (
            bytes32ToString(debtors[_identificationCode].credit[_account].beneficiary),
            bytes32ToString(debtors[_identificationCode].credit[_account].debtors)
        );
    }

function getCreditGuarantee(bytes32 _identificationCode, uint _account) public constant
    returns (string, uint, string) {

        return (
            bytes32ToString(debtors[_identificationCode].credit[_account].guarantee.guarantees),
            debtors[_identificationCode].credit[_account].guarantee.guaranteesValue,
            bytes32ToString(debtors[_identificationCode].credit[_account].guarantee.riskType)
        );
    }

function getCreditInformation (bytes32 _identificationCode, uint _account) public constant
    returns (string, string, string, string, string, uint) {

        return (
            bytes32ToString(debtors[_identificationCode].credit[_account].information.awardTerm),
            bytes32ToString(debtors[_identificationCode].credit[_account].information.cardsAndLeasing),
            bytes32ToString(debtors[_identificationCode].credit[_account].information.creditBehavior),
            bytes32ToString(debtors[_identificationCode].credit[_account].information.latePayments),
            bytes32ToString(debtors[_identificationCode].credit[_account].information.currency),
            debtors[_identificationCode].credit[_account].information.amount
        );

    }

function getCreditSchedules (bytes32 _identificationCode, uint _account) public constant
    returns (uint, uint, string) {
        return (
            debtors[_identificationCode].credit[_account].schedules.startDate,
            debtors[_identificationCode].credit[_account].schedules.endDate,
            bytes32ToString(debtors[_identificationCode].credit[_account].schedules.paymentsInterval)
        );
    }

/* ======================================================================================================================
    Payment Getters
======================================================================================================================= */


function getPayments(bytes32 _identificationCode, uint _account) public constant returns (uint[], uint[]) {
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        // Variables
        uint recordsNo = debtors[_identificationCode].payments[_account].length;
        uint[] memory amounts = new uint[](recordsNo);
        uint[] memory dates = new uint[](recordsNo);
        
        for (uint i = 0; i < recordsNo; i++) {
            amounts[i] = debtors[_identificationCode].payments[_account][i].amount;
            dates[i] = debtors[_identificationCode].payments[_account][i].date;
        }

        return (amounts, dates);    
}


function getPayment (bytes32 _identificationCode, uint _account, uint position) public constant returns (uint, uint) {
        // Has debtor details
        require (debtors[_identificationCode].isValue == true); 

        // Has credit details
        require (debtors[_identificationCode].credit[_account].isValue == true);

        return (
            debtors[_identificationCode].payments[_account][position].amount,
            debtors[_identificationCode].payments[_account][position].date
        );
}

/* ======================================================================================================================
    Utility Functions
======================================================================================================================= */

    function bytes32ToString(bytes32 x) public constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }   

}