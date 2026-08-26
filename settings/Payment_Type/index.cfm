<cfsilent>
<CFPARAM NAME="form.display" 	DEFAULT="active">
<CFPARAM NAME="form.command" 	DEFAULT="">
<CFPARAM NAME="form.returnTo" 	DEFAULT="">
<CFPARAM NAME="form.Include_Claim_Rates_Report" 	DEFAULT="0">
<CFPARAM NAME="form.Include_Pricing_Report" 	DEFAULT="0">
<cfset selectedIndex = 99>
<cfswitch expression="#form.display#">
	<cfcase value="active">    <cfset selectedIndex = 0> 	</cfcase>
	<cfcase value="inActive">  <cfset selectedIndex = 1> 	</cfcase>
	<cfcase value="add">       <cfset selectedIndex = 2> 	</cfcase>
</cfswitch>	
</cfsilent>
<cfmodule template="/customTags/layout.cfm" 
							layoutID = "claimMechanics" 
							selectedIndex = "#selectedIndex#" >

<CFOUTPUT>
<CFSET PAGETITLE = "CLAIM MECHANICS">
</CFOUTPUT>
<SCRIPT SRC="/script/javascript/string_functions.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="payment_type_component.js"></SCRIPT>
<script type="text/javascript" src="/script/tTip.js"></script>
<link rel="stylesheet" href="/styles/tTip.css" type="text/css" /> 

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rebate Component List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->


<cfscript>
	compRebate = CreateObject("component","components.programs.payment_type.paymenttype");
</cfscript>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Controller Section xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


<!---****************************** START COMMANDS ***********************************--->

<!---/////////////ADD COMPONENT///////////--->
<cfif form.command eq "addComp">
			
	<cfscript>
		compRebate.add(form.compName,form.compDesc,form.Off_Invoice, form.Restrict_From_Billback, request.accessstructure.User_ID, form.Program_Lock_Type_ID, form.Include_Claim_Rates_Report, form.Include_Pricing_Report,form.BBClosingMethod);
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
		if (compRebate.update(form.compId,form.compName,form.compDesc,form.Off_Invoice,form.Restrict_From_Billback, request.accessstructure.User_ID, form.Program_Lock_Type_ID, form.Include_Claim_Rates_Report, form.Include_Pricing_Report,form.BBClosingMethod))
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

  <!----------------------------------------------------------------------------- 
  Dev Notes: D18281 - Solo - Add new closing method on billback entry	
  All the closing method dropdown and values now come from the DB based on 
  the settings in the settings panel 
  -Anand Rao/29-May-09
  ------------------------------------------------------------------------------>
<cfset useLakebaseForgetClosingMethods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_closing_methods")>
<cfif useLakebaseForgetClosingMethods>
	<cftry>
		<cfset getClosingMethods = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_closing_methods", {
				"deleted" = "eq.0",
				"benabled" = "eq.1",
				"order" = "vchbillback_closing_method_desc.asc",
				"select" = "ibillback_closing_method_id,vchbillback_closing_method_desc,benabled,tiautopay_bb_status,deleted,abbreviation"
			}), "ibillback_closing_method_id,vchbillback_closing_method_desc,benabled,tiautopay_bb_status,deleted,abbreviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetClosingMethods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetClosingMethods>
<cfquery NAME="getClosingMethods" datasource="#application.datasource#">
  SELECT  iBillback_Closing_Method_ID,
        	vchBillback_Closing_Method_Desc,
        	bEnabled,
      	  tiAutoPay_BB_Status,
      	  Deleted,
      	  Abbreviation
  FROM  Billback_Closing_Methods WHERE Deleted = 0 
  AND bEnabled = 1
  ORDER BY vchBillback_Closing_Method_Desc 
</cfquery>
</cfif>
              
<FORM ACTION="index.cfm" METHOD="post" NAME="DataForm">

<!--switch for each action--->
<cfswitch expression="#form.display#">
	
	<cfcase value="active">
		<cfinclude template="payment_type_display.cfm" />
	</cfcase>
	
	<cfcase value="inActive">
		<cfinclude template="payment_type_display.cfm" />
	</cfcase>
	
	<cfcase value="add">
		<cfinclude template="payment_type_add.cfm" />
	</cfcase>
	
	<cfcase value="edit">
		<cfinclude template="payment_type_edit.cfm" />
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


</cfmodule>