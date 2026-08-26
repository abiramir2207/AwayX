<CFOUTPUT>
<CFSET PAGETITLE = "PROGRAMS: Off-Invoice Component Names">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="oi_name_component.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<cfparam name="form.Operating_Group_ID" 	default="0">
<cfparam name="form.Allowance_Code_ID" 	default="0">
<cfparam name="form.Required_Effective_Rate_Percent" 	default="0">
<cfparam name="form.Template_Select" 	default="">

<cfscript>
	compRebate = CreateObject("component","components.programs.Off_Invoice.OffInvoiceComponent");
</cfscript>

<cfset operatingGroupManager = CreateObject("component","components.Operating_Group.OperatingGroupManager").init() />
<cfset operatingGroupOn = operatingGroupManager.operatingGroupOn() />
<cfset operatingGroupLevel = operatingGroupManager.componentMapLevel() />
<cfset allowanceCodeManager = CreateObject("component","components.Operating_Group.AllowanceCodeManager").init() />
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
			
	<cfscript>
		stError = StructNew();
		stError.bNameExists = compRebate.add(form.compName, form.compExternalID, form.Operating_Group_ID, form.Allowance_Code_ID, form.Required_Effective_Rate_Percent, form.Template_Select);
		if(stError.bNameExists NEQ 0 AND stError.bNameExists NEQ 1)
		{			
			form.display = "add";
		}
	</cfscript>
		
<!---/////////////DEACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "deactSel">
				
	<cfscript>
		compRebate.deactivate(form.CID);
	</cfscript>
		
<!---/////////////DEACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "deact">
		
	<cfscript>
		compRebate.deactivate(form.compId);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "actSel">
				
	<cfscript>
		compRebate.activate(form.CID);
	</cfscript>
		
<!---/////////////ACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "act">
		
	<cfscript>
		compRebate.activate(form.compId);
	</cfscript>
			
<!---/////////////DELETE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "delete">
		
	<cfscript>
		compRebate.delete(form.compId);
	</cfscript>
	
<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif form.command eq "update">
		
	<cfscript>
		bNameExists = compRebate.update(form.compId,form.compName, form.compExternalID, form.Operating_Group_ID, form.Allowance_Code_ID, form.Required_Effective_Rate_Percent, form.Template_Select);
		if (bNameExists)
		{
			stError = StructNew();
			stError.bNameExists = bNameExists;
			form.display = "edit";
		}
	</cfscript>
		
</cfif>
	
<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->

<cfif form.display eq "active">
	
	<cfscript>
		qGetCompRebates = compRebate.getActive();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->	
<cfelseif form.display eq "inActive">

	<cfscript>
		qGetCompRebates = compRebate.getInActive();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">
	
	<cfscript>
		qGetCompRebates = compRebate.getComp(form.compId);
	</cfscript>
	
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<cfinclude template="oi_name_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="active">
		<cfinclude template="oi_name_display.cfm" />
	</cfcase>
	
	<cfcase value="inActive">
		<cfinclude template="oi_name_display.cfm" />
	</cfcase>
	
	<cfcase value="add">
		<cfinclude template="oi_name_add.cfm" />
	</cfcase>
	
	<cfcase value="edit">
		<cfinclude template="oi_name_edit.cfm" />
	</cfcase>

</cfswitch>	

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="compId" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
</cfoutput>
</FORM>

</BODY>
</HTML>
