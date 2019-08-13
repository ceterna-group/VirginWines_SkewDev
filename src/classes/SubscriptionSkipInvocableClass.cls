public class SubscriptionSkipInvocableClass {
	//Custom Setting:
	public static Mantiki__c mantikiSettings = new Mantiki__c();
	
	// "FlowInputs" wrapper class
	// @InvocableVariableVariables to fetch values from user input in the Flow to Apex
	public class FlowInputs{
		
		@InvocableVariable
		public String subscriptionId;
		
		@InvocableVariable
		public String skipReasonCode;
		
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
	     Purpose: Get Subscription Skip Reason Code from Flow and make REST Callout to Mantiki
	     Parameters: List<FlowInputs>
	     Returns: List<FlowOutputs>
	     Throws [Exceptions]: --
	*/
	@InvocableMethod(label='Invoke Apex method: getSubscriptionSkip' description='Get Subscription Skip Reason Code from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> getSubscriptionSkip(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		
		// Get values of the Custom Setting necessary for the REST CALLOUT:
		mantikiSettings = SettingsClass.getSettings();

		if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {

			Subscriptions__c subscription = [SELECT Customer_Subscription_ID__c, Skip_Reason__c, Event_State__c, Due_Date__c
											FROM Subscriptions__c
											WHERE Id = :flowInputs[0].subscriptionId];

			try {
				// PREPARE JSON TO BE SEND
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';
				// PREPARE BODY OF THE REQUEST
				mapToSerialize.put('reasonCode', flowInputs[0].skipReasonCode);
				jsonVar = JSON.serialize(mapToSerialize);

				// CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer ' + mantikiSettings.Token__c);
				HTTPResponse response = new HTTPResponse();
				connectionDetails.put('EndPoint',
								mantikiSettings.End_Point__c + mantikiSettings.Prefix__c + mantikiSettings.Subscriptions__c + '/' + 'skip' + '/' + subscription.Customer_Subscription_ID__c);

				// RESPONSE
				response = InterfaceClass.put(jsonVar, connectionDetails);

				// DESERIALIZE body of RESPONSE to use in fields of the Subscription object:
				ResponseClass responseValue = new ResponseClass();

				if(!String.isBlank(response.getBody())) {
					responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
				}

				// TREATMENT OF RESPONSE:
				if (response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();

					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('SubscriptionSkipInvocableClass',
									'getSubscriptionSkip ' + 'skip', InterfaceClass.saveRequest, response, null, subscription.Id);
				} else {
					//Insert Callout Record Success:
					CalloutRecord.insertCalloutRecordSuccess('SubscriptionSkipInvocableClass',
									'getSubscriptionSkip ' + 'skip', InterfaceClass.saveRequest, response, null, subscription.Id);

					//If the request is successful 'start date', 'end date', 'state' and 'due on date' should be updated on the WineBank membership object:
					subscription.Skip_Reason__c = flowInputs[0].skipReasonCode;
					subscription.Event_State__c = responseValue.state;
					subscription.Due_Date__c = responseValue.dueOn;
					update subscription;
				}

				flowOutputsList.add(flowOutputs);

			}catch (Exception e) {
				System.debug('Error::' + e.getMessage());
				CalloutRecord.insertCalloutRecordError('SubscriptionSkipInvocableClass',
						'getSubscriptionSkip', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),subscription.Id);
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
		//Variables from Response to update the fields of the Subscription object:
		public String state {get;set;}
		public Date dueOn {get;set;}
	}
}