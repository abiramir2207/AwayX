<!---
Name: 			actionScriptFunctions.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Description:	File that holds all the action script functions
Parameters:		gridName - Name of the grid you want to perform functions on
Usage:			N/A
--->

<!----set default params--->
<cfparam name="variables.gridName" default="" />

<cfoutput>
<cfsavecontent variable="actionInsert">
	GridData.insertRow(#trim(variables.gridName)#);
	_global.backupDP.push(#trim(variables.gridName)#.getItemAt(applicationSettings.length -1));	
</cfsavecontent>
<cfsavecontent variable="actionDelete">
	var item = #trim(variables.gridName)#.selectedItem;
	if(_global.backupDP != undefined)
	{
		for(var i = 0; i < _global.backupDP.length; i++)
		{
			if(_global.backupDP[i] == item)
			{
				_global.backupDP.removeItemAt(i);
			}
		}
	}
	GridData.deleteRow(#trim(variables.gridName)#);
</cfsavecontent>
<cfsavecontent variable="actionFilter">
if(_global.backupDP == undefined)
	{
		 _global.backupDP = #trim(variables.gridName)#.dataProvider.slice(0);
	}
	var backupDP = _global.backupDP;
	var fortext = forInput.text.toLowerCase();
	var selected = column.selectedItem.data;
	#trim(variables.gridName)#.dataProvider.removeAll();
	
	for(var i =0; i <  backupDP.length;i++)
	{
		var item = backupDP[i];
		if(item[selected].toString().substr(0,fortext.length).toLowerCase() == fortext)
		{
			#trim(variables.gridName)#.dataProvider.addItem(item);
		}
	}
</cfsavecontent>

<cfsavecontent variable="actionRemove">
	var applicationSettings = #trim(variables.gridName)#;
	var confirm = function (evt)
	{
        if (evt.detail == mx.controls.Alert.OK)
        {
             for(var i:Number = applicationSettings.length-1; i >= 0; i--)
			{
				var item:Object = applicationSettings.dataProvider[i];
				
				if(item.checked.toString() == "true")
				{
					applicationSettings.selectedIndex = i;
					GridData.deleteRow(applicationSettings);
				}
			}
        }
	}
	alert("Are you sure you want to remove the checked records?", "Warning", 
	mx.controls.Alert.OK | mx.controls.Alert.CANCEL,  confirm);
</cfsavecontent>
<cfsavecontent variable="selectToggle">
	if(selectBtn.label == "Check all")
	{
		for(var i:Number = 0; i < #trim(variables.gridName)#.length; i++)
		{
			#trim(variables.gridName)#.editField(i, "checked", "true");
		}
		selectBtn.label = "Uncheck all";
	}
	else if(selectBtn.label == "Uncheck all")
	{
		for(var i:Number = 0; i < #trim(variables.gridName)#.length; i++)
		{
			applicationSettings.editField(i, "checked", "false");
		}
		selectBtn.label = "Check all";
	}
</cfsavecontent>
</cfoutput>