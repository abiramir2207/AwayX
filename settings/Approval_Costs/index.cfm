<!------ Cost_Sequence.cfm ----->

<!------ Set Defaults ----->
<cfparam name="form.command" 	default="list">
<cfparam name="form.id" 	default="0">

<cfset CostSequenceManager = CreateObject("component", "components.settings.CostSequenceManager") />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset formName = "frmCostSequence">
<!------ <cfif form.status EQ 1>
	
	
	<cfabort>
</cfif> ----->

<CFSET PageTitle="PROGRAM APPROVAL: COST VARIABLES SEQUENCE">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<title>#PageTitle#</title>
</head>

<body>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<script language="JavaScript">

function submitForm(formName, sCommand)
{
	var oForm = eval("document." + formName);	
	var errCount = 0;
	var bContinue = 1;
	
	if(oForm)
	{
		if(sCommand == "changeOrder2")
		{
			errCount = changeOrderValidate(oForm);
		}
		else if (sCommand == "add")
		{
			if(arguments.length > 2)
			{
				var insertAt = arguments[2];
				oForm.Add_Cost_Sequence_Order.value = insertAt;
			}
			else
			{
				bContinue = 0;
			}
		}
		else if (sCommand == "edit")
		{
			oForm.id.value = arguments[2];
		}
		else if(sCommand == "list")
		{
			oForm.Add_Cost_Sequence_Order.value = 0;
		}
		else if(sCommand == "addEditSave")
		{
			errCount = addEditSaveValidate(oForm);
		}
		else if(sCommand == "delete")
		{
			if(arguments.length > 2)
			{
				if(window.confirm("Do you want to delete the entry (" + arguments[3] + ") ?"))
				{
					var deleteAt = arguments[2];
					oForm.id.value = deleteAt;
				}
				else
				{
					bContinue = 0;
				}
			}
			else
			{
				bContinue = 0;
			}
		}

		if(errCount)
		{
			showMessageWindow();
		}
		else if (bContinue)
		{
			
			oForm.command.value = sCommand;
			oForm.submit();
			//alert("submit");
		}
	}
	return false;
}

</script>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<form method="post" name="#formName#">

<cfswitch expression="#form.command#">
	<cfcase value="list,add,edit" delimiters=",">
		<cfinclude template="cost_Sequence.cfm">
	</cfcase>
	<cfcase value="changeOrder1,changeOrder2">
		<cfinclude template="cost_Sequence_Change_Order.cfm">
	</cfcase>
	<cfcase value="addEditSave">
		<cfinclude template="cost_Sequence_Add_Edit_Save.cfm">
	</cfcase>
	<cfcase value="delete">
		<cfinclude template="cost_Sequence_Delete.cfm">
	</cfcase>
</cfswitch>

<input type="Hidden" name="command" value="#form.command#">
<input type="Hidden" name="Add_Cost_Sequence_Order" value="#form.Add_cost_Sequence_Order#">
</form>

<cf_messagewindow>

</body>
</html>
</cfoutput>