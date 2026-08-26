
<cfif IsDefined("url.BBID")>
	<CFSET Billback_ID=URL.BBID>
<cfelseif IsDefined("Form.BBID")>
	<CFSET Billback_ID= Form.BBID>
<cfelse>
	<cfset Billback_ID = "">
</cfif>

<CFIF Billback_ID NEQ "">
	<CFIF IsDefined("FORM.BillBack_Program_ID_List")>
		<CFLOOP LIST="#FORM.BillBack_Program_ID_List#" INDEX="BB_Prog_Guid">
			<CFSET Repalced_BB_Program_ID = REPLACE(BB_Prog_Guid,"_","-","All")>					
			<CFIF IsDefined("FORM.Count_Dont_Count_#BB_Prog_Guid#")>
				<CFSET ThisProgCount = EVALUATE("FORM.Count_Dont_Count_#BB_Prog_Guid#")>				
				<CFQUERY NAME="SetFlag" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback_Product
					SET 	Count_Flag = 1
					WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
							Billback_Product_ID IN (#LISTQUALIFY(ThisProgCount,"'",",","All")#)  
				</CFQUERY>
			</CFIF>
			<CFQUERY NAME="SetOthersZero" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product
				SET 	Count_Flag = 0
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Billback_Program_ID = <cfqueryparam value="#Repalced_BB_Program_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						<CFIF IsDefined("FORM.Count_Dont_Count_#BB_Prog_Guid#")>
						Billback_Product_ID NOT IN (#LISTQUALIFY(ThisProgCount,"'",",","All")#) AND 
						</CFIF>
						Deleted = 0 
			</CFQUERY>	
		</CFLOOP>		
	</CFIF>	
</CFIF>

<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#Billback_ID#'
</CFQUERY>
</cfif>
<CFIF GetStatus.Billback_Status_ID GTE 3> 
	<!--- 17302 - Redirect to Summary --->
	<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
	<CFSET BB_ID_TO_Redirect = Billback_ID>
	<CFINCLUDE TEMPLATE = "/Billbacks/Capture/BB_Summary_Redirect.cfm">
	<CFABORT>
</CFIF>

<!---
<CFQUERY NAME="UpdateManualValue" DATASOURCE="#Application.Datasource#">
	UPDATE Billback_Program_Lumpsum_Component
	SET Manual_Lumpsum_Amount = NULL
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>
--->

<CFQUERY NAME="UpdateGrowth" DATASOURCE="#Application.Datasource#">
	UPDATE BB_Growth_Program
	SET Manual_Growth_Amount = NULL
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!---------------- Call Stored Proc ----------------------->
<CFQUERY  dataSource="#application.datasource#" NAME="SP_BB_Populate_Approval_Tables">
	EXEC BB_Populate_Approval_Tables <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />,
	<cfif structKeyExists(form,"volume_override") and form.volume_override is 1>
	 <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />,
	<cfelse>
	 <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />,
	</cfif>
    <cfif structKeyExists(form,"rate_override") and form.rate_override is 1>
	 <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />
	<cfelse>
	 <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
	</cfif>
</CFQUERY>
<!--- 13678 See if the Billback exists in the BB_Volume Override
      Table. If so, then update it. Otherwise insert it --->
<cfset variables.bb_Override = createObject("component", "components.Billback.BB_Volume_Override").init() />
<cfset variables.bb_rateOverride = createObject("component", "components.Billback.BB_Rate_Override").init() />
<cfset variables.overrideExist = variables.bb_Override.BB_Override_Info_ById(Billback_ID) />	 
<cfset variables.rate_overrideExist = variables.bb_rateOverride.BB_Rate_Override_Info_ById(Billback_ID) />

<!--- Keep track of Volume Override --->
<cfif structKeyExists(form,"volume_override") and form.volume_override is 1>	
 <cfif variables.overrideExist.RecordCount>
  <cfset variables.bb_Override.update_BB_Override(variables.overrideExist.BB_Volume_Override_ID,0) />
 <cfelse>
  <cfset variables.bb_Override.insertBBVolume(Billback_Id) />
</cfif>
 <cfelse>
  <cfif variables.overrideExist.RecordCount>
   <cfset variables.bb_Override.update_BB_Override(variables.overrideExist.BB_Volume_Override_ID,1) />
  </cfif>
</cfif>

<!--- Keep Track of Rate Override --->
<cfif structKeyExists(form,"rate_override") and form.rate_override is 1>	
 <cfif variables.rate_overrideExist.RecordCount>
  <cfset variables.bb_rateOverride.update_BB_Rate_Override(variables.rate_overrideExist.BB_Rate_Override_ID,0) />
 <cfelse>
  <cfset variables.bb_rateOverride.insertBBRate(Billback_Id) />
</cfif>
 <cfelse>
  <cfif variables.rate_overrideExist.RecordCount>
   <cfset variables.bb_rateOverride.update_BB_Rate_Override(variables.rate_overrideExist.BB_Rate_Override_ID,1) />
  </cfif>
</cfif>
<!---------------- Call Stored Proc ----------------------->

<cfoutput>
<cflocation url="index.cfm?BBID=#Billback_ID#" ADDTOKEN="No">
</cfoutput>