<!----------------------------------------------------------------------------------
Name: 			ADLManager.cfc
Copyright:		(c) 2014 Blacksmith Applications, Inc.
Created Date: 	05/05/2021
Created By:    	Deepa
Description:	DB edit/access for ADL (Authorized Distribution List)
---------------------------------------------------------------------------------->

<cfcomponent name="ADLManager" displayname="ADLManager" hint="Manages ADL settings" extends="mvc.Models.SettingsService" access="public">


	<!--- Get Header level information  --->
	<cffunction name="getADLHeader" access="public" returntype="query" output="false" >
		<cfargument name="headerId" type="numeric" required="false" default="0" />

		<cfquery name="getADLHeader" datasource="#application.datasource#">
			SELECT	h.Authorized_Distribution_List_Header_ID, h.Title,
					grp.Group_Desc + ' (' + grp.Group_Number + ')' as Customer,
					ISNULL(uu.Name_First + ' ' + uu.Name_Last, cu.Name_First + ' ' + cu.Name_Last) as Updated_By_User_Name,
					ISNULL(h.Updated_Date, h.Created_Date) as Updated_Date
			FROM	Authorized_Distribution_List_Header h
			LEFT JOIN _Users cu ON cu.User_ID = h.Created_By
			LEFT JOIN _Users uu ON uu.User_ID = h.Updated_By
			LEFT JOIN All_Customer_Group_Types grp
			ON 		grp.Group_Guid = h.Distributor_Group_ID
			AND		grp.Distributor_Group_Level_ID = h.Distributor_Group_Level_ID
			WHERE	h.Deleted = 0
			<cfif arguments.headerId neq 0>
			AND		h.Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric">
			</cfif>
			ORDER BY h.Title
		</cfquery>

		<cfreturn getADLHeader />
	</cffunction>

	<cffunction name="getADLHeaderAsArray" returntype="array" hint="Take a query as input and return an array">
		<cfargument name="headerId" type="numeric" required="false" default="0" />

		<cfset qryADLHeader = getADLHeader(arguments.headerId) />

		<cfreturn getQueryAsArray(qryADLHeader) />

	</cffunction>

	<!--- Save Header level information  --->
	<cffunction name="saveADLHeader" access="public" returntype="void" output="false" >
		<cfargument name="customer" type="string" required="true" />
		<cfargument name="title" type="string" required="true" />

		<cfset local.distGroupType  = getDistributorGroupType()>
		<cfquery name="insertADLHeader" datasource="#application.datasource#">
			INSERT INTO Authorized_Distribution_List_Header (Title, Distributor_Group_Level_ID, Distributor_Group_ID, Created_By)
			VALUES (
				<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#val(local.distGroupType)#" cfsqltype="cf_sql_numeric">,
				<cfqueryparam value="#arguments.customer#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
			)
		</cfquery>

	</cffunction>

	<!--- Get detail level information  --->
	<cffunction name="getADLdetail" access="public" returntype="query" output="false" >
		<cfargument name="headerId" type="numeric" required="false" default="0" />

		<cfquery name="getADLdetail" datasource="#application.datasource#">
			SELECT	d.Authorized_Distribution_List_Detail_ID, i.Item, i.Description,
					d.Include as inc_exc,
					d.Start_Date, d.End_Date, li.Item as Like_Item, li.Description as  Like_Item_Desc,
					d.Like_Product_Percent,
					d.BSA_Foodservice_Items_Master_ID as Product_ID, d.Active,
					d.Authorized_Distribution_List_Detail_ID as Row_ID,
					d.Like_BSA_Foodservice_Items_Master_ID as Like_Product_ID
			FROM	Authorized_Distribution_List_Detail d
			INNER JOIN BSA_Foodservice_Items_Master i ON i.BSA_Foodservice_Items_Master_ID = d.BSA_Foodservice_Items_Master_ID
			LEFT JOIN BSA_Foodservice_Items_Master li ON li.BSA_Foodservice_Items_Master_ID = d.Like_BSA_Foodservice_Items_Master_ID
			WHERE	d.Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric" />
			ORDER BY Item
		</cfquery>

		<cfreturn getADLdetail />
	</cffunction>

	<cffunction name="getADLdetailAsArray" returntype="array" hint="Take a query as input and return an array">
		<cfargument name="headerId" type="numeric" required="false" default="0" />

		<cfset qryADLDetail = getADLdetail(arguments.headerId) />

		<cfreturn getQueryAsArray(qryADLDetail) />
	</cffunction>

	<!--- Add Products  --->
	<cffunction name="addProducts" access="public" returntype="void" output="false" >
		<cfargument name="headerId" type="numeric" required="false" default="0" />
		<cfargument name="ProductList" type="string" required="false" default="" />

		<cfquery name="qDrop" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##tmp_insert') IS NOT NULL
			DROP TABLE ##tmp_insert
		</cfquery>

		<cfquery name="insertADLDetail" datasource="#application.datasource#">
			SELECT	i.BSA_Foodservice_Items_Master_ID
			INTO	##tmp_insert
			FROM	BSA_Foodservice_Items_Master i
			WHERE	i.BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#arguments.ProductList#" cfsqltype="cf_sql_varchar" list="yes" />)
			AND		NOT EXISTS (
				SELECT 	1
				FROM 	Authorized_Distribution_List_Detail d
				WHERE 	d.Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric" />
				AND		d.BSA_Foodservice_Items_Master_ID = i.BSA_Foodservice_Items_Master_ID
			)

			INSERT INTO Authorized_Distribution_List_Detail (Authorized_Distribution_List_Header_ID, BSA_Foodservice_Items_Master_ID, Active, Created_By)
			SELECT	#arguments.headerId# as Authorized_Distribution_List_Header_ID, BSA_Foodservice_Items_Master_ID, 0 as Active,
					<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">
			FROM	##tmp_insert

			INSERT INTO Authorized_Distribution_List_History (
					Authorized_Distribution_List_Header_ID, Authorized_Distribution_List_Detail_ID,
					Distributor_Group_Level_ID, Distributor_Group_ID,
					BSA_Foodservice_Items_Master_ID, Include, Start_Date, End_Date,
					Like_BSA_Foodservice_Items_Master_ID, Like_Product_Percent,
					Updated_By,
					Action
			)
			SELECT	d.Authorized_Distribution_List_Header_ID, d.Authorized_Distribution_List_Detail_ID,
					h.Distributor_Group_Level_ID, h.Distributor_Group_ID,
					d.BSA_Foodservice_Items_Master_ID, d.Include, d.Start_Date, d.End_Date,
					d.Like_BSA_Foodservice_Items_Master_ID, d.Like_Product_Percent,
					<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="add prod" cfsqltype="cf_sql_varchar">
			FROM	Authorized_Distribution_List_Detail d
			INNER JOIN Authorized_Distribution_List_Header h
			ON		h.Authorized_Distribution_List_Header_ID = d.Authorized_Distribution_List_Header_ID
			WHERE	d.Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric" />
			AND		EXISTS (SELECT 1 FROM ##tmp_insert i WHERE i.BSA_Foodservice_Items_Master_ID = d.BSA_Foodservice_Items_Master_ID)
		</cfquery>

		<cfset setHeaderUpdatedInfo(arguments.headerId) />

	</cffunction>

	<cffunction name="updateADLValues" output="false" returntype="string" returnformat="JSON" access="remote">
		<cfargument name="headerId" type="numeric" required="true" />
		<cfargument name="rowId" type="numeric" required="true" />
		<cfargument name="inc_exc" type="boolean" required="true" />
		<cfargument name="start_date" type="string" required="true" />
		<cfargument name="end_date" type="string" required="true" />
		<cfargument name="like_product_percent" type="string" required="true" />

		<cfset active = 0 />

		<cfset start_date_valid = IsValid("date", arguments.start_date) />
		<cfset end_date_valid = IsValid("date", arguments.end_date) />
		<cfset like_product_percent_valid = IsValid("numeric", arguments.like_product_percent) />
		<cfif start_date_valid && end_date_valid>
			<cfset active = 1 />
		</cfif>

		<cfquery name="updateADLDetail" datasource="#application.datasource#">
			UPDATE	Authorized_Distribution_List_Detail
			SET		Active = <cfqueryparam value="#active#" cfsqltype="cf_sql_bit" />,
					Include = <cfqueryparam value="#arguments.inc_exc#" cfsqltype="cf_sql_bit" />,
					Start_Date = <cfqueryparam value="#arguments.start_date#" cfsqltype="cf_sql_date" null="#!start_date_valid#" />,
					End_Date = <cfqueryparam value="#arguments.end_date#" cfsqltype="cf_sql_date" null="#!end_date_valid#" />,
					Like_Product_Percent = <cfqueryparam value="#arguments.like_product_percent#" cfsqltype="cf_sql_float" null="#!like_product_percent_valid#" />,
					Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					Updated_Date = GetDate()
			WHERE	Authorized_Distribution_List_Detail_ID = <cfqueryparam value="#arguments.rowId#" cfsqltype="cf_sql_numeric" />
		</cfquery>

		<cfset setHeaderUpdatedInfo(arguments.headerId) />

		<cfset insertHistoryDetail(arguments.rowId, "upd") />

		<cfreturn getCurrentUpdatedInfo() />

	</cffunction>

	<!--- Update Like Product  --->
	<cffunction name="updateLikeProduct" access="public" returntype="void" output="false" >
		<cfargument name="headerId" type="numeric" required="true" />
		<cfargument name="rowId" type="numeric" required="true" />
		<cfargument name="ProductList" type="string" required="true" />

		<cfquery name="qUpdateLikeProduct" datasource="#application.datasource#">
			UPDATE	Authorized_Distribution_List_Detail
			SET		Like_BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#ListFirst(arguments.ProductList)#" cfsqltype="cf_sql_varchar" null="#arguments.ProductList eq ''#" />,
					Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					Updated_Date = GetDate()
			WHERE	Authorized_Distribution_List_Detail_ID = <cfqueryparam value="#arguments.rowId#" cfsqltype="cf_sql_numeric" />
		</cfquery>

		<cfset setHeaderUpdatedInfo(arguments.headerId) />

		<cfset insertHistoryDetail(arguments.rowId, "upd-like prod") />

	</cffunction>

	<cffunction name="deleteADLDetail" output="false" returntype="string" returnformat="JSON" access="remote">
		<cfargument name="headerId" type="numeric" required="true" />
		<cfargument name="rowId" type="numeric" required="true" />

		<cfset insertHistoryDetail(arguments.rowId, "del") />

		<cfquery name="insertADLDetail" datasource="#application.datasource#">
			DELETE	Authorized_Distribution_List_Detail
			WHERE	Authorized_Distribution_List_Detail_ID = <cfqueryparam value="#arguments.rowId#" cfsqltype="cf_sql_numeric" />
		</cfquery>

		<cfset setHeaderUpdatedInfo(arguments.headerId) />

		<cfreturn getCurrentUpdatedInfo() />
	</cffunction>

	<cffunction name="setHeaderUpdatedInfo" output="false" returntype="void">
		<cfargument name="headerId" type="numeric" required="true" />

		<cfquery name="updatedDate" datasource="#application.datasource#">
			UPDATE	Authorized_Distribution_List_Header
			SET		Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					Updated_Date = GetDate()
			WHERE	Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric" />
		</cfquery>

	</cffunction>

	<cffunction name="getCurrentUpdatedInfo" output="false" returntype="string">

		<cfscript>
		variables.reply = {};
		</cfscript>

		<cfset variables.reply.lastUpdatedDate = dateFormat(Now(), "medium") />
		<cfset variables.reply.lastUpdatedTime = timeFormat(Now(), "short") />
		<cfset variables.reply.lastUpdatedBy = "#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#" />

		<cfreturn SerializeJSON( variables.reply) />

	</cffunction>

	<cffunction name="insertHistoryDetail" output="false" returntype="void">
		<cfargument name="rowId" type="numeric" required="true" />
		<cfargument name="action" type="string" required="true" />

		<cfquery name="insertHistory" datasource="#application.datasource#">
			INSERT INTO Authorized_Distribution_List_History (
					Authorized_Distribution_List_Header_ID, Authorized_Distribution_List_Detail_ID,
					Distributor_Group_Level_ID, Distributor_Group_ID,
					BSA_Foodservice_Items_Master_ID, Include, Start_Date, End_Date,
					Like_BSA_Foodservice_Items_Master_ID, Like_Product_Percent,
					Updated_By,
					Action
			)
			SELECT	d.Authorized_Distribution_List_Header_ID, d.Authorized_Distribution_List_Detail_ID,
					h.Distributor_Group_Level_ID, h.Distributor_Group_ID,
					d.BSA_Foodservice_Items_Master_ID, d.Include, d.Start_Date, d.End_Date,
					d.Like_BSA_Foodservice_Items_Master_ID, d.Like_Product_Percent,
					<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.action#" cfsqltype="cf_sql_varchar">
			FROM	Authorized_Distribution_List_Detail d
			INNER JOIN Authorized_Distribution_List_Header h
			ON		h.Authorized_Distribution_List_Header_ID = d.Authorized_Distribution_List_Header_ID
			WHERE	d.Authorized_Distribution_List_Detail_ID = <cfqueryparam value="#arguments.rowId#" cfsqltype="cf_sql_numeric" />
		</cfquery>

	</cffunction>

	<cffunction name="getQueryAsArray" returntype="array" hint="Take a query as input and return an array">
		<cfargument name="qry" type="query" required="true" />

		<cfset retArr = ArrayNew(1)/>
		<cfloop query="qry">
			<cfset stRow = this.GetQueryRow(qry,currentRow) />
			<cfset arrayAppend(retArr, stRow) />
		</cfloop>
		<cfreturn retArr />
	</cffunction>

	<!--- Get distributor group type from app setting --->
    <cffunction name="getDistributorGroupType" returntype="numeric" output="false">
        <cfreturn application.util.query.get_setting('Authorized_Distribution_List_Dist_Group_Type', 0)>
    </cffunction>

	<!--- Get List of distributor groups based on app setting --->
    <cffunction name="getDistributorGroupTypes" output="false">
        <cfset local.distGroupType  = getDistributorGroupType()>

		<cfquery name="local.qTypes" datasource="#application.datasource#">
			SELECT  Group_Desc, Group_Guid, Group_Number
              FROM  All_Customer_Group_Types
             WHERE  Distributor_Group_Level_ID = <cfqueryparam value="#val(local.distGroupType)#" cfsqltype="cf_sql_numeric">
			        AND Deleted = 0
			ORDER BY Group_Desc
		 </cfquery>

        <cfreturn local.qTypes>
    </cffunction>

	<!--- Get List of distributor group label based on app setting --->
    <cffunction name="getDistributorGroupLabel" output="false">
        <cfset local.distGroupType  = getDistributorGroupType() />

        <cfquery name="local.qLabels" datasource="#application.datasource#">
            SELECT	Distributor_Group_Level_ID, Group_Level_Desc_Internal, Group_Level_Desc  AS Custom_Label
			FROM    Distributor_Group_Level l
			WHERE   l.Distributor_Group_Level_ID = <cfqueryparam value="#val(local.distGroupType)#" cfsqltype="cf_sql_numeric">
        </cfquery>

        <cfreturn local.qLabels.recordCount
                        ? local.qLabels.Custom_Label
                        : 'Distributor Group'>
    </cffunction>

	<cffunction name="deleteADLHeader" output="false" returntype="void">
		<cfargument name="headerId" type="numeric" required="true" />

		<cfquery datasource="#application.datasource#">
			UPDATE	Authorized_Distribution_List_Header
			SET		Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
					Updated_Date = GetDate(),
                    Deleted = 1
			WHERE	Authorized_Distribution_List_Header_ID = <cfqueryparam value="#arguments.headerId#" cfsqltype="cf_sql_numeric" />
		</cfquery>
	</cffunction>

</cfcomponent>
