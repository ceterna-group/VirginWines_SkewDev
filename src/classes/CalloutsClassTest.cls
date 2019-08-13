@isTest
public class CalloutsClassTest {
	//ACCOUNT
	public static Account configAccount(){
		Id personAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 

		Account account = new Account();
		account.Store__c = 'Virgin Wines';
		account.PersonEmail = 'test@test.com';
		account.Salutation = 'Mr';
		account.FirstName = 'FirstTest';
		account.LastName = 'LastTest';
		account.Phone = '1234567890';
		account.PersonHomePhone = '1234567890';
		account.PersonOtherPhone = '1234567890';
		account.PersonBirthdate = Date.today() - 100;
		account.RecordTypeId = personAccount;

		return account;
	}
	//CONTACT
	public static Contact configContact()	{
        Contact contact = new Contact(
            FirstName = 'Test First Name',
            LastName = 'Test Last Name'
        );

        return contact;
	}
	//CUSTOM SETTING
	public static void createCustomSetting(){
		Mantiki__c man = new Mantiki__c();
		man.Begin__c = null;
		man.Client_Id__c = 'xxxx';
		man.Client_Secret__c = 'xxxxxxxxxxxxxxxxxxxxxxxxxxx';
		man.End_Point__c = 'http://teste.com';
		man.Finish__c = null;
		man.getToken__c = 'xxxx/xxxxx';
		man.Grant_Type__c = 'xxxxxxxxxxxxx';
		man.Message__c = null;
		man.Token__c = null;
		man.Account__c = 'xxxxxxxxxxxxxx';
		man.Individual__c = 'xxxxxxxxxxxxxx';
		man.Winebank__c = 'xxxxxxxxxxxxxx';
		man.Telesales__c = 'xxxxxxxxxxxxxx';
		insert man;
	}


}