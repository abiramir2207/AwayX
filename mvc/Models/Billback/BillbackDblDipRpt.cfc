<!----------------------------------------------------------------------------------
Name: 			BillbackDblDipRpt.cfc
Copyright:		(c) 2021 Blacksmith Applications, Inc.
Created Date: 	02/22/2021
Created By:    	Anand Rao
Description:	DB edit/access for BB Double Dip Report
Parameters:		N/A
Usage:			N/A
---------------------------------------------------------------------------------->

<cfcomponent name="BillbackDblDipRpt" displayname="BillbackDblDipRpt" hint="Manages double dip related queries">

	<cffunction name="getDropDownRows" access="public" returntype="query" output="false" >
		<cfquery name="qGetDropDownRows" datasource="#application.datasource#">
			 
			DECLARE @Date datetime = '01/01/2020'
			
			IF OBJECT_ID ('tempdb..##Double_dip_option_drop_down') IS NOT NULL
			       DROP TABLE tempdb..##Double_dip_option_drop_down
			CREATE TABLE tempdb..##Double_dip_option_drop_down
			       (
			       Dropdown_value VARCHAR(50)
			       )
			
			IF(    SELECT COUNT(*)  
			       FROM   BB_upload_Log 
			       WHERE  deleted = 0 
			       AND          Upload_Type = 3 
			       AND          Source_code = 'SYSCO' 
			       AND          Upload_Date >= @Date) > 0 
			BEGIN 
			       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
			       VALUES ('SYSCO')
			END  
			
			IF(    SELECT COUNT(*)  
			       FROM   BB_upload_Log 
			       WHERE  deleted = 0 
			       AND          Upload_Type = 3 
			       AND          Source_code = 'USFS' 
			       AND          Upload_Date >= @Date) >0
			BEGIN
			       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
			       VALUES ('USFS')
			END  
			
			IF( SELECT    COUNT(*)  
			       FROM   BB_upload_Log 
			       WHERE  deleted = 0 
			       AND          Upload_Type = 3 
			       AND          ISNULL(Source_code ,'')= ''
			       AND          Upload_Date >= @Date )>0
			BEGIN 
			       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
			       VALUES ('3rd Party')
			END  
			
			SELECT * 
			FROM   ##Double_dip_option_drop_down
			
			</cfquery>
		<cfreturn qGetDropDownRows />
	</cffunction>			
	<!--- Check to see if the Double Dip Report is locked by another user --->
	<cffunction name="checkDblDipRptLock" access="public" returntype="query" output="false" >
		<cfset var qCheckDblDipRptLock = "" />	
		<cfquery name="qCheckDblDipRptLock" datasource="#application.datasource#">
			SELECT 		ISNULL(BB_DblDipRpt_Lock.IS_LOCKED, 0) AS IS_LOCKED, 
						BB_DblDipRpt_Lock.USER_ID, 
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER 
			FROM		BB_DblDipRpt_Lock
			LEFT JOIN	_USERS 
			ON			_USERS.USER_ID =  BB_DblDipRpt_Lock.USER_ID
			WHERE		BB_DblDipRpt_Lock.DELETED = 0
			AND			BB_DblDipRpt_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC 
		</cfquery>
		
		<cfreturn qCheckDblDipRptLock />
	</cffunction>

	<cffunction name="checkIsRunning" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qCheckIsRunning" datasource="#application.datasource#">
			declare @x int = 0
			declare @y int = 0
			declare @z int = 0
			
			exec isSP_Running 'EDI_SYSCO_Double_Dip_Extract',@out = @x OUTPUT;
			exec isSP_Running 'EDI_USFS_Double_Dip_Extract',@out = @y OUTPUT;
			exec isSP_Running 'III_Party_Double_Dip_Extract',@out = @z OUTPUT;
			
			select @x AS SyscoRunning,@y AS USFSRunning, @z as IIIPartyRunning
		</cfquery>
		<cfscript>
			if(qCheckIsRunning.SyscoRunning == 1 OR qCheckIsRunning.USFSRunning == 1 OR qCheckIsRunning.IIIPartyRunning == 1){
				Return True;
			}
			else{
				Return False;
			}
		</cfscript>

	</cffunction>	
<!--- Lock the page --->
	<cffunction name="lockDblDipRpt" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
					
		<cfset var qLock = "" />
		<cfset var temp = this.unlockDblDipRpt()/> <!--- unlock first others --->
			
		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		BB_DblDipRpt_Lock (User_ID,Is_Locked)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>
		
		<cfreturn true />
	</cffunction>	


	<!--- Unlock the page --->
	<cffunction name="unlockDblDipRpt" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		BB_DblDipRpt_Lock
			SET			Is_Locked = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						Deleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		Is_Locked = 1
			AND			Deleted = 0 
		</cfquery>
		
		<cfreturn true />
	</cffunction>		
	
	<cffunction name="getExclusionList" access="public" returntype="query" output="false" >
		<cfargument name="exclusion_Type" type="string" required="false">
		
		<cfquery name="qGetExclusions" datasource="#application.datasource#">
			SELECT  DISTINCT
					III_Party_Double_Dip_Exclusions_ID, 
					Exclusion_Type,
					Value 
			FROM 
					III_Party_Double_Dip_Exclusions
					<cfif (arguments.exclusion_Type EQ "OPER")>
						WHERE Exclusion_Type = 'Operator'
					<cfelseif (arguments.exclusion_Type EQ "PROG")>
						WHERE Exclusion_Type = 'Program'
					</cfif>
		</cfquery>
		
		<cfreturn qGetExclusions />
	</cffunction>
	
 	<cffunction name="getProgramExclusionListIDs" access="public" returntype="query" output="false" >
		<!--- <cfargument name="exclusion_Type" type="string" required="false"> --->
		<cfquery name="qGetPrgExclusionsIDs" datasource="#application.datasource#">
	 		SELECT Contract_Main_ID FROM contract_main WHERE contract_number IN(
			SELECT  Value 
			FROM 
					III_Party_Double_Dip_Exclusions
					WHERE Exclusion_Type = 'Program') AND Deleted = 0
		</cfquery>
		<cfreturn qGetPrgExclusionsIDs />
	</cffunction>
	
	
	<cffunction name="getProgramExclusionList" access="public" returntype="query" output="false" >
		<cfargument name="ProgIDList" type="string" required="true"> 
		<cfquery name="qGetPrgExclusionsIDs" datasource="#application.datasource#">
			SELECT DISTINCT Contract_Number FROM Contract_Main WHERE Contract_Main_ID IN (#arguments.ProgIDList# ) AND Deleted = 0
		</cfquery>
		<cfreturn qGetPrgExclusionsIDs />
	</cffunction>

 	<cffunction name="getOperatorExclusionListIDs" access="public" returntype="query" output="false" >
		<!--- <cfargument name="exclusion_Type" type="string" required="false"> --->
		<cfquery name="qGetOprExclusionsIDs" datasource="#application.datasource#">
	 		SELECT BSA_Operator_ID FROM dbo.BSA_Operator WHERE Legacy_ID IN(
			SELECT  Value 
			FROM 
					III_Party_Double_Dip_Exclusions
					WHERE Exclusion_Type = 'Operator') AND Deleted = 0			
		</cfquery>
		<cfreturn qGetOprExclusionsIDs />
	</cffunction>
	
	<cffunction name="getOperatorExclusionList" access="public" returntype="query" output="false" >
		<cfargument name="OprIDList" type="string" required="true"> 
		<cfquery name="qGetOprExclusionsIDs" datasource="#application.datasource#">
			SELECT DISTINCT Legacy_ID FROM BSA_Operator WHERE BSA_Operator_ID IN (#arguments.OprIDList# ) AND Deleted = 0
		</cfquery>
		<cfreturn qGetOprExclusionsIDs />
	</cffunction>
	
	<cffunction name="updGetReportHistoryID" access="public" returntype="query" output="false" >
		<!--- <cfargument name="exclusion_Type" type="string" required="false"> --->
		<cfset qGetReportHistoryID = QueryNew("BB_DblDipRpt_History_ID, savedExclusion") />
		<cfset wasSaved = "" />
		<cfif ((isDefined("FORM.newPrgIDs") AND FORM.newPrgIDs NEQ "") AND FORM.ReportType EQ "3rd Party")>
			<cfset qryNewPrgExcludeList = this.getProgramExclusionList("#FORM.newPrgIDs#") />
			<cfset newPrgExcludeList = ValueList(qryNewPrgExcludeList.Contract_number) />
			<cfset prgCurrentList = this.getExclusionList('PROG') />
						<!--- Compare to make sure there is atleast one program that is exists/ deos not exist to perform the delete and Insert --->
			<cfset NotExistsCtr1 = 0/>
			<cfset NotExistsCtr2 = 0/>
 			
			<cfloop index = "Newval" list = "#newPrgExcludeList#"  delimiters = ",">
				<cfif ListContains("#Valuelist(prgCurrentList.value)#" ,Newval) EQ 0>
					<cfset 	NotExistsCtr1 = NotExistsCtr1 + 1 />
				</cfif>
			</cfloop>
			<cfloop index = "Oldval" list = "#Valuelist(prgCurrentList.value)#"  delimiters = ",">
				<cfif ListContains("#newPrgExcludeList#"  ,Oldval) EQ 0>
					<cfset NotExistsCtr2 = NotExistsCtr2 + 1 />
				</cfif>
			</cfloop>
				<!--- <cfdump var="#NotExistsCtr1#" /><cfdump var="#NotExistsCtr2#" />
in update:   --->
				
			<cfif NotExistsCtr1 GTE 1 OR  NotExistsCtr2 GTE 1>
				<cfset useLakebaseFordelPrgIIIPartyDoubleDipExclusions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("iii_party_double_dip_exclusions")>
<cfif useLakebaseFordelPrgIIIPartyDoubleDipExclusions>
	<cftry>
		<cfset application.oLakebase.deleteRows("iii_party_double_dip_exclusions", {
			"exclusion_type" = "eq.Program"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelPrgIIIPartyDoubleDipExclusions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelPrgIIIPartyDoubleDipExclusions>
<cfquery name="delPrgIIIPartyDoubleDipExclusions" datasource="#application.datasource#">
					DELETE FROM III_Party_Double_Dip_Exclusions WHERE Exclusion_Type = 'Program'
				</cfquery>
</cfif>
				
				 <cfloop index = "i" list = "#newPrgExcludeList#"  delimiters = ",">
					<cfset useLakebaseForqInsertPrgExclusion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("iii_party_double_dip_exclusions")>
<cfif useLakebaseForqInsertPrgExclusion>
	<cftry>
		<cfset application.oLakebase.insertRow("iii_party_double_dip_exclusions", {
			"exclusion_type" = "Program",
			"value" = "#i#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertPrgExclusion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertPrgExclusion>
<cfquery name="qInsertPrgExclusion" datasource="#application.datasource#">
						INSERT INTO III_Party_Double_Dip_Exclusions 
						(
							Exclusion_Type,	
							Value
						)
						VALUES
						(
							'Program',
							'#i#'	
						)
					</cfquery>
</cfif>
					<cfset wasSaved = "Program" />
				</cfloop> 
			</cfif>
			<cfset FORM.newPrgIDs = "" />
		</cfif>
		<cfif (isDefined("FORM.newOprIDs") AND FORM.newOprIDs NEQ "")>
			<cfset qryNewOprExcludeList = this.getOperatorExclusionList("#FORM.newOprIDs#") />
			<cfset newOprExcludeList = ValueList(qryNewOprExcludeList.Legacy_ID) />
			<cfset oprCurrentList = this.getExclusionList('OPER') />
			<!--- Compare to make sure there is atleast one program that is exists/ deos not exist to perform the delete and Insert --->
			<cfset NotExistsCtr1 = 0/>
			<cfset NotExistsCtr2 = 0/>
			<cfloop index = "Newval" list = "#newOprExcludeList#"  delimiters = ",">
				<cfif ListContains("#Valuelist(oprCurrentList.value)#" ,Newval) EQ 0>
					<cfset 	NotExistsCtr1 = NotExistsCtr1 + 1 />
				</cfif>
			</cfloop>
			<cfloop index = "Oldval" list = "#Valuelist(oprCurrentList.value)#"  delimiters = ",">
				<cfif ListContains("#newOprExcludeList#"  ,Oldval) EQ 0>
					<cfset NotExistsCtr2 = NotExistsCtr2 + 1 />
				</cfif>
			</cfloop>
			
			<cfif NotExistsCtr1 GTE 1 OR  NotExistsCtr2 GTE 1>
				<cfset useLakebaseFordelOprIIIPartyDoubleDipExclusions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("iii_party_double_dip_exclusions")>
<cfif useLakebaseFordelOprIIIPartyDoubleDipExclusions>
	<cftry>
		<cfset application.oLakebase.deleteRows("iii_party_double_dip_exclusions", {
			"exclusion_type" = "eq.Operator"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelOprIIIPartyDoubleDipExclusions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelOprIIIPartyDoubleDipExclusions>
<cfquery name="delOprIIIPartyDoubleDipExclusions" datasource="#application.datasource#">
					DELETE FROM III_Party_Double_Dip_Exclusions WHERE Exclusion_Type = 'Operator'
				</cfquery>
</cfif>
				
				 <cfloop index = "j" list = "#newOprExcludeList#"  delimiters = ",">
					<cfset useLakebaseForqInsertOprExclusion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("iii_party_double_dip_exclusions")>
<cfif useLakebaseForqInsertOprExclusion>
	<cftry>
		<cfset application.oLakebase.insertRow("iii_party_double_dip_exclusions", {
			"exclusion_type" = "Operator",
			"value" = "#j#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertOprExclusion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertOprExclusion>
<cfquery name="qInsertOprExclusion" datasource="#application.datasource#">
						INSERT INTO III_Party_Double_Dip_Exclusions 
						(
							Exclusion_Type,	
							Value
						)
						VALUES
						(
							'Operator',
							'#j#'	
						)
					</cfquery>
</cfif>
				</cfloop> 
				<cfif (wasSaved EQ "Program")>
					<cfset wasSaved = "Program_Operator" />
				<cfelse>
					<cfset wasSaved = "Operator" />
				</cfif>
			</cfif>
			<cfset FORM.newOprIDs = "" />
		</cfif>
		<cfif (isDefined("FORM.actionsToDo") AND FORM.actionsToDo EQ "SaveOnly")> 
			<!--- <cfset temp = QuerySetCell(qGetReportHistoryID, "BB_DblDipRpt_History_ID", "0", 1)>
			<cfset temp = QuerySetCell(qGetReportHistoryID, "savedExclusion", "#wasSaved#", 1)> --->
			<cfquery name="qGetReportHistoryID" datasource="#application.datasource#">
				SELECT '0' AS BB_DblDipRpt_History_ID, '#wasSaved#' AS savedExclusion	
			</cfquery>
		</cfif>
		<cfif ((NOT(isDefined("FORM.Excluded_Operator_List")) OR (isDefined("FORM.Excluded_Operator_List") AND FORM.Excluded_Operator_List EQ "")) AND FORM.ReportType EQ "3rd Party")>
			<cfset qryFormOpr =  this.getExclusionList('OPER') />
			<cfset FORM.Excluded_Operator_List =  ValueList(qryFormOpr.value) />
		<cfelse>	
			<cfset FORM.Excluded_Operator_List =  "" />
		</cfif>
		<cfif ((NOT(isDefined("FORM.Excluded_Program_List")) OR (isDefined("FORM.Excluded_Program_List") AND FORM.Excluded_Program_List EQ "")) AND FORM.ReportType EQ "3rd Party")>
			<cfset qryFormPrg = this.getExclusionList('PROG') />
			<cfset FORM.Excluded_Program_List =  ValueList(qryFormPrg.value) />
		<cfelse>
			<cfset FORM.Excluded_Program_List =  "" />
		</cfif>
		<cfif (isDefined("FORM.actionsToDo") AND FORM.actionsToDo EQ "SaveAndGenerate")> 
			<cfquery name="qGetReportHistoryID" datasource="#application.datasource#">
			INSERT INTO BB_DblDipRpt_History
			(
				User_Picked_Date,
				BB_DblDipRpt_Type,
				Excluded_Operator_List,
				Excluded_Program_List,
				Overlap_Days,
				Created_By,
				Created_Date
			)
			VALUES
			(
				'#FORM.ReportDate#',
				'#FORM.ReportType#',
				'#FORM.Excluded_Operator_List#',
				'#FORM.Excluded_Program_List#',
				'#FORM.OverlapDays#',
				'#request.AccessStructure.User_ID#',
				getDate()
			)
	 		
			SELECT SCOPE_IDENTITY()	AS BB_DblDipRpt_History_ID, '#wasSaved#' AS savedExclusion		
			</cfquery>
			<cfreturn qGetReportHistoryID />
		</cfif>
		<cfreturn qGetReportHistoryID />
	</cffunction>
  
</cfcomponent>