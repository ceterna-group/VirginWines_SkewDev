public class CustomerDetailsInvocableClass {
	
	//Custom Setting:
	public static Mantiki__c mantikiSettings = new Mantiki__c();
	
	// "FlowInputs" wrapper class
	// @InvocableVariableVariables to fetch values from user input in the Flow to Apex
	public class FlowInputs{
		@InvocableVariable
		public String personAccountId;
		
		@InvocableVariable
		public String email;
		
		@InvocableVariable
		public String salutation;
		
		@InvocableVariable
		public String firstName;
		
		@InvocableVariable
		public String lastName;
		
		@InvocableVariable
		public String phone;
		
		@InvocableVariable
		public String personHomePhone;
		
		@InvocableVariable
		public String personOtherPhone;
		
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
	
	
	/*
	     Purpose: Get Account Details from Flow and make REST Callout to Mantiki
	     Parameters: List<FlowInputs>
	     Returns: List<FlowOutputs>
	     Throws [Exceptions]: --
	*/
	@InvocableMethod(label='Invoke Apex method: getAccountDetails' description='Get Account Details from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> getAccountDetails(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		
		// Get values of the Custom Setting necessary for the REST CALLOUT:
		mantikiSettings = SettingsClass.getSettings();

		if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {


			Account personAccount = [SELECT Salutation, FirstName, LastName, PersonBirthdate,
											AccountNumber, Customer_ID__c, PersonContactId,
											Phone, PersonHomePhone, PersonOtherPhone, PersonEmail, Risk_Level__c
									FROM Account
									WHERE Id = :flowInputs[0].personAccountId];

			try {
				// PREPARE JSON TO BE SEND
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';
				// PREPARE BODY OF THE REQUEST
				mapToSerialize.put('emailAddress', flowInputs[0].email);
				mapToSerialize.put('title', flowInputs[0].salutation);
				mapToSerialize.put('firstName', flowInputs[0].firstName);
				mapToSerialize.put('lastName', flowInputs[0].lastName);
				if(!String.isBlank(flowInputs[0].phone)){
					mapToSerialize.put('telephone1', flowInputs[0].phone);
				}
				if(!String.isBlank(flowInputs[0].personHomePhone)){
					mapToSerialize.put('telephone2', flowInputs[0].personHomePhone);
				}
				if(!String.isBlank(flowInputs[0].personOtherPhone)){
					mapToSerialize.put('telephone3', flowInputs[0].personOtherPhone);
				}
				jsonVar = JSON.serialize(mapToSerialize);

				// CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer ' + mantikiSettings.Token__c);
				HTTPResponse response = new HTTPResponse();
				connectionDetails.put('EndPoint',
								mantikiSettings.End_Point__c + mantikiSettings.Prefix__c + mantikiSettings.Account__c + '/' + personAccount.Customer_ID__c);

				// RESPONSE
				response = InterfaceClass.put(jsonVar, connectionDetails);

				// TREATMENT OF RESPONSE:
				if (response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// DESERIALIZE body of RESPONSE (in this case the Response Body only has content if it's an ERROR >=400 <=500)
					//ResponseClass responseValue = new ResponseClass();
					//responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);

					// Variables to return to Flow from Apex:
					System.debug('Status Code');
					System.debug(response.getStatusCode());
					System.debug(response.getBody());
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();
					/*flowOutputs.responseErrorType = responseValue.error_type;
					flowOutputs.responseMessage = responseValue.message;*/
					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('CustomerDetailsInvocableClass',
									'getAccountDetails ' , InterfaceClass.saveRequest, response, null, personAccount.Id);
					// Add FlowOutput to the List to be returned to the FLOW:
					flowOutputsList.add(flowOutputs);
				} else {
					//Insert Callout Record Success:
					CalloutRecord.insertCalloutRecordSuccess('CustomerDetailsInvocableClass',
									'getAccountDetails ', InterfaceClass.saveRequest, response, null, personAccount.Id);

					//If the request is successful Account Details from Flow should be updated on the Account object:
					personAccount.PersonEmail = flowInputs[0].email;
					personAccount.Salutation = flowInputs[0].salutation;
					personAccount.FirstName = flowInputs[0].firstName;
					personAccount.LastName = flowInputs[0].lastName;
					personAccount.Phone = flowInputs[0].phone;
					personAccount.PersonHomePhone = flowInputs[0].personHomePhone;
					personAccount.PersonOtherPhone = flowInputs[0].personOtherPhone;
					update personAccount;

				}


			}catch (Exception e) {
				System.debug('Error::' + e.getMessage());
				CalloutRecord.insertCalloutRecordError('CustomerDetailsInvocableClass',
						'getAccountDetails', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),personAccount.Id);
			}
		} else {
			flowOutputs.responseStatusCode = Integer.valueOf(mantikiSettings.Status_Code__c);
			flowOutputs.responseMessage = mantikiSettings.Message__c;
			flowOutputsList.add(flowOutputs);
		}
		return flowOutputsList;
	}
	
	//Wrapper Class to store values coming from JSON of CALLOUT Response
	public class ResponseClass{
		ResponseClass(){
		
		}
		//Variables to send back to FLow from Apex,
		// Variable names must match exactly the names in the JSON of the Body of Response:
		public String message {get;set;}
		public String error_type {get;set;}
		
	}
}