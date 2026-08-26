<!------ Authority_Sequence.cfm ----->

<!------ Set Defaults ----->
<cfparam name="form.command" 	default="list">
<cfparam name="form.id" 	default="0">
<cfparam name="url.command" 	default="">
<cfparam name="form.Add_Authority_Sequence_Order" default="0">
<cfparam name="form.Add_HQ_Position_Order" default="0">
<cfparam name="form.HQ_Position_Id" default="0">
<cfparam name="form.HQ_Position_Order_check" default="0">

<cfif isdefined("url.command") and url.command NEQ "">
<cfset form.command = url.command>
<cfset url.command = " ">
</cfif>

<cfset authoritySequenceManager = CreateObject("component", "components.user.AuthoritySequenceManager").init() />
<cfset HQPositionManager = CreateObject("component", "components.user.HQPositionManager") />
<cfset createLog = createObject("component", "components.settings.AuditTrail.AuditTrail").init()>

<cfset formName = "frmAuthoritySequence">
<!------ <cfif form.status EQ 1>


	<cfabort>
</cfif> ----->

<CFSET PageTitle="USERS: AUTHORITY SEQUENCE">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<title>#PageTitle#</title>
</head>

<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>


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
			<cfif appSettings.getHQpositionsOn()>
			if (!confirm("All the authority sequences assigned to the HQ positions will be deleted. Click OK to continue or Cancel."))
			{
				return false;
			}
			</cfif>
		}
		else if (sCommand == "add")
		{
			if(arguments.length > 2)
			{
				var insertAt = arguments[2];
				oForm.Add_Authority_Sequence_Order.value = insertAt;
				oForm.id.value = 0;
			}
			else
			{
				bContinue = 0;
			}
		}
		else if (sCommand == "addHQ")
		{
			if(arguments.length > 2)
			{
				var insertAt = arguments[2];
				oForm.Add_HQ_Position_Order.value = insertAt;
			}
			else
			{
				bContinue = 0;
			}
		}
		else if(sCommand == "list")
		{
			oForm.Add_Authority_Sequence_Order.value = 0;
		}
		else if(sCommand == "HQ")
		{
			oForm.Add_HQ_Position_Order.value = 0;
		}
		else if(sCommand == "edit")
		{
			oForm.Authority_Sequence_Order.value = arguments[2];
			oForm.Authority_Sequence_Name.value = arguments[3];
			oForm.id.value = arguments[4];
			bContinue = 0;
		}
		else if(sCommand == "editHQ")
		{
			oForm.HQ_Position_Order.value = arguments[2];
			oForm.HQ_Position_Name.value = arguments[3];
			oForm.id.value = arguments[4];
			bContinue = 0;
		}
		else if(sCommand == "addEditSave" || sCommand == "addEditSaveHQ" )
		{
			errCount = addEditSaveValidate(oForm);
		}
		else if(sCommand == "AssignHQ")
		{
		oForm.HQ_Position_Id.value =  arguments[2];
		oForm.HQ_Position_Order_check.value =  arguments[3];
		}
		else if(sCommand == "AssignHQSave")
		{
			errCount = AssignASValidate(oForm);
		}
		else if(sCommand == "delete" || sCommand == "deleteHQ")
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
<cfif appSettings.getHQpositionsOn()>
<cfinclude template="Authority_sequence_header.cfm" />
</cfif>

<form method="post" name="#formName#" action="index.cfm">
<cfswitch expression="#form.command#">
	<cfcase value="list,add" delimiters=",">
		<cfinclude template="Authority_Sequence.cfm">
	</cfcase>
	<cfcase value="changeOrder1,changeOrder2">
		<cfinclude template="Authority_Sequence_Change_Order.cfm">
	</cfcase>
	<cfcase value="addEditSave,addEditSaveHQ">
		<cfinclude template="Authority_Sequence_Add_Edit_Save.cfm">
	</cfcase>
	<cfcase value="delete,deleteHQ">
		<cfinclude template="Authority_Sequence_Delete.cfm">
	</cfcase>
	<cfcase value="HQ,addHQ">
		<cfinclude template="HQ_Positions.cfm">
	</cfcase>
	<cfcase value="AssignHQ">
		<cfinclude template="AssignAS_HQ.cfm">
	</cfcase>
	<cfcase value="AssignHQSave,AssignHQDelete">
		<cfinclude template="AssignAS_HQSave.cfm">
	</cfcase>
	<cfcase value="RT">
		<cfinclude template="AssignHQ_RevisionTypes.cfm">
	</cfcase>
	<cfcase value="RTSave">
		<cfinclude template="AssignAS_HQSave.cfm">
	</cfcase>
</cfswitch>

<cfif appSettings.getAuditTrailStorage() NEQ 0>
	<cfswitch expression="#form.command#">
		<cfcase value="changeOrder2,addEditSave,addEditSaveHQ,delete,deleteHQ"><!--- changeOrder1 -- Removed this command --->
			<cfset createLog.createXMLlog("Authority_Sequence",2)>
			<cflocation addtoken="No" url="index.cfm?command=list">
		</cfcase>
	</cfswitch>
</cfif>

<input type="Hidden" name="command" value="#form.command#">
<input type="Hidden" name="Add_Authority_Sequence_Order" value="#form.Add_Authority_Sequence_Order#">
<input type="Hidden" name="Add_HQ_Position_Order" value="#form.Add_HQ_Position_Order#">
<input type="Hidden" name="HQ_Position_Id" value="#form.HQ_Position_Id#">
<input type="Hidden" name="HQ_Position_Order_check" value="#form.HQ_Position_Order_check#">
</form>

<cf_messagewindow>

</body>
</html>
</cfoutput>