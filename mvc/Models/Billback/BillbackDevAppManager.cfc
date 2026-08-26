<!-----------------------------------------------------------------------------

FILE NAME:		BillbackDevAppManager.cfc
DESCRIPTION:	Returns the data for populating the datagrid
              
CREATED BY:		Anand Rao/ 29-Jul-09

MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************
 
------------------------------------------------------------------------------>

<cfcomponent name="BillbackDevAppManager" displayname="BillbackDevAppManager" hint="Billback Deviations, Approval Pages" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />

  <!--------------------------------------------------------------------------- 
  *****************************************************************************
    This function executes a query and gets all the information about the 
    billback for display purpose and returns the result to the Flex tool     
  *****************************************************************************    
  -----------------------------------------------------------------------------> 
  
  <cffunction name="getBillbackHeader" hint="return all the details about the Billback" access="remote" output="false" returntype="any">
    <cfargument name="BBID" default=""> 
    <cfargument name="UserId" default="" />
    <cfoutput>
    <!------------------------------------------------------------------------- 
      This query returns all the required information about the Billback that 
      needs to be displayed in the header
    --------------------------------------------------------------------------->
    <!--- <cfdump var="#application.datasource#" output="C:\ds.html"  /> --->
    <cfquery name="qryBillbackHeader" datasource="#application.datasource#">
     DECLARE	@Payee_Name nvarchar(200)     
    
    IF OBJECT_ID('tempdb..##tmp_bb_header') IS NOT NULL
    DROP TABLE ##tmp_bb_header
    
    SELECT	
      Billback.Billback_ID, 
      LTRIM(RTRIM(Billback.BB_Title)) AS BB_Title, 
      CONVERT(VARCHAR(10), Billback.BB_Start_Date, 101) AS BB_Start_Date,
      CONVERT(VARCHAR(10), Billback.BB_End_Date, 101) AS BB_End_Date, 
      Billback.BB_Amount, 
      Billback.BB_Code, 
      CONVERT(VARCHAR(10), Billback.BB_Date, 101) AS BB_Date, 
      Billback.Billback_Status_ID,
      Billback.Billback_Payee_Type_ID,
      Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag,
      Billback.BB_All_Dup_Group_ID,
      Billback.Validate_BB_UOM,
      Billback.Validate_BB_UOM_Failure,
      Billback.Billback_ID_Int
    INTO	##tmp_bb_header
    FROM	Billback	
    WHERE 	<cfif len(arguments.BBID) eq 36>
				Billback.Billback_ID = '#arguments.BBID#'
    		<cfelse>
    			Billback.Billback_ID_Int = '#arguments.BBID#'
			</cfif>
  
    -- Payee is distributor
    SELECT	@Payee_Name = BSA_Foodservice_Customers.Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Distributor
    ON	Billback_Distributor.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Distributor.Deleted = 0
    INNER JOIN	BSA_Foodservice_Customers
    ON	Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
    WHERE	Billback_Payee_Type_ID = 1
    
    -- Payee is distributor (unknown)
    SELECT	@Payee_Name = Billback_Distributor.BB_Distributor_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Distributor
    ON	Billback_Distributor.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Distributor.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 5
    
    -- Payee is operator
    SELECT	@Payee_Name = BSA_Operator.Operator_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Operator
    ON	Billback_Operator.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Operator.Deleted = 0
    INNER JOIN	BSA_Operator
    ON	Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID
    WHERE	Billback_Payee_Type_ID = 2
    
    -- Payee is operator (unknown)
    SELECT	@Payee_Name = Billback_Operator.BB_Operator_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Operator
    ON	Billback_Operator.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Operator.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 6
    
    
    -- Payee is broker
    SELECT	@Payee_Name = BSA_Foodservice_Brokers.Broker_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Broker
    ON	Billback_Broker.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Broker.Deleted = 0
    INNER JOIN	BSA_Foodservice_Brokers
    ON	Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
    WHERE	Billback_Payee_Type_ID = 3
    
    
    -- Payee is broker (unknown)
    SELECT	@Payee_Name = Billback_Broker.BB_Broker_Name 
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Broker
    ON	Billback_Broker.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Broker.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 7
    
    
    /* SELECT 	##tmp_bb_header.*, LTRIM(RTRIM(@Payee_Name)) as Payee_Name, CAST(_Application_Settings.BB_Deviations_Override_price AS INT) AS BB_Deviations_Override_price
    FROM	##tmp_bb_header INNER JOIN _Application_Settings ON
    1=1 */
 
    SELECT 	*, LTRIM(RTRIM(@Payee_Name)) as Payee_Name
    FROM	##tmp_bb_header 
     
  </cfquery>  
  </cfoutput>
  
  <cfset oBillbackColorSettings = createObject("component", "components.billback.BillbackSettingsManager") />
  <cfset qGetBBDevColorSetting 	= oBillbackColorSettings.getBBDevColorSetting() />	
  
 <!---  <cfdump var="#qryBillbackHeader#" output="C:\qryBillbackHeader.html" /> --->
  <!--------------------------------------------------------------------------- 
    Get all the appsettings from the application scope
    This line should be 
     <cfset appSettings = request.applicationAppSettingsManager.getApplicationAppSettings()> 
     in 5.1
  ----------------------------------------------------------------------------->
 <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()> 
  <!--------------------------------------------------------------------------- 
    Get the setting BB_DEVIATIONS_OVERRIDE_PRICE from the appsettings and 
    add it to the result set qryBillbackHeader
  ----------------------------------------------------------------------------->
  
  <cfset iBBDevOverridePrice = appSettings.BB_DEVIATIONS_OVERRIDE_PRICE />
  <cfif qryBillbackHeader.BB_Level_Deviations_Override_Price_Flag EQ 1>
		<cfset iBBDevOverridePrice = 1 />
  </cfif>

  <cfset arrBBDev = ArrayNew(1)>
  <cfset arrBBDev[1] = iBBDevOverridePrice>
  <cfset addColumn1 = QueryAddColumn(qryBillbackHeader, "BB_DEVIATIONS_OVERRIDE_PRICE", arrBBDev)>
  
  <!--- Add the two new setting that was added for 21923 --->
  <cfset arrBBDev[1] = appSettings.UPDATE_BB_APPROVE_AMT>
  <cfset addColumn2 = QueryAddColumn(qryBillbackHeader, "UPDATE_BB_APPROVE_AMT", arrBBDev)>
  
  <!--- 
    If the Override price setting not set then, no issues with setting the 
    Expected Less Tolerance if not then set the Less tolerance setting to 0
  ---> 
  <cfif (iBBDevOverridePrice EQ 0)>
    <cfset arrBBDev[1] = appSettings.BB_APPROVE_EXPECTED_RATE_LESS_TOLERANCE>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn3 = QueryAddColumn(qryBillbackHeader, "BB_APPROVE_EXPECTED_RATE_LESS_TOLERANCE", arrBBDev)>
  
  <!--- 
        22925/Anand Rao/01-Apr-2010:
        BBK approval - disagree option is no longer available
   --->
   <cfset useLakebaseForqryGetProfileID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqryGetProfileID>
	<cftry>
		<cfset qryGetProfileID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#arguments.UserId#",
				"select" = "profiles_id"
			}), "profiles_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetProfileID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetProfileID>
<CFQUERY NAME="qryGetProfileID" DATASOURCE="#application.datasource#">
    	SELECT Profiles_ID FROM _Users WHERE User_ID = '#arguments.UserId#'
    </CFQUERY>
</cfif>
    <cfset profile = CreateObject("component","components.user.Profile").init() />
    <cfset Get_Profile_Settings = profile.getProfileSettings(#qryGetProfileID.Profiles_ID#)>
    
  <cfif (Get_Profile_Settings.BB_Approve EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_Approve>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn4 = QueryAddColumn(qryBillbackHeader, "BB_APPROVE", arrBBDev)>
    
<!--- 
	Dev Notes: 23156/Anand Rao/26-Apr-10
	User profile to control manual rate override on bb deviation grid
--->
    
  <cfif (Get_Profile_Settings.BB_Dev_Grid_Manual_Rate_Override_Check EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_Dev_Grid_Manual_Rate_Override_Check>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn5 = QueryAddColumn(qryBillbackHeader, "BB_DEV_GRID_MANUAL_RATE_OVERRIDE_CHECK", arrBBDev)>
    
<!--- 
	Dev Notes: D23395/Anand Rao/17-May-10
	  BB Deviation grid should consider profile settings
--->
    
  <cfif (Get_Profile_Settings.BB_Volume_Override EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_Volume_Override>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn6 = QueryAddColumn(qryBillbackHeader, "BB_VOLUME_OVERRIDE", arrBBDev)>
    
  <cfif (Get_Profile_Settings.BB_Rate_Override EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_Rate_Override>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn7 = QueryAddColumn(qryBillbackHeader, "BB_RATE_OVERRIDE", arrBBDev)>    
    
 	<!--- 
				Dev Notes: D24193/Anand Rao/27-Jul-10
				BB Flex Grid Select All Button & Approve Change
	--->
  <!--- COLOR CODING FOR BUTTONS  --->
  <cfif (qGetBBDevColorSetting.ExpBtnBgColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.ExpBtnBgColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn8 = QueryAddColumn(qryBillbackHeader, "EXPBTNBGCOLOR", arrBBDev)>   

  <cfif (qGetBBDevColorSetting.ExpBtnFontColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.ExpBtnFontColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn9 = QueryAddColumn(qryBillbackHeader, "EXPBTNFONTCOLOR", arrBBDev)>    

  <cfif (qGetBBDevColorSetting.EltBtnBgColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.EltBtnBgColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn10 = QueryAddColumn(qryBillbackHeader, "ELTBTNBGCOLOR", arrBBDev)>    
  
  <cfif (qGetBBDevColorSetting.EltBtnFontColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.EltBtnFontColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn11 = QueryAddColumn(qryBillbackHeader, "ELTBTNFONTCOLOR", arrBBDev)>  

  <cfif (qGetBBDevColorSetting.ClmBtnBgColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.ClmBtnBgColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn12 = QueryAddColumn(qryBillbackHeader, "CLMBTNBGCOLOR", arrBBDev)>   

  <cfif (qGetBBDevColorSetting.ClmBtnFontColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.ClmBtnFontColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn13 = QueryAddColumn(qryBillbackHeader, "CLMBTNFONTCOLOR", arrBBDev)>  
  
  <cfif (qGetBBDevColorSetting.SelBtnBgColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.SelBtnBgColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn14 = QueryAddColumn(qryBillbackHeader, "SELBTNBGCOLOR", arrBBDev)>    

  <cfif (qGetBBDevColorSetting.SelBtnFontColor NEQ "")>
    <cfset arrBBDev[1] = '0x' & qGetBBDevColorSetting.SelBtnFontColor>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn15 = QueryAddColumn(qryBillbackHeader, "SELBTNFONTCOLOR", arrBBDev)>          

  <!--- START: D28359: BB Dev - user can only approve expected/ Anand Rao/10-Jan-2012 --->
  
  <cfif (Get_Profile_Settings.BB_DevGrid_Expected EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_DevGrid_Expected>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn16 = QueryAddColumn(qryBillbackHeader, "PROFILE_BB_DEVGRID_EXPECTED", arrBBDev)>
  
  <cfif (Get_Profile_Settings.BB_DevGrid_ELT EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_DevGrid_ELT>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn17 = QueryAddColumn(qryBillbackHeader, "PROFILE_BB_DEVGRID_ELT", arrBBDev)>
  
  <cfif (Get_Profile_Settings.BB_DevGrid_Claimed EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_DevGrid_Claimed>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn18 = QueryAddColumn(qryBillbackHeader, "PROFILE_BB_DEVGRID_CLAIMED", arrBBDev)>
  
  <cfif (Get_Profile_Settings.BB_DevGrid_Selected EQ 1)>
    <cfset arrBBDev[1] = Get_Profile_Settings.BB_DevGrid_Selected>
  <cfelse>
    <cfset arrBBDev[1] = 0 />
  </cfif>
  <cfset addColumn19 = QueryAddColumn(qryBillbackHeader, "PROFILE_BB_DEVGRID_SELECTED", arrBBDev)>
  <!--- END: D28359: BB Dev - user can only approve expected/ Anand Rao/10-Jan-2012 --->  
  
  <!---  START: D30798: BBK Deviation grid allows partial cases in the manual volume field/Anand Rao/08-Mar-2012 --->
  <cfset arrBBDev[1] = appSettings.BB_FRACTIONAL_VOLUME>
  <cfset addColumn20 = QueryAddColumn(qryBillbackHeader, "BB_FRACTIONAL_VOLUME", arrBBDev)>
  
  <!---  END: D30798: BBK Deviation grid allows partial cases in the manual volume field/Anand Rao/08-Mar-2012 --->
  
	<cfset arrBBDev[1] = appSettings.BB_LS_CLAIMED_REBATE_EXPECTED>
	<cfset QueryAddColumn(qryBillbackHeader, "BB_LS_CLAIMED_REBATE_EXPECTED", arrBBDev)>
  
	<!--- START: 36746: Billback Deviation & Summary - Add Operator to the display/Anand Rao/22-Apr-2013  --->
	<cfset arrBBDev[1] = appSettings.VIEW_OPERATOR_IN_BILLBACK_DEVIATION>
	<cfset QueryAddColumn(qryBillbackHeader, "VIEW_OPERATOR_IN_BILLBACK_DEVIATION", arrBBDev)>

	<cfset arrBBDev[1] = appSettings.BB_OVERLAP_DEVIATION_BASED_ON_OPERATOR>
	<cfset QueryAddColumn(qryBillbackHeader, "BB_OVERLAP_DEVIATION_BASED_ON_OPERATOR", arrBBDev)>
 	<!--- END: 36746: Billback Deviation & Summary - Add Operator to the display/Anand Rao/22-Apr-2013  --->

	<!--- START: D39421: Deviations Grid - Allow Manual values greater than Claimed/ Anand Rao/24-Sep-2013 --->
	<cfset arrBBDev[1] = appSettings.DEVIATION_GRID_ALLOW_MANUAL_VALUES_GT_CLAIMED>
	<cfset QueryAddColumn(qryBillbackHeader, "DEVIATION_GRID_ALLOW_MANUAL_VALUES_GT_CLAIMED", arrBBDev)>
	<!--- END: D39421: Deviations Grid - Allow Manual values greater than Claimed/ Anand Rao/24-Sep-2013 --->  

	<!--- START: 76536: BB Oper Location Level - dup check / Anand Rao / 24-Aug-2018 --->
	<cfset arrBBDev[1] = appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker')>
	<cfset QueryAddColumn(qryBillbackHeader, "BB_OPER_LOCATION_LEVEL_DUP_CHECKER", arrBBDev)>
	<!--- END: 76536: BB Oper Location Level - dup check / Anand Rao / 24-Aug-2018 --->

	
	<!--- START: 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->	
	<cfif (Get_Profile_Settings.View_Deviated_Items_Only_OnLoad EQ 1)>
	    <cfset arrBBDev[1] = Get_Profile_Settings.View_Deviated_Items_Only_OnLoad>
	<cfelse>
	   <cfset arrBBDev[1] = 0 />
	</cfif>
	<cfset QueryAddColumn(qryBillbackHeader, "PROFILE_VIEW_DEVIATED_ITEMS_ONLY_ONLOAD", arrBBDev)>
  	<!--- END: 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->	
	
	<!--- START: 81080: BB Deviation Grid - Show "Count" column --->	
	<cfif (Get_Profile_Settings.View_Count_Column_In_Deviation_Grid EQ 1)>
	    <cfset arrBBDev[1] = Get_Profile_Settings.View_Count_Column_In_Deviation_Grid>
	<cfelse>
	   <cfset arrBBDev[1] = 0 />
	</cfif>
	<cfset QueryAddColumn(qryBillbackHeader, "PROFILE_VIEW_COUNT_COLUMN_IN_DEVIATION_GRID", arrBBDev)>
  	<!--- END: 81080: BB Deviation Grid - Show "Count" column --->		
  <cfreturn qryBillbackHeader />
  
  </cffunction>

	<!--- Below function (getBillbackData) is used by AG Grid to load deviation data. A similar function (getBillbackDetails)
	is being called is being called for "Flex" below.
	--->
   <cffunction name="getBillbackData" hint="return all products" access="remote" output="false" returntype="any">
    <cfargument name="BBID" default="0">
     
     <cfquery name="qryBillbackId" datasource="#application.datasource#">
	    
	    SELECT	
	      Billback.Billback_ID as BBID
	    FROM	Billback	
	    WHERE
				<cfif len(arguments.BBID) eq 36>
					Billback.Billback_ID = '#arguments.BBID#'
    			<cfelse>
    				Billback.Billback_ID_Int = '#arguments.BBID#'
				</cfif>
	 </cfquery>
     <!--- Refer Email from Deepa Fri 8/7/2009 3:24 PM --->
    <cfstoredproc procedure="BB_Update_Count_Flag" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#qryBillbackId.BBID#">      
		  <cfprocresult name="qryUpdateCountFlag">  
    </cfstoredproc>

    <cfstoredproc procedure="BB_Populate_Approval_Tables" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" null="no" value="#qryBillbackId.BBID#">      
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Override_Volume" null="no" value="0">      
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Override_Rate"   null="no" value="0">      
  		<cfprocresult name="qryPopulateApprovalTables">  
    </cfstoredproc> 
     
    
     <cfstoredproc procedure="BB_Claimed_Expted_Selected_DTL" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#qryBillbackId.BBID#">  
	  <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@HTML_Code" null="no" value="1">
		  <cfprocresult name="qryDeviationData">  
    </cfstoredproc>
    
 
    <cfreturn qryDeviationData />
  </cffunction>
  
  <!--------------------------------------------------------------------------- 
  *****************************************************************************
    This function calls the Main stored procedure BB_Claimed_Expted_Selected_DTL 
    by passing the Billback_ID and returns to result to the Flex tool for 
    manipulation.
	A similar function (getBillbackData) is being called is being called for "AG grid" above.
  *****************************************************************************    
  ----------------------------------------------------------------------------->
  <cffunction name="getBillbackDetails" hint="return all products" access="remote" output="false" returntype="any">
    <cfargument name="BBID" default="0">
     
     <cfquery name="qryBillbackId" datasource="#application.datasource#">
	    
	    SELECT	
	      Billback.Billback_ID as BBID
	    FROM	Billback	
	    WHERE
				<cfif len(arguments.BBID) eq 36>
					Billback.Billback_ID = '#arguments.BBID#'
    			<cfelse>
    				Billback.Billback_ID_Int = '#arguments.BBID#'
				</cfif>
	 </cfquery>
     <!--- Refer Email from Deepa Fri 8/7/2009 3:24 PM --->
    <cfstoredproc procedure="BB_Update_Count_Flag" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#qryBillbackId.BBID#">      
		  <cfprocresult name="qryUpdateCountFlag">  
    </cfstoredproc>
    <!--- 
      This stored procedure was moved from updateBBDeviations cffunction to 
      here as per Ana's request on 28-Sep-09
    ---> 
    <cfstoredproc procedure="BB_Populate_Approval_Tables" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" null="no" value="#qryBillbackId.BBID#">      
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Override_Volume" null="no" value="0">      
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Override_Rate"   null="no" value="0">      
  		<cfprocresult name="qryPopulateApprovalTables">  
    </cfstoredproc> 
    <!--- BB_Deviation_Data was called ealier --->       
 	<!--- 
		36593	Billback Optimization - Deviation grid SP calls/27-Feb-2013/Anand Rao
		Set iDone = 1 when expected amount is greater than claimed amount In the SP
		Hence commenting this code so that the SP will be called only once.
	--->
	<!---     <cfstoredproc procedure="BB_Claimed_Expted_Selected_DTL" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" null="no" value="#qryBillbackId.BBID#">      
		 <cfprocresult name="qryDeviationData1">  
    </cfstoredproc> --->
       
    <!--- 
      adding this solution for now should be discussed with ANA and see if this could be done during the 
      insert into BB_Item_Invoice_Level table
    --->
 <!--- 
    <cfloop query="qryDeviationData1">
      <cfif (qryDeviationData1.iDone EQ 0)>
       <!--- <cfif (qryDeviationData1.Claimed_Amount EQ qryDeviationData1.Final_Payment)> 
       // Expected_Amount was Final_Payment earlier.  This was changed after the discussion with
  		// Paul on  22-Oct-09
       --->
        <cfif (qryDeviationData1.Expected_Amount GTE qryDeviationData1.Claimed_Amount)>
          <cfquery name="qryUpdiDone" datasource="#application.datasource#">
            UPDATE BB_Item_Invoice_Level
            SET iDone = 1
           WHERE   
              BB_Item_Invoice_Level_ID = <cfqueryparam value="#qryDeviationData1.SrNo#" cfsqltype="CF_SQL_VARCHAR">
          </cfquery>
        </cfif>
      </cfif>
    </cfloop> --->
    
     <cfstoredproc procedure="BB_Claimed_Expted_Selected_DTL" datasource="#application.datasource#">
      <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#qryBillbackId.BBID#">  
		  <cfprocresult name="qryDeviationData">  
    </cfstoredproc>
    
<!---    <cfdump var="#qryDeviationData#" output="C:\qryDeviationData.txt"  />  --->
 
    <cfreturn qryDeviationData />
  </cffunction>
  
  <!--------------------------------------------------------------------------- 
  *****************************************************************************
    This function updates all the rows recursively in the tables calculating
    the appropriate values.
  *****************************************************************************    
  ----------------------------------------------------------------------------->

    <!--- Function being called from the "AG Grid" deviation screen --->
	<cffunction name="updateBBDeviationsJSON" access="remote" output="false" returnFormat="json">
		<cfargument name="Billback_ID" default="" />
		<cfargument name="userId" default="" />
		<cfargument name="updateBBDev" type="any" />
		<cfargument name="strAction" default="doSave" />
		<cfargument name="ApprovalButton" default="" />

		<cfset local.reply      = {}>
		<cfset local.reply.STRMESSAGE = updateBBDeviations(arguments.Billback_ID,arguments.userId,deserializeJson(updateBBDev),arguments.strAction,arguments.ApprovalButton)>
	
		<cfreturn serializeJSON(local.reply, "struct")>

	</cffunction>

    <cffunction name="updateBBDeviations" Hint = "NEWSAVE to update the data changed " access="remote" output="true" returntype="any">
   
      <cfargument name="Billback_ID" default="" />
      <cfargument name="userId" default="" />
	  <cfargument name="updateBBDev" type="array" />
      <cfargument name="strAction" default="doSave" />
      <cfargument name="ApprovalButton" default="" />


	  
      <!--- cflog text="updateBBDeviations A :; #Billback_ID# :: #userId# :: #strAction#" --->
<!--- <cfdump var="#updateBBDev#" output="C:\data.html"  /> --->
      
      <!--- Variable declarations --->
      <cfset strApprovedRate     = 0.0 />
      <cfset strManualAmount     = 0.0 />
      <cfset strLBVol            = 0 />
      <cfset iSelVol             = 0 />
      <cfset strCSVol            = 0 />
      <cfset errorFlag           = 0 />
      <cfset iSelRateType        = 0 />
      <cfset iSelRateValueCS     = 0 />
      <cfset iSelRateValueLB     = 0 /> 
      <cfset iSelRateValueUK     = 0 />  
      <cfset iSelProgramPriceType    = 0 />
      <cfset iSelProgramPriceValueUK    = 0 />
      <cfset iSelProgramPriceValueCS  = 0 />
      <cfset iSelProgramPriceValueLB  = 0 />
      <cfset iSelInvoicePriceType    = 0 />
      <cfset iSelInvoicePriceValueUK    = 0 />
      <cfset iSelInvoicePriceValueCS    = 0 />
      <cfset iSelInvoicePriceValueLB    = 0 />        
      <cfset iManualInvoicePriceUK = 0 />
      <cfset iManualInvoicePriceCS = 0 />
      <cfset iManualInvoicePriceLB = 0 />  
      <cfset iManualProgramPriceUK = 0 />
      <cfset iManualProgramPriceCS = 0 />
      <cfset iManualProgramPriceLB = 0 />   	   
      <cfset iFinalPayment = 0 />
      <cfset bVolumeOverride = 0 />
      <cfset bRateOverride = 0 />
      <cfset nInvMinusPgmPrice = 0 />
      <cfset strCaughtError = "" />
      <cfset iPgmPrice = 0 />
      <cfset iSelInvoicePriceValue = 0 />
      <cfset iManualRate = 0 />      
      <cfset iManualRateCS = 0 />
      <cfset iManualRateLB = 0 />
      
      <!--- Added for manual Volume --->        
      <cfset iManualVol = 0 />      
      <cfset iManualVolCS = 0 />
      <cfset iManualVolLB = 0 />
   
     <cfif len(arguments.Billback_ID) neq 36>
	 	 <cfset useLakebaseForqrygetBillbackID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqrygetBillbackID>
	<cftry>
		<cfset qrygetBillbackID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id_int" = "eq.#arguments.Billback_ID#",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetBillbackID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetBillbackID>
<cfquery name="qrygetBillbackID" datasource="#application.datasource#">
		  SELECT Billback_ID
		  FROM Billback 
		  WHERE billback_ID_Int = '#arguments.Billback_ID#'
		</cfquery>
</cfif>
		
		<cfset arguments.Billback_ID = qrygetBillbackID.Billback_ID />
		<!--- cflog text="updateBBDeviations B :: #arguments.Billback_ID# ::" --->
	</cfif>
	
	<!--- Save which button did did the user actually click on - claimed,expected,selected etc --->
	<cfquery name="qrygetBillbackID" datasource="#application.datasource#">
	  UPDATE Billback_Allied
	  SET Approval_Button = '#arguments.ApprovalButton#'
	  WHERE 
  	      Billback_id = '#arguments.Billback_ID#'
	</cfquery>

      <cfset iBBDevOverridePrice = appSettings.BB_DEVIATIONS_OVERRIDE_PRICE />
      <cfoutput> 
        <!--- 
        In case the user A opened the Grid and left it and some user B unlocked 
        User A and made changes to the Grid and saved it.  Then User A should 
        not be able to make any changes to the grid.
      --->
        <cfset useLakebaseForqryBillbackLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForqryBillbackLocked>
	<cftry>
		<cfset qryBillbackLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"select" = "bb_locked_by_user_id,bb_is_locked"
			}), "bb_locked_by_user_id,bb_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryBillbackLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryBillbackLocked>
<cfquery name="qryBillbackLocked" datasource="#application.datasource#">
          SELECT BB_LOCKED_BY_USER_ID,BB_IS_LOCKED 
          FROM Billback_Allied
  	      WHERE 
  	      Billback_id = '#arguments.Billback_ID#'
        </cfquery>
</cfif>
        <!--- cflog text="qryBillbackLocked ::quid #qryBillbackLocked.BB_LOCKED_BY_USER_ID# :: u #arguments.userId# :: bbid #arguments.Billback_ID#" --->
		<!---
        <cfif (qryBillbackLocked.BB_LOCKED_BY_USER_ID NEQ arguments.userId)><!---  AND (qryBillbackLocked.BB_IS_LOCKED EQ 1) --->
          <cfset errorFlag = 1 />
       <!---    <cfset strCaughtError = "The Billback has been locked by another User now.  Kindly close this window and retry later." /> --->
        </cfif> 
       --->
        <!--- <cfdump var="#arguments.updateBBDev#" output="C:\test.html"  />  --->
       
   <cfif  (errorFlag NEQ 1)> 
    <cftry>
       <cfset useLakebaseForGetFormInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetFormInfo>
	<cftry>
		<cfset GetFormInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"select" = "billback_payee_type_id,billback_status_id,bb_amount,totaltaxamount,scheduled_auto_bb,bb_amount,bb_deviations_override_price as bb_level_deviations_override_price_flag"
			}), "billback_payee_type_id,billback_status_id,bb_amount,totaltaxamount,scheduled_auto_bb,bb_amount,bb_deviations_override_price as bb_level_deviations_override_price_flag"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFormInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFormInfo>
<cfquery name="GetFormInfo" datasource="#application.datasource#">
      SELECT Billback_Payee_Type_ID, Billback_Status_ID, BB_Amount, TotalTaxAmount, Scheduled_Auto_BB, BB_Amount, BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
      FROM Billback
      WHERE Billback_ID = '#arguments.Billback_ID#'
    </cfquery>
</cfif>
	
	<cfif GetFormInfo.BB_Level_Deviations_Override_Price_Flag eq 1>
		<cfset iBBDevOverridePrice = 1 />
	</cfif>
	
    <!--- 
      21923: Added the condition for updating the Approval_Type flag when in RFA status and 
      for already approved Billback 
      On update of approved BB (When the BB is in approved status) set BB_Approved.Approval_Type = 3, Approval_Updated_By and Approval_Updated_Date 
    --->

    <cfif (GetFormInfo.Billback_Status_ID EQ 3)>
      <cfquery name="updBBApproved" datasource="#application.datasource#">
	      UPDATE BB_Approved
	      SET Approval_Type = 3,
          Approval_Updated_By = '#arguments.userId#'<!--- <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="CF_SQL_VARCHAR"> --->,
          Approval_Updated_Date = GetDate()
        WHERE 
         Billback_ID = '#arguments.Billback_ID#'
      </cfquery>
    </cfif>
    
      <cfloop from="1" to="#ArrayLen(updateBBDev)#" index="i" step="1"> 
        <cfif (updateBBDev[i].E_Volume EQ "")>
          <cfset varE_Volume = 0 />
        <cfelse>
          <cfset varE_Volume = updateBBDev[i].E_Volume />
        </cfif>
        <!--- Count Flag checking and updating --->
        <cfif ((updateBBDev[i].count_Flag EQ "YES") OR (updateBBDev[i].count_Flag EQ "1") OR (updateBBDev[i].count_Flag EQ "true"))>
          <cfset bCountFlag = 1 />
        <cfelse>
          <cfset bCountFlag = 0 />       
        </cfif>
      
        <!--- START: VOLUME COLUMNS MANIPULATION --->
          <!--- Added for Manual Volume Start --->
        <cfif (updateBBDev[i].Selected_Vol_Type EQ "3")>
            <!--- A value of 3 gets saved in the database if Expected is selected for volume --->
            <cfset iSelVol = "3" />
            <!--- Expected has been selected --->
            <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
              <!--- Cases --->
               <cfset strCSVol = updateBBDev[i].Manual_Vol  />
               <cfset iManualVolCS = updateBBDev[i].Manual_Vol />
               <cfset strLBVol = val(updateBBDev[i].Manual_Vol) * updateBBDev[i].Net_Weight/>
               <cfset iManualVolLB = val(updateBBDev[i].Manual_Vol) * updateBBDev[i].Net_Weight/>
            <cfelseif (updateBBDev[i].Claimed_Volume_UOM EQ "2")>
              <!--- Pounds --->
               <cfset strLBVol = updateBBDev[i].Manual_Vol />
               <cfset iManualVolLB = updateBBDev[i].Manual_Vol />
               <cfset strCSVol = updateBBDev[i].Manual_Vol/updateBBDev[i].Net_Weight  />
               <cfset iManualVolCS = updateBBDev[i].Manual_Vol/updateBBDev[i].Net_Weight  />               
            </cfif>
            <!--- Added for Manual Volume End --->
        <cfelseif (updateBBDev[i].Selected_Vol_Type EQ "2")>
            <!--- A value of 2 gets saved in the database if Expected is selected for volume --->
            <cfset iSelVol = "2" />
            <!--- Expected has been selected --->
            <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
              <!--- Cases --->
               <cfset strCSVol = varE_Volume  />
               <cfset strLBVol = val(varE_Volume) * updateBBDev[i].Net_Weight/>
            <cfelseif (updateBBDev[i].Claimed_Volume_UOM EQ "2")>
              <!--- Pounds --->
               <cfset strLBVol = varE_Volume />
               <cfset strCSVol = varE_Volume/updateBBDev[i].Net_Weight  />
            </cfif>
          <cfelse>
            <!--- A value of 1 gets saved in the database if Claimed is selected for volume --->
            <cfset iSelVol = "1" />
            <!--- Claim has been selected --->
            <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
              <!--- Cases --->
               <cfset strCSVol = updateBBDev[i].Claimed_Volume />
               <cfset strLBVol = updateBBDev[i].Claimed_Volume * updateBBDev[i].Net_Weight/>
            <cfelseif (updateBBDev[i].Claimed_Volume_UOM EQ "2")>
              <!--- Pounds --->
               <cfset strLBVol = updateBBDev[i].Claimed_Volume />
               <cfset strCSVol = updateBBDev[i].Claimed_Volume/updateBBDev[i].Net_Weight  />
            </cfif>
        </cfif>
       <!--- END: VOLUME COLUMNS MANIPULATION --->
       
       <!--- START: RATE COLUMNS MANIPULATION--->
        <!--- Editable_Rate =1 means that the Rate column has a Radio button and is selectable--->  
        <cfif (updateBBDev[i].Editable_Rate EQ 1)>
          <cfif (updateBBDev[i].Selected_Rate_Type EQ 1)>
            <!--- Claim was selected --->            
            <cfset iSelRateType = 1 />
            <cfset iSelRateValueUK = updateBBDev[i].Claimed_Rate />
          <cfelseif (updateBBDev[i].Selected_Rate_Type EQ 2)>
            <!--- Expected was selected --->
            <cfset iSelRateType = 2 />
            <cfset iSelRateValueUK = updateBBDev[i].E_Rate />
          <cfelseif (updateBBDev[i].Selected_Rate_Type EQ 3)>
           <cfset iSelRateType = 3 />
            <cfset iSelRateValueUK = updateBBDev[i].Manual_Rate />
          <cfelse>
            <!--- Expected was selected --->
            <cfset iSelRateType = 6 />
            <cfset iSelRateValueUK = updateBBDev[i].ELT_Rate />
          </cfif>
          <cfif isNumeric(iSelRateValueUK) EQ False>
	  		<cfset iSelRateValueUK = 0 />
		  </cfif>
          <!--- Now based on the UOM we Assign/Calulcate the CS and LB values --->
          <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
            <cfset iSelRateValueCS = iSelRateValueUK />
            <cfset iSelRateValueLB = iSelRateValueCS/updateBBDev[i].Net_Weight  />
          <cfelseif (updateBBDev[i].Claimed_Volume_UOM EQ "2")>
            <cfset iSelRateValueLB = iSelRateValueUK />
            <cfset iSelRateValueCS = val(iSelRateValueLB) * updateBBDev[i].Net_Weight />
          </cfif>
          <cfif (updateBBDev[i].Selected_Rate_Type EQ 3)>
            <cfset iManualRateCS = iSelRateValueCS />
            <cfset iManualRateLB = iSelRateValueLB />
          </cfif>
          
          
          
       <cfelse>
        <!--- Editable_Rate=0 means that the Rate column had no Radio button and is display only--->  
          <cfif (updateBBDev[i].Selected_Invoice_Price_Type EQ "1")>
            <!--- user picked Claimed hence assign the value of Claimed invoice price --->
            <cfset iSelInvoicePriceType = 1 />
            <cfset iSelInvoicePriceValueUK = updateBBDev[i].Claim_Invoice_Price />
          <cfelseif (updateBBDev[i].Selected_Invoice_Price_Type EQ "2")>
            <!--- user picked Expected hence assign the value of Expected invoice price --->
            <cfset iSelInvoicePriceType = 2 />
            <cfset iSelInvoicePriceValueUK  = updateBBDev[i].Expected_Invoice_Price />
          <cfelseif (updateBBDev[i].Selected_Invoice_Price_Type EQ "3")>
            <!--- user Entered a value for the invoice price so pick that --->
            <cfset iSelInvoicePriceType = 3 />
            <cfset iSelInvoicePriceValueUK = updateBBDev[i].Manual_Invoice_Price />
            <cfset iManualInvoicePriceUK  = updateBBDev[i].Manual_Invoice_Price />
          </cfif>
          <!--- GET THE PROGRAM PRICE --->
          <cfif (updateBBDev[i].Selected_Program_Price_Type EQ "2")>
              <cfset iSelProgramPriceType = 2 />
              <cfset iPgmPrice = updateBBDev[i].Expected_Program_Price />
		  <cfelseif (updateBBDev[i].Selected_Program_Price_Type EQ "3")>
            <!--- user Entered a value for the invoice price so pick that --->
            <cfset iSelProgramPriceType = 3 />
            <cfset iSelProgramPriceValueUK = updateBBDev[i].Manual_Program_Price />
            <cfset iManualProgramPriceUK  = updateBBDev[i].Manual_Program_Price />
			<cfset iPgmPrice = updateBBDev[i].Manual_Program_Price />
          <cfelse>
              <cfset iSelProgramPriceType = 1 />
              <cfset iPgmPrice = updateBBDev[i].Claimed_Program_Price />
          </cfif>   
          
          <!--- Check if the selected invoice price is Expected or claimed --->
          <cfif ((updateBBDev[i].Selected_Invoice_Price_Type EQ "1") OR (updateBBDev[i].Selected_Invoice_Price_Type EQ "2"))>
            <!--- Assign the value of the selected type to the invoice price variable --->
            <cfset iSelInvoicePriceValue = iSelInvoicePriceValueUK />
          <cfelse>
            <!--- Assign the value of the manually entered invoice price to variable --->
            <cfset iSelInvoicePriceValue = iManualInvoicePriceUK />
          </cfif>
 
          <!--- Calculate the Rate value by subtractive the program price from the invoice price --->

          <cfset Rate_UnknownUOM = iSelInvoicePriceValue - iPgmPrice />

         <!---
          <cfif (Rate_UnknownUOM LT 0)>
            <cfset Rate_UnknownUOM = 0 />
          </cfif>
         ---> 
             <!--- If UOM is case then assign the value to CS variable for rate --->
          <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
            <cfset iSelRateValueCS = Rate_UnknownUOM />
            <cfset iSelRateValueLB = iSelRateValueCS/updateBBDev[i].Net_Weight  />
          <cfelse>
             <!--- If UOM is pounds then assign the value to LB variable for rate --->
            <cfset iSelRateValueLB = Rate_UnknownUOM />
             <cfset iSelRateValueCS = val(iSelRateValueLB) * updateBBDev[i].Net_Weight />
          </cfif>
        </cfif> 
       
       <!--- END: RATE COLUMNS MANIPULATION--->
           
        <!--- 
        Calculating the Final Payment Here as we are having problems with item 
        renderer when it is updating the value.
        --->
       <!---  <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")> --->
          <cfif (updateBBDev[i].BB_Product_Type_ID EQ "1" AND updateBBDev[i].Editable_Rate EQ "0")>
          <!--- 
            Dev Notes: Anand Rao/21628/14-Dec-09 
                       Added this condition so that the value what is shown in the Final Payment 
                       in the Grid gets saved in the DB also.
           --->
          <cfset nInvMinusPgmPrice = iSelInvoicePriceValueUK - iPgmPrice />
          <cfif (nInvMinusPgmPrice LT 0)>
            <cfset nInvMinusPgmPrice = 0 />
          </cfif>
          
            <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
                <cfset iFinalPayment = nInvMinusPgmPrice * strCSVol />
            <cfelse>   
                <cfset iFinalPayment = nInvMinusPgmPrice * strLBVol  />
            </cfif>
          <cfelse>
            <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
                <cfset iFinalPayment = iSelRateValueUK * strCSVol />
            <cfelse>   
                <cfset iFinalPayment = iSelRateValueUK * strLBVol  />
            </cfif>
          </cfif>
      <!--- Query to update the DB with the values --->
        <cfset variDone = 0 />
        <cfif updateBBDev[i].iDone EQ 1>
          <cfset variDone = 2 />
        <cfelse>
          <cfset variDone = updateBBDev[i].iDone />
        </cfif>
        
<!--- 
  For Third Party upload = "Combo":
  If the record is a dummy program or of UnKnown_item type them set them to expected
  and Final_Payment to 0
 --->
        <cfif ((updateBBDev[i].Third_Party_BB_Upload EQ 3) AND ((updateBBDev[i].Dummy_Program EQ 1) OR (updateBBDev[i].UnKnown_Item EQ 1)))>
          <cfset iFinalPayment = 0 />
          <cfset iSelVol = 2 />
          <cfset iSelRateType = 2 />
          <cfset iSelInvoicePriceType = 2 />
          <cfset iSelProgramPriceType = 2 />
    			
    		  <cfset strCSVol = 0 />
    		  <cfset strLBVol = 0 />
    		  <cfset iSelRateValueCS = 0 />
    		  <cfset iSelRateValueLB = 0 />
        </cfif>  

      <!---  Start: 21935/Anand Rao/08-Jan-10: Solo Prd - Total apprvd amt does not equal interface & summ statement --->
      <cfif ((iPgmPrice GT iSelInvoicePriceValue) OR (iFinalPayment EQ 0))>
        <cfset iSelRateValueCS = 0 />
        <cfset iSelRateValueLB = 0 />
       </cfif>  
      <!---  End 21935 --->
                
        
     <!---    <cfset iManualRate = updateBBDev[i].Manual_Rate />       --->
                
<cfif ((updateBBDev[i].Denied EQ 0) OR (updateBBDev[i].Denied EQ ""))>
        <cfquery name="qryUpdBBItemInvoiceLevel" datasource="#application.datasource#">
          UPDATE BB_Item_Invoice_Level
            SET Updated_By = '#arguments.userId#',
				        Updated_Date = getdate(),
                Selected_Vol_Type = <cfqueryparam value="#iSelVol#" cfsqltype="CF_SQL_INTEGER">
                ,Selected_Vol_CS = <cfqueryparam value="#strCSVol#" cfsqltype="CF_SQL_FLOAT"> 
                ,Selected_Vol_LB = <cfqueryparam value="#strLBVol#" cfsqltype="CF_SQL_FLOAT"> 
                ,Selected_Rate_CS = <cfqueryparam value="#iSelRateValueCS#" cfsqltype="CF_SQL_FLOAT"> 
                ,Selected_Rate_LB = <cfqueryparam value="#iSelRateValueLB#" cfsqltype="CF_SQL_FLOAT"> 
                <cfif (updateBBDev[i].Editable_Rate EQ 1)>
                  ,Selected_Rate_Type = <cfqueryparam value="#iSelRateType#" cfsqltype="CF_SQL_INTEGER">
                  ,Selected_Invoice_Price_Type = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true"> 
                  ,Selected_Program_Price_Type = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                <cfelse>
                  ,Selected_Rate_Type = <cfqueryparam value="4" cfsqltype="CF_SQL_INTEGER"> 
                  ,Selected_Invoice_Price_Type = <cfqueryparam value="#iSelInvoicePriceType#" cfsqltype="CF_SQL_FLOAT"> 
                  ,Selected_Program_Price_Type = <cfqueryparam value="#iSelProgramPriceType#" cfsqltype="CF_SQL_FLOAT"> 
                </cfif>
                <cfif (updateBBDev[i].Selected_Invoice_Price_Type EQ 3)>
                  <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
                    ,Manual_Invoice_Price_CS = <cfqueryparam value="#iManualInvoicePriceUK#" cfsqltype="CF_SQL_FLOAT"> 
                    ,Manual_Invoice_Price_LB = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                  <cfelse>
                    ,Manual_Invoice_Price_CS = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                    ,Manual_Invoice_Price_LB = <cfqueryparam value="#iManualInvoicePriceUK#" cfsqltype="CF_SQL_FLOAT"> 
                  </cfif>
                <cfelse>
                ,Manual_Invoice_Price_CS = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                ,Manual_Invoice_Price_LB = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
              </cfif>
                <cfif (updateBBDev[i].Selected_Program_Price_Type EQ 3)>
                  <cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
                    ,Manual_Program_Price_CS = <cfqueryparam value="#iManualProgramPriceUK#" cfsqltype="CF_SQL_FLOAT"> 
                    ,Manual_Program_Price_LB = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                  <cfelse>
                    ,Manual_Program_Price_CS = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                    ,Manual_Program_Price_LB = <cfqueryparam value="#iManualProgramPriceUK#" cfsqltype="CF_SQL_FLOAT"> 
                  </cfif>
                <cfelse>
                ,Manual_Program_Price_CS = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
                ,Manual_Program_Price_LB = <cfqueryparam value="NULL" cfsqltype="CF_SQL_FLOAT" null="true">
              </cfif>

			  
              <!--- DONE: iManualRate should have iManualRateCS and iManaualRateLB and should be assigned below --->
              <cfif (updateBBDev[i].Selected_Rate_Type EQ 3)>
                ,Manual_Rate_CS =   <cfqueryparam value="#iManualRateCS#" cfsqltype="CF_SQL_FLOAT">               
                ,Manual_Rate_LB =   <cfqueryparam value="#iManualRateLB#" cfsqltype="CF_SQL_FLOAT">            
              </cfif>   
              <!--- Manual Volume Changes START --->
               <cfif (updateBBDev[i].Selected_Vol_Type EQ "3")>
                ,Manual_Vol_LB =   <cfqueryparam value="#iManualVolLB#" cfsqltype="CF_SQL_FLOAT">               
                ,Manual_Vol_CS =   <cfqueryparam value="#iManualVolCS#" cfsqltype="CF_SQL_FLOAT">            
              </cfif>   
              <!--- Manual Volume Changes END--->
              ,count_Flag = <cfqueryparam value="#bCountFlag#" cfsqltype="CF_SQL_BIT">
			  <!--- 
			  		44029: Deviation Grid Final Payment rounding issue/Anand Rao/29-Jul-2014
			  		Made the code change for the Final payment as there was rounding issue and it was causing a 
					mismatch in the total that was calculated using SQL and hence the BB was getting stuck in the interface.
					When the CAST was used it was not rounding the iFinalPayment, if it was value was 16.214999, it was rounding as 16.21 and not 16.22.
			   --->
			  <cfif (updateBBDev[i].BB_Product_Type_ID EQ "1" AND updateBBDev[i].Editable_Rate EQ "0")>
			  	,Final_Payment = CAST(#iFinalPayment# AS DECIMAL(18,2)) <!--- <cfqueryparam value="#iFinalPayment#" cfsqltype="CF_SQL_FLOAT">  --->
			  <cfelse>
				<cfif (updateBBDev[i].Claimed_Volume_UOM EQ "1")>
					,Final_Payment = CAST(CAST(#iSelRateValueUK# as decimal(24, 9)) * cast(#strCSVol# as decimal(20, 4)) AS DECIMAL(18,2)) 
				<cfelse>   
					,Final_Payment = CAST(CAST(#iSelRateValueUK# as decimal(24, 9)) * cast(#strLBVol# as decimal(20, 4)) AS DECIMAL(18,2)) 
            	</cfif>
			  </cfif>
			 <!--- updateBBDev[i].Final_Payment --->   
              ,iDone = <cfqueryparam value="#variDone#" cfsqltype="CF_SQL_INTEGER">
               <!--- Volume override update --->
              <cftry>
                <cfif (updateBBDev[i].Volume_Override EQ 1)>
                  ,Volume_Override = <cfqueryparam value="#updateBBDev[i].Volume_Override#" cfsqltype="CF_SQL_BIT">
                  ,Allocated_Expected_CS = Claimed_CS
                  ,Allocated_Expected_LB = Claimed_LB
                </cfif>
                <cfcatch>
                  <!--- The only possibility of an error happening is that the Volume_Override was not present in the Array--->
                </cfcatch>
              </cftry>
              <cftry>
               <cfif (updateBBDev[i].Rate_Override EQ 1)>
                ,Rate_Override =  <cfqueryparam value="#updateBBDev[i].Rate_Override#" cfsqltype="CF_SQL_BIT">
                ,Expected_Rate_CS = Claimed_Rate_CS
                ,Expected_Rate_LB = Claimed_Rate_LB
               </cfif> 
               <cfcatch>
                  <!--- The only possibility of an error happening is that the Rate_Override was not present in the Array--->
                </cfcatch>
              </cftry>  
            WHERE   
              BB_Item_Invoice_Level_ID = <cfqueryparam value="#updateBBDev[i].SrNo#" cfsqltype="CF_SQL_VARCHAR">

        </cfquery>
	</cfif>		
        <cfset bVolumeOverride = updateBBDev[i].Volume_Override />
        <cfset bRateOverride   = updateBBDev[i].Rate_Override />
      </cfloop> 
      <!-----------------------------------------------------------------------
        Call the BB_Volume_Override_Update if Volume_Override = 1 OR 
        Rate_Override = 1
      ------------------------------------------------------------------------>  
     <!---  <cfif ((bVolumeOverride EQ 1) OR (bRateOverride EQ 1))>
        <cfstoredproc procedure="BB_Volume_Override_Update" datasource="#application.datasource#">
          <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@Billback_ID" null="no" value="#arguments.Billback_ID#">      
          <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Volume_Override" null="no" value="#bVolumeOverride#">      
          <cfprocparam type = "IN" CFSQLType ="CF_SQL_BIT" dbVarName = "@@Rate_Override"   null="no" value="#bRateOverride#">      
  		    <cfprocresult name="BBVolumeOverrideUpdate">  
        </cfstoredproc>
      </cfif> --->
	
	<!--- When a user checks or unckhecks the ("Count Volume") checkbox from the deviation screen, save the selected option in the database. --->
	<cfquery NAME="updCountFlag" datasource="#application.datasource#">
		UPDATE Billback_product
		SET Count_Flag = BB_Item_Invoice_Level.Count_Flag
		FROM Billback_product
		INNER JOIN BB_Item_Invoice_Level
		ON BB_Item_Invoice_Level.Billback_product_id = Billback_product.Billback_product_id
		WHERE Billback_product.billback_id = '#arguments.Billback_ID#'
	</cfquery>

       <!-----------------------------------------------------------------------
        This should get executed only, if the strAction is doSaveApprove
      ------------------------------------------------------------------------>  
      <cfif (arguments.strAction EQ "doSaveApprove")>
          <cfstoredproc procedure="BB_Populate_Approval_Table_Update" datasource="#application.datasource#">
              <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#arguments.Billback_ID#">
              <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@User_ID" null="no" value="#arguments.userId#">      
              <cfprocresult name="qryBBPopulateApprovalTableUpdate">  
          </cfstoredproc>   
      </cfif>
 
      <!-----------------------------------------------------------------------
        This should get executed only, if the strAction is doSaveRecalc
        We need to call BB_Deviation_Run_All after saving to run the deviation
      ------------------------------------------------------------------------>  

  <cfif (arguments.strAction EQ "doSaveRecalc")>
	  <cfset useLakebaseForCheckUpdProgress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckUpdProgress>
	<cftry>
		<cfset CheckUpdProgress = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"select" = "bb_upd_inprogress"
			}), "bb_upd_inprogress"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckUpdProgress = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckUpdProgress>
<CFQUERY NAME="CheckUpdProgress" datasource="#application.datasource#">
			SELECT BB_Upd_InProgress
			FROM Billback
			WHERE Billback_ID = '#arguments.Billback_ID#'
		</CFQUERY>
</cfif>


    		<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>
            <cftry>
              <cflock timeout="3" type="Exclusive" name="#arguments.userid#_#arguments.Billback_ID#">
                    <cfset useLakebaseForupdBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"deviation_inprogress" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBillback>
<cfquery name="updBillback" datasource="#application.datasource#">
                        UPDATE Billback 
                        SET Deviation_InProgress = 1
                        WHERE Billback_ID = '#arguments.Billback_ID#'
                    </cfquery>
</cfif> 
                  <cfstoredproc procedure="BB_Deviation_Run_All" datasource="#application.datasource#">
                    <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" null="no" value="#arguments.Billback_ID#">      
                    <cfprocresult name="qryBBDeviationRunAll">  
                  </cfstoredproc> 
                
                    <cfset useLakebaseForgetDeviationHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetDeviationHistory>
	<cftry>
		<cfset getDeviationHistory = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"select" = "deviation_ran_by,deviation_ran_date,uploaded_billback,billback_status_id,bb_deviations_override_price as bb_level_deviations_override_price_flag"
			}), "deviation_ran_by,deviation_ran_date,uploaded_billback,billback_status_id,bb_deviations_override_price as bb_level_deviations_override_price_flag"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDeviationHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDeviationHistory>
<cfquery name="getDeviationHistory" datasource="#application.datasource#">
                       SELECT Deviation_Ran_By,
                              Deviation_Ran_Date,
                              Uploaded_Billback,
                              Billback_Status_ID,
                              Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
                       FROM Billback                
                       WHERE Billback_ID = '#arguments.Billback_ID#'
                    </cfquery>
</cfif>
                    
                    <cfquery name="updBillback" datasource="#application.datasource#">
                        UPDATE Billback 
                        SET 
                            Deviation_Ran_By = '#arguments.userId#',
                            Deviation_Ran_Date = getdate()
                        WHERE Billback_ID = '#arguments.Billback_ID#'
                    </cfquery>
                </cflock>
              <cfcatch>
                <cfif cfcatch.type EQ 'LOCK'>
                  <cfset errorFlag = 2 />
                  <cfset strCaughtError = "Type: DEVIATION LOCK" & " Message: Deviations are currently executing for this billback.  Please check back shortly to see if it has completed." />
                  <!--- STOP PROCESSING AND RETURN THE ERROR --->
                  <cfreturn strCaughtError />
                <cfelse>
                  <!--- FOR ANY REAL ERRORS, LET ERROR HANDLER DO IT's JOB --->
                  <cfrethrow/>
                </cfif>
              </cfcatch>
          </cftry> 
         		<!---
        		Rules for deleting entries from BB_Item_Invoice_Level
        		For client who do not allow editing of claimed amount and claimed quantity, only delete for WIP/RFA billbacks which are not third party upload 
        		For client who allow editing of claimed amount and claimed quantity, delete for any WIP/RFA billbacks		
        		--->
        		<cfif 
        			NOT(
        				(getDeviationHistory.Uploaded_Billback EQ 3 
        			 	AND (appSettings.getBB_Upload_III_P_Qty_Amt_Editable() EQ 0 OR getDeviationHistory.BB_Level_Deviations_Override_Price_Flag EQ 1))
        				OR
        				(getDeviationHistory.Uploaded_Billback EQ 2 
        			 	AND (appSettings.getEditableClaimedDollarsQuantity() EQ 0 OR getDeviationHistory.BB_Level_Deviations_Override_Price_Flag EQ 1))
        			 	)
        			 AND getDeviationHistory.Billback_Status_ID LT 3>
                    <cfquery name="delDeviationHistory" datasource="#application.datasource#">
                      DELETE FROM BB_Item_Invoice_Level
                      WHERE Billback_ID = '#arguments.Billback_ID#'
                    </cfquery>
            <cfelse>
                      <cfset useLakebaseForUpdBBItemInvoiceLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseForUpdBBItemInvoiceLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_invoice_level",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"volume_override" = "0",
				"rate_override" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdBBItemInvoiceLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdBBItemInvoiceLevel>
<cfquery name="UpdBBItemInvoiceLevel" datasource="#application.datasource#">
                          UPDATE BB_Item_Invoice_Level
                          SET Volume_Override = 0,
                              Rate_Override = 0
                          WHERE Billback_ID = '#arguments.Billback_ID#'
                      </cfquery>
</cfif>
            </cfif> 
    		  	<cfquery name="updBillback" datasource="#application.datasource#">
    	          UPDATE Billback 
    	          SET Deviation_InProgress = 0
    	          WHERE Billback_ID = '#arguments.Billback_ID#'
    	        </cfquery> 
        <cfelse>
    	  		   <cfset errorFlag = 3 />
        			<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 1>
        				<CFSET UpdMessage = "Basic Info update">
        			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 2>
        				<CFSET UpdMessage = "Payee Update">
        			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 3>
        				<CFSET UpdMessage = "Program Update">
        			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 4>
        				<CFSET UpdMessage = "Switch Program">
        			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 5>
        				<CFSET UpdMessage = "Switch Product">
        			</CFIF> 			
    	 </cfif><!--- <CFIF CheckUpdProgress.BB_Upd_InProgress NEQ 0> --->
	 </cfif> <!---  <cfif (arguments.strAction EQ "doSaveRecalc")> --->
      
    <cfcatch>
        <cfset errorFlag = 2 />
        <cfset strCaughtError = "Type: " & cfcatch.type & " Message: " & cfcatch.message & " Details: " & cfcatch.detail />
        <cfif (arguments.strAction EQ "doSaveRecalc") >
          <CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>
            <cfset useLakebaseForupdBillback_Deviation_InProgress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdBillback_Deviation_InProgress>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"deviation_inprogress" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBillback_Deviation_InProgress = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBillback_Deviation_InProgress>
<cfquery name="updBillback_Deviation_InProgress" datasource="#application.datasource#">
                UPDATE Billback 
                SET Deviation_InProgress = 0
                WHERE Billback_ID = '#arguments.Billback_ID#'
            </cfquery>
</cfif>
          </CFIF>
        </cfif>
		<cfrethrow>
    </cfcatch>
    </cftry>
  </cfif>     

     <!--------------------------------------------------------------------------- 
        This message will get returned to the Flex and be shown to the user as an alert 
        --->
		<CFSET strMessage = "">
      <cfif (errorFlag EQ 1)>
        <cfset strMessage = "1" />
      <cfelseif (errorFlag EQ 2)>
        <cfset strMessage = "Error Updating BB Data:  " & strCaughtError />        
      <cfelseif (errorFlag EQ 3)>
	  	<cfset strMessage =  UpdMessage & " is in progress. Cannot ReCalc Deviation. "  /> 
	  <cfelseif (arguments.strAction EQ "doSave")>   
	    <cfset strMessage = "Save Complete." />
	 <cfelseif (arguments.strAction EQ "doSaveRecalc")>   
	    <cfset strMessage = "Save and Recalc Complete." />
      </cfif>
     
      <cfreturn strMessage />
      </cfoutput>
    </cffunction>
	
	<!--- check if deviations should run --->
	<cffunction name="checkToRunDeviation" output="false" access="public" hint="Function to check if deviation should be run">
	
		<cfargument name="billbackId" required="true" type="string">

		<cfscript>
			//set local variables
			var strBillbackIdID	= "";
			var rRunDeviation	= 0;

			//assign local variables
			strBillbackIdID = arguments.billbackId;
		</cfscript>
	
		<!--- first check if deviation has run yet--->
		<cfquery name="qCheckIfDeviationRan" datasource="#application.datasource#">
			SELECT	*	
         	FROM 	Billback                
         	WHERE 	Billback_ID = '#strBillbackIdID#'
			AND		(Deviation_Ran_Date IS NULL OR LTRIM(RTRIM(Deviation_Ran_Date)) = '')
        </cfquery>
		
		<cfif qCheckIfDeviationRan.RecordCount>
			<cfset rRunDeviation = 1 />
		</cfif>
		
		<!--- if deviations have been run then check to see if billback has a lump sum component --->
		<cfif rRunDeviation eq 0>
			<cfset useLakebaseForqCheckForLumpSums = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_lumpsum_component")>
<cfif useLakebaseForqCheckForLumpSums>
	<cftry>
		<cfset qCheckForLumpSums = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program_lumpsum_component", {
				"billback_id" = "eq.#strBillbackIdID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckForLumpSums = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckForLumpSums>
<cfquery name="qCheckForLumpSums" datasource="#application.datasource#">
				SELECT	* 
				FROM 	Billback_Program_Lumpsum_Component 
				WHERE 	Billback_ID = '#strBillbackIdID#'
				AND 	Deleted = 0
			</cfquery>
</cfif>
			
			<cfif qCheckForLumpSums.RecordCount>
				<cfset rRunDeviation = 1 />
			</cfif>
			
		</cfif>
		
		<cfreturn rRunDeviation />
		
	</cffunction>
  
</cfcomponent>