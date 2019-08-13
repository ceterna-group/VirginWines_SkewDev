global class WineBankCancelInvocableClass {

	public static Mantiki__c mantikiSettings = new Mantiki__c();

	public class FlowInputs{
		@InvocableVariable
		public Boolean balanceToCustomer;

		@InvocableVariable
		public String cancelReason;

		@InvocableVariable
		public String winebankId;
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

	@InvocableMethod(label='Invoke Apex method: cancelWineBank' description='Get Winebank Cancel Reason and balance from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> cancelWineBank(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();

		Winebank_Membership__c winebank = [SELECT Customer_Account_ID__c, Customer__r.Customer_ID__c
	                                        FROM Winebank_Membership__c
		                                    WHERE Id = :flowInputs[0].winebankId];

		try {
			// Get values of the Custom Setting necessary for the REST CALLOUT:
			mantikiSettings = SettingsClass.getSettings();

			if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {

				//PREPARE JSON TO BE SEND
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';

				//PREPARE BODY OF THE REQUEST
				mapToSerialize.put('reasonCode',flowInputs[0].cancelReason);
				mapToSerialize.put('refundBalance',flowInputs[0].balanceToCustomer);
				jsonVar = JSON.serialize(mapToSerialize);

				//CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer '+mantikiSettings.token__c);
				HttpResponse response = new HttpResponse();
				connectionDetails.put('EndPoint', mantikiSettings.End_Point__c+mantikiSettings.Prefix__c+mantikiSettings.Winebank__c+'/'+'cancel'+'/'+winebank.Customer__r.Customer_ID__c);

				response = InterfaceClass.put(jsonVar, connectionDetails);

				ResponseClass responseValue = new ResponseClass();
				if(!String.isBlank(response.getBody())) {

					System.debug('In is blank');
					responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
					System.debug('In is blank');
				}

				//TREATMENT OF RESPONSE
				if(response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();
					/*
					if(!String.isBlank(responseValue.error_type) || !String.isBlank(responseValue.message)) {
						flowOutputs.responseErrorType = responseValue.error_type;
						flowOutputs.responseMessage = responseValue.message;
					}*/

					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('WineBankCancelInvocableClass', 'cancelWineBank', InterfaceClass.saveRequest, response, null, winebank.Id);

				} else {
					//Insert Callout Record Sucess:
					CalloutRecord.insertCalloutRecordSuccess('WineBankCancelInvocableClass', 'cancelWineBank', InterfaceClass.saveRequest, response,null,winebank.Id);
					//If the request is successful 'Cancel Reason', 'Winebank State', 'Cancel Date', 'Winebank Balance' and 'Winebank Interest' should be updated on the WineBank membership object:
					winebank.Cancel_Reason__c = flowInputs[0].cancelReason;
					winebank.Winebank_State__c = responseValue.state;
					winebank.Cancel_Date__c = responseValue.leftOn;
					winebank.WineBank_Interest__c = responseValue.interest;
					winebank.WineBank_Balance__c = responseValue.balance;

					update winebank;

					System.debug('Cancel winebank ' + winebank);
				}
				flowOutputsList.add(flowOutputs);
			}  else {
				flowOutputs.responseStatusCode = Integer.valueOf(mantikiSettings.Status_Code__c);
				flowOutputs.responseMessage = mantikiSettings.Message__c;
				flowOutputsList.add(flowOutputs);
			}
		} catch (Exception e) {
			System.debug('Error::' + e.getMessage());
			CalloutRecord.insertCalloutRecordError('WineBankCancelInvocableClass', 'cancelWineBank', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),winebank.Id);
		}
		return flowOutputsList;
	}

	public List<FlowInputs> getWrapper(Boolean balanceToCustomer, String cancelReason, String winebankId) {
		List<FlowInputs> inputs = new List<FlowInputs>();
		FlowInputs input = new FlowInputs();
		input.balanceToCustomer = balanceToCustomer;
		input.cancelReason = cancelReason;
		input.winebankId = winebankId;
		inputs.add(input);

		return inputs;
	}
	//Wrapper Class to store values coming from JSON of CALLOUT Response
	public class ResponseClass{
		responseClass() {

		}
		//Variables to send to FLow from Apex, variable names must be exacly as in JSON of Response:
		public Integer statusCode {get;set;}
		public String message {get;set;}
		public String error_type {get;set;}
		//Variables from Response to update the fields of the Winebank:
		public Datetime leftOn { get; set; }
		public String state { get; set; }
		public Double balance { get; set; }
		public Double interest { get; set; }
	}
}