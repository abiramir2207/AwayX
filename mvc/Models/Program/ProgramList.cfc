<cfcomponent displayname="ProgramList">
	<!--- get lists of  saved program criteria for future use.  returns an array of objects o.  
	one of the objects o.data is an array of program criteria.
	This one is used for Adobe Flex Program search tool.
	--->
	<cffunction name="getUserProgramList" output="false" access="remote" returntype="Array">
		<cfargument name="ID" required="false">
		<cfset var qRead = "">
		<cfset var qGetData = "">
		<cfset var acData = ArrayNew(1)/>
		<cfset var tmpData = ArrayNew(1)/>
		<cfset var t = "" />
		<cfquery name="qRead" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT	upl.User_Program_List_id, 
					upl.User_Id,
					upl.List_Name
			FROM      dbo.User_Program_List upl
			INNER JOIN dbo.User_Program_List_Data upld
			ON upl.User_Program_List_id = upld.User_Program_List_id
			WHERE upl.User_Id = '#arguments.ID#'
			/* Where there is no value in the column. These are the favorites saved from Flex. */
			AND nullif(upld.DATASOURCE,'') IS NULL
			ORDER BY upl.List_Name
		</cfquery>
		<!---<cflog text="query ran: #qRead.recordcount# :: #arguments.ID#">--->	

	<cfloop query="qRead">
		<cfset t = structnew()>
		<cfset t.User_Program_List_id = User_Program_List_id>
		<cfset t.User_Id = User_Id>
		<cfset t.List_Name = List_Name>
		<cfset t.Data = ArrayNew(1) />
		
			<cfquery name="qGetData" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT  Status,Template,RSP,BuyingGroup,Family,UserInfo,Position,ProgramInfo,
				ReportType,Conditions,Program_Info,Distributor_Info,Operator_Info,Item_Info,
				BudgetClass,BusinessSegment
				FROM  dbo.User_Program_List_Data
				WHERE User_Program_List_id = '#User_Program_List_id#'
			</cfquery>
			<cfset tmpData = ArrayNew(1)/>

			<cfset ArrayAppend(tmpData,qGetData.Status) />		
			<cfset ArrayAppend(tmpData,qGetData.Template) />
			<cfset ArrayAppend(tmpData,qGetData.RSP) />
			<cfset ArrayAppend(tmpData,qGetData.BuyingGroup) />
			<cfset ArrayAppend(tmpData,qGetData.Family) />			
			<cfset ArrayAppend(tmpData,qGetData.UserInfo) />
			<cfset ArrayAppend(tmpData,qGetData.Position) />
			<cfset ArrayAppend(tmpData,qGetData.ProgramInfo) />
			<cfset ArrayAppend(tmpData,qGetData.ReportType) />
			<cfset ArrayAppend(tmpData,qGetData.Conditions) />
			<cfset ArrayAppend(tmpData,qGetData.Program_Info) />
			<cfset ArrayAppend(tmpData,qGetData.Distributor_Info) />
			<cfset ArrayAppend(tmpData,qGetData.Operator_Info) />
			<cfset ArrayAppend(tmpData,qGetData.Item_Info) />
			<cfset ArrayAppend(tmpData,qGetData.BudgetClass) />
			<cfset ArrayAppend(tmpData,qGetData.BusinessSegment) />
			
			<cfset t.Data = tmpData	/>
			<!---append this structure to the array--->
	         <cfset arrayappend(acData, t)>
		</cfloop>
	<cfreturn acData>

	</cffunction>

	<!--- Get list of saved search options. Return data in JSON format for AG GRID --->
	<cffunction name="getSavedUserProgramFavorite" output="false" access="remote" returnFormat="json">
		<cfargument name="listID" required="true">

			<cfset var qGetData = "">
			<cfset var sDataSource = "">
			<cfset var strData = structnew()>
			<cfset arrStatus = ArrayNew(1)>
			<cfset arrTemplate = ArrayNew(1)>
			<cfset arrRSP = ArrayNew(1)>
			<cfset arrBuyingGroup = ArrayNew(1)>
			<cfset arrFamily = ArrayNew(1)>
			<cfset arrUserInfo = ArrayNew(1)>
			<cfset arrPosition = ArrayNew(1)>
			<cfset arrProgramInfo = ArrayNew(1)>
			<cfset arrReportType = ArrayNew(1)>
			<cfset arrConditions = ArrayNew(1)>
			<cfset arrBudgetClass = ArrayNew(1)>
			<cfset arrBusinessSegment = ArrayNew(1)>
			<cfset arrDatasource = ArrayNew(1)>
			<cfset arrDiscount_Type = ArrayNew(1)>
			<cfset arrFixed_Discount_Types = ArrayNew(1)>
			<cfset arrRebate_Discount_Types = ArrayNew(1)>
			<cfset arrLump_Sum_Discount_Types = ArrayNew(1)>
			<cfset arrGrowth_Discount_Types = ArrayNew(1)>
			<cfset arrRate_Compare = ArrayNew(1)>
			<cfset arrRate_Uom = ArrayNew(1)>
			<cfset arrRate_Val = ArrayNew(1)>
	
			<cfquery name="qGetData" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT  Status,Template,RSP,BuyingGroup,Family,UserInfo,Position,ProgramInfo,
				ReportType,Conditions,Program_Info,Distributor_Info,Operator_Info,Item_Info,
				BudgetClass,BusinessSegment,				
				CASE Datasource
					WHEN 'Catalog' THEN 1
					ELSE 0
				END
				As Datasource,
				Discount_Type,Fixed_Discount_Types,Rebate_Discount_Types,
				Lump_Sum_Discount_Types,Growth_Discount_Types,Rate_Compare,Rate_Uom,Rate_Val
				FROM  dbo.User_Program_List_Data
				WHERE User_Program_List_id = '#arguments.listID#'
			</cfquery>


			<cfset arrStatus = ListToArray(valueList(qGetData.Status))>
			<cfset arrTemplate = ListToArray(valueList(qGetData.Template))>
			<cfset arrRSP = ListToArray(valueList(qGetData.RSP))>
			<cfset arrBuyingGroup = ListToArray(valueList(qGetData.BuyingGroup))>
			<cfset arrFamily = ListToArray(valueList(qGetData.Family))>
			<cfset arrUserInfo = ListToArray(valueList(qGetData.UserInfo))>
			<cfset arrPosition = ListToArray(valueList(qGetData.Position))>
			<cfset arrProgramInfo = ListToArray(valueList(qGetData.ProgramInfo))>
			<cfset arrReportType = ListToArray(valueList(qGetData.ReportType))>
			<cfset arrConditions = ListToArray(valueList(qGetData.Conditions))>
			<cfset arrBudgetClass = ListToArray(valueList(qGetData.BudgetClass))>
			<cfset arrBusinessSegment = ListToArray(valueList(qGetData.BusinessSegment))>
			<cfset arrDatasource = ListToArray(valueList(qGetData.Datasource))>
			<cfset arrDiscount_Type = ListToArray(valueList(qGetData.Discount_Type))>
			<cfset arrFixed_Discount_Types = ListToArray(valueList(qGetData.Fixed_Discount_Types))>
			<cfset arrRebate_Discount_Types = ListToArray(valueList(qGetData.Rebate_Discount_Types))>
			<cfset arrLump_Sum_Discount_Types = ListToArray(valueList(qGetData.Lump_Sum_Discount_Types))>
			<cfset arrGrowth_Discount_Types = ListToArray(valueList(qGetData.Growth_Discount_Types))>
			<cfset arrRate_Compare = ListToArray(valueList(qGetData.Rate_Compare))>
			<cfset arrRate_Uom = ListToArray(valueList(qGetData.Rate_Uom))>
			<cfset arrRate_Val = ListToArray(valueList(qGetData.Rate_Val))>

			<cfset strData.Status = arrStatus>
			<cfset strData.Template = arrTemplate>
			<cfset strData.RSP = arrRSP>
			<cfset strData.BuyingGroup = arrBuyingGroup>
			<cfset strData.Family = arrFamily>
			<cfset strData.UserInfo = arrUserInfo>
			<cfset strData.Position = arrPosition>
			<cfset strData.ProgramInfo = arrProgramInfo>
			<cfset strData.ReportType = arrReportType>
			<cfset strData.Conditions = arrConditions>
			<cfset strData.Program_Info = qGetData.Program_Info>
			<cfset strData.Distributor_Info= qGetData.Distributor_Info>
			<cfset strData.Operator_Info = qGetData.Operator_Info>
			<cfset strData.Item_Info = qGetData.Item_Info>
			<cfset strData.BudgetClass = arrBudgetClass>
			<cfset strData.BusinessSegment = arrBusinessSegment>
			<cfset strData.Datasource = arrDatasource>
			<cfset strData.Discount_Type = arrDiscount_Type>
			<cfset strData.Fixed_Discount_Types = arrFixed_Discount_Types>
			<cfset strData.Rebate_Discount_Types = arrRebate_Discount_Types>
			<cfset strData.Lump_Sum_Discount_Types = arrLump_Sum_Discount_Types>
			<cfset strData.Growth_Discount_Types = arrGrowth_Discount_Types>
			<cfset strData.Rate_Compare = arrRate_Compare>
			<cfset strData.Rate_Uom = arrRate_Uom>
			<cfset strData.Rate_Val = arrRate_Val>

			<cfset strData = serializeJSON(strData, "struct")>

		<cfreturn strData>
	</cffunction>
	
	<!--- Used by AG Grid Program search --->
	<cffunction name="getFavoriteProgramList" output="false" returntype="query">
		<cfargument name="userID" required="true">
			<cfquery name="getFavorites" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT		upl.User_Program_List_id, 
							upl.List_Name
				FROM      dbo.User_Program_List upl
				INNER JOIN dbo.User_Program_List_Data upld
				ON upl.User_Program_List_id = upld.User_Program_List_id
				WHERE upl.User_Id = '#arguments.userID#'
				/* Where there is a value in the column - either "Programs" or "Catalog".
				These are the favorites saved from Ag Grid. 
				*/
				AND nullif(upld.DATASOURCE,'') IS NOT NULL
				ORDER BY upl.List_Name
			</cfquery>

		<cfreturn getFavorites>
	</cffunction>

	<!--- Used by AG Grid Program search --->
	<cffunction name="getFavoritesCount" output="false" access="remote" returnFormat="json">
		<cfargument name="userID" required="true">

			<cfset var strData = structNew()>

			<cfquery name="qGetFavoritesCount" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT    COUNT(upl.User_Program_List_id) As NumOfRecords
				FROM      dbo.User_Program_List upl
				INNER JOIN dbo.User_Program_List_Data upld
				ON upl.User_Program_List_id = upld.User_Program_List_id
				WHERE upl.User_Id = '#arguments.userID#'
				/* Where there is a value in the column - either "Programs" or "Catalog".
				These are the favorites saved from Ag Grid.
				*/
				AND nullif(upld.DATASOURCE,'') IS NOT NULL
			</cfquery>

			<cfset strData.FavoriteCount = qGetFavoritesCount.NumOfRecords>

		<cfreturn serializeJSON(strData, "struct")>
	</cffunction>

	<!--- Used by AG Grid Program search --->
	<cffunction name="getDuplicateFavoritesByName" output="false" access="remote" returnFormat="json">
		<cfargument name="userID" required="true">
		<cfargument name="lName" required="true" type="String">

			<cfset var strData = structNew()>

			<cfquery name="qGetDuplicateFavoritesByName" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
				SELECT upl.User_Program_List_id
				FROM dbo.User_Program_List upl
				INNER JOIN dbo.User_Program_List_Data upld
				ON upl.User_Program_List_id = upld.User_Program_List_id
				WHERE upl.User_Id = '#arguments.userID#'
				/* Where there is a value in the column - either "Programs" or "Catalog".
				These are the favorites saved from Ag Grid.
				*/
				AND nullif(upld.DATASOURCE,'') IS NOT NULL
				AND upl.List_Name = '#arguments.lName#'
			</cfquery>

			<cfset strData.DuplicateCount = qGetDuplicateFavoritesByName.recordcount>

		<cfreturn serializeJSON(strData, "struct")>
	</cffunction>

	<!--- save a list of program criteria for future use.
	This one is used for Adobe Flex Program search tool.
	--->
	<cffunction name="saveUserProgramCriteria" output="false" access="remote" returntype="void">
	<cfargument name="UserId" required="true" type="String">
	<cfargument name="lName" required="true" type="String">
	<cfargument name="Status" required="true" type="String">
	<cfargument name="Template" required="true" type="String">
	<cfargument name="RSP" required="true" type="String">
	<cfargument name="BuyingGroup" required="true" type="String">
	<cfargument name="Family" required="true" type="String">
	<cfargument name="UserInfo" required="true" type="String">
	<cfargument name="Position" required="true" type="String">
	<cfargument name="ProgramInfo" required="true" type="String">
	<cfargument name="ReportType" required="true" type="String">
	<cfargument name="Conditions" required="true" type="String">
	<cfargument name="Program_Info" required="true" type="String">
	<cfargument name="Distributor_Info" required="true" type="String">
	<cfargument name="Operator_Info" required="true" type="String">
	<cfargument name="Item_Info" required="true" type="String">
	<cfargument name="BudgetClass" required="true" type="String">
	<cfargument name="BusinessSegments" required="true" type="String">

		<cfset saveUserProgramCriteriaData(argumentcollection='#arguments#')>
	</cffunction>

	<!--- save a list of program criteria for future use.
	This one is used for AG Grid tool.
	--->
	<cffunction name="saveUserFavoriteProgramCriteria" output="false" access="remote" returnFormat="json">
		<cfargument name="UserId" required="true" type="String">
		<cfargument name="lName" required="true" type="String">
		<cfargument name="Status" required="true" type="String">
		<cfargument name="Template" required="true" type="String">
		<cfargument name="RSP" required="true" type="String">
		<cfargument name="BuyingGroup" required="true" type="String">
		<cfargument name="Family" required="true" type="String">
		<cfargument name="UserInfo" required="true" type="String">
		<cfargument name="Position" required="true" type="String">
		<cfargument name="ProgramInfo" required="true" type="String">
		<cfargument name="ReportType" required="true" type="String">
		<cfargument name="Conditions" required="true" type="String">
		<cfargument name="Program_Info" required="true" type="String">
		<cfargument name="Distributor_Info" required="true" type="String">
		<cfargument name="Operator_Info" required="true" type="String">
		<cfargument name="Item_Info" required="true" type="String">
		<cfargument name="BudgetClass" required="false" type="String" default="">
		<cfargument name="BusinessSegment" required="false" type="String" default="">
		<cfargument name="Datasource" required="false" type="String" default="">
		<cfargument name="Discount_Type" required="false" type="String" default="">
		<cfargument name="Fixed_Discount_Types" required="false" type="String" default="">
		<cfargument name="Rebate_Discount_Types" required="false" type="String" default="">
		<cfargument name="Lump_Sum_Discount_Types" required="false" type="String" default="">
		<cfargument name="Growth_Discount_Types" required="false" type="String" default="">
		<cfargument name="Rate_Compare" required="false" type="String" default="">
		<cfargument name="Rate_Uom" required="false" type="String" default="">
		<cfargument name="Rate_Val" required="false" type="String" default="">

		<cfset local.stReturnMsg = saveUserProgramFavoriteCriteriaData(argumentcollection='#arguments#')>
		<cfreturn serializeJSON(local.stReturnMsg, "struct")>
	</cffunction>

	<!--- Even though there are arguments being passed to "saveUserProgramCriteria". It does not work
		  when we use "cfargument" here". This one is used for Adobe Flex Program search tool.
	--->
	<cffunction name="saveUserProgramCriteriaData" output="false" access="private" returntype="void">

	<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var i = "">
		
		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Program_list(
							User_Id, 
							List_Name)
				values (
					<cfqueryparam value="#arguments.UserId#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.lName#" cfsqltype="CF_SQL_VARCHAR" />
					)
				
			      SELECT @@Identity AS newId      
			      SET NOCOUNT OFF 
			</cfquery>
			<cfset listId = qCreate.newId />
			
					<cfquery name="qGetID" datasource="#application.datasource#">
						insert into dbo.User_Program_list_Data(
								User_Program_List_Id,Status,Template,RSP,BuyingGroup,Family,UserInfo,Position,
								ProgramInfo,ReportType,Conditions,Program_Info,Distributor_Info,
								Operator_Info,Item_Info,BudgetClass,BusinessSegment,Discount_Type,
								Fixed_Discount_Types,Rebate_Discount_Types,Lump_Sum_Discount_Types,
								Growth_Discount_Types,Rate_Compare,Rate_Uom,Rate_Val
						)
						values (
						<cfqueryparam value="#listId#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Status#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Template#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.RSP#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BuyingGroup#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Family#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.UserInfo#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Position#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.ProgramInfo#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.ReportType#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Conditions#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Program_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Distributor_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Operator_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Item_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BudgetClass#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BusinessSegments#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Discount_Type#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Fixed_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rebate_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Lump_Sum_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Growth_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Compare#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Uom#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Val#" cfsqltype="CF_SQL_VARCHAR" />
						)
					</cfquery>
			</cftransaction>

				<!--- <cfscript>
			arguments.bean.setUser_Item_List_Id(qGetID.User_Item_List_Id);
		</cfscript>
		<cfreturn arguments.bean /> --->
	</cffunction>

	<!--- This one is used for AG Grid Program search tool. --->
	<cffunction name="saveUserProgramFavoriteCriteriaData" output="false" access="private" returntype="struct">

		<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var i = "">
		<cfset var dataSourceText = "">
		<cfset var stReturnMsg = StructNew()>
		
		<cfif arguments.Datasource eq 1>
			<cfset dataSourceText = "Catalog">
		<cfelse>
			<!--- "Programs" is the default value. 
			We need to make thus entry to differentiate between favorites saved from Flex and Ag Grid.
			There is no proper way to convert the favorites from flex into Ag Grid and so we decided to
			not show the favories saved fron Flex on the new Ag Grid screen and vice-versa. The favorites
			saved from Ag Grid will have an entry in the "Datasource" column - either "Programs" or "Catalog".
			The fsavorites saved fron Flex will have the "Datasource" column blank.
			--->
			<cfset dataSourceText = "Programs">
		</cfif>

		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Program_list(
							User_Id, 
							List_Name)
				values (
					<cfqueryparam value="#arguments.UserId#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.lName#" cfsqltype="CF_SQL_VARCHAR" />
					)
				
			      SELECT @@Identity AS newId      
			      SET NOCOUNT OFF 
			</cfquery>
			<cfset listId = qCreate.newId />
			
					<cfquery name="qGetID" datasource="#application.datasource#">
						insert into dbo.User_Program_list_Data(
								User_Program_List_Id,Status,Template,RSP,BuyingGroup,Family,UserInfo,Position,
								ProgramInfo,ReportType,Conditions,Program_Info,Distributor_Info,
								Operator_Info,Item_Info,BudgetClass,BusinessSegment,Datasource,Discount_Type,
								Fixed_Discount_Types,Rebate_Discount_Types,Lump_Sum_Discount_Types,
								Growth_Discount_Types,Rate_Compare,Rate_Uom,Rate_Val)
						values (
						<cfqueryparam value="#listId#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Status#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Template#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.RSP#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BuyingGroup#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Family#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.UserInfo#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Position#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.ProgramInfo#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.ReportType#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Conditions#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Program_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Distributor_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Operator_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Item_Info#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BudgetClass#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.BusinessSegment#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#dataSourceText#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Discount_Type#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Fixed_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rebate_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Lump_Sum_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Growth_Discount_Types#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Compare#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Uom#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#arguments.Rate_Val#" cfsqltype="CF_SQL_VARCHAR" />
						)
					</cfquery>
			</cftransaction>

			<cfset stReturnMsg.listID = listId>
			<cfset stReturnMsg.listName = arguments.lName>

			<cfreturn stReturnMsg>
	</cffunction>

	<cffunction name="deleteUserProgramList" output="false" access="remote" returntype="void">
		<cfargument required="true" name="ID" type="Numeric">
		<cfset var qDeleteUser_Program_list_Data = "">
		
		<cftransaction action="BEGIN">
			<cftry>
		<cfquery name="qDeleteUser_Program_list_Data" datasource="#application.datasource#">
					DELETE FROM dbo.User_Program_list_Data
					WHERE User_Program_list_Id = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfquery name="qDeleteUser_Program_list" datasource="#application.datasource#">
					DELETE FROM dbo.User_Program_list
					WHERE User_Program_list_Id = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
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
