/**
 * Created by ronanwilliams on 2019-07-23.
 */

public class OpportunityTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        beforeInsert((List<Opportunity>)Trigger.new);
    }

    public override void beforeUpdate() {
        beforeUpdate((Map<Id,Opportunity>)Trigger.newMap, (Map<Id,Opportunity>)Trigger.oldMap);
    }

    /*
     * @method exampleBeforeInsert
     * @desc Example method defined within the class to be used in the various
     *   contexts provided by the TriggerHandler class.
     *
     * @return {null}
     */
    public void beforeInsert(List<Opportunity> newOpportunities) {

        Map<Id,List<Id>> skewIdMap = new Map<Id,List<Id>>();

        for (Opportunity opp : newOpportunities){
            if (opp.Skew__c != null){
                skewIdMap.put(opp.Skew__c, new List<Id>());
            }
        }

        for (Skew_Line_Item__c lineItem : [SELECT Skew__c, Id, Week_Number__c
                                            FROM Skew_Line_Item__c
                                            WHERE Skew__c IN :skewIdMap.keySet()
                                            ORDER BY Week_Number__c ASC]) {
            skewIdMap.get(lineItem.Skew__c).add(lineItem.Id);
        }

        for (Opportunity opp : newOpportunities) {
            if (opp.Skew__c != null && opp.SkewNumber__c >= 0 && opp.SkewNumber__c <= skewIdMap.get(opp.Skew__c).size()) {
                opp.Skew_Line_Item__c = skewIdMap.get(opp.Skew__c)[Integer.valueOf(opp.SkewNumber__c)];
            } else {
                opp.Skew_Line_Item__c = null;
            }
        }
    }

    /*
      * @method exampleBeforeInsert
      * @desc Example method defined within the class to be used in the various
      *   contexts provided by the TriggerHandler class.
      *
      * @return {null}
      */
    public void beforeUpdate(Map<Id,Opportunity> updatedOpportunityMap, Map<Id,Opportunity> oldOpportunityMap) {

        Map<Id,List<Id>> skewIdMap = new Map<Id,List<Id>>();

        for (Opportunity opp : updatedOpportunityMap.values()){
            if (opp.Skew__c != null && (
                    opp.CloseDate != oldOpportunityMap.get(opp.Id).CloseDate ||
                    opp.Skew__c != oldOpportunityMap.get(opp.Id).Skew__c)){
                skewIdMap.put(opp.Skew__c, new List<Id>());
            }
        }

        for (Skew_Line_Item__c lineItem : [SELECT Skew__c, Id, Week_Number__c
                                            FROM Skew_Line_Item__c
                                            WHERE Skew__c IN :skewIdMap.keySet()
                                            ORDER BY Week_Number__c ASC]) {
            skewIdMap.get(lineItem.Skew__c).add(lineItem.Id);
        }

        for (Opportunity opp : updatedOpportunityMap.values()) {
            if (opp.Skew__c != null &&
                    (opp.CloseDate != oldOpportunityMap.get(opp.Id).CloseDate ||
                            opp.Skew__c != oldOpportunityMap.get(opp.Id).Skew__c)){
                if (opp.SkewNumber__c <= skewIdMap.get(opp.Skew__c).size() && opp.SkewNumber__c >= 0){
                    opp.Skew_Line_Item__c = skewIdMap.get(opp.Skew__c)[Integer.valueOf(opp.SkewNumber__c)];
                } else {
                    opp.Skew_Line_Item__c = null;
                }
            }
        }
    }

}