CreditBureau.deployed().then(function(instance) {app=instance;})

// Debtor
app.addDebtor ("Andrei Mititelu","GZ099192","RO","0001","N/A","N/A","N/A","N/A","N/A");
app.getFullName ("GZ099192");
app.getCountry ("GZ099192");
app.getDebtor ("GZ099192");

// Accounts

app.addAccount("GZ099192", 100000);
app.addAccount("GZ099192");
app.getAccountsNumber ("GZ099192");
app.getAccounts ("GZ099192");
app.getAccount ("GZ099192", 1);

// Credit 

app.addCredit("GZ099192",100000, "Andrei Mititelu", "N/A");
app.getCredit("GZ099192", 100000);

app.getCredit("GZ1234", 100014);

app.addCreditGuarantee("GZ099192",100000, "G", 0, "R"); 
app.getCreditGuarantee("GZ099192",100000);

app.addCreditInformation("GZ099192",100000, "AWT", "Card", "CBHV", "LP", "EUR", 0);
app.getCreditInformation ("GZ099192",100000);

app.addCreditSchedules("GZ099192",100000, 1514558869, 1514558869, "N/A")
app.getCreditSchedules("GZ099192",100000);

// Payments

app.addPayment("GZ099192",100000,100000,1514558869);
app.getPayments("GZ099192", 100000);

/* app.addAccount("andrei", 1, {from: web3.eth.accounts[0]})
app.getCreditOfficer("andrei");
app.getAccountsNo("andrei");
app.getAccounts("andrei");*/


var getAccountsNumberEvent = app.getAccountsNumberEvent({}, {fromBlock: 0, toBlock: 'latest'}).watch(function (error, event) { console.log (event);})
var getAccountsEvent = app.getAccountsEvent({}, {fromBlock: 0, toBlock: 'latest'}).watch(function (error, event) { console.log (event);})
