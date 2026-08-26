<cfsilent>
<cfparam NAME="form.display" 	default="active">
<cfparam NAME="form.command" 	default="">
<cfparam NAME="form.returnTo" default="">
<cfparam name="form.SortBy" 	default="GL_Account" />
<cfparam name="form.discountComponents" 	default="" />

<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "glAccounts"
							selectedIndex = "#selectedIndex#" >

<!-- style -->
<style>.Orangline{border-right: 2px solid orange;}</style>

<script type="text/javascript"> var glAccountLabel = '<cfoutput>#Application.GLAccountLabel#</cfoutput>'; </script>

<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="gl_account_component.js"></SCRIPT>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<cfscript>
	compRebate = CreateObject("component","GLAccountManager");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
	<cfscript>
		compRebate.addComp(form.GL_Account,form.GL_Account_Desc,form.Start_Date,form.End_Date,request.accessstructure.user_id, form.discountComponents);
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
		compRebate.activate(form.CID,request.accessstructure.user_id);
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
		compRebate.editComp(form.compID,form.GL_Account,form.GL_Account_Desc,form.Start_Date,form.End_Date,request.accessstructure.user_id, form.discountComponents);
	</cfscript>

</cfif>

<cfset form.command = "" />

<!---****************************** END COMMANDS ***********************************--->


<!---****************************** START DISPLAY ***********************************--->

<!---/////////////DISPLAY ACTIVE///////////--->

<cfif form.display eq "active">
	<cfscript>
		qGetCompRebates = compRebate.getActive(form.SortBy);
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->
<cfelseif form.display eq "inActive">
	<cfscript>
		qGetCompRebates = compRebate.getInActive(form.SortBy);
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">
	<cfscript>
		qGetCompRebates = compRebate.getComp(form.compId);
	</cfscript>

	<!------ we need to find out if this gl account if already used in a program. If so do nto allow the user to edit teh gl code --->
	<cfset glUsedInProgram = 0 />
	<cfset ProgramComponents = CreateObject("component", "components.programs.ProgramComponents") />
	<cfloop list="1,2,3,4" index="discountId">
		<cfset qProgramDiscountComponentsForThisGL = ProgramComponents.GetProgramComponents(Discount_Type_ID=discountId, GL_Account_ID=form.compId) />
		<cfif qProgramDiscountComponentsForThisGL.recordCount>
			<cfset glUsedInProgram = 1 />
			<cfbreak />
		</cfif>
	</cfloop>
<!---	D45619 :: Add [copy] link and alphabetize selected components in GL codes START--->
<cfelseif form.display eq "copy">
	<cfscript>
		qGetCompRebates = compRebate.getComp(form.compId);
	</cfscript>
<!---	D45619 :: Add [copy] link and alphabetize selected components in GL codes END--->
</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!--- <cfinclude template="gl_account_header.cfm" /> --->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="GL_Account_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="GL_Account_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="GL_Account_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="GL_Account_edit.cfm" />
	</cfcase>
<!---	D45619 :: Add [copy] link and alphabetize selected components in GL codes START--->
	<cfcase value="copy">
		<cfinclude template="GL_Account_copy.cfm" />
	</cfcase>
<!---	D45619 :: Add [copy] link and alphabetize selected components in GL codes END--->
</cfswitch>

<cfoutput>
<!---hidden form fields--->
<input type="hidden" name="SortBy" value="<cfoutput>#SortBy#</cfoutput>">
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="compId" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
</cfoutput>
</FORM>
<script>
function sortResults(fieldname)
{
	document.DataForm.SortBy.value = fieldname;
	window.parent.mainwindow.document.DataForm.submit();
	return false;
}
</script>

</cfmodule>
