({
	buildJson : function(component) {
        var action = component.get('c.getWinebank');
        action.setParams({
                    winebank : component.get("v.recordId")
                }); 
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("yes");
                var ret = response.getReturnValue();
                console.log("ret=>");
                console.log("ret=> " + ret);
                
                if(ret) {
                    console.log(ret);
                    var jsonResult=JSON.parse(ret);
                
                console.log("json=>");
                console.log(jsonResult);
                console.log(jsonResult[0].agent);

                component.set("v.jsonArray", jsonResult);
                console.log(jsonResult);
                jsonResult.map(item => {
                    if(!item.money_in) {
                    	return item.money_in = 0;
                	}
                    if(!item.money_out) {
                    	return item.money_out = 0;
                	}                               
                });
            	var count = Object.keys(jsonResult).length;
                }
                
                //component.set("v.numberRecords", recordToDisply);
                //component.set("v.beginRecords", beginRec);
                //component.set("v.page", 1);
                //component.set("v.total",count);
                //component.set("v.pages", Math.ceil(count / recordToDisply));                
            }else  {
                console.log('helper.initialize.setCallback.NOTSUCCESS');
            }
        });
        
        $A.enqueueAction(action);
       
	}
})