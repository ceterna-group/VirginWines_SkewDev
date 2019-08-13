global class WinebankHolidayInvocableClass {
	
	//Custom Setting:
	public static Mantiki__c mantikiSettings = new Mantiki__c();
	
	// "FlowInputs" wrapper class
	// @InvocableVariableVariables to fetch values from user input in the Flow to Apex
	public class FlowInputs{
		@InvocableVariable
		public String winebankId;
		
		@InvocableVariable
		public Date holidayStartDate;
		
		@InvocableVariable
		public Integer months;
		
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
	     Purpose: Get WineBank Holidy Start Date and Months from Flow and make REST Callout to Mantiki
	     Parameters: List<FlowInputs>
	     Returns: List<FlowOutputs>
	     Throws [Exceptions]: --
	*/
	@InvocableMethod(label='Invoke Apex method: getWinebankHoliday' description='Get WineBank Holidy Start Date and Months from Flow and make REST Callout to Mantiki')
	public static List<FlowOutputs> getWinebankHoliday(List<FlowInputs>  flowInputs) {
		//Wrapper class to store values to send back to Flow:
		FlowOutputs flowOutputs = new FlowOutputs();
		List<FlowOutputs> flowOutputsList = new List<FlowOutputs>();
		
		// Get values of the Custom Setting necessary for the REST CALLOUT:
		mantikiSettings = SettingsClass.getSettings();

		if(mantikiSettings.Message__c.startsWith(SettingsClass.BEGIN_PHRASE)) {



			Winebank_Membership__c winebank = [SELECT Customer_Account_ID__c, Customer__r.Customer_ID__c,  Holiday_Start_Date__c, Holiday_End_Date__c,
														Event_State__c, Next_Instalment_Date__c
												FROM Winebank_Membership__c
												WHERE Id = :flowInputs[0].winebankId];

			try {
				// PREPARE JSON TO BE SEND
				Map<String, Object> mapToSerialize = new Map<String, Object>();
				String jsonVar = '';
				// PREPARE BODY OF THE REQUEST
				mapToSerialize.put('startDay', flowInputs[0].holidayStartDate);
				mapToSerialize.put('months', flowInputs[0].months);
				jsonVar = JSON.serialize(mapToSerialize);

				// CALLOUT
				Map<String, String> connectionDetails = new Map<String, String>();
				connectionDetails.put('Token', 'Bearer ' + mantikiSettings.Token__c);
				HTTPResponse response = new HTTPResponse();
				connectionDetails.put('EndPoint',
								mantikiSettings.End_Point__c + mantikiSettings.Prefix__c + mantikiSettings.Winebank__c + '/' + 'holiday' + '/' + winebank.Customer__r.Customer_ID__c);


				// RESPONSE
				response = InterfaceClass.put(jsonVar, connectionDetails);


				// DESERIALIZE body of RESPONSE to use in fields of the Winebank object:
				ResponseClass responseValue = new ResponseClass();
				if(!String.isBlank(response.getBody())) {
					responseValue = (ResponseClass)System.JSON.deserialize(response.getBody(), ResponseClass.class);
				}


				// TREATMENT OF RESPONSE:
				if (response.getStatusCode() >= 400 && response.getStatusCode() <= 600 || response.getStatusCode() == 0) {
					// Variables to return to Flow from Apex:
					flowOutputs.responseStatusCode = response.getStatusCode();
					flowOutputs.responseMessage = response.getBody();

					/*if(!String.isBlank(responseValue.error_type) || !String.isBlank(responseValue.message)) {

						flowOutputs.responseErrorType = responseValue.error_type;
						flowOutputs.responseMessage = responseValue.message;
					}*/
					//Insert Callout Record Error:
					CalloutRecord.insertCalloutRecordError('WinebankHolidayInvocableClass',
									'getWinebankHoliday ' + 'holiday', InterfaceClass.saveRequest, response, null, winebank.Id);
				} else {
					//Insert Callout Record Success:
					CalloutRecord.insertCalloutRecordSuccess('WinebankHolidayInvocableClass',
									'getWinebankHoliday ' + 'holiday', InterfaceClass.saveRequest, response, null,	winebank.Id);

					//If the request is successful 'start date', 'end date', 'state' and 'due on date' should be updated on the WineBank membership object:
					winebank.Holiday_Start_Date__c = flowInputs[0].holidayStartDate;
					winebank.Holiday_End_Date__c = responseValue.endDay;
					winebank.Event_State__c = responseValue.state;
					winebank.Next_Instalment_Date__c = responseValue.dueOn;
					update winebank;
				}

				flowOutputsList.add(flowOutputs);

			}catch (Exception e) {
				System.debug('Error::' + e.getMessage());
				CalloutRecord.insertCalloutRecordError('WinebankHolidayInvocableClass',
						'getWinebankHoliday', null, null,e.getMessage()+ '\n'+ e.getStackTraceString(),winebank.Id);
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
		//Variables from Response to update the fields of the Winebank object:
		public Date endDay {get;set;}
		public String state {get;set;}
		public Date dueOn {get;set;}
	}
}