<CFOUTPUT>
<CFSET PAGETITLE = "Deductions: Rebill Letter">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="rebill_component.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.DD_Rebill_Text" 	DEFAULT="">

<cfscript>
	compRebill = CreateObject("component","components.Deduction.Rebill.Rebill");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp" and len(trim(form.DD_Rebill_Text)) GT 0>
	
	<cfscript>
		compRebill.add(DD_Rebill_Text, form.Is_Mandatory, form.Is_Editable, form.Clause_Order,request.AccessStructure.User_ID, form.DD_Classification_ID);
		
	</cfscript>
		
<!---/////////////DEACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "deactSel">
				
	<cfscript>
		compRebill.deactivate(form.CID);
	</cfscript>
		
<!---/////////////DEACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "deact">
		
	<cfscript>
		compRebill.deactivate(form.compId);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "actSel">
				
	<cfscript>
		compRebill.activate(form.CID);
	</cfscript>
		
<!---/////////////ACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "act">
		
	<cfscript>
		compRebill.activate(form.compId);
	</cfscript>
			
<!---/////////////DELETE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "delete">
		
	<cfscript>
		compRebill.delete(form.compId);
	</cfscript>
	
<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif form.command eq "update">
		
	<cfscript>
		if (compRebill.update(form.CompID,form.compName, form.Is_Mandatory, form.Is_Editable, form.Clause_Order,request.AccessStructure.User_ID, form.DD_Classification_ID))
		{
			stError = StructNew();
			stError.bNameExists = true;
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
		qGetCompRebates = compRebill.getActive();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->	
<cfelseif form.display eq "inActive">

	<cfscript>
		qGetCompRebates = compRebill.getInActive();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">
	
	<cfscript>
		qGetCompRebates = compRebill.getComp(form.compId);
	</cfscript>
	
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<cfinclude template="rebill_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm" ENCTYPE="application/x-www-form-urlencoded">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="active">
		<cfinclude template="rebill_display.cfm" />
	</cfcase>
	
	<cfcase value="inActive">
		<cfinclude template="rebill_display.cfm" />
	</cfcase>
	
	<cfcase value="add">
		<cfinclude template="rebill_add.cfm" />
	</cfcase>
	
	<cfcase value="edit">
		<cfinclude template="rebill_edit.cfm" />
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
