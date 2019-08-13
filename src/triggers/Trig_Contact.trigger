trigger Trig_Contact on Contact (after insert, after update) {
    et4ae5.triggerUtility.automate('Contact'); 
}