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
                var totalActual = 0;
                lines.forEach(function(line){
                    totalPercent    += line.Predicted__c;
                    totalActual     += line.Actual_Value__c;
                    line.Revert     = line.Predicted__c;
                    line.Class      = '';
                    line.ValueClass = '';
                });

                $C.set('v.totalPercent',totalPercent);
                $C.set('v.totalActual',totalActual);
            }
        });
        $A.enqueueAction(lineItemGet);
    },
    addRow : function($C,$E,$H){

        var lines = $C.get('v.lines');
        var newLine = {
            Week_Number__c : lines.length + 1,
            Predicted__c : 0,
            Actual_Value__c : 0,
            Skew__c : $C.get('v.recordId')
        };

        lines.push(newLine);
        $C.set('v.lines',lines);

        var insertLine = $C.get('c.insertNewLineItem');
        insertLine.setParams({
            recordId : $C.get('v.recordId'),
            lineItem : newLine
        });
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
        var totalActual = 0;

        for (var x = 0; x < lines.length; x++){
            if (lines[x].Week_Number__c !== x + 1){
                lines[x].Week_Number__c = x +1;
            }
            totalPercent += parseInt(lines[x].Predicted__c);
            totalActual += parseInt(lines[x].Actual_Value__c);
        }
        $C.set('v.lines',lines);
        $C.set('v.totalPercent',totalPercent);
        $C.set('v.totalActual',totalActual);

        var deleteLineAction = $C.get('c.deleteLineItem');
        deleteLineAction.setParams({ lineItem : deleteLine, lineItems : lines, deleteIndex : deleteIndex });
        deleteLineAction.setCallback(this, function (response) {
            $C.set('v.responsePending',false);

            console.log(response.getReturnValue());
            if (response.getState() === 'SUCCESS'){
                $C.set('v.lines',response.getReturnValue());
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

    }
});