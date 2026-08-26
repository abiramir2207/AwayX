<cfcomponent displayname="ProgramList">
	<!--- get lists of  saved billback criteria for future use.  returns an array of objects o.  
	one of the objects o.data is an array of billback criteria 
	--->
	<cffunction name="getUserBillbackList" output="false" access="remote" returntype="Array">
		<cfargument name="ID" required="false">
		  <cfset var qRead = "">
		  <cfset var qGetData = "">
		  <cfset var arrUserFavoritesData = ArrayNew(1)>
		
		  <cfset var arrgetStatusTypes = ArrayNew(1)>
		  <cfset var arrgetClosingMethods = ArrayNew(1)>
		  <cfset var arrgetBBTypes = ArrayNew(1)>
		  <cfset var arrgetAnalysts = ArrayNew(1)>
		  <cfset var arrgetUsers = ArrayNew(1)>

		  <cfset var reload = 1>


		<cfquery name="qRead" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT    	User_Billback_List_id, 
						User_Id,
						List_Name
			FROM      dbo.User_Billback_List
			WHERE User_Id = '#arguments.ID#'
			ORDER BY List_Name
		</cfquery>
		<!---<cflog text="query ran: #qRead.recordcount# :: #arguments.ID#">--->	

	   <cfloop query="qRead">		
		<cfquery name="qGetData" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT  BB_Code_or_Title,BB_Reference_or_ReferenceNum,Status,Closing_Method,Analyst,
				Check_Number,Billback_Type,Search_Amount_Type,Search_Amount_Criteria,Search_Amount,
				Search_Start_Date_Type,Search_Start_Date_Criteria,cast(Search_Start_Date as datetime) as Search_Start_Date,
				Search_End_Date_Type,Search_End_Date_Criteria,cast(Search_End_Date as datetime) as Search_End_Date,			
				Program,Entity_Type,Entity_Keyword,History_Type,History_User,Conditions,Payee,bSearchAmount,
				bSearchStartDate,bSearchEndDate,Current_Including_Paid,bChkDuplicate
			FROM  dbo.User_Billback_List_Data
			WHERE User_Billback_List_id = '#User_Billback_List_id#'
		</cfquery>
	  

	  <cfscript>
		
		//get Status Array. Comma-delimited list of "Status" is returned from the query and is passed to "getAllStauses" to return a "Status" object.
		arrgetStatusTypes = application.oController.getObject(path="mvc.Models.Billback.BillbackLoadManager",bReload= reload).getAllStauses(qRead.User_Id,1,qGetData.Status);
		
		//get Closing Method Array. Comma-delimited list of "Closing Method" is returned from the query and is passed to "getAllClosingMethods" to return a "Closing Method" object.
		arrgetClosingMethods = application.oController.getObject(path="mvc.Models.Billback.BillbackLoadManager",bReload= reload).getAllClosingMethods(1,qGetData.Closing_Method);

		//get BB Type Array. Comma-delimited list of "BB Type" is returned from the query and is passed to "getAllBBUploadedTypeLabels" to return a "type" object.
		arrgetBBTypes = application.oController.getObject(path="mvc.Models.Billback.BillbackLoadManager",bReload= reload).getAllBBUploadedTypeLabels(1,qGetData.Billback_Type);

		//get Analyst Array. Comma-delimited list of "Analyst" is returned from the query and is passed to "getAllBBUploadedTypeLabels" to return a "user" object.
		arrgetAnalysts = application.oController.getObject(path="mvc.Models.Billback.BillbackLoadManager",bReload= reload).getAnalysts(1,qGetData.Analyst);

		
		//get User array. Comma-delimited list of "User" is returned from the query and is passed to "getAllBBUploadedTypeLabels" to return a "user" object.
		arrgetUsers = application.oController.getObject(path="mvc.Models.Billback.BillbackLoadManager",bReload= reload).getUsers(1,qGetData.History_User);


		/* Assign the objects */
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.BBFilterParams";
		stData["BBCodeKeyword"] = qGetData.BB_Code_or_Title;
		stData["BBNumberKeyword"] = qGetData.BB_Reference_or_ReferenceNum;
		stData["programKeyword"] = qGetData.Program;
		stData["checkNoKeyword"] = qGetData.Check_Number;
		stData["amountTypeSelect"] = qGetData.Search_Amount_Type;
		stData["amountCriteriaSelect"] = qGetData.Search_Amount_Criteria;
		stData["amountValueKeyword"] = qGetData.Search_Amount;
		stData["dateRangeStartTypeSelect"] = qGetData.Search_Start_Date_Type;
		stData["dateRangeStartCriteriaSelect"] = qGetData.Search_Start_Date_Criteria;
		stData["dateRangeStartValueKeyword"] = qGetData.Search_Start_Date;
		stData["dateRangeEndTypeSelect"] = qGetData.Search_End_Date_Type;
		stData["dateRangeEndCriteriaSelect"] = qGetData.Search_End_Date_Criteria;
		stData["dateRangeEndValueKeyword"] = qGetData.Search_End_Date;
		stData["entitySelect"] = qGetData.Entity_Type;
		stData["entityKeyword"] = qGetData.Entity_Keyword;
		stData["historySelect"] = qGetData.History_Type;
		stData["historyUsernameSelect"] = arrgetUsers;
		stData["actionSelect"] = "";
		stData["conditionSelect"] = qGetData.Conditions;
		stData["statusListSelect"] = arrgetStatusTypes;
		stData["closingMethodSelect"] = arrgetClosingMethods;	
		stData["typeListSelect"] = arrgetBBTypes;
		stData["analystListSelect"] = arrgetAnalysts;
		stData["bSearchDateRangeStart"] = qGetData.bSearchStartDate;
		stData["bSearchDateRangeEnd"] = qGetData.bSearchEndDate;
		stData["bSearchAmount"] = qGetData.bSearchAmount;
		stData["payeeKeyword"] = qGetData.Payee;
		//stData["loadArchive"] = "";
		//stData["includePaid"] =  0;
		//stData["refreshData"] =  0;
		stData["userBillbackListId"] = User_Billback_List_id;
		stData["userId"] = User_Id;
		stData["listName"] = List_Name;
		stData["currentIncludingPaid"] = qGetData.Current_Including_Paid;
		stDate["bChkDuplicate"] = qGetData.bChkDuplicate;	
		ArrayAppend(arrUserFavoritesData, duplicate(stData));
	   </cfscript>

	 </cfloop>

	   <cfreturn arrUserFavoritesData />
	</cffunction>


	<!--- save a list of billback criteria for future use. --->
	<cffunction name="saveUserBillbackCriteria" output="false" access="remote" returntype="void">
		<cfargument name="BBFilterparams" required="true">
		<cfargument name="userID" required="true">
		<cfargument name="listName" required="true">

		<cfset saveUserBillbackCriteriaData(argumentcollection='#arguments#')>
	</cffunction>

	<!--- Even though there are arguments being passed to "saveUserBillbackCriteria". It does not work
		  when we use "cfargument" here"
	--->
	<cffunction name="saveUserBillbackCriteriaData" output="false" access="private" returntype="void">

		<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var k = "">

		<cfset var ArrStatus = ArrayNew(1)>
		<cfset var ArrClosingMethod = ArrayNew(1)>
		<cfset var ArrAnalyst = ArrayNew(1)>
		<cfset var ArrBBType = ArrayNew(1)>
		<cfset var ArrHistoryUserName = ArrayNew(1)>

		<cfset var StrStatus = "">
		<cfset var StrClosingMethod = "">
		<cfset var StrAnalyst = "">
		<cfset var StrBBType = "">
		<cfset var StrHistoryUserName = "">
		<cfset var StrStartDateValue = "">
		<cfset var StrEndDateValue = "">
		
		<cftransaction isolation="read_committed">
		<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Billback_list(
							User_Id, 
							List_Name)
				values (
					<cfqueryparam value="#arguments.UserId#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.listName#" cfsqltype="CF_SQL_VARCHAR" />
					)
				
			      SELECT @@Identity AS newId      
			      SET NOCOUNT OFF 
			</cfquery>
			<cfset listId = qCreate.newId />

			<!---	<cfquery name="qCreate" datasource="#application.datasource#">
				insert into test_flex(profile_id)
				values('#IsArray(arguments.BBFilterparams.statusListSelect)#')
				</cfquery>
			--->

		<!--- Loop through the list of statuses (Status_ID) passed by Flex. User ArrayToList to convert the array of statuses to
		      a comma-delimited list of statuses.
		--->
		<cfif IsDefined("arguments.BBFilterparams.statusListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.statusListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.statusListSelect)#" index="k">
					<cfset ArrStatus[k] = arguments.BBFilterparams.statusListSelect[k].id>
					<cfset StrStatus = ArrayToList(ArrStatus)>
				</cfloop>
			</cfif>
		</cfif>
		
		<!--- Loop through the list of closing methods (Closing_Method_ID) passed by Flex. User ArrayToList to convert the array of closing method to
		      a comma-delimited list of closing methods.
		--->
		<cfif IsDefined("arguments.BBFilterparams.closingMethodSelect")>
			<cfif IsArray("#arguments.BBFilterparams.closingMethodSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.closingMethodSelect)#" index="k">
					<cfset ArrClosingMethod[k] = arguments.BBFilterparams.closingMethodSelect[k].id>
					<cfset StrClosingMethod = ArrayToList(ArrClosingMethod)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Loop through the list of analysts (User_ID_Int) passed by Flex. User ArrayToList to convert the array of analysts to
		      a comma-delimited list of analysts (user_id_int).
		--->
		<cfif IsDefined("arguments.BBFilterparams.analystListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.analystListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.analystListSelect)#" index="k">
					<cfset ArrAnalyst[k] = arguments.BBFilterparams.analystListSelect[k].idInt>
					<cfset StrAnalyst = ArrayToList(ArrAnalyst)>
				</cfloop>
			</cfif>
		</cfif>
		
		<!--- Loop through the list of billback type (BB_Type_ID in mvc\models\BillbackLoadManager.cfc) passed by Flex. User ArrayToList to convert the array of billback type to
		      a comma-delimited list of billback types.
		--->
		<cfif IsDefined("arguments.BBFilterparams.typeListSelect")>
			<cfif IsArray("#arguments.BBFilterparams.typeListSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.typeListSelect)#" index="k">
					<cfset ArrBBType[k] = arguments.BBFilterparams.typeListSelect[k].id>
					<cfset StrBBType = ArrayToList(ArrBBType)>
				</cfloop>
			</cfif>
		</cfif>

		<cfif IsDefined("arguments.BBFilterparams.historyUsernameSelect")>
			<cfif IsArray("#arguments.BBFilterparams.historyUsernameSelect#")>
				<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.historyUsernameSelect)#" index="k">
					<cfset ArrHistoryUserName[k] = arguments.BBFilterparams.historyUsernameSelect[k].idInt>
					<cfset StrHistoryUserName = ArrayToList(ArrHistoryUserName)>
				</cfloop>
			</cfif>
		</cfif>

		<cfif IsDefined("arguments.BBFilterparams.dateRangeStartValueKeyword")>
			<cfif arguments.BBFilterparams.dateRangeStartValueKeyword neq "">
				<cfset StrStartDateValue = DateFormat(arguments.BBFilterparams.dateRangeStartValueKeyword,"MM/DD/YYYY")>
			</cfif>
		</cfif>

		<cfif IsDefined("arguments.BBFilterparams.dateRangeEndValueKeyword")>
			<cfif arguments.BBFilterparams.dateRangeEndValueKeyword neq "">
				<cfset StrEndDateValue = DateFormat(arguments.BBFilterparams.dateRangeEndValueKeyword,"MM/DD/YYYY")>
			</cfif>
		</cfif>	

			<cfquery name="qGetID" datasource="#application.datasource#">
				insert into dbo.User_Billback_list_Data(
					User_Billback_List_id,BB_Code_or_Title,BB_Reference_or_ReferenceNum,Status,Closing_Method,Analyst,
					Check_Number,Billback_Type,Search_Amount_Type,Search_Amount_Criteria,Search_Amount,
					Search_Start_Date_Type,Search_Start_Date_Criteria,Search_Start_Date,
					Search_End_Date_Type,Search_End_Date_Criteria,Search_End_Date,
					Program,Entity_Type,Entity_Keyword,History_Type,History_User,Conditions,
					Payee,bSearchAmount,bSearchStartDate,bSearchEndDate,Current_Including_Paid,bChkDuplicate)
				values (
				<cfqueryparam value="#listId#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBFilterparams.BBCodeKeyword#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.BBNumberKeyword#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrStatus#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrClosingMethod#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrAnalyst#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.checkNoKeyword#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrBBType#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.amountTypeSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.amountCriteriaSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.amountValueKeyword#" cfsqltype="CF_SQL_VARCHAR" />,					
				<cfqueryparam value="#arguments.BBFilterparams.dateRangeStartTypeSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.dateRangeStartCriteriaSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrStartDateValue#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.dateRangeEndTypeSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.dateRangeEndCriteriaSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrEndDateValue#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.programKeyword#" cfsqltype="CF_SQL_VARCHAR" />,				
				<cfqueryparam value="#arguments.BBFilterparams.entitySelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.entityKeyword#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.historySelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#StrHistoryUserName#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.conditionSelect#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.payeeKeyword#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBFilterparams.bSearchAmount#" cfsqltype="CF_SQL_BIT" />,
				<cfqueryparam value="#arguments.BBFilterparams.bSearchDateRangeStart#" cfsqltype="CF_SQL_BIT" />,
				<cfqueryparam value="#arguments.BBFilterparams.bSearchDateRangeEnd#" cfsqltype="CF_SQL_BIT" />,
				<cfqueryparam value="#arguments.BBFilterparams.currentIncludingPaid#" cfsqltype="CF_SQL_BIT" />,
				<cfqueryparam value="#arguments.BBFilterparams.bChkDuplicate#" cfsqltype="CF_SQL_BIT" />
				)
			</cfquery>
		</cftransaction>
	</cffunction>

	<cffunction name="deleteUserBillbackList" output="false" access="remote" returntype="void">
		<cfargument required="true" name="ID" type="Numeric">
		<cfset var qDeleteUser_Billback_list_Data = "">
		<cfset var qDeleteUser_Billback_list = "">
		
		<cftransaction action="BEGIN">
			<cftry>
		<cfquery name="qDeleteUser_Billback_list_Data" datasource="#application.datasource#">
					DELETE FROM dbo.User_Billback_list_Data
					WHERE User_Billback_list_Id = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="qDeleteUser_Billback_list" datasource="#application.datasource#">
					DELETE FROM dbo.User_Billback_list
					WHERE User_Billback_list_Id = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cftransaction action="COMMIT" />
				<cfcatch>
					<cftransaction action="ROLLBACK" />
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cftransaction>
	</cffunction>
	
</cfcomponent>
