public with sharing class AccountTriggerHandler extends TriggerHandler {
    public AccountTriggerHandler() {

    }

    public override void afterInsert() {
      for (Account a : (List<Account>) Trigger.new) {
        // Goal is to write a query where BOTH phone^fax exist. This is
        // considered a qualified lead for pharma sales.
        // In this case, we will be hard-coding only results from Calgary, 
        // although a helper method can be written where the city can be
        // pre-selected at run-time. This is something which resembles
        // a query-builder as found here: https://soqlbuilder.herokuapp.com/

        result = [SELECT ShippingCity, Phone, Fax, Website FROM Account 
                  WHERE ShippingCity='Calgary' and Fax != NULL and Phone != NULL];
      }      

    }

}