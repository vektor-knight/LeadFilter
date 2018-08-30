@isTest
public class EmailTriggerTest {
    
    /*
    @IsTest
    static void oneAccount(){
        Account acct = new Account(Name='TestPharm', ShippingCity='Calgary', Phone='403-679-4502', Fax='403-679-4503', Website='www.test.com' );
        upsert acct;
        test.startTest();
        Database.UpsertResult result = Database.upsert(acct, true);
        test.stopTest();
        System.assert(result.isSuccess());
        System.assert(result.getErrors().size() > 0);
    }*/
    
    public static testMethod void testSendMail() {
        Account acct = new Account(Name='TestPharm', ShippingCity='Calgary', Phone='403-679-4502', Fax='403-679-4503', Website='www.test.com' );
		insert acct;
        test.startTest();
        MailUtil.sendMail('This is my email message');
    	test.stopTest();
    }
    
    
}