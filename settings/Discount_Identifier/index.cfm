<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<cfparam name="form.External_Component_Type" default="" />
<cfset useLakebaseForGeneralSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForGeneralSettings>
	<cftry>
		<cfset GeneralSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"limit" = "1",
				"select" = "use_discount_id"
			}), "use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGeneralSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGeneralSettings>
<cfquery name="GeneralSettings" datasource="#application.datasource#">
SELECT TOP 1 Use_Discount_ID
FROM General_Settings
</cfquery>
</cfif>
<cfset selectedIndex = 99>
<cfif GeneralSettings.Use_Discount_ID IS 1>
	<cfswitch expression="#form.display#">
		<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
		<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
		<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
	</cfswitch>
</cfif>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "discountIdentifiers"
							selectedIndex = "#selectedIndex#" >

<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="discount_id_component.js"></SCRIPT>


<!---They don't use discount IDs--->
<cfif GeneralSettings.Use_Discount_ID IS 1>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<cfscript>
	compRebate = CreateObject("component","components.programs.discount_identifier.discountidentifier");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">

	<cfscript>
		compRebate.add(form.compName,form.compDesc,form.External_Component_Type,form.External_Customer_Type_ID,form.infFixedPrice,form.infRebate,form.infLumpSum,form.infGrowth,form.External_FixedPrice_Component_Type,form.External_Rebate_Component_Type,form.External_LumpSum_Component_Type,form.External_Growth_Component_Type);
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
		if (compRebate.update(form.compId,form.compName,form.compDesc,form.External_Component_Type,form.External_Customer_Type_ID,form.infFixedPrice,form.infRebate,form.infLumpSum,form.infGrowth,form.External_FixedPrice_Component_Type,form.External_Rebate_Component_Type,form.External_LumpSum_Component_Type,form.External_Growth_Component_Type))
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

	<form action="/settings/discount_identifier/turn_on_off.cfm" method="post" name="TurnOn">
		<input type="radio" value="0" name="Use_Discount_ID"> <strong>Turn off discount identification</strong>
		<cfoutput>
			<a href='javascript:TurnOn.submit();'>#application.util.string.actionLinkFormat2('Change Status')#</a>
		</cfoutput>
	</form>

<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">

	<cfcase value="active">
		<cfinclude template="discount_id_display.cfm" />
	</cfcase>

	<cfcase value="inActive">
		<cfinclude template="discount_id_display.cfm" />
	</cfcase>

	<cfcase value="add">
		<cfinclude template="discount_id_add.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="discount_id_edit.cfm" />
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

<form action="change_default.cfm" method="post" name="Change_Default_ID">
	<input type="hidden" name="New_Default_ID" value="1">
</form>

<cfelse>
<!---They don't have the functionality turned on--->

	<blockquote>
	<strong>Turn on discount identifiers</strong>
	<hr width="90%" color="orange" align="left">
	<form action="/settings/discount_identifier/turn_on_off.cfm" method="post" name="TurnOn">
		<input type="radio" value="1" name="Use_Discount_ID"> <strong>Turn on discount identification</strong> <br>
		&nbsp; &nbsp; &nbsp; &nbsp; (will not take affect until you add a default identifier)
		<p></p>
		<CF_button
				button_name		=	""
				button_caption	=	"Change Status"
				button_action	=	"TurnOn.submit();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
	</form>
	</blockquote>
</cfif>
</cfmodule>