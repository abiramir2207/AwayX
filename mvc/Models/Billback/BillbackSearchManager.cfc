
<cfcomponent name="BillbackSearchManager" displayname="BillbackSearchManager" hint="Billback Search">

	<!--------------------------------------------------------------------------- 
	Filter function for Fulltext keyword searches And/or Billback status filters: 
		Agreed, Pending Approval, and Under review
	--------------------------------------------------------------------------->
	<cffunction name="filterRemoteData" output="false" access="remote" returntype="Struct">
		<cfargument name="BBFilterparams" required="true" default="" />
		<cfargument name="userId" type="string" required="true" />

		<cfset var reload = 1> //used for mvc calls
		<cfset var s = structNew()> 
		<cfset var a = ArrayNew(1)> 
		<cfset var arrFilterString = ArrayNew(1)> 
		<cfset var arrFilterStatus = ArrayNew(1)> 
		<cfset var useStringFilter = 0> 
		<cfset var usePendingFilter = 0>
		<cfset var i = 0>
		<cfset var profiles_id = 0>
		<cfset var ArrStatus = ArrayNew(1)>

		<cfloop from="1" to="#Arraylen(arguments.BBFilterparams.statusListSelect)#" index="k">

		<!--- When the user manually selects "Agreed" or "Pending Approval" or "Under Review", then desccription of that status will be populated
		      in the "BBFilterparams" and we can use it.
		--->
		<cfif arguments.BBFilterparams.statusListSelect[k].description neq "">
			<cfset ArrStatus[k] = arguments.BBFilterparams.statusListSelect[k].description>
		<cfelse>
		<!--- When the user visits billback search from the scorecard using a status, only the statusID is passed and so we need to populate 
		    the description here.
		--->
			<cfif arguments.BBFilterparams.statusListSelect[k].id eq 201>
				<cfset ArrStatus[k] = "Agreed">
			<cfelseif arguments.BBFilterparams.statusListSelect[k].id eq 202>
				<cfset ArrStatus[k] = "Pending Approval">
			<cfelseif arguments.BBFilterparams.statusListSelect[k].id eq 203>
				<cfset ArrStatus[k] = "Under Review">
			</cfif>
		</cfif>

		</cfloop>

		<cfset StrStatus =  ArrayToList(ArrStatus)>

		<cfscript>

				profiles_id = val(getUserProfile('#arguments.userId#'));

				/*First check for keyword filters and get array of billback_ID_Int that meet the keyword criteria*/
				if(arguments.BBFilterparams.programKeyword != '' || arguments.BBFilterparams.entityKeyword != '' || arguments.BBFilterparams.payeeKeyword != '' || arguments.BBFilterparams.checknoKeyword != '')
					{
						/*if any keyword filters are passed, use fulltext to get array of billback_ID_Int that meet criteria*/
						arrFilterString = application.oController.getObject(path="mvc.Models.Billback.BillbackSearchDetails",bReload= reload).fullTextBillbackFilter(arguments.BBFilterparams);
						useStringFilter = 1;
					}
				
				/* Second check for the billback status filter and get billback_Id_Int.  "Under Review" returns its own exclusion array*/
				if(StrStatus.indexOf('Under Review') != -1 || StrStatus.indexOf('Pending Approval') != -1 || StrStatus.indexOf('Agreed') != -1)
					{
						/*if billback status filter is paseed get array of billback_Id_Int that are in that status*/
						arrFilterStatus = application.oController.getObject(path="mvc.Models.Billback.BillbackSearchDetails",bReload= reload).getUnderReviewOrPendingApprovalOrAgreedBillbacks(arguments.userId,profiles_Id,StrStatus);
						usePendingFilter = 1;
					}
					
				/*now decide what to return -> get the common elements from the Arrays or for under review combine 2 arrays*/
				if(useStringFilter == 1 && (usePendingFilter == 1))
					{
						for (i = 1; i lte arraylen(arrFilterStatus); i = i + 1) 
							{ 
								if(arrFilterString.indexOf(arrFilterStatus[i]) > -1)
									{
										ArrayAppend( a,arrFilterStatus[i] );
									}
							}
					}
				else if(useStringFilter == 1)
					{
						a = arrFilterString;
					}
				else if(usePendingFilter == 1)
					{
						a = arrFilterStatus;
					}

				/* return a Struct with  array: F = Filter Array */
				s.F = a;

		</cfscript>
	
			<cfreturn s />
	</cffunction>
	
	<cffunction name="getUserProfile" returntype="string">
		<cfargument name="userId" type="string" required="true" />
		<cfset var p = 0/>	
		<cfif not isdefined("request.AccessStructure")>	
			<cfquery name="qryGetUserProfile" datasource="#application.datasource#">
				SELECT profiles.profiles_id
				FROM profiles inner join _users
				ON profiles.profiles_id = _users.profiles_id
				WHERE _users.user_id ='#arguments.userId#'
				AND profiles.deleted = 0
			</cfquery>
			<cfset request.AccessStructure.profiles_id = qryGetUserProfile.profiles_id />
			<cfset request.AccessStructure.user_id = arguments.userId />
		</cfif>
			<cfreturn request.AccessStructure.profiles_id />	
	</cffunction>


	<!--- get saved BBSearch Grid column width --->
	<cffunction name="getBBSearchGridColumnSize" output="false" access="remote" returntype="Struct">
		<cfargument name="userId" type="string" required="true">
		<cfset var qGetData = "">
		
		<cfset useLakebaseForqGetData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_search_grid_column_size")>
<cfif useLakebaseForqGetData>
	<cftry>
		<cfset qGetData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_search_grid_column_size", {
				"user_id" = "eq.#arguments.userId#",
				"select" = "status,payable_number,billback_number,title,bb_date,bb_received_date,payee,start_date,end_date,claimed_amount,approved_amount,closing_method,more_info,vendor"
			}), "status,payable_number,billback_number,title,bb_date,bb_received_date,payee,start_date,end_date,claimed_amount,approved_amount,closing_method,more_info,vendor"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetData>
<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT  Status,Payable_Number,Billback_Number,Title,BB_Date,BB_Received_Date,Payee,Start_Date,End_Date,
				Claimed_Amount,Approved_Amount,Closing_Method,More_Info,Vendor
			FROM  BB_Search_Grid_Column_Size
			WHERE User_Id = '#arguments.userId#'
		</cfquery>
</cfif>

	  <cfif qGetData.recordcount eq 0>
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT  Status,Payable_Number,Billback_Number,Title,BB_Date,BB_Received_Date,Payee,Start_Date,End_Date,
				Claimed_Amount,Approved_Amount,Closing_Method,More_Info,Vendor
			FROM  BB_Search_Grid_Column_Size
			WHERE User_Id = '00000000-9999-9999-0000000000000000'
		</cfquery>
	  </cfif>

	   <cfscript>
		/* Assign the objects */
		stData = structNew();
		stData["__type__"] = "mvc.Models.Billback.vos.BBSearchGridColumnSize";
		stData["status"] = qGetData.Status;
		stData["BBCode"] = qGetData.Payable_Number;
		stData["BBNumber"] = qGetData.Billback_Number;
		stData["title"] = qGetData.Title;
		stData["BBDate"] = qGetData.BB_Date;
		stData["BBReceivedDate"] = qGetData.BB_Received_Date;
		stData["payee"] = qGetData.Payee;
		stData["startDate"] = qGetData.Start_Date;
		stData["endDate"] = qGetData.End_Date;
		stData["claimedAmount"] = qGetData.Claimed_Amount;
		stData["approvedAmount"] = qGetData.Approved_Amount;
		stData["closingMethod"] = qGetData.Closing_Method;
		stData["moreInfo"] = qGetData.More_Info;
		stData["vendor"] = qGetData.Vendor;
	   </cfscript>

	   <cfreturn stData>
	</cffunction>

	<!--- save BB Search Grid width values --->
	<cffunction name="saveBBSearchGridColumnSize" output="false" access="remote" returntype="void">				
		<cfargument name="userID" required="true">
		<cfargument name="BBSearchGridColumnSize" required="true">

		  <cfset saveBBSearchGridColumnSizeData(argumentcollection='#arguments#')>
	</cffunction>

	<!--- Even though there are arguments being passed to "saveBBSearchGridColumnSizeData". It does not work
	  when we use "cfargument" here"
	--->
	<cffunction name="saveBBSearchGridColumnSizeData" output="false" access="private" returntype="void">

		<cfset var qGetData = "">
		<cfset var qSaveColumnSize = "">

		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT Count(*) As IsExistsUserEntry
			FROM  BB_Search_Grid_Column_Size
			WHERE User_Id = '#arguments.userId#'
		</cfquery>

	  <cfif qGetData.IsExistsUserEntry eq 0>

			<cfquery name="qSaveColumnSize" datasource="#application.datasource#">
				insert into BB_Search_Grid_Column_Size(
					User_Id,Status,Payable_Number,Billback_Number,Title,BB_Date,BB_Received_Date,Payee,Start_Date,End_Date,
					Claimed_Amount,Approved_Amount,Closing_Method,More_Info,Vendor)
				values (
				<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.status#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.BBCode#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.BBNumber#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.title#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.BBDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.BBReceivedDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.payee#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.startDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.endDate#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.claimedAmount#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.approvedAmount#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.closingMethod#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.moreInfo#" cfsqltype="CF_SQL_INTEGER" />,
				<cfqueryparam value="#arguments.BBSearchGridColumnSize.vendor#" cfsqltype="CF_SQL_INTEGER" />
				)
			</cfquery>
	   <cfelse>
			<cfquery name="qSaveColumnSize" datasource="#application.datasource#">
				UPDATE BB_Search_Grid_Column_Size
					SET 
						Status = <cfqueryparam value="#arguments.BBSearchGridColumnSize.status#" cfsqltype="CF_SQL_INTEGER" />,
						Payable_Number = <cfqueryparam value="#arguments.BBSearchGridColumnSize.BBCode#" cfsqltype="CF_SQL_INTEGER" />,
						Billback_Number = <cfqueryparam value="#arguments.BBSearchGridColumnSize.BBNumber#" cfsqltype="CF_SQL_INTEGER" />,
						Title = <cfqueryparam value="#arguments.BBSearchGridColumnSize.title#" cfsqltype="CF_SQL_INTEGER" />,
						BB_Date = <cfqueryparam value="#arguments.BBSearchGridColumnSize.BBDate#" cfsqltype="CF_SQL_INTEGER" />,
						BB_Received_Date = <cfqueryparam value="#arguments.BBSearchGridColumnSize.BBReceivedDate#" cfsqltype="CF_SQL_INTEGER" />,
						Payee = <cfqueryparam value="#arguments.BBSearchGridColumnSize.payee#" cfsqltype="CF_SQL_INTEGER" />,
						Start_Date = <cfqueryparam value="#arguments.BBSearchGridColumnSize.startDate#" cfsqltype="CF_SQL_INTEGER" />,
						End_Date = <cfqueryparam value="#arguments.BBSearchGridColumnSize.endDate#" cfsqltype="CF_SQL_INTEGER" />,
						Claimed_Amount = <cfqueryparam value="#arguments.BBSearchGridColumnSize.claimedAmount#" cfsqltype="CF_SQL_INTEGER" />,
						Approved_Amount = <cfqueryparam value="#arguments.BBSearchGridColumnSize.approvedAmount#" cfsqltype="CF_SQL_INTEGER" />,
						Closing_Method = <cfqueryparam value="#arguments.BBSearchGridColumnSize.closingMethod#" cfsqltype="CF_SQL_INTEGER" />,
						More_Info = <cfqueryparam value="#arguments.BBSearchGridColumnSize.moreInfo#" cfsqltype="CF_SQL_INTEGER" />,
						Vendor = <cfqueryparam value="#arguments.BBSearchGridColumnSize.vendor#" cfsqltype="CF_SQL_INTEGER" />
					WHERE User_Id = <cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR" />
			</cfquery>
	   </cfif>

	</cffunction>

</cfcomponent>	