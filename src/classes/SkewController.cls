/*
*  @class - SkewController()
*  @desc - Used to retrieve line items from the skew
*/
public class SkewController {

    /*
    *  @method - getLineItems()
    *  @desc - Used to retrieve the current line items from the skew template based on the record Id
    *  @param - String recordId - the recordId from the skew template
    *  @return - returns a db query to get Id, weekNumber, percentage from skew template based on the recordId
    */
    @AuraEnabled
    public static List<Skew_Line_Item__c> getLineItems(String recordId){

        return [SELECT Id, Week_Number__c, Predicted__c, Actual_Value__c, Week_Start_Date__c
                FROM Skew_Line_Item__c
                WHERE Skew__c = :recordId
                ORDER BY Week_Number__c ASC];
    }

    /*
    *  @method - insertNewLineItem()
    *  @desc - Used to insert a line item
    *  @param - Skew_Template_Line_Item__c lineItem - referenced the Line Item Object
    *  @return - returns the new line item
    */
    @AuraEnabled
    public static Skew_Line_Item__c insertNewLineItem(String recordId, Skew_Line_Item__c lineItem){

        Date startDate = [SELECT Skew_Start_Date__c FROM Skew__c WHERE Id = :recordId].Skew_Start_Date__c;
        lineItem.Week_Start_Date__c = startDate.addDays(Integer.valueOf((lineItem.Week_Number__c - 1) * 7));

        insert lineItem;
        return [SELECT Id, Week_Number__c, Predicted__c, Actual_Value__c, Week_Start_Date__c
                FROM Skew_Line_Item__c
                WHERE Id = :lineItem.Id];
    }

    /*
    *  @method - deleteLineItem()
    *  @desc - Used to delete a line item
    *  @param - Skew_Template_Line_Item__c lineItem
    *  @param - List<Skew_Template_Line_Item__c> lineItems - referenced the Line Item Object and a list of the rest line items
    *  @return - returns true when the new list of line items deletes and updates the line item
    */
    @AuraEnabled
    public static List<Skew_Line_Item__c> deleteLineItem(Skew_Line_Item__c lineItem, List<Skew_Line_Item__c> lineItems, Integer deleteIndex){

        delete lineItem;

        for (Skew_Line_Item__c line : lineItems){
            if (line.Week_Number__c >= deleteIndex){
                line.Week_Start_Date__c = line.Week_Start_Date__c.addDays(-7);
            }
        }

        update lineItems;
        return lineItems;
    }

    /*
    *  @method - updateLinePercent()
    *  @desc - Used to update the percentage on the line item
    *  @param - String Id, Integer percent - used to get the id of the particular line item and update the percent
    *  @return - returns true and updates the existing line items percentage
    */
    @AuraEnabled
    public static Boolean updateLinePercent(String Id, Integer percent){
        update new Skew_Line_Item__c(Id = Id, Predicted__c = percent);
        return true;
    }

}