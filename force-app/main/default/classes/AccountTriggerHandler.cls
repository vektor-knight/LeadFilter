//Sample code for AccountTriggerHandler
public class AccountTriggerHandler extends TriggerHandler{

    /// "Globals"
    // Best practice: handle SOQL -outside- loops to mitigate risk 
    // of overrunning governer limits during batch jobs.
    List<Account> result = [SELECT ShippingCity, Phone, Fax, Website FROM a 
                  WHERE ShippingCity='Calgary' and Fax != NULL and Phone != NULL];
    // Flat-file header information (target columns)
    string header = 'City, Phone Number, Fax Number, Website \n';
    string blobHeader = header;




  public override void beforeInsert(){
    System.debug( 'AccountTriggerHandler beforeInsert Start' );

    System.debug( 'Trigger.isExecuting : '   + isExecuting );
    System.debug( 'Trigger.isInsert : '      + isInsert );
    System.debug( 'Trigger.isUpdate : '      + isUpdate );
    System.debug( 'Trigger.isDelete : '      + isDelete );
    System.debug( 'Trigger.isBefore : '      + isBefore );
    System.debug( 'Trigger.isAfter : '       + isAfter );
    System.debug( 'Trigger.isUndelete : '    + isUndelete );
    System.debug( 'Trigger.new : '           + newList );
    System.debug( 'Trigger.newMap : '        + newMap );
    System.debug( 'Trigger.old : '           + oldList );
    System.debug( 'Trigger.oldMap : '        + oldMap );
    System.debug( 'Trigger.size : '          + size );

    System.debug('AccountTriggerHandler beforeInsert End');
  }

  public override void afterInsert(){
    System.debug('AccountTriggerHandler afterInsert Start');
    for (Account a : (result) Trigger.new) {
        string singleRecord = a.ShippingCity + ',' + a.Phone + ',' + a.Fax + ',' + a.Website + '\n';
        // Take row data and append it underneath the column headers in blobHeader
        blobHeader = blobHeader + singleRecord;
    }

    /// Email operations
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

  public override void beforeUpdate(){
    System.debug('AccountTriggerHandler beforeUpdate Start');
  }

  public override void afterUpdate(){
    System.debug('AccountTriggerHandler afterUpdate Start');
  }

  public override void beforeDelete(){
    System.debug('AccountTriggerHandler beforeDelete Start');
  }

  public override void afterDelete(){
    System.debug('AccountTriggerHandler afterDelete Start');
  }

  public override void afterUndelete(){
    System.debug('AccountTriggerHandler afterUndelete Start');
  }
    
}