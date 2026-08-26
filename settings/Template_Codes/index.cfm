<CFOUTPUT>
<CFSET PAGETITLE = "PROGRAMS: FIXED COMPONENTS">
</CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="template_code.js"></SCRIPT>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Fixed Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.compExternalID" 	DEFAULT="">

<cfscript>
	tempCode = CreateObject("component","components.programs.TemplateCodes.TemplateCodeManager");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
			
	<cfscript>
		stError = StructNew();
		stError.bNameExists = tempCode.add(form.compName, form.compExternalID,form.compNameDesc);
		if(stError.bNameExists EQ 2)
		{			
			form.display = "add";
		}
	</cfscript>
		
<!---/////////////DEACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "deactSel">
				
	<cfscript>
		tempCode.deactivate(form.CID);
	</cfscript>
		
<!---/////////////DEACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "deact">
		
	<cfscript>
		tempCode.deactivate(form.compId);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST OF COMPONENTS///////////--->
<cfelseif form.command eq "actSel">
				
	<cfscript>
		tempCode.activate(form.CID);
	</cfscript>
		
<!---/////////////ACTIVATE SINGLE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "act">
		
	<cfscript>
		tempCode.activate(form.compId);
	</cfscript>
			
<!---/////////////DELETE SELECTED COMPONENT///////////--->
<cfelseif form.command eq "delete">
		
	<cfscript>
		tempCode.delete(form.compId);
	</cfscript>
	
<!---/////////////UPDATE COMPONENT///////////--->
<cfelseif form.command eq "update">
		
	<cfscript>
		if (tempCode.update(form.compId, form.compName, form.compExternalID,form.compNameDesc))
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
		qGetTempCode = tempCode.getActive();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->	
<cfelseif form.display eq "inActive">

	<cfscript>
		qGetTempCode = tempCode.getInActive();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">
	
	<cfscript>
		qGetTempCode = tempCode.getComp(form.compId);
	</cfscript>
	
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<cfinclude template="/settings/fixed_components/Fixed_component_header.cfm" />

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="active">
		<cfinclude template="template_code_display.cfm" />
	</cfcase>
	
	<cfcase value="inActive">
		<cfinclude template="template_code_display.cfm" />
	</cfcase>
	
	<cfcase value="add">
		<cfinclude template="template_code_add.cfm" />
	</cfcase>
	
	<cfcase value="edit">
		<cfinclude template="template_code_edit.cfm" />
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
