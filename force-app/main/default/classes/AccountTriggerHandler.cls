public with sharing class AccountTriggerHandler extends TriggerHandler {
    public AccountTriggerHandler() {

    }

    // Declare target query as 'FINAL'; it is an attribute of our
    // specific trigger. Hence, we pull it up, and run the Trigger.new
    // on the resultant atom itself.

        // Goal is to write a query where BOTH phone^fax exist. This is
        // considered a qualified lead for pharma sales.
        // In this case, we will be hard-coding only results from Calgary, 
        // although a helper method can be written where the city can be
        // pre-selected at run-time. This is something which resembles
        // a query-builder as found here: https://soqlbuilder.herokuapp.com/

    List<Account> result = [SELECT ShippingCity, Phone, Fax, Website FROM a 
                  WHERE ShippingCity='Calgary' and Fax != NULL and Phone != NULL];

    // Flat-file header information (target columns)
    string header = 'City, Phone Number, Fax Number, Website \n';
    string blobHeader = header;
    
    public override void afterInsert() {
      for (Account a : (result) Trigger.new) {

        string singleRecord = a.ShippingCity + ',' + a.Phone + ',' + a.Fax + ',' + a.Website + '\n';
        // Take row data and append it underneath the column headers in blobHeader
        blobHeader = blobHeader + singleRecord;

      }


      // Now that we have the query atom, we will format it and use email
      // management snippets from SF.com to email the results to the sales agent.
      // This next snippet is a candidate for refactoring. Email management
      // can be done in a separate handler.

      // First, reserve email capacity for the current Apex transaction to ensure
      // that we won't exceed our daily email limits when sending email after
      // the current transaction is committed.
      Messaging.reserveSingleEmailCapacity(2);

      // Prepare the file attachment
      Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
      blob csvBlob = Blob.valueOf(blobHeader);
      string csvName = 'CalgaryLeads_Clean.csv';
      csvAttc.setFileName(csvName);
      csvAttc.setBody(csvBlob);



      // Processes and actions involved in the Apex transaction occur next,
      // which conclude with sending a single email.

      // Now create a new single email message object
      // that will send out a single email to the addresses in the To, CC & BCC list.
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      // Strings to hold the email addresses to which you are sending the email.
      String[] toAddresses = new String[] {'tseibt@tractionondemand.com'}; 
      String[] ccAddresses = new String[] {'sartaj.hundal@ucalgary.ca', 'rmurtha@tractionondemand.com, jmeyer@tractionondemand.com'};
  

      // Assign the addresses for the To and CC lists to the mail object.
      mail.setToAddresses(toAddresses);
      mail.setCcAddresses(ccAddresses);

      // Specify the address used when the recipients reply to the email. 
      mail.setReplyTo('sartaj.hundal@ucalgary.ca');

      // Specify the name used as the display name.
      mail.setSenderDisplayName('HundalBot Delivery Service');

      // Specify the subject line for your email address.
      mail.setSubject('ATTN: Calgary Territory Manager - Qualified Leads');

      // Optionally append the salesforce.com email signature to the email.
      // The email address of the user executing the Apex Code will be used.
      mail.setUseSignature(true);

      // Specify the text content of the email.
      mail.setPlainTextBody('Hi, Territory Manager. Here are the qualified leads we got from the database using our new expert system.');
       
      mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
      // Send the email you have created, with the attachment.
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      

    }

}