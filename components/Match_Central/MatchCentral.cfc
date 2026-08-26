<cfcomponent Displayname="MatchCentral" hint="Matching Functions for Deductions, Billbacks, and Credits" extends="mvc.Models.SettingsService">

	<cffunction name="init" output="false" returntype="components.Match_Central.MatchCentral">

		<cfargument name="matchCentralUserID" default="#request.AccessStructure.User_ID#" required="no" />

		<cfset this.matchCentralUserID = arguments.matchCentralUserID />
		<cfset this.stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

		<cfscript>
			// System and settings info
			genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init();
			appSettings = genSettingsManager.get();
			this.dsn = Application.Datasource;
			this.cfVersion = listGetAt(server.coldfusion.productversion,1,",");

			// Path info
			this.MatchCentralDataPath = expandPath('/') & "common_documents\Data_Files\Created\MatchCentral";
			this.MatchCentralXMLPath = "#this.MatchCentralDataPath#\xml";
			this.MatchCentralPath = "#this.MatchCentralXMLPath#\#this.matchCentralUserID#";

			// External component managers
			this.DDMgr = createObject("Component","components.Deduction.DeductionManager").init();
			this.BBMgr = createObject("Component","components.Billback.BillbackManager").init();
		</cfscript>

		<cfif NOT directoryExists(this.MatchCentralDataPath)>
			<cfdirectory action="create" directory="#this.MatchCentralDataPath#">
		</cfif>
		<cfif NOT directoryExists(this.MatchCentralXMLPath)>
			<cfdirectory action="create" directory="#this.MatchCentralXMLPath#">
		</cfif>
		<cfif NOT directoryExists(this.MatchCentralPath)>
			<cfdirectory action="create" directory="#this.MatchCentralPath#">
		</cfif>

		<cfscript>
			// Global variables
			this.workListIDList = workListIDList();
			this.selectedBBlist = selectedBBlist();
			this.selectedDDlist = selectedDDlist();
			this.selectedCRlist = selectedCRlist();

			// Current User
			this.CurUserWorkListIDList = CurUserWorkListIDList();
		</cfscript>

		<cfreturn this />

	</cffunction>

	<!--- HELPER FUNCTIONS FOR CFSCRIPTS --->
	<cffunction name="dump"
					access="private"
					returntype="void"
					output="true"
					displayname="dump">

		<cfargument name="dataToDump" required="true" type="any">

		<cfdump var="#arguments.dataToDump#">
		<cfdump var=" ">

	</cffunction>
	<cffunction name="abort"
					access="private"
					returntype="void"
					output="true"
					displayname="abort">

		<cfabort>

	</cffunction>

	<!--- GETTERS --->
	<cffunction name="getDDAnalysts"
					access="public"
					returntype="query"
					output="false"
					displayname="searchDeductions">

		<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
		<CFQUERY NAME="DeductionsProfilesSettings" DATASOURCE="#application.datasource#">
			SELECT *
			FROM Deductions_Profiles_Settings
			WHERE Profiles_ID = <cfqueryparam value="#Get_Profile_Settings.Profiles_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
		<CFQUERY NAME="UserHasAssignments" DATASOURCE="#Application.Datasource#">
			 SELECT *
			 FROM DD_Analyst
			 WHERE Analyst_User_ID = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">
			 	AND Deleted=0
		</CFQUERY>
		<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
			SELECT 		User_ID, Name_First, Name_Last
			FROM 		DD_Analyst INNER JOIN 	_Users ON _Users.user_ID = DD_Analyst.Analyst_User_ID
			WHERE 		DD_Analyst.Deleted=0 AND _Users.Deleted=0
			ORDER BY	_Users.Name_First,_Users.Name_Last
		</CFQUERY>

		<cfreturn Get_Analyst>

	</cffunction>
	<cffunction name="GetMatchedAmounts"
					access="public"
					returntype="numeric"
					output="true"
					displayname="GetMatchedAmounts"
					hint="returns the remaining balance for the work item id that was passed in">

		<cfargument name="workItem" required="true" type="string">

		<cfscript>
			matchListFile = readMatchListFile(arguments.workItem);
			matchListFile = xmlParse(matchListFile);
			matchingType = getMatchingType(arguments.workItem);

			if (matchingType EQ "BB"){
				AmtArray = XmlSearch(matchListFile, "/matchlist/bb/bb_approved_amount/");
			} else if (matchingType EQ "CR"){
				AmtArray = XmlSearch(matchListFile, "/matchlist/cr/dd_amount/");
			} else if (matchingType EQ "DD"){
				AmtArray = XmlSearch(matchListFile, "/matchlist/dd/dd_amount/");
			} else {
				AmtArray = arrayNew(1);
			}

			amount = 0;
			for (i=1;i LTE arrayLen(AmtArray);i=(i+1))
			{
				amount = amount + AmtArray[i].xmlText;
			}

			workItemType = getWorkItemType(arguments.workItem);
			if (workItemType EQ "BB"){
				BBInfo = getBBInfo(arguments.workItem);
				if(BBInfo.RecordCount GTE 1)
				{
				amount = BBInfo.BB_Approved_Amount - amount;
				}
				else
				{
				amount = 0;
				}
			} else if (workItemType EQ "CR"){
				CRInfo = this.DDMgr.getDeduction(arguments.workItem);
				if (matchingType EQ "BB"){
					amount = CRInfo.DD_Amount - amount;
				} else if (matchingType EQ "DD") {
					amount = CRInfo.DD_Amount + amount;
				}
			} else if (workItemType EQ "DD"){
				DDInfo = this.DDMgr.getDeduction(arguments.workItem);
				if (matchingType EQ "BB"){
					amount = DDInfo.DD_Amount - amount;
				} else if (matchingType EQ "CR") {
					amount = DDInfo.DD_Amount + amount;
				}
			}
		</cfscript>

		<cfreturn amount>

	</cffunction>
	<cffunction name="getBBInfo"
					access="public"
					returntype="query"
					output="true"
					displayname="getDDInfo">

		<cfargument name="bbid" required="true" type="string">
		<cfargument name="agree" required="false" type="boolean" default="0">

		<cfset var bAgreedOnly = 0>

		<!--- If we need to check "agree" information --->
		<cfif arguments.agree eq 1>

			<!--- Check if the billback is approved --->
			<cfquery name="qApprovedbillbackInfo" datasource="#this.dsn#">
				SELECT BB_Approved_ID
				FROM BB_Approved
				WHERE Billback_ID =  <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<!--- Get the billback agreed amount. This the amount agreed to by the user who agreed to it last. --->
			<cfquery name="qAgreedbillbackInfo" datasource="#this.dsn#">
				SELECT TOP 1 BB_Agreed_Info_ID,Agreed_Amount
				FROM BB_Agreed_Info
				WHERE Billback_ID =  <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
				AND deleted = 0
				ORDER BY Created_Date DESC
			</cfquery>

			<!--- If the billback has been agreed to, but has not been approved --->
			<cfif qApprovedbillbackInfo.recordcount eq 0 AND qAgreedbillbackInfo.recordcount GT 0>
				<cfset bAgreedOnly = 1>
			</cfif>
		</cfif>

		<!---
			Added columns: shr_ship_to as Payee_ID and Name as Payee_name for displaying the Payee_name & Payee_Id
			- Anand Rao 01/06/09
		--->
		<cfquery name="billbackInfo" datasource="#this.dsn#">
			SELECT BB.*,
			BBS.Billback_Status_ID,
				BBS.BB_Status_Description,
				BBS.BB_Status_Abbreviation,
				BB.Special_Handling AS SpecialHandling,
				BBA.Approved_Amount,
				BBA.Paid_Amount,
				BBA.Document_Number_1,
				BBA.Document_Number_2,
				BCM.vchBillback_Closing_Method_Desc AS Closing_Method_Description,
				BCM.Abbreviation,
			<cfif bAgreedOnly eq 0>
			BBA.Paid_Amount AS BB_Approved_Amount,
			<cfelse>
			<!--- If the billback has been agreed to, but has not been approved --->
			#qAgreedbillbackInfo.Agreed_Amount# As BB_Approved_Amount,
			</cfif>
			BSAFC.BSA_Foodservice_Customers_ID AS Dist_ID,
			BSAFC.Distributor_Bill_To_ID,

			CASE WHEN BSAFC.Shr_Ship_To IS NULL
			THEN VM.Vendor_ID
			ELSE
			BSAFC.Shr_Ship_To
			END
			AS Payee_ID,

			CASE WHEN BSAFC.Shr_Ship_To IS NULL
			THEN ''
			ELSE
			BSAFC.Business_Segment_ID
			END
			AS Payee_Business_Segment_ID,

			CASE WHEN BSAFC.Name
			IS NULL
			THEN VM.Vendor_Name
			ELSE
			BSAFC.Name
			END
			AS Payee_Name,

			CASE WHEN DBT.Shr_Bill_To
			IS NULL
			THEN VM.Vendor_ID
			ELSE
			DBT.Shr_Bill_To
			END
			As Shr_Bill_To,

			CASE WHEN DBT.Name
			IS NULL
			THEN VM.Vendor_Name
			ELSE
			DBT.Name
			END
			AS Bill_To_Name,
			VM2.Vendor_ID AS MC_Vendor_ID,
			VM2.Vendor_Name AS MC_Vendor_Name
			FROM Billback BB

				LEFT JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
				LEFT JOIN
					(
						Billback_Distributor BBD LEFT JOIN BSA_Foodservice_Customers BSAFC
						ON (BBD.Distributor_ID = BSAFC.BSA_Foodservice_Customers_ID)
					)
				ON (
						(BBD.Billback_ID = BB.Billback_ID) AND
							(
								(BB.Billback_Payee_Type_ID = 1) OR (BB.Billback_Payee_Type_ID = 5)
							)
						AND (BBD.Deleted = 0)
					)
				LEFT JOIN Distributor_Bill_To DBT
				ON BSAFC.Distributor_Bill_To_ID = DBT.Distributor_Bill_To_ID

				LEFT JOIN Vendor_Master VM
				ON BBD.Distributor_ID = VM.Vendor_Master_ID
				AND BBD.Deleted = 0
				LEFT JOIN
				Billback_Status BBS
				ON
				BB.Billback_Status_ID = BBS.Billback_Status_ID
				LEFT JOIN
				Billback_Closing_Methods BCM
				ON
				BB.BB_Closing_Method = BCM.iBillback_Closing_Method_ID AND BCM.Deleted = 0
				LEFT JOIN Vendor_Master VM2
				ON
				BBA.Vendor_Master_ID = VM2.Vendor_Master_ID
			WHERE BB.billback_id = <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn billbackInfo>

	</cffunction>
	<cffunction name="getDistributorInfo"
					access="public"
					returntype="query"
					output="true"
					displayname="getDistributorInfo">

		<cfargument name="distID" required="true" type="string">

		<CFQUERY NAME="qgetDistributors" datasource="#application.datasource#">
			SELECT	*
			FROM	BSA_Foodservice_Customers
			WHERE	BSA_Foodservice_Customers_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.distID#" />
		</CFQUERY>

		<cfreturn qgetDistributors>

	</cffunction>
	<cffunction name="getBBStatusImageString"
					access="public"
					returntype="any"
					output="false">
		<cfargument name="bbStatusId" required="true" type="numeric" />
		<cfoutput>
		<cfsavecontent variable="returnValue">
		#getBBStatusImage(arguments.bbStatusId)#
		</cfsavecontent>
		</cfoutput>
		<cfreturn returnValue />

	</cffunction>
	<cffunction name="getBBStatusImage"
					access="public"
					returntype="any"
					output="false">
		<cfargument name="bbStatusId" required="true" type="numeric" />

		<cfset returnValue = "" />
		<CFSWITCH EXPRESSION="#arguments.bbStatusId#">
			<CFCASE VALUE="1">
				<!--- WIP --->
				<cfset returnValue = "/images/wip.gif" />
			</CFCASE>
			<CFCASE VALUE="2">
				<!--- Ready For Approval --->
				<cfset returnValue = "/images/rfa.gif" />
			</CFCASE>
			<CFCASE VALUE="3">
				<!--- Active Programs --->
				<cfset returnValue = "/images/preactive.gif" />
			</CFCASE>
			<CFCASE VALUE="4">
				<!--- Archived/Expired --->
				<cfset returnValue = "/images/active.gif" />
			</CFCASE>
			<CFCASE VALUE="5">
				<!--- Archived/Expired --->
				<cfset returnValue = "/images/expired.gif" />
			</CFCASE>
			<CFCASE VALUE="6">
				<!--- Pending Fund update --->
				<cfset returnValue = "/images/statusImage2.gif" />
			</CFCASE>
			<CFCASE VALUE="7">
				<!--- Pending Vendor ID --->
				<cfset returnValue = "/images/statusImage1.gif" />
			</CFCASE>
			<CFCASE VALUE="8">
				<!--- Approved/Void --->
				<cfset returnValue = "/images/expiring.gif" />
			</CFCASE>
		</CFSWITCH>
		<cfreturn returnValue />

	</cffunction>

	<!--- CHECK FOR, AND GET TYPE FUNCTIONS --->
	<cffunction name="selectedMatchListByTyp"
					access="public"
					returntype="string"
					output="true"
					displayname="selectedBBlistByTyp">

		<cfargument name="typid" required="true" type="string">

		<cfscript>
			matchListFile = readMatchListFile(arguments.typid);
			matchType = getMatchingType(arguments.typid);

			if (matchType EQ "BB"){
				matchArray = XmlSearch(matchListFile, "/matchlist/bb/billback_id");
			} else if (matchType EQ "CR"){
				matchArray = XmlSearch(matchListFile, "/matchlist/cr/deduction_id");
			}else if (matchType EQ "DD"){
				matchArray = XmlSearch(matchListFile, "/matchlist/dd/deduction_id");
			}

			matchList = "";
			for (i=1;i LTE arrayLen(matchArray);i=(i+1))
			{
				matchList = listAppend(matchList,matchArray[i].xmlText);
			}
		</cfscript>

		<cfreturn matchList>

	</cffunction>
	<cffunction name="checkForBB"
					access="public"
					returntype="string"
					output="true"
					displayname="selectedBBlist">

		<cfargument name="bbid" type="string" required="true">
		<cfargument name="workItemid" type="string" required="true">

		<cfscript>
			matchListFile = readMatchListFile(arguments.workItemid);
			xmlDoc = xmlParse(matchListFile);
			bbAmtArray = XmlSearch(matchListFile, "/matchlist/bb/billback_id");
			bblist = "";

			for (i=1;i LTE arrayLen(bbAmtArray);i=(i+1))
			{
				bblist = listAppend(bblist,bbAmtArray[i].xmlText);
			}

			exists = listFind(bblist,arguments.bbid);
			if (exists EQ 0){
				exists = "BBDoesNotExist";
			} else {
				exists = "BBExists";
			}
		</cfscript>

		<cfreturn exists>

	</cffunction>
	<cffunction name="checkForDD"
					access="public"
					returntype="string"
					output="true"
					displayname="selectedBBlist">

		<cfargument name="ddid" type="string" required="true">
		<cfargument name="workItemid" type="string" required="true">

		<cfscript>
			matchListFile = readMatchListFile(arguments.workItemid);
			xmlDoc = xmlParse(matchListFile);
			ddAmtArray = XmlSearch(matchListFile, "/matchlist/dd/deduction_id");
			ddlist = "";

			for (i=1;i LTE arrayLen(ddAmtArray);i=(i+1))
			{
				ddlist = listAppend(ddlist,ddAmtArray[i].xmlText);
			}

			exists = listFind(ddlist,arguments.ddid);
			if (exists EQ 0){
				exists = "DDDoesNotExist";
			} else {
				exists = "DDExists";
			}
		</cfscript>

		<cfreturn exists>

	</cffunction>
	<cffunction name="checkForCR"
					access="public"
					returntype="string"
					output="true"
					displayname="selectedBBlist">

		<cfargument name="ddid" type="string" required="true">
		<cfargument name="workItemid" type="string" required="true">

		<cfscript>
			matchListFile = readMatchListFile(arguments.workItemid);
			xmlDoc = xmlParse(matchListFile);
			ddAmtArray = XmlSearch(matchListFile, "/matchlist/cr/deduction_id");
			ddlist = "";

			for (i=1;i LTE arrayLen(ddAmtArray);i=(i+1))
			{
				ddlist = listAppend(ddlist,ddAmtArray[i].xmlText);
			}

			exists = listFind(ddlist,arguments.ddid);
			if (exists EQ 0){
				exists = "CRDoesNotExist";
			} else {
				exists = "CRExists";
			}
		</cfscript>

		<cfreturn exists>

	</cffunction>
	<cffunction name="getWorkItemType"
					access="public"
					returntype="string"
					output="true"
					displayname="getWorkItemType">

		<cfargument name="workItemID" required="true" type="string">


	<cfloop from="1" to=#listlen(arguments.workItemID)# index="arg">
		<cfscript>
			workListFile = readWorkListFile();
			bbtyp = XmlSearch(workListFile, "/worklist/bb/billback_id");
			crdtyp = XmlSearch(workListFile, "/worklist/crd/deduction_id");
			dedtyp = XmlSearch(workListFile, "/worklist/ded/deduction_id");

			if (arrayLen(bbtyp) GT 0){
				for (i=1;i LTE arrayLen(bbtyp);i=i+1){
					if (bbtyp[i].xmlText EQ listGetAt(arguments.workItemID, arg)){
						itemType = "BB";
					}
				}
			}
			if (arrayLen(crdtyp) GT 0) {
				for (i=1;i LTE arrayLen(crdtyp);i=i+1){
					if (crdtyp[i].xmlText EQ listGetAt(arguments.workItemID, arg)){
						itemType = "CR";
						xx = 1;
					}
				}
			}
			if (arrayLen(dedtyp) GT 0) {
				for (i=1;i LTE arrayLen(dedtyp);i=i+1){
					if (dedtyp[i].xmlText EQ listGetAt(arguments.workItemID, arg)){
						itemType = "DD";
					}
				}
			}
		</cfscript>
	</cfloop>

		<cfreturn itemType>

	</cffunction>
	<cffunction name="getMatchingType"
					access="public"
					returntype="string"
					output="true"
					displayname="getMatchType">

		<cfargument name="workItemID" required="true" type="string">

		<cfscript>
			workItemType = getWorkItemType(arguments.workItemID);
			workListFile = readWorkListFile();
			arrayPos = 0;

			if (workItemType EQ "DD"){
				idList = XmlSearch(workListFile, "/worklist/ded/deduction_id/");
				for (i=1;i LTE arrayLen(idList);i=i+1){
					idToFind = idList[i].xmlText;
					arrayPos = i;
					if(idToFind EQ arguments.workItemID){
						break;
					}
				}
				matchType = XmlSearch(workListFile, "/worklist/ded/match_type/");
				matchType = matchType[arrayPos].xmlText;
			} else if (workItemType EQ "CR") {
				idList = XmlSearch(workListFile, "/worklist/crd/deduction_id/");
				for (i=1;i LTE arrayLen(idList);i=i+1){
					idToFind = idList[i].xmlText;
					arrayPos = i;
					if(idToFind EQ arguments.workItemID){
						break;
					}
				}
				matchType = XmlSearch(workListFile, "/worklist/crd/match_type/");
				matchType = matchType[arrayPos].xmlText;
			} else if (workItemType EQ "BB") {
				idList = XmlSearch(workListFile, "/worklist/bb/billback_id/");
				for (i=1;i LTE arrayLen(idList);i=i+1){
					idToFind = idList[i].xmlText;
					arrayPos = i;
					if(idToFind EQ arguments.workItemID){
						break;
					}
				}
				matchType = XmlSearch(workListFile, "/worklist/bb/match_type/");
				matchType = matchType[arrayPos].xmlText;
			} else {
				matchType = "";
			}
		</cfscript>

		<cfreturn matchType>

	</cffunction>

	<!--- LOCKING/UNLOCKING FUNCTIONS --->
	<cffunction name="billbackLocking"
					access="public"
					returntype="void"
					output="false"
					displayname="billbackLocking"
					hint="">

		<cfargument name="bbid" required="true" type="string">
		<cfargument name="lock" required="true" type="string">

		<cfif arguments.lock EQ "lock">
			<cfquery name="lockBillback" datasource="#this.dsn#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 1
					,BB_Locked_By_User_ID = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">
					,BB_Lock_Date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					,BB_Locked_By_Match_Central = 1
				WHERE Billback_ID = <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery name="unLockBillback" datasource="#this.dsn#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 0
					,BB_Locked_By_Match_Central = 0
				WHERE Billback_ID = <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	</cffunction>
	<cffunction name="deductionLocking"
					access="public"
					returntype="void"
					output="false"
					displayname="billbackLocking"
					hint="">

		<cfargument name="ddid" required="true" type="string">
		<cfargument name="lock" required="true" type="string">

		<cfif arguments.lock EQ "lock">
			<cfquery name="lockBillback" datasource="#this.dsn#">
				UPDATE Deductions
				SET Is_Locked = 1
					,Locked_By = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">
					,DD_Locked_By_Match_Central = 1
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery name="unLockBillback" datasource="#this.dsn#">
				UPDATE Deductions
				SET Is_Locked = 0
					,DD_Locked_By_Match_Central = 0
					,Locked_By = NULL
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	</cffunction>

	<!--- 	THIS FUNCTION IS USED TO UNLOCK DD, CR OR BB'S EVEN IF THE XML FILES HAVE BEEN DELETED SOMEHOW
			CALLED FROM 'SETTINGS/ACCESS_RIGHTS/UNLOCK_USER_RECORDS.CFM' AND 'SCHEDULED/UPGRADE.CFM' ONLY 		--->
	<cffunction name="unlockMatchCentralLocksByUser"
					access="public"
					returntype="void"
					output="false"
					displayname="unlockMatchCentralLocksByUser"
					hint="">

			<cfquery name="unLockBillback" datasource="#this.dsn#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 0
					,BB_Locked_By_Match_Central = 0
					,BB_Locked_By_User_ID = NULL
				WHERE BB_Locked_By_User_ID = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">
					AND BB_Locked_By_Match_Central = 1
			</cfquery>
			<cfquery name="unLockDeductions" datasource="#this.dsn#">
				UPDATE Deductions
				SET Is_Locked = 0
					,DD_Locked_By_Match_Central = 0
					,Locked_By = NULL
				WHERE Locked_By = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">
					AND DD_Locked_By_Match_Central = 1
			</cfquery>

	</cffunction>

	<!--- CALLED WITHOUT THE INIT FUNCTION --->
	<cffunction name="unlockMatchCentralLocks"
					access="public"
					returntype="void"
					output="false"
					displayname="unlockMatchCentralLocks"
					hint="">

			<cfquery name="unLockBillback" datasource="#Application.Datasource#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 0
					,BB_Locked_By_Match_Central = 0
					,BB_Locked_By_User_ID = NULL
				WHERE BB_Locked_By_Match_Central = 1
			</cfquery>
			<cfquery name="unLockDeductions" datasource="#Application.Datasource#">
				UPDATE Deductions
				SET Is_Locked = 0
					,DD_Locked_By_Match_Central = 0
					,Locked_By = NULL
				WHERE DD_Locked_By_Match_Central = 1
			</cfquery>

	</cffunction>
	<cffunction name="xmlFilePurge"
					access="public"
					returntype="void"
					output="false"
					displayname="xmlFilePurge"
					hint="">

		<cfset MCBasePath = expandPath('/') & "common_documents\Data_Files\Created\MatchCentral">
		<cfset xmlPath = "#MCBasePath#\xml">

		<cfif directoryExists(xmlPath)>
			<cfdirectory action="delete" directory="#xmlPath#" recurse="true">
		</cfif>

	</cffunction>

	<!--- PRIVATE FUNCTIONS --->
	<cffunction name="workListIDList"
					access="private"
					returntype="string"
					output="true"
					displayname="workListIDList">

		<cfdirectory action="list" directory="#this.MatchCentralXMLPath#" name="qUserDirectories">
		<cfset ddList = "">
		<cfoutput query="qUserDirectories">
				<cfset path = "#directory#\#name#">
				<cfscript>
					if (fileExists("#path#\worklist.xml")){
						fileData = readWorkListFile(path);
						xmlDoc = xmlParse(fileData); // Work list file
						xmlItems = arrayNew(1); // Empty master array

						// create arrays of all possible options, and append them to a master array
						dedxmlarray = XmlSearch(xmlDoc, "/worklist/ded");
						bbxmlarray = XmlSearch(xmlDoc, "/worklist/bb");
						crdxmlarray = XmlSearch(xmlDoc, "/worklist/crd");

						if(arrayLen(dedxmlarray) GT 0){
							for (dedcnt=1;dedcnt LTE arrayLen(dedxmlarray);dedcnt=(dedcnt+1)){
								arrayAppend(xmlItems,dedxmlarray[dedcnt]);
							}
						}
						if(arrayLen(bbxmlarray) GT 0){
							for (bbcnt=1;bbcnt LTE arrayLen(bbxmlarray);bbcnt=(bbcnt+1)){
								arrayAppend(xmlItems,bbxmlarray[bbcnt]);
							}
						}
						if(arrayLen(crdxmlarray) GT 0){
							for (crdcnt=1;crdcnt LTE arrayLen(crdxmlarray);crdcnt=(crdcnt+1)){
								arrayAppend(xmlItems,crdxmlarray[crdcnt]);
							}
						}

						// loop over the master array, and check for the id argument
						for (i=1;i LTE arrayLen(xmlItems);i=(i+1))
						{
							//XmlChildren[2] is the array index where the ID is stored for every record in the xml file
							id2 = xmlItems[i].XmlChildren[2].XmlText;

							ddList = listAppend(ddList,id2);
						}
					} else {
						ddList = "";
					}
				</cfscript>
		</cfoutput>

		<cfreturn ddList>

	</cffunction>
	<cffunction name="selectedBBlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedBBlist">

		<cfdirectory action="list" directory="#this.MatchCentralXMLPath#" name="qUserDirectories">
		<cfset bbList = "">

		<cfoutput query="qUserDirectories">
			<cfset path = "#directory#\#name#\">
			<cfdirectory action="list" directory="#path#" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID,path = path);
						xmlDoc = xmlParse(matchListFile);
						bbArray = XmlSearch(matchListFile, "/matchlist/bb/billback_id");

						for (i=1;i LTE arrayLen(bbArray);i=(i+1))
						{
							bbList = listAppend(bbList,bbArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn bbList>

	</cffunction>
	<cffunction name="selectedDDlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedDDlist">

		<cfdirectory action="list" directory="#this.MatchCentralXMLPath#" name="qUserDirectories">
		<cfset ddlist = "">

		<cfoutput query="qUserDirectories">
			<cfset path = "#directory#\#name#\">
			<cfdirectory action="list" directory="#directory#\#name#\" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID,path = path);
						xmlDoc = xmlParse(matchListFile);
						ddArray = XmlSearch(matchListFile, "/matchlist/dd/deduction_id");

						for (i=1;i LTE arrayLen(ddArray);i=(i+1))
						{
							ddlist = listAppend(ddlist,ddArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn ddlist>

	</cffunction>
	<cffunction name="selectedCRlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedCRlist">

		<cfdirectory action="list" directory="#this.MatchCentralXMLPath#" name="qUserDirectories">
		<cfset crlist = "">

		<cfoutput query="qUserDirectories">
			<cfset path = "#directory#\#name#\">
			<cfdirectory action="list" directory="#directory#\#name#\" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID,path = path);
						xmlDoc = xmlParse(matchListFile);
						crArray = XmlSearch(matchListFile, "/matchlist/cr/deduction_id");

						for (i=1;i LTE arrayLen(crArray);i=(i+1))
						{
							crlist = listAppend(crlist,crArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn crlist>

	</cffunction>

	<cffunction name="CurUserWorkListIDList"
					access="private"
					returntype="string"
					output="true"
					displayname="CurUserWorkListIDList">

		<cfscript>
			if (fileExists("#this.MatchCentralPath#\worklist.xml")){
				xmlDoc = xmlParse(readWorkListFile()); // Work list file
				xmlItems = arrayNew(1); // Empty master array
				ddList = "";

				// create arrays of all possible options, and append them to a master array
				dedxmlarray = XmlSearch(xmlDoc, "/worklist/ded");
				bbxmlarray = XmlSearch(xmlDoc, "/worklist/bb");
				crdxmlarray = XmlSearch(xmlDoc, "/worklist/crd");


				if(arrayLen(dedxmlarray) GT 0){
					for (dedcnt=1;dedcnt LTE arrayLen(dedxmlarray);dedcnt=(dedcnt+1)){
						arrayAppend(xmlItems,dedxmlarray[dedcnt]);
					}
				}
				if(arrayLen(bbxmlarray) GT 0){
					for (bbcnt=1;bbcnt LTE arrayLen(bbxmlarray);bbcnt=(bbcnt+1)){
						arrayAppend(xmlItems,bbxmlarray[bbcnt]);
					}
				}
				if(arrayLen(crdxmlarray) GT 0){
					for (crdcnt=1;crdcnt LTE arrayLen(crdxmlarray);crdcnt=(crdcnt+1)){
						arrayAppend(xmlItems,crdxmlarray[crdcnt]);
					}
				}

				// loop over the master array, and check for the id argument
				for (i=1;i LTE arrayLen(xmlItems);i=(i+1))
				{
					//XmlChildren[2] is the array index where the ID is stored for every record in the xml file
					id2 = xmlItems[i].XmlChildren[2].XmlText;

					ddList = listAppend(ddList,id2);
				}
			} else {
				ddList = "";
			}
		</cfscript>

		<cfreturn ddList>

	</cffunction>
	<cffunction name="CurUserSelectedBBlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedBBlist">

		<cfdirectory action="list" directory="#this.MatchCentralPath#" name="userDirectory">
		<cfset bbList = "">

		<cfoutput query="userDirectory">
			<cfdirectory action="list" directory="#this.MatchCentralPath#\" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID);
						xmlDoc = xmlParse(matchListFile);
						bbArray = XmlSearch(matchListFile, "/matchlist/bb/billback_id");

						for (i=1;i LTE arrayLen(bbArray);i=(i+1))
						{
							bbList = listAppend(bbList,bbArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn bbList>

	</cffunction>
	<cffunction name="CurUserSelectedDDlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedDDlist">

		<cfdirectory action="list" directory="#this.MatchCentralPath#" name="userDirectory">
		<cfset ddList = "">

		<cfoutput query="userDirectory">
			<cfdirectory action="list" directory="#this.MatchCentralPath#\" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID,path = path);
						xmlDoc = xmlParse(matchListFile);
						ddArray = XmlSearch(matchListFile, "/matchlist/dd/deduction_id");

						for (i=1;i LTE arrayLen(ddArray);i=(i+1))
						{
							ddlist = listAppend(ddlist,ddArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn ddlist>

	</cffunction>
	<cffunction name="CurUserSelectedCRlist"
					access="private"
					returntype="string"
					output="true"
					displayname="selectedCRlist">

		<cfdirectory action="list" directory="#this.MatchCentralPath#" name="userDirectory">
		<cfset crList = "">
		<cfoutput query="userDirectory">
			<cfdirectory action="list" directory="#this.MatchCentralPath#\" filter="*matchlist.xml" name="qMatchListFiles">
			<cfif qMatchListFiles.recordCount>
				<cfscript>
					fileList = valueList(qMatchListFiles.name);

					for (listCount=1;listCount LTE listLen(fileList);listCount=(listCount+1))
					{
						fileName = listGetAt(filelist,listCount);
						workID = replace(fileName,"-matchlist.xml","","ALL");

						matchListFile = readMatchListFile(workItemID = workID,path = path);
						xmlDoc = xmlParse(matchListFile);
						crArray = XmlSearch(matchListFile, "/matchlist/cr/deduction_id");

						for (i=1;i LTE arrayLen(crArray);i=(i+1))
						{
							crlist = listAppend(crlist,crArray[i].xmlText);
						}
					}
				</cfscript>
			</cfif>
		</cfoutput>

		<cfreturn crList>

	</cffunction>

	<!--- WORK LIST FUNCTIONS --->
	<cffunction name="writeWorkListFile"
				access="public"
				returntype="void"
				output="false"
				displayname="writeWorkListFile">

		<cfargument name="fileData" required="true" default="" type="string">

		<cffile action="write" file="#this.MatchCentralPath#\worklist.xml" output="#arguments.fileData#">

	</cffunction>
	<cffunction name="readWorkListFile"
				access="public"
				returntype="xml"
				output="false"
				displayname="readWorkListFile">

		<cfargument name="path" required="false" default="" type="string">

		<cfif arguments.path NEQ "">
			<cffile action="read" file="#arguments.path#\worklist.xml" variable="xmlDoc">
		<cfelse>
			<cffile action="read" file="#this.MatchCentralPath#\worklist.xml" variable="xmlDoc">
		</cfif>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="clearWorkList"
				access="public"
				returntype="void"
				output="false"
				displayname="AddToWorkList">

		<cfscript>
			// Current User Lists
			CurUserWorkListIDList = CurUserWorkListIDList();
			CurUserSelectedBBlist = CurUserSelectedBBlist();
			CurUserSelectedDDlist = CurUserSelectedDDlist();
			CurUserSelectedCRlist = CurUserSelectedCRlist();

			for (i=1; i LTE listLen(CurUserSelectedBBlist); i=i+1){
				id = listGetAt(CurUserSelectedBBlist,i);
				billbackLocking(id,"unlock");
			}
			for (i=1; i LTE listLen(CurUserSelectedDDlist); i=i+1){
				id = listGetAt(CurUserSelectedDDlist,i);
				deductionLocking(id,"unlock");
			}
			for (i=1; i LTE listLen(CurUserSelectedCRlist); i=i+1){
				id = listGetAt(CurUserSelectedCRlist,i);
				deductionLocking(id,"unlock");
			}
			for (i=1; i LTE listLen(CurUserWorkListIDList); i=i+1){
				id = listGetAt(CurUserWorkListIDList,i);
				deductionLocking(id,"unlock");
				billbackLocking(id,"unlock");
			}
			if (CurUserSelectedBBlist EQ "")
			{
				unlockMatchCentralLocksByUser();
			}
		</cfscript>

		<cfdirectory directory="#this.MatchCentralPath#\" action="list" filter="*.xml" name="files">
		<cfoutput query="files">
			<cffile action="delete" file="#this.MatchCentralPath#\#name#">
		</cfoutput>

	</cffunction>
	<cffunction name="clearWorkListItem"
				access="public"
				returntype="boolean"
				output="true"
				displayname="Clear work list item">

		<cfargument name="typid" required="true" type="string">

		<cfscript>
			// FIRST: Unlock all items that are matched
			matchType = getMatchingType(arguments.typid);
			matchListFile = readMatchListFile(arguments.typid);
			matchListFile = xmlParse(matchListFile);

			if (matchType EQ "DD"){
				idArray = XmlSearch(matchListFile, "/matchlist/dd/deduction_id");
				for (i=1;i LTE arrayLen(idArray);i=(i+1))
				{
					id2unlock = idArray[i].XmlText;
					deductionLocking(id2unlock,"unlock");
				}
			} else if (matchType EQ "CR"){
				idArray = XmlSearch(matchListFile, "/matchlist/cr/deduction_id");
				for (i=1;i LTE arrayLen(idArray);i=(i+1))
				{
					id2unlock = idArray[i].XmlText;
					deductionLocking(id2unlock,"unlock");
				}
			} else if (matchType EQ "BB"){
				idArray = XmlSearch(matchListFile, "/matchlist/bb/billback_id");
				for (i=1;i LTE arrayLen(idArray);i=(i+1))
				{
					id2unlock = idArray[i].XmlText;
					billbackLocking(id2unlock,"unlock");
				}
			}

			// SECOND: Read the work list file to search for the id to delete
			workItemType = getWorkItemType(arguments.typid);
			xmlDoc = xmlParse(readWorkListFile()); // Work list file
			xmlItems = arrayNew(1); // Empty master array

			// create arrays of all possible options, and append them to a master array
			dedxmlarray = XmlSearch(xmlDoc, "/worklist/ded");
			bbxmlarray = XmlSearch(xmlDoc, "/worklist/bb");
			crdxmlarray = XmlSearch(xmlDoc, "/worklist/crd");

			if(arrayLen(dedxmlarray) GT 0){
				for (dedcnt=1;dedcnt LTE arrayLen(dedxmlarray);dedcnt=(dedcnt+1)){
					arrayAppend(xmlItems,dedxmlarray[dedcnt]);
				}
			}
			if(arrayLen(bbxmlarray) GT 0){
				for (bbcnt=1;bbcnt LTE arrayLen(bbxmlarray);bbcnt=(bbcnt+1)){
					arrayAppend(xmlItems,bbxmlarray[bbcnt]);
				}
			}
			if(arrayLen(crdxmlarray) GT 0){
				for (crdcnt=1;crdcnt LTE arrayLen(crdxmlarray);crdcnt=(crdcnt+1)){
					arrayAppend(xmlItems,crdxmlarray[crdcnt]);
				}
			}

			// loop over the master array, and check for the id argument
			for (i=1;i LTE arrayLen(xmlItems);i=(i+1))
			{
				//XmlChildren[2] is the array index where the ID is stored for every record in the xml file
				id2 = xmlItems[i].XmlChildren[2].XmlText;

				if (arguments.typid EQ id2){
					elemPos = i;
					break;
				}
			}
			// delete the node from the master array
			ArrayDeleteAt(xmlItems, elemPos);

			// recreate the worklist file, with the node removed
			startString = '<?xml version="1.0" encoding="UTF-8" ?><worklist>';
			endString = "</worklist>";
			xmlString = "";
			for (j=1;j LTE arrayLen(xmlItems);j=(j+1))
			{
				xmlStringTemp = removeChars(xmlParse(xmlItems[j]),1,len('<?xml version="1.0" encoding="UTF-8" ?>'));
				xmlString = listAppend(xmlString,xmlStringTemp," ");
			}
			finalString = startString & xmlString & endString;
			writeWorkListFile(finalString);
			itemsExist = true;

			if(workItemType EQ "CR" OR workItemType EQ "DD"){
				// unlock the deduction
				deductionLocking(arguments.typid,"unlock");
			} else if (workItemType EQ "BB"){
				// unlock the deduction
				billbackLocking(arguments.typid,"unlock");
			}

			// THIRD: delete the associated match list XML file
			fileString = this.MatchCentralPath & "\" & arguments.typid & "-matchlist.xml";
			if(this.cfVersion GTE 8){
				if(fileExists(fileString)){
					fileDelete(fileString);
				}
			}

			// if the master array has no length, then run the clear worklist function to clear all
			if(arrayLen(xmlItems) EQ 0){
				clearWorkList();
				itemsExist = false;
			}
		</cfscript>

		<cfif this.cfVersion LTE 7>
			<cfif fileExists(fileString)>
				<cffile action="delete" file="#fileString#">
			</cfif>
		</cfif>

		<cfreturn itemsExist>

	</cffunction>
	<cffunction name="addToWorkList"
				access="public"
				returntype="xml"
				output="true"
				displayname="AddToWorkList">

		<cfargument name="typid" required="true" type="string" hint="work item id">
		<cfargument name="typ" required="true" type="string" hint="work item type">
		<cfargument name="matchtype" required="true" type="string" hint="what type is being matched to the work item">

		<cfswitch expression="#arguments.typ#">
			<cfcase value="DD">
				<cfquery name="deductions" datasource="#this.dsn#">
					SELECT DD.DD_DedID + ' - ' + ISNULL(DD.SP_Number, '000') AS DD_DedID, DD.Deduction_ID, DD.DD_Amount, DD.DD_Status, DD.Distributor_ID, U.Name_First, U.Name_Last, DD.DD_Check_Number, DD.DD_Reference
					FROM Deductions DD LEFT JOIN _Users U ON DD.Analyst_User_ID = U.User_ID
					WHERE DD.Deduction_ID LIKE '%#arguments.typid#%'
						AND DD.deleted = 0
					ORDER BY DD_DedID
				</cfquery>

				<cfscript>

					if (NOT fileExists("#this.MatchCentralPath#\worklist.xml")){
						xmlDoc = XmlNew();
						xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"worklist");
						xmlNodePos = 1;
						xmlMasterNodePos = 1;
					} else {
						ddNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/ded"));
						bbNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/bb"));
						crNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/crd"));
						xmlMasterNodePos = ddNodes + bbNodes + crNodes + 1;
						xmlNodePos = ddNodes + 1;
					}

					if(deductions.recordCount){

						//lock the deduction
						deductionLocking(arguments.typid,"lock");

						xmlDoc.worklist.XmlChildren[xmlMasterNodePos] = XmlElemNew(xmlDoc,"ded");

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"dd_dedid");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[1].XmlText = deductions.dd_dedid;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"deduction_id");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[2].XmlText = deductions.deduction_id;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"dd_amount");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[3].XmlText = deductions.dd_amount;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[4] = XmlElemNew(xmlDoc,"dd_status");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[4].XmlText = deductions.dd_status;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[5] = XmlElemNew(xmlDoc,"analyst_name");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[5].XmlText = "#deductions.name_first# #deductions.name_last#";

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[6] = XmlElemNew(xmlDoc,"distributor_id");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[6].XmlText = deductions.distributor_id;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[7] = XmlElemNew(xmlDoc,"match_type");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[7].XmlText = arguments.matchtype;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[8] = XmlElemNew(xmlDoc,"typ");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[8].XmlText = arguments.typ;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[9] = XmlElemNew(xmlDoc,"dd_check_number");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[9].XmlText = deductions.dd_check_number;

						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[10] = XmlElemNew(xmlDoc,"dd_reference");
						xmlDoc.worklist.ded[xmlNodePos].XmlChildren[10].XmlText = deductions.dd_reference;

					}
				</cfscript>

			</cfcase>
			<cfcase value="BB">

				<cfscript>
					bbInfo = getBBInfo(arguments.typid);

					if (NOT fileExists("#this.MatchCentralPath#\worklist.xml")){
						xmlDoc = XmlNew();
						xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"worklist");
						xmlNodePos = 1;
						xmlMasterNodePos = 1;
					} else {
						ddNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/ded"));
						bbNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/bb"));
						crNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/crd"));
						xmlMasterNodePos = ddNodes + bbNodes + crNodes + 1;
						xmlNodePos = bbNodes + 1;
					}

					if(bbInfo.recordCount){

						//lock the billback
						billbackLocking(arguments.typid,"lock");

						xmlDoc.worklist.XmlChildren[xmlMasterNodePos] = XmlElemNew(xmlDoc,"bb");

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"bb_code");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[1].XmlText = bbInfo.bb_code;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"billback_id");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[2].XmlText = bbInfo.billback_id;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"bb_title");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[3].XmlText = bbInfo.bb_title;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[4] = XmlElemNew(xmlDoc,"bb_approved_amount");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[4].XmlText = bbInfo.bb_approved_amount;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[5] = XmlElemNew(xmlDoc,"match_type");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[5].XmlText = arguments.matchtype;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[6] = XmlElemNew(xmlDoc,"payee_id");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[6].XmlText = bbInfo.payee_id;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[7] = XmlElemNew(xmlDoc,"payee_name");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[7].XmlText = bbInfo.payee_name;

						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[8] = XmlElemNew(xmlDoc,"typ");
						xmlDoc.worklist.bb[xmlNodePos].XmlChildren[8].XmlText = arguments.typ;

					}
				</cfscript>

			</cfcase>
			<cfcase value="CR">
				<cfquery name="deductions" datasource="#this.dsn#">
					SELECT DD.DD_DedID + ' - ' + ISNULL(DD.SP_Number, '000') AS DD_DedID, DD.Deduction_ID, DD.DD_Amount, DD.DD_Status, DD.Distributor_ID, U.Name_First, U.Name_Last, DD.DD_Check_Number, DD.DD_Reference
					FROM Deductions DD INNER JOIN _Users U ON DD.Analyst_User_ID = U.User_ID
					WHERE DD.Deduction_ID LIKE '%#arguments.typid#%'
						AND DD.deleted = 0
					ORDER BY DD_DedID
				</cfquery>

				<cfscript>

					if (NOT fileExists("#this.MatchCentralPath#\worklist.xml")){
						xmlDoc = XmlNew();
						xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"worklist");
						xmlNodePos = 1;
						xmlMasterNodePos = 1;
					} else {
						ddNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/ded"));
						bbNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/bb"));
						crNodes = arrayLen(XmlSearch(xmlDoc, "/worklist/crd"));
						xmlMasterNodePos = ddNodes + bbNodes + crNodes + 1;
						xmlNodePos = crNodes + 1;
					}

					if(deductions.recordCount){

						//lock the deduction
						deductionLocking(arguments.typid,"lock");

						xmlDoc.worklist.XmlChildren[xmlMasterNodePos] = XmlElemNew(xmlDoc,"crd");

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"dd_dedid");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[1].XmlText = deductions.dd_dedid;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"deduction_id");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[2].XmlText = deductions.deduction_id;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"dd_amount");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[3].XmlText = deductions.dd_amount;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[4] = XmlElemNew(xmlDoc,"dd_status");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[4].XmlText = deductions.dd_status;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[5] = XmlElemNew(xmlDoc,"analyst_name");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[5].XmlText = "#deductions.name_first# #deductions.name_last#";

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[6] = XmlElemNew(xmlDoc,"distributor_id");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[6].XmlText = deductions.distributor_id;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[7] = XmlElemNew(xmlDoc,"match_type");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[7].XmlText = arguments.matchtype;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[8] = XmlElemNew(xmlDoc,"typ");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[8].XmlText = arguments.typ;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[9] = XmlElemNew(xmlDoc,"dd_check_number");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[9].XmlText = deductions.dd_check_number;

						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[10] = XmlElemNew(xmlDoc,"dd_reference");
						xmlDoc.worklist.crd[xmlNodePos].XmlChildren[10].XmlText = deductions.dd_reference;

					}
				</cfscript>

			</cfcase>
		</cfswitch>

		<cfset writeWorkListFile(xmlDoc)>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="getWorkListXMLArray"
				access="public"
				returntype="array"
				output="true"
				displayname="getXMLArray">

		<cfscript>
			itemTypeList = "ded,bb,crd";
			allItemArray = arrayNew(1);

			for (i=1;i LTE listLen(itemTypeList);i=(i+1)){
				itemType = listGetAt(itemTypeList,i);
				xmlDoc = xmlParse(readWorkListFile());
				xmlItems = XmlSearch(xmlDoc, "/worklist/#itemType#");
				itemStruct = structNew();

				for (j=1;j LTE arrayLen(xmlItems);j=(j+1))
				{
					itemArray = xmlItems[j].xmlChildren;
						for (k=1;k LTE arrayLen(itemArray);k=(k+1))
						{
							varName = itemArray[k].xmlName;
							varVal = itemArray[k].xmlText;
							structInsert(itemStruct,varName,varVal);
						}

					arrayAppend(allItemArray,itemStruct);
					itemStruct = structNew();
				}
			}
		</cfscript>

		<cfreturn allItemArray>

	</cffunction>

	<cffunction name="getWorkListXMLArrayIndex"
				access="public"
				returntype="numeric"
				output="true"
				displayname="getWorkListXMLArrayIndex">

        <cfargument name="findWorkItemID" required="true" type="string" />
        <cfset returnValue = 0 />

        <cfset itemArray = getWorkListXMLArray()>

        <cfloop from="1" to="#arrayLen(itemArray)#" index="row">
			<cfscript>
				workItemType = itemArray[row].typ;
				if (workItemType EQ "DD"){
					workItemID = itemArray[row].deduction_id;

				} else if (workItemType EQ "CR"){
					workItemID = itemArray[row].deduction_id;

				} else if (workItemType EQ "BB"){
					workItemID = itemArray[row].billback_id;

				}

                if(workItemID == arguments.findWorkItemID)
                    returnValue = row;
			</cfscript>
        </cfloop>

		<cfreturn returnValue />

	</cffunction>

	<!--- MATCH LIST FUNCTIONS --->
	<cffunction name="writeMatchListFile"
				access="public"
				returntype="void"
				output="false"
				displayname="writematchlistFile">

		<cfargument name="fileData" required="true" default="" type="string" />
		<cfargument name="workItemID" required="true" type="string" />

		<cffile action="write" file="#this.MatchCentralPath#\#arguments.workItemID#-matchlist.xml" output="#arguments.fileData#" />

	</cffunction>
	<cffunction name="readMatchListFile"
				access="public"
				returntype="xml"
				output="false"
				displayname="readMatchListFile">

		<cfargument name="workItemID" required="true" type="string">
		<cfargument name="path" required="false" default="" type="string">

		<cfif arguments.path NEQ "">
			<cfif fileExists("#arguments.path#\#arguments.workItemID#-matchlist.xml")>
				<cffile action="read" file="#arguments.path#\#arguments.workItemID#-matchlist.xml" variable="xmlDoc">
			<cfelse>
				<cfset xmlDoc = '<?xml version="1.0" encoding="UTF-8" ?><matchlist></matchlist>'>
			</cfif>
		<cfelse>
			<cfif fileExists("#this.MatchCentralPath#\#arguments.workItemID#-matchlist.xml")>
				<cffile action="read" file="#this.MatchCentralPath#\#arguments.workItemID#-matchlist.xml" variable="xmlDoc">
			<cfelse>
				<cfset xmlDoc = '<?xml version="1.0" encoding="UTF-8" ?><matchlist></matchlist>'>
			</cfif>
		</cfif>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="clearMatchlistItem"
				access="public"
				returntype="boolean"
				output="true"
				displayname="Clear Match List Item">

		<cfargument name="workItemID" required="true" type="string">
		<cfargument name="matchItemID" required="true" type="string">

		<cfscript>
			matchingType = getMatchingType(arguments.workItemID);
			xmlDoc = readMatchListFile(arguments.workItemID);
			xmlDoc = xmlParse(xmlDoc);

			if (matchingType EQ "BB"){
				xmlnode = XmlSearch(xmlDoc, "/matchlist/bb");
				nodeArray = XmlSearch(xmlDoc, "/matchlist/bb/billback_id/");
				billbackLocking(arguments.matchItemID,"unlock");
			} else if (matchingType EQ "CR"){
				xmlnode = XmlSearch(xmlDoc, "/matchlist/cr");
				nodeArray = XmlSearch(xmlDoc, "/matchlist/cr/deduction_id/");
				deductionLocking(arguments.matchItemID,"unlock");
			} else if (matchingType EQ "DD"){
				xmlnode = XmlSearch(xmlDoc, "/matchlist/dd");
				nodeArray = XmlSearch(xmlDoc, "/matchlist/dd/deduction_id/");
				deductionLocking(arguments.matchItemID,"unlock");
			}

				for (i=1;i LTE arrayLen(nodeArray);i=(i+1))
				{
					id2 = nodeArray[i].XmlText;

					if (arguments.matchItemID EQ id2){
						elemPos = i;
						break;
					}
				}
				ArrayDeleteAt(xmlnode, elemPos);

				startString = '<?xml version="1.0" encoding="UTF-8" ?><matchlist>';
				endString = "</matchlist>";
				xmlString = "";
				for (j=1;j LTE arrayLen(xmlnode);j=(j+1))
				{
					xmlStringTemp = removeChars(xmlParse(xmlnode[j]),1,len('<?xml version="1.0" encoding="UTF-8" ?>'));
					xmlString = listAppend(xmlString,xmlStringTemp," ");
				}
				finalString = startString & xmlString & endString;
				writematchlistFile(finalString,arguments.workItemID);
				itemsExist = true;


		</cfscript>


		<cfreturn itemsExist>

	</cffunction>
	<cffunction name="addBBToMatchList"
				access="public"
				returntype="xml"
				output="false"
				displayname="addBBToMatchList">

		<cfargument name="bbid" required="true" type="string" />
		<cfargument name="workItemid" required="true" type="string" />

		<cfquery name="qBillback" datasource="#this.dsn#">
			SELECT BB.Billback_ID, BB.BB_Amount, BB.BB_Title, BB.BB_Code, BBAL.BB_Is_Locked, BBA.Paid_Amount AS BB_Approved_Amount
			FROM Billback BB
				INNER JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
				INNER JOIN Billback_Allied BBAL ON BBAL.Billback_ID = BB.Billback_ID
			WHERE BB.Billback_ID LIKE '%#arguments.bbid#%'
		</cfquery>

		<cfscript>
			bblist = selectedBBlist();
			bbexists = listFind(bblist,arguments.bbid);


			if (bbexists EQ 0 AND NOT qBillback.bb_is_locked){
				//lock the billback
				billbackLocking(arguments.bbid,"lock");
				if (NOT fileExists("#this.MatchCentralPath#\#arguments.workItemid#-matchlist.xml")){
					xmlDoc = XmlNew();
					xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"matchlist");
					xmlNodePos = 1;
				} else {
					xmlDoc = readMatchListFile(workItemID);
					xmlDoc = XMLParse(xmlDoc);
					xmlNodePos = arrayLen(XmlSearch(xmlDoc, "/matchlist/bb")) + 1;
				}

				xmlDoc.matchlist.XmlChildren[xmlNodePos] = XmlElemNew(xmlDoc,"bb");

				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"billback_id");
				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[1].XmlText = qBillback.billback_id;

				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"bb_code");
				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[2].XmlText = qBillback.bb_code;

				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"bb_title");
				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[3].XmlText = qBillback.bb_title;

				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[4] = XmlElemNew(xmlDoc,"bb_approved_amount");
				xmlDoc.matchlist.bb[xmlNodePos].XmlChildren[4].XmlText = qBillback.bb_approved_amount;

				writeMatchListFile(xmlDoc,arguments.workItemid);
			} else {
				xmlDoc = readMatchListFile(arguments.workItemid);
			}
		</cfscript>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="addDDToMatchList"
				access="public"
				returntype="xml"
				output="true"
				displayname="addDDToMatchList">

		<cfargument name="ddid" required="true" type="string">
		<cfargument name="workItemid" required="true" type="string">

		<cfscript>
			ddInfo = this.DDMgr.getDeduction(arguments.ddid);
			ddlist = workListIDList() & "," & selectedDDlist();
			ddexists = listFind(ddlist,arguments.ddid);

			if (ddexists EQ 0 AND NOT ddInfo.is_locked){
				//lock the deduction
				deductionLocking(arguments.ddid,"lock");
				if (NOT fileExists("#this.MatchCentralPath#\#arguments.workItemid#-matchlist.xml")){
					xmlDoc = XmlNew();
					xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"matchlist");
					xmlNodePos = 1;
				} else {
					xmlDoc = readMatchListFile(workItemID);
					xmlDoc = XMLParse(xmlDoc);
					xmlNodePos = arrayLen(XmlSearch(xmlDoc, "/matchlist/dd")) + 1;
				}

				xmlDoc.matchlist.XmlChildren[xmlNodePos] = XmlElemNew(xmlDoc,"dd");

				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"deduction_id");
				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[1].XmlText = ddinfo.deduction_id;

				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"dd_dedid");
				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[2].XmlText = ddinfo.dd_dedid;

				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"dd_amount");
				xmlDoc.matchlist.dd[xmlNodePos].XmlChildren[3].XmlText = ddinfo.dd_amount;

				writeMatchListFile(xmlDoc,arguments.workItemid);
			} else {
				xmlDoc = readMatchListFile(arguments.workItemid);
			}
		</cfscript>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="addCRToMatchList"
				access="public"
				returntype="xml"
				output="true"
				displayname="addDDToMatchList">

		<cfargument name="crdid" required="true" type="string">
		<cfargument name="workItemid" required="true" type="string">

		<cfscript>
			crInfo = this.DDMgr.getDeduction(arguments.crdid);
			crlist = workListIDList() & "," & selectedCRlist();
			crexists = listFind(crlist,arguments.crdid);

			if (crexists EQ 0 AND NOT crInfo.is_locked){
				//lock the deduction
				deductionLocking(arguments.crdid,"lock");
				if (NOT fileExists("#this.MatchCentralPath#\#arguments.workItemid#-matchlist.xml")){
					xmlDoc = XmlNew();
					xmlDoc.xmlRoot = XmlElemNew(xmlDoc,"matchlist");
					xmlNodePos = 1;
				} else {
					xmlDoc = readMatchListFile(workItemID);
					xmlDoc = XMLParse(xmlDoc);
					xmlNodePos = arrayLen(XmlSearch(xmlDoc, "/matchlist/cr")) + 1;
				}

				xmlDoc.matchlist.XmlChildren[xmlNodePos] = XmlElemNew(xmlDoc,"cr");

				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[1] = XmlElemNew(xmlDoc,"deduction_id");
				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[1].XmlText = crInfo.deduction_id;

				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[2] = XmlElemNew(xmlDoc,"dd_dedid");
				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[2].XmlText = crInfo.dd_dedid;

				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[3] = XmlElemNew(xmlDoc,"dd_amount");
				xmlDoc.matchlist.cr[xmlNodePos].XmlChildren[3].XmlText = crInfo.dd_amount;

				writeMatchListFile(xmlDoc,arguments.workItemid);
			} else {
				xmlDoc = readMatchListFile(arguments.workItemid);
			}
		</cfscript>

		<cfreturn xmlDoc>

	</cffunction>
	<cffunction name="getMatchListXMLArray"
				access="public"
				returntype="array"
				output="true"
				displayname="getXMLArray">

		<cfargument name="workItemID" required="false" default="" type="string">

		<cfscript>
			if (fileExists("#this.MatchCentralPath#\#arguments.workItemID#-matchlist.xml")) {
				matchingType = getMatchingType(arguments.workItemID);
				xmlDoc = readMatchListFile(arguments.workItemID);
				xmlDoc = xmlParse(xmlDoc);

				if (matchingType EQ "BB") {
					xmlNode = XmlSearch(xmlDoc, "/matchlist/bb");
				} else if (matchingType EQ "DD") {
					xmlNode = XmlSearch(xmlDoc, "/matchlist/dd");
				} else if (matchingType EQ "CR") {
					xmlNode = XmlSearch(xmlDoc, "/matchlist/cr");
				} else {
					xmlNode = arrayNew(1);
				}

				if (arrayLen(xmlNode) GT 0){
					mlArray = arrayNew(1);
					itemStruct = structNew();

					for (i=1;i LTE arrayLen(xmlNode);i=(i+1))
						{
							itemArray = xmlNode[i].xmlChildren;
								for (j=1;j LTE arrayLen(itemArray);j=(j+1))
								{
									varName = itemArray[j].xmlName;
									varVal = itemArray[j].xmlText;
									structInsert(itemStruct,varName,varVal);
								}

							arrayAppend(mlArray,itemStruct);
							itemStruct = structNew();
						}
				} else {
					mlArray = arrayNew(1);
				}
			} else {
				mlArray = arrayNew(1);
			}
		</cfscript>

		<cfreturn mlArray>

	</cffunction>

	<!--- PROCESSING FUNCTIONS --->
	<cffunction name="getReasonCodes"
					access="public"
					returntype="query"
					output="false"
					displayname="getReasonCodes">

		<cfargument name="workItemID" required="true" type="string">

		<cfset workItemInfo = this.DDMgr.getDeduction(arguments.workItemID)>

		<cfquery name="AutoCloseReason" datasource="#application.datasource#">
			SELECT DD_Reason_Code_ID
			FROM DD_Auto_Close
		</cfquery>
		<cfquery name="GetReasonCodes" datasource="#application.datasource#">
			SELECT *
			FROM DD_Reason_Code
			WHERE Deleted = 0 AND Display_In IN (1,3)
			<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
				AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
			</CFIF>
			<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
				<CFIF len(trim(workItemInfo.DD_Closure_ID)) GT 0 AND workItemInfo.DD_Closure_Type IS 1>
					AND Closing_Method = 1
				<CFELSEIF len(trim(workItemInfo.DD_Closure_ID)) GT 0 AND workItemInfo.DD_Closure_Type EQ 5>
					AND Closing_Method = 2
				<CFELSEIF (len(workItemInfo.Is_Last_Status_Rebill) GT 0 AND workItemInfo.Is_Last_Status_Rebill)>
					AND Closing_Method = 4
				<CFELSEIF (len(workItemInfo.Is_Write_Off) GT 0 AND workItemInfo.Is_Write_Off)>
					AND Closing_Method = 3
				<CFELSEIF (len(workItemInfo.DD_Rejected) GT 0 AND workItemInfo.DD_Rejected)>
					AND Closing_Method = 5
				</CFIF>
			</CFIF>
			ORDER BY DD_Reason_Code_Description
		</cfquery>

		<cfreturn GetReasonCodes>

	</cffunction>
	<cffunction name="splitDD"
					access="public"
					returntype="array"
					output="false"
					displayname="splitRemaining"
					hint="">

		<cfargument name="ddID" required="true" type="string">
		<cfargument name="bbID" required="true" type="string">
		<cfargument name="classificationID" required="true" type="numeric">
		<cfargument name="splitReason" required="true" type="string">
		<cfargument name="classificationIDForSplit" required="true" type="numeric">

		<cfscript>
			totalBillbackApprovedAmount = this.BBMgr.getBillbackPaidAmountMulti(billbackIDList = bbID);
			returnArray = this.DDMgr.splitDeduction(
				deductionId = ddID,
				newDeductionAmount = totalBillbackApprovedAmount,
				currentRecordSplitClassificationID = classificationID,
				currentRecordSplitReason = splitReason,
				balanceRecordSplitClassificationID = classificationIDForSplit,
				balanceRecordSplitReason = splitReason);
		</cfscript>

		<cfreturn returnArray>

	</cffunction>
	<cffunction name="writeOffDD"
					access="public"
					returntype="void"
					output="false"
					displayname="writeOffDD"
					hint="">

		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="DD_Write_Off_Reason" required="true" type="string">


		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Is_Write_Off = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					Write_Off_By = <cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">,
					Write_Off_Date = getdate(),
					Write_Off_Reason = <cfqueryparam value="#arguments.DD_Write_Off_Reason#" cfsqltype="cf_sql_varchar">

			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>

	</cffunction>
	<!--- Ana D19384 - Rebill Integration  --->
	<cffunction name="rebillDD"
					access="public"
					returntype="void"
					output="false"
					displayname="rebillDD"
					hint="">

		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="DD_Rebill_Package_Hrd_ID" required="true" type="numeric">
		<cfargument name="Rebill_Message_DF" required="true" type="string">
		<cfargument name="Rebill_Message_AddOn" required="true" type="string">
		<cfargument name="DD_Classification_ID" required="true" type="numeric">
		<cfargument name="DD_Reason_Code_ID" required="true" type="numeric">

		<CFQUERY NAME="DelExist" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Rebill_Integration
			SET 	Deleted = 1,
					Deleted_Date = getdate()
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> AND
					Deleted = 0
		</CFQUERY>

		<CFIF arguments.Rebill_Message_DF NEQ "">
		<CFSET Rebill_Message = "#arguments.Rebill_Message_DF#  #arguments.Rebill_Message_AddOn#">
		</CFIF>

		<CFQUERY NAME="InsRebill" DATASOURCE="#Application.Datasource#">
			INSERT 	DD_Rebill_Integration
					(	Deduction_ID,
						DD_Rebill_Package_Hrd_ID,
						Rebill_Message_DF,
						Rebill_Message_AddOn,
						DD_Classification_ID,
						DD_Reason_Code_ID,
						Rebill_By,
						Rebill_Ack_Status

					)
			SELECT 	<cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.DD_Rebill_Package_Hrd_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.Rebill_Message_DF#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.Rebill_Message_AddOn#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.DD_Classification_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.DD_Reason_Code_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#this.matchCentralUserID#" cfsqltype="cf_sql_varchar">			,
					1
		</CFQUERY>

		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Status = <cfqueryparam value="7" cfsqltype="cf_sql_numeric">,
					DD_Classification_ID = <cfqueryparam value="#arguments.DD_Classification_ID#" cfsqltype="cf_sql_numeric">,
					DD_Resolution_Code = <cfqueryparam value="#arguments.DD_Reason_Code_ID#" cfsqltype="cf_sql_numeric">,
					Is_Last_Status_Rebill = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					rebill_date = getdate()
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>

	</cffunction>

	<cffunction name="AssociateDDtoBB"
					access="public"
					returntype="any"
					output="true"
					displayname="AssociateDDtoBB">

		<cfargument name="BBParentID" required="true" type="string">
		<cfargument name="DDList" required="true" type="string">
		<cfargument name="splitStartCount" required="true" type="numeric">

		<cfset loopCount = arguments.splitStartCount />
		<cfloop list="#arguments.DDList#" index="DDID">
			<cfset loopCount = loopCount + 1>
			<cfif loopCount LT 10>
				<cfset splitNum = "0#loopCount#">
			<cfelse>
				<cfset splitNum = "#loopCount#">
			</cfif>
			<cfquery name="qGetDDAmount" datasource="#application.datasource#">
				SELECT DD_Amount
				FROM Deductions
				WHERE Deduction_ID = '#DDID#'
			</cfquery>
			<cfquery name="qGetBBInfo" datasource="#application.datasource#">
				SELECT BB.Billback_ID
				FROM Billback BB INNER JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
				WHERE BB.BB_Parent_ID = '#arguments.BBParentID#'
					AND BBA.Paid_Amount = '#qGetDDAmount.DD_Amount#'
					AND BB.BB_Split_Number = '#splitNum#'
					AND BB.Billback_Status_ID <> 5
			</cfquery>

			<cfset this.DDMgr.setAssociatedBB(Deduction_ID = DDID,Billback_ID = qGetBBInfo.Billback_ID)>

		</cfloop>

	</cffunction>

	<cffunction name="getBBToAssociate"
					access="public"
					returntype="any"
					output="true"
					displayname="getBBToAssociate">

		<cfargument name="BBParentID" required="true" type="string">
		<cfargument name="BBAmount" required="true" type="string">
		<cfargument name="splitIndex" required="true" type="numeric">

		<cfset loopCount = arguments.splitIndex />
		<cfif loopCount LT 10>
			<cfset splitNum = "0#loopCount#">
		<cfelse>
			<cfset splitNum = "#loopCount#">
		</cfif>

		<cfquery name="qGetBBInfo" datasource="#application.datasource#">
			SELECT BB.Billback_ID
			FROM Billback BB INNER JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
			WHERE BB.BB_Parent_ID = '#arguments.BBParentID#'
				AND BBA.Paid_Amount = '#arguments.BBAmount#'
				AND BB.BB_Split_Number = '#splitNum#'
				AND BB.Billback_Status_ID <> 5
		</cfquery>

		<cfreturn qGetBBInfo.Billback_ID />

	</cffunction>

	<cffunction name="getIsDeductionAvailableForMatching"
					access="public"
					returntype="numeric"
					output="true"
					displayname="getCanDeductionsBeMatched">

		<cfargument name="Deduction_ID" required="true" type="string">

		<!--- Below logic comes from "DEDUCTIONS\search_screens\Ded_Search_Query.cfm".
		The issue is that there are duplicate splits for a deduction. This query will
		not return this deduction, so it cannot be processed more than once.
		--->
		<cfquery name="qGetCanDeductionsBeMatched" datasource="#application.datasource#">
			SELECT count(*) As Dedcount
			FROM Deductions
			WHERE Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> AND
			Deductions.DD_Status NOT IN (4,5,6,9) AND
			<!--- If a deduction (parent or child) is closed (deduction amount matching the billback amount),
			then DD_Closure_ID will not be NULL and so this condition will prevent it from being returned.
			--->
			Deductions.DD_Closure_ID IS NULL AND
			Deductions.Is_Write_Off = 0 AND
			<!--- If a parent deduction is split, then Split_Count will be more than 0,
			and so this condition will prevent it from being returned. --->
			Deductions.Split_Count = 0
			<!--- If a child deduction(split) is further split, then that child deduction will be set to
			deleted = 1, and so this condition will prevent it from being returned.
			--->
			AND Deductions.deleted = 0
		</cfquery>

		<cfreturn qGetCanDeductionsBeMatched.Dedcount />

	</cffunction>
	<cffunction name="getDDAutoMatchSettings"
					access="public"
					returntype="query"
					output="true"
					displayname="getDDAutoMatchSettings">
		<CFQUERY NAME="qGetAutoMatch" DATASOURCE="#Application.Datasource#">
			SELECT	DD_Auto_Match_ID,Enabled,Dollar_Amount,Dollar_Amount_Value,Match_Reference_Number,Match_Distributor_Bill_To,
						Match_Distributor_Ship_To,Auto_Match_DD_Reason_Code_ID,	Write_Off_DD_Reason_Code_ID,Use_Auto_Match_DD_Reason_Code,
						Use_Write_Off_DD_Reason_Code,Deduction_Status_After_Auto_Match,Write_Off_Dollar_Amount_Value,Auto_Match_Reconcile <!--- 61842 --->
						,Reconcile_Dollar_Amount_Value <!---98653--->
			FROM	DD_Auto_Match
		</CFQUERY>
		<cfreturn qGetAutoMatch />
	</cffunction>
<cffunction name="dumper" access="remote" output="false">
		<cfargument name="arrBBPDIR"	required="true"		type="any" />
		<cfargument name="filename" required = "true" type="string" />
		<cfdump var="#arguments.arrBBPDIR#" output="#arguments.filename#" />

		<cfreturn />
	</cffunction>
<!---
Usage in script:
<cfscript>
	dumper(arrBBPDir,"C:\CFdumptemp\arrBBPDir.txt");
</cfscript>
--->

</cfcomponent>