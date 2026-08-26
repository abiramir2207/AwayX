<CFSILENT>
<CFPARAM NAME="showlinks" 	DEFAULT="false">
<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="Position">
<CFSET SORT_BY = "User_Positions.User_Positions_ID">
<CFSWITCH expression="#LCase(URL.SORT_BY)#">
	<CFCASE value="status">
		<CFSET SORT_BY = "Contract_Status_Types.Contract_Status_Type_ID">
	</CFCASE>
	<CFCASE value="number">
		<CFSET SORT_BY = "Contract_Main.Contract_Number">
	</CFCASE>	
</CFSWITCH>

<CFQUERY NAME="Get_All_Programs" DATASOURCE="#application.datasource#">
	SELECT	Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, Contract_Main.Contract_Title, 
			Contract_Status_Types.Contract_Status_Type_ID, Contract_Status_Types.Contract_Status_Type_Desc,
			_Users.Name_FIrst + ' ' + _Users.Name_Last AS Creator, User_Positions.User_Positions_ID, User_Positions.Position_Label
	FROM	Contract_Main
		INNER JOIN Contract_Status_Types
		ON
		Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
		LEFT JOIN _Users
		ON
		_Users.User_ID = Contract_Main.Creator_ID
		LEFT JOIN User_Position_Holders
		ON
		User_Position_Holders.User_ID = _Users.User_ID
		and User_Position_Holders.User_Position_Type = 'P' and User_Position_Holders.deleted = 0
		LEFT JOIN User_Positions
		ON
		User_Positions.User_Positions_ID = User_Position_Holders.User_Positions_ID		
	WHERE
		Contract_Main.Deleted = 0
		AND
		Contract_Main.Flagged_As_Purged = 0
	ORDER BY #SORT_BY#
</CFQUERY>
</CFSILENT>
<TABLE cellpadding="2" cellpadding="0" bgcolor="#CCCCCC">
<THEAD>
	<TR>
		<TH></TH>
		<TH><CFIF showlinks><A HREF="Show_All_Programs.cfm?SORT_BY=number"></CFIF>Number<CFIF showlinks></A></CFIF></TH>		
		<TH>Title</TH>
		<TH><CFIF showlinks><A HREF="Show_All_Programs.cfm?SORT_BY=status"></CFIF>Status<CFIF showlinks></A></CFIF></TH>		
		<TH>Creator</TH>
		<TH><CFIF showlinks><A HREF="Show_All_Programs.cfm?SORT_BY=position"></CFIF>Creator Position<CFIF showlinks></A></CFIF></TH>
		<TH>All Positions</TH>
		<TH>All Users</TH>
	</TR>
</THEAD>
<CFSET Prev_Positions = "">
<CFSET Prev_Position_ID = "">
<CFOUTPUT query="Get_All_Programs">
	<!------ <CFIF Contract_Status_Type_ID EQ 1>
		<CFSET BGCOLOR="##FFDEAD">
	<CFELSEIF Contract_Status_Type_ID EQ 2>
		<CFSET BGCOLOR="Yellow">
	<CFELSE>
		<CFSET BGCOLOR="White">
	</CFIF> ----->
	<CFIF currentrow MOD 2>
		<CFSET BGCOLOR="##FFDEAD">
	<CFELSE>
		<CFSET BGCOLOR="White">
	</CFIF>
	<TR bgcolor="#BGCOLOR#" valign="top">
		<TD>#currentrow#. </TD>
		<TD WIDTH="70">#Contract_Number#</TD>
		<TD>#Contract_Title#</TD>
		<TD WIDTH="70">#Contract_Status_Type_Desc#</TD>
		<TD WIDTH="70">#Creator#</TD>
		<TD width="100">#Position_Label#</TD>
		<CFSET Curr_Position = User_Positions_ID>
		<CFIF Contract_Status_Type_ID GTE 2>
			<CFIF Prev_Position_ID NEQ User_Positions_ID>
				<!------ Get user positions above User_Positions_ID ----->
				<CFSET GP_Supplied_Position = User_Positions_ID>
				<CFINCLUDE TEMPLATE="positions_above.cfm">
				<CFSET Prev_Position_ID = User_Positions_ID>
				<CFSET Prev_Positions = GP_Position_List_From_My_Position_Down>
			</CFIF>
			<CFSET Curr_Position = ListAppend(Curr_Position, Prev_Positions, ",")>
		</CFIF>
		<CFIF Contract_Status_Type_ID GTE 3>
			<!------ Approved ----->
			<!------ Find Distributors ----->
			<CFQUERY NAME="getAllDistributors" datasource="#application.datasource#">
			SELECT    	DISTINCT  BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
			FROM      	Contract_Distributors			
						INNER JOIN	BSA_Foodservice_Customers
						ON
						BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			WHERE     
						Contract_Distributors.Contract_Main_ID = #Contract_Main_ID#
						AND
						Contract_Distributors.Deleted = 0
			</CFQUERY>
			
			<CFSET BrokersList = ValueList(getAllDistributors.BSA_Foodservice_Brokers_ID)>
			
			<!------ Find Brokers ----->
			<cfset useLakebaseForgetAllBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseForgetAllBrokers>
	<cftry>
		<cfset getAllBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_brokers", {
				"contract_main_id" = "eq.#Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "bsa_foodservice_brokers_id"
			}), "bsa_foodservice_brokers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllBrokers>
<CFQUERY NAME="getAllBrokers" datasource="#application.datasource#">
			SELECT    	DISTINCT  Contract_Brokers.BSA_Foodservice_Brokers_ID
			FROM      	Contract_Brokers
			WHERE     
						Contract_Brokers.Contract_Main_ID = #Contract_Main_ID#
						AND
						Contract_Brokers.Deleted = 0
			</CFQUERY>
</cfif>
			
			<CFSET BrokersList = ListAppend(BrokersList, ValueList(getAllBrokers.BSA_Foodservice_Brokers_ID))>
			
			<!------ Get Userpositions ----->
			
			<CFIF BrokersList NEQ "">
				<CFQUERY NAME="Get_Broker_Positions" DATASOURCE="#application.datasource#">
					SELECT	User_Positions.User_Positions_ID
					FROM	Service_Markets
							INNER JOIN User_Positions
							ON
							User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
							AND
							User_Positions.Deleted = 0
					WHERE
							Service_Markets.BSA_Foodservice_Brokers_ID IN (#ListQualify(BrokersList, "'", ",")#)
							AND
							Service_Markets.Deleted = 0
				</CFQUERY>
				<CFLOOP query="Get_Broker_Positions">
					<CFSET GP_Supplied_Position = User_Positions_ID>
					<CFINCLUDE TEMPLATE="positions_above.cfm">
					<CFSET Curr_Position = ListAppend(Curr_Position, GP_Position_List_From_My_Position_Down, ",")>
				</CFLOOP>
			</CFIF>
		</CFIF>
		
		<TD WIDTH="100">
			<CFQUERY NAME="Get_All_Positions" DATASOURCE="#application.datasource#">
				SELECT DISTINCT User_Positions_ID, Position_Label
				FROM	User_Positions
				WHERE
						User_Positions_ID IN (#Curr_Position#)
						AND
						User_Positions.Deleted = 0
				ORDER BY User_Positions_ID
			</CFQUERY>
			<CFSET Curr_Position = ValueList(Get_All_Positions.User_Positions_ID)>
			<CFSET Position_Labels = ValueList(Get_All_Positions.Position_Label, ", ")>
			<!------ <TABLE>				
			<CFLOOP query="Get_All_Positions">
			<TR><TD>#Position_Label#</TD></TR>
			</CFLOOP>
			</TABLE>	 ----->	
			#Position_Labels#
		</TD>
		<TD>
			<CFQUERY NAME="Get_All_Users" DATASOURCE="#application.datasource#">
				SELECT _Users.Name_First  + ' ' + _Users.Name_Last AS User_Name
				FROM	User_Position_Holders
						INNER JOIN _Users
						ON
						User_Position_Holders.User_ID = _Users.User_ID
						AND
						_Users.Deleted = 0
						AND
						_Users.User_Rights_ID <> 9999
				WHERE
						User_Positions_ID IN (#Curr_Position#)
						AND
						User_Position_Holders.Deleted = 0
				ORDER BY User_Positions_ID
			</CFQUERY>
			<CFSET Names = ValueList(Get_All_Users.User_Name, ", ")>
			<!------ <TABLE>				
			<CFLOOP query="Get_All_Users">
			<TR><TD>#User_Name#</TD></TR>
			</CFLOOP>
			</TABLE>	 ----->
			#Names#
		</TD>
	</TR>
</CFOUTPUT>
</TABLE>