/*
 * @class TemplateTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler
 *   class. You must keep the extends attribute for this class to work.
 */
public with sharing class SkewTriggerHandler extends TriggerHandler {

    public override void afterInsert() {
        afterInsert((List<Skew__c>)Trigger.new);
    }

    public override void afterUpdate() {

        Map<Id,Skew__c> triggerOldMap   = (Map<Id,Skew__c>)Trigger.oldMap;
        Map<Id,Skew__c> updatedSkewMap  = new Map<Id,Skew__c>();

        for (Skew__c skew : (List<Skew__c>)Trigger.new){
            if (skew.Skew_Template__c != null && skew.Skew_Template__c != triggerOldMap.get(skew.Id).Skew_Template__c){
                updatedSkewMap.put(skew.Id,skew);
            }
        }

        afterUpdate(updatedSkewMap);
    }


    /*
     * @method exampleBeforeInsert
     * @desc Example method defined within the class to be used in the various
     *   contexts provided by the TriggerHandler class.
     *
     * @return {null}
     */
    public void afterInsert(List<Skew__c> newSkews) {

        Map<Id,Skew_Template__c> templateMap = new Map<Id,Skew_Template__c>();

        for (Skew__c skew : newSkews){
            if (skew.Skew_Template__c != null){
                templateMap.put(skew.Skew_Template__c, null);
            }
        }

        for (Skew_Template__c template : [SELECT Id, Name,
                                                (SELECT Id, Week_Number__c, Predicted__c
                                                FROM Skew_Template_Line_Items__r
                                                ORDER BY Week_Number__c ASC)
                                            FROM Skew_Template__c
                                            WHERE Id IN :templateMap.keySet()]){
            templateMap.put(template.Id,template);
        }

        List<Skew_Line_Item__c> skewLineItems = new List<Skew_Line_Item__c>();

        for (Skew__c skew : newSkews){
            if (skew.Skew_Template__c != null){
                for (Skew_Template_Line_Item__c templateLineItem :
                        templateMap.get(skew.Skew_Template__c).Skew_Template_Line_Items__r){
                    skewLineItems.add(
                            new Skew_Line_Item__c(
                                Skew__c             = skew.Id,
                                Week_Number__c      = templateLineItem.Week_Number__c,
                                Week_Start_Date__c  = skew.Skew_Start_Date__c.addDays(Integer.valueOf((templateLineItem.Week_Number__c - 1) * 7)),
                                Predicted__c        = templateLineItem.Predicted__c
                            )
                    );
                }
            }
        }

        insert skewLineItems;
    }


    /*
      * @method exampleBeforeInsert
      * @desc Example method defined within the class to be used in the various
      *   contexts provided by the TriggerHandler class.
      *
      * @return {null}
      */
    public void afterUpdate(Map<Id,Skew__c> updatedSkewMap) {

        Map<Id,Skew_Template__c> templateMap = new Map<Id,Skew_Template__c>();

        for (Skew__c skew : updatedSkewMap.values()){
            templateMap.put(skew.Skew_Template__c, null);
        }

        // skew lines to delete
        delete [SELECT Id FROM Skew_Line_Item__c WHERE Skew__c IN :updatedSkewMap.keySet()];

        for (Skew_Template__c template : [SELECT Id, Name,
                                            (SELECT Id, Week_Number__c, Predicted__c
                                            FROM Skew_Template_Line_Items__r
                                            ORDER BY Week_Number__c ASC)
                                            FROM Skew_Template__c
                                            WHERE Id IN :templateMap.keySet()]){
            templateMap.put(template.Id,template);
        }

        Map<String,Skew_Line_Item__c> skewLineItems = new Map<String,Skew_Line_Item__c>();

        for (Skew__c skew : updatedSkewMap.values()){
            if (skew.Skew_Template__c != null){
                List<Skew_Template_Line_Item__c> lineItems = templateMap.get(skew.Skew_Template__c).Skew_Template_Line_Items__r;
                for (Integer x = 0; x < lineItems.size(); x++){
                    String identifier = skew.Skew_Template__c + String.valueOf(x);
                    skewLineItems.put(identifier,
                            new Skew_Line_Item__c(
                                    Skew__c             = skew.Id,
                                    Week_Number__c      = lineItems[x].Week_Number__c,
                                    Week_Start_Date__c  = skew.Skew_Start_Date__c.addDays(Integer.valueOf((lineItems[x].Week_Number__c - 1) * 7)),
                                    Predicted__c        = lineItems[x].Predicted__c
                            )
                    );
                }
            }
        }

        insert skewLineItems.values();


        // get all opps referenced by current skews
        List<Opportunity> skewOpportunities = [SELECT Id, CloseDate, Skew__c, Skew__r.Skew_Start_Date__c
                                                FROM Opportunity
                                                WHERE Skew__c IN :updatedSkewMap.keySet()];

        for (Opportunity opp : skewOpportunities){

            String weekId = String.valueOf(opp.Skew__r.Skew_Start_Date__c.daysBetween(opp.CloseDate) / 7);

            if (skewLineItems.containsKey(opp.Skew__c + weekId)){
                opp.Skew_Line_Item__c = skewLineItems.get(opp.Skew__c + weekId).Id;
            } else {
                opp.Skew__c = null;
            }
        }

        update skewOpportunities;
    }


}