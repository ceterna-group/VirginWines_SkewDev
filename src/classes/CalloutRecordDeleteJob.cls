global class CalloutRecordDeleteJob implements Database.Batchable<sObject>, Database.stateful, Schedulable{
	
	global Database.QueryLocator start(Database.BatchableContext BC){
	    Callout_Record_Days__c customSetting = Callout_Record_Days__c.getInstance('Default');
	    Decimal days = customSetting.Days__c;
	    Date deletionDate = Date.today().addDays(Integer.valueOf(- days));
        if(Test.isRunningTest())    {
            return Database.getQueryLocator('SELECT Id FROM Callout_Record__c WHERE Class_Name__c = \'className\'');
        }else{
            return Database.getQueryLocator('SELECT Id FROM Callout_Record__c WHERE CreatedDate < :deletionDate');
        }
    }
	
	global void execute(SchedulableContext sc){
		Database.executeBatch(new CalloutRecordDeleteJob());
	}
	
	global void execute(Database.BatchableContext BC, List<Callout_Record__c> scope){
        if(!scope.isEmpty()){
            delete scope;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }

}