<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "currency"
							selectedIndex = "#selectedIndex#" >

<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="currency_component.js"></SCRIPT>



<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<cfscript>
	currency = CreateObject("component","components.programs.currency.currencytype");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD CURRENCY///////////--->
<cfif form.command eq "addcurrency">

	<cfscript>
		currency.add(form.currencyName,form.currencyCode, request.accessstructure.User_ID);
	</cfscript>

<!---/////////////DEACTIVATE SELECTED LIST OF CURRENCIES///////////--->
<cfelseif form.command eq "deactSel">

	<cfscript>
		currency.deactivate(form.CID);
	</cfscript>

<!---/////////////DEACTIVATE SINGLE SELECTED CURRENCY///////////--->
<cfelseif form.command eq "deact">

	<cfscript>
		currency.deactivate(form.currencyId);
	</cfscript>

<!---/////////////ACTIVATE SELECTED LIST OF CURRENCIES///////////--->
<cfelseif form.command eq "actSel">

	<cfscript>
		currency.activate(form.CID);
	</cfscript>

<!---/////////////ACTIVATE SINGLE SELECTED CURRENCY///////////--->
<cfelseif form.command eq "act">

	<cfscript>
		currency.activate(form.currencyId);
	</cfscript>

<!---/////////////DELETE SELECTED CURRENCY///////////--->
<cfelseif form.command eq "delete">

	<cfscript>
		currency.delete(form.currencyId);
	</cfscript>

<!---/////////////UPDATE CURRENCY///////////--->
<cfelseif form.command eq "update">

	<cfscript>
		if (currency.update(form.currencyId,form.currencyName,form.currencyCode, request.accessstructure.User_ID))
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
		qGetCurrency = currency.getActive();
	</cfscript>

<!---/////////////DISPLAY INACTIVE///////////--->
<cfelseif form.display eq "inActive">

	<cfscript>
		qGetCurrency = currency.getInActive();
	</cfscript>

<!---/////////////DISPLAY EDIT///////////--->
<cfelseif form.display eq "edit">

	<cfscript>
		qGetCurrency = currency.getCurrency(form.currencyId);
	</cfscript>

</cfif>

<!---****************************** END DISPLAY ***********************************--->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  End Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->

<!--- <cfinclude template="currency_header.cfm" /> --->

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="currency_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="currency_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="currency_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="currency_edit.cfm" />
	</cfcase>

</cfswitch>

<cfoutput>
<!---hidden form fields--->
<input name="display" type="hidden" value="#form.display#" />
<input name="command" type="hidden" value="#form.command#" />
<input name="currencyId" type="hidden" value="" />
<input name="returnTo" type="hidden" value="#form.returnTo#"/>
</cfoutput>
</FORM>

<form action="change_default.cfm" method="post" name="Change_Default_ID">
	<input type="hidden" name="New_Default_ID" value="1">
</form>

</cfmodule>