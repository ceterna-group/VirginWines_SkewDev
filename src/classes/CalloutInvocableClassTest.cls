@isTest
public class CalloutInvocableClassTest {

	// TESTED CLASS: WinebankHolidayInvocableClass
	// OBJECT: Winebank
	static testmethod void getWinebankHolidaySuccessTest(){

		// 1) Create Custom setting:
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// 2) Insert Winebank:
		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test'
		);
		insert winebank;


		// 3)  Mock: Return a success response from Mantiki with a JSON that matches the WineBankHolidayResponse :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"endDay":"2019-07-01","state":"pending","dueOn":"2019-07-14"}', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse1);

		// 4) Create Flow Inputs for the Invocable variables in the Invocable Class:
		WinebankHolidayInvocableClass.FlowInputs flowInputs = new WinebankHolidayInvocableClass.FlowInputs();
		flowInputs.winebankId = winebank.Id;
		flowInputs.holidayStartDate = System.today() + 30;
		flowInputs.months = 3;

		// 5) Method in the Invocable class only accepts a List as parameter:
		List<WinebankHolidayInvocableClass.FlowInputs> flowInputsList = new List<WinebankHolidayInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
			WinebankHolidayInvocableClass.getWinebankHoliday(flowInputsList);
		Test.stopTest();

		System.assertEquals('pending', [SELECT Event_State__c FROM Winebank_Membership__c WHERE Id = :winebank.Id].Event_State__c ,
						' Winebank should have been updated with the values from the Mock Response. ');
		System.assertEquals('2019-07-14', String.valueOf([SELECT Next_Instalment_Date__c FROM Winebank_Membership__c WHERE Id = :winebank.Id].Next_Instalment_Date__c),
						' Winebank should have been updated with the values from the Mock Response. ');
	}

	// TESTED CLASS: WinebankHolidayInvocableClass
	// OBJECT: Winebank
	static testmethod void getWinebankHolidayErrorTest(){

		// 1) Create Custom setting:
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// 2) Insert Winebank:
		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test'
		);
		insert winebank;

		// 3)  Mock: Return a success response from Mantiki with a JSON that matches the WineBankHolidayResponse :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"WineBank not open"}', null);

		Test.setMock(HttpCalloutMock.class, fakeResponse1);

		// 4) Create Flow Inputs for the Invocable variables in the Invocable Class:
		WinebankHolidayInvocableClass.FlowInputs flowInputs = new WinebankHolidayInvocableClass.FlowInputs();
		flowInputs.winebankId = winebank.Id;
		flowInputs.holidayStartDate = System.today() + 30;
		flowInputs.months = 3;

		// 5) Method in the Invocable class only accepts a List as parameter:
		List<WinebankHolidayInvocableClass.FlowInputs> flowInputsList = new List<WinebankHolidayInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
			WinebankHolidayInvocableClass.getWinebankHoliday(flowInputsList);
		Test.stopTest();

		System.assertEquals(NULL ,[SELECT Event_State__c FROM Winebank_Membership__c WHERE Id = :winebank.Id].Event_State__c ,
				'  Winebank should NOT have been updated.');
		System.assertEquals(NULL, String.valueOf([SELECT Next_Instalment_Date__c FROM Winebank_Membership__c WHERE Id = :winebank.Id].Next_Instalment_Date__c),
				'  Winebank should NOT have been updated. ');

	}

	//TEST MOCK #1 (method calling HttpCalloutMock Class):
	//OBJECT: Winebank
	static testmethod void cancelWinebankSuccess() {
		WineBankCancelInvocableClass testWineBankCancel = new WineBankCancelInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse3 = new CalloutsClassMock(200, 'Complete', '{"leftOn" : "2019-05-01", "state" : "closed","balance" : 50.0,"interest" : 10.0}', null);
		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		//CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		//requestsMap.put('1', fakeResponse1);
		requestsMap.put('3', fakeResponse3);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Account account = CalloutsClassTest.configAccount();
		//insert account;

		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test',
				//Customer__c = account.Id,
				Winebank_State__c = 'open'
		);
		insert winebank;

		Test.startTest();
			WineBankCancelInvocableClass.cancelWineBank(testWineBankCancel.getWrapper(true, 'PF Do Not Like Wine', winebank.Id));
		Test.stopTest();
		Winebank_Membership__c winebankNew = [SELECT Name, Winebank_State__c, Cancel_Reason__c, Cancel_Date__c, WineBank_Interest__c, WineBank_Balance__c FROM Winebank_Membership__c WHERE Id = :winebank.Id];
		System.debug('winebankNew Test' + winebankNew);
		System.assertEquals('closed', winebankNew.Winebank_State__c, ' Winebank should have been updated with the values from the Mock Response ');
		System.assertEquals('PF Do Not Like Wine', winebankNew.Cancel_Reason__c, ' Winebank should have been updated with the values from the Mock Response ');
		System.assertEquals('2019-05-01 01:00:00', String.valueOf(winebankNew.Cancel_Date__c), ' Winebank should have been updated with the values from the Mock Response ');
		System.assertEquals(10.0, winebankNew.WineBank_Interest__c, ' Winebank should have been updated with the values from the Mock Response ');
		System.assertEquals(50.0, winebankNew.WineBank_Balance__c, ' Winebank should have been updated with the values from the Mock Response ');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :winebankNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Subscriptions__c is INSERTED/UPDATED. ');
	}

	//TEST MOCK #2 (method calling HttpCalloutMock Class):
	//OBJECT: Winebank
	static testmethod void cancelWinebankError() {
		WineBankCancelInvocableClass testWineBankCancel = new WineBankCancelInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"WineBank not open"}', null);
		//
		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		//CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		//requestsMap.put('1', fakeResponse1);
		requestsMap.put('1', fakeResponse1);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Account account = CalloutsClassTest.configAccount();
		//insert account;

		Winebank_Membership__c winebank = new Winebank_Membership__c(
				Name = 'test',
			//Customer__c = account.Id,
				Winebank_State__c = 'open'
		);
		insert winebank;

		Test.startTest();
		WineBankCancelInvocableClass.cancelWineBank(testWineBankCancel.getWrapper(true, 'Test', winebank.Id));
		Test.stopTest();
		Winebank_Membership__c winebankNew = [SELECT Name, Winebank_State__c, Cancel_Reason__c, Cancel_Date__c, WineBank_Interest__c, WineBank_Balance__c FROM Winebank_Membership__c WHERE Id = :winebank.Id];
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :winebankNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Error has ocurred. ');
	}


	// TESTED CLASS: SubscriptionSkipInvocableClass
	// OBJECT: Subscription
	static testmethod void getSubscriptionSkipSuccessTest() {
		// 1) Create Custom setting:
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// 2) Insert Subscriptions:
		Subscriptions__c subscription = new Subscriptions__c(
				Name = 'test'
		);
		insert subscription;

		// 3)  Mock: Return a success response from Mantiki with a JSON that matches the SkipSubscriptionResponse :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete','{"state":"pending","dueOn":"2019-07-14"}', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse1);

		// 4) Create Flow Inputs for the Invocable variables in the Invocable Class:
		SubscriptionSkipInvocableClass.FlowInputs flowInputs = new SubscriptionSkipInvocableClass.FlowInputs();
		flowInputs.subscriptionId = subscription.Id;
		flowInputs.skipReasonCode = 'HOL';

		// 5) Method in the Invocable class only accepts a List as parameter:
		List<SubscriptionSkipInvocableClass.FlowInputs> flowInputsList = new List<SubscriptionSkipInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
			SubscriptionSkipInvocableClass.getSubscriptionSkip(flowInputsList);
		Test.stopTest();

		System.assertEquals('HOL', [SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Skip_Reason__c,
				' Subscription should have been updated with the values from the Mock Response. ');
		System.assertEquals('pending' ,[SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Event_State__c ,
				'  Subscription should NOT have been updated.');
		System.assertEquals('2019-07-14' ,String.valueOf([SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Due_Date__c ),
				'  Subscription should NOT have been updated.');

	}



	// TESTED CLASS: SubscriptionSkipInvocableClass
	// OBJECT: Subscription
	static testmethod void getSubscriptionSkipErrorTest() {
		// 1) Create Custom setting:
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		// 2) Insert Subscriptions:
		Subscriptions__c subscription = new Subscriptions__c(
				Name = 'test'
		);
		insert subscription;

		// 3)  Mock: Return a success response from Mantiki with an Error Status Code :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(400, 'Complete','{"error_category":"Bad Request","error_type":"Invalid state","message":"WineBank not open"}', null);
		Test.setMock(HttpCalloutMock.class, fakeResponse1);

		// 4) Create Flow Inputs for the Invocable variables in the Invocable Class:
		SubscriptionSkipInvocableClass.FlowInputs flowInputs = new SubscriptionSkipInvocableClass.FlowInputs();
		flowInputs.subscriptionId = subscription.Id;
		flowInputs.skipReasonCode = 'Due to holiday';

		// 5) Method in the Invocable class only accepts a List as parameter:
		List<SubscriptionSkipInvocableClass.FlowInputs> flowInputsList = new List<SubscriptionSkipInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
			SubscriptionSkipInvocableClass.getSubscriptionSkip(flowInputsList);
		Test.stopTest();

		System.assertEquals(NULL, [SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Skip_Reason__c,
				'  Subscription should NOT have been updated.');
		System.assertEquals(NULL ,[SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Event_State__c ,
				'  Subscription should NOT have been updated.');
		System.assertEquals(NULL ,[SELECT Skip_Reason__c, Event_State__c, Due_Date__c FROM Subscriptions__c WHERE Id = :subscription.Id].Due_Date__c ,
				'  Subscription should NOT have been updated.');
	}


	//TEST MOCK #3 (method calling HttpCalloutMock Class):
	//OBJECT: Subscription
	static testmethod void cancelSubscriptionSuccess() {
		SubscriptionCancelInvocableClass testSubscriptionCancel = new SubscriptionCancelInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;
		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"leftOn" : "2019-05-01","state" : "closed"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('3', fakeResponse1);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Account account = CalloutsClassTest.configAccount();
		//insert account;

		Subscriptions__c subscriptions = new Subscriptions__c(
				Name = 'test',
				//Customer__c = account.Id,
				Subscription_State__c = 'open'
		);
		insert subscriptions;

		Test.startTest();
			SubscriptionCancelInvocableClass.cancelSubscription(testSubscriptionCancel.getWrapper('Customer Failure - Signed Up In Error', subscriptions.Id));
		Test.stopTest();
		Subscriptions__c subscriptionNew = [SELECT Name, Subscription_State__c, Cancel_Reason__c, Cancel_Date__c FROM Subscriptions__c WHERE Id = :subscriptions.Id];
		System.assertEquals('closed', subscriptionNew.Subscription_State__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('2019-05-01 01:00:00', String.valueOf(subscriptionNew.Cancel_Date__c), ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Customer Failure - Signed Up In Error', subscriptionNew.Cancel_Reason__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :subscriptions.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Subscriptions__c is INSERTED/UPDATED. ');

	}

	//TEST MOCK #4 (method calling HttpCalloutMock Class):
	//OBJECT: Subscription
	static testmethod void cancelSubscriptionError() {
		SubscriptionCancelInvocableClass testSubscriptionCancel = new SubscriptionCancelInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;
		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"WineBank not open"}', null);
		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Account account = CalloutsClassTest.configAccount();
		//insert account;

		Subscriptions__c subscriptions = new Subscriptions__c(
				Name = 'test',
			//Customer__c = account.Id,
				Subscription_State__c = 'open'
		);
		insert subscriptions;

		Test.startTest();
		SubscriptionCancelInvocableClass.cancelSubscription(testSubscriptionCancel.getWrapper('Test', subscriptions.Id));
		Test.stopTest();
		Subscriptions__c subscriptionNew = [SELECT Name, Subscription_State__c, Cancel_Reason__c, Cancel_Date__c FROM Subscriptions__c WHERE Id = :subscriptions.Id];
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :subscriptionNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Error has ocurred. ');

	}

	//TEST MOCK #5 (method calling HttpCalloutMock Class):
	//OBJECT: Individual
	static testmethod void contactPermissionsSuccessVwshop() {
		ContactPermissionsInvocableClass testContactPermissions = new ContactPermissionsInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = CalloutsClassTest.configAccount();
		account.Store__c = 'vwshop';
		insert account;

		//Get Contact linked to the Account with Store != 'vwshop' that was created when the Person Account was inserted:
		Contact contact = [SELECT Name, AccountId, Account.Store__c FROM Contact WHERE AccountId = :account.Id];

		//Insert Individual and link it to the Contact linked to the Account with Store = 'vwshop'
		Individual individual = new Individual(
				LastName = 'Mendes',
				Wine_Advisor_emails__c = 'Monthly',
				Contact__c = contact.Id

		);
		insert individual;

		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"Virgin_Wines_emails": "Never","Virgin_Wines_other_Phone": "false","Virgin_Wines_other_SMS": "false","Virgin_Wines_other_Post": "false","Send_a_Gift_emails": "Never","Send_a_Gift_other_Phone": "false", "Send_a_Gift_other_SMS": "false","Send_a_Gift_other_Post": "false","Other_Third_Parties_Email": "true","Other_Virgin_Companies_Email": "true","Wine_Advisor_emails": "Never"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('3', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Create the Flow input
		List<ContactPermissionsInvocableClass.FlowInputs> inputs = new List<ContactPermissionsInvocableClass.FlowInputs>();
		ContactPermissionsInvocableClass.FlowInputs input = new ContactPermissionsInvocableClass.FlowInputs();
		input.Virgin_Wines_emails = 'Never';
		input.checkboxGroupVW = '';
		input.checkboxGroupSend='';
		input.Send_a_Gift_emails = 'Never';
		input.Other_Third_Parties_Email = true;
		input.Other_Virgin_Companies_Email = true;
		input.Wine_Advisor_email = 'Never';
		input.accountId = account.Id;
		inputs.add(input);

		Test.startTest();
			ContactPermissionsInvocableClass.contactPreferences(inputs);
		Test.stopTest();

		Individual individualNew = [SELECT Virgin_Wines_emails__c,
									Virgin_Wines_other_Phone__c,
									Virgin_Wines_other_Post__c,
									Virgin_Wines_other_SMS__c,
									Other_Third_Parties_Email__c,
									Other_Virgin_Companies_Email__c,
									Send_a_Gift_emails__c,
									Send_a_Gift_other_Phone__c,
									Send_a_Gift_other_SMS__c,
									Send_a_Gift_other_Post__c,
									Wine_Advisor_emails__c
									FROM Individual
									WHERE Id = :individual.Id];
		System.assertEquals('Never', individualNew.Virgin_Wines_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Never', individualNew.Send_a_Gift_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Never', individualNew.Wine_Advisor_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Virgin_Wines_other_Phone__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Virgin_Wines_other_Post__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Virgin_Wines_other_SMS__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_Phone__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_SMS__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_Post__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(True, individualNew.Other_Third_Parties_Email__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(True, individualNew.Other_Virgin_Companies_Email__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :individualNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Individual is INSERTED/UPDATED. ');

	}

	//TEST MOCK #6 (method calling HttpCalloutMock Class):
	//OBJECT: Individual
	static testmethod void contactPermissionsSuccessDaily() {
		ContactPermissionsInvocableClass testContactPermissions = new ContactPermissionsInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = CalloutsClassTest.configAccount();
		insert account;

		//Get Contact linked to the Account with Store != 'vwshop' that was created when the Person Account was inserted:
		Contact contact = [SELECT Name, AccountId, Account.Store__c FROM Contact WHERE AccountId = :account.Id];

		//Insert Individual and link it to the Contact linked to the Account with Store = 'vwshop'
		Individual individual = new Individual(
				LastName = 'Mendes',
				Wine_Advisor_emails__c = 'Monthly',
				Contact__c = contact.Id

		);
		insert individual;

		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"Daily_Mail_emails": "Never","Daily_Mail_other_Phone": "false","Daily_Mail_other_SMS": "false","Daily_Mail_other_Post": "false","Send_a_Gift_emails": "Never","Send_a_Gift_other_Phone": "false", "Send_a_Gift_other_SMS": "false","Send_a_Gift_other_Post": "false","Mail_Wine_club_emails": "Never","Mail_Wine_club_other_Phone": "false","Mail_Wine_club_other_SMS": "false","Mail_Wine_club_other_Post": "false","Wine_Advisor_emails": "Never"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('3', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Create the Flow input
		List<ContactPermissionsInvocableClass.FlowInputs> inputs = new List<ContactPermissionsInvocableClass.FlowInputs>();
		ContactPermissionsInvocableClass.FlowInputs input = new ContactPermissionsInvocableClass.FlowInputs();
		input.Daily_Mail_emails = 'Never';
		input.checkboxGroupDailyMail = '';
		input.checkboxGroupSendDaily='';
		input.checkboxGroupMailWine='By Phone, By SMS, By Post';
		input.Send_a_Gift_EmailsDaily = 'Never';
		input.Wine_Advisor_EmailDaily = 'Never';
		input.Mail_Wine_club_emails = 'Never';
		input.accountId = account.Id;
		inputs.add(input);

		Test.startTest();
		ContactPermissionsInvocableClass.contactPreferences(inputs);
		Test.stopTest();

		Individual individualNew = [SELECT Virgin_Wines_emails__c,
				Daily_Mail_emails__c,
				Daily_Mail_Other_Phone__c,
				Daily_Mail_Other_SMS__c,
				Daily_Mail_Other_Post__c,
				Mail_Wine_club_emails__c,
				Send_a_Gift_emails__c,
				Send_a_Gift_other_Phone__c,
				Send_a_Gift_other_SMS__c,
				Send_a_Gift_other_Post__c,
				Wine_Advisor_emails__c,
				Mail_Wine_club_other_Phone__c,
				Mail_Wine_club_other_SMS__c,
				Mail_Wine_club_other_Post__c
				FROM Individual
				WHERE Id = :individual.Id];
		System.assertEquals('Never', individualNew.Daily_Mail_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Never', individualNew.Mail_Wine_club_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Never', individualNew.Send_a_Gift_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals('Never', individualNew.Wine_Advisor_emails__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Daily_Mail_Other_Phone__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Daily_Mail_Other_SMS__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Daily_Mail_Other_Post__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_Phone__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_SMS__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(false, individualNew.Send_a_Gift_other_Post__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(True, individualNew.Mail_Wine_club_other_Phone__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(True, individualNew.Mail_Wine_club_other_SMS__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(True, individualNew.Mail_Wine_club_other_Post__c, ' Subscription should have been updated with the values from the Mock Response ');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :individualNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Individual is INSERTED/UPDATED. ');

	}

	//TEST MOCK #7 (method calling HttpCalloutMock Class):
	//OBJECT: Individual
	static testmethod void contactPermissionError() {
		ContactPermissionsInvocableClass testContactPermissions = new ContactPermissionsInvocableClass();
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = CalloutsClassTest.configAccount();
		insert account;

		//Get Contact linked to the Account with Store != 'vwshop' that was created when the Person Account was inserted:
		Contact contact = [SELECT Name, AccountId, Account.Store__c FROM Contact WHERE AccountId = :account.Id];

		//Insert Individual and link it to the Contact linked to the Account with Store = 'vwshop'
		Individual individual = new Individual(
				LastName = 'Mendes',
				Wine_Advisor_emails__c = 'Monthly',
				Contact__c = contact.Id

		);
		insert individual;

		// Mock #3: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"Error"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('3', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Create the Flow input
		List<ContactPermissionsInvocableClass.FlowInputs> inputs = new List<ContactPermissionsInvocableClass.FlowInputs>();
		ContactPermissionsInvocableClass.FlowInputs input = new ContactPermissionsInvocableClass.FlowInputs();
		input.Daily_Mail_emails = 'Test';
		input.checkboxGroupDailyMail = '';
		input.checkboxGroupSendDaily='';
		input.checkboxGroupMailWine='By Phone, By SMS, By Post';
		input.Send_a_Gift_EmailsDaily = 'Never';
		input.Wine_Advisor_EmailDaily = 'Never';
		input.Mail_Wine_club_emails = 'Never';
		input.accountId = account.Id;
		inputs.add(input);

		Test.startTest();
		ContactPermissionsInvocableClass.contactPreferences(inputs);
		Test.stopTest();
		Individual individualNew = [SELECT Name
				FROM Individual
				WHERE Id = :individual.Id];
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :individualNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Individual is INSERTED/UPDATED. ');

	}

	//TEST MOCK #7 (method calling HttpCalloutMock Class):
	//OBJECT: Individual
	static testmethod void customerDetailsSuccess() {
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = CalloutsClassTest.configAccount();
		account.Created_on_Mantiki__c = true;
		insert account;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #2: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(200, 'Complete', '{"Daily_Mail_emails": "Never","Daily_Mail_other_Phone": "false","Daily_Mail_other_SMS": "false","Daily_Mail_other_Post": "false","Send_a_Gift_emails": "Never","Send_a_Gift_other_Phone": "false", "Send_a_Gift_other_SMS": "false","Send_a_Gift_other_Post": "false","Mail_Wine_club_emails": "Never","Mail_Wine_club_other_Phone": "false","Mail_Wine_club_other_SMS": "false","Mail_Wine_club_other_Post": "false","Wine_Advisor_emails": "Never"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//  Create Flow Inputs for the Invocable variables in the Invocable Class:
		CustomerDetailsInvocableClass.FlowInputs flowInputs = new CustomerDetailsInvocableClass.FlowInputs();
		flowInputs.personAccountId = account.Id;
		flowInputs.email = 'example@virginwines.co.uk';
		flowInputs.salutation = 'Mr';
		flowInputs.firstName = 'John Test';
		flowInputs.lastName = 'Smith';
		flowInputs.phone = '01234 567890';
		flowInputs.personHomePhone = '01234 567891';
		flowInputs.personOtherPhone = '01234 567892';

		// Method in the Invocable class only accepts a List as parameter:
		List<CustomerDetailsInvocableClass.FlowInputs> flowInputsList = new List<CustomerDetailsInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
		CustomerDetailsInvocableClass.getAccountDetails(flowInputsList);
		Test.stopTest();
		Account accountNew = [SELECT PersonEmail,
									Salutation,
									FirstName,
									LastName,
									Phone,
									PersonHomePhone,
									PersonOtherPhone,
									Risk_Level__c
									FROM Account
									WHERE Id = :account.Id];
		System.assertEquals('example@virginwines.co.uk',accountNew.PersonEmail , ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('Mr', accountNew.Salutation, ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('John Test',accountNew.FirstName , ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('Smith', accountNew.LastName, ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('01234 567890',accountNew.Phone , ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('01234 567891',accountNew.PersonHomePhone , ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals('01234 567892',accountNew.PersonOtherPhone , ' Account should have been updated with the values from the Mock Response ');
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :accountNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Individual is INSERTED/UPDATED. ');

	}

	//TEST MOCK #8 (method calling HttpCalloutMock Class):
	//OBJECT: Individual
	static testmethod void customerDetailsError() {
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Account account = CalloutsClassTest.configAccount();
		account.Created_on_Mantiki__c = true;
		insert account;

		// Mock #1: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual :
		CalloutsClassMock fakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"Customer_Number":"1212121","Customer_ID":121212121,"Title":"Mr","First_Name":"Nuno","Last_Name":"Mendes","Telephone_1":"1234567890","Telephone_2":null,"Telephone_3":null,"Date_Of_Birth":"27/02/1978","Fraud_Status":"10","Store_ID":"vwshop","VA_A_Number":"13","Email":"test@gmail.com","preferences":[{"Virgin_Wines_emails":true,"Virgin_Wines_other_Phone":false,"Virgin_Wines_other_SMS":false,"Virgin_Wines_other_Post":false,"Send_a_Gift_emails":"Never","Send_a_Gift_other_Phone":false,"Send_a_Gift_other_SMS":false,"Send_a_Gift_other_Post":false,"Other_Third_Parties_Email":true,"Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Daily_Mail_emails":"Never","Daily_Mail_other_Phone":false,"Daily_Mail_other_SMS":false,"Daily_Mail_other_Post":false,"Mail_Wine_club_emails":"Never","Mail_Wine_club_other_Phone":false,"Mail_Wine_club_other_SMS":false,"Mail_Wine_club_other_Post":false}]}', null);
		// Mock #2: Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and Individual :
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"Error"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', fakeResponse1);
		requestsMap.put('2', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//  Create Flow Inputs for the Invocable variables in the Invocable Class:
		CustomerDetailsInvocableClass.FlowInputs flowInputs = new CustomerDetailsInvocableClass.FlowInputs();
		flowInputs.personAccountId = account.Id;
		flowInputs.email = 'example@virginwines.co.uk';
		flowInputs.salutation = 'Mr';
		flowInputs.firstName = 'Error';
		flowInputs.lastName = 'Smith';
		flowInputs.phone = '01234 567890';
		flowInputs.personHomePhone = '01234 567891';
		flowInputs.personOtherPhone = '01234 567892';

		// Method in the Invocable class only accepts a List as parameter:
		List<CustomerDetailsInvocableClass.FlowInputs> flowInputsList = new List<CustomerDetailsInvocableClass.FlowInputs>();
		flowInputsList.add(flowInputs);

		Test.startTest();
		CustomerDetailsInvocableClass.getAccountDetails(flowInputsList);
		Test.stopTest();
		Account accountNew = [SELECT PersonEmail,
									Salutation,
									FirstName,
									LastName,
									Phone,
									PersonHomePhone,
									PersonOtherPhone,
									Risk_Level__c
									FROM Account
									WHERE Id = :account.Id];
		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :accountNew.Id].size(), ' CalloutsClass should insert a record of Callout Records when an Individual is INSERTED/UPDATED. ');

	}


	//TEST MOCK #9 (method calling HttpCalloutMock Class):
	//OBJECT: Account
	static testmethod void createB2BAccountSuccess() {
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();

		Account account = new Account(Name = 'Virgin Wines', RecordTypeId = recTypeId, Phone = '0000000000', Store__c = 'vwshop');
		insert account;

		// Mock #1: For Account Insert   -->  Success (200)
		// Return a success response from Mantiki with a JSON that matches the CreateAccountWrapper in the AccountProcess class so it can insert an Account and an Individual
		// (in this case the Mock the "contactPreferences" is empty so it won't insert an Individual ):
		CalloutsClassMock accountFakeResponse1 = new CalloutsClassMock(200, 'Complete', '{"id":1245,"customerNumber":"84002450","preferences":[{"Send_a_Gift_emails":"Never","Other_Virgin_Companies_Email":true,"Wine_Advisor_emails":"Never","Virgin_Wines_other_Phone":false,"Virgin_Wines_emails":"Never","Virgin_Wines_other_Post":false,"Send_a_Gift_other_SMS":false,"Other_Third_Parties_Email":true,"Virgin_Wines_other_SMS":false,"Send_a_Gift_other_Post":false,"Send_a_Gift_other_Phone":false}],"riskLevel":"Medium"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('1', accountFakeResponse1);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Create the Flow input
		List<AccountB2BInvocableClass.FlowInputs> inputs = new List<AccountB2BInvocableClass.FlowInputs>();
		AccountB2BInvocableClass.FlowInputs input = new AccountB2BInvocableClass.FlowInputs();
		input.accountId = account.Id;
		inputs.add(input);

		Test.startTest();
		AccountB2BInvocableClass.createB2BAccount(inputs);
		Test.stopTest();

		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(), ' CalloutsClass should insert a record of Callout Records when an account is INSERTED/UPDATED. ');

	}

	//TEST MOCK #9 (method calling HttpCalloutMock Class):
	//OBJECT: Account
	static testmethod void createB2BAccountError() {
		CalloutsClassTest.createCustomSetting();
		//Make token in custom setting different than null:
		Mantiki__c man = Mantiki__c.getOrgDefaults();
		man.Token__c = 'testing';
		update man;

		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();

		Account account = new Account(Name = 'ERROR B2B', RecordTypeId = recTypeId, Phone = '0000000000', Store__c = 'vwshop');
		insert account;

		// Mock #1: Return a error response from Mantiki with a JSON
		CalloutsClassMock fakeResponse2 = new CalloutsClassMock(400, 'Complete', '{"error_category":"Bad Request","error_type":"Invalid state","message":"Error"}', null);

		Map<String, HttpCalloutMock> requestsMap = new Map<String, HttpCalloutMock>();
		requestsMap.put('2', fakeResponse2);

		MultiRequestMock fakeMultiResponse  = new MultiRequestMock(requestsMap);
		Test.setMock(HttpCalloutMock.class, fakeMultiResponse);

		//Create the Flow input
		List<AccountB2BInvocableClass.FlowInputs> inputs = new List<AccountB2BInvocableClass.FlowInputs>();
		AccountB2BInvocableClass.FlowInputs input = new AccountB2BInvocableClass.FlowInputs();
		input.accountId = account.Id;
		inputs.add(input);

		Test.startTest();
		AccountB2BInvocableClass.createB2BAccount(inputs);
		Test.stopTest();

		System.assertEquals(1, [SELECT Object__c FROM Callout_Record__c WHERE Object__c = :account.Id].size(), ' CalloutsClass should insert a record of Callout Records when an error occur while inserting an account ');
	}


}