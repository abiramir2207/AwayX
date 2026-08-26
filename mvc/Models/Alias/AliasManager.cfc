<cfcomponent hint="Alias Manager">

<cffunction name="init" output="false" returntype="mvc.Models.Alias.AliasManager">

	<cfreturn this />

</cffunction>

<cffunction name="getProductInfo" access="public" returntype="query">
	<cfargument name="formValues" required="true" type="Struct" />
	<cfargument name="DistributorLabel" required="true" type="string">
	<!--- Whether we have more than 1 distributor or family or buying group --->
	<cfargument name="AllDistributors" required="true" type="boolean" default="0">
	<!--- If 1, then show the ones without an alias --->
	<cfargument name="IsAlias" required="true" type="boolean" default="0">

	<cfset var qgetGroupLevelDesc = "">
	<cfset var DistributorLevel = arguments.DistributorLabel>

	<cfset var qgetDistributorName = "">
	<cfset var DistributorName = "">

	<cfset var qgetTmpItems = "">

	<cfset var qUpdateTmpAliasManagementProducts = "">

	<cfset var qgetProductInfo = "">

	<!--- DISTRIBUTOR LEVEL --->
	<!--- Do not use "var" here. The code expects all "vars" at the top. Even "cfif" is not allowed --->
	 <cfif formValues.Distributor_level eq 0>
		<cfset Distributor_ID = formValues.Distributor_List>
	 <cfelseif formValues.Distributor_level eq 2>
		<cfset Distributor_ID = formValues.Family_Name>
	 <cfelseif formValues.Distributor_level eq 3>
		<cfset Distributor_ID = formValues.Buying_Group>
	 </cfif>

	<!--- GET THE DESCRIPTION OF THE DISTRIBUTOR LEVEL --->
	<cfif formValues.Distributor_Level eq 2 OR formValues.Distributor_Level eq 3>
	<cfquery name="qgetGroupLevelDesc" datasource="#application.datasource#">
	SELECT dgl.Group_Level_Desc
	FROM distributor_group_level dgl
	WHERE dgl.distributor_group_level_type_id = <cfqueryparam value="#formValues.Distributor_Level#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

		<cfset DistributorLevel = qgetGroupLevelDesc.Group_Level_Desc>
	</cfif>


	<!--- GET THE NAME OF THE SELECTED DISTRIBUTOR (DISTRIBUTOR OR FAMILY OR BUYING GROUP) --->
	<cfquery name="qgetDistributorName" datasource="#application.datasource#">
	<!--- If a single distributor or family or buying group --->
	<cfif AllDistributors eq 0>
	SELECT
	<cfif formValues.Distributor_level eq 0>
	bsafc.ship_to
	<cfelseif formValues.Distributor_level eq 2>
	df.Family
	<cfelseif formValues.Distributor_level eq 3>
	dbg.Buying_Group
	</cfif>
	As DistributorName,

	<cfif formValues.Distributor_level eq 0>
	bsafc.BSA_Foodservice_Customers_ID
	<cfelseif formValues.Distributor_level eq 2>
	df.Family_ID
	<cfelseif formValues.Distributor_level eq 3>
	dbg.Buying_Group_ID
	</cfif>
	 As Distributor_ID

	FROM BSA_Foodservice_Customers bsafc
		LEFT JOIN Distributor_Family df
	ON bsafc.BSA_Foodservice_Customers_ID = df.Family_ID
		LEFT JOIN Distributor_Buying_Groups dbg
	ON bsafc.BSA_Foodservice_Customers_ID = dbg.Buying_Group_ID
	WHERE bsafc.BSA_Foodservice_Customers_ID = <cfqueryparam value="#Distributor_ID#" cfsqltype="CF_SQL_VARCHAR">

	<cfelse>
	<!--- If multiple distributors or family or buying group --->

	<cfif formValues.Distributor_level eq 0>
	SELECT ship_to As DistributorName,BSA_Foodservice_Customers_ID As Distributor_ID
	FROM BSA_Foodservice_Customers
	WHERE BSA_Foodservice_Customers_ID IN (<cfqueryparam value="#Distributor_ID#" cfsqltype="CF_SQL_VARCHAR" list="true">)
	AND Deleted = 0
	AND Active_Code = 'A'

	<cfelseif formValues.Distributor_level eq 2>
	SELECT Family As DistributorName,Family_ID As Distributor_ID
	FROM Distributor_Family
	WHERE Deleted = 0

	<cfelseif formValues.Distributor_level eq 3>
	SELECT Buying_Group As DistributorName, Buying_Group_ID As Distributor_ID
	FROM Distributor_Buying_Groups
	WHERE Deleted = 0
	</cfif>

	</cfif>
	</cfquery>

	<cfquery name="qCreateTmpTbl" datasource="#application.datasource#">
	if object_id('tempdb..##tmp_Alias_Management_Products') is not null
	drop table ##tmp_Alias_Management_Products

	CREATE TABLE ##tmp_Alias_Management_Products
	(
	Group_Level_ID tinyint,
	Group_Level_Desc varchar(50) Not Null,
	Distributor_ID varchar(50),
	Distributor_Number varchar(100) Not Null,
	Product_ID varchar(50),
	Item varchar(100) Not Null,
	Distributor_Product_Number varchar(50) Null
	)
	</cfquery>

	<!--- LOOP THROUGH PRODUCTS --->
	<cfloop list="#formValues.Product_List#" index="Product_ID">
	  <!--- LOOP THROUGH DISTRIBUTORS --->
	  <cfloop query="qgetDistributorName">

		<!--- GET THE ITEM NUMBER --->
		<cfquery name="qgetTmpItems" datasource="#application.datasource#">
		SELECT bfim.item
		FROM bsa_foodservice_items_master bfim
		WHERE bfim.bsa_foodservice_items_master_id = '#Product_ID#'
		</cfquery>

		<!--- INSERT ALL SELECTED INFO INTO TEMP TABLE --->
		<cfquery name="qgetTmpAliasManagementProducts" datasource="#application.datasource#">
		INSERT INTO ##tmp_Alias_Management_Products(Group_Level_ID,Group_Level_Desc,Distributor_ID,Distributor_Number,Product_ID,Item)
		VALUES
		(
		<cfqueryparam value="#formValues.Distributor_Level#" cfsqltype="CF_SQL_INTEGER">,<cfqueryparam value="#DistributorLevel#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#qgetDistributorName.Distributor_ID#" cfsqltype="CF_SQL_VARCHAR">,<cfqueryparam value="#qgetDistributorName.DistributorName#" cfsqltype="CF_SQL_VARCHAR">,
		<cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar">,<cfqueryparam value="#qgetTmpItems.item#" cfsqltype="cf_sql_varchar">
		)
		</cfquery>

	  </cfloop>
	</cfloop>

	<!--- UPDATE THE RECORDS WITH 'Distributor_Product_Number' FOR RECORDS WHICH ALREADY HAVE A 'Distributor_Product_Number' --->
	<cfquery name="qUpdateTmpAliasManagementProducts" datasource="#application.datasource#">
	UPDATE tmp_amp
	SET tmp_amp.Distributor_Product_Number = amp.Distributor_Product_Number
	FROM ##tmp_Alias_Management_Products tmp_amp INNER JOIN Alias_Management_Products amp
	ON  tmp_amp.Group_Level_ID = amp.Distributor_Group_Level_ID
	AND tmp_amp.Distributor_ID = amp.Distributor_ID
	AND tmp_amp.Product_ID = amp.Product_ID
	</cfquery>

	<!--- IF WE WANT TO SEE ENTRIES WITHOUT ANY ALIAS, THEN DELETE THE ONES WHICH HAVE AN ALIAS --->
	<cfif arguments.IsAlias eq 1>
	<cfquery name="qDelExistingAliases" datasource="#application.datasource#">
	 DELETE FROM ##tmp_Alias_Management_Products
	 WHERE Distributor_Product_Number IS NOT NULL
	 </cfquery>
	</cfif>

	<!--- NOW WE GET A LIST OF PRODUCTS WITH DISTRIBUTORS AND 'Distributor_Product_Number'.IN THIS STEP WE FINALLY GET A
	      DISTINCT LIST OF PRODUCTS WITH 'Distributor_Product_Number' (WHICH MAY OR MAY NOT BE EMPTY).
	--->

	<cfquery name="qgetProductInfo" datasource="#application.datasource#">
	SELECT LTRIM(RTRIM(Group_Level_Desc)) As Group_Level_Desc,LTRIM(RTRIM(Distributor_Number)) As Distributor_Number,
	LTRIM(RTRIM(Item)) As Item,LTRIM(RTRIM(Distributor_Product_Number)) As Distributor_Product_Number
	FROM ##tmp_Alias_Management_Products
	ORDER BY Item

	if object_id('tempdb..##tmp_Alias_Management_Products') is not null
	drop table ##tmp_Alias_Management_Products
	</cfquery>

	<cfreturn qgetProductInfo />

</cffunction>

<!--- Get the Distributor levels --->
<cffunction name="getDistributorGroupLevels" access="public" returntype="query">

	<cfset var qgetDistributorGroupLevels = "">
	<cfquery name="qgetDistributorGroupLevels" datasource="#application.datasource#">
	SELECT Distributor_Group_Level_ID,Group_Level_Desc
	FROM   Distributor_Group_Level
	WHERE  Deleted = 0
	AND Group_Level_Desc_Internal IN ('Family','Buying Group')
	</cfquery>
	<cfreturn qgetDistributorGroupLevels />
</cffunction>

<!------ Add product alias ----->
<cffunction name="addProdAlias" output="false" hint="Function used to add product alias." returntype="void">
	<cfargument name="formValues" required="true" type="Struct" />
		<!---<cfdump var="#formValues#"><cfabort>--->

		<!--- Distributor Level --->
		<!--- Do not use "var" here. The code expects all "vars" at the top. Even "cfif" is not allowed --->
		<cfif formValues.Distributor_level eq 0>
			<cfset Distributor_ID = formValues.Distributor_List>
		<cfelseif formValues.Distributor_level eq 2>
			<cfset Distributor_ID = formValues.Family_Name>
		<cfelseif formValues.Distributor_level eq 3>
			<cfset Distributor_ID = formValues.Buying_Group>
		</cfif>

		<!--- Delete Alias --->
		<cfquery name="qgetExistingAlias" datasource="#application.datasource#">
		DELETE FROM Alias_Management_Products
		WHERE	Distributor_Group_level_ID = <cfqueryparam value="#formValues.Distributor_level#" cfsqltype="CF_SQL_INTEGER">
		AND	Distributor_ID = <cfqueryparam value="#Distributor_ID#" cfsqltype="cf_sql_varchar">
		AND	Product_ID IN (<cfqueryparam value="#DeleteProductList#" cfsqltype="cf_sql_varchar" list="true">)
		</cfquery>

		<cfloop list="#formValues.Product_List#" index="Product_ID">

		<!--- Does the alias already exist.. --->
		<cfquery name="qgetExistingAlias" datasource="#application.datasource#">
		SELECT	Count(Distributor_Product_Number) As AliasExists
		FROM	Alias_Management_Products
		WHERE	Distributor_Group_level_ID = <cfqueryparam value="#formValues.Distributor_level#" cfsqltype="CF_SQL_INTEGER">
		AND	Distributor_ID = <cfqueryparam value="#Distributor_ID#" cfsqltype="cf_sql_varchar">
		AND	Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfset Distributor_Product_Number = form['Distributor_Product_Number_'&Product_ID]>

		<!--- If the alias does not exist --->
		<cfif qgetExistingAlias.AliasExists EQ 0>
			<cfquery name="qAddProdAlias" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO Alias_Management_Products
					(Distributor_Group_level_ID,Distributor_Group_ID,Distributor_ID,Product_ID,Distributor_Product_Number,User_Entry,Updated_Date)
				VALUES
					(<cfqueryparam value="#formValues.Distributor_level#"  cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#Distributor_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#Distributor_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#Distributor_Product_Number#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="1" cfsqltype="CF_SQL_BIT">,
					<cfqueryparam value="#createodbcdatetime(Now())#" cfsqltype="CF_SQL_DATE">
					)

				SET NOCOUNT OFF
			</cfquery>
		<cfelse>
			<!--- If the alias exists --->
			<cfquery name="qUpdateProdAlias" datasource="#application.datasource#">
				SET NOCOUNT ON
				UPDATE Alias_Management_Products
				SET	Distributor_Product_Number = <cfqueryparam value="#Distributor_Product_Number#" cfsqltype="cf_sql_varchar">,
					Updated_Date = <cfqueryparam value="#createodbcdatetime(Now())#" cfsqltype="CF_SQL_DATE">

				WHERE Distributor_Group_level_ID = <cfqueryparam value="#formValues.Distributor_level#"  cfsqltype="CF_SQL_INTEGER">
				AND Distributor_ID = <cfqueryparam value="#Distributor_ID#" cfsqltype="cf_sql_varchar">
				AND Product_ID = <cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar">
				SET NOCOUNT OFF
			</cfquery>
		</cfif>
		</cfloop>

		<!--- We do not need to execute this for any aliases added at the distributor level --->
		<cfif formValues.Distributor_level neq 0>
			<!--- Now we need to rerun the complete process of Alias allocation. It's best to run this everytime to avoid any issues. --->
			<cfstoredproc procedure="Update_Group_Alias" datasource="#application.datasource#">
			</cfstoredproc>
		</cfif>

</cffunction>

<!--- Get alias upload history --->
<cffunction name="getAliasManagementHistory" access="public" returntype="query">

	<cfset var qgetAliasManagementHistory = "">
	<cfquery name="qgetAliasManagementHistory" datasource="#application.datasource#">
	SELECT amph.Alias_Management_Product_History_ID, amph.Upload_Action_Status,
	amph.Is_Complete,
	_Users.Name_First + ' ' + _Users.Name_Last As Uploaded_By,
	convert(char(10),created_date,101) + convert(char(10),created_date,108)
	As Created_Date,amph.Upload_FileName,
	(
	 <!--- Are there any errors associated with the upload --->
	 SELECT Count(Alias_Management_Product_History_ID)
	 FROM Alias_Management_Products_History_Detail
	 WHERE Alias_Management_Product_History_ID = amph.Alias_Management_Product_History_ID
	 AND Alias_Management_Products_History_Detail.Error_Message IS NOT NULL
	) As Error_Count

	FROM   Alias_Management_Products_History amph

	INNER JOIN _Users
	ON amph.Creator_ID = _Users.User_ID
	ORDER BY amph.Alias_Management_Product_History_ID DESC
	</cfquery>

	<cfreturn qgetAliasManagementHistory />

</cffunction>

<!--- Get alias upload error details --->
<cffunction name="getAliasManagementHistoryDetail" access="public" returntype="query">
	<cfargument name="Alias_Management_Product_History_ID" required="true" type="numeric" />

	<cfset var qgetAliasManagementHistoryDetail = "">
	<cfquery name="qgetAliasManagementHistoryDetail" datasource="#application.datasource#">
	 SELECT amphd.Row_Num,amphd.Error_Message
	 FROM   Alias_Management_Products_History amph
	 INNER JOIN Alias_Management_Products_History_Detail amphd
	 ON amph.Alias_Management_Product_History_ID = amphd.Alias_Management_Product_History_ID
	 WHERE amphd.Error_Message IS NOT NULL
	 AND amphd.Alias_Management_Product_History_ID =  <cfqueryparam value="#arguments.Alias_Management_Product_History_ID#" cfsqltype="CF_SQL_INTEGER">
	 ORDER BY amphd.Row_num
	</cfquery>

	<cfreturn qgetAliasManagementHistoryDetail />

</cffunction>

<!--- Get alias (Distributor Product Number) search results --->
<cffunction name="getSearchResults" access="public" returntype="query">
	<cfargument name="Item" required="false" type="string" />
	<cfargument name="Shr_Ship_To" required="false" type="string" />
	<cfargument name="Family_ID" required="false" type="string" />
	<cfargument name="Buying_Group_ID" required="false" type="string" />
	<cfargument name="Sort_By" required="true" type="string" />
	<cfargument name="Sort_Order" required="true" type="string" />
	<cfargument name="DistributorSingularLabel" required="true" type="string" />
	<cfargument name="FamilySingularlabel" required="true" type="string" />
	<cfargument name="BuyingGroupSingularlabel" required="true" type="string" />

	<cfset var qgetSearchResults = "">

	<cfif arguments.Sort_By eq "Item">
	 <cfset SortByTableName = "bsafim">
	<cfelseif arguments.Sort_By eq "Distributor_Product_Number" OR  arguments.Sort_By eq "Distributor_Group_Level_ID"
	 OR arguments.Sort_By eq "Distributor_Name">
	 <cfset SortByTableName = "amp">
	</cfif>

	<cfquery name="qgetSearchResults" datasource="#application.datasource#">
	SELECT bsafim.BSA_Foodservice_Items_Master_ID,bsafim.Item,amp.Distributor_Product_Number,amp.Distributor_Group_Level_ID,
	CASE amp.Distributor_Group_Level_ID
	 WHEN 0
		THEN bsafc.Name
	 WHEN 2
		THEN df.Family_Name
	 WHEN 3
		THEN dbg.Buying_Group_Name
	 END
	 As Distributor_Name,
	CASE amp.Distributor_Group_Level_ID
	 WHEN 0
		THEN bsafc.Shr_Ship_To
	 WHEN 2
		THEN df.Family
	 WHEN 3
		THEN dbg.Buying_Group
	 END
	 As Distributor_ID,
	CASE amp.Distributor_Group_Level_ID
	 WHEN 0
		THEN '#arguments.DistributorSingularLabel#'
	 WHEN 2
		THEN '#arguments.FamilySingularlabel#'
	 WHEN 3
		THEN '#arguments.BuyingGroupSingularlabel#'
	 END
	 As Distributor_Group_Level

	 FROM Alias_Management_Products amp

	 INNER JOIN BSA_Foodservice_Items_Master bsafim
	 ON bsafim.BSA_Foodservice_Items_Master_ID = amp.Product_ID

	 LEFT JOIN BSA_Foodservice_Customers bsafc
	 ON bsafc.BSA_Foodservice_Customers_ID = amp.Distributor_ID

	 LEFT JOIN Distributor_Family df
	 ON df.Family_ID = amp.Distributor_ID

	 LEFT JOIN Distributor_Buying_Groups dbg
	 ON dbg.Buying_Group_ID = amp.Distributor_ID

	 <!--- We can only have one Distributor level search criteria at a time
	      (Distributor,Family and Buying Group)
	 --->
	 <cfif arguments.Shr_Ship_To neq "">
	 WHERE CHARINDEX(<cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="CF_SQL_VARCHAR">, bsafc.Shr_Ship_To) > 0

	 <cfelseif arguments.Family_ID neq "0">
	  WHERE CHARINDEX(<cfqueryparam value="#arguments.Family_ID#" cfsqltype="CF_SQL_VARCHAR">, df.Family_ID) > 0

	 <cfelseif arguments.Buying_Group_ID neq "0">
	  WHERE CHARINDEX(<cfqueryparam value="#arguments.Buying_Group_ID#" cfsqltype="CF_SQL_VARCHAR">, dbg.Buying_Group_ID) > 0
	 </cfif>

	 <!--- If the only search criteria is "Item" --->
	 <cfif arguments.Item neq "">
	 <cfif arguments.Shr_Ship_To eq "" AND arguments.Family_ID eq "0" AND arguments.Buying_Group_ID eq "0">
	 WHERE
	 <cfelse>
	 AND
	 </cfif>
	 CHARINDEX(<cfqueryparam value="#arguments.Item#" cfsqltype="CF_SQL_VARCHAR">, bsafim.Item) > 0
	 </cfif>

	 <!--- If no search criteria is passed. It is an open search. --->
	 <cfif arguments.Item eq "" and arguments.Shr_Ship_To eq "" AND arguments.Family_ID eq "0" AND arguments.Buying_Group_ID eq "0">
	 WHERE
	 <cfelse>
	 AND
	 </cfif>
	 <!--- Entries made by the user. We do not want to see group (Family,Buying Group) members which were populated from
	       the nightly process
	 --->
	 amp.User_Entry = 1

	ORDER BY #SortByTableName#.#arguments.Sort_By# #arguments.Sort_Order#
	</cfquery>

	<cfreturn qgetSearchResults />

</cffunction>

<!--- Add Distributor Level Ranking (1,2,3 ranks)--->
<cffunction name="addDistributorLevelRanking" access="public" returntype="void">
	<cfargument name="Shr_Ship_To" required="true" type="numeric" />
	<cfargument name="Family_Name" required="true" type="numeric" />
	<cfargument name="Buying_Group" required="true" type="numeric" />

	<cfset var qaddDistributorLevelRanking = "">
	<cfquery name="qInactivateDistributorLevelRanking" datasource="#application.datasource#">
	 UPDATE Alias_Management_Ranking
	 SET Active_Ranking = 0
	</cfquery>

	<cfquery name="qaddDistributorLevelRanking" datasource="#application.datasource#">
	<!--- Group level of 0 is 'Distributor' --->
	 INSERT INTO Alias_Management_Ranking(Distributor_Group_level_ID,Alias_Management_Ranking,Active_Ranking,Creator_ID,Created_Date)
	 VALUES(0,<cfqueryparam value="#arguments.Shr_Ship_To#" cfsqltype="CF_SQL_VARCHAR">,1,<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	 ,getDate())

	 <!--- Group level of 2 is 'Family' --->
	 INSERT INTO Alias_Management_Ranking(Distributor_Group_level_ID,Alias_Management_Ranking,Active_Ranking,Creator_ID,Created_Date)
	 VALUES(2,<cfqueryparam value="#arguments.Family_Name#" cfsqltype="CF_SQL_VARCHAR">,1,<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	 ,getDate())

	<!--- Group level of 3 is 'Buying Group' --->
	 INSERT INTO Alias_Management_Ranking(Distributor_Group_level_ID,Alias_Management_Ranking,Active_Ranking,Creator_ID,Created_Date)
	 VALUES(3,<cfqueryparam value="#arguments.Buying_Group#" cfsqltype="CF_SQL_VARCHAR">,1,<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
	 ,getDate())
	</cfquery>

</cffunction>

<!--- Get Distributor Level Ranking (1,2,3 ranks) --->
<cffunction name="getDistributorLevelRanking" access="public" returntype="query">
	<cfargument name="DistributorLevel" required="false" type="string" default="">

	<cfset var qgetDistributorLevelRanking = "">
	<cfquery name="qgetDistributorLevelRanking" datasource="#application.datasource#">
	 SELECT Distributor_Group_level_ID,Alias_Management_Ranking
	 FROM Alias_Management_Ranking
	 WHERE Active_Ranking = 1
	 <cfif arguments.DistributorLevel neq "">
	  AND Distributor_Group_level_ID = <cfqueryparam value="#arguments.DistributorLevel#" cfsqltype="CF_SQL_INTEGER">
	 </cfif>
	</cfquery>

	<cfreturn qgetDistributorLevelRanking />

</cffunction>

<!--- Has the Alias upload process Completed.... --->
<cffunction name="getCompletedStatus" access="public" returntype="query">

	<cfset var qgetCompletedStatus = "">
	<cfquery name="qgetCompletedStatus" datasource="#application.datasource#">
	SELECT	TOP 1 Is_Complete, Upload_Action_Status
	FROM Alias_Management_Products_History
	ORDER BY Alias_Management_Product_History_ID DESC
	</cfquery>
	<cfreturn qgetCompletedStatus />

</cffunction>

</cfcomponent>