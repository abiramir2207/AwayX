<CFSET PAGETITLE = "PROGRAMS: FUTURES PRICING SETTINGS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>

<!------ set defaults ----->
<cfparam name="form.state" 	default="0">
<cfparam name="url.command" 	default="ceSettings">
<cfparam name="form.command" 	default="#url.command#">
<cfset thisPage = cgi.script_name>
<cfset formName = "frmFuturesPricingSettings">

<cfinclude template="header.cfm">
<script language="JavaScript">
	function submitForm(thisForm, sCommand)
	{
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
</script>

<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">
	function selectAll(srcObj)
	{
		var i, optCount = srcObj.options.length - 1;
		for(i=optCount;i>=0;i--)
		{
			srcObj.options[i].selected = true;
		}	
	}
	
	function addAll(srcObj, destObj)
	{
		var i, optCount = srcObj.options.length - 1;
		for(i=optCount;i>=0;i--)
		{
			addThisValue(srcObj, destObj, i);
		}		
	}
	function addSelect(srcObj, destObj)
	{
		//var optIndex = srcObj.selectedIndex;
		//addThisValue(srcObj, destObj, optIndex);
		var i, optLen = srcObj.options.length - 1;
		for(i=optLen;i>=0;i--)
		{
			if(srcObj.options[i].selected)
			{
				addThisValue(srcObj, destObj, i);
			}
		}
	}
	function addThisValue(srcObj, destObj, optIndex)
	{
		if(optIndex >= 0)
		{
			if(srcObj.options[optIndex].RequestExist && srcObj.options[optIndex].RequestExist == '0')
			{
				addToSelect(destObj, srcObj.options[optIndex]);
				removeToSelect(srcObj, optIndex);
			}
		}
	}
	function addToSelect(selObj, optObj)
	{
		if(optObj)
		{
			var oOption = document.createElement("OPTION");
			oOption.text = optObj.text;
			oOption.value = optObj.value;
			oOption.RequestExist = optObj.RequestExist;			
			var i, optLen = selObj.options.length;
			for(i=0;i<optLen;i++)
			{
				if(selObj.options[i].text.toLowerCase() >= oOption.text.toLowerCase())
				{
					break;
				}
			}
			selObj.add(oOption, i);
		}
	}
	function removeToSelect(selObj, index)
	{
		selObj.remove(index);
	}
	
	function validateThisField(iType, oInput, sMsg)
	{
		var isValid = true;
		switch(iType)
		{
			case 1:
			{
				isValid = isInt(oInput.value);
				break;
			}
			case 2:
			{
				isValid = !isSpace(oInput.value);
				break;
			}
		}
		
		var errObj = eval("document.all.err_sp_" + oInput.name);
		if(isValid)
		{
			clearQueue(errObj);		
		}
		else
		{
			queueMessage(sMsg, errObj);					
		}
		return isValid;
	}

</script>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<form action="#thisPage#" method="post" name="#formName#" style="display:inline;">
	<cfswitch expression="#form.command#">
		<cfcase value="ceSettings">
			<cfinclude template="settings.cfm">
		</cfcase>
		<cfcase value="ceGroupUsers2" delimiters=",">
			<cfset userGroup = 2>
			<cfinclude template="users.cfm">
		</cfcase>
		<cfcase value="ceGroupUsers3" delimiters=",">
			<cfset userGroup = 3>
			<cfinclude template="users.cfm">
		</cfcase>
		<cfcase value="lPreservation,dPreservation" delimiters=",">
			<cfinclude template="preservation.cfm">
		</cfcase>
		<cfcase value="lStatus" delimiters=",">
			<cfinclude template="status.cfm">
		</cfcase>		
	</cfswitch>
	<input type="Hidden" name="state" value="1">
	<input type="Hidden" name="command" value="#form.command#">
</form>
<CF_MessageWindow />
</cfoutput>
</BODY>
</HTML>
