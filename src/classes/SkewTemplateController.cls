/**
 * Created by ronanwilliams on 2019-08-16.
 */

public class SkewTemplateController {


    @AuraEnabled
    public static List<Object> getLineItems(String recordId){

        return [SELECT Id, Week_Number__c, Predicted__c
                FROM Skew_Template_Line_Item__c
                WHERE Skew_Template__c = :recordId
                ORDER BY Week_Number__c ASC];

    }

    @AuraEnabled
    public static Skew_Template_Line_Item__c insertNewLineItem(Skew_Template_Line_Item__c lineItem){

        insert lineItem;
        return lineItem;
    }


    @AuraEnabled
    public static Boolean deleteLineItem(Skew_Template_Line_Item__c lineItem, List<Skew_Template_Line_Item__c> lineItems){

        delete lineItem;
        update lineItems;
        return true;
    }

    @AuraEnabled
    public static Boolean updateLinePercent(String Id, Integer percent){
        update new Skew_Template_Line_Item__c( Id = Id, Predicted__c = percent);
        return true;
    }

}