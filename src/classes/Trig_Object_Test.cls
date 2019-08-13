@isTest
private class Trig_Object_Test {
    
    static testMethod void runTests() {

        Account newAccount = new Account (
            name = 'Test Account',
            BillingCity ='Test City',
            BillingCountry ='Test Country',
            BillingStreet ='Test Street',
            BillingPostalCode ='123456',
    		Store__c = 'Test'
        );
        
        insert newAccount;
        
        Contact newContact = new Contact (
            FirstName = 'MC',
            LastName = 'Test',
            Account = newAccount,
            Email = 'mctest@mail.com'
        );
        
        insert newContact;
        
        Lead lead = new Lead (
            LastName = 'MC Test',
            Company = 'Test Company',
            Email = 'mctest@mail.com',
            Status = 'Open'
        );
        
        insert lead;
    }
}