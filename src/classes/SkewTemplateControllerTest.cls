/*
*  @class - SkewTemplateControllerTest()
*  @desc - Used to test the methods in the SkewTemplateController
*/
@IsTest
public with sharing class SkewTemplateControllerTest {

/*
*  @method - doTestSetup()
*  @desc - Used to insert a skew template and and a skew line item for that template
*/
    @TestSetup
    private static void doTestSetup() {
        //new template
        Skew_Template__c skewTemplate = new Skew_Template__c();
        skewTemplate.Name = 'Test Template';
        insert skewTemplate;

        //new line item
        Skew_Template_Line_Item__c skewLineItem = new Skew_Template_Line_Item__c();
        skewLineItem.Skew_Template__c = skewTemplate.Id;
        skewLineItem.Week_Number__c = 1;
        skewLineItem.Predicted__c = 0;

        insert skewLineItem;
    }
/*
*  @method - testGetLineItems()
*  @desc - Used to test the method the getLineItems() method in the skewTemplateController.
*  @desc - this class tests if there's an existing line item
*/
    @IsTest
    public static void testGetLineItems(){

        Id templateId = [SELECT Id FROM Skew_Template__c WHERE Name = 'Test Template' LIMIT 1].Id;

        List<Skew_Template_Line_Item__c> returnLineItems = SkewTemplateController.getLineItems(templateId);

        //expects 1 against the size of the template
        System.assertEquals(1, [SELECT Id FROM Skew_Template_Line_Item__c WHERE Skew_Template__r.Name = 'Test Template'].size());

    }
/*
*  @method - testInsertNewLineItem()
*  @desc - Used to test the method the insertNewLineItem() method in the skewTemplateController.
*  @desc - this class inserts a new lineItem and tests if there's more than 1
*/
    @IsTest
    public static void testInsertNewLineItem(){

        Skew_Template_Line_Item__c lineItem = new Skew_Template_Line_Item__c(
                Week_Number__c = 2,
                Predicted__c = 50,
                Skew_Template__c = [SELECT Id FROM Skew_Template__c WHERE Name = 'Test Template' LIMIT 1].Id
        );

        Skew_Template_Line_Item__c returnLineItem = SkewTemplateController.insertNewLineItem(lineItem);

        //to the if the lineitem Id has a value that is not equal to null
        System.assertNotEquals(null, returnLineItem.Id);
        //expects 2 as we insert a new line item. This is compared against the size of the skew template
        System.assertEquals(2, [SELECT Id FROM Skew_Template_Line_Item__c WHERE Skew_Template__r.Name = 'Test Template'].size());

    }
/*
*  @method - testDeleteLineItem()
*  @desc - Used to test the method the deleteLineItem() method in the skewTemplateController.
*  @desc - this class inserts a new lineItem and then deletes it. Tests if there's only 1 line item left
*/
    @IsTest
    public static void testDeleteLineItem(){

        Skew_Template_Line_Item__c lineItem = new Skew_Template_Line_Item__c(
                Week_Number__c   = 2,
                Predicted__c     = 50,
                Skew_Template__c = [SELECT Id FROM Skew_Template__c WHERE Name = 'Test Template' LIMIT 1].Id
        );

        insert lineItem;

        List<Skew_Template_Line_Item__c> lineItems = new List<Skew_Template_Line_Item__c>{lineItem};

        SkewTemplateController.deleteLineItem([SELECT Id, Week_Number__c, Predicted__c, Skew_Template__c
                                               FROM Skew_Template_Line_Item__c WHERE Week_Number__c = 1 ], lineItems);

        //expects 1. After we insert the lineitem we then call the deleteLineItem method which deletes the line item based on the week number
        System.assertEquals(1, [SELECT Id FROM Skew_Template_Line_Item__c WHERE Skew_Template__r.Name = 'Test Template'].size());

    }
/*
*  @method - testUpdateLinePercent()
*  @desc - Used to test the method the updateLinePercent() method in the skewTemplateController.
*  @desc - this class inserts a new lineItem and updates the percent from 50 to 64. Tests if there's the percentage is now 64 on the line item.
*/
    @IsTest
    public static void testUpdateLinePercent(){

        Skew_Template_Line_Item__c lineItem = new Skew_Template_Line_Item__c(
                Week_Number__c   = 2,
                Predicted__c     = 50,
                Skew_Template__c = [SELECT Id FROM Skew_Template__c WHERE Name = 'Test Template' LIMIT 1].Id
        );

        insert lineItem;

        //updated to 64 from 50
        Decimal percent = lineItem.Predicted__c = 64;
        SkewTemplateController.updateLinePercent(lineItem.Id, (Integer) percent);
        //compares 64 against the the line item with the corresponding id
        System.assertEquals(64, [SELECT Predicted__c FROM Skew_Template_Line_Item__c WHERE Id = : lineItem.Id].Predicted__c);
    }

    @IsTest
    public static void testUpdateTemplateName(){

        Skew_Template__c skewTemplate = new Skew_Template__c(
                Name = 'Test Template'
        );

        insert skewTemplate;

        skewTemplate.Name = 'test';

        update skewTemplate;

        SkewTemplateController.updateTemplateName(skewTemplate.Id, skewTemplate.Name);
        System.assertEquals('test', [SELECT Name FROM Skew_Template__c WHERE Name = 'test'].Name);
    }

    @IsTest
    public static void testDeleteSkewTemplate(){

        Skew_Template__c skewTemplate = new Skew_Template__c(
                Name = 'Test Template'
        );

        insert skewTemplate;
        SkewTemplateController.deleteSkewTemplate(skewTemplate);
        System.assertEquals(1, [SELECT Name FROM Skew_Template__c WHERE Name = 'Test Template'].size());
    }

    @IsTest
    public static void testInsertCloneSkewTemplate(){

        Skew_Template__c skewTemplate = new Skew_Template__c(
                Name = 'Clone Template'
        );

        insert skewTemplate;

        //new line item
        Skew_Template_Line_Item__c skewLineItem = new Skew_Template_Line_Item__c();
        skewLineItem.Skew_Template__c = skewTemplate.Id;
        skewLineItem.Week_Number__c = 1;
        skewLineItem.Predicted__c = 35;

        insert skewLineItem;

        SkewTemplateController.insertSkewTemplate(skewTemplate.Id);


        System.assertEquals('Copy of Clone Template', [SELECT Name FROM Skew_Template__c WHERE Name = 'Copy of Clone Template'].Name);
    }
}