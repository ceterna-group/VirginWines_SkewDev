@isTest
private class CalloutRecordDeleteJobTest {
	static testmethod void testCalloutDeleteBatch(){

	Callout_Record_Days__c crd = new Callout_Record_Days__c();
	crd.Name = 'Default';
	crd.Days__c = 1;

	insert crd;

	Test.startTest();
	Callout_Record__c calloutRecord = new Callout_Record__c();

	calloutRecord.User_Id__c = UserInfo.getUserId();
	calloutRecord.User_Name__c = UserInfo.getName();
	calloutRecord.Callout_Date__c = String.valueOfGmt(Datetime.now());
	calloutRecord.Class_Name__c = 'className';
	calloutRecord.Method_Name__c = 'methodName';
	calloutRecord.Type_Record__c = 'Warning';
	calloutRecord.Message__c = 'message';
	calloutRecord.Object__c = 'objectId';

	insert calloutRecord;

	String CRON_EXP = '0 0 0 1 1 ? '+String.valueOf(Date.today().year() + 1);
	String jobId = System.schedule('CalloutRecordDeleteJobTest', CRON_EXP, new CalloutRecordDeleteJob());
	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];


	Test.stopTest();
	}
}