App = {
  web3Provider: null,
  contracts: {},
  account: 0x0,

  // Init Application
  init: function() {
    console.log ("App init!");
    return App.initWeb3();
  },

  // Init Web3 Component
  initWeb3: function() {
    // Initialize web3 and set the provider to the testRPC.
    console.log ("Web3 Provider: ", web3.currentProvider);
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // set the provider you want from Web3.providers
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }

    App.displayAccountInfo();
    return App.initContract();
  },


  // Unlock application
  unlock : function () {
    console.log ("Unlock account!");
    console.log (App.account);

    if (App.account == 0 || App.account === null) {
      swal("No account was selected!");
    } else {
      // Redirect to search page
      window.location.replace("search.html");
    }
  },

  // Display Account Info
  displayAccountInfo: function() {
    web3.eth.getCoinbase(function(err, account) {
      console.log ("Account:", account);
      console.log ("Error:", err);

      if (account !== null) {
        App.account = account;
        $("#account").text(account);
        web3.eth.getBalance(account, function(err, balance) {
          console.log ("Balance:", balance);
          if (err === null) {
            $("#accountBalance").text(web3.fromWei(balance, "ether") + " ETH");
          }
        });
      } else {
        var url = new URL(window.location.href);
        if (url.pathname != "/") {
          // Redirect to lock screen
          window.location.replace("/");
        }
      }
    });
  },

  initContract: function() {
    $.getJSON('CreditBureau.json', function(creditBureauArtifact) {
      // Get the necessary contract artifact file and use it to instantiate a truffle contract abstraction.
      App.contracts.CreditBureau = TruffleContract(creditBureauArtifact);

      // Set the provider for our contract.
      App.contracts.CreditBureau.setProvider(App.web3Provider);

      // Display Stats
      App.displayStats();
    });
  },

  displayStats: function() {
    App.contracts.CreditBureau.deployed().then(function(instance) {
      instance.getStats().then(function (results) {
          console.log ("Display Stats: ", results);
          $("#lifetime_debtors").text(results[0]);
          $("#lifetime_credits").text(results[1]);
          $("#lifetime_queries").text(results[2]);
      });
    });
  },

  validate : function(id) {

    $.validate({
        onError : function($form) {
          console.log('Validation of form '+$form.attr('id')+' failed!');
          return false;
        },
        onSuccess : function($form) {
          console.log('The form '+$form.attr('id')+' is valid!');
          switch(id) {
            case "debtor":
                App.addDebtor();
                break;
            case "credit":
                App.addCredit();
                break;
            case "payment":
                App.addPayment();
                break;
            default:
                console.log("Default");
          } 

          return false; // Will stop the submission of the form
        },
        onValidate : function($form) {
            console.log('On Validate!');
        }
      });
  },

  convertDate : function(inputFormat) {
    function pad(s) { return (s < 10) ? '0' + s : s; }
    var d = new Date(inputFormat);
    return [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('/');
  },

  search: function() {
    console.log ("Search!");
    var identificationCode = $("#search").val().trim();
    if (search.length != 0) {
      App.contracts.CreditBureau.deployed().then(function(instance) {
        instance.getDebtor(identificationCode).then(function (results) {
          console.log (results);
          $("#debtor_information, #accounts_information, #credit_information, #schedules_information, #payment_information").hide("fast");
          
          if (results[0].length != 0) {
            $("#debtor_information").show("fast");
            $("input#fullname").val(results[0]);
            $("input#country").val(results[1]);
            $("input#activity_code").val(results[2]);
            $("input#special_situation").val(results[3]);
            $("input#legal_form").val(results[4]);
            $("input#occupation_status").val(results[5]);
          } 
          
          // Get Accounts 
          instance.getAccounts(identificationCode).then(function (results) {
            console.log (results);
            
            for (var i = 1; i < results.length; i++) {
              $('#accounts').append($('<option>', {
                value: results[i],
                text: results[i]
            }));

            $("#accounts_information").show("fast");

            }

          });
          
        });
      }).then(function (result) {
        console.log (result);
      }).catch(function(err) {
        console.error(err);
      });
    }
  },

  getCredit: function () {
    console.log ("Get Credit!");
    var creditAccount = $("#accounts").val();
    var identificationCode = $("#search").val().trim();
    if (creditAccount.length != 0 && identificationCode.length != 0) {
      App.contracts.CreditBureau.deployed().then(function(instance) {
        instance.getCreditInformation (identificationCode,creditAccount).then(function (results) {
          console.log (results);
          if (results[0].length != 0) {
            $("input#award_term").val(results[0]);
            $("input#cards_and_leasing").val(results[1]);
            $("input#credit_behavior").val(results[2]);
            $("input#late_payments").val(results[3]);
            $("input#amount").val(results[5]);
            $("input#currency").val(results[4]);

            instance.getCreditSchedules(identificationCode,creditAccount).then(function (results) {
                console.log (results);
                $("input#start_date").val(App.convertDate(results[0].c[0]));
                $("input#end_date").val(App.convertDate(results[1].c[0]));
                $("input#payments_interval").val(results[2]);

                $("#credit_information, #schedules_information").show("fast");

                instance.getPayments(identificationCode, creditAccount).then(function (results) {
                    console.log (results);
                    for (var i=0; i < results[0].length; i++) {
                      $("#payments tbody").append('<tr><th scope="row">' + (i + 1) + '</th>' + '<td>' + results[0][i] + '</td>' + '<td>' + App.convertDate(results[1][i].c[0]) + '</td></tr>');
                    }
                    $("#payment_information").show("fast");
                    

                });

            });
          }
        });
      });

    }
  },

  addDebtor: function() {
    console.log ("Add Debtor!");

    var details = $('#new_debtor_form').serializeJSON();
    
    App.contracts.CreditBureau.deployed().then(function(instance) {

      return instance.addDebtor (
        details.fullname, 
        details.identification_code,
        details.country,
        details.activity_code,
        details.special_situation,
        details.legal_form,
        details.occupation_status,
        details.group,
        details.group_id, {
          from: App.account,
          gas: 500000
        });
    }).then(function(result) {
       console.log (result);
       swal(
        {
            title: 'Debtor was successfully created in blockchain!',
            type: 'success',
            confirmButtonColor: '#4fa7f3'
        }
      );
    }).catch(function(err) {
      console.error(err);
    });

  },

  addCredit: function () {
    console.log ("Add Credit!");
    var details = $('#new_credit_form').serializeJSON();
    var credit = {};
    console.log (details);

    

    App.contracts.CreditBureau.deployed().then(function(instance) {
      
            // Add New Account 
            return instance.addAccount (
              details.credit_beneficiary, {
                from: App.account,
                gas: 500000
              }).then (function(result) {
                console.log ("New Account: ", result);
                // Get Accounts Number
                instance.getAccountsNumber (details.credit_beneficiary).then(function (result) {
                   
                  // Get Account
                  instance.getAccount (details.credit_beneficiary, result.c[0]).then(function (result) {
                    credit.currentAccount = result[1].c[0];

                    // Add Credit 
                    instance.addCredit(
                      details.credit_beneficiary,
                      credit.currentAccount,
                      "", 
                      details.other_debtors,{
                        from: App.account,
                        gas: 500000
                      }
                    ).then(function (result) {
                      console.log ("Add Credit: " ,result);

                      // Add Credit Guarantees
                      instance.addCreditGuarantee(
                        details.credit_beneficiary,
                        credit.currentAccount,
                        details.guarantees, 
                        details.total_guarantees_value, 
                        details.risk_type,{
                          from: App.account,
                          gas: 500000
                        }
                      ).then(function (result) {
                        console.log ("Add Credit Guarantees: ", result);

                        // Add Credit Information 
                        instance.addCreditInformation(
                          details.credit_beneficiary,
                          credit.currentAccount,
                          details.award_term, 
                          details.cards_and_leasing, 
                          details.credit_behavior, 
                          details.late_payments,
                          details.currency, 
                          details.amount, {
                            from: App.account,
                            gas: 500000
                          }).then(function (result) {
                            console.log ("Add Credit Information: ", result);

                            // Add Credit Schedules
                            instance.addCreditSchedules(
                              details.credit_beneficiary,
                              credit.currentAccount, 
                              new Date(details.start_date).getTime(), 
                              new Date(details.end_date).getTime(),
                              details.payments_interval, {
                                from: App.account,
                                gas: 500000
                              }).then(function (result) {
                                console.log ("Add Credit Schedules: ", result);
                                swal(
                                  {
                                      title: 'Credit was successfully created in blockchain!',
                                      text: 'Account number: ' + credit.currentAccount,
                                      type: 'success',
                                      confirmButtonColor: '#4fa7f3'
                                  }
                                );

                              }); 
                          });
                      }); 

                    });
                    
                  });
                  
                });
              });


          }).then(function(result) {
             console.log (result);
             

          }).catch(function(err) {
            console.error(err);
          });

  }, 

  getPaymentAccounts: function () {
    console.log ("Get Payment Accounts!");
    var identificationCode = $("#identification_code").val();

    $("#select_accounts, #payment_information, #submit_payment").hide();
    if (identificationCode.length != 0) {
      
      App.contracts.CreditBureau.deployed().then(function(instance) {
        instance.getAccounts (identificationCode).then(function (results) {
          console.log (results);

          for (var i = 1; i < results.length; i++) {
            $('#accounts').append($('<option>', {
              value: results[i],
              text: results[i]
            }));
          }

          $("#select_accounts, #payment_information, #submit_payment").show();

        });
      });

    }
  },

  addPayment : function () {
    console.log ("Add Payment!");

    var details = $('#new_payment_form').serializeJSON();
    console.log (details);
    App.contracts.CreditBureau.deployed().then(function(instance) {
      instance.addPayment(
        details.identification_code,
        details.accounts,
        details.amount,
        new Date(details.start_date).getTime()
      ).then(function (results) {
        console.log (results);
      });

    });

  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
