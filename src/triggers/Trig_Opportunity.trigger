/**
 * Created by ronanwilliams on 2019-07-23.
 */

trigger Trig_Opportunity on Opportunity (before insert, before update, after insert, after update) {

    // create a handler using a class that extends TriggerHandler
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();

    // call the handler methods you want from each trigger path
    // if you don't need a path, you can remove it below

    // before insert
    if (Trigger.isInsert && Trigger.isBefore) {
        handler.beforeInsert();
    }

    // after insert
    if (Trigger.isInsert && Trigger.isAfter) {
    }

    // before update
    if (Trigger.isUpdate && Trigger.isBefore) {
        handler.beforeUpdate();
    }

    // after update
    if (Trigger.isUpdate && Trigger.isAfter) {
    }

}