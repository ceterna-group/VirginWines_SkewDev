public class SubscriptionCancelInvocableClass {
	public static Mantiki__c mantikiSettings = new Mantiki__c();

	public class FlowInputs{
		@InvocableVariable
		public String cancelReason;

		@InvocableVariable
		public String subscriptionId;
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

	@InvocableMethod(label='Invoke Apex method: cancelSubscription' description='Get Subscription Cancel Reason from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> cancelSubscription(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();

		Subscriptions__c subscription = [SELECT Cancel_Reason__c, Customer_Subscription_ID__c FROM Subscriptions__c WHERE Id = :flowInputs[0].subscriptionId];

		System.debug('subscription');
		System.debug(subscription);

		try {
			// Get values of the Custom Setting necessary for the REST CALLOUT:
			mantikiSettings = SettingsClass.getSettings();

			if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {

				//PREPARE BODY OF THE REQUEST
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';

				//PREPARE BODY OF THE REQUEST
				mapToSerialize.put('reasonCode',flowInputs[0].cancelReason);
				System.debug('Cancel');
				jsonVar = JSON.serialize(mapToSerialize);

				//CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer '+mantikiSettings.token__c);
				HttpResponse response = new HttpResponse();
				connectionDetails.put('EndPoint', mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Subscriptions__c+'/'+'cancel'+'/'+subscription.Customer_Subscription_ID__c);

				response = InterfaceClass.put(jsonVar, connectionDetails);
				System.debug('Cancel2');
				System.debug(response);
				ResponseClass responseValue = new ResponseClass();
				responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);


				//TREATMENT OF RESPONSE
				if(response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();

					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('SubscriptionCancelInvocableClass', 'cancelSubscription', InterfaceClass.saveRequest, response, null, subscription.Id);

				} else {
					//Insert Callout Record Sucess:
					CalloutRecord.insertCalloutRecordSuccess('SubscriptionCancelInvocableClass', 'cancelSubscription', InterfaceClass.saveRequest, response,null,subscription.Id);
					//If the request is successful 'Cancel Reason', 'Winebank State', 'Cancel Date', 'Winebank Balance' and 'Winebank Interest' should be updated on the WineBank membership object:
					subscription.Cancel_Reason__c = flowInputs[0].cancelReason;
					subscription.Subscription_State__c = responseValue.state;
					subscription.Cancel_Date__c = responseValue.leftOn;

					update subscription;
				}
				flowOutputsList.add(flowOutputs);
			} else {
				flowOutputs.responseStatusCode = Integer.valueOf(mantikiSettings.Status_Code__c);
				flowOutputs.responseMessage = mantikiSettings.Message__c;
				flowOutputsList.add(flowOutputs);
			}
		} catch (Exception e) {
			System.debug('Error::' + e.getMessage());
			CalloutRecord.insertCalloutRecordError('SubscriptionCancelInvocableClass', 'cancelSubscription', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),subscription.Id);
		}
		return flowOutputsList;
	}

	public List<FlowInputs> getWrapper(String cancelReason, String subscriptionId) {
		List<FlowInputs> inputs = new List<FlowInputs>();
		FlowInputs input = new FlowInputs();
		input.cancelReason = cancelReason;
		input.subscriptionId = subscriptionId;
		inputs.add(input);

		return inputs;
	}

	//Wrapper Class to store values coming from JSON of CALLOUT Response
	public class ResponseClass {
		responseClass() {

		}

		//Variables to send to FLow from Apex, variable names must be exacly as in JSON of Response:
		public Integer statusCode { get;set; }
		public String message { get;set; }
		public String error_type { get;set; }

		//Variables from Response to update the fields of the subscription:
		public Datetime leftOn { get; set; }
		public String state { get; set; }
	}
}