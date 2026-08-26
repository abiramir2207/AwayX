<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<cfparam name="url.Generic_Type" default="">
<cfparam name="url.PRICE_PROTECTION_ON" default="">

<cfoutput>
<SCRIPT LANGUAGE="JavaScript"><!--

	
	window.onresize= new Function("ResizeSelect();");
	function ResizeSelect()
	{
		var selectObj = document.all.compNameId_#copNameIndx#;
		
		var wdth = document.body.clientWidth - 50;
		var hght = document.body.clientHeight - 100;
		
		if (wdth < 150)
		{
			wdth = 100;
		}
		
		if (hght < 200)
		{
			hght = 200;
		}
		
		selectObj.style.width = wdth;
		selectObj.style.height = hght;
	}

	function save() 
	{
		thsFrm = document.popupForm;
		if (thsFrm.compNameId_#copNameIndx#.value == "")
		{
			alert("Please select a component or cancel.");
			return;
		}
		//check to make sure there are no components with the same paid to
		var compLen = opener.document.dataForm.compLen.value;
		var tmpCompId = thsFrm.compNameId_#copNameIndx#.value;
		var tmpPaidTo = opener.document.dataForm.compPaidTo_#copNameIndx#.value;
		for(i=1; i<= compLen; i++)
		{
			cmpNmeId = eval("opener.document.dataForm.compNameId_"+[i]+".value");
			pdTo = eval("opener.document.dataForm.compPaidTo_"+[i]+".value");
			//if the component and paid to combination already exists then show an alert
			if (tmpCompId == cmpNmeId && tmpPaidTo == pdTo)
			{
				alert("This component already exists with the same Paid To. Please select another component.");
				return;
			}
		}
    	opener.document.dataForm.compNameId_#copNameIndx#.value = thsFrm.compNameId_#copNameIndx#.value;
    	opener.document.dataForm.submit();
    	window.close();
    	return;
	}
	
//--></SCRIPT>
</cfoutput>

<title>Select Component</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!------ Operating Group ----->
<cfset componentsUnderOperatingGroupLevel2 = "0" />
<cfif appSettings.getOperatingGroupOn()>
	<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
	<!------ Get the operating group for this program ----->
	<cfset operatingGroupProgramLevel2 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=url.program_id) />
	<cfset qGetComponentsUnderOperatingGroupLevel2 = operatingGroupManager.getComponents(operatingGroupProgramLevel2, 2) />
	<cfset componentsUnderOperatingGroupLevel2 = ValueList(qGetComponentsUnderOperatingGroupLevel2.Component_ID) />	
</cfif>
<!------ Operating Group ----->
<cfset isUSDA = 0>
<!---Return only usda components --->
<cfif url.Generic_Type IS "USDA NOI">
	<cfset isUSDA = 1>
</cfif>
	
<!---get the name of the component wiht the id that's in the data struct--->
<cfscript>
	comp = createObject("component","components.programs.rebates.RebateComponent");
	qGetActiveComps = comp.getActive(request.AccessStructure.Profiles_ID, componentsUnderOperatingGroupLevel2, isUSDA,url.PRICE_PROTECTION_ON);
</cfscript>

<FORM NAME="popupForm">
<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td><B><font color="FF0000">[</font> <a href="javascript:save();">save</a> <font color="FF0000">]</font></B>&nbsp;<B><font color="FF0000">[</font> <a href="javascript:window.close();">cancel</a> <font color="FF0000">]</font></B></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td bgcolor="DFE6FF"><b>Select Component</b></td>
	</tr>
	<tr>
		<td>
			<select name="compNameId_<cfoutput>#copNameIndx#</cfoutput>" size="10" style="width:150">
				<cfoutput query="qGetActiveComps">
					<option value="#Program_Rebates_Component_Name_ID#">#Program_Rebates_Component_Name#</option>
				</cfoutput>
			</select>
		</td>
	</tr>
</table>
</form>
</body>
</html>
