public class AccountB2BInvocableClass {
	public static Mantiki__c mantikiSettings = new Mantiki__c();

	public class FlowInputs{
		@InvocableVariable
		public String accountId;
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

	@InvocableMethod(label='Invoke Apex method: createB2BAccount' description='Create B2B Account in Mantiki from Flow')
	public static List<FlowOutputs> createB2BAccount(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
		Account account = [SELECT Name,
							RecordTypeId,
							Customer_ID__c,
							Store__c,
							Corporate__c,
							Phone,
							Telephone_2__c,
							Telephone_3__c,
							BillingAddress,
							FirstName,
							LastName,
							Salutation
							FROM Account
							WHERE Id = :flowInputs[0].accountId
							AND RecordTypeId = :recTypeId];
		System.debug(account);

		try {
			// Get values of the Custom Setting necessary for the REST CALLOUT:
			mantikiSettings = SettingsClass.getSettings();

			if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {
				//PREPARE BODY OF THE REQUEST
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';

				//PREPARE BODY OF THE REQUEST
				mapToSerialize.put('salesforceId',account.Id);
				mapToSerialize.put('store', 'vwshop');
				mapToSerialize.put('emailAddress', account.Name.replaceAll('[^a-zA-Z0-9\\s+]', '').replaceAll( '\\s+', '') + '@corpvirginwines.co.uk');
				mapToSerialize.put('title', 'Mr');
				mapToSerialize.put('firstName',account.Name);
				mapToSerialize.put('lastName',account.Name);
				mapToSerialize.put('telephone1',account.Phone);
				mapToSerialize.put('telephone2',account.Telephone_2__c);
				mapToSerialize.put('telephone3',account.Telephone_3__c);
				mapToSerialize.put('dateOfBirth',Datetime.newInstance(1970, 1, 1));
				mapToSerialize.put('allowContact',FALSE);
				mapToSerialize.put('corporate', TRUE);
				jsonVar = JSON.serialize(mapToSerialize);
				System.debug('jsonVar ' + jsonVar);
				//CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer '+mantikiSettings.token__c);
				HttpResponse response = new HttpResponse();
				connectionDetails.put('EndPoint', mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Account__c);
				response = InterfaceClass.post(jsonVar,connectionDetails);

				/*ResponseClass responseValue = new ResponseClass();
				if(!String.isBlank(response.getBody())) {

					responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
				}*/

				//TREATMENT OF RESPONSE
				if(response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();

					/*if(!String.isBlank(responseValue.error_type) || !String.isBlank(responseValue.message)) {
						flowOutputs.responseErrorType = responseValue.error_type;
						flowOutputs.responseMessage = responseValue.message;
					}*/

					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('AccountB2BInvocableClass', 'createB2BAccount', InterfaceClass.saveRequest, response, null, account.Id);

				} else {
					//Insert Callout Record Sucess:
					CalloutRecord.insertCalloutRecordSuccess('AccountB2BInvocableClass', 'createB2BAccount', InterfaceClass.saveRequest, response,null,account.Id);

					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getStatus();

				}
				flowOutputsList.add(flowOutputs);
			} else {
				flowOutputs.responseStatusCode = Integer.valueOf(mantikiSettings.Status_Code__c);
				flowOutputs.responseMessage = mantikiSettings.Message__c;
				flowOutputsList.add(flowOutputs);
			}

		} catch(Exception e) {
			System.debug('Error::' + e.getMessage());
			CalloutRecord.insertCalloutRecordError('AccountB2BInvocableClass', 'createB2BAccount', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),account.Id);
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