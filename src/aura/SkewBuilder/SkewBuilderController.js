/**
 * Created by ronanwilliams on 2019-08-16.
 */

({

    doInit : function($C,$E,$H){

        var lineItemGet = $C.get('c.getLineItems');
        lineItemGet.setParams({ recordId : $C.get('v.recordId')});
        lineItemGet.setCallback(this, function (response) {

            console.log(response.getReturnValue());

            if (response.getState() === 'SUCCESS'){
                var lines = response.getReturnValue();

                $C.set('v.lines',lines);

                var totalPercent = 0;
                lines.forEach(function(line){
                    totalPercent += line.Predicted__c;
                    line.Revert = line.Predicted__c;
                    line.Class = '';
                    line.ValueClass = '';
                });

                $C.set('v.totalPercent',totalPercent);
            }
        });
        $A.enqueueAction(lineItemGet);
    },
    addRow : function($C,$E,$H){

        var lines = $C.get('v.lines');
        var newLine = {
            Week_Number__c : lines.length + 1,
            Predicted__c : 0,
            Skew_Template__c : $C.get('v.recordId')
        };

        lines.push(newLine);
        $C.set('v.lines',lines);

        var insertLine = $C.get('c.insertNewLineItem');
        insertLine.setParams({ lineItem : newLine});
        insertLine.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS'){
                var line = response.getReturnValue();
                line.Class = 'success';
                lines[lines.length -1] = line;
                $C.set('v.lines',lines);

                window.setTimeout(
                    $A.getCallback(function() {
                        line.Class = '';
                        lines[lines.length -1] = line;
                        $C.set('v.lines',lines);
                    }), 800
                );
            }
        });
        $A.enqueueAction(insertLine);
    },
    deleteRow : function($C,$E,$H){

        var deleteIndex = $E.currentTarget.dataset.index;
        var lines       = $C.get('v.lines');
        var deleteLine  = lines[deleteIndex];

        lines.splice(deleteIndex,1);

        var totalPercent = 0;

        for (var x = 0; x < lines.length; x++){
            lines[x].Week_Number__c = x +1;
            totalPercent += parseInt(lines[x].Predicted__c);
        }
        $C.set('v.lines',lines);
        $C.set('v.totalPercent',totalPercent);

        var deleteLineAction = $C.get('c.deleteLineItem');
        deleteLineAction.setParams({ lineItem : deleteLine, lineItems : lines });
        deleteLineAction.setCallback(this, function (response) {
            $C.set('v.responsePending',false);

            console.log(response.getReturnValue());
            if (response.getState() === 'SUCCESS'){
                // $C.set('v.lines',lines);
            }
        });
        $A.enqueueAction(deleteLineAction);

    },
    updatePercent : function($C,$E,$H){

        var percent         = $E.getSource().get('v.value');
        var lineId          = $E.getSource().get('v.name');
        var lines           = $C.get('v.lines');
        var totalPercent    = 0;

        lines.forEach(function(line){
            if (!isNaN(parseInt(line.Predicted__c))){
                totalPercent += parseInt(line.Predicted__c);
            }
        });

        $C.set('v.totalPercent',totalPercent);

        if (!percent || totalPercent > 100 || isNaN(percent)){
            $C.set('v.invalidId',lineId);
            $C.set('v.responsePending',true);
        } else {
            $C.set('v.invalidId','none');
            $C.set('v.responsePending',false);

            var updateLinePercent = $C.get('c.updateLinePercent');
            updateLinePercent.setParams({ Id : lineId, percent : percent });
            updateLinePercent.setCallback(this, function (response) {

                console.log(response.getReturnValue());
                if (response.getState() === 'SUCCESS'){
                    lines.forEach(function(line){
                        if (lineId === line.Id){
                            line.Revert     = line.Predicted__c;
                            line.ValueClass = 'successInput';
                        }
                    });
                    $C.set('v.lines',lines);
                    window.setTimeout(
                        $A.getCallback(function() {
                            lines.forEach(function(line){
                                if (lineId === line.Id){
                                    line.ValueClass = '';
                                }
                            });
                            $C.set('v.lines',lines);
                        }), 800
                    );
                }
            });
            $A.enqueueAction(updateLinePercent);
        }
    },
    undoChange : function ($C,$E,$H) {

        var revertId        = $E.currentTarget.dataset.id;
        var lines           = $C.get('v.lines');
        var totalPercent    = 0;

        lines.forEach(function(line){
            if (line.Id === revertId){
                line.Predicted__c = line.Revert;
                $C.set('v.invalidId','none');
                $C.set('v.responsePending',false);

            }
            totalPercent += parseInt(line.Predicted__c);
        });

        $C.set('v.lines',lines);
        $C.set('v.totalPercent',totalPercent);

    },
    updateName: function($C,$E,$H){

        var template = $C.get('v.skewTemplate');

        if (template.Name){
            var updateTemplateName1 = $C.get('c.updateTemplateName');
            updateTemplateName1.setParams({ Id : $C.get("v.recordId"), tempName : template.Name});
            updateTemplateName1.setCallback(this, function (response) {
                console.log(response.getState());

                if (response.getState() === 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();
                    $C.set('v.nameClass','successInput');

                    window.setTimeout(
                        $A.getCallback(function() {
                            $C.set('v.nameClass','');
                        }), 800
                    );
                }
            });
            $A.enqueueAction(updateTemplateName1);

        }

    },
    deleteSkewTemp: function($C,$E,$H){

        var skewTemp    = $C.get('v.skewTemplate');
        var deleteSkew  = $C.get('c.deleteSkewTemplate');

        deleteSkew.setParams({ skewTemplate : skewTemp});

        deleteSkew.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": '00B4E000002a7KuUAI',
                    "scope": "Skew_Template__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(deleteSkew);
    },
    insertSkewTemp: function($C,$E,$H){

        var skewTemp = $C.get('v.recordId');
        var insertSkew = $C.get('c.insertSkewTemplate');
        insertSkew.setParams({ recordId : skewTemp });

        insertSkew.setCallback(this, function (response) {

            if (response.getState() === 'SUCCESS') {
                var newSkew = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId" : newSkew});
                navEvt.fire();
            }
        });
        $A.enqueueAction(insertSkew);
    }
});