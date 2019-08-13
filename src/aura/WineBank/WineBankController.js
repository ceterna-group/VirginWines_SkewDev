({
    doInit : function(component, event, helper) {
        // this function call on the component load first time     
        // get the page Number if it's not define, take 1 as default
        //var page = component.get("v.page") || 1;
        //var beginRecords = 0;
        // get the select option (drop-down) values.   
        //var recordToDisply = component.find("recordSize").get("v.value");
        // call the helper function   
        helper.buildJson(component);
    },     
})