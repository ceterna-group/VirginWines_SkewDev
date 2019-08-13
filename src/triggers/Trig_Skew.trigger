/*
 * @class TemplateTrigger
 * @desc This would be your Trigger, build on a specific object. Ideally you would
 *    have one Trigger, one TriggerHandler extension, and then whatever logic you need.
 */
trigger Trig_Skew on Skew__c (before insert, before update, after insert, after update) {

    // create a handler using a class that extends TriggerHandler
    SkewTriggerHandler handler = new SkewTriggerHandler();

    // call the handler methods you want from each trigger path
    // if you don't need a path, you can remove it below

    // before insert
    if (Trigger.isInsert && Trigger.isBefore) {
    }

    // after insert
    if (Trigger.isInsert && Trigger.isAfter) {
        handler.afterInsert();
    }

    // before update
    if (Trigger.isUpdate && Trigger.isBefore) {
    }

    // after update
    if (Trigger.isUpdate && Trigger.isAfter) {
        handler.afterUpdate();
    }

}