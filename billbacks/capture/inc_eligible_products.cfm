<!--- 
Called from:
	/billbacks/capture/selectproductsfromprogram.cfm
	/billbacks/capture/power_punch_action.cfm
	/billbacks/big_billbacks/enterBBstoBillbacks.cfm
Expected inputs:
*BBID (Billback_ID)
*DiscountList
*Billback_Contract_Main_ID or getParentIDs_List

Calling pages query AllEligibleProducts
Ana: D12909 - removed most of the queries in this page and converting them into procedure.
 --->
<cfset Billback_ID = BBID>
<cfset ValidDiscountBGColor = "ffff99">

<cfparam name="Calling_Page" default="ProductsOnPrograms">
<cfparam name="getParentIDs_List" default="">
<!---BJF 12106 - Intelligent product highlighting --->

<!---Payable to--->
<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
	SELECT 	BB_Start_Date, BB_End_Date, Billback_Payee_Type_ID 
	FROM 	Billback 
	WHERE 	Billback_ID = '#Billback_ID#'
</cfquery> 

<cfset BB_Start_Date = GetBillbackInfo.BB_Start_Date>
<cfset BB_End_Date = GetBillbackInfo.BB_End_Date>
<cfset Payee_Type = GetBillbackInfo.Billback_Payee_Type_ID>

<CFOUTPUT>
	<!---D40276 ::  EVENT ERRORS
		Was not able to recreate this event error as a precaution added code to check LENGTH of Billback Contract Main ID to Prevent these event errors
		--->
		
<cfif (isDefined("Billback_Contract_Main_ID") AND LEN(Billback_Contract_Main_ID)) AND NOT isDefined("GetParentIDFor_MultiPrograms")>
	<!--- get eligible revisions --->
	<!--- For product highlighting, just the latest version --->
	<cfquery name="getParentIDs" datasource="#application.datasource#">
		SELECT Contract_Main_ID 
		FROM Contract_Main
		WHERE Contract_Number IN (SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = #Billback_Contract_Main_ID#)
		AND Approved = 1
		ORDER By Contract_Main_ID DESC
	</cfquery>
		
	<CFSET getParentIDs_List = valuelist(getParentIDs.contract_main_id)><!--- input for inc_eligible_products.cfm ---->

	<!---D40276 ::  EVENT ERRORS
		Was not able to recreate this event error as a precaution added code to check LENGTH of Billback Contract Main ID to Prevent these event errors
		--->
<CFELSEIF (isDefined("Billback_Contract_Main_ID") AND LEN(Billback_Contract_Main_ID)) AND IsDefined("GetParentIDFor_MultiPrograms")>
	<CFLOOP LIST="#Billback_Contract_Main_ID#" INDEX="ThisProgramID">
	<!--- For product highlighting, just the latest version --->
	<cfquery name="getParentIDs" datasource="#application.datasource#">
		SELECT Contract_Main_ID 
		FROM Contract_Main
		WHERE Contract_Number IN (SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = #ThisProgramID#)
		AND Approved = 1
		ORDER By Contract_Main_ID DESC
	</cfquery>
		<CFSET getParentIDs_ValueList = valuelist(getParentIDs.contract_main_id)><!--- input for inc_eligible_products.cfm ---->
		<CFIF getParentIDs_List EQ "">
			<CFSET getParentIDs_List = getParentIDs_ValueList>
		<CFELSE>
			<CFSET getParentIDs_List = "#getParentIDs_List#,#getParentIDs_ValueList#">
		</CFIF>		
	</CFLOOP>
</CFIF>
</CFOUTPUT>

<CFIF NOT ISDefined("DontExecSPInInclude")>
	<Cfif Calling_Page IS "Highlight">
	<CFQUERY name="AllEligibleProducts" datasource="#application.datasource#">
		EXEC BB_Highlighed_Products '#Billback_ID#', '#getParentIDs_List#',#Payee_Type#,'#DiscountList#'
	</CFQUERY>
	<Cfelse>
	<CFQUERY name="AllEligibleProducts" datasource="#application.datasource#">
		EXEC BB_Products_On_Program '#Billback_ID#', '#getParentIDs_List#',#Payee_Type#
	</CFQUERY>
	</cfif>
</CFIF>
