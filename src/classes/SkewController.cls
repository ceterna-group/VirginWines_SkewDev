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
    public static Skew_Template_Line_Item__c insertNewLineItem(Skew_Template_Line_Item__c lineItem){

        insert lineItem;
        return lineItem;
    }

    /*
    *  @method - deleteLineItem()
    *  @desc - Used to delete a line item
    *  @param - Skew_Template_Line_Item__c lineItem
    *  @param - List<Skew_Template_Line_Item__c> lineItems - referenced the Line Item Object and a list of the rest line items
    *  @return - returns true when the new list of line items deletes and updates the line item
    */
    @AuraEnabled
    public static Boolean deleteLineItem(Skew_Template_Line_Item__c lineItem, List<Skew_Template_Line_Item__c> lineItems){

        delete lineItem;
        update lineItems;
        return true;
    }

    /*
    *  @method - updateLinePercent()
    *  @desc - Used to update the percentage on the line item
    *  @param - String Id, Integer percent - used to get the id of the particular line item and update the percent
    *  @return - returns true and updates the existing line items percentage
    */
    @AuraEnabled
    public static Boolean updateLinePercent(String Id, Integer percent){
        update new Skew_Template_Line_Item__c(Id = Id, Predicted__c = percent);
        return true;
    }

    /*
    *  @method - updateTemplateName()
    *  @desc - Used to update the template name if of the Skew
    *  @param - String Id, String tempName - used to get the id Skew Template and to get the exact name of the current skew template
    *  @return - returns true and updates the existing templates name
    */
    @AuraEnabled
    public static Boolean updateTemplateName(String Id, String tempName){
        update new Skew_Template__c(Id = Id, Name = tempName);
        return true;
    }

    /*
    *  @method - deleteSkewTemplate()
    *  @desc - Used to delete an existing skew template when 'delete' is clicked
    *  @param - Skew_Template_c skewTemplate - to get the existing template that you're on
    *  @return - returns true, deletes the skew template and updates the list of existing templates
    */
    @AuraEnabled
    public static Boolean deleteSkewTemplate(Skew_Template__c skewTemplate){
        delete skewTemplate;
        return true;
    }

    /*
    *  @method - insertSkewTemplate()
    *  @desc - Used to insert and clone an existing skew template as a new one
    *  @param - String recordId - used to get the id of an existing skew template,
    *           which is used to get the existing line items and clone them to a new one
    *  @return - returns the Id of newly cloned skew template
    */
    @AuraEnabled
    public static Id insertSkewTemplate(String recordId){
        Skew_Template__c sourceTemplate = [SELECT Id, Name,
        (SELECT Id, Week_Number__c, Predicted__c
        FROM Skew_Template_Line_Items__r
        ORDER BY Week_Number__c ASC)
        FROM Skew_Template__c
        WHERE Id = : recordId];

        Skew_Template__c cloneSkewTemplate = new Skew_Template__c();
        cloneSkewTemplate.Name = 'Copy of ' + sourceTemplate.Name;
        insert cloneSkewTemplate;

        List<Skew_Template_Line_Item__c> cloneLines = new List<Skew_Template_Line_Item__c>();

        for (Skew_Template_Line_Item__c sourceLine : sourceTemplate.Skew_Template_Line_Items__r){
            cloneLines.add(
                    new Skew_Template_Line_Item__c(
                            Week_Number__c      = sourceLine.Week_Number__c,
                            Predicted__c        = sourceLine.Predicted__c,
                            Skew_Template__c    = cloneSkewTemplate.Id
                    )
            );
        }

        insert cloneLines;
        return cloneSkewTemplate.Id;
    }
}