 <!-----------------------------------------------------------------------------

FILE NAME:		DeductionManager.cfc
DESCRIPTION:	Deduction Manager to manage different functions for the 
				Deductions
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	01-Jun-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent alias="mvc.Models.Deduction.DeductionManager" extends="mvc.Models.SettingsService" output="false">

	<cfset appSettings = application.appSettingsGet />
	
	<cfscript>
		variables.oDeductionDAO = createObject('component','mvc.Models.Deduction.DeductionDAO');
		variables.oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO");
	</cfscript>	
	
	<cffunction name="init" output="false" returntype="mvc.Models.Deduction.DeductionManager">
		<cfreturn this />
	</cffunction>

	<cffunction name="getDeductionsJSON" returntype="string"  access="remote" returnformat="JSON">
		<cfargument name="bbDeductionFilterParms" type="any">

		<cfscript>
			var bbdf = deserializejson(arguments.bbDeductionFilterParms);

			var arr = this.getDeductions(bbdf);
			//writedump(var="#arr#", output="c:\dump.log");
			return serializeJson(arr);
		</cfscript>

	</cffunction>
	
	<!--- 
		This function works exactly like the 
		/Deductions/Search_screens/Ded_Search_Query.cfm file and will return the Deduction
		Object in an array when a Billback_ID is passed to it.
	--->
	<cffunction name="getDeductions" returntype="array"  access="remote" hint="This function will call different functions and return the list of Deductions for the given Billback ID">
		<cfargument name="bbDeductionFilterParms" type="any">
		<cfscript>
			var qGetBillback = '';
			var billbackID = '';
			var FILTERdistributor = arguments.bbDeductionFilterParms.bDistributor;
			var FILTERamount = arguments.bbDeductionFilterParms.bAmount;
			var FILTERremainingBalance = arguments.bbDeductionFilterParms.bBalance;
			var keyword = arguments.bbDeductionFilterParms.sKeyword;
			var remainBalance = arguments.bbDeductionFilterParms.nBalance;
			var strDistributorId = arguments.bbDeductionFilterParms.strDistributorId;
			
		</cfscript>
		<cfset qGetBillback =   variables.oBillbackDAO.getBBRecord(arguments.bbDeductionFilterParms.iBillbackId) />
		<cfset billbackID = qGetBillback.Billback_ID />
		
		<!---<cfargument name="billbackID" 				required="true"  type="string">
		<cfargument name="FILTERdistributor" 		required="false" type="boolean" default="false">
		<cfargument name="FILTERamount"  			required="false" type="boolean" default="false">
		<cfargument name="FILTERremainingBalance" 	required="false" type="boolean" default="false">
		<cfargument name="keyword"  				required="false" type="string" default="">
		<cfargument name="remainBalance"  			required="false" type="numeric" default="1000000">--->
		
		<cfset stForm = StructNew() />
 
		<cfparam name="stForm.Selected_Distributor" default="">
		<cfparam name="Selected_Broker" default="">
		<cfparam name="stForm.Distributor_List" default="">
		<cfparam name="stForm.Broker_List" 	default="">
		<cfparam name="stForm.DD_Number" default="">
		<cfparam name="stForm.Dollar_Operator" default="=">
		<cfparam name="stForm.DD_Amount" default="">
		<cfparam name="stForm.DD_To_Amount" default="">
		<cfparam name="stForm.Date_Operator" default="=">
		<cfparam name="stForm.Date_Time" default="">
		<cfparam name="stForm.To_Date_Time" default="">
		
		<cfparam name="stForm.ClDate_Operator" default="">
		<cfparam name="stForm.ClDate_Time" default="">
		<cfparam name="stForm.ClTo_Date_Time" default="">
		<cfparam name="stForm.C1AR_Reference" default="">
		<cfparam name="stForm.C1Cust_RefNo" default="">
		
		<cfparam name="stForm.Check_No" default="">
		<cfparam name="stForm.Service_Market_ID" default="">
		<cfparam name="stForm.Distributor" default="">
		<cfparam name="stForm.Distributor_Name" default="">
		<cfparam name="stForm.Family_ID" default="">
		<cfparam name="stForm.Analyst_User_ID" default="">
		<cfparam name="stForm.Service_Region_ID" default="">
		<cfparam name="stForm.Broker" default="">
		<cfparam name="stForm.DD_Stage_ID" default="">
		<cfparam name="stForm.DD_Aging" default="">
		<cfparam name="stForm.Service_Zone_ID" default="">
		<cfparam name="stForm.DD_Reason_Code_ID" default="">
		<cfparam name="stForm.DD_Status" default="">
		<cfparam name="stForm.DD_Parent_ID" default="">
		<cfparam name="stForm.Form_Submitted" default="">
		<cfparam name="SubmitTheForm" default="0">
		<cfparam name="stForm.Distributor_Bill_To_ID" default="">
		<cfparam name="stForm.Distributor_Bill_To" default="">
		<cfparam name="stForm.Line_Of_Business_ID" default="">
		<cfparam name="stForm.DD_Operator_ID" default="">
		<cfparam name="stForm.IsBusEnabled" default="">
		<cfparam name="stForm.Business_Segment_ID" default="">
		<cfparam name="stForm.Q_Brand_ID" default="">
		<cfparam name="stForm.DD_Operator_ID" default="">
		<cfparam name="stForm.Operating_Unit_ID" default="">
		<cfparam name="stForm.AccessAllDeductions" default="0">
		<cfparam name="stForm.DD_Ref" default="">
		<cfparam name="stForm.DDAmountFilter" default="">
		<cfparam name="stForm.MC_Shr_Ship_to" default="">
		<cfparam name="stForm.MC_Shr_Bill_To" default="">
		<cfparam name="stForm.MC_Bill_To_Name" default="">
		<cfparam name="stForm.MC_Distributor_Name" default="">
		<cfparam name="stForm.Broker_Name" default="">
		<cfparam name="stForm.SearchSource" default="">
		<cfparam name="isFlexSettlement" default="false">
		 
		<cfparam name="stForm.startrow"  default="1">
		<cfparam name="stForm.frompage"   default="1">
		<cfparam name="stForm.pageLength"  default=10>
		
		<cfparam name="stForm.SORT_BY" 	default="DD_DedID_SP_Number">
		<cfparam name="stForm.SORT_ORDER" 	default="ASC">
		<cfparam name="stForm.IsParentDeduction" 	default="0">
		<cfparam name="stForm.Filter_Closed" default="0">
		<cfparam name="stForm.Only_DD_With_Inactive_Relations" default="0">
		<cfparam name="stForm.Filter_Attached" default="0">
		<cfparam name="stForm.Rebill_Number" default="">
		
		<cfparam name="stForm.Classification" default="0">   
		<cfparam name="stForm.DeductionType" default="0">   
		<cfparam name="sortField" default="BB_Approved_Amount">
		<cfparam name="sortOrder" default="DESC">

		<cfscript>
		MCObject = createObject("Component","components.Match_Central.MatchCentral").init();
		workItemType = 'BB';
		matchingType = 'DD';	// workItem	
		stForm.Filter_Attached = 1;
		stForm.Filter_Closed = 1;
		stForm.IsParentDeduction = 1;
		stForm.MC_Shr_Ship_to = "";
		stForm.MC_Distributor_Name = "";
		stForm.MC_Shr_Bill_To = "";
		stForm.MC_Bill_To_Name = "";
		workList = MCObject.workListIDList;
		isFlexSettlement = true;
		businessSegmentID = "";
				
		if (workItemType EQ "CR" OR workItemType EQ "DD"){
			if (workItemType EQ "CR"){
				stForm.SearchSource  = "MatchCentralDD";
				sortField = "DD_Amount";
				sortOrder = "DESC";
			} else if (workItemType EQ "DD"){
				stForm.SearchSource  = "MatchCentralCR";
				sortField = "DD_Amount";
				sortOrder = "ASC";
			}
			CRDInfo = MCObject.DDMgr.getDeduction(billbackID);
			

			if (NOT FILTERdistributor){
				distid = "";
				stForm.MC_Shr_Ship_to = "";
				stForm.MC_Distributor_Name = "";
				stForm.MC_Bill_To_Name = "";
				stForm.MC_Shr_Bill_To =	 "";
			} else {
				distid = CRDInfo.distributor_id;
				stForm.MC_Shr_Ship_to = CRDInfo.Shr_Ship_To;
				stForm.MC_Distributor_Name = CRDInfo.Name;
				stForm.MC_Bill_To_Name = CRDInfo.BillToName;
				stForm.MC_Shr_Bill_To =	 CRDInfo.Shr_Bill_To;
			}
			/* Business Segment ID of the Deduction's Distributor */
			businessSegmentID = CRDInfo.Dist_Business_Segment_ID;
			if (FILTERamount){
				stForm.DDAmountFilter = CRDInfo.DD_Amount * -1;
			} else {
				stForm.DDAmountFilter = "";
			}

		}
		if (workItemType EQ "BB"){
			BBInfo = MCObject.getBBInfo(billbackID);
			if (NOT FILTERdistributor){
				distid = "";
				stForm.MC_Shr_Ship_to = "";
				stForm.MC_Distributor_Name = "";
				stForm.MC_Bill_To_Name = "";
				stForm.MC_Shr_Bill_To =	 "";

			} else {
				distid = BBInfo.Dist_ID;
				stForm.MC_Shr_Ship_to = BBInfo.Payee_ID;
				stForm.MC_Distributor_Name = BBInfo.Payee_Name;
				stForm.MC_Bill_To_Name = BBInfo.Bill_To_Name;
				stForm.MC_Shr_Bill_To =	 BBInfo.Shr_Bill_To;
			}

			/* Business Segment ID of the Billback's payee */			
			businessSegmentID = BBInfo.Payee_Business_Segment_ID;

			if (matchingType EQ "DD"){
				stForm.SearchSource  = "MatchCentralDD";
				sortField = "DD_Amount";
				sortOrder = "DESC";
				
				if (FILTERamount){
					if (BBInfo.BB_Approved_Amount NEQ "" AND isNumeric(BBInfo.BB_Approved_Amount))
					{
						stForm.DDAmountFilter = BBInfo.BB_Approved_Amount;
					}
					else
					{
						stForm.DDAmountFilter = BBInfo.BB_Amount;
					}
				} else {
					stForm.DDAmountFilter = "";
				}
				
			} else if (matchingType EQ "CR"){
				stForm.SearchSource  = "MatchCentralCR";
				sortField = "DD_Amount";
				sortOrder = "ASC";
				matchToBB = true;

				if (FILTERamount){
					if (BBInfo.BB_Approved_Amount NEQ "" AND isNumeric(BBInfo.BB_Approved_Amount))
					{
						stForm.DDAmountFilter = BBInfo.BB_Approved_Amount;
					}
					else
					{
						stForm.DDAmountFilter = BBInfo.BB_Amount;
					}
				} else {
					stForm.DDAmountFilter = "";
				}
			}
		}		
		</cfscript>

	 <!--- TODO: push these cfqueries into the DAO file  --->
	<cfquery name="UserHasAssignments" datasource="#Application.Datasource#">
	 	SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0
	</cfquery>

	<cfquery name="DefaultSupervisor" datasource="#Application.Datasource#">
	SELECT Name_First, Name_Last
	FROM _Users u INNER JOIN  DD_Analyst dda
	ON u.User_ID = dda.Analyst_User_ID
	WHERE dda.Is_Default_Supervisor = 1
	</cfquery>
	
	
	
	<!--- Adding this cfinclude for timebeing, SHOULD be rewritten into the function at a later point --->
	<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
	<cfset Access_Position_List = GP_Position_List_From_My_Position_Down>
	
	<cfset IaASupervisor = variables.oDeductionDAO.getIaASupervisor() />
	<cfif IaASupervisor.RecordCount GT 0>
		<!--- 
			fix for issue #362, not sure, if for some reason this field was null and hence 
			we got an error so if null then set it to 0
		--->
		<cfif IaASupervisor.Is_Default_Supervisor EQ "">
			<cfset isDefaultSupervisor = 0 />
		<cfelse>
			<cfset isDefaultSupervisor = IaASupervisor.Is_Default_Supervisor />
		</cfif>

		<cfset GetAnalystUnderMe = variables.oDeductionDAO.getAnalystUnderMe(isDefaultSupervisor) />
		<cfset AnalystUnderMe_List = VALUELIST(GetAnalystUnderMe.Analyst_User_ID)>
	<cfset AnalystUnderMe_List = ListAppend(AnalystUnderMe_List, request.AccessStructure.User_ID)>
</cfif>

<cfset UserIsASupervisor = 0>
<cfif IaASupervisor.RecordCount GT 0 AND GetAnalystUnderMe.RecordCount GT 0>
	<cfset UserIsASupervisor = 1>
</cfif>
	<cfset stForm.businessSegmentID = businessSegmentID />
	<cfset HQPosition = variables.oDeductionDAO.getHQPosition() />
	<!--- if the strDistributorId local variable has a value then pass it to the getDDSearchResults() to filter on --->
	<cfif len(trim(strDistributorId))>
		<cfset stForm.Distributor_ID = strDistributorId />
		<cfset stForm.Distributor = strDistributorId />
	</cfif>
	<cfset qryDeductionsMain = variables.oDeductionDAO.getDDSearchResults(billbackID,stForm) />
	<cfscript>
		if (workItemType EQ "CR" OR workItemType EQ "DD"){
			amountFilter = remainBalance * -1;
			if (workItemType EQ "CR"){
				SQLOpr = "<=";
			} else if (workItemType EQ "DD"){
				SQLOpr = ">=";
			}
		} else if (workItemType EQ "BB"){
			amountFilter = remainBalance;
			SQLOpr = "<=";
		}
	</cfscript>
 
	<cfif (keyword NEQ "")>
		<cfquery name="qryDeductions" dbtype="query">
			SELECT *
			FROM qryDeductionsMain
				WHERE 
				Deleted = 0 AND DD_Rejected = 0
				AND		DD_Status IN (1,2)
				AND		Is_Credit = 0
				AND		Is_Write_Off = 0 
				AND		DD_Closure_ID IS NULL
				AND
					(
						(LOWER(CustomerName) 		LIKE '%#lcase(keyword)#%' AND CustomerName 		IS NOT NULL)
						OR (LOWER(Shr_ship_to) 		LIKE '%#lcase(keyword)#%' AND Shr_ship_to 		IS NOT NULL)
						OR (LOWER(Name)				LIKE '%#lcase(keyword)#%' AND Name 				IS NOT NULL)
						OR (LOWER(Shr_Bill_To) 		LIKE '%#lcase(keyword)#%' AND Shr_Bill_To 		IS NOT NULL)
						OR (LOWER(DD_Reference) 	LIKE '%#lcase(keyword)#%' AND DD_Reference 		IS NOT NULL)
						OR (LOWER(DD_Check_Number) 	LIKE '%#lcase(keyword)#%' AND DD_Check_Number 	IS NOT NULL)
					)
				<cfif FILTERremainingBalance>
					AND DD_Amount #SQLOpr# #amountFilter#
				</cfif>
			ORDER BY #sortField# #sortOrder#
		</cfquery>
	<cfelse>
		<cfquery name="qryDeductions" dbtype="query">
			SELECT *
			FROM qryDeductionsMain
			WHERE	Deleted = 0 AND DD_Rejected = 0
			AND		DD_Status IN (1,2)
			AND		Is_Credit = 0
			AND		Is_Write_Off = 0 
			AND		DD_Closure_ID IS NULL
			<cfif FILTERremainingBalance>
				AND DD_Amount #SQLOpr# #amountFilter#
			</cfif>
			ORDER BY #sortField# #sortOrder#
		</cfquery>
	</cfif>	 
	 
	 
	<!--- Insert the query data into an Array and return it as the Deduction Object --->
	<cfset DDArr = ArrayNew(1)/>
  	 <cfset DDArr = this.getDeductionsAsArray(qryDeductions) /> 
	<cfreturn DDArr />
	
	</cffunction>
	
	<cffunction name="getDeductionsAsArray" returntype="array"  access="remote" hint="Take a query as input and return an array of Deduction Objects in return">
		<cfargument name="qryDeductions" required="true" type="query"> 
		<cfloop query="qryDeductions">
			<cfset stDeduction = this.GetQueryRow(qryDeductions,currentRow) />
			<cfset DeductionObj = this.getDeductionObject(stDeduction)/>
			<cfset arrayAppend(DDArr,Duplicate(DeductionObj)) />
		</cfloop> 
		<cfreturn DDArr />	
	</cffunction>
	
 	<cffunction name="getDeduction" returntype="mvc.Models.Deduction.vos.Deduction"  access="remote" hint="" output ="false">
		<cfargument name="ddId" required="true" type="string">
		<cfscript> 
			qryDeductions = variables.oDeductionDAO.getDeductionOnID(ddId);
			stDeduction = this.GetQueryRow(qryDeductions,1);
			DeductionObj = this.getDeductionObject(stDeduction);
			return DeductionObj;
		</cfscript>
	</cffunction>
 
	<cffunction name="getDeductionObject" returntype="mvc.Models.Deduction.vos.Deduction"  access="remote" hint="Take a struct as input and return the Deduction Object in return">
		<cfargument name="stDeduction" required="true" type="struct">
		<cfscript>
			DeductionObj 	= createObject("component","mvc.Models.Deduction.vos.Deduction").init();
	
			DDDistObj 	 	= createObject("component","mvc.Models.Entity.vos.Payee");
			DDBrokerObj 	= createObject("component","mvc.Models.Entity.vos.Payee");
			DDAnalystUser 	= createObject("component","mvc.Models.Entity.vos.User");
			DDLock		 	= createObject("component","mvc.Models.Entity.vos.Lock");		
			DDLockedUser	= createObject("component","mvc.Models.Entity.vos.User");
	
			DDDistObj["payeeId"]			= stDeduction.Distributor_ID;
			DDDistObj["name"]				= stDeduction.Distributor_Name;
			DDBrokerObj["payeeId"]			= stDeduction.Broker_ID;
			DDBrokerObj["name"]			= stDeduction.Broker_Name;
			DDAnalystUser["id"]			= stDeduction.Analyst_User_ID;
			DDAnalystUser["fullName"]		= stDeduction.Name_First & " " & stDeduction.Name_Last;
			DDLock["bLocked"]  			= stDeduction.Is_Locked;
			DDLock["lockDate"] 			= now();// ""; //stDeduction.Deduction_Lock_Date;
	
			DDLockedUser["id"]				= stDeduction.Locked_By;
			DDLockedUser["fullName"]		= stDeduction.LockedName_First & " " & stDeduction.LockedName_Last;
			DDLock["userLocked"]			= DDLockedUser;
			
			DeductionObj["deductionID"] 	= stDeduction.Deduction_ID;
			DeductionObj["deductionNumber"] = stDeduction.DD_DedID;
			DeductionObj["amount"] 		= stDeduction.DD_Amount;
			DeductionObj["ddDate"] 		= now(); //""; //stDeduction.DD_Date;
			DeductionObj["distObj"]		= DDDistObj;
			DeductionObj["brokerObj"]		= DDBrokerObj;
			DeductionObj["analystObj"]		= DDAnalystUser;
			DeductionObj["lockObj"]		= DDLock;	
			DeductionObj["ddCheckNumber"]	= stDeduction.DD_Check_Number;
			DeductionObj["spNumber"]		= stDeduction.SP_Number;
			DeductionObj["amountParent"]	= stDeduction.DD_Amount_Parent;
			DeductionObj["ddSpNumberParent"] = stDeduction.DD_DedID_SP_Number_Parent;
		return DeductionObj;
		</cfscript>
	</cffunction>
	
	<cffunction name="updateDeductionLock" returntype="array" access="remote" hint="">
		<cfargument name="argDeductions" type="mvc.Models.Deduction.vos.Deduction" default="">
		<!--- 
			- get the deduction_ID
			- Check for lock
			- update the lock object with the new record
			- Update the deduction Object
			- return dedObj 
		--->
		
 
	</cffunction>
	
</cfcomponent>



	 