public class ContactPermissionsInvocableClass {
	public static Mantiki__c mantikiSettings = new Mantiki__c();

	public class FlowInputs{
		@InvocableVariable
		public String accountId;

		@InvocableVariable
		public String Virgin_Wines_Emails;

		@InvocableVariable
		public String Send_a_Gift_Emails;

		@InvocableVariable
		public String checkboxGroupSend;

		@InvocableVariable
		public String checkboxGroupVW;

		//Daily Customer
		@InvocableVariable
		public String Send_a_Gift_EmailsDaily;

		@InvocableVariable
		public String checkboxGroupSendDaily;

		@InvocableVariable
		public String checkboxGroupDailyMail;

		@InvocableVariable
		public String checkboxGroupMailWine;

		@InvocableVariable
		public String Daily_Mail_emails;

		@InvocableVariable
		public String Mail_Wine_club_emails;

		@InvocableVariable
		public Boolean Other_Virgin_Companies_Email;

		@InvocableVariable
		public Boolean Other_Third_Parties_Email;

		@InvocableVariable
		public String Wine_Advisor_Email;

		@InvocableVariable
		public String Wine_Advisor_EmailDaily;

	}

	// "FlowOutputs" wrapper class
	// @InvocableVariables to store outputs from Apex to Flow
	public class FlowOutputs{
		@InvocableVariable
		public Integer responseStatusCode;

		@InvocableVariable
		public String responseErrorType;

		@InvocableVariable
		public String responseMessage;

	}

	@InvocableMethod(label='Invoke Apex method: contactPreferences' description='Get Subscription Cancel Reason from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> contactPreferences(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();

		//API Version shoul be 42
		Individual person = [SELECT Name, Customer_ID__c, Contact__r.Account.AccountNumber, Contact__r.Account.Store__c
							FROM Individual
							WHERE Contact__r.Account.Id = :flowInputs[0].accountId LIMIT 1];

		try {
			// Get values of the Custom Setting necessary for the REST CALLOUT:
			mantikiSettings = SettingsClass.getSettings();

			if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {
				//PREPARE BODY OF THE REQUEST
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';
				System.debug('Before vwshop');
				//PREPARE BODY OF THE REQUEST
				if(person.Contact__r.Account.Store__c == 'vwshop') {
					System.debug('IN vwshop');
					//(flowInputs[0].checkboxGroupVW.contains('By SMS') ? 'True' : 'False')
					mapToSerialize.put('Virgin_Wines_emails',flowInputs[0].Virgin_Wines_Emails);
					mapToSerialize.put('Virgin_Wines_other_Phone',flowInputs[0].checkboxGroupVW.contains('By Phone'));
					mapToSerialize.put('Virgin_Wines_other_SMS',flowInputs[0].checkboxGroupVW.contains('By SMS'));
					mapToSerialize.put('Virgin_Wines_other_Post',flowInputs[0].checkboxGroupVW.contains('By Post'));
					mapToSerialize.put('Send_a_Gift_emails',flowInputs[0].Send_a_Gift_Emails);
					mapToSerialize.put('Send_a_Gift_other_Phone',flowInputs[0].checkboxGroupSend.contains('By Phone'));
					mapToSerialize.put('Send_a_Gift_other_SMS',flowInputs[0].checkboxGroupSend.contains('By SMS'));
					mapToSerialize.put('Send_a_Gift_other_Post',flowInputs[0].checkboxGroupSend.contains('By Post'));
					mapToSerialize.put('Other_Third_Parties_Email',flowInputs[0].Other_Third_Parties_Email);
					mapToSerialize.put('Other_Virgin_Companies_Email',flowInputs[0].Other_Virgin_Companies_Email);
					mapToSerialize.put('Wine_Advisor_emails',flowInputs[0].Wine_Advisor_Email);
				} else {
					System.debug('OUT vwshop');
					mapToSerialize.put('Daily_Mail_emails',flowInputs[0].Daily_Mail_emails);
					mapToSerialize.put('Daily_Mail_other_Phone',flowInputs[0].checkboxGroupDailyMail.contains('By Phone'));
					mapToSerialize.put('Daily_Mail_other_SMS',flowInputs[0].checkboxGroupDailyMail.contains('By SMS'));
					mapToSerialize.put('Daily_Mail_other_Post',flowInputs[0].checkboxGroupDailyMail.contains('By Post'));
					mapToSerialize.put('Mail_Wine_club_emails',flowInputs[0].Mail_Wine_club_emails);
					mapToSerialize.put('Mail_Wine_club_other_Phone',flowInputs[0].checkboxGroupMailWine.contains('By Phone'));
					mapToSerialize.put('Mail_Wine_club_other_SMS',flowInputs[0].checkboxGroupMailWine.contains('By SMS'));
					mapToSerialize.put('Mail_Wine_club_other_Post', flowInputs[0].checkboxGroupMailWine.contains('By Post'));
					mapToSerialize.put('Send_a_Gift_emails',flowInputs[0].Send_a_Gift_EmailsDaily);
					mapToSerialize.put('Send_a_Gift_other_Phone',flowInputs[0].checkboxGroupSendDaily.contains('By Phone'));
					mapToSerialize.put('Send_a_Gift_other_SMS',flowInputs[0].checkboxGroupSendDaily.contains('By SMS'));
					mapToSerialize.put('Send_a_Gift_other_Post',flowInputs[0].checkboxGroupSendDaily.contains('By Post'));
					mapToSerialize.put('Wine_Advisor_emails',flowInputs[0].Wine_Advisor_EmailDaily);
					System.debug('Daily_Mail_emails ' + flowInputs[0].Daily_Mail_emails);
					System.debug('Daily_Mail_other_Phone ' + flowInputs[0].checkboxGroupDailyMail.contains('By Phone'));
					System.debug('Daily_Mail_other_SMS ' + flowInputs[0].checkboxGroupDailyMail.contains('By SMS'));
					System.debug('Daily_Mail_other_Post ' + flowInputs[0].checkboxGroupDailyMail.contains('By Post'));
					System.debug('Mail_Wine_club_emails ' + flowInputs[0].Mail_Wine_club_emails);
					System.debug('Mail_Wine_club_other_Phone ' + flowInputs[0].checkboxGroupMailWine.contains('By Phone'));
					System.debug('Mail_Wine_club_other_SMS ' + flowInputs[0].checkboxGroupMailWine.contains('By SMS'));
					System.debug('Mail_Wine_club_other_Post ' + flowInputs[0].checkboxGroupMailWine.contains('By Post'));
					System.debug('Send_a_Gift_emails ' + flowInputs[0].checkboxGroupMailWine.contains('By Post'));
					System.debug('Send_a_Gift_other_Phone ' + flowInputs[0].Send_a_Gift_EmailsDaily);
					System.debug('Send_a_Gift_other_Phone ' + flowInputs[0].checkboxGroupSendDaily.contains('By Phone'));
					System.debug('Send_a_Gift_other_SMS ' + flowInputs[0].checkboxGroupSendDaily.contains('By SMS'));
					System.debug('Send_a_Gift_other_Post ' + flowInputs[0].checkboxGroupSendDaily.contains('By Post'));
					System.debug('Wine_Advisor_emails ' + flowInputs[0].Wine_Advisor_EmailDaily);

				}

				jsonVar = '{"contactPreferences" : '+JSON.serialize(mapToSerialize)+'}';

				//CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer '+mantikiSettings.token__c);
				HttpResponse response = new HttpResponse();
				connectionDetails.put('EndPoint', mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Individual__c+'/'+person.Customer_ID__c);

				response = InterfaceClass.put(jsonVar, connectionDetails);

				//TREATMENT OF RESPONSE
				if(response.getStatusCode() >= 400 && response.getStatusCode() <= 500 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();

					flowOutputsList.add(flowOutputs);
					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('ContactPermissionsInvocableClass', 'contactPreferences', InterfaceClass.saveRequest, response, null, person.Id);

				} else {
					//Insert Callout Record Sucess:
					CalloutRecord.insertCalloutRecordSuccess('ContactPermissionsInvocableClass', 'contactPreferences', InterfaceClass.saveRequest, response,null,person.Id);
					//If the request is successful 'Cancel Reason', 'Winebank State', 'Cancel Date', 'Winebank Balance' and 'Winebank Interest' should be updated on the WineBank membership object:



					if(person.Contact__r.Account.Store__c == 'vwshop') {
						person.Virgin_Wines_emails__c = flowInputs[0].Virgin_Wines_Emails;
						person.Virgin_Wines_other_Phone__c = flowInputs[0].checkboxGroupVW.contains('By Phone');
						person.Virgin_Wines_other_Post__c = flowInputs[0].checkboxGroupVW.contains('By Post');
						person.Virgin_Wines_other_SMS__c = flowInputs[0].checkboxGroupVW.contains('By SMS');
						person.Other_Third_Parties_Email__c = flowInputs[0].Other_Third_Parties_Email;
						person.Other_Virgin_Companies_Email__c = flowInputs[0].Other_Virgin_Companies_Email;
						person.Send_a_Gift_emails__c = flowInputs[0].Send_a_Gift_Emails;
						person.Send_a_Gift_other_Phone__c = flowInputs[0].checkboxGroupSend.contains('By Phone');
						person.Send_a_Gift_other_SMS__c = flowInputs[0].checkboxGroupSend.contains('By SMS');
						person.Send_a_Gift_other_Post__c = flowInputs[0].checkboxGroupSend.contains('By Post');
						person.Wine_Advisor_emails__c = flowInputs[0].Wine_Advisor_Email;
					} else {
						person.Daily_Mail_emails__c = flowInputs[0].Daily_Mail_emails;
						person.Daily_Mail_Other_Phone__c = flowInputs[0].checkboxGroupDailyMail.contains('By Phone');
						person.Daily_Mail_Other_SMS__c = flowInputs[0].checkboxGroupDailyMail.contains('By SMS');
						person.Daily_Mail_Other_Post__c = flowInputs[0].checkboxGroupDailyMail.contains('By Post');
						person.Mail_Wine_club_emails__c = flowInputs[0].Mail_Wine_club_emails;
						person.Mail_Wine_club_other_Phone__c = flowInputs[0].checkboxGroupMailWine.contains('By Phone');
						person.Mail_Wine_club_other_SMS__c = flowInputs[0].checkboxGroupMailWine.contains('By SMS');
						person.Mail_Wine_club_other_Post__c = flowInputs[0].checkboxGroupMailWine.contains('By Post');
						person.Send_a_Gift_emails__c = flowInputs[0].Send_a_Gift_EmailsDaily;
						person.Send_a_Gift_other_Phone__c = flowInputs[0].checkboxGroupSendDaily.contains('By Phone');
						person.Send_a_Gift_other_SMS__c = flowInputs[0].checkboxGroupSendDaily.contains('By SMS');
						person.Send_a_Gift_other_Post__c = flowInputs[0].checkboxGroupSendDaily.contains('By Post');
						person.Wine_Advisor_emails__c = flowInputs[0].Wine_Advisor_EmailDaily;
					}
					update person;
				}
			} else {
				flowOutputs.responseStatusCode = Integer.valueOf(mantikiSettings.Status_Code__c);
				flowOutputs.responseMessage = mantikiSettings.Message__c;
				flowOutputsList.add(flowOutputs);
			}
		} catch(Exception e) {
			System.debug('Error::' + e.getMessage());
			CalloutRecord.insertCalloutRecordError('ContactPermissionsInvocableClass', 'contactPreferences', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),person.Id);
		}
		return flowOutputsList;
	}

	//Wrapper Class to store values coming from JSON of CALLOUT Response
	public class ResponseClass {
		responseClass() {

		}

		//Variables to send to FLow from Apex, variable names must be exacly as in JSON of Response:
		public String message { get;set; }
		public String error_type { get;set; }
	}
}