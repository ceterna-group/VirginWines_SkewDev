public with sharing class CalloutRecord {

	public static void insertCalloutRecordError(String className, String methodName, HttpRequest request, HttpResponse response,String message,String objectId){
		insertCalloutRecord(className,methodName,request,response,'Error',message,objectId);
	}
	public static void insertCalloutRecordWarning(String className, String methodName, HttpRequest request, HttpResponse response,String message,String objectId){
		insertCalloutRecord(className,methodName,request,response,'Warning',message,objectId);
	}
	public static void insertCalloutRecordSuccess(String className, String methodName, HttpRequest request, HttpResponse response,String message,String objectId){
		insertCalloutRecord(className,methodName,request,response,'Success',message,objectId);
	}	

	public static void insertCalloutRecord(String className, String methodName, HttpRequest request, HttpResponse response,String typeRecord,String message,String objectId){
			Callout_Record__c calloutRecord = new Callout_Record__c();

			calloutRecord.User_Id__c = UserInfo.getUserId();
			calloutRecord.User_Name__c = UserInfo.getName();
			calloutRecord.Callout_Date__c = String.valueOfGmt(Datetime.now());
			calloutRecord.Class_Name__c = className;
			calloutRecord.Method_Name__c = methodName;
			if(request!=null){
				calloutRecord.HTTP_Method__c = request.getMethod();
				calloutRecord.JSON_Sent__c = request.getBody();
				calloutRecord.Request_End_Point__c = request.getEndpoint();
			}
			if(response!=null)	{
				calloutRecord.JSON_Received__c = response.getBody();
				calloutRecord.Status_Code__c = response.getStatusCode();
				calloutRecord.Status_Message__c = response.getStatus();
			}			
			calloutRecord.Type_Record__c = typeRecord;
			calloutRecord.Message__c = message;
			calloutRecord.Object__c = objectId;
			calloutRecord.Type__c = 'Call Out';
		insert calloutRecord;
	}

	public static void insertCallinRecordError(String className, String methodName, String jsonReceived, String jsonSend,String message,String objectId,String httpMethod){
		insertCallinRecord(className,methodName,jsonReceived,jsonSend,'Error',message,objectId,httpMethod);
	}
	public static void insertCallinRecordWarning(String className, String methodName, String jsonReceived, String jsonSend,String message,String objectId,String httpMethod){
		insertCallinRecord(className,methodName,jsonReceived,jsonSend,'Warning',message,objectId,httpMethod);
	}
	public static void insertCallinRecordSucess(String className, String methodName, String jsonReceived, String jsonSend,String message,String objectId,String httpMethod){
		insertCallinRecord(className,methodName,jsonReceived,jsonSend,'Success',message,objectId,httpMethod);
	}	

	public static void insertCallinRecord(String className, String methodName, String jsonReceived, String jsonSend,String typeRecord,String message,String objectId,String httpMethod){
			Callout_Record__c calloutRecord = new Callout_Record__c();

			calloutRecord.User_Id__c = UserInfo.getUserId();
			calloutRecord.User_Name__c = UserInfo.getName();
			calloutRecord.Callout_Date__c = String.valueOfGmt(Datetime.now());
			calloutRecord.Class_Name__c = className;
			calloutRecord.Method_Name__c = methodName;
			calloutRecord.HTTP_Method__c = httpMethod;
			calloutRecord.JSON_Sent__c = jsonSend;
			calloutRecord.JSON_Received__c = jsonReceived;
			calloutRecord.Type_Record__c = typeRecord;
			calloutRecord.Message__c = message;
			calloutRecord.Object__c = objectId;
			calloutRecord.Type__c = 'Call In';	
		insert calloutRecord;
	}
}