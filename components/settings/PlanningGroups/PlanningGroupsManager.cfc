<!-----------------------------------------------------------------------------

FILE NAME:		PlanningGroupsManager.cfc
DESCRIPTION:	This component will store
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	9-Dec-2008	Added check number and
							DD_Reference fields

------------------------------------------------------------------------------>

<cfcomponent displayname="PlanningGroupsManager" hint="Handles Planning Groups Methods" output="false">

	<cfset this.stBusinessSegmentSettings = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getEnabled() />
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<!--- Init --->
	<cffunction name="init" output="false" returntype="components.settings.PlanningGroups.PlanningGroupsManager">
		<cfreturn this />
	</cffunction>

	<!--- getLDAPSettings : Settings for userName, password and mailServer --->

<cffunction name="fnGetAllPGTypes" output="false" returntype="Query">
		<cfset var qGetActivePGTypes = "" />
		<cfset useLakebaseForqGetActivePGTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_type")>
<cfif useLakebaseForqGetActivePGTypes>
	<cftry>
		<cfset qGetActivePGTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_type", {
				"deleted" = "eq.0",
				"select" = "pg_type_id,pg_type_code,pg_type_name,pg_group_type,active,deleted,updated_date,created_date,created_by,updated_by"
			}), "pg_type_id,pg_type_code,pg_type_name,pg_group_type,active,deleted,updated_date,created_date,created_by,updated_by"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActivePGTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActivePGTypes>
<cfquery name="qGetActivePGTypes" datasource="#application.datasource#">
			SELECT
        PG_Type_ID,
        PG_Type_Code,
        PG_Type_Name,
        PG_Group_Type,
        Active,
        Deleted,
        Updated_Date,
        Created_Date,
        Created_By,
        Updated_By
			FROM		PG_Type
			WHERE  Deleted = 0
    	</cfquery>
</cfif>
		<cfreturn qGetActivePGTypes />
	</cffunction>

	<cffunction name="fnGetActivePGTypes" output="false" returntype="Query">
  <cfargument name="sortBy" required="true" type="string"   />
  <cfargument name="sortOrder" required="true" type="string" />
  <cfset var qGetActivePGTypes = "" />
	<cfif arguments.sortBy EQ "PG_Group_Type">
		<cfset arguments.sortBy = "PG_Group_Type_Name" />
	<cfelse>
		<cfset arguments.sortBy = "PGT." & arguments.sortBy />
	</cfif>

		<cfquery name="qGetActivePGTypes" datasource="#application.datasource#">
      SELECT	DISTINCT
        PGT.PG_Type_ID,
        PGT.PG_Type_Code,
        PGT.PG_Type_Name,
        PGT.PG_Group_Type,
				CASE WHEN (PGT.PG_Group_Type = 1) THEN '#application.returned_customer_setting.Item_Label#'
				WHEN (PGT.PG_Group_Type = 2) THEN  '#application.returned_customer_setting.Distributor_Label_Singular#'
				WHEN (PGT.PG_Group_Type = 3) THEN '#application.returned_customer_setting.Operator_Label_Singular#'
				END
				AS PG_Group_Type_Name,
       	PGT.Active,
        PGT.Deleted,
        PGT.Updated_Date,
        PGT.Created_Date,
        PGT.Created_By,
        PGT.Updated_By,
        CASE WHEN PGT.PG_Group_Type = 1 AND PGPC.PG_Product_Category_ID IS NOT NULL THEN
		    1
      	ELSE
      	0
      	END AS PGProdRelation,
        CASE WHEN PGT.PG_Group_Type = 2 AND PGCC.PG_Customer_Category_ID IS NOT NULL THEN
      	1
      	ELSE
      	0
      	END AS PGCusRelation,
        CASE WHEN PGT.PG_Group_Type = 3 AND PGOC.PG_Operator_Category_ID IS NOT NULL THEN
      	1
      	ELSE
      	0
      	END AS PGOprRelation,
        /*
      	--PGCC.PG_Customer_Category_ID,
      	--PGPC.PG_Product_Category_ID,
        --	CASE WHEN PGCC.PG_Customer_Category_ID IS NULL AND PGPC.PG_Product_Category_ID is NULL THEN 0
        --		 WHEN PGCC.PG_Customer_Category_ID IS NOT NULL AND PGPC.PG_Product_Category_ID IS NULL THEN 1
        --		 WHEN PGCC.PG_Customer_Category_ID IS NULL AND PGPC.PG_Product_Category_ID is NOT NULL THEN 1
        --	END AS  CannotDelete,
        --
				*/
      	CASE WHEN (PGCC.PG_Customer_Category_ID IS NOT NULL OR  PGPC.PG_Product_Category_ID IS NOT NULL) THEN 1
      		 ELSE 0
      	END AS  CannotDelete
        , PGT.Is_System            <!---28269--->
        FROM	PG_Type PGT
        LEFT JOIN PG_Product_Category PGPC
        ON		PGPC.Pg_Type_ID = PGT.PG_Type_ID
        AND		PGPC.Active = 1
        AND		PGPC.Deleted = 0
        LEFT JOIN PG_Customer_Category PGCC
        ON		PGCC.Pg_Type_ID = PGT.PG_Type_ID
        AND		PGCC.Active = 1
        AND		PGCC.Deleted = 0
        LEFT JOIN PG_Operator_Category PGOC
        ON		PGOC.PG_Type_ID = PGT.PG_Type_ID
        AND		PGOC.Active = 1
        AND		PGOC.Deleted = 0
        WHERE	PGT.Active = 1
        AND		PGT.Deleted = 0
        ORDER BY #arguments.sortBy# #sortOrder#
    	</cfquery>
		<cfreturn qGetActivePGTypes />
	</cffunction>

  <cffunction name="fnGetPGTypeByID" output="false" returntype="Query">
    <cfargument name="PGTypeID" required="true" type="string" />
		<cfset var qGetPGTypeByID = "" />
		<cfquery name="qGetPGTypeByID" datasource="#application.datasource#">
			SELECT
        PGT.PG_Type_ID,
        PGT.PG_Type_Code,
        PGT.PG_Type_Name,
        PGT.PG_Group_Type,
        PGT.Active,
        PGT.Deleted,
        PGT.Updated_Date,
        PGT.Created_Date,
        PGT.Created_By,
        PGT.Updated_By,
        Us.Name_First,
        Us.Name_Last
			FROM PG_Type PGT
      LEFT JOIN
        _Users Us ON PGT.Updated_BY = Us.User_ID
			WHERE  PGT.Deleted = 0
      AND PGT.PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    	</cfquery>
		<cfreturn qGetPGTypeByID />
	</cffunction>


	<cffunction name="fnGetActivePGTypesByGrpType" output="false" returntype="Query">
    <cfargument name="GroupID" required="true" type="string"  />

		<cfquery name="qGetActivePGTypeByGrpType" datasource="#application.datasource#">
			SELECT
        PG_Type_ID,
        PG_Type_Code,
        PG_Type_Name,
        PG_Group_Type,
        Active,
        Deleted,
        Updated_Date,
        Created_Date,
        Created_By,
        Updated_By
			FROM		PG_Type
			WHERE Active = 1
      AND   PG_Group_Type = <cfqueryparam value="#arguments.GroupID#" cfsqltype="CF_SQL_INTEGER"/>
      AND   Deleted = 0
      AND   Is_System = 0     <!---28269--->
	  ORDER BY PG_Type_Name ASC
    	</cfquery>
		<cfreturn qGetActivePGTypeByGrpType />
	</cffunction>

	<cffunction name="fnGetInActivePGTypes" output="false" returntype="Query">
    <cfargument name="sortBy" required="true" type="string"   />
    <cfargument name="sortOrder" required="true" type="string" />
		<cfset var qGetInActivePGTypes = "" />

		<cfif arguments.sortBy EQ "PG_Group_Type">
			<cfset arguments.sortBy = "PG_Group_Type_Name" />
 		</cfif>
		<cfquery name="qGetInActivePGTypes" datasource="#application.datasource#">
			SELECT
        PG_Type_ID,
        PG_Type_Code,
        PG_Type_Name,
        PG_Group_Type,
				CASE WHEN (PG_Group_Type = 1) THEN '#application.returned_customer_setting.Item_Label#'
				WHEN (PG_Group_Type = 2) THEN  '#application.returned_customer_setting.Distributor_Label_Singular#'
				WHEN (PG_Group_Type = 3) THEN '#application.returned_customer_setting.Operator_Label_Singular#'
				END
				AS PG_Group_Type_Name ,
        Active,
        Deleted,
        Updated_Date,
        Created_Date,
        Created_By,
        Updated_By
        , Is_System            <!---28269--->
			FROM		PG_Type
			WHERE Active = 0
      AND   Deleted = 0
      ORDER BY #arguments.sortBy# #sortOrder#
    	</cfquery>
		<cfreturn qGetInActivePGTypes />
	</cffunction>

	<cffunction name="fnGetActiveCustomerPGs" output="false" returntype="Query">
		<cfset var qGetActiveCustomerPGs = "" />
		<cfset useLakebaseForqGetActiveCustomerPGs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category")>
<cfif useLakebaseForqGetActiveCustomerPGs>
	<cftry>
		<cfset qGetActiveCustomerPGs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_customer_category", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_customer_category_id,pg_type_id,pg_customer_category_code,pg_customer_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
			}), "pg_customer_category_id,pg_type_id,pg_customer_category_code,pg_customer_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveCustomerPGs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveCustomerPGs>
<cfquery name="qGetActiveCustomerPGs" datasource="#application.datasource#">
			SELECT
            PG_Customer_Category_ID,
            PG_Type_ID,
            PG_Customer_Category_Code,
            PG_Customer_Category_Name,
            Active,
            Deleted,
            Updated_Date,
            Created_Date,
            Created_By,
            Updated_By,
            Include_In_Other_PG
			FROM		PG_Customer_Category
			WHERE Active = 1
      AND   Deleted = 0
    	</cfquery>
</cfif>
		<cfreturn qGetActiveCustomerPGs />
	</cffunction>

 	<cffunction name="fnGetInActiveCustomerPGs" output="false" returntype="Query">
		<cfset var qGetInActiveCustomerPGs = "" />
		<cfset useLakebaseForqGetInActiveCustomerPGs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category")>
<cfif useLakebaseForqGetInActiveCustomerPGs>
	<cftry>
		<cfset qGetInActiveCustomerPGs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_customer_category", {
				"active" = "eq.0",
				"deleted" = "eq.0",
				"select" = "pg_customer_category_id,pg_type_id,pg_customer_category_code,pg_customer_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
			}), "pg_customer_category_id,pg_type_id,pg_customer_category_code,pg_customer_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetInActiveCustomerPGs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetInActiveCustomerPGs>
<cfquery name="qGetInActiveCustomerPGs" datasource="#application.datasource#">
			SELECT
            PG_Customer_Category_ID,
            PG_Type_ID,
            PG_Customer_Category_Code,
            PG_Customer_Category_Name,
            Active,
            Deleted,
            Updated_Date,
            Created_Date,
            Created_By,
            Updated_By,
            Include_In_Other_PG
			FROM		PG_Customer_Category
			WHERE Active = 0
      AND   Deleted = 0
    	</cfquery>
</cfif>
		<cfreturn qGetInActiveCustomerPGs />
	</cffunction>

    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
	<cffunction name="fnGetPGCustomerCategoryByID" output="false" returntype="Query">
    <cfargument name="PGCustomerCategoryID" required="true" type="string"  />
		<cfset var qryGetPGCustomerCategoryByID = "" />
		<cfquery name="qryGetPGCustomerCategoryByID" datasource="#application.datasource#">
			SELECT
         PGCC.PG_Customer_Category_ID,
         PGCC.PG_Type_ID,
         PGCC.PG_Customer_Category_Code,
         PGCC.PG_Customer_Category_name,
         PGCC.Active,
         PGCC.Deleted,
         PGCC.Updated_Date,
         PGCC.Created_Date,
         PGCC.Created_By,
         PGCC.Updated_By,
         PGCC.Include_In_Other_PG,
         PGT.PG_Type_Name,
         BS.Business_Unit_Desc,
         BS.BUSINESS_SEGMENT_ID,
         u1.Name_First,
         u1.Name_Last,
         PGCC.Is_Master_Group,
  PGCC.Capture_Removes,
  PGCC.Vendor_Master_ID,
  PGCC.Distributor_ID
 ,PGCC.PG_Effective_Start_Date
,PGCC.PG_Effective_End_Date
 ,PGCC.PG_Number_Sequence
FROM		PG_Customer_Category PGCC
   LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGCC.PG_Type_ID
   LEFT JOIN _Users u1 ON u1.User_ID = PGCC.Updated_By
   LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGCC.Business_Segment_ID
WHERE PGCC.PG_Customer_Category_ID = <cfqueryparam value="#arguments.PGCustomerCategoryID#" cfsqltype="cf_sql_varchar"/>
      AND   PGCC.Deleted = 0
    	</cfquery>
		<cfreturn qryGetPGCustomerCategoryByID />
	</cffunction>
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
  <cffunction name="fnAddPGType" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />

    <cfset returnValue = "" />
     <cfquery name="qPGTypeNameCheck" datasource="#application.datasource#">
      SELECT PG_Type_Name FROM PG_Type WHERE PG_Type_Name = '#RTrim(LTrim(arguments.stForm.TypeName))#' AND Deleted = 0
     </cfquery>

    <cfif qPGTypeNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>

    <!---
      PG_Type:
      1=Product
      2=Customer/Distributor
      3=Operator
    --->
   <!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() /> --->
 <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters() />
    <cfif (isDefined("arguments.stForm.rdoTypeCategory"))>
    <cfquery name="qInsPgType" datasource="#application.datasource#">
        DECLARE @PG_Type_ID int
        INSERT INTO PG_Type
          (PG_Type_Code,
           PG_Type_Name,
           PG_Group_Type,
           Active,
           Deleted,
           Created_Date,
           Created_By)
        VALUES
          (
            <cfqueryparam value="#Trim(arguments.stForm.TypeID)#" cfsqltype="cf_sql_varchar"/>,
            <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
            <cfqueryparam value="#arguments.stForm.rdoTypeCategory#" cfsqltype="CF_SQL_INTEGER"/>,
            <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER"/>,
            <cfqueryparam value="0" cfsqltype="CF_SQL_INTEGER"/>,
            GetDate(),
            <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
          )
          SET @PG_Type_ID = SCOPE_IDENTITY()
          SELECT PG_Type_ID = @PG_Type_ID
      </cfquery>



    <!--- Loop Through the
    chkBoxSearch_ :   Field in distributor Search
    & chkBoxGroup_ : Allow as Group selection
    --->
    <!---   <cfloop index="i" from=1 to=#arguments.structForm.iTemplateCount#> --->

      <cfloop query="qryTemplateList">
        <cfset allowInSearch = 0 />
        <cfset allowInGroupSearch = 0 />
        <cfif (isDefined("arguments.stForm.chkBoxSearch_#First_Parent_ID#_"))>
          <cfset allowInSearch = 1 />
        </cfif>
        <cfif (isDefined("arguments.stForm.chkBoxGroup_#First_Parent_ID#_"))>
          <cfset allowInGroupSearch = 1 />
        </cfif>
        <cfif ((allowInSearch EQ 1) OR (allowInGroupSearch EQ 1))>
        <cfquery name="qInsPGTypeTemplate" datasource="#application.datasource#">
          INSERT INTO Group_Template
           (Template_ID,
            Group_Level_ID,
            PG_Group_Type,
            Allow_in_Search,
            Allow_in_Group_Search,
            Active,
            Deleted,
            Created_Date,
            Created_By,
            PG_Flag,
            Updated_From)
          VALUES
           (#First_Parent_ID#,
            #qInsPgType.PG_Type_ID#,
            <cfqueryparam value="#arguments.stForm.rdoTypeCategory#" cfsqltype="CF_SQL_INTEGER"/>,
            #allowInSearch#,
            #allowInGroupSearch#,
            <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER"/>,
            <cfqueryparam value="0" cfsqltype="CF_SQL_INTEGER"/>,
            GetDate(),
            <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
             <cfqueryparam value="1" cfsqltype="cf_sql_bit"/>,
            <cfqueryparam value="PG Type Add Page" cfsqltype="cf_sql_varchar"/>
           )
          </cfquery>
        </cfif>
      </cfloop>
<!---
      Insert the PG type record in the Product_Group_Level if it was of PG_type = 1
      OR into the Distributor_Group_Level if PG_Type is 2  OR into the
      Operator_Group_Level if PG_Type is 3
 --->
      <cfif (arguments.stForm.rdoTypeCategory EQ 1)>
      <!--- Insert into the  Product_Group_Level and Product_Group_Attribute Table  --->
        <cfquery name="qInsProductGroupLevel" datasource="#application.datasource#">
          INSERT INTO Product_Group_Level
          (
            Product_Group_Level_ID,
            Group_Level_Desc,
            Deleted,
            Created_Date,
            Product_Group_Level_Type,
            Active,
            List_Order,
            Group_Internal_Label,
            Approval_Group_Type,
            Is_Group_Combination,
            Search_Filter_On,
            Is_PG
          )
          VALUES
          (
            #qInsPgType.PG_Type_ID#,
            <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
            0,
            GetDate(),
            #qInsPgType.PG_Type_ID#,
            1,
            #qInsPgType.PG_Type_ID#,
            <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
            0,
            0,
            1,
            1
          )
        </cfquery>
        <cfset useLakebaseForqInsProductGroupAttribute = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_attribute")>
<cfif useLakebaseForqInsProductGroupAttribute>
	<cftry>
		<cfset application.oLakebase.insertRow("product_group_attribute", {
			"product_group_level_id" = "#qInsPgType.PG_Type_ID#",
			"product_group_attribute_table" = "PG_Product_Category",
			"product_group_attribute_id_field" = "PG_Product_Category_ID",
			"product_group_attribute_name_field" = "PG_Product_Category_Name",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"product_group_attribute_search_sequence_field" = "PG_Product_Category",
			"product_group_attribute_master_id_field" = "PG_Product_Category_ID",
			"product_group_attribute_number_field" = "PG_Product_Category_Code"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsProductGroupAttribute = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsProductGroupAttribute>
<cfquery name="qInsProductGroupAttribute" datasource="#application.datasource#">
          INSERT INTO Product_Group_Attribute
          (
            Product_Group_Level_ID,
            Product_Group_Attribute_Table,
            Product_Group_Attribute_ID_Field,
            Product_Group_Attribute_Name_Field,
            Active,
            Deleted,
            Created_Date,
            Product_Group_Attribute_Search_Sequence_Field,
            Product_Group_Attribute_Master_ID_Field,
            Product_Group_Attribute_Number_Field
          )
          VALUES
          (
            #qInsPgType.PG_Type_ID#,
            'PG_Product_Category',
            'PG_Product_Category_ID',
            'PG_Product_Category_Name',
            1,
            0,
            GetDate(),
            'PG_Product_Category',
            'PG_Product_Category_ID',
            'PG_Product_Category_Code'
         )
        </cfquery>
</cfif>
      <cfelseif (arguments.stForm.rdoTypeCategory EQ 2)>
      <!--- Insert into the  Distributor_Group_Level Table  --->
        <cfquery name="qInsDistGroupLevel" datasource="#application.datasource#">
          INSERT INTO Distributor_Group_Level
          (
            Group_Level_Desc,
            Deleted,
            Created_Date,
            Distributor_Group_Level_Type_ID,
            Active,
            Distributor_Group_Attribute_Table,
            Distributor_Group_Attribute_ID_Field,
            Distributor_Group_Attribute_Master_ID_Field,
            Distributor_Group_Attribute_Name_Field,
            Group_Level_Desc_Internal,
            Search_Filter_On,
            Distributor_Group_Level_ID,
            Is_Group_Combination,
            Level_ID,
            List_Order,
            Distributor_Group_Attribute_Number_Field,
            Is_PG
          )
          VALUES
          (
            <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
            0,
            GetDate(),
            #qInsPgType.PG_Type_ID#,
            1,
            'PG_Customer_Category',
            'PG_Customer_Category_ID',
            'PG_Customer_Category_ID',
            'PG_Customer_Category_Name',
			      <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
            1,
            #qInsPgType.PG_Type_ID#,
			      0,
			      0,
            #qInsPgType.PG_Type_ID#,
            'PG_Customer_Category_Code',
            1
          )
        </cfquery>
      <cfelseif (arguments.stForm.rdoTypeCategory EQ 3)>
           <!--- Insert into the  Distributor_Group_Level Table  --->
        <cfquery name="qInsOprGroupLevel" datasource="#application.datasource#">
        INSERT INTO Operator_Group_Level
        (
          Group_Level_Desc,
          Deleted,
          Created_Date,
          Operator_Group_Level_Type_ID,
          Active,
          Search_Sequence_Name,
          Operator_Group_Attribute_Table,
          Operator_Group_Attribute_ID_Field,
          Operator_Group_Attribute_Master_ID_Field,
          Operator_Group_Attribute_Name_Field,
          Group_Level_Desc_Internal,
          Search_Filter_On,
          Operator_Group_Level_ID,
          Is_Group_Combination,
          List_Order,
          Operator_Group_Attribute_Number_Field,
          Operator_Group_Attribute_Interface_Field,
					IS_PG
        )
        VALUES
        (
          <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
          0,
          GetDate(),
          #qInsPgType.PG_Type_ID#,
          1,
          <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
          'PG_Operator_Category',  --Operator_Group_Attribute_Table
          'PG_Operator_Category_ID',--Operator_Group_Attribute_ID_Field
          'PG_Operator_Category_ID',  --Operator_Group_Attribute_Master_ID_Field
          'PG_Operator_Category_Name', --Operator_Group_Attribute_Name_Field
          <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
          1,
          #qInsPgType.PG_Type_ID#,
           0,
          NULL,
          'PG_Operator_Category_Code',
          NULL,
					1
        )
         </cfquery>
       </cfif>
</cfif>
  <cfreturn returnValue/>
  </cffunction>

<!--- This function Will save the PG Type on Edit --->
  <cffunction name="fnEditPGType" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfset returnValue = "" />
     <cfquery name="qPGTypeNameCheck" datasource="#application.datasource#">
      SELECT PG_Type_Name FROM PG_Type WHERE PG_Type_Name = '#RTrim(LTrim(arguments.stForm.TypeName))#' AND Deleted = 0
      AND PG_Type_ID  != #arguments.stForm.PGTypeID#
     </cfquery>

    <cfif qPGTypeNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>

    <!---
      PG_Type:
      1=Product
      2=Customer/Distributor
      3=Operator
    --->
 <!--- <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() /> --->
  <cfset qryTemplateList = CreateObject("component","components.programs.template.TemplateManager").getAllTemplatesForPGWithFilters() />
    <cfquery name="qUpdPgType" datasource="#application.datasource#">
      UPDATE PG_Type
      SET PG_Type_Code = <cfqueryparam value="#Trim(arguments.stForm.TypeID)#" cfsqltype="cf_sql_varchar"/>,
          PG_Type_Name = <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>,
          PG_Group_Type = <cfqueryparam value="#arguments.stForm.rdoTypeCategory#" cfsqltype="CF_SQL_INTEGER"/>,
          Updated_Date = GetDate(),
          Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
      WHERE PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
       </cfquery>

			  <cfif (arguments.stForm.rdoTypeCategory EQ 1)>
					<cfquery name="qUpdProdGroupLevel" datasource="#application.datasource#">
						UPDATE Product_Group_Level
						SET Group_Level_Desc = <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>
						WHERE Product_Group_Level_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
					</cfquery>
				<cfelseif (arguments.stForm.rdoTypeCategory EQ 2)>
					<cfquery name="qUpdDistGroupLevel" datasource="#application.datasource#">
						UPDATE Distributor_Group_Level
						SET Group_Level_Desc = <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>
						WHERE Distributor_Group_Level_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
					</cfquery>
			 	<cfelseif (arguments.stForm.rdoTypeCategory EQ 3)>
					<cfquery name="qUpdOprGroupLevel" datasource="#application.datasource#">
						UPDATE Operator_Group_Level
						SET Group_Level_Desc = <cfqueryparam value="#Trim(arguments.stForm.TypeName)#" cfsqltype="cf_sql_varchar"/>
						WHERE Operator_Group_Level_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
					</cfquery>
				</cfif>
    <!--- Loop Through the
    chkBoxSearch_ :   Field in distributor Search
    & chkBoxGroup_ : Allow as Group selection
    --->
    <!---   <cfloop index="i" from=1 to=#arguments.structForm.iTemplateCount#> --->

      <cfloop query="qryTemplateList">
       <cfquery name="qUpdPGTypeTemplate" datasource="#application.datasource#">
          UPDATE Group_Template
          SET
            Active = 0, Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
          WHERE
            Group_Level_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
            AND Template_ID = #First_Parent_ID#
       </cfquery>
        <cfset allowInSearch = 0 />
        <cfset allowInGroupSearch = 0 />
        <cfif (isDefined("arguments.stForm.chkBoxSearch_#First_Parent_ID#_"))>
          <cfset allowInSearch = 1 />
        </cfif>
        <cfif (isDefined("arguments.stForm.chkBoxGroup_#First_Parent_ID#_"))>
          <cfset allowInGroupSearch = 1 />
        </cfif>
        <cfif ((allowInSearch EQ 1) OR (allowInGroupSearch EQ 1))>

        <!--- See if the combination exists for the Template_id and PG_type ID --->
        <cfquery name="qryCheckPGTemplateCombination" datasource="#application.datasource#">
          SELECT
            Group_Template_ID
          FROM
            Group_Template
          WHERE
            Group_Level_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
            AND Template_ID = #First_Parent_ID#
         </cfquery>

        <cfif qryCheckPGTemplateCombination.RecordCount GTE 1>
<!---           <cfif (allowInSearch EQ 0 AND allowInGroupSearch EQ 0)>

          <cfelse> --->
             <cfquery name="qUpdPGTypeTemplate" datasource="#application.datasource#">
              UPDATE Group_Template
              SET Allow_in_Search = #allowInSearch#,
                  Allow_in_Group_Search = #allowInGroupSearch#,
                  Active = 1,
                  Deleted = 0,
                  Updated_Date = GetDate(),
                  Updated_By =  '#arguments.UserID#',
									PG_Group_Type = <cfqueryparam value="#arguments.stForm.rdoTypeCategory#" cfsqltype="CF_SQL_INTEGER"/>
              WHERE
                Group_Level_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
                AND Template_ID = #First_Parent_ID#
            </cfquery>
         <!---  </cfif> --->
        <cfelse>
          <cfquery name="qInsPGTypeTemplate" datasource="#application.datasource#">
            INSERT INTO Group_Template
             (Template_ID,
              Group_Level_ID,
              Allow_in_Search,
              Allow_in_Group_Search,
							PG_Group_Type,
              Active,
              Deleted,
              Created_Date,
              Created_By,
              PG_Flag,
              Updated_From)
            VALUES
             (#First_Parent_ID#,
              #arguments.stForm.PGTypeID#,
              #allowInSearch#,
              #allowInGroupSearch#,
							<cfqueryparam value="#arguments.stForm.rdoTypeCategory#" cfsqltype="CF_SQL_INTEGER"/>,
              <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER"/>,
              <cfqueryparam value="0" cfsqltype="CF_SQL_INTEGER"/>,
              GetDate(),
              <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
               <cfqueryparam value="1" cfsqltype="cf_sql_bit"/>,
              <cfqueryparam value="PG Type Add Page" cfsqltype="cf_sql_varchar"/>
             )
            </cfquery>
          </cfif>
        </cfif>
      </cfloop>

  <cfreturn returnValue/>
  </cffunction>



  <!--- This function Deactivates an Exclusion record --->
  <cffunction   name="deactivateType" output="false" returntype="void">
    <cfargument name="PGTypeID" type="string" required="true" />
  	<cfquery name="qDeActivate" datasource="#application.datasource#">
      UPDATE	PG_Type
      SET 		Active = 0,
      	  		Updated_Date = GetDate(),
          		Updated_By = <cfqueryparam value="#request.accessStructure.User_ID#" cfsqltype="cf_sql_varchar"/>
      WHERE PG_Type_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
		<!--- Deactivate all the relevant records in the other places --->
		<!--- <cfquery name="qryPGGroupType" datasource="#application.datasource#">
			SELECT PG_Group_Type
			FROM PG_Type
			WHERE PG_Type_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		</cfquery>
		<cfif isDefined("qryPGGroupType") AND qryPGGroupType.RecordCount GTE 1>
			<cfquery name="qDelGroupTemplate" datasource="#application.datasource#">
	      UPDATE Group_Template
	      SET ACTIVE = 0
	      			WHERE Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
	    </cfquery>
			<cfif qryPGGroupType.PG_Group_Type EQ 1>
				<cfquery name="qDelProduct" datasource="#application.datasource#">
	      	UPDATE Product_Group_Level
		      SET ACTIVE = 0
		      			WHERE Product_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
				<cfquery name="qDelProductAttribute" datasource="#application.datasource#">
		      UPDATE Product_Group_Attribute
		      SET ACTIVE = 0
		      		WHERE Product_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelDistributor" datasource="#application.datasource#">
					UPDATE Distributor_Group_Level
		      SET ACTIVE = 0
		      			WHERE Distributor_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelOperator" datasource="#application.datasource#">
					UPDATE Operator_Group_Level
		      SET ACTIVE = 0
		      		WHERE Operator_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			</cfif>
		</cfif> --->

  </cffunction>


  <cffunction   name="activateType" output="false" returntype="void">
    <cfargument name="PGTypeID" type="string" required="true" />
  	<cfquery name="qActivate" datasource="#application.datasource#">
      UPDATE PG_Type
      SET	 Active = 1,
      	  	 Updated_Date = GetDate(),
          	 Updated_By = <cfqueryparam value="#request.accessStructure.User_ID#" cfsqltype="cf_sql_varchar"/>
      WHERE PG_Type_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
	<!--- Activate all the relevant records in the other places --->
		<cfquery name="qryPGGroupType" datasource="#application.datasource#">
			SELECT PG_Group_Type
			FROM PG_Type
			WHERE PG_Type_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		</cfquery>
		<cfif isDefined("qryPGGroupType") AND qryPGGroupType.RecordCount GTE 1>
			<cfquery name="qDelGroupTemplate" datasource="#application.datasource#">
	      UPDATE Group_Template
	      SET ACTIVE = 1
	      			WHERE Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
	    </cfquery>
			<cfif qryPGGroupType.PG_Group_Type EQ 1>
				<cfquery name="qDelProduct" datasource="#application.datasource#">
	      	UPDATE Product_Group_Level
		      SET ACTIVE = 1
		     		 WHERE Product_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
				<cfquery name="qDelProductAttribute" datasource="#application.datasource#">
		      UPDATE Product_Group_Attribute
		      SET ACTIVE = 1
		      		WHERE Product_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelDistributor" datasource="#application.datasource#">
					UPDATE Distributor_Group_Level
		      SET ACTIVE = 1
		      		WHERE Distributor_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelOperator" datasource="#application.datasource#">
					UPDATE Operator_Group_Level
		      SET ACTIVE = 1
		      		WHERE Operator_Group_Level_ID IN (<cfqueryparam value="#arguments.PGTypeID#" list="yes" cfsqltype="cf_sql_idstamp" >)
		    </cfquery>
			</cfif>
		</cfif>
  </cffunction>


  <!--- This function Deactivates an Exclusion record --->
  <cffunction   name="delType" output="false" returntype="void">
    <cfargument name="PGTypeID" type="string" required="true" />

	<cfquery name="qDelType" datasource="#application.datasource#">
      UPDATE PG_Type
      SET 	 ACTIVE = 0, Deleted = 1,
    	  	 Updated_Date = GetDate(),
          	 Updated_By = <cfqueryparam value="#request.accessStructure.User_ID#" cfsqltype="cf_sql_varchar"/>
      WHERE PG_Type_ID in (#arguments.PGTypeID#)
    </cfquery>
		<!--- Deactivate all the relevant records in the other places --->
		<cfquery name="qryPGGroupType" datasource="#application.datasource#">
			SELECT PG_Group_Type
			FROM PG_Type
			WHERE PG_Type_ID in (#arguments.PGTypeID#)
		</cfquery>
		<cfif isDefined("qryPGGroupType") AND qryPGGroupType.RecordCount GTE 1>
			<cfquery name="qDelGroupTemplate" datasource="#application.datasource#">
	      UPDATE Group_Template
	      SET ACTIVE = 0, Deleted = 1,
      	  	 	Updated_Date = GetDate(),
          	 	Updated_By = <cfqueryparam value="#request.accessStructure.User_ID#" cfsqltype="cf_sql_varchar"/>
	      WHERE Group_Level_ID in (#arguments.PGTypeID#)
	    </cfquery>
			<cfif qryPGGroupType.PG_Group_Type EQ 1>
				<cfquery name="qDelProduct" datasource="#application.datasource#">
	      	UPDATE Product_Group_Level
		      SET ACTIVE = 0
					/* , Deleted = 1 */
		      WHERE Product_Group_Level_ID in (#arguments.PGTypeID#)
		    </cfquery>
				<cfquery name="qDelProductAttribute" datasource="#application.datasource#">
		      UPDATE Product_Group_Attribute
		      SET ACTIVE = 0
					/* , Deleted = 1 */
		      WHERE Product_Group_Level_ID in (#arguments.PGTypeID#)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelDistributor" datasource="#application.datasource#">
					UPDATE Distributor_Group_Level
		      		SET ACTIVE = 0,
			 		 	Updated_Date = GetDate()
					/* , Deleted = 1 */
		      WHERE Distributor_Group_Level_ID in (#arguments.PGTypeID#)
		    </cfquery>
			<cfelseif qryPGGroupType.PG_Group_Type EQ 2>
				<cfquery name="qDelOperator" datasource="#application.datasource#">
					UPDATE Operator_Group_Level
		      		SET ACTIVE = 0,
			  			Updated_Date = GetDate()
					/* , Deleted = 1 */
		      WHERE Operator_Group_Level_ID in (#arguments.PGTypeID#)
		    </cfquery>
			</cfif>
		</cfif>


	</cffunction>

 <!----------------------------------------------------------------------------
 *********************** Function to add the Product PG ***********************
 ------------------------------------------------------------------------------>
  <cffunction name="fnAddProductPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />

    <cfset returnValue = "" />
     <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Product_Category_Name FROM PG_Product_Category WHERE PG_Product_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#' AND Deleted = 0
     </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>
    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

		<cfparam name="arguments.stForm.bCaptureRemoves" default="0">

<!---D81389 Tyson - System generated number for Planning Groups --->
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <cfset PG_Number_Sequence = this.PGSequenceNumber()/>
<cfelse>
  <cfset PG_Number_Sequence = 0>
</cfif>

 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID Column--->
    <cfquery name="qInsPGProduct" datasource="#application.datasource#">
      DECLARE @PG_Product_Category_ID VARCHAR (50)
      SET @PG_Product_Category_ID = NEWID()
      INSERT INTO PG_Product_Category
      (
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code,
        PG_Product_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Created_By,
        Include_In_Other_PG,
        Business_Segment_ID,
        Is_Master_Group             <!---31191--->
        ,Capture_Removes
		, PG_Effective_Start_Date
		,PG_Effective_End_Date
    ,PG_Number_Sequence
      )
      VALUES
      (

        @PG_Product_Category_ID,
        <cfqueryparam value="#iPGTypeID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        1,
        0,
        GetDate(),
        <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
		<cfqueryparam value="#arguments.stForm.business_segment#" cfsqltype="cf_sql_integer"/>,
        <cfif isdefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>     <!---31191--->
       <!---  <cfqueryparam value="#arguments.stForm.selTypeName#" cfsqltype="cf_sql_varchar"/>,  --->
       <!---  <cfqueryparam value="#arguments.stForm.selPlanningGroup#" cfsqltype="cf_sql_varchar"/>,    --->
       ,<cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>
	  ,<cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
	  ,<cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
    ,<cfqueryparam value="#PG_Number_Sequence#" cfsqltype="cf_sql_bigint"/>
      )

      -- SET @PG_Product_Category_ID = @@IDENTITY
       SELECT PG_Product_Category_ID = @PG_Product_Category_ID
    </cfquery>
   <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    <cfloop query="arguments.stSession.qryGrpProdPack">
      <cfif arguments.stSession.qryGrpProdPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpProdPack.IsPG EQ "" OR arguments.stSession.qryGrpProdPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>

    <!--- DO NOT INSERT IF THE PRODUCT_ID IS IN EITHER THE INCLUDE OR EXCLUDE LIST DELMARKED FIELD --->
    <!--- <cfif (FindNoCase(arguments.stSession.qryGrpProdPack.Group_Product_ID,arguments.stForm.DelMarkedInInclude) EQ 0 AND FindNoCase(arguments.stSession.qryGrpProdPack.Group_Product_ID,arguments.stForm.DelMarkedInExclude) EQ 0)  >   --->
  	<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0>
		<cfset recDelInExclude = 0>

		<cfif arguments.stSession.qryGrpProdPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpProdPack.Group_Product_ID>
						<!--- <cfset 	recDelInInclude = 1 />    --->
						<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpProdPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpProdPack.Group_Product_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>

      <cfset useLakebaseForqInsPGProductCategoryDefinition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_product_category_definition")>
<cfif useLakebaseForqInsPGProductCategoryDefinition>
	<cftry>
		<cfset application.oLakebase.insertRow("pg_product_category_definition", {
			"pg_product_category_id" = "#qInsPGProduct.PG_Product_Category_ID#",
			"pg_type_id" = "#iPGTypeID#",
			"product_group_level_id" = "#arguments.stSession.qryGrpProdPack.GroupLevel_ID#",
			"product_group_id" = "#arguments.stSession.qryGrpProdPack.Group_Product_ID#",
			"inclusion_exclusion" = "#arguments.stSession.qryGrpProdPack.Inc_Exc#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"include_in_other_pg" = "#bIncInOthers#",
			"is_pg" = "#IsAPG#",
			"pg_effective_start_date" = "#arguments.stForm.PG_Effective_Start_Date#",
			"pg_effective_end_date" = "#arguments.stForm.PG_Effective_End_Date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGProductCategoryDefinition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGProductCategoryDefinition>
<cfquery name="qInsPGProductCategoryDefinition" datasource="#application.datasource#">
        INSERT INTO PG_Product_Category_Definition
        (
          PG_Product_Category_ID,
          PG_Type_ID,
          Product_Group_Level_ID,
          Product_Group_ID,
          Inclusion_Exclusion,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          Include_In_Other_PG,
          Is_PG,
		  PG_Effective_Start_Date,
		  PG_Effective_End_Date
        )
        VALUES
        (
          '#qInsPGProduct.PG_Product_Category_ID#',
          #iPGTypeID#,
          #arguments.stSession.qryGrpProdPack.GroupLevel_ID#,
          '#arguments.stSession.qryGrpProdPack.Group_Product_ID#',
          #arguments.stSession.qryGrpProdPack.Inc_Exc#,
          1,
          0,
          GetDate(),
          '#arguments.UserID#',
          #bIncInOthers#,
          #IsAPG#,
		  '#arguments.stForm.PG_Effective_Start_Date#',
		  '#arguments.stForm.PG_Effective_End_Date#'
        )
      </cfquery>
</cfif>
    </cfif>
   </cfloop>

<!---
[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
--->
<!---
  <cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #(arguments.stForm[colName])#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>

    <cfset totalLen = Len(colName) />
	 	<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 	<cfset TemplateFiltersID =  Right(colName,  returnLen) />

 	 	<cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
		  <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
	      -- DECLARE @Template_Filters_ID INT
	      INSERT INTO Template_Filters
	      (
	        Template_Id,
	        Parent_Template_Id,
	        Description,
	        Status,
	        Deleted,
	        Created_User_Id,
	        Created_Date
	      )
	      VALUES
	      (
	        #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
	        #arguments.stForm[colName]#,
	        '#Left(qryTemplateDetails.Created_Type,50)#',
	        'ACTIVE',
	         0,
	        '#arguments.UserID#',
	        GetDate()
	      )
	      SELECT SCOPE_IDENTITY() AS Template_Filters_ID
	    </cfquery>
		 <cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
	</cfif>

      <cfset useLakebaseForqInsPGProductGroupTemplateSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_template_selection")>
<cfif useLakebaseForqInsPGProductGroupTemplateSelection>
	<cftry>
		<cfset application.oLakebase.insertRow("product_group_template_selection", {
			"template_id" = "#arguments.stForm[colName]#",
			"product_group_level_id" = "#arguments.stForm.PGTypeID#",
			"product_group_id" = "#qInsPGProduct.PG_Product_Category_ID#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"pg_flag" = "1",
			"updated_from" = "PG Adding Page",
			"template_filters_id" = "#TemplateFiltersID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGProductGroupTemplateSelection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGProductGroupTemplateSelection>
<cfquery name="qInsPGProductGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Product_Group_Template_Selection
        (
          Template_ID,
          Product_Group_Level_ID,
          Product_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#qInsPGProduct.PG_Product_Category_ID#',
          1,
          0,
          GetDate(),
          <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
          '#arguments.UserID#',
          1,
          'PG Adding Page',
          #TemplateFiltersID#
        )
      </cfquery>
</cfif>
    </cfif>
</cfloop>
--->

<cfquery name="qryPopulateTempTableForProduct" datasource="#application.datasource#">
IF OBJECT_ID ('tempdb..##tmp_PG_View_Product_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Product_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Product_Category_Definition.PG_Product_Category_ID,
				PG_Product_Category_Definition.Product_Group_Level_ID,
				PG_Product_Category_Definition.Product_Group_ID,
				PG_Product_Category_Definition.Inclusion_Exclusion,
				PG_Product_Category_Definition.IS_PG,
				PG_Product_Category.Include_In_Other_PG,
				PG_Product_Category.PG_Product_Category_Code,
				PG_Product_Category.PG_Product_Category_Name,
				<cfif this.stBusinessSegmentSettings.ProductEnabled>
					PG_Product_Category.Business_Segment_ID
				<cfelse>
					NULL
				</cfif> as Business_Segment_ID
		INTO	##tmp_PG_View_Product_Members
		FROM	PG_Type
		INNER JOIN	PG_Product_Category_Definition
		ON		PG_Product_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Product_Category
		ON		PG_Product_Category.PG_Product_Category_ID = PG_Product_Category_Definition.PG_Product_Category_ID
		AND		PG_Product_Category.Deleted = 0
		WHERE	PG_Product_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type = 1 --Product
		AND		(PG_Product_Category_Definition.PG_Product_Category_ID IN ('#qInsPGProduct.PG_Product_Category_ID#')
		OR		PG_Product_Category_Definition.PG_Product_Category_ID IN (SELECT DISTINCT Product_Group_ID FROM PG_Product_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Product_Category_ID IN ('#qInsPGProduct.PG_Product_Category_ID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Product_Category_Definition.PG_Product_Category_ID,
				PG_Product_Category.Include_In_Other_PG,
				PG_Product_Category_Definition.Product_Group_Level_ID,
				PG_Product_Category_Definition.Product_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Product_Members_C] ON [dbo].[##tmp_PG_View_Product_Members]([Product_Group_ID],[Product_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]
  </cfquery>
   <cfstoredproc procedure="USP_POPULATE_PRODUCT_PG_MEMBERS" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
      <cfprocresult name="qryUSPPopulateProductPGMembers">
    </cfstoredproc>
     <cfreturn returnValue />
  </cffunction>

<!----------------------------------------------------------------------------
********************** Function to Edit the Product PG ***********************
----------------------------------------------------------------------------->

  <cffunction name="fnEditProductPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />

    <cfset returnValue = "" />

	<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
	<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
     <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Product_Category_Name
    	  FROM PG_Product_Category
    	 WHERE PG_Product_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#'
    	       AND PG_Product_Category_ID != '#arguments.stForm.PGProductCategoryID#'
    	       AND Deleted = 0
             AND Active = 1
     </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>

    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

<cfparam name="arguments.stForm.bCaptureRemoves" default="0">


    <cfquery name="qUpdPGProduct" datasource="#application.datasource#">
      UPDATE PG_Product_Category
      SET
        PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>,
        PG_Product_Category_Code =  <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        PG_Product_Category_Name = <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        Updated_Date = GetDate(),
        Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        Include_In_Other_PG =  <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
        Is_Master_Group = <cfif isdefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>     <!---31191--->
        ,Capture_Removes = <cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>
        ,PG_Effective_Start_Date	 = <cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
		,PG_Effective_End_Date	 = <cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
      WHERE PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#'
     </cfquery>

	<!--- D32768: Update PG_Type_ID in other PG tables, updating definition table will fix all other tables --->
	<cfquery name="qUpdPGProductMember" datasource="#application.datasource#">
      UPDATE PG_Product_Category_Definition
      SET PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>
      WHERE  PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#'
     </cfquery>

	<!---
	 	START: D47046 Planning Group 'type' updates not reflected in other planning group rules:/Anand Rao/17-Dec-2014
	--->
		 <cfif (bIncInOthers EQ 1)>
		 	<cfquery name="qUpdPGProductDef" datasource="#application.datasource#">
				UPDATE PG_Product_Category_Definition SET Product_Group_Level_ID = '#arguments.stForm.PGTypeID#' WHERE PG_Product_Category_Definition_ID IN
 				(SELECT PG_Product_Category_Definition_ID FROM PG_Product_Category_Definition WHERE Deleted = 0 AND Product_Group_ID = '#arguments.stForm.PGProductCategoryID#' AND Is_PG = 1)
		 	</cfquery>
		</cfif>
	 <!--- END:  D46895 --->
 <!--- Update the existing records in the PG_Product_Category_Definition table --->
    <!--- Get all the current records in the table for this PG_Product_Category_ID --->

    <cfset useLakebaseForqrySelectProdCatDef = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_product_category_definition")>
<cfif useLakebaseForqrySelectProdCatDef>
	<cftry>
		<cfset qrySelectProdCatDef = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_product_category_definition", {
				"pg_product_category_id" = "eq.#arguments.stForm.PGProductCategoryID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_product_category_definition_id,pg_product_category_id,pg_type_id,product_group_level_id,product_group_id,inclusion_exclusion,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg,is_pg"
			}), "pg_product_category_definition_id,pg_product_category_id,pg_type_id,product_group_level_id,product_group_id,inclusion_exclusion,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg,is_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrySelectProdCatDef = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrySelectProdCatDef>
<cfquery name="qrySelectProdCatDef" datasource="#application.datasource#">
      SELECT
        PG_Product_Category_Definition_ID,
        PG_Product_Category_ID,
        PG_Type_ID,
        Product_Group_Level_ID,
        Product_Group_ID,
        Inclusion_Exclusion,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG,
        Is_PG
      FROM
        PG_Product_Category_Definition
      WHERE PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#'
      AND Active = 1
      AND Deleted = 0
    </cfquery>
</cfif>

    <cfloop query="qrySelectProdCatDef">
      <cfset groupFound = 0 />

	  <cfif (appSettings.get_Setting('PG_Eff_Date_Product') eq '1')>
		 <cfif (isDefined("arguments.stForm.PG_Effective_Start_Date_#Replace(qrySelectProdCatDef.PG_Product_Category_Definition_ID,'-','_','ALL')#") AND isDefined("arguments.stForm.PG_Effective_End_Date_#Replace(qrySelectProdCatDef.PG_Product_Category_Definition_ID,'-','_','ALL')#") )>
			<cfset PGEffStartDate = evaluate("arguments.stForm.PG_Effective_Start_Date_" & Replace(qrySelectProdCatDef.PG_Product_Category_Definition_ID,'-','_','ALL')) />
			<cfset PGEffEndDate = evaluate("arguments.stForm.PG_Effective_End_Date_" & Replace(qrySelectProdCatDef.PG_Product_Category_Definition_ID,'-','_','ALL')) />
		  <cfelse>
			<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
			<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
		  </cfif>
	  <cfelse>
		<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
		<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
	  </cfif>

	  <cfif PGEffStartDate EQ "1900-01-01 00:00:00.000" OR PGEffStartDate EQ "">
	 	 <cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
	  </cfif>
	   <cfif PGEffEndDate EQ "1900-01-01 00:00:00.000" OR PGEffEndDate EQ "">
	 	 <cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
	  </cfif>

      <cfloop collection="#arguments.stForm#" item="i">
        <!--- <cfif FindNoCase("rdoIncExc_",i,1)> --->
         <cfif (FindNoCase("rdoIncExc_",i) NEQ 0)>
          <cfset groupFound = 1 />
          <cfset totLength = Len(i) />
          <cfset varID = Replace(Right(i,(totLength-10)),"_","-","ALL") /> <!--- 10 is the length of "rdoIncExc_" --->
					<cfset checkRec = 0>
					<cfloop index = "prodID" list = "#arguments.stForm.DelMarkedInExisting#"  delimiters = ",">
						<cfif prodID EQ qrySelectProdCatDef.Product_Group_ID>
							<cfset 	checkRec = 1 />
						</cfif>
					</cfloop>


          <cfif (qrySelectProdCatDef.Product_Group_ID EQ varID AND checkRec EQ 0)<!--- FindNoCase(qrySelectProdCatDef.Product_Group_ID,arguments.stForm.DelMarkedInExisting) EQ 0) --->>

            <cfquery name="updProdCatDef1" datasource="#application.datasource#">
              UPDATE PG_Product_Category_Definition
              SET
                Inclusion_Exclusion = #arguments.stForm[i]#,
                Updated_Date = GetDate(),
                Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
				<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
					,PG_Effective_Start_Date = '#PGEffStartDate#'
					,PG_Effective_End_Date = '#PGEffEndDate#'
				</cfif>
              WHERE
                PG_Product_Category_Definition_ID =  #qrySelectProdCatDef.PG_Product_Category_Definition_ID#
            </cfquery>
          <cfelseif (qrySelectProdCatDef.Product_Group_ID EQ varID) AND checkRec EQ 1 <!--- FindNoCase(qrySelectProdCatDef.Product_Group_ID,arguments.stForm.DelMarkedInExisting) GT 0 --->>
          <!--- If the record was checked to a different option and then --->
            <cfquery name="updProdCatDef2" datasource="#application.datasource#">
              UPDATE PG_Product_Category_Definition
              SET
                Active = 0,
                Deleted = 1,
                Updated_Date = GetDate(),
                Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
				<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
					,PG_Effective_Start_Date = '#PGEffStartDate#'
					,PG_Effective_End_Date = '#PGEffEndDate#'
				</cfif>
              WHERE
                PG_Product_Category_Definition_ID =  #qrySelectProdCatDef.PG_Product_Category_Definition_ID#
           </cfquery>

          </cfif>
        </cfif>
      </cfloop>

      <cfif groupFound EQ 0>
        <cfquery name="updProdCatDef3" datasource="#application.datasource#">
          UPDATE PG_Product_Category_Definition
          SET
            Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
			<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
				,PG_Effective_Start_Date = '#PGEffStartDate#'
				,PG_Effective_End_Date = '#PGEffEndDate#'
			</cfif>
          WHERE
            PG_Product_Category_Definition_ID =  #qrySelectProdCatDef.PG_Product_Category_Definition_ID#
        </cfquery>
      </cfif>
    </cfloop>

    <cfloop query="arguments.stSession.qryGrpProdPack">
      <cfif arguments.stSession.qryGrpProdPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpProdPack.IsPG EQ "" OR arguments.stSession.qryGrpProdPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>

    <!--- Insert the newly added category Definitions/ members into the PG_Product_Category_Definition table --->
  	<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0>
		<cfset recDelInExclude = 0>

		<cfif arguments.stSession.qryGrpProdPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpProdPack.Group_Product_ID>
						<!--- <cfset 	recDelInInclude = 1 />    --->
						<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpProdPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpProdPack.Group_Product_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>
		<!--- Dev Note(66983)- start --->
		<cfset bPGProductExist = fnIsPlanningGroupProductExist(arguments.stForm.PGProductCategoryID,arguments.stSession.qryGrpProdPack.Group_Product_ID)>
		<cfif bPGProductExist eq 1>
			<!--- Delete the existing record before adding it again below (In case it already exists) --->
			<cfset fnDeletePlanningGroupProduct(arguments.stForm.PGProductCategoryID,arguments.stSession.qryGrpProdPack.Group_Product_ID,arguments.UserID)>
		</cfif>
		<!--- Dev Note(66983)- end --->

	<cfquery name="qInsPGProductCategoryDefinition" datasource="#application.datasource#">
      INSERT INTO PG_Product_Category_Definition
      (
        PG_Product_Category_ID,
        PG_Type_ID,
        Product_Group_Level_ID,
        Product_Group_ID,
        Inclusion_Exclusion,
        Active,
        Deleted,
        Created_Date,
        Created_By,
        Include_In_Other_PG,
        Is_PG
		<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
			,PG_Effective_Start_Date
			,PG_Effective_End_Date
		</cfif>
      )
      VALUES
      (
        '#arguments.stForm.PGProductCategoryID#',
        #iPGTypeID#,
        #arguments.stSession.qryGrpProdPack.GroupLevel_ID#,
        '#arguments.stSession.qryGrpProdPack.Group_Product_ID#',
        #arguments.stSession.qryGrpProdPack.Inc_Exc#,
        1,
        0,
        GetDate(),
        '#arguments.UserID#',
        #bIncInOthers#,
        #IsAPG#
		<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1'>
			,'#PGEffStartDate#'
			,'#PGEffEndDate#'
		</cfif>
      )
    </cfquery>
		</cfif>
   </cfloop>

  <!--- ChkBoxTemplate Insert for new and Update for removed ones --->
  <cfset qryProdGrpTemSel = this.fnProdGrpTemSel('#arguments.stForm.PGProductCategoryID#') />

  <!---
    Loop through the above query and see if the template_ID is available in the chkboxTemplate_ value
   If not then delete that record.
  --->
<!---
[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
--->
<!---
    <cfloop query = "qryProdGrpTemSel">
      <cfset templateFound = 0 />
      <cfloop index="colName" list="#arguments.stForm.fieldnames#">
        <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
        <cfset totLength = Len(colName) />
				<cfset strFirstPart 	 = Left(colName,(FindNoCase("_FID_",colName)-1)) />
				<cfset strFirstPartLen = Len(strFirstPart) />
				<cfset varID = Right(strFirstPart,(strFirstPartLen-15)) />
	 			<cfset returnLen = totLength - (FindNoCase("_FID_",colName) + 4) />
	 			<cfset TemplateFiltersID =  Right(colName,  returnLen) />
        <!---  <cfset varID = Right(i,(totLength-15)) /> --->
          <cfif qryProdGrpTemSel.Template_ID EQ varID AND qryProdGrpTemSel.Template_Filters_ID EQ TemplateFiltersID><!--- arguments.stForm[colName] --->
            <cfset templateFound = 1 />
            <!--- The ID is already there and no change hence remove it from the FORM as no change to this Template --->
               <cfset arguments.stForm.fieldnames = Replace(arguments.stForm.fieldnames,colName,"") />
             <cfset temp2 = StructDelete(arguments.stForm, colName) />
             <cfbreak />
          </cfif>
        </cfif>
      </cfloop>
      <cfif templateFound EQ 0>
        <cfset useLakebaseForupdProdCatDef = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_template_selection")>
<cfif useLakebaseForupdProdCatDef>
	<cftry>
		<cfset application.oLakebase.updateRows("product_group_template_selection",
			{
				"product_group_id" = "eq.#qryProdGrpTemSel.Product_Group_ID#",
				"template_id" = "eq.#qryProdGrpTemSel.Template_ID#",
				"template_filters_id" = "eq.#qryProdGrpTemSel.Template_Filters_ID#"
			},
			{
				"active" = "0",
				"deleted" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#arguments.UserID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdProdCatDef = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdProdCatDef>
<cfquery name="updProdCatDef" datasource="#application.datasource#">
          UPDATE Product_Group_Template_Selection
          SET
            Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
          WHERE
            Product_Group_ID =  '#qryProdGrpTemSel.Product_Group_ID#'	AND
						Template_ID = #qryProdGrpTemSel.Template_ID# AND
						Template_Filters_ID = #qryProdGrpTemSel.Template_Filters_ID#
        </cfquery>
</cfif>
       <!---  <cfquery name="updProdCatDef" datasource="#application.datasource#">
          UPDATE Template_Filters
          SET
            Status = 'INACTIVE',
            Deleted = 1
          WHERE Template_Filters_ID =  #qryProdGrpTemSel.Template_Filters_Id#
        </cfquery> --->

      </cfif>
    </cfloop>


<cfset TemplateFiltersID = "" />
  <cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)> <!--- AND isDefined(arguments.stForm[colName]) --->
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #arguments.stForm[colName]#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>
			<cfset totalLen = Len(colName) />
	 		<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 		<cfset TemplateFiltersID =  Right(colName,  returnLen) />
			 <cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
      <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
      -- DECLARE @Template_Filters_ID INT
      INSERT INTO Template_Filters
      (
        Template_Id,
        Parent_Template_Id,
        Description,
        Status,
        Deleted,
        Created_User_Id,
        Created_Date
      )
      VALUES
      (
        #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
        #arguments.stForm[colName]#,
        '#Left(qryTemplateDetails.Created_Type,50)#',
        'ACTIVE',
         0,
        '#arguments.UserID#',
        GetDate()
      )
      SELECT SCOPE_IDENTITY() AS Template_Filters_ID
    </cfquery>
 		<cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
		</cfif>

      <cfquery name="qInsPGProductGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Product_Group_Template_Selection
        (
          Template_ID,
          Product_Group_Level_ID,
          Product_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#arguments.stForm.PGProductCategoryID#',
          1,
          0,
          GetDate(),
          <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
          '#arguments.UserID#',
          1,
          'PG Editing Page',
          #TemplateFiltersID#
        )
      </cfquery>
    </cfif>
</cfloop>
 --->

<cfquery name="qryPopulateTempTableForProduct" datasource="#application.datasource#">
IF OBJECT_ID ('tempdb..##tmp_PG_View_Product_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Product_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Product_Category_Definition.PG_Product_Category_ID,
				PG_Product_Category_Definition.Product_Group_Level_ID,
				PG_Product_Category_Definition.Product_Group_ID,
				PG_Product_Category_Definition.Inclusion_Exclusion,
				PG_Product_Category_Definition.IS_PG,
				PG_Product_Category.Include_In_Other_PG,
				PG_Product_Category.PG_Product_Category_Code,
				PG_Product_Category.PG_Product_Category_Name,
				<cfif this.stBusinessSegmentSettings.ProductEnabled>
					PG_Product_Category.Business_Segment_ID
				<cfelse>
					NULL
				</cfif> as Business_Segment_ID
		INTO	##tmp_PG_View_Product_Members
		FROM	PG_Type
		INNER JOIN	PG_Product_Category_Definition
		ON		PG_Product_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Product_Category
		ON		PG_Product_Category.PG_Product_Category_ID = PG_Product_Category_Definition.PG_Product_Category_ID
		AND		PG_Product_Category.Deleted = 0
		WHERE	PG_Product_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =1 --Product
		AND		(PG_Product_Category_Definition.PG_Product_Category_ID IN ('#arguments.stForm.PGProductCategoryID#')
		OR		PG_Product_Category_Definition.PG_Product_Category_ID IN (SELECT DISTINCT Product_Group_ID FROM PG_Product_Category_Definition WHERE  IS_PG = 1 AND Deleted = 0 AND PG_Product_Category_ID IN ('#arguments.stForm.PGProductCategoryID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Product_Category_Definition.PG_Product_Category_ID,
				PG_Product_Category.Include_In_Other_PG,
				PG_Product_Category_Definition.Product_Group_Level_ID,
				PG_Product_Category_Definition.Product_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Product_Members_C] ON [dbo].[##tmp_PG_View_Product_Members]([Product_Group_ID],[Product_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  </cfquery>
  <cfif arguments.stForm.DELMARKEDINEXISTING NEQ "">
	  <cfquery name="updProdMembers" datasource="#application.datasource#">
          /*
		  -- D111192 - Products missing from Planning Groups - GFS Bars/Brownies - CF Long term fix / Anand Rao / 18-Oct-2021
		  UPDATE PG_Product_Members
          SET
            Active = 0,
            Deleted = 1,
            Updated_From = 2,
            Updated_Bit = 1
			*/
			DELETE FROM
				PG_Product_Members
        	WHERE
				PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#' AND
				BSA_Foodservice_Items_Master_ID IN (<cfqueryparam value="#arguments.stForm.DELMARKEDINEXISTING#" cfsqltype="CF_SQL_VARCHAR" list="yes"/>) AND
				Deleted = 0
        </cfquery>
	</cfif>

	<cfif (isDefined('qryPopulateTempTableForProduct') AND qryPopulateTempTableForProduct.Recordcount GTE 1)>
	  <cfquery name="updProdMembers" datasource="#application.datasource#">
	   /*
		  -- D111192 - Products missing from Planning Groups - GFS Bars/Brownies - CF Long term fix / Anand Rao / 18-Oct-2021
          UPDATE PG_Product_Members
          SET
            Active = 0,
            Deleted = 1,
            Updated_From = 2,
            Updated_Bit = 1
		*/
			DELETE FROM
				PG_Product_Members
          	WHERE
				PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#' AND
				Deleted = 0
        </cfquery>
	</cfif>

    <cfstoredproc procedure="USP_POPULATE_PRODUCT_PG_MEMBERS" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
      <cfprocresult name="qryUSPPopulateProductPGMembers">
    </cfstoredproc>

<!--- D34374:Planning Group end date maintenance in group members table START ---->
<cfif len(arguments.stForm.DELMARKEDINEXISTING)>
        <cfquery name="UpdateGroupMembers" datasource="#application.datasource#">
          UPDATE Group_Members
          SET End_Date = CAST(GETDATE() as DATE), Updated_Bit = 1
          WHERE   Product_Group_ID =  '#arguments.stForm.PGProductCategoryID#'
		  AND End_Date > CAST(GETDATE() as DATE)
		  AND BSA_FoodService_Items_Master_ID IN (<cfqueryparam value="#arguments.stForm.DELMARKEDINEXISTING#" cfsqltype="CF_SQL_VARCHAR" list="yes"/>)
		  <!--- End date Group_Members only when product is no longer a member of the PG.
		  If user is deleting an excluded record, that product may now become member of the PG, in that case we should not end date it.
		  --->
		  AND NOT EXISTS (
                SELECT 1
                FROM PG_Product_Members m
                WHERE m.PG_Product_Category_ID = '#arguments.stForm.PGProductCategoryID#'
                AND m.BSA_Foodservice_Items_Master_ID = Group_Members.BSA_Foodservice_Items_Master_ID
                AND m.Deleted = 0
        )
        </cfquery>
</cfif>
<!--- D34374:Planning Group end date maintenance in group members table END ---->
     <cfreturn returnValue />
  </cffunction>

<!--- Function to find existing "product planning group" records --->
  <cffunction name="fnIsPlanningGroupProductExist" output="false" returntype="boolean" >
	<cfargument name="PG_Product_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Product_ID"	required="true" type="string" />

	<cfset var bPGExist = 0 />

	<cfset useLakebaseForqIsPlanningGroupProductExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_product_category_definition")>
<cfif useLakebaseForqIsPlanningGroupProductExist>
	<cftry>
		<cfset qIsPlanningGroupProductExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_product_category_definition", {
				"pg_product_category_id" = "eq.#arguments.PG_Product_Category_ID#",
				"product_group_id" = "eq.#arguments.Group_Product_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsPlanningGroupProductExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsPlanningGroupProductExist>
<cfquery name="qIsPlanningGroupProductExist" datasource="#application.datasource#">
		SELECT 1
		FROM PG_Product_Category_Definition
		WHERE PG_Product_Category_ID = '#arguments.PG_Product_Category_ID#'
		AND Product_group_ID = '#arguments.Group_Product_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

	<cfif qIsPlanningGroupProductExist.recordcount>
		<cfset bPGExist = 1 />
	</cfif>

	<cfreturn bPGExist />
</cffunction>

<!--- Function to delete "product planning group" records --->
<cffunction name="fnDeletePlanningGroupProduct" output="false" returntype="void" >
	<cfargument name="PG_Product_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Product_ID"	required="true" type="string" />
	<cfargument name="UserID"	required="true" type="string" />

	<cfset useLakebaseForqDeletePlanningGroupProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_product_category_definition")>
<cfif useLakebaseForqDeletePlanningGroupProduct>
	<cftry>
		<cfset application.oLakebase.updateRows("pg_product_category_definition",
			{
				"pg_product_category_id" = "eq.#arguments.PG_Product_Category_ID#",
				"product_group_id" = "eq.#arguments.Group_Product_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1"
			},
			{
				"deleted" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#arguments.UserID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeletePlanningGroupProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeletePlanningGroupProduct>
<cfquery name="qDeletePlanningGroupProduct" datasource="#application.datasource#">
		UPDATE PG_Product_Category_Definition
		SET deleted = 1,
			Updated_Date = GetDate(),
			Updated_By =  '#arguments.UserID#'
		WHERE PG_Product_Category_ID = '#arguments.PG_Product_Category_ID#'
		AND Product_group_ID = '#arguments.Group_Product_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

</cffunction>

<!---------------------------------------------------------------------------------------
  *************************************************************************************
    Functions for Product Tab
  ************************************************************************************
--------------------------------------------------------------------------------------->
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
  	<cffunction name="fnGetActiveProductCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetActiveProductCategory = "" />
		  <cfquery name="qGetActiveProductCategory" datasource="#application.datasource#">
  			SELECT
            PGPC.PG_Product_Category_ID,
            PGPC.PG_Type_ID,
            PGPC.PG_Product_Category_Code,
            PGPC.PG_Product_Category_Name,
            PGPC.Active,
            PGPC.Deleted,
            PGPC.Created_Date,
            PGPC.Updated_Date,
            PGPC.Created_By,
            PGPC.Updated_BY,
            PGPC.Include_In_Other_PG,
            BS.Business_Unit_Desc,
            BS.BUSINESS_SEGMENT_ID,
            PGT.PG_Type_Name
            ,PGPC.Is_System  <!---28269--->
  			FROM		PG_Product_Category PGPC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGPC.PG_Type_ID
        LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGPC.Business_Segment_ID
  			WHERE PGPC.Active = 1
        AND   PGPC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelseif arguments.sortBy EQ "Business_Unit_Desc">BS.<cfelse>PGPC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetActiveProductCategory />
	  </cffunction>
	      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
  	<cffunction name="fnGetInActiveProductCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetInActiveProductCategory = "" />
		  <cfquery name="qGetInActiveProductCategory" datasource="#application.datasource#">
  			SELECT
            PGPC.PG_Product_Category_ID,
            PGPC.PG_Type_ID,
            PGPC.PG_Product_Category_Code,
            PGPC.PG_Product_Category_Name,
            PGPC.Active,
            PGPC.Deleted,
            PGPC.Created_Date,
            PGPC.Updated_Date,
            PGPC.Created_By,
            PGPC.Updated_BY,
            PGPC.Include_In_Other_PG,
            BS.Business_Unit_Desc,
            BS.BUSINESS_SEGMENT_ID,
            PGT.PG_Type_Name
            ,PGPC.Is_System  <!---28269--->
        FROM	PG_Product_Category PGPC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGPC.PG_Type_ID
        LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGPC.Business_Segment_ID
  			WHERE PGPC.Active = 0
        AND   PGPC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelseif arguments.sortBy EQ "Business_Unit_Desc">BS.<cfelse>PGPC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetInActiveProductCategory />
	  </cffunction>
   	      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
  	<cffunction name="fnGetPGProductCategoryByID" output="false" returntype="Query">
      <cfargument name="PGProductCategoryID" type="string" required="true" />
		  <cfset var qGetActiveProductCategory = "" />
		  <cfquery name="qGetActiveProductCategory" datasource="#application.datasource#">
  			SELECT
            PGPC.PG_Product_Category_ID,
            PGPC.PG_Type_ID,
            PGPC.PG_Product_Category_Code,
            PGPC.PG_Product_Category_Name,
            PGPC.Active,
            PGPC.Deleted,
            PGPC.Created_Date,
            PGPC.Updated_Date,
            PGPC.Created_By,
            PGPC.Updated_By,
            PGPC.Include_In_Other_PG,
            BS.Business_Unit_Desc,
            BS.BUSINESS_SEGMENT_ID,
            PGT.PG_Type_Name,
            u1.Name_First,
            u1.Name_Last,
            PGPC.Is_Master_Group     <!---31191--->
            ,PGPC.Capture_Removes
			,PGPC.PG_Effective_Start_Date
			,PGPC.PG_Effective_End_Date
      ,PGPC.PG_Number_Sequence
  			 FROM		PG_Product_Category PGPC
      		 LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGPC.PG_Type_ID
   			 LEFT JOIN _Users u1 ON u1.User_ID = PGPC.Updated_By
             LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGPC.Business_Segment_ID
  			WHERE  PGPC.Deleted = 0
        AND PGPC.PG_Product_Category_ID = <cfqueryparam value="#arguments.PGProductCategoryID#" cfsqltype="cf_sql_varchar"/>
    	</cfquery>
		  <cfreturn qGetActiveProductCategory />
	  </cffunction>
      <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->

    <!-------------------------------------------------------------------------
      This function will return the active Product Planning Groups to be
      displayed in the drop down while selecting the Product planning Groups for
      the complex PGs.
    --------------------------------------------------------------------------->

    <cffunction name="fnGetCoreProductPG" output="false" returntype="Query">
		  <cfset var qGetCoreProductPG = "" />
      <cfset useLakebaseForqGetCoreProductPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_product_category")>
<cfif useLakebaseForqGetCoreProductPG>
	<cftry>
		<cfset qGetCoreProductPG = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_product_category", {
				"include_in_other_pg" = "eq.1",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_product_category_id,pg_type_id,pg_product_category_code,pg_product_category_name,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg"
			}), "pg_product_category_id,pg_type_id,pg_product_category_code,pg_product_category_name,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCoreProductPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCoreProductPG>
<cfquery name="qGetCoreProductPG" datasource="#application.datasource#">
        SELECT
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code,
        PG_Product_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
        FROM PG_Product_Category
        WHERE Include_In_Other_PG = 1 AND ACTIVE = 1 AND DELETED = 0
      </cfquery>
</cfif>
    <cfreturn qGetCoreProductPG />
	  </cffunction>



  <cffunction  name="activateProductPG" output="false" returntype="void">
    <cfargument name="PGProductCatID" type="string" required="true" />
  	<cfquery name="qryActivateProductPG" datasource="#application.datasource#">
      UPDATE PG_Product_Category
      SET Active = 1
      WHERE PG_Product_Category_ID IN (<cfqueryparam value="#arguments.PGProductCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>

  <cffunction   name="deActivateProductPG" output="false" returntype="void">
    <cfargument name="PGProductCatID" type="string" required="true" />
  	<cfquery name="qryDeActivateProductPG" datasource="#application.datasource#">
      UPDATE PG_Product_Category
      SET Active = 0
      WHERE PG_Product_Category_ID IN (<cfqueryparam value="#arguments.PGProductCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>


  <cffunction  name="delProductPG" output="false" returntype="void">
    <cfargument name="PGProductCatID" type="string" required="true" />
  	<cfquery name="qryDeleteProductPG" datasource="#application.datasource#">
      UPDATE PG_Product_Category
      SET Deleted = 1
      WHERE PG_Product_Category_ID in ('#arguments.PGProductCatID#')
    </cfquery>
  </cffunction>


<!---------------------------------------------------------------------------------------
  *************************************************************************************
    Functions for Customer Tab
  ************************************************************************************
--------------------------------------------------------------------------------------->

    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
  	<cffunction name="fnGetActiveCustomerCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetActiveCustomerCategory = "" />
		  <cfquery name="qGetActiveCustomerCategory" datasource="#application.datasource#">
  			SELECT
          PGCC.PG_Customer_Category_ID,
          PGCC.PG_Type_ID,
          PGCC.PG_Customer_Category_Code,
          PGCC.PG_Customer_Category_Name,
          PGCC.Active,
          PGCC.Deleted,
          PGCC.Created_Date,
          PGCC.Updated_Date,
          PGCC.Created_By,
          PGCC.Updated_BY,
          PGCC.Include_In_Other_PG,
          BS.Business_Unit_Desc,
          BS.BUSINESS_SEGMENT_ID,
          PGT.PG_Type_Name
        	, PGCC.Is_System            <!---28269--->
          , PGCC.Is_Master_Group      <!---31191--->
  			FROM		PG_Customer_Category PGCC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGCC.PG_Type_ID
        LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGCC.Business_Segment_ID
  			WHERE PGCC.Active = 1
        AND   PGCC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelseif arguments.sortBy EQ "Business_Unit_Desc">BS.<cfelse>PGCC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetActiveCustomerCategory />
	  </cffunction>
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment Description and left join Business segment table--->
  	<cffunction name="fnGetInActiveCustomerCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetInActiveCustomerCategory = "" />
		  <cfquery name="qGetInActiveCustomerCategory" datasource="#application.datasource#">
  			SELECT
          PGCC.PG_Customer_Category_ID,
          PGCC.PG_Type_ID,
          PGCC.PG_Customer_Category_Code,
          PGCC.PG_Customer_Category_Name,
          PGCC.Active,
          PGCC.Deleted,
          PGCC.Created_Date,
          PGCC.Updated_Date,
          PGCC.Created_By,
          PGCC.Updated_BY,
          PGCC.Include_In_Other_PG,
          BS.Business_Unit_Desc,
          BS.BUSINESS_SEGMENT_ID,
  			  PGT.PG_Type_Name
        	, PGCC.Is_System            <!---28269--->
  			FROM		PG_Customer_Category PGCC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGCC.PG_Type_ID
         LEFT JOIN Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGCC.Business_Segment_ID
  			WHERE PGCC.Active = 0
        AND   PGCC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelseif arguments.sortBy EQ "Business_Unit_Desc">BS.<cfelse>PGCC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetInActiveCustomerCategory />
	  </cffunction>
    <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    <cffunction name="fnGetCoreCustomerPG" output="false" returntype="Query">
		  <cfset var qGetCoreCustomerPG = "" />
		  <cfquery name="qGetCoreCustomerPG" datasource="#application.datasource#">
  			SELECT
          PG_Customer_Category_ID,
          PG_Type_ID,
          PG_Customer_Category_Code,
          PG_Customer_Category_Name,
          Active,
          Deleted,
          Created_Date,
          Updated_Date,
          Created_By,
          Updated_BY,
          Include_In_Other_PG
  			FROM		PG_Customer_Category
  			WHERE Include_In_Other_PG = 1
        AND Active = 1
        AND Deleted = 0
    	</cfquery>
		  <cfreturn qGetCoreCustomerPG />
	  </cffunction>


 <cffunction  name="activateCustomerPG" output="false" returntype="void">
    <cfargument name="PGCustomerCatID" type="string" required="true" />
  	<cfquery name="qryActivateCustomerPG" datasource="#application.datasource#">
      UPDATE PG_Customer_Category
      SET Active = 1
	  WHERE PG_Customer_Category_ID IN (<cfqueryparam value="#arguments.PGCustomerCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>

  <cffunction   name="deActivateCustomerPG" output="false" returntype="void">
    <cfargument name="PGCustomerCatID" type="string" required="true" />
  	<cfquery name="qryDeActivateCustomerPG" datasource="#application.datasource#">
      UPDATE PG_Customer_Category
      SET Active = 0
	  WHERE PG_Customer_Category_ID IN (<cfqueryparam value="#arguments.PGCustomerCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>


  <cffunction  name="delCustomerPG" output="false" returntype="void">
    <cfargument name="PGCustomerCatID" type="string" required="true" />
  	<cfquery name="qryDeleteCustomerPG" datasource="#application.datasource#">
      UPDATE PG_Customer_Category
      SET Deleted = 1
      WHERE PG_Customer_Category_ID in ('#arguments.PGCustomerCatID#')
    </cfquery>
  </cffunction>

  <cffunction  name="fnGetProductPGByTypeID" output="false" returntype="Query">
    <cfargument name="PGTypeID" type="string" required="true" />
  	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
      SELECT
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code,
        PG_Product_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Product_Category
    WHERE
      Active = 1 AND
      Deleted = 0 AND
    PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
    <cfreturn qryProductPGByTypeID />
  </cffunction>

  <cffunction  name="fnGetCustomerPGByTypeID" output="false" returntype="Query">
    <cfargument name="PGTypeID" type="string" required="true" />
  	<cfquery name="qryCustomerPGByTypeID" datasource="#application.datasource#">
      SELECT
        PG_Customer_Category_ID,
        PG_Type_ID,
        PG_Customer_Category_Code,
        PG_Customer_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Customer_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
    <cfreturn qryCustomerPGByTypeID />
  </cffunction>


 <!----------------------------------------------------------------------------
 *********************** Function to add the Customer PG ***********************
 ------------------------------------------------------------------------------>
  <cffunction name="fnAddCustomerPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />
    <cfset returnValue = "" />

     <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Customer_Category_Name FROM PG_Customer_Category WHERE PG_Customer_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#' AND Deleted = 0
     </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>
    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

<!---D81389 Tyson - System generated number for Planning Groups --->
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <cfset PG_Number_Sequence = this.PGSequenceNumber()/>
<cfelse>
  <cfset PG_Number_Sequence =0>
</cfif>

		<cfparam name="arguments.stForm.bCaptureRemoves" default="0">
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID column--->
    <cfquery name="qInsPGCustomer" datasource="#application.datasource#">
      DECLARE @PG_Customer_Category_ID VARCHAR (50)
      SET @PG_Customer_Category_ID = NEWID()
      INSERT INTO PG_Customer_Category
      (
        PG_Customer_Category_ID,
        PG_Type_ID,
        PG_Customer_Category_Code,
        PG_Customer_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Created_By,
        Include_In_Other_PG,
        Business_Segment_ID,
        Is_Master_Group,             <!---31191--->
        Capture_Removes
	<cfif appsettings.getPayeeFromPlanningGroups() eq 1>
	,Vendor_Master_ID
	,Distributor_ID
	</cfif>
		, PG_Effective_Start_Date
		,PG_Effective_End_Date
   ,PG_Number_Sequence
      )
      VALUES
      (

        @PG_Customer_Category_ID,
        <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        1,
        0,
        GetDate(),
        <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
		    <cfqueryparam value="#arguments.stForm.business_segment#" cfsqltype="cf_sql_integer"/>,
        <cfif isDefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>
       <!---  <cfqueryparam value="#arguments.stForm.selTypeName#" cfsqltype="cf_sql_varchar"/>,  --->
       <!---  <cfqueryparam value="#arguments.stForm.selPlanningGroup#" cfsqltype="cf_sql_varchar"/>,    --->
       ,<cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>
       <cfif appsettings.getPayeeFromPlanningGroups() eq 1>
       ,<cfqueryparam value="#arguments.stForm.Vendor_Master_ID#" cfsqltype="cf_sql_varchar"  null="#len(arguments.stForm.Vendor_Master_ID) eq 0#"/>
       ,<cfqueryparam value="#arguments.stForm.distributor_id#" cfsqltype="cf_sql_varchar"  null="#len(arguments.stForm.distributor_id) eq 0#"/>
       </cfif>
		,<cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
		,<cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
    ,<cfqueryparam value="#PG_Number_Sequence#" cfsqltype="cf_sql_bigint"/>
        )
      -- SET @PG_Customer_Category_ID = @@IDENTITY
       SELECT PG_Customer_Category_ID = @PG_Customer_Category_ID
    </cfquery>
 <!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
    <cfloop query="arguments.stSession.qryGrpDistPack">
      <cfif arguments.stSession.qryGrpDistPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpDistPack.IsPG EQ "" OR  arguments.stSession.qryGrpDistPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>

 <!--- DO NOT INSERT IF THE PRODUCT_ID IS IN EITHER THE INCLUDE OR EXCLUDE LIST DELMARKED FIELD --->
   <!--- <cfif (FindNoCase(arguments.stSession.qryGrpDistPack.Group_Dist_ID,arguments.stForm.DelMarkedInInclude) EQ 0 AND FindNoCase(arguments.stSession.qryGrpDistPack.Group_Dist_ID,arguments.stForm.DelMarkedInExclude) EQ 0)  > --->

		<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0>
		<cfset recDelInExclude = 0>

		<cfif arguments.stSession.qryGrpDistPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpDistPack.Group_Dist_ID>
						<!--- <cfset 	recDelInInclude = 1 />    --->
						<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpDistPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpDistPack.Group_Dist_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>

	    <cfset useLakebaseForqInsPGCustomerCategoryDefinition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category_definition")>
<cfif useLakebaseForqInsPGCustomerCategoryDefinition>
	<cftry>
		<cfset application.oLakebase.insertRow("pg_customer_category_definition", {
			"pg_customer_category_id" = "#qInsPGCustomer.PG_Customer_Category_ID#",
			"pg_type_id" = "#iPGTypeID#",
			"distributor_group_level_id" = "#arguments.stSession.qryGrpDistPack.GroupLevel_ID#",
			"distributor_group_id" = "#arguments.stSession.qryGrpDistPack.Group_Dist_ID#",
			"inclusion_exclusion" = "#arguments.stSession.qryGrpDistPack.Inc_Exc#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"include_in_other_pg" = "#bIncInOthers#",
			"is_pg" = "#IsAPG#",
			"pg_effective_start_date" = "#arguments.stForm.PG_Effective_Start_Date#",
			"pg_effective_end_date" = "#arguments.stForm.PG_Effective_End_Date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGCustomerCategoryDefinition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGCustomerCategoryDefinition>
<cfquery name="qInsPGCustomerCategoryDefinition" datasource="#application.datasource#">
	      INSERT INTO PG_Customer_Category_Definition
	      (
	        PG_Customer_Category_ID,
	        PG_Type_ID,
	        Distributor_Group_Level_ID,
	        Distributor_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        Created_Date,
	        Created_By,
	        Include_In_Other_PG,
	        Is_PG,
			PG_Effective_Start_Date,
		  	PG_Effective_End_Date
	      )
	      VALUES
	      (
	        '#qInsPGCustomer.PG_Customer_Category_ID#',
	        #iPGTypeID#, <!--- arguments.stForm.PGTypeID --->
	        #arguments.stSession.qryGrpDistPack.GroupLevel_ID#,
	        '#arguments.stSession.qryGrpDistPack.Group_Dist_ID#',
	        #arguments.stSession.qryGrpDistPack.Inc_Exc#,
	        1,
	        0,
	        GetDate(),
	        <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
	        '#arguments.UserID#',
	        #bIncInOthers#,
	        #IsAPG#,
		  	'#arguments.stForm.PG_Effective_Start_Date#',
		  	'#arguments.stForm.PG_Effective_End_Date#'
	      )
	    </cfquery>
</cfif>
    </cfif>
   </cfloop>

<!---
[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
--->
<!---
  <cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #arguments.stForm[colName]#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>
			<cfset totalLen = Len(colName) />
	 		<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 		<cfset TemplateFiltersID =  Right(colName,  returnLen) />

 	 	<cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
      <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
        -- DECLARE @Template_Filters_ID INT
        INSERT INTO Template_Filters
        (
          Template_Id,
          Parent_Template_Id,
          Description,
          Status,
          Deleted,
          Created_User_Id,
          Created_Date
        )
        VALUES
        (
          #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
          #arguments.stForm[colName]#,
          '#Left(qryTemplateDetails.Created_Type,50)#',
          'ACTIVE',
          0,
          '#arguments.UserID#',
          GetDate()
        )
        SELECT SCOPE_IDENTITY() AS Template_Filters_ID
      </cfquery>
		 <cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
	</cfif>
      <cfset useLakebaseForqInsPGCustomerGroupTemplateSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_group_template_selection")>
<cfif useLakebaseForqInsPGCustomerGroupTemplateSelection>
	<cftry>
		<cfset application.oLakebase.insertRow("customer_group_template_selection", {
			"template_id" = "#arguments.stForm[colName]#",
			"distributor_group_level_id" = "#arguments.stForm.PGTypeID#",
			"distributor_group_id" = "#qInsPGCustomer.PG_Customer_Category_ID#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"pg_flag" = "1",
			"updated_from" = "PG Adding Page",
			"template_filters_id" = "#TemplateFiltersID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGCustomerGroupTemplateSelection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGCustomerGroupTemplateSelection>
<cfquery name="qInsPGCustomerGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Customer_Group_Template_Selection
        (
          Template_ID,
          Distributor_Group_Level_ID,
          Distributor_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#qInsPGCustomer.PG_Customer_Category_ID#',
          1,
          0,
          GetDate(),
          <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
          '#arguments.UserID#',
          1,
          'PG Adding Page',
          #TemplateFiltersID#
        )
      </cfquery>
</cfif>
    </cfif>
</cfloop>
--->

<cfquery name="qryPopulateTempTableForCustomer" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_PG_View_Customer_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Customer_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Customer_Category_Definition.PG_Customer_Category_ID,
				PG_Customer_Category_Definition.Distributor_Group_Level_ID,
				PG_Customer_Category_Definition.Distributor_Group_ID,
				PG_Customer_Category_Definition.Inclusion_Exclusion,
				PG_Customer_Category_Definition.IS_PG,
				PG_Customer_Category.Include_In_Other_PG,
				PG_Customer_Category.PG_Customer_Category_Code,
				PG_Customer_Category.PG_Customer_Category_Name,
				<cfif this.stBusinessSegmentSettings.DistributorEnabled>
					PG_Customer_Category.Business_Segment_ID
				<cfelse>
					NULL
				</cfif> as Business_Segment_ID
		INTO	##tmp_PG_View_Customer_Members
		FROM	PG_Type
		INNER JOIN	PG_Customer_Category_Definition
		ON		PG_Customer_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Customer_Category
		ON		PG_Customer_Category.PG_Customer_Category_ID = PG_Customer_Category_Definition.PG_Customer_Category_ID
		AND		PG_Customer_Category.Deleted = 0
		WHERE	PG_Customer_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =2 --Customer
		AND		(PG_Customer_Category_Definition.PG_Customer_Category_ID IN ('#qInsPGCustomer.PG_Customer_Category_ID#')
		OR		PG_Customer_Category_Definition.PG_Customer_Category_ID IN (SELECT DISTINCT DISTRIBUTOR_Group_ID FROM PG_Customer_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Customer_Category_ID IN ('#qInsPGCustomer.PG_Customer_Category_ID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Customer_Category_Definition.PG_Customer_Category_ID,
				PG_Customer_Category.Include_In_Other_PG,
				PG_Customer_Category_Definition.Distributor_Group_Level_ID,
				PG_Customer_Category_Definition.Distributor_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Customer_Members_C] ON [dbo].[##tmp_PG_View_Customer_Members]([Distributor_Group_ID],[Distributor_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  	</cfquery>

	<cfquery datasource="#application.datasource#">
		EXEC USP_POPULATE_CUSTOMER_PG_MEMBERS 2
	</cfquery>

    <cfreturn returnValue>
  </cffunction>


<!------------------------------------------------------------------------------
 *********************** Function to Edit the Customer PG ***********************
 ------------------------------------------------------------------------------>
  <cffunction name="fnEditCustomerPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />
    <cfset returnValue = "" />

	<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
	<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
    <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Customer_Category_Name
	  FROM PG_Customer_Category
	  WHERE PG_Customer_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#'
	  AND PG_Customer_Category_ID != '#arguments.stForm.PGCustomerCategoryID#'
	  AND Deleted = 0
    </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
      <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>
    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

		<cfparam name="arguments.stForm.bCaptureRemoves" default="0">
    <cfquery name="qUpdPGCustomer" datasource="#application.datasource#">
      UPDATE PG_Customer_Category
      SET
        PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>,
        PG_Customer_Category_Code =  <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        PG_Customer_Category_Name = <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        Updated_Date = GetDate(),
        Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        Include_In_Other_PG =  <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
        Is_Master_Group = <cfif isDefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>       <!---31191--->
	,Capture_Removes = <cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>
	<cfif appsettings.getPayeeFromPlanningGroups() eq 1>
	,Vendor_Master_ID = <cfqueryparam value="#arguments.stForm.Vendor_Master_ID#" cfsqltype="cf_sql_varchar" null="#len(arguments.stForm.Vendor_Master_ID) eq 0#" />
	,Distributor_ID = <cfqueryparam value="#arguments.stForm.Distributor_ID#" cfsqltype="cf_sql_varchar"  null="#len(arguments.stForm.Distributor_ID) eq 0#" />
	</cfif>
		,PG_Effective_Start_Date = <cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
		,PG_Effective_End_Date	 = <cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
      WHERE PG_Customer_Category_ID = '#arguments.stForm.PGCustomerCategoryID#'
     </cfquery>

	<!--- D32768: Update PG_Type_ID in other PG tables, updating definition table will fix all other tables --->
	<cfquery name="qUpdPGCustomerMember" datasource="#application.datasource#">
      UPDATE PG_Customer_Category_Definition
      SET
        PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>
      WHERE
        PG_Customer_Category_ID = '#arguments.stForm.PGCustomerCategoryID#'
     </cfquery>

	<!---
	 	START: D47046 Planning Group 'type' updates not reflected in other planning group rules:/Anand Rao/17-Dec-2014
	--->
		 <cfif (bIncInOthers EQ 1)>
		 	<cfquery name="qUpdPGCustomerDef" datasource="#application.datasource#">
				UPDATE PG_Customer_Category_Definition SET Distributor_Group_Level_ID = '#arguments.stForm.PGTypeID#' WHERE PG_Customer_Category_Definition_ID IN
 				(SELECT PG_Customer_Category_Definition_ID FROM PG_Customer_Category_Definition WHERE Deleted = 0 AND Distributor_Group_ID = '#arguments.stForm.PGCustomerCategoryID#' AND Is_PG = 1)
		 	</cfquery>
		</cfif>
	 <!--- END:  D46895 --->
 <!--- Update the existing records in the PG_Customer_Category_Definition table --->
    <!--- Get all the current records in the table for this PG_Customer_Category_ID --->

    <cfset useLakebaseForqrySelectCusCatDef = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category_definition")>
<cfif useLakebaseForqrySelectCusCatDef>
	<cftry>
		<cfset qrySelectCusCatDef = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_customer_category_definition", {
				"pg_customer_category_id" = "eq.#arguments.stForm.PGCustomerCategoryID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_customer_category_definition_id,pg_customer_category_id,pg_type_id,distributor_group_level_id,distributor_group_id,inclusion_exclusion,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg,is_pg"
			}), "pg_customer_category_definition_id,pg_customer_category_id,pg_type_id,distributor_group_level_id,distributor_group_id,inclusion_exclusion,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg,is_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrySelectCusCatDef = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrySelectCusCatDef>
<cfquery name="qrySelectCusCatDef" datasource="#application.datasource#">
      SELECT
        PG_Customer_Category_Definition_ID,
        PG_Customer_Category_ID,
        PG_Type_ID,
        Distributor_Group_Level_ID,
        Distributor_Group_ID,
        Inclusion_Exclusion,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG,
        Is_PG
      FROM
        PG_Customer_Category_Definition
      WHERE PG_Customer_Category_ID = '#arguments.stForm.PGCustomerCategoryID#'
      AND Active = 1
      AND Deleted = 0
    </cfquery>
</cfif>

<cfscript>
    queryExecute( " DROP TABLE IF EXISTS ##tmp_customer_pg
                    CREATE TABLE ##tmp_customer_pg (
                            [ID]      [INT] NOT NULL,
                            [Active]  [BIT] NULL,
                            [Deleted] [BIT] NULL,
                            [Inclusion_Exclusion] [BIT] NULL
                        ) ON [PRIMARY]
                    ", {}, { datasource: application.datasource } );

    local.PG_Eff_Date_Distributor = appSettings.get_Setting( 'PG_Eff_Date_Distributor' );

    if ( local.PG_Eff_Date_Distributor eq '1' ) {
        PGEffStartDate = evaluate("arguments.stForm.PG_Effective_Start_Date_" & Replace(qrySelectCusCatDef.PG_Customer_Category_Definition_ID,'-','_','ALL'));
        PGEffEndDate = evaluate("arguments.stForm.PG_Effective_End_Date_" & Replace(qrySelectCusCatDef.PG_Customer_Category_Definition_ID,'-','_','ALL'));
    }
    else {
        PGEffStartDate = arguments.stForm.PG_Effective_Start_Date;
        PGEffEndDate   = arguments.stForm.PG_Effective_End_Date;
    }

    if ( PGEffStartDate EQ "1900-01-01 00:00:00.000" OR PGEffStartDate EQ "" ) {
        PGEffStartDate = arguments.stForm.PG_Effective_Start_Date;
    }

    if ( PGEffEndDate EQ "1900-01-01 00:00:00.000" OR PGEffEndDate EQ "" ) {
        PGEffEndDate = arguments.stForm.PG_Effective_End_Date;
    }

    // <!--- store multiple values for a single INSERT statment into an array for a speedy batch processing --->
    bundled_sql = [];
    // an arbitrary value represents a NULL value in CF
    local.empty = 6212022;
</cfscript>

<cfoutput>
<cfloop query="qrySelectCusCatDef">
    <cfscript>
        local.active  = local.empty;
        local.deleted = local.empty;
        local.inclusion_exclusion = local.empty;

        // <!--- establish the form element name for include/exclude --->
        element_name = "rdoIncExc_" & qrySelectCusCatDef.Distributor_Group_ID.replace( "-", "_", "all" );
        if ( arguments.stForm.DelMarkedInExisting.findNoCase( qrySelectCusCatDef.Distributor_Group_ID ) ) {
            local.active = 0;
            local.deleted = 1;
        }

        // <!--- found include/exclude flag in form element --->
        else if ( structKeyExists( arguments.stForm, element_name ) ) {
            local.active  = 1;
            local.deleted = 0;
            local.Inclusion_Exclusion = arguments.stForm[ element_name ];
			if(FindOneOf(local.Inclusion_Exclusion,",") GTE 1)
			{
				local.Inclusion_Exclusion = ListLast(local.Inclusion_Exclusion);
			}
        }
        else {
            local.active  = 0;
            local.deleted = 1;
        }
    </cfscript>

    <cfsavecontent variable="new_sql">( #qrySelectCusCatDef.PG_Customer_Category_Definition_ID#
                                        ,<cfif local.active eq local.empty> NULL <cfelse> #local.active# </cfif>
                                        ,<cfif local.deleted eq local.empty> NULL <cfelse> #local.deleted# </cfif>
                                        ,<cfif local.inclusion_exclusion eq local.empty> NULL <cfelse> #local.inclusion_exclusion# </cfif> )</cfsavecontent>
    <!--- save new value to load into the db later --->
    <cfset bundled_sql.append( new_sql )>

    <cfif ( qrySelectCusCatDef.currentRow mod 900 eq 0 ) or ( qrySelectCusCatDef.currentRow gte qrySelectCusCatDef.recordCount )>
        <!--- executing multiple SQL statements in one database trip --->
        <cfquery datasource="#application.datasource#">
            SET NOCOUNT ON
            INSERT INTO ##tmp_customer_pg ( ID, Active, Deleted, Inclusion_Exclusion )
                VALUES #bundled_sql.toList()#

            <!--- carry out update to the actual table --->
            <cfif ( qrySelectCusCatDef.currentRow gte qrySelectCusCatDef.recordCount )>
                UPDATE pg
                    SET   Active = ISNULL( tmp.Active, pg.Active )
                        ,Deleted = ISNULL( tmp.Deleted, pg.Deleted )
                        ,inclusion_exclusion = ISNULL( tmp.Inclusion_Exclusion, pg.Inclusion_Exclusion )
                        ,Updated_Date = GetDate()
                        ,Updated_By = '#arguments.UserID#'
                        <cfif local.PG_Eff_Date_Distributor eq '1'>
                            ,PG_Effective_Start_Date = '#PGEffStartDate#'
                            ,PG_Effective_End_Date = '#PGEffEndDate#'
                        </cfif>
                  FROM PG_Customer_Category_Definition pg
                    JOIN ##tmp_customer_pg tmp ON tmp.ID = pg.PG_Customer_Category_Definition_ID
            </cfif>

            SET NOCOUNT OFF
        </cfquery>

        <!--- reset our batch processing array for the next chunk --->
        <cfset bundled_sql = []>
    </cfif>
</cfloop>
</cfoutput>





    <cfloop query="arguments.stSession.qryGrpDistPack">
      <cfif arguments.stSession.qryGrpDistPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpDistPack.IsPG EQ "" OR  arguments.stSession.qryGrpDistPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>


    <!--- Insert the newly added category Definitions/ members into the PG_Customer_Category_Definition table --->

	<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0>
		<cfset recDelInExclude = 0>

		<cfif arguments.stSession.qryGrpDistPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpDistPack.Group_Dist_ID>
						<!--- <cfset 	recDelInInclude = 1 />    --->
						<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpDistPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpDistPack.Group_Dist_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>

		<!--- Dev Note(66983)- start --->
		<cfset bPGCustomerExist = fnIsPlanningGroupCustomerExist(arguments.stForm.PGCustomerCategoryID,arguments.stSession.qryGrpDistPack.Group_Dist_ID)>
		<cfif bPGCustomerExist eq 1>
			<!--- Delete the existing record before adding it again below (In case it already exists) --->
			<cfset fnDeletePlanningGroupCustomer(arguments.stForm.PGCustomerCategoryID,arguments.stSession.qryGrpDistPack.Group_Dist_ID,arguments.UserID)>
		</cfif>
		<!--- Dev Note(66983)- end --->

	    <cfquery name="qInsPGCustomerCategoryDefinition" datasource="#application.datasource#">
	      INSERT INTO PG_Customer_Category_Definition
	      (
	        PG_Customer_Category_ID,
	        PG_Type_ID,
	        Distributor_Group_Level_ID,
	        Distributor_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        Created_Date,
	        Created_By,
	        Include_In_Other_PG,
	        Is_PG
			<cfif appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1'>
			,PG_Effective_Start_Date
			,PG_Effective_End_Date
			</cfif>
	      )
	      VALUES
	      (
	        '#arguments.stForm.PGCustomerCategoryID#',
	        #iPGTypeID#,
	        #arguments.stSession.qryGrpDistPack.GroupLevel_ID#,
	        '#arguments.stSession.qryGrpDistPack.Group_Dist_ID#',
	        #arguments.stSession.qryGrpDistPack.Inc_Exc#,
	        1,
	        0,
	        GetDate(),
	        <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
	        '#arguments.UserID#',
	        #bIncInOthers#,
	        #IsAPG#
			<cfif appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1'>
				,'#PGEffStartDate#'
				,'#PGEffEndDate#'
			</cfif>
	      )
	    </cfquery>
		</cfif>
   </cfloop>

  <!--- ChkBoxTemplate Insert for new and Update for removed ones --->
   <cfset qryCusGrpTemSel = this.fnCusGrpTemSel('#arguments.stForm.PGCustomerCategoryID#') />

  <!---
    Loop through the above query and see if the template_ID is available in the chkboxTemplate_ value
    If not then delete that record.
	[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
  --->
<!---
    <cfloop query = "qryCusGrpTemSel">
      <cfset templateFound = 0 />
      <cfloop index="colName" list="#arguments.stForm.fieldnames#">
        <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
        <cfset totLength = Len(colName) />
        <cfset strFirstPart 	 = Left(colName,(FindNoCase("_FID_",colName)-1)) />
				<cfset strFirstPartLen = Len(strFirstPart) />
				<cfset varID = Right(strFirstPart,(strFirstPartLen-15)) />
				<cfset returnLen = totLength - (FindNoCase("_FID_",colName) + 4) />
	 			<cfset TemplateFiltersID =  Right(colName,  returnLen) />
        <!---  <cfset varID = Right(i,(totLength-15)) /> --->
          <cfif qryCusGrpTemSel.Template_ID EQ varID AND qryCusGrpTemSel.Template_Filters_ID EQ TemplateFiltersID><!--- arguments.stForm[colName] --->
            <cfset templateFound = 1 />
            <!--- The ID is already there and no change hence remove it from the FORM as no change to this Template --->
            <!---  <cfset temp = StructDelete(arguments.stForm.fieldnames, colName) /> --->
 							<cfset arguments.stForm.fieldnames = Replace(arguments.stForm.fieldnames,colName,"") />
             <cfset temp2 = StructDelete(arguments.stForm, colName) />
             <cfbreak />
          </cfif>
        </cfif>
      </cfloop>
      <cfif templateFound EQ 0>
        <cfset useLakebaseForupdCusCatDef = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_group_template_selection")>
<cfif useLakebaseForupdCusCatDef>
	<cftry>
		<cfset application.oLakebase.updateRows("customer_group_template_selection",
			{
				"distributor_group_id" = "eq.#qryCusGrpTemSel.Distributor_Group_ID#",
				"template_id" = "eq.#qryCusGrpTemSel.Template_ID#",
				"template_filters_id" = "eq.#qryCusGrpTemSel.Template_Filters_ID#"
			},
			{
				"active" = "0",
				"deleted" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#arguments.UserID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdCusCatDef = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdCusCatDef>
<cfquery name="updCusCatDef" datasource="#application.datasource#">
          UPDATE Customer_Group_Template_Selection
          SET
            Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
          WHERE
            Distributor_Group_ID =  '#qryCusGrpTemSel.Distributor_Group_ID#' AND
						Template_ID = #qryCusGrpTemSel.Template_ID# AND
						Template_Filters_ID = #qryCusGrpTemSel.Template_Filters_ID#
        </cfquery>
</cfif>
<!---         <cfquery name="updCusCatDef" datasource="#application.datasource#">
          UPDATE Template_Filters
          SET
            Status = 'INACTIVE',
            Deleted = 1
          WHERE Template_Filters_ID =  #qryCusGrpTemSel.Template_Filters_Id#
        </cfquery> --->

      </cfif>
    </cfloop>


<!--- For newly selected templates insert as it is done in the insert --->
  <cfset TemplateFiltersID = "" />
	<cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #arguments.stForm[colName]#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>
			<cfset totalLen = Len(colName) />
	 		<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 		<cfset TemplateFiltersID =  Right(colName,  returnLen) />
			<cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
      <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
        -- DECLARE @Template_Filters_ID INT
        INSERT INTO Template_Filters
        (
          Template_Id,
          Parent_Template_Id,
          Description,
          Status,
          Deleted,
          Created_User_Id,
          Created_Date
        )
        VALUES
        (
          #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
          #arguments.stForm[colName]#,
          '#Left(qryTemplateDetails.Created_Type,50)#',
          'ACTIVE',
          0,
          '#arguments.UserID#',
          GetDate()
        )
        SELECT SCOPE_IDENTITY() AS Template_Filters_ID
      </cfquery>
			<cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
		</cfif>
      <cfquery name="qInsPGCustomerGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Customer_Group_Template_Selection
        (
          Template_ID,
          Distributor_Group_Level_ID,
          Distributor_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#arguments.stForm.PGCustomerCategoryID#',
          1,
          0,
          GetDate(),
          <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
          '#arguments.UserID#',
          1,
          'PG Adding Page',
          #TemplateFiltersID#
        )
      </cfquery>
    </cfif>
</cfloop>
--->
<cfquery name="qryPopulateTempTableForCustomer" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_PG_View_Customer_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Customer_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Customer_Category_Definition.PG_Customer_Category_ID,
				PG_Customer_Category_Definition.Distributor_Group_Level_ID,
				PG_Customer_Category_Definition.Distributor_Group_ID,
				PG_Customer_Category_Definition.Inclusion_Exclusion,
				PG_Customer_Category_Definition.IS_PG,
				PG_Customer_Category.Include_In_Other_PG,
				PG_Customer_Category.PG_Customer_Category_Code,
				PG_Customer_Category.PG_Customer_Category_Name,
				<cfif this.stBusinessSegmentSettings.DistributorEnabled>
					PG_Customer_Category.Business_Segment_ID
				<cfelse>
					NULL
				</cfif> as Business_Segment_ID
		INTO	##tmp_PG_View_Customer_Members
		FROM	PG_Type
		INNER JOIN	PG_Customer_Category_Definition
		ON		PG_Customer_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Customer_Category
		ON		PG_Customer_Category.PG_Customer_Category_ID = PG_Customer_Category_Definition.PG_Customer_Category_ID
		AND		PG_Customer_Category.Deleted = 0
		WHERE	PG_Customer_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =2 --Customer
		AND		(PG_Customer_Category_Definition.PG_Customer_Category_ID IN ('#arguments.stForm.PGCustomerCategoryID#')
		OR		PG_Customer_Category_Definition.PG_Customer_Category_ID IN (SELECT DISTINCT DISTRIBUTOR_Group_ID FROM PG_Customer_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Customer_Category_ID IN ('#arguments.stForm.PGCustomerCategoryID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Customer_Category_Definition.PG_Customer_Category_ID,
				PG_Customer_Category.Include_In_Other_PG,
				PG_Customer_Category_Definition.Distributor_Group_Level_ID,
				PG_Customer_Category_Definition.Distributor_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Customer_Members_C] ON [dbo].[##tmp_PG_View_Customer_Members]([Distributor_Group_ID],[Distributor_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  </cfquery>

	<cfquery name="qryUSPPopulateCustomerPGMembers" datasource="#application.datasource#">
		EXEC USP_POPULATE_CUSTOMER_PG_MEMBERS 2
	</cfquery>

<!---35259 Conversion failed when converting from a character string to uniqueidentifier--->
<CFIF len(arguments.stForm.DELMARKEDINEXISTING)>
        <cfset sDelMarkedInExisting =  #arguments.stForm.DelMarkedInExisting# />
        <cfset i = 1>
        <cfloop index = "DistributorGroupID" list = "#sDelMarkedInExisting#"  delimiters = ",">
        	<cfif FindNoCase('-','#DistributorGroupID#') EQ 0>
        		<CFSET  arguments.stForm.DelMarkedInExisting = ListDeleteAt(arguments.stForm.DelMarkedInExisting, i)>
        	<cfelse>
        		<cfset i = i+1>
        	</cfif>
       </cfloop>

<!--- D34374:Planning Group end date maintenance in group members table START ---->
<cfif len(arguments.stForm.DELMARKEDINEXISTING) and appSettings.getEnableGroupMembershipDates() EQ 1>

        <cfquery name="UpdateGroupMembers" datasource="#application.datasource#">
          UPDATE Customer_Group_Members
          SET End_Date = CAST(GETDATE() as DATE), Updated_Bit = 1
          WHERE   Customer_Group_ID =  '#arguments.stForm.PGCUSTOMERCATEGORYID#'
		  AND End_Date > CAST(GETDATE() as DATE)
		  AND BSA_FoodService_Customers_ID  IN (<cfqueryparam value="#arguments.stForm.DELMARKEDINEXISTING#" cfsqltype="CF_SQL_VARCHAR" list="yes"/>)
		  and deleted = 0
		  <!--- End date Group_Members only when customer is no longer a member of the PG.
		  If user is deleting an excluded record, that customer may now become member of the PG, in that case we should not end date it.
		  --->
		  AND NOT EXISTS (
                SELECT 1
                FROM PG_Customer_Members m
                WHERE m.PG_Customer_Category_ID = '#arguments.stForm.PGCUSTOMERCATEGORYID#'
                AND m.BSA_FoodService_Customers_ID = Customer_Group_Members.BSA_FoodService_Customers_ID
                AND m.Deleted = 0
        )
        </cfquery>
</cfif>
<!--- D34374:Planning Group end date maintenance in group members table END ---->
</CFIF>

     <cfreturn returnValue />
  </cffunction>

  <!--- Function to find existing "customer planning group" records --->
  <cffunction name="fnIsPlanningGroupCustomerExist" output="false" returntype="boolean" >
	<cfargument name="PG_Customer_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Distributor_ID"	required="true" type="string" />

	<cfset var bPGExist = 0 />

	<cfset useLakebaseForqIsPlanningGroupCustomerExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category_definition")>
<cfif useLakebaseForqIsPlanningGroupCustomerExist>
	<cftry>
		<cfset qIsPlanningGroupCustomerExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_customer_category_definition", {
				"pg_customer_category_id" = "eq.#arguments.PG_Customer_Category_ID#",
				"distributor_group_id" = "eq.#arguments.Group_Distributor_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsPlanningGroupCustomerExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsPlanningGroupCustomerExist>
<cfquery name="qIsPlanningGroupCustomerExist" datasource="#application.datasource#">
		SELECT 1
		FROM PG_Customer_Category_Definition
		WHERE PG_Customer_Category_ID = '#arguments.PG_Customer_Category_ID#'
		AND Distributor_group_ID = '#arguments.Group_Distributor_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

	<cfif qIsPlanningGroupCustomerExist.recordcount>
		<cfset bPGExist = 1 />
	</cfif>

	<cfreturn bPGExist />
</cffunction>

<!--- Function to delete "customer planning group" records --->
<cffunction name="fnDeletePlanningGroupCustomer" output="false" returntype="void" >
	<cfargument name="PG_Customer_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Distributor_ID"	required="true" type="string" />
	<cfargument name="UserID"	required="true" type="string" />

	<cfset useLakebaseForqDeletePlanningGroupCustomer = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_customer_category_definition")>
<cfif useLakebaseForqDeletePlanningGroupCustomer>
	<cftry>
		<cfset application.oLakebase.updateRows("pg_customer_category_definition",
			{
				"pg_customer_category_id" = "eq.#arguments.PG_Customer_Category_ID#",
				"distributor_group_id" = "eq.#arguments.Group_Distributor_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1"
			},
			{
				"deleted" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#arguments.UserID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeletePlanningGroupCustomer = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeletePlanningGroupCustomer>
<cfquery name="qDeletePlanningGroupCustomer" datasource="#application.datasource#">
		UPDATE PG_Customer_Category_Definition
		SET deleted = 1,
			Updated_Date = GetDate(),
			Updated_By =  '#arguments.UserID#'
		WHERE PG_Customer_Category_ID = '#arguments.PG_Customer_Category_ID#'
		AND Distributor_group_ID = '#arguments.Group_Distributor_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

</cffunction>

<!--- FUNCTION TO GET THE MEMBERS BASED ON THE PG_Product_Category_ID --->

 <cffunction  name="fnGetPGProductCategoryDefinition" output="false" returntype="void">
    <cfargument name="PGProductCategoryID" type="string" required="true" />
  			<cfquery name="qGetActivePGTypeByGrpType" datasource="#application.datasource#">
			SELECT
        PGPCD.PG_Product_Category_Definition_ID,
        PGPCD.PG_Product_Category_ID,
        PGPCD.PG_Type_ID,
        PGPCD.Product_Group_Level_ID,
        PGPCD.Product_Group_ID,
        PGPCD.Inclusion_Exclusion,
        PGPCD.Active,
        PGPCD.Deleted,
        PGPCD.Created_Date,
        PGPCD.Updated_Date,
        PGPCD.Created_By,
        PGPCD.Updated_BY,
        PGPCD.Include_In_Other_PG,
        PGPCD.Is_PG,
        PGL.Group_Level_Desc
			FROM		PG_Product_Category_Definition PGPCD
      LEFT JOIN ON Product_Group_Level PGL ON PGL.Product_Group_Level_ID = PGPCD.Product_Group_Level_ID
			WHERE PGPCD.Active = 1
      AND   PGPCD.PG_Product_Category_ID = <cfqueryparam value="#arguments.PGProductCategoryID#" cfsqltype="cf_sql_varchar"/>
      AND   PGPCD.Deleted = 0
    	</cfquery>
  </cffunction>

  <cffunction  name="fnGetPGCustomerCategoryDefinition" output="false" returntype="void">
    <cfargument name="PGCustomerCategoryID" type="string" required="true" />
  			<cfquery name="qGetActivePGTypeByGrpType" datasource="#application.datasource#">
			SELECT
        PGCCD.PG_Customer_Category_Definition_ID
        PGCCD.PG_Customer_Category_ID,
        PGCCD.PG_Type_ID,
        PGCCD.Distributor_Group_Level_ID,
        PGCCD.Distributor_Group_ID,
        PGCCD.Inclusion_Exclusion,
        PGCCD.Active,
        PGCCD.Deleted,
        PGCCD.Created_Date,
        PGCCD.Updated_Date,
        PGCCD.Created_By,
        PGCCD.Updated_BY,
        PGCCD.Include_In_Other_PG,
        PGCCD.Is_PG,
        DGL.Group_Level_Desc
			FROM		PG_Customer_Category_Definition PGCCD
      LEFT JOIN ON Distributor_Group_Level DGL ON DGL.Distributor_Group_Level_ID = PGCCD.Distributor_Group_Level_ID
			WHERE PGCCD.Active = 1
      AND   PGCCD.PG_Customer_Category_ID = <cfqueryparam value="#arguments.PGCustomerCategoryID#" cfsqltype="cf_sql_varchar"/>
      AND   PGCCD.Deleted = 0
    	</cfquery>
  </cffunction>

    <cffunction  name="fnGetGroupTemplateByPGTypeID" output="false" returntype="Query">
    <cfargument name="PGTypeID" type="string" required="true" />
  			<cfquery name="qryGetGroupTemplateByPGTypeID" datasource="#application.datasource#">
			SELECT
        GT.Group_Template_ID,
        GT.Template_ID,
        GT.Group_Level_ID,
        GT.PG_Group_Type,
        GT.Allow_In_Search,
        GT.Allow_In_Group_Search,
        GT.Active,
        GT.Deleted,
        GT.Created_Date,
        GT.Updated_Date,
        GT.Created_By,
        GT.Updated_BY,
        GT.PG_Flag,
        GT.Updated_From,
        Us.Name_First,
        Us.Name_Last
			FROM		Group_Template GT
      LEFT JOIN
        _Users Us ON GT.Updated_BY = Us.User_ID
			WHERE GT.Deleted = 0
      AND   GT.Group_Level_Id = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="cf_sql_varchar"/>
    	</cfquery>
      <cfreturn qryGetGroupTemplateByPGTypeID />
  </cffunction>

  <cffunction  name="fnGetGroupTemplateByTemplateID" output="false" returntype="Query">
    <cfargument name="FirstParentID" type="string" required="true" />
    <cfargument name="PGGroupType" type="string" required="true" />
	<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
  	<cfquery name="qryGetGroupTemplateByTemplateID" datasource="#application.datasource#">
		SELECT
	        GT.Group_Template_ID,
	        GT.Template_ID,
	        GT.Group_Level_ID,
	        GT.PG_Group_Type,
	        GT.Allow_In_Search,
	        GT.Allow_In_Group_Search,
	        GT.Allow_Filter,
			GT.Prg_Vol_By_Attribute,
	        GT.Active,
	        GT.Deleted,
	        GT.Created_Date,
	        GT.Updated_Date,
	        GT.Created_By,
	        GT.Updated_BY,
	        GT.PG_Flag,
	        GT.Updated_From,
	        Us.Name_First,
	        Us.Name_Last
		FROM		Group_Template GT
		<cfif TemplateFiltersID NEQ 0 AND arguments.PGGroupType EQ 1>
			LEFT JOIN Product_Group_Template_Selection PGTS ON
				PGTS.Template_ID = GT.Template_ID AND
				PGTS.Template_Filters_Id = <cfqueryparam value="#arguments.TemplateFiltersID#" cfsqltype="cf_sql_integer" /> AND
				PGTS.Product_Group_Level_ID = GT.Group_Level_ID AND
				PGTS.Deleted = 0
		</cfif>
      	LEFT JOIN _Users Us ON
			GT.Updated_BY = Us.User_ID
		WHERE
	        GT.Deleted = 0
	        AND GT.Active = 1
	        AND GT.Template_ID = <cfqueryparam value="#arguments.FirstParentID#" cfsqltype="cf_sql_varchar"/>
	        AND GT.PG_Group_Type = <cfqueryparam value="#arguments.PGGroupType#" cfsqltype="cf_sql_varchar"/>
    </cfquery>
	<cfreturn qryGetGroupTemplateByTemplateID />
  </cffunction>

  <cffunction name="fnCusGrpTemSel" output="false" returntype="Query">
    <cfargument name="PGCustomerCategoryID" type="string" required="true" />
     <cfset useLakebaseForqryCusGrpTemSel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_group_template_selection")>
<cfif useLakebaseForqryCusGrpTemSel>
	<cftry>
		<cfset qryCusGrpTemSel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_group_template_selection", {
				"distributor_group_id" = "eq.#arguments.PGCustomerCategoryID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "customer_group_template_selection_id,template_id,distributor_group_level_id,distributor_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
			}), "customer_group_template_selection_id,template_id,distributor_group_level_id,distributor_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCusGrpTemSel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCusGrpTemSel>
<cfquery name="qryCusGrpTemSel" datasource="#application.datasource#">
        SELECT
          Customer_Group_Template_Selection_ID,
          Template_ID,
          Distributor_Group_Level_ID,
          Distributor_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Updated_Date,
          Created_By,
          Updated_BY,
          PG_Flag,
          Updated_From,
          Template_Filters_Id
        FROM
          Customer_Group_Template_Selection
        WHERE Distributor_Group_ID = '#arguments.PGCustomerCategoryID#'
        AND Active = 1
        AND Deleted = 0
      </cfquery>
</cfif>
       <cfreturn qryCusGrpTemSel />
  </cffunction>

<cffunction name="fnProdGrpTemSel" output="false" returntype="Query">
    <cfargument name="PGProductCategoryID" type="string" required="true" />
     <cfset useLakebaseForqryProdGrpTemSel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_template_selection")>
<cfif useLakebaseForqryProdGrpTemSel>
	<cftry>
		<cfset qryProdGrpTemSel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_template_selection", {
				"product_group_id" = "eq.#arguments.PGProductCategoryID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "product_group_template_selection_id,template_id,product_group_level_id,product_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
			}), "product_group_template_selection_id,template_id,product_group_level_id,product_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryProdGrpTemSel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryProdGrpTemSel>
<cfquery name="qryProdGrpTemSel" datasource="#application.datasource#">
        SELECT
          Product_Group_Template_Selection_ID,
          Template_ID,
          Product_Group_Level_ID,
          Product_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Updated_Date,
          Created_By,
          Updated_BY,
          PG_Flag,
          Updated_From,
          Template_Filters_Id
        FROM
          Product_Group_Template_Selection
        WHERE Product_Group_ID = '#arguments.PGProductCategoryID#'
        AND Active = 1
        AND Deleted = 0
      </cfquery>
</cfif>
       <cfreturn qryProdGrpTemSel />
  </cffunction>


<cffunction name="fnMaxItemsOnProdSearch" output="false" returntype="any">
  <cfset var Max_No_of_Dropdowns_in_Product_Search = 4 />
  <cfreturn Max_No_of_Dropdowns_in_Product_Search />
</cffunction>

<cffunction name="fnMaxItemsOnDistSearch" output="false" returntype="any">
  <cfset var Max_No_of_Dropdowns_in_Distributor_Search = 4 />

  <cfreturn Max_No_of_Dropdowns_in_Distributor_Search />
</cffunction>

<cffunction name="fnMaxItemsOnOprSearch" output="false" returntype="any">
  <cfset var Max_No_of_Dropdowns_in_Distributor_Search = 4 />
  <cfreturn Max_No_of_Dropdowns_in_Distributor_Search />
</cffunction>

<!--- Operator Functions  --->


<cffunction name="fnGetActiveOperatorPGs" output="false" returntype="Query">
		<cfset var qGetActiveOperatorPGs = "" />
		<cfset useLakebaseForqGetActiveOperatorPGs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForqGetActiveOperatorPGs>
	<cftry>
		<cfset qGetActiveOperatorPGs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
			}), "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveOperatorPGs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveOperatorPGs>
<cfquery name="qGetActiveOperatorPGs" datasource="#application.datasource#">
			SELECT
            PG_Operator_Category_ID,
            PG_Type_ID,
            PG_Operator_Category_Code,
            PG_Operator_Category_Name,
            Active,
            Deleted,
            Updated_Date,
            Created_Date,
            Created_By,
            Updated_By,
            Include_In_Other_PG
			FROM		PG_Operator_Category
			WHERE Active = 1
      AND   Deleted = 0
    	</cfquery>
</cfif>
		<cfreturn qGetActiveOperatorPGs />
	</cffunction>

 	<cffunction name="fnGetInActiveOperatorPGs" output="false" returntype="Query">
		<cfset var qGetInActiveOperatorPGs = "" />
		<cfset useLakebaseForqGetInActiveOperatorPGs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForqGetInActiveOperatorPGs>
	<cftry>
		<cfset qGetInActiveOperatorPGs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"active" = "eq.0",
				"deleted" = "eq.0",
				"select" = "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
			}), "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,updated_date,created_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetInActiveOperatorPGs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetInActiveOperatorPGs>
<cfquery name="qGetInActiveOperatorPGs" datasource="#application.datasource#">
			SELECT
            PG_Operator_Category_ID,
            PG_Type_ID,
            PG_Operator_Category_Code,
            PG_Operator_Category_Name,
            Active,
            Deleted,
            Updated_Date,
            Created_Date,
            Created_By,
            Updated_By,
            Include_In_Other_PG
			FROM		PG_Operator_Category
			WHERE Active = 0
      AND   Deleted = 0
    	</cfquery>
</cfif>
		<cfreturn qGetInActiveOperatorPGs />
	</cffunction>

	<cffunction name="fnGetPGOperatorCategoryByID" output="false" returntype="Query">
    <cfargument name="PGOperatorCategoryID" required="true" type="string"  />
		<cfset var qryGetPGOperatorCategoryByID = "" />
		<cfquery name="qryGetPGOperatorCategoryByID" datasource="#application.datasource#">
			SELECT
            PGOC.PG_Operator_Category_ID,
            PGOC.PG_Type_ID,
            PGOC.PG_Operator_Category_Code,
            PGOC.PG_Operator_Category_name,
            PGOC.Active,
            PGOC.Deleted,
            PGOC.Updated_Date,
            PGOC.Created_Date,
            PGOC.Created_By,
            PGOC.Updated_By,
            PGOC.Include_In_Other_PG,
            PGT.PG_Type_Name,
            u1.Name_First,
            u1.Name_Last,
            PGOC.Is_Master_Group,
			PGOC.Capture_Removes,
			PGOC.For_Recapture
			,PGOC.PG_Effective_Start_Date
			,PGOC.PG_Effective_End_Date
      ,PGOC.PG_Number_Sequence
			FROM		PG_Operator_Category PGOC
      LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGOC.PG_Type_ID
      LEFT JOIN _Users u1 ON u1.User_ID = PGOC.Updated_By
			WHERE PGOC.PG_Operator_Category_ID = <cfqueryparam value="#arguments.PGOperatorCategoryID#" cfsqltype="cf_sql_varchar"/>
      AND   PGOC.Deleted = 0
    	</cfquery>
		<cfreturn qryGetPGOperatorCategoryByID />
	</cffunction>

  <cffunction name="fnGetActiveOperatorCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetActiveOperatorCategory = "" />
		  <cfquery name="qGetActiveOperatorCategory" datasource="#application.datasource#">
  			SELECT
          PGOC.PG_Operator_Category_ID,
          PGOC.PG_Type_ID,
          PGOC.PG_Operator_Category_Code,
          PGOC.PG_Operator_Category_Name,
          PGOC.Active,
          PGOC.Deleted,
          PGOC.Created_Date,
          PGOC.Updated_Date,
          PGOC.Created_By,
          PGOC.Updated_BY,
          PGOC.Include_In_Other_PG,
          PGT.PG_Type_Name
          ,PGOC.Is_System            <!---28269--->
  			FROM		PG_Operator_Category PGOC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGOC.PG_Type_ID
  			WHERE PGOC.Active = 1
        AND   PGOC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelse>PGOC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetActiveOperatorCategory />
	  </cffunction>


  	<cffunction name="fnGetInActiveOperatorCategory" output="false" returntype="Query">
      <cfargument name="sortBy" required="true" type="string"   />
      <cfargument name="sortOrder" required="true" type="string" />
		  <cfset var qGetInActiveOperatorCategory = "" />
		  <cfquery name="qGetInActiveOperatorCategory" datasource="#application.datasource#">
  			SELECT
          PGOC.PG_Operator_Category_ID,
          PGOC.PG_Type_ID,
          PGOC.PG_Operator_Category_Code,
          PGOC.PG_Operator_Category_Name,
          PGOC.Active,
          PGOC.Deleted,
          PGOC.Created_Date,
          PGOC.Updated_Date,
          PGOC.Created_By,
          PGOC.Updated_BY,
          PGOC.Include_In_Other_PG,
  			  PGT.PG_Type_Name
          ,PGOC.Is_System            <!---28269--->
  			FROM		PG_Operator_Category PGOC
        LEFT JOIN PG_Type PGT ON PGT.PG_Type_ID = PGOC.PG_Type_ID
  			WHERE PGOC.Active = 0
        AND   PGOC.Deleted = 0
        ORDER BY <cfif arguments.sortBy EQ "PG_Type_Name">PGT.<cfelse>PGOC.</cfif>#arguments.sortBy# #arguments.sortOrder#
    	</cfquery>
		  <cfreturn qGetInActiveOperatorCategory />
	  </cffunction>

    <cffunction name="fnGetCoreOperatorPG" output="false" returntype="Query">
		  <cfset var qGetCoreOperatorPG = "" />
		  <cfset useLakebaseForqGetCoreOperatorPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForqGetCoreOperatorPG>
	<cftry>
		<cfset qGetCoreOperatorPG = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"include_in_other_pg" = "eq.1",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg"
			}), "pg_operator_category_id,pg_type_id,pg_operator_category_code,pg_operator_category_name,active,deleted,created_date,updated_date,created_by,updated_by,include_in_other_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCoreOperatorPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCoreOperatorPG>
<cfquery name="qGetCoreOperatorPG" datasource="#application.datasource#">
  			SELECT
          PG_Operator_Category_ID,
          PG_Type_ID,
          PG_Operator_Category_Code,
          PG_Operator_Category_Name,
          Active,
          Deleted,
          Created_Date,
          Updated_Date,
          Created_By,
          Updated_BY,
          Include_In_Other_PG
  			FROM		PG_Operator_Category
  			WHERE Include_In_Other_PG = 1
        AND Active = 1
        AND Deleted = 0
    	</cfquery>
</cfif>
		  <cfreturn qGetCoreCustomerPG />
	  </cffunction>


  <cffunction  name="activateOperatorPG" output="false" returntype="void">
    <cfargument name="PGOperatorCatID" type="string" required="true" />
  	<cfquery name="qryActivateOperatorPG" datasource="#application.datasource#">
      UPDATE PG_Operator_Category
      SET Active = 1
	  WHERE PG_Operator_Category_ID IN (<cfqueryparam value="#arguments.PGOperatorCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>

<cffunction name="deActivateOperatorPG" output="false" returntype="void">
    <cfargument name="PGOperatorCatID" type="string" required="true" />
  	<cfquery name="qryDeActivateOperatorPG" datasource="#application.datasource#">
      UPDATE PG_Operator_Category
      SET Active = 0
	  WHERE PG_Operator_Category_ID IN (<cfqueryparam value="#arguments.PGOperatorCatID#" list="yes" cfsqltype="cf_sql_idstamp" >)
    </cfquery>
  </cffunction>


  <cffunction  name="delOperatorPG" output="false" returntype="void">
    <cfargument name="PGOperatorCatID" type="string" required="true" />
  	<cfquery name="qryDeleteOperatorPG" datasource="#application.datasource#">
      UPDATE PG_Operator_Category
      SET Deleted = 1
      WHERE PG_Operator_Category_ID in ('#arguments.PGOperatorCatID#')
    </cfquery>
  </cffunction>

  <cffunction name="fnGetOperatorData" output="false" returntype="Query">
    <cfargument name="OperatorList" type="string" required="true" />
    <cfset var qOperatorData = "" />
      <cfquery name="qOperatorData" datasource="#application.datasource#">
        SELECT BSA_Operator.*
			<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
				,Bus_Seg.Business_Unit_Desc
			</cfif>
        FROM BSA_Operator
			<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
				LEFT JOIN Business_Segment Bus_Seg
				ON Bus_Seg.Business_Segment_ID = BSA_Operator.Business_Segment_ID
			</cfif>
        WHERE BSA_Operator_ID in (#arguments.OperatorList#)
      </cfquery>
    <cfreturn qOperatorData />
	</cffunction>


 <cffunction  name="fnGetOperatorPGByTypeID" output="false" returntype="Query">
    <cfargument name="PGTypeID" type="string" required="true" />
  	<cfquery name="qryOperatorPGByTypeID" datasource="#application.datasource#">
      SELECT
        PG_Operator_Category_ID,
        PG_Type_ID,
        PG_Operator_Category_Code,
        PG_Operator_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Operator_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
    <cfreturn qryOperatorPGByTypeID />
  </cffunction>

   <!--- Operator Adding function  --->

 <cffunction name="fnAddOperatorPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />
    <cfset returnValue = "" />
     <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Operator_Category_Name FROM PG_Operator_Category WHERE PG_Operator_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#' AND Deleted = 0
     </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
       <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>
    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

<!---D81389 Tyson - System generated number for Planning Groups --->
<cfif appSettings.get_Setting('PG_Eff_Date_Product') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Distributor') eq '1' OR appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
  <cfset PG_Number_Sequence = this.PGSequenceNumber()/>
<cfelse>
  <cfset PG_Number_Sequence = 0>
</cfif>

		<cfparam name="arguments.stForm.bCaptureRemoves" default="0">

    <cfquery name="qInsPGOperator" datasource="#application.datasource#">
      DECLARE @PG_Operator_Category_ID VARCHAR (50)
      SET @PG_Operator_Category_ID = NEWID()
      INSERT INTO PG_Operator_Category
      (
        PG_Operator_Category_ID,
        PG_Type_ID,
        PG_Operator_Category_Code,
        PG_Operator_Category_Name,
        Active,
        Deleted,
        Created_Date,
        Created_By,
        Include_In_Other_PG,
        Is_Master_Group, <!---31191--->
        Capture_Removes,
		For_Recapture
		 ,PG_Effective_Start_Date
		 ,PG_Effective_End_Date
     ,PG_Number_Sequence
      )
      VALUES
      (
        @PG_Operator_Category_ID,
        <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        1,
        0,
        GetDate(),
        <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
        <cfif isdefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>,  <!---31191--->
       <cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>,
	   <cfif isdefined("arguments.stForm.For_Recapture")>1<cfelse>0</cfif>
	  ,<cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
	  ,<cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
      ,<cfqueryparam value="#PG_Number_Sequence#" cfsqltype="cf_sql_bigint"/>
      )

       SELECT PG_Operator_Category_ID = @PG_Operator_Category_ID
    </cfquery>

    <cfloop query="arguments.stSession.qryGrpOperatorPack">
      <cfif arguments.stSession.qryGrpOperatorPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpOperatorPack.IsPG EQ "" OR  arguments.stSession.qryGrpOperatorPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>


 <!--- DO NOT INSERT IF THE Operator_ID IS IN EITHER THE INCLUDE OR EXCLUDE LIST DELMARKED FIELD --->
     <!---  <cfif (FindNoCase(arguments.stSession.qryGrpOperatorPack.Operator_ID,arguments.stForm.DelMarkedInInclude) EQ 0 AND FindNoCase(arguments.stSession.qryGrpOperatorPack.Operator_ID,arguments.stForm.DelMarkedInExclude) EQ 0)  > --->

		<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0>
		<cfset recDelInExclude = 0>

		<cfif arguments.stSession.qryGrpOperatorPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpOperatorPack.Operator_ID >
					<!--- <cfset 	recDelInInclude = 1 />    --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpOperatorPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpOperatorPack.Operator_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>
			<cfset useLakebaseForqInsPGOperatorCategoryDefinition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForqInsPGOperatorCategoryDefinition>
	<cftry>
		<cfset application.oLakebase.insertRow("pg_operator_category_definition", {
			"pg_operator_category_id" = "#qInsPGOperator.PG_Operator_Category_ID#",
			"pg_type_id" = "#iPGTypeID#",
			"operator_group_level_id" = "#arguments.stSession.qryGrpOperatorPack.GroupLevel_ID#",
			"operator_group_id" = "#arguments.stSession.qryGrpOperatorPack.Operator_ID#",
			"inclusion_exclusion" = "#arguments.stSession.qryGrpOperatorPack.Inc_Exc#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"include_in_other_pg" = "#bIncInOthers#",
			"is_pg" = "#IsAPG#",
			"pg_effective_start_date" = "#arguments.stForm.PG_Effective_Start_Date#",
			"pg_effective_end_date" = "#arguments.stForm.PG_Effective_End_Date#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGOperatorCategoryDefinition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGOperatorCategoryDefinition>
<cfquery name="qInsPGOperatorCategoryDefinition" datasource="#application.datasource#">
	      INSERT INTO PG_Operator_Category_Definition
	      (
	        PG_Operator_Category_ID,
	        PG_Type_ID,
	        Operator_Group_Level_ID,
	        Operator_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        Created_Date,
	        Created_By,
	        Include_In_Other_PG,
	        Is_PG,
			PG_Effective_Start_Date,
		  	PG_Effective_End_Date
	      )
	      VALUES
	      (
	        '#qInsPGOperator.PG_Operator_Category_ID#',
	        #iPGTypeID#,<!--- arguments.stForm.PGTypeID --->
	        #arguments.stSession.qryGrpOperatorPack.GroupLevel_ID#,
	        '#arguments.stSession.qryGrpOperatorPack.Operator_ID#',
	        #arguments.stSession.qryGrpOperatorPack.Inc_Exc#,
	        1,
	        0,
	        GetDate(),
	        <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
	        '#arguments.UserID#',
	        #bIncInOthers#,
	        #IsAPG#,
			'#arguments.stForm.PG_Effective_Start_Date#',
			'#arguments.stForm.PG_Effective_End_Date#'
	      )
	    </cfquery>
</cfif>
    </cfif>
   </cfloop>

<!---
[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
--->
<!---
  <cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #arguments.stForm[colName]#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>
    <cfset totalLen = Len(colName) />
	 	<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 	<cfset TemplateFiltersID =  Right(colName,  returnLen) />
 	 	<cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
      <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
        -- DECLARE @Template_Filters_ID INT
        INSERT INTO Template_Filters
        (
          Template_Id,
          Parent_Template_Id,
          Description,
          Status,
          Deleted,
          Created_User_Id,
          Created_Date
        )
        VALUES
        (
          #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
          #arguments.stForm[colName]#,
          '#Left(qryTemplateDetails.Created_Type,50)#',
          'ACTIVE',
          0,
          '#arguments.UserID#',
          GetDate()
        )
        SELECT SCOPE_IDENTITY() AS Template_Filters_ID
      </cfquery>
		 	<cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
	</cfif>
      <cfset useLakebaseForqInsPGOperatorGroupTemplateSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_group_template_selection")>
<cfif useLakebaseForqInsPGOperatorGroupTemplateSelection>
	<cftry>
		<cfset application.oLakebase.insertRow("operator_group_template_selection", {
			"template_id" = "#arguments.stForm[colName]#",
			"operator_group_level_id" = "#arguments.stForm.PGTypeID#",
			"operator_group_id" = "#qInsPGOperator.PG_Operator_Category_ID#",
			"active" = "1",
			"deleted" = "0",
			"created_date" = "#now()#",
			"created_by" = "#arguments.UserID#",
			"pg_flag" = "1",
			"updated_from" = "PG Adding Page",
			"template_filters_id" = "#TemplateFiltersID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsPGOperatorGroupTemplateSelection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsPGOperatorGroupTemplateSelection>
<cfquery name="qInsPGOperatorGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Operator_Group_Template_Selection
        (
          Template_ID,
          Operator_Group_Level_ID,
          Operator_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#qInsPGOperator.PG_Operator_Category_ID#',
          1,
          0,
          GetDate(),
          '#arguments.UserID#',
          1,
          'PG Adding Page',
          #TemplateFiltersID#
        )
      </cfquery>
</cfif>
    </cfif>
</cfloop>
--->

<cfquery name="qryPopulateTempTableForOperator" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_PG_View_Operator_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Operator_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID,
				PG_Operator_Category_Definition.Inclusion_Exclusion,
				PG_Operator_Category_Definition.IS_PG,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category.PG_Operator_Category_Code,
				PG_Operator_Category.PG_Operator_Category_Name
		INTO	##tmp_PG_View_Operator_Members
		FROM	PG_Type
		INNER JOIN	PG_Operator_Category_Definition
		ON		PG_Operator_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER JOIN PG_Operator_Category
		ON		PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Category_Definition.PG_Operator_Category_ID
		AND		PG_Operator_Category.Deleted = 0
		WHERE	PG_Operator_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =3 --Operator
		AND		(PG_Operator_Category_Definition.PG_Operator_Category_ID IN ('#qInsPGOperator.PG_Operator_Category_ID#')
		OR		PG_Operator_Category_Definition.PG_Operator_Category_ID IN (SELECT DISTINCT Operator_Group_ID FROM PG_Operator_Category_Definition WHERE IS_PG =1 AND Deleted = 0 AND PG_Operator_Category_ID IN ('#qInsPGOperator.PG_Operator_Category_ID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Operator_Members_C] ON [dbo].[##tmp_PG_View_Operator_Members]([Operator_Group_ID],[Operator_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  </cfquery>
    <cfstoredproc procedure="USP_POPULATE_OPERATOR_PG_MEMBERS" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
      <cfprocresult name="qryUSPPopulateOperatorPGMembers">
    </cfstoredproc>

    <cfreturn returnValue />
  </cffunction>

<!------------------------------------------------------------------------------
 *********************** Function to Edit the Customer PG ***********************
 ------------------------------------------------------------------------------>
  <cffunction name="fnEditOperatorPG" output="false" returntype="string" >
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfargument name="stSession"     required="true" default="" type="any" />
    <cfset returnValue = "" />
	<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
	<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
    <cfquery name="qNameCheck" datasource="#application.datasource#">
      SELECT PG_Operator_Category_Name FROM PG_Operator_Category WHERE PG_Operator_Category_Name = '#RTrim(LTrim(arguments.stForm.planningGroupName))#' AND PG_Operator_Category_ID != '#arguments.stForm.PGOperatorCategoryID#'
			AND Deleted = 0
    </cfquery>

    <cfif qNameCheck.RecordCount GTE 1>
      <cfset returnValue = "1" />
      <cfreturn returnValue />
    </cfif>
    <cfif isDefined("arguments.stForm.bIncludeInOthers")>
      <cfset bIncInOthers = 1 />
    <cfelse>
      <cfset bIncInOthers = 0 />
    </cfif>

    <cfif isDefined("arguments.stForm.PGTypeID")>
      <cfif (arguments.stForm.PGTypeID EQ "") AND IsDefined("arguments.stForm.SelTypeName") AND arguments.stForm.SelTypeName NEQ "0">
        <cfset iPGTypeID = arguments.stForm.SelTypeName />
      <cfelse>
        <cfset iPGTypeID = arguments.stForm.PGTypeID />
      </cfif>
    <cfelse>
      <cfset iPGTypeID = 0 />
    </cfif>

		<cfparam name="arguments.stForm.bCaptureRemoves" default="0">

    <cfquery name="qUpdPGOperator" datasource="#application.datasource#">
      UPDATE PG_Operator_Category
      SET
        PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>,
        PG_Operator_Category_Code =  <cfqueryparam value="#arguments.stForm.planningGroupCode#" cfsqltype="cf_sql_varchar"/>,
        PG_Operator_Category_Name = <cfqueryparam value="#RTrim(LTrim(arguments.stForm.planningGroupName))#" cfsqltype="cf_sql_varchar"/>,
        Updated_Date = GetDate(),
        Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
        Include_In_Other_PG =  <cfqueryparam value="#bIncInOthers#" cfsqltype="cf_sql_tinyint"/>,
        Is_Master_Group = <cfif isDefined("arguments.stForm.bMasterGroupOnly")>1<cfelse>0</cfif>,      <!---31191--->
        Capture_Removes = <cfqueryparam value="#arguments.stForm.bCaptureRemoves#" cfsqltype="cf_sql_tinyint"/>,
		For_Recapture = <cfif isDefined("arguments.stForm.For_Recapture")>1<cfelse>0</cfif>
		,PG_Effective_Start_Date	 = <cfqueryparam value="#arguments.stForm.PG_Effective_Start_Date#" cfsqltype="cf_sql_date"/>
		,PG_Effective_End_Date	 = <cfqueryparam value="#arguments.stForm.PG_Effective_End_Date#" cfsqltype="cf_sql_date"/>
      WHERE PG_Operator_Category_ID = '#arguments.stForm.PGOperatorCategoryID#'
     </cfquery>

	<!--- D32768: Update PG_Type_ID in other PG tables, updating definition table will fix all other tables --->
	<cfquery name="qUpdPGOperatorMember" datasource="#application.datasource#">
      UPDATE PG_Operator_Category_Definition
      SET
        PG_Type_ID = <cfqueryparam value="#arguments.stForm.PGTypeID#" cfsqltype="cf_sql_varchar"/>
      WHERE
        PG_Operator_Category_ID = '#arguments.stForm.PGOperatorCategoryID#'
     </cfquery>
	<!---
	 	START: D47046 Planning Group 'type' updates not reflected in other planning group rules:/Anand Rao/17-Dec-2014
	--->
		<cfif (bIncInOthers EQ 1)>
		 	<cfquery name="qUpdPGOperatorDef" datasource="#application.datasource#">
				UPDATE PG_Operator_Category_Definition SET Operator_Group_Level_ID = '#arguments.stForm.PGTypeID#' WHERE PG_Operator_Category_Definition_ID IN
 				(SELECT PG_Operator_Category_Definition_ID FROM PG_Operator_Category_Definition WHERE Deleted = 0 AND Operator_Group_ID = '#arguments.stForm.PGOperatorCategoryID#' AND Is_PG = 1)
		 	</cfquery>
		</cfif>
	 <!--- END:  D46895 --->

 <!--- Update the existing records in the PG_Operator_Category_Definition table --->
    <!--- Get all the current records in the table for this PG_Operator_Category_ID --->

    <cfquery name="qrySelectCusCatDef" datasource="#application.datasource#">
      SELECT
        PG_Operator_Category_Definition_ID,
        PG_Operator_Category_ID,
        PG_Type_ID,
        Operator_Group_Level_ID,
        Operator_Group_ID,
        Inclusion_Exclusion,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG,
        Is_PG,
		PG_Effective_Start_Date,
		PG_Effective_End_Date
      FROM
        PG_Operator_Category_Definition
      WHERE PG_Operator_Category_ID = '#arguments.stForm.PGOperatorCategoryID#'
      AND Active = 1
      AND Deleted = 0
    </cfquery>


    <cfloop query="qrySelectCusCatDef">
      <cfset groupFound = 0 />
	   <cfif (appSettings.get_Setting('PG_Eff_Date_Operator') eq '1')>
		<cfif (isDefined("arguments.stForm.PG_Effective_Start_Date_#Replace(qrySelectCusCatDef.PG_Operator_Category_Definition_ID,'-','_','ALL')#") AND isDefined("arguments.stForm.PG_Effective_End_Date_#Replace(qrySelectCusCatDef.PG_Operator_Category_Definition_ID,'-','_','ALL')#") )>
			<cfset PGEffStartDate = evaluate("arguments.stForm.PG_Effective_Start_Date_" & Replace(qrySelectCusCatDef.PG_Operator_Category_Definition_ID,'-','_','ALL')) />
			<cfset PGEffEndDate = evaluate("arguments.stForm.PG_Effective_End_Date_" & Replace(qrySelectCusCatDef.PG_Operator_Category_Definition_ID,'-','_','ALL')) />
		<cfelse>
			<cfset PGEffStartDate = qrySelectCusCatDef.PG_Effective_Start_Date />
			<cfset PGEffEndDate = qrySelectCusCatDef.PG_Effective_End_Date />
		</cfif>
	  <cfelse>
		<cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
		<cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
	  </cfif>

	  <cfif PGEffStartDate EQ "1900-01-01 00:00:00.000" OR PGEffStartDate EQ "">
	 	 <cfset PGEffStartDate = arguments.stForm.PG_Effective_Start_Date />
	  </cfif>
	   <cfif PGEffEndDate EQ "1900-01-01 00:00:00.000" OR PGEffEndDate EQ "">
	 	 <cfset PGEffEndDate = arguments.stForm.PG_Effective_End_Date />
	  </cfif>
      <cfloop collection="#arguments.stForm#" item="i">
         <cfif (FindNoCase("rdoIncExc_",i) NEQ 0)>
          <cfset groupFound = 1 />
          <cfset totLength = Len(i) />
          <cfset varID = Replace(Right(i,(totLength-10)),"_","-","ALL") /> <!--- 10 is the length of "rdoIncExc_" --->
					<cfset checkRec = 0>
					<cfloop index = "oprID" list = "#arguments.stForm.DelMarkedInExisting#"  delimiters = ",">
						<cfif oprID EQ qrySelectCusCatDef.Operator_Group_ID>
							<cfset 	checkRec = 1 />
						</cfif>
					</cfloop>
          <cfif (qrySelectCusCatDef.Operator_Group_ID EQ varID AND checkRec EQ 0 <!--- FindNoCase(qrySelectCusCatDef.Operator_Group_ID,arguments.stForm.DelMarkedInExisting) EQ 0 --->)>
            <cfquery name="updCusCatDef1" datasource="#application.datasource#">
              UPDATE PG_Operator_Category_Definition
              SET
                Inclusion_Exclusion = #arguments.stForm[i]#,
                Updated_Date = GetDate(),
                Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
				<cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
					,PG_Effective_Start_Date = '#PGEffStartDate#'
					,PG_Effective_End_Date = '#PGEffEndDate#'
				</cfif>
              WHERE
                PG_Operator_Category_Definition_ID =  #qrySelectCusCatDef.PG_Operator_Category_Definition_ID#
            </cfquery>
          <cfelseif (qrySelectCusCatDef.Operator_Group_ID EQ varID AND checkRec EQ 1 <!--- FindNoCase(qrySelectCusCatDef.Operator_Group_ID,arguments.stForm.DelMarkedInExisting) GT 0 --->)>
          <!--- If the record was checked to a different option and then --->
            <cfquery name="updCusCatDef2" datasource="#application.datasource#">
              UPDATE PG_Operator_Category_Definition
              SET
              Active = 0,
              Deleted = 1,
              Updated_Date = GetDate(),
              Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
			  <cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
					,PG_Effective_Start_Date = '#PGEffStartDate#'
					,PG_Effective_End_Date = '#PGEffEndDate#'
				</cfif>
            WHERE
              PG_Operator_Category_Definition_ID =  #qrySelectCusCatDef.PG_Operator_Category_Definition_ID#
        </cfquery>

          </cfif>
        </cfif>
      </cfloop>
      <cfif groupFound EQ 0>
        <cfquery name="updCusCatDef3" datasource="#application.datasource#">
          UPDATE PG_Operator_Category_Definition
          SET
            Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
			<cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
				,PG_Effective_Start_Date = '#PGEffStartDate#'
				,PG_Effective_End_Date = '#PGEffEndDate#'
			</cfif>
          WHERE
            PG_Operator_Category_Definition_ID =  #qrySelectCusCatDef.PG_Operator_Category_Definition_ID#
        </cfquery>
      </cfif>
    </cfloop>

<cfif (isDefined("arguments.stSession.qryGrpOperatorPack") AND arguments.stSession.qryGrpOperatorPack.RecordCount GTE 1)>
    <cfloop query="arguments.stSession.qryGrpOperatorPack">
      <cfif arguments.stSession.qryGrpOperatorPack.IsPG EQ "NO" OR  arguments.stSession.qryGrpOperatorPack.IsPG EQ "" OR  arguments.stSession.qryGrpOperatorPack.IsPG EQ 0>
        <cfset IsAPG = 0 />
      <cfelse>
        <cfset IsAPG = 1 />
      </cfif>


    <!--- Insert the newly added category Definitions/ members into the PG_Operator_Category_Definition table --->

		<cfset recInDelList = 0 />
		<cfset recDelInInclude = 0 />
		<cfset recDelInExclude = 0 />

		<cfif arguments.stSession.qryGrpOperatorPack.Inc_Exc EQ 1>
			<cfloop index = "delItem" list = "#arguments.stForm.DelMarkedInInclude#"  delimiters = ",">
				<cfif delItem EQ arguments.stSession.qryGrpOperatorPack.Operator_ID >
					<!--- <cfset 	recDelInInclude = 1 />    --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		<cfelseif arguments.stSession.qryGrpOperatorPack.Inc_Exc EQ 0>
			<cfloop index = "delItem2" list = "#arguments.stForm.DelMarkedInExclude#"  delimiters = ",">
				<cfif delItem2 EQ arguments.stSession.qryGrpOperatorPack.Operator_ID>
				<!--- 	<cfset 	recDelInExclude = 1 />   --->
					<cfset 	recInDelList = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<!--- <cfif recDelInInclude EQ 0 AND recDelInExclude EQ 0> --->
		<cfif recInDelList EQ 0>

		<!--- Dev Note(66983)- start --->
		<cfset bPGOperatorExist = fnIsPlanningGroupOperatorExist(arguments.stForm.PGOperatorCategoryID,arguments.stSession.qryGrpOperatorPack.Operator_ID)>
		<cfif bPGOperatorExist eq 1>
			<!--- Delete the existing record before adding it again below (In case it already exists) --->
			<cfset fnDeletePlanningGroupOperator(arguments.stForm.PGOperatorCategoryID,arguments.stSession.qryGrpOperatorPack.Operator_ID,arguments.UserID)>
		</cfif>
		<!--- Dev Note(66983)- end --->

	    <cfquery name="qInsPGOperatorCategoryDefinition" datasource="#application.datasource#">
	      INSERT INTO PG_Operator_Category_Definition
	      (
	        PG_Operator_Category_ID,
	        PG_Type_ID,
	        Operator_Group_Level_ID,
	        Operator_Group_ID,
	        Inclusion_Exclusion,
	        Active,
	        Deleted,
	        Created_Date,
	        Created_By,
	        Include_In_Other_PG,
	        Is_PG
			<cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
			,PG_Effective_Start_Date
			,PG_Effective_End_Date
			</cfif>
	      )
	      VALUES
	      (
	        '#arguments.stForm.PGOperatorCategoryID#',
	        #iPGTypeID#,
	        #arguments.stSession.qryGrpOperatorPack.GroupLevel_ID#,
	        '#arguments.stSession.qryGrpOperatorPack.Operator_ID#',
	        #arguments.stSession.qryGrpOperatorPack.Inc_Exc#,
	        1,
	        0,
	        GetDate(),
	        <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
	        '#arguments.UserID#',
	        #bIncInOthers#,
	        #IsAPG#
			<cfif appSettings.get_Setting('PG_Eff_Date_Operator') eq '1'>
				,'#PGEffStartDate#'
				,'#PGEffEndDate#'
			</cfif>
	      )
	    </cfquery>
		</cfif>
   </cfloop>
</cfif>
  <!--- ChkBoxTemplate Insert for new and Update for removed ones --->
   <cfset qryCusGrpTemSel = this.fnCusGrpTemSel('#arguments.stForm.PGOperatorCategoryID#') />

  <!---
    Loop through the above query and see if the template_ID is available in the chkboxTemplate_ value
    If not then delete that record.
  --->
<!---
[Deepa 8/30/2011] Commenting below as we no longer need it.
	We no longer display the template filter selection inside the planning groups create/edit page
--->
<!---
	<cfloop query = "qryCusGrpTemSel">
      <cfset templateFound = 0 />
      <cfloop index="colName" list="#arguments.stForm.fieldnames#">
        <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
        <cfset totLength = Len(colName) />
				<cfset strFirstPart 	 = Left(colName,(FindNoCase("_FID_",colName)-1)) />
				<cfset strFirstPartLen = Len(strFirstPart) />
				<cfset varID = Right(strFirstPart,(strFirstPartLen-15)) />
				<cfset returnLen = totLength - (FindNoCase("_FID_",colName) + 4) />
	 			<cfset TemplateFiltersID =  Right(colName,  returnLen) />
        <!---  <cfset varID = Right(i,(totLength-15)) /> --->
          <cfif qryCusGrpTemSel.Template_ID EQ varID AND qryCusGrpTemSel.Template_Filters_ID EQ TemplateFiltersID><!--- arguments.stForm[colName] --->
            <cfset templateFound = 1 />
            <!--- The ID is already there and no change hence remove it from the FORM as no change to this Template --->
            <!---  <cfset temp = StructDelete(arguments.stForm.fieldnames, colName) /> --->
 						 <cfset arguments.stForm.fieldnames = Replace(arguments.stForm.fieldnames,colName,"") />
             <cfset temp2 = StructDelete(arguments.stForm, colName) />
             <cfbreak />
          </cfif>
        </cfif>
      </cfloop>
      <cfif templateFound EQ 0>
        <cfquery name="updCusCatDef" datasource="#application.datasource#">
          UPDATE Operator_Group_Template_Selection
          SET
            Active = 0,
            Deleted = 1,
            Updated_Date = GetDate(),
            Updated_By =  '#arguments.UserID#'
          WHERE
            Operator_Group_ID =  '#qryCusGrpTemSel.Operator_Group_ID#' AND
						Template_ID = #qryProdGrpTemSel.Template_ID# AND
						Template_Filters_ID = #qryProdGrpTemSel.Template_Filters_ID#
        </cfquery>
<!---         <cfquery name="updCusCatDef" datasource="#application.datasource#">
          UPDATE Template_Filters
          SET
            Status = 'INACTIVE',
            Deleted = 1
          WHERE Template_Filters_ID =  #qryCusGrpTemSel.Template_Filters_Id#
        </cfquery> --->

      </cfif>
    </cfloop>

<!--- For newly selected templates insert as it is done in the insert --->
   <cfset TemplateFiltersID = "" />
  <cfloop index="colName" list="#arguments.stForm.fieldnames#">
    <cfif (FindNoCase("CHKBOXTEMPLATE_",colName) NEQ 0)>
      <cfquery name="qryTemplateDetails" datasource="#application.datasource#">
        SELECT TOP 1
          ProgramControl_Panel_Options_ID,
          Created_Type
        FROM
          Program_Control_Panel_Options
        WHERE
          First_Parent_ID = #arguments.stForm[colName]#
          AND Active = 1
          AND IsDominant = 1
          AND Deleted = 0
          ORDER BY Date_Created DESC
      </cfquery>
			<cfset totalLen = Len(colName) />
	 		<cfset returnLen = totalLen - (FindNoCase("_FID_",colName) + 4) />
	 		<cfset TemplateFiltersID =  Right(colName,  returnLen) />
			<cfif TemplateFiltersID EQ "">
		 <!---
		 		This query will never get executed as there always will be a value within the name
				This is kept just as a backup measure, not to throw an error.
		 --->
      <cfquery name="qInsTemplateFilters" datasource="#application.datasource#">
        -- DECLARE @Template_Filters_ID INT
        INSERT INTO Template_Filters
        (
          Template_Id,
          Parent_Template_Id,
          Description,
          Status,
          Deleted,
          Created_User_Id,
          Created_Date
        )
        VALUES
        (
          #qryTemplateDetails.ProgramControl_Panel_Options_ID#,
          #arguments.stForm[colName]#,
          '#Left(qryTemplateDetails.Created_Type,50)#',
          'ACTIVE',
          0,
          '#arguments.UserID#',
          GetDate()
        )
        SELECT SCOPE_IDENTITY() AS Template_Filters_ID
      </cfquery>
 		<cfset TemplateFiltersID = qInsTemplateFilters.Template_Filters_ID />
		</cfif>
      <cfquery name="qInsPGOperatorGroupTemplateSelection" datasource="#application.datasource#">
        INSERT INTO Operator_Group_Template_Selection
        (
          Template_ID,
          Operator_Group_Level_ID,
          Operator_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Created_By,
          PG_Flag,
          Updated_From,
          Template_Filters_ID
        )
        VALUES
        (
          #arguments.stForm[colName]#,
          #arguments.stForm.PGTypeID#,
          '#arguments.stForm.PGOperatorCategoryID#',
          1,
          0,
          GetDate(),
          <!--- <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>, --->
          '#arguments.UserID#',
          1,
          'PG Adding Page',
          #TemplateFiltersID#
        )
      </cfquery>
    </cfif>
</cfloop>
--->

<cfquery name="qryPopulateTempTableForOperator" datasource="#application.datasource#">
		IF OBJECT_ID ('tempdb..##tmp_PG_View_Operator_Members') IS NOT NULL
		DROP TABLE ##tmp_PG_View_Operator_Members

		SELECT	Distinct
				PG_Type.PG_Type_ID,
				PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID,
				PG_Operator_Category_Definition.Inclusion_Exclusion,
				PG_Operator_Category_Definition.IS_PG,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category.PG_Operator_Category_Code,
				PG_Operator_Category.PG_Operator_Category_Name
		INTO	##tmp_PG_View_Operator_Members
		FROM	PG_Type
		INNER JOIN	PG_Operator_Category_Definition
		ON		PG_Operator_Category_Definition.PG_Type_ID = PG_Type.PG_Type_ID
		INNER join PG_Operator_Category
		ON		PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Category_Definition.PG_Operator_Category_ID
		AND		PG_Operator_Category.Deleted = 0
		WHERE	PG_Operator_Category_Definition.Deleted = 0
		AND		PG_Type.PG_Group_Type =3 --Operator
		AND		(PG_Operator_Category_Definition.PG_Operator_Category_ID IN ('#arguments.stForm.PGOperatorCategoryID#')
		OR		PG_Operator_Category_Definition.PG_Operator_Category_ID IN (SELECT DISTINCT Operator_Group_ID FROM PG_Operator_Category_Definition WHERE  IS_PG =1 AND Deleted = 0 AND PG_Operator_Category_ID IN ('#arguments.stForm.PGOperatorCategoryID#' )
		))
		Order by PG_Type.PG_type_ID, PG_Operator_Category_Definition.PG_Operator_Category_ID,
				PG_Operator_Category.Include_In_Other_PG,
				PG_Operator_Category_Definition.Operator_Group_Level_ID,
				PG_Operator_Category_Definition.Operator_Group_ID

		CREATE CLUSTERED INDEX [I_tmp_PG_View_Operator_Members_C] ON [dbo].[##tmp_PG_View_Operator_Members]([Operator_Group_ID],[Operator_Group_Level_ID]) WITH  FILLFACTOR = 90,  PAD_INDEX  ON [PRIMARY]

  </cfquery>
    <cfstoredproc procedure="USP_POPULATE_OPERATOR_PG_MEMBERS" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_TINYINT" dbVarName = "@View_Or_Save" value = "2" null="no">
      <cfprocresult name="qryUSPPopulateOperatorPGMembers">
    </cfstoredproc>

  <cfquery name="qryUpdateCaptureGroup" datasource="#application.datasource#">
     UPDATE CO set Group_Capture_Delta_Flag = 'u' FROM Contract_MAin cm
     inner join Contract_operators CO ON
        CO.Contract_main_Id = Cm.Contract_main_Id
     WHERE cm.deleted = 0 and cm.approved = 1 and CM.Contract_end_Date > getdate()
     and co.Is_Group = 1 and co.Deleted = 0 and Operator_Group_ID  =  '#arguments.stForm.PGOperatorCategoryID#' and ISNULL(Co.Group_Capture_Delta_Flag, '') = ''
  </cfquery>

	<cfquery name="qryCaptureGroup" datasource="#application.datasource#">
		SELECT DISTINCT cm.Contract_Main_ID FROM Contract_MAin cm
     inner join Contract_operators CO ON
        CO.Contract_main_Id = Cm.Contract_main_Id
     WHERE cm.deleted = 0 and cm.approved = 1 and cm.manual_cancel = 0 and CM.Contract_end_Date > getdate()
     and co.Is_Group = 1 and co.Deleted = 0 and Operator_Group_ID  =  '#arguments.stForm.PGOperatorCategoryID#' and ISNULL(Co.Group_Capture_Delta_Flag, '') = 'U'
	</cfquery>

	<cfif (qryCaptureGroup.RecordCount GTE 1)>
		<cfloop query ="qryCaptureGroup">
			<cfstoredproc procedure="CAPTURE_OPERATOR_GROUPS" datasource="#application.datasource#">
				<cfprocparam type="IN" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#qryCaptureGroup.Contract_Main_ID#" null="no">
			</cfstoredproc>
		</cfloop>
	</cfif>
<!--- D34374:Planning Group end date maintenance in group members table START ---->
<cfif len(arguments.stForm.DELMARKEDINEXISTING)>
        <cfquery name="UpdateGroupMembers" datasource="#application.datasource#">
          UPDATE Operator_Group_Members
          SET End_Date = CAST(GETDATE() as DATE), Updated_Bit = 1
          WHERE   Operator_Group_ID =  '#arguments.stForm.PGOPERATORCATEGORYID#'
		  AND End_Date > CAST(GETDATE() as DATE)
		  AND BSA_Operator_ID IN (<cfqueryparam value="#arguments.stForm.DELMARKEDINEXISTING#" cfsqltype="CF_SQL_VARCHAR" list="yes"/>)
		  <!--- End date Group_Members only when operator is no longer a member of the PG.
		  If user is deleting an excluded record, that operator may now become member of the PG, in that case we should not end date it.
		  --->
		  AND NOT EXISTS (
                SELECT 1
                FROM PG_Operator_Members m
                WHERE m.PG_Operator_Category_ID = '#arguments.stForm.PGCUSTOMERCATEGORYID#'
                AND m.BSA_Operator_ID = Operator_Group_Members.BSA_Operator_ID
                AND m.Deleted = 0
        )
        </cfquery>
</cfif>
<!--- D34374:Planning Group end date maintenance in group members table END ---->

     <cfreturn returnValue />
  </cffunction>


<!--- Function to find existing "operator planning group" records --->
  <cffunction name="fnIsPlanningGroupOperatorExist" output="false" returntype="boolean" >
	<cfargument name="PG_Operator_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Operator_ID"	required="true" type="string" />

	<cfset var bPGExist = 0 />

	<cfset useLakebaseForqIsPlanningGroupOperatorExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForqIsPlanningGroupOperatorExist>
	<cftry>
		<cfset qIsPlanningGroupOperatorExist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category_definition", {
				"pg_operator_category_id" = "eq.#arguments.PG_Operator_Category_ID#",
				"operator_group_id" = "eq.#arguments.Group_Operator_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsPlanningGroupOperatorExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsPlanningGroupOperatorExist>
<cfquery name="qIsPlanningGroupOperatorExist" datasource="#application.datasource#">
		SELECT 1
		FROM PG_Operator_Category_Definition
		WHERE PG_Operator_Category_ID = '#arguments.PG_Operator_Category_ID#'
		AND Operator_group_ID = '#arguments.Group_Operator_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

	<cfif qIsPlanningGroupOperatorExist.recordcount>
		<cfset bPGExist = 1 />
	</cfif>

	<cfreturn bPGExist />
</cffunction>

<!--- Function to delete "operator planning group" records --->
<cffunction name="fnDeletePlanningGroupOperator" output="false" returntype="void" >
	<cfargument name="PG_Operator_Category_ID"	required="true" type="string"  />
	<cfargument name="Group_Operator_ID"	required="true" type="string" />
	<cfargument name="UserID"	required="true" type="string" />

	<cfset useLakebaseForqDeletePlanningGroupOperator = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category_definition")>
<cfif useLakebaseForqDeletePlanningGroupOperator>
	<cftry>
		<cfset application.oLakebase.updateRows("pg_operator_category_definition",
			{
				"pg_operator_category_id" = "eq.#arguments.PG_Operator_Category_ID#",
				"operator_group_id" = "eq.#arguments.Group_Operator_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1"
			},
			{
				"deleted" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#arguments.UserID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeletePlanningGroupOperator = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeletePlanningGroupOperator>
<cfquery name="qDeletePlanningGroupOperator" datasource="#application.datasource#">
		UPDATE PG_Operator_Category_Definition
		SET deleted = 1,
			Updated_Date = GetDate(),
			Updated_By =  '#arguments.UserID#'
		WHERE PG_Operator_Category_ID = '#arguments.PG_Operator_Category_ID#'
		AND Operator_group_ID = '#arguments.Group_Operator_ID#'
		AND deleted = 0
		AND Active = 1
	</cfquery>
</cfif>

</cffunction>


<cffunction  name="fnGetOprPGByTypeID" output="false" returntype="Query">

  <cfset useLakebaseForqryGetTopLevelOprPGTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_group_level")>
<cfif useLakebaseForqryGetTopLevelOprPGTypes>
	<cftry>
		<cfset qryGetTopLevelOprPGTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operator_group_level", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"order" = "group_level_desc.asc",
				"select" = "group_level_desc,deleted,created_date,operator_group_level_type_id,updated_date,active,search_sequence_name,operator_group_attribute_table,operator_group_attribute_id_field,operator_group_attribute_master_id_field,operator_group_attribute_name_field,group_level_desc_internal,search_filter_on,operator_group_level_id,is_group_combination,level_id,list_order,operator_group_attribute_number_field,operator_group_attribute_interface_field,is_pg"
			}), "group_level_desc,deleted,created_date,operator_group_level_type_id,updated_date,active,search_sequence_name,operator_group_attribute_table,operator_group_attribute_id_field,operator_group_attribute_master_id_field,operator_group_attribute_name_field,group_level_desc_internal,search_filter_on,operator_group_level_id,is_group_combination,level_id,list_order,operator_group_attribute_number_field,operator_group_attribute_interface_field,is_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetTopLevelOprPGTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetTopLevelOprPGTypes>
<cfquery name="qryGetTopLevelOprPGTypes" datasource="#application.datasource#">
    SELECT
      Group_Level_Desc,
      Deleted,
      Created_Date,
      Operator_Group_Level_Type_ID,
      updated_date,
      Active,
      Search_Sequence_Name,
      Operator_Group_Attribute_Table,
      Operator_Group_Attribute_ID_Field,
      Operator_Group_Attribute_Master_ID_Field,
      Operator_Group_Attribute_Name_Field,
      Group_Level_Desc_Internal,
      Search_Filter_On,
      Operator_Group_Level_ID,
      Is_Group_Combination,
      Level_ID,
      List_Order,
      Operator_Group_Attribute_Number_Field,
      Operator_Group_Attribute_Interface_Field,
      Is_PG
    FROM
      Operator_Group_Level
    WHERE
      Active = 1 AND
      Deleted = 0
      ORDER BY Group_Level_Desc ASC
   </cfquery>
</cfif>
  <cfreturn qryGetTopLevelOprPGTypes />

</cffunction>



<cffunction name="fnOprGrpTemSel" output="false" returntype="Query">
    <cfargument name="PGOperatorCategoryID" type="string" required="true" />
     <cfset useLakebaseForqryOprGrpTemSel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_group_template_selection")>
<cfif useLakebaseForqryOprGrpTemSel>
	<cftry>
		<cfset qryOprGrpTemSel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operator_group_template_selection", {
				"operator_group_id" = "eq.#arguments.PGOperatorCategoryID#",
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "operator_group_template_selection_id,template_id,operator_group_level_id,operator_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
			}), "operator_group_template_selection_id,template_id,operator_group_level_id,operator_group_id,active,deleted,created_date,updated_date,created_by,updated_by,pg_flag,updated_from,template_filters_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryOprGrpTemSel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryOprGrpTemSel>
<cfquery name="qryOprGrpTemSel" datasource="#application.datasource#">
        SELECT
          Operator_Group_Template_Selection_ID,
          Template_ID,
          Operator_Group_Level_ID,
          Operator_Group_ID,
          Active,
          Deleted,
          Created_Date,
          Updated_Date,
          Created_By,
          Updated_BY,
          PG_Flag,
          Updated_From,
          Template_Filters_Id
        FROM
          Operator_Group_Template_Selection
        WHERE Operator_Group_ID = '#arguments.PGOperatorCategoryID#'
        AND Active = 1
        AND Deleted = 0
      </cfquery>
</cfif>
       <cfreturn qryOprGrpTemSel />
  </cffunction>

  <cffunction name="fnMicroMemberIncludeList" output="false" returntype="Query">
   <cfargument name="PGOperatorCategoryID" type="string" required="true" />
      <cfquery name="qryMicoMembersIncludeList" datasource="#application.datasource#">
        SELECT
          PG_Operator_Category.PG_Operator_Category_ID,
  		    PG_Operator_Category.PG_Operator_Category_Code,
  		    PG_Operator_Category.PG_Operator_Category_Name,
  		    BSA_Operator.BSA_Operator_ID,
  		   -- BSA_Operator.Shr_Ship_to,
  		    BSA_Operator.Operator_Name
        FROM
          PG_Operator_Members
        INNER JOIN PG_Operator_Category
        ON		PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Members.PG_Operator_Category_ID
        INNER JOIN BSA_Operator
        ON		BSA_Operator.BSA_Operator_ID = PG_Operator_Members.BSA_Operator_ID
        WHERE PG_Operator_Members.PG_Operator_Category_ID IN ('#arguments.PGOperatorCategoryID#')
      </cfquery>
    <cfreturn qryMicoMembersIncludeList />
  </cffunction>




  <!--- Operator Planning Group Queries end --->


	<!--- D29686: Program Wizard and Segement Filters for Distributor  --->
	<cffunction name="IsSystemCheck" output="false" returntype="boolean">
		<cfargument name="pggrouptype" type="numeric" required="true" />
		<cfargument name="pgtypeid" type="numeric" required="true" />

		<cfscript>
			var bIsSystemCheck = 0;
		</cfscript>

		<cfset useLakebaseForqIsSystem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_type")>
<cfif useLakebaseForqIsSystem>
	<cftry>
		<cfset qIsSystem = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_type", {
				"deleted" = "eq.0",
				"pg_group_type" = "eq.#arguments.pggrouptype#",
				"pg_type_id" = "eq.#arguments.pgtypeid#",
				"is_system" = "eq.1",
				"select" = "is_system"
			}), "is_system"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsSystem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsSystem>
<cfquery name="qIsSystem" datasource="#application.datasource#">
			SELECT  Is_System
        	FROM 	pg_type
        	WHERE 	Deleted = 0
        	AND 	pg_group_type = '#arguments.pggrouptype#'
        	AND 	pg_type_id = '#arguments.pgtypeid#'
			AND 	Is_System = 1
		</cfquery>
</cfif>

		<cfif qIsSystem.RecordCount>
			<cfset bIsSystemCheck = 1 />
		</cfif>

       <cfreturn bIsSystemCheck />

	</cffunction>
 <!--- D29686: Program Wizard and Segement Filters for Distributor  --->

	<cffunction name="fnGetSystemPGTypes" output="false" returntype="Query">
    	<cfargument name="GroupType" required="true" type="string"  />

		<cfquery name="qGetSystemPGTypes" datasource="#application.datasource#">
			SELECT	PG_Type_ID,
					PG_Type_Code,
					PG_Type_Name,
					PG_Group_Type,
					Active,
					Deleted
			FROM	PG_Type
			WHERE 	Active = 1
			AND   	PG_Group_Type = <cfqueryparam value="#arguments.GroupType#" cfsqltype="CF_SQL_INTEGER"/>
			AND   	Deleted = 0
			AND   	Is_System = 1
			ORDER BY PG_Type_Name
    	</cfquery>
		<cfreturn qGetSystemPGTypes />
	</cffunction>
<!--- pg performance --->
<cffunction name="singleProductGroupInfo" returntype="struct" access="remote" output="no">

	<cfargument name="page" required="true" />
	<cfargument name="pageSize" required="true" />
	<cfargument name="gridsortcolumn" required="no" />
	<cfargument name="gridsortdirection" required="no" />
	<cfargument name="filter" required="false" default="" />
	<cfargument name="ID" required="true" type="string" >
	<cfargument name="bus_segment" required="true" default="1">


	<cfif arguments.gridsortcolumn eq "">
		<cfset arguments.gridsortcolumn = "Group_Name" />
		<cfset arguments.gridsortdirection = "asc" />
	</cfif>

	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Product_Category_ID" value = "#arguments.ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Keyword" value = "#arguments.filter#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderBy" value="ASC" null="no">
	    <cfprocresult name="qryPGProductCategoryDefinitionByID">
	</cfstoredproc>
<cfif #arguments.bus_segment#>
   <cfset qryFinalQuery = QueryNew("Group_Number, Group_Desc, Group_Name, Business_Unit_Desc, Inclusion_Exclusion","varchar,varchar,varchar,varchar,varchar") />
<cfelse>
   <cfset qryFinalQuery = QueryNew("Group_Number, Group_Desc, Group_Name, Inclusion_Exclusion","varchar,varchar,varchar,varchar") />
</cfif>
   <cfloop query="qryPGProductCategoryDefinitionByID">
      <cfset QueryAddRow(qryFinalQuery) />
      <cfset QuerySetCell(qryFinalQuery, "Group_Number", "#qryPGProductCategoryDefinitionByID.Group_Number#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Desc", "#qryPGProductCategoryDefinitionByID.Group_Desc#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Name", "#qryPGProductCategoryDefinitionByID.Group_Name#") />
	  <cfif arguments.bus_segment>
	  <cfset QuerySetCell(qryFinalQuery, "Business_Unit_Desc", "#qryPGProductCategoryDefinitionByID.Business_Unit_Desc#") />
	  </cfif>
  <cfif qryPGProductCategoryDefinitionByID.Inclusion_Exclusion EQ "true">
  	  <cfset in_check = "checked">
<cfelse>
	<cfset in_check = "">
  </cfif>

  <cfif qryPGProductCategoryDefinitionByID.Inclusion_Exclusion EQ "false">
  	  <cfset ex_check = "checked">
<cfelse>
	<cfset ex_check = "">
  </cfif>
	  <cfset IN_OUT 	= '<input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="1" '& #in_check# & '>'
	  								& 'Include' &
	  					  '<input type="radio" name="rdoIncExc_#Replace(qryPGProductCategoryDefinitionByID.Product_Group_ID,'-','_','ALL')#" value="0" '& #ex_check# & '>'
									& 'Exclude'
	  />

	  <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "#IN_OUT#")/>

	   <!---<cfset DeActivate = '<img src="/images/pg_cancel.png" style="margin-left:20px" onclick="deactivate('& '''#qppg.PG_Product_Category_ID#''' &');">' />--->
    </cfloop>

	<cfreturn QUERYCONVERTFORGRID(qryFinalQuery, ARGUMENTS.page, ARGUMENTS.pagesize) />

</cffunction>

<cffunction name="TypeMembers" returntype="Query" >
	<cfargument name="PGTypeID" required="true" type="string" >
	<cfargument name="PGGroup" required="true" type="numeric" >
		<cfif #arguments.PGGroup# EQ 1>
<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
    SELECT
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code AS PG_Type_ID,
        PG_Product_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Product_Category
    WHERE Active = 1 AND
          Deleted = 0 AND
          PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
<cfelseif #arguments.PGGroup# EQ 2>
	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
	SELECT
        PG_Customer_Category_ID,
        PG_Type_ID,
        PG_Customer_Category_Code AS PG_Type_ID,
        PG_Customer_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Customer_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
<cfelseif #arguments.PGGroup# EQ 3>
	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
      SELECT
        PG_Operator_Category_ID,
        PG_Type_ID,
        PG_Operator_Category_Code AS PG_Type_ID,
        PG_Operator_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Operator_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
    </cfquery>
</cfif>
<cfreturn qryProductPGByTypeID>
</cffunction>


<!--- Group Members Queries START --->
<cffunction name="TypeGroupInfo" returntype="struct" access="remote" output="no">

	<cfargument name="page" required="true" />
	<cfargument name="pageSize" required="true" />
	<cfargument name="gridsortcolumn" required="no" />
	<cfargument name="gridsortdirection" required="no" />
	<cfargument name="filter" required="false" default="" />
	<cfargument name="PGTypeID" required="true" type="string" >
	<cfargument name="PGGroup" required="true" type="numeric" >

	<cfif arguments.gridsortcolumn eq "">
		<cfset arguments.gridsortcolumn = "PG_Product_Category_Name" />
		<cfset arguments.gridsortdirection = "asc" />
	</cfif>
<cfif #arguments.PGGroup# EQ 1>
	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
    SELECT
        PG_Product_Category_ID,
        PG_Type_ID,
        PG_Product_Category_Code AS PG_Type_ID,
        PG_Product_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Product_Category
    WHERE Active = 1 AND
          Deleted = 0 AND
          PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
		  <cfif len(arguments.filter)>
		  	  AND ((PG_Product_Category_Code like '%#arguments.filter#%') OR (PG_Product_Category_Name like '%#arguments.filter#%'))
		  </cfif>
    </cfquery>
<cfelseif #arguments.PGGroup# EQ 2>
	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
	SELECT
        PG_Customer_Category_ID,
        PG_Type_ID,
        PG_Customer_Category_Code AS PG_Type_ID,
        PG_Customer_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Customer_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
		  <cfif len(arguments.filter)>
		  	  AND ((PG_Customer_Category_Code like '%#arguments.filter#%') OR (PG_Customer_Category_Name like '%#arguments.filter#%'))
		  </cfif>
    </cfquery>
<cfelseif #arguments.PGGroup# EQ 3>
	<cfquery name="qryProductPGByTypeID" datasource="#application.datasource#">
      SELECT
        PG_Operator_Category_ID,
        PG_Type_ID,
        PG_Operator_Category_Code AS PG_Type_ID,
        PG_Operator_Category_Name AS PG_Name,
        Active,
        Deleted,
        Created_Date,
        Updated_Date,
        Created_By,
        Updated_BY,
        Include_In_Other_PG
    FROM PG_Operator_Category
    WHERE
        Active = 1 AND
        Deleted = 0 AND
        PG_Type_ID = <cfqueryparam value="#arguments.PGTypeID#" cfsqltype="CF_SQL_INTEGER"/>
		  <cfif len(arguments.filter)>
		  	  AND ((PG_Operator_Category_Code like '%#arguments.filter#%') OR (PG_Product_Category_Name like '%#arguments.filter#%'))
		  </cfif>
    </cfquery>
</cfif>
		<cfreturn QUERYCONVERTFORGRID(qryProductPGByTypeID, ARGUMENTS.page, ARGUMENTS.pagesize) />

</cffunction>

<cffunction name="ProductGroupInfo" returntype="struct" access="remote" output="no">

	<cfargument name="page" required="true" />
	<cfargument name="pageSize" required="true" />
	<cfargument name="gridsortcolumn" required="no" />
	<cfargument name="gridsortdirection" required="no" />
	<cfargument name="filter" required="false" default="" />
	<cfargument name="ID" required="true" type="string" >


	<cfif arguments.gridsortcolumn eq "">
		<cfset arguments.gridsortcolumn = "Group_Name" />
		<cfset arguments.gridsortdirection = "asc" />
	</cfif>

	<cfstoredproc procedure="Get_Product_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Product_Category_ID" value = "#arguments.ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Keyword" value = "#arguments.filter#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderBy" value="ASC" null="no">
	    <cfprocresult name="qryPGProductCategoryDefinitionByID">
	</cfstoredproc>


   <cfset qryFinalQuery = QueryNew("Group_Desc, Group_Number, Group_Name, Inclusion_Exclusion, Business_Unit_Desc","varchar,varchar,varchar,varchar,varchar") />
   <cfloop query="qryPGProductCategoryDefinitionByID">
      <cfset QueryAddRow(qryFinalQuery) />
      <cfset QuerySetCell(qryFinalQuery, "Group_Desc", "#qryPGProductCategoryDefinitionByID.Group_Desc#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Number", "#qryPGProductCategoryDefinitionByID.Group_Number#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Name", "#qryPGProductCategoryDefinitionByID.Group_Name#") />
	  <cfif qryPGProductCategoryDefinitionByID.Inclusion_Exclusion EQ "true">
      <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Included")/>
	  <cfelseif qryPGProductCategoryDefinitionByID.Inclusion_Exclusion Eq "false">
	  <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Excluded")/>
	  </cfif>
      <cfset QuerySetCell(qryFinalQuery, "Business_Unit_Desc", "#qryPGProductCategoryDefinitionByID.Business_Unit_Desc#") />
   </cfloop>





	<cfreturn QUERYCONVERTFORGRID(qryFinalQuery, ARGUMENTS.page, ARGUMENTS.pagesize) />

</cffunction>

<cffunction name="CustomerGroupInfo" returntype="struct" access="remote" output="no">

	<cfargument name="page" required="true" />
	<cfargument name="pageSize" required="true" />
	<cfargument name="gridsortcolumn" required="no" />
	<cfargument name="gridsortdirection" required="no" />
	<cfargument name="filter" required="false" default="" />
	<cfargument name="ID" required="true" type="string" >


	<cfif arguments.gridsortcolumn eq "">
		<cfset arguments.gridsortcolumn = "Group_Name" />
		<cfset arguments.gridsortdirection = "asc" />
	</cfif>

	<cfstoredproc procedure="Get_Customer_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Customer_Category_ID" value = "#arguments.ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Keyword" value = "#arguments.filter#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderBy" value="ASC" null="no">
		<cfprocresult name="qryPGCustomerCategoryDefinitionByID">
	</cfstoredproc>


   <cfset qryFinalQuery = QueryNew("Group_Desc, Group_Number, Group_Name, Inclusion_Exclusion, Business_Unit_Desc","varchar,varchar,varchar,varchar,varchar") />
   <cfloop query="qryPGCustomerCategoryDefinitionByID">
      <cfset QueryAddRow(qryFinalQuery) />
      <cfset QuerySetCell(qryFinalQuery, "Group_Desc", "#qryPGCustomerCategoryDefinitionByID.Group_Desc#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Number", "#qryPGCustomerCategoryDefinitionByID.Group_Number#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Name", "#qryPGCustomerCategoryDefinitionByID.Group_Name#") />
	  <cfif qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion EQ "true">
      <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Included")/>
	  <cfelseif qryPGCustomerCategoryDefinitionByID.Inclusion_Exclusion Eq "false">
	  <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Excluded")/>
	  </cfif>
      <cfset QuerySetCell(qryFinalQuery, "Business_Unit_Desc", "#qryPGCustomerCategoryDefinitionByID.Business_Unit_Desc#") />
   </cfloop>





	<cfreturn QUERYCONVERTFORGRID(qryFinalQuery, ARGUMENTS.page, ARGUMENTS.pagesize) />

</cffunction>

<cffunction name="OperatorGroupInfo" returntype="struct" access="remote" output="no">

	<cfargument name="page" required="true" />
	<cfargument name="pageSize" required="true" />
	<cfargument name="gridsortcolumn" required="no" />
	<cfargument name="gridsortdirection" required="no" />
	<cfargument name="filter" required="false" default="" />
	<cfargument name="ID" required="true" type="string" >

	<cfif arguments.gridsortcolumn eq "">
		<cfset arguments.gridsortcolumn = "Group_Name" />
		<cfset arguments.gridsortdirection = "asc" />
	</cfif>

	<cfstoredproc procedure="Get_Operator_Group_Info_For_PG" datasource="#application.datasource#">
	    <cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Operator_Category_ID" value = "#arguments.ID#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@Keyword" value = "#arguments.filter#" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderByField" value="Group_Name" null="no">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@OrderBy" value="ASC" null="no">
		<cfprocresult name="qryPGOperatorCategoryDefinitionByID">
	</cfstoredproc>

   <cfset qryFinalQuery = QueryNew("Group_Desc, Group_Number, Group_Name, Inclusion_Exclusion","varchar,varchar,varchar,varchar") />
   <cfloop query="qryPGOperatorCategoryDefinitionByID">
      <cfset QueryAddRow(qryFinalQuery) />
      <cfset QuerySetCell(qryFinalQuery, "Group_Desc", "#qryPGOperatorCategoryDefinitionByID.Group_Desc#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Number", "#qryPGOperatorCategoryDefinitionByID.Group_Number#") />
      <cfset QuerySetCell(qryFinalQuery, "Group_Name", "#qryPGOperatorCategoryDefinitionByID.Group_Name#") />
	  <cfif qryPGOperatorCategoryDefinitionByID.Inclusion_Exclusion EQ "true">
      <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Included")/>
	  <cfelseif qryPGOperatorCategoryDefinitionByID.Inclusion_Exclusion Eq "false">
	  <cfset QuerySetCell(qryFinalQuery, "Inclusion_Exclusion", "Excluded")/>
	  </cfif>
   </cfloop>

	<cfreturn QUERYCONVERTFORGRID(qryFinalQuery, ARGUMENTS.page, ARGUMENTS.pagesize) />

</cffunction>
<!--- Group Members Queries END --->


<cffunction name="getBudgetsForPlanningGroup" returntype="query" access="public" output="no">
 <cfargument name="planningGroupType" required="true" type="numeric" />
 <cfargument name="PGCategoryID" required="true" type="string" />

<cfquery name="qryBudgetsForPlanningGroup" datasource="#application.datasource#">
	<!--- PRODUCT --->
	<cfif arguments.planningGroupType eq 1>
		SELECT
			PG_Product_Category.PG_product_category_Code As [PG Code],PG_Product_Category.PG_product_category_name As [PG Name],
			Budget.budget_code As [Budget Code],Budget.budget_Desc As [Budget Description]
		FROM dbo.Budget_Product_Rate
			INNER JOIN dbo.Budget
			ON Budget_Product_Rate.Budget_ID = Budget.Budget_ID
			INNER JOIN dbo.PG_Product_Category
			ON PG_Product_Category.PG_Product_Category_ID = Budget_Product_Rate.Product_Group_ID
		WHERE
			Budget.Deleted = 0
		AND PG_Product_Category.PG_Product_Category_ID = '#arguments.PGCategoryID#'

	<!--- CUSTOMER --->
	<cfelseif  arguments.planningGroupType eq 2>
		SELECT
			PG_Customer_Category.PG_customer_category_Code As [PG Code],PG_Customer_Category.PG_customer_category_name As [PG Name],
			Budget.budget_code As [Budget Code],Budget.budget_Desc As [Budget Description]
		FROM dbo.Budget_Distributor
			INNER JOIN dbo.Budget
			ON Budget_Distributor.Budget_ID = Budget.Budget_ID
			INNER JOIN dbo.PG_Customer_Category
			ON PG_Customer_Category.PG_Customer_Category_ID = Budget_Distributor.Distributor_Group_ID
		WHERE
			Budget.Deleted = 0
		AND Budget_Distributor.Deleted = 0
		AND PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCategoryID#'
	</cfif>
</cfquery>


<!--- SINCE BUDGET DOES NOT FOR OPERATORS, WE DO NOT HAVE A CONDITION FOR OPERATORS --->

<cfreturn qryBudgetsForPlanningGroup>

</cffunction>


<cffunction name="getVolumePlansForPlanningGroup" returntype="query" access="public" output="no">
 <cfargument name="planningGroupType" required="true" type="numeric" />
 <cfargument name="PGCategoryID" required="true" type="string" />

<cfquery name="qryVolumePlansForPlanningGroup" datasource="#application.datasource#">
	<!--- PRODUCT --->
	<cfif arguments.planningGroupType eq 1>
		SELECT
			PG_Product_Category.PG_product_category_Code As [PG Code],PG_Product_Category.PG_product_category_name As [PG Name],
			VF_plan.VF_Plan_Number As [Volume Plan Num],VF_plan.VF_Plan_Desc As [Volume Plan Description]
		FROM dbo.VF_Planning_Groups
			INNER join dbo.VF_plan
			ON VF_Planning_Groups.VF_plan_ID = VF_plan.VF_plan_ID
			INNER JOIN dbo.PG_Product_Category
			ON PG_Product_Category.PG_Product_Category_ID = VF_Planning_Groups.PG_Product_Category_ID
		WHERE
			VF_plan.Deleted = 0
		AND VF_Planning_Groups.deleted = 0
		AND PG_Product_Category.PG_Product_Category_ID = '#arguments.PGCategoryID#'

	<!--- CUSTOMER --->
	<cfelseif  arguments.planningGroupType eq 2>
		SELECT
			PG_Customer_Category.PG_customer_category_Code As [PG Code],PG_Customer_Category.PG_customer_category_name As [PG Name],
			VF_plan.VF_Plan_Number As [Volume Plan Num],VF_plan.VF_Plan_Desc As [Volume Plan Description]
		FROM dbo.VF_Distributor_Planning_Groups
			INNER join dbo.VF_plan
			ON VF_Distributor_Planning_Groups.VF_plan_ID = VF_plan.VF_plan_ID
			INNER JOIN dbo.PG_Customer_Category
			ON PG_Customer_Category.PG_Customer_Category_ID = VF_Distributor_Planning_Groups.PG_Customer_Category_ID
		WHERE
			VF_plan.Deleted = 0
		AND VF_Distributor_Planning_Groups.deleted = 0
		AND PG_Customer_Category.PG_Customer_Category_ID =  '#arguments.PGCategoryID#'
	</cfif>
</cfquery>

<!--- SINCE VOLUME PLAN (FORECAST) DOES NOT FOR OPERATORS, WE DO NOT HAVE A CONDITION FOR OPERATORS --->

<cfreturn qryVolumePlansForPlanningGroup>

</cffunction>


<cffunction name="getProgramsForPlanningGroup" returntype="query" access="public" output="no">
 <cfargument name="planningGroupType" required="true" type="numeric" />
 <cfargument name="PGCategoryID" required="true" type="string" />

<cfquery name="qryProgramsForPlanningGroup" datasource="#application.datasource#">
	<!--- PRODUCT --->
	<cfif arguments.planningGroupType eq 1>
		SELECT
			PG_Product_Category.PG_product_category_Code As [PG Code],PG_Product_Category.PG_product_category_name As [PG Name],
			Contract_Main.Contract_Number As [Contract Number],Contract_Main.Contract_Title As [Contract Title]
		FROM dbo.Contract_products
			INNER JOIN Contract_Main
			ON Contract_products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			INNER JOIN dbo.PG_Product_Category ON CAST(Contract_products.Product_group_ID AS VARCHAR(50))  = CAST(PG_Product_Category.PG_Product_Category_ID AS VARCHAR(50))
		WHERE
			Contract_Main.Deleted = 0
		AND Contract_products.Deleted = 0
		AND Contract_products.Product_group_ID IS NOT NULL
		AND Contract_products.Is_Group = 1
		AND PG_Product_Category.PG_Product_Category_ID = '#arguments.PGCategoryID#'

	<!--- CUSTOMER --->
	<cfelseif  arguments.planningGroupType eq 2>
		SELECT
			PG_Customer_Category.PG_customer_category_Code As [PG Code],PG_Customer_Category.PG_customer_category_name As [PG Name],
			Contract_Main.Contract_Number As [Contract Number],Contract_Main.Contract_Title As [Contract Title]
		FROM dbo.Contract_distributors
			INNER JOIN Contract_Main
			ON Contract_distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			INNER JOIN dbo.PG_Customer_Category ON CAST(Contract_distributors.Distributor_group_ID AS VARCHAR(50)) = CAST(PG_Customer_Category.PG_Customer_Category_ID AS VARCHAR(50))
		WHERE
			Contract_Main.Deleted = 0
		AND Contract_distributors.Deleted = 0
		AND Contract_distributors.Distributor_group_ID IS NOT NULL
		AND Contract_distributors.Is_Group = 1
		AND Contract_distributors.Captured_From_Group = 0
		AND PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCategoryID#'

	<!--- OPERATOR --->
	<cfelseif  arguments.planningGroupType eq 3>
		SELECT
			PG_Operator_Category.PG_operator_category_Code As [PG Code],PG_Operator_Category.PG_operator_category_name As [PG Name],
			Contract_Main.Contract_Number As [Contract Number], Contract_Main.Contract_Title As [Contract Title]
		FROM dbo.Contract_Operators
			INNER JOIN Contract_Main
			ON Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
			INNER JOIN dbo.PG_Operator_Category ON CAST(Contract_Operators.Operator_group_ID AS VARCHAR(50)) = CAST(PG_Operator_Category.PG_Operator_Category_ID AS VARCHAR(50))
		WHERE
			Contract_Main.Deleted = 0
		AND Contract_Operators.Deleted = 0
		AND Contract_Operators.Operator_group_ID IS NOT NULL
		AND Contract_Operators.Is_Group = 1
		AND PG_Operator_Category.PG_Operator_Category_ID = '#arguments.PGCategoryID#'
	</cfif>
</cfquery>

<cfreturn qryProgramsForPlanningGroup>

</cffunction>


<cffunction name="getTemplatesForPlanningGroup" returntype="query" access="public" output="no">
 <cfargument name="planningGroupType" required="true" type="numeric" />
 <cfargument name="PGCategoryID" required="true" type="string" />

<cfquery name="qryTemplatesForPlanningGroup" datasource="#application.datasource#">
	<!--- PRODUCT --->
	<cfif arguments.planningGroupType eq 1>
		SELECT
			pgpc.PG_Product_category_Code As [PG Code], pgpc.PG_product_category_name As [PG Name],
			t.Generic_Type As [Program Generic Type], t.Created_Type As [Program Created Type]
		FROM  Program_Control_Panel_Options t
			INNER JOIN Group_Template gt
			ON          gt.Template_ID =  t.First_Parent_ID
			AND         gt.Active = 1
			AND         gt.Deleted = 0
			<!--- product--->
			AND         gt.PG_Group_Type = 1
			AND         gt.Allow_Filter = 1 -- If template is filtered on a group
			AND         gt.PG_Flag = 1
			<!--- It is better to not use "deleted = 0" for "PG_Type" table --->
			INNER JOIN PG_Type pg
			ON          pg.PG_Type_ID = gt.Group_Level_ID
			AND         pg.Is_System = 1
			INNER JOIN Template_Filters tf
			ON          tf.Template_Id = t.ProgramControl_Panel_Options_ID
			AND	    tf.deleted = 0
			INNER JOIN Product_Group_Template_Selection pgts
			ON          pgts.Template_ID = t.First_Parent_ID
			AND         pgts.Template_Filters_Id = tf.Template_Filters_Id
			AND         pgts.Product_Group_Level_ID = gt.Group_Level_ID
			AND         pgts.Active = 1
			AND         pgts.Deleted = 0
			AND         pgts.Product_Group_ID != 'undefined'
			INNER JOIN PG_Product_Category pgpc
			ON          pgpc.PG_Product_Category_ID = pgts.Product_Group_ID
		WHERE
			pgpc.PG_Product_Category_ID = '#arguments.PGCategoryID#'

	<!--- CUSTOMER --->
	<cfelseif  arguments.planningGroupType eq 2>
		SELECT
			pgcc.PG_customer_category_Code As [PG Code], pgcc.PG_customer_category_name As [PG Name],
			t.Generic_Type As [Program Generic Type], t.Created_Type As [Program Created Type]
		FROM  Program_Control_Panel_Options t
			INNER JOIN Group_Template gt
			ON          gt.Template_ID =  t.First_Parent_ID
			AND         gt.Active = 1
			AND         gt.Deleted = 0
			<!--- customer--->
			AND         gt.PG_Group_Type = 2
			AND         gt.Allow_Filter = 1 -- If template is filtered on a group
			AND         gt.PG_Flag = 1
			<!--- It is better to not use "deleted = 0" for "PG_Type" table --->
			INNER JOIN PG_Type pg
			ON          pg.PG_Type_ID = gt.Group_Level_ID
			AND         pg.Is_System = 1
			INNER JOIN Template_Filters tf
			ON          tf.Template_Id = t.ProgramControl_Panel_Options_ID
			AND	    tf.deleted = 0
			INNER JOIN Customer_Group_Template_Selection cgts
			ON          cgts.Template_ID = t.First_Parent_ID
			AND         cgts.Template_Filters_Id = tf.Template_Filters_Id
			AND         cgts.Distributor_Group_Level_ID = gt.Group_Level_ID
			AND         cgts.Active = 1
			AND         cgts.Deleted = 0
			AND         cgts.Distributor_Group_ID != 'undefined'
			INNER JOIN PG_Customer_Category pgcc
			ON          pgcc.PG_Customer_Category_ID = cgts.Distributor_Group_ID
		WHERE
			pgcc.PG_Customer_Category_ID = '#arguments.PGCategoryID#'

	<!--- OPERATOR --->
	<cfelseif  arguments.planningGroupType eq 3>
		SELECT
			pgoc.PG_operator_category_Code As [PG Code], pgoc.PG_operator_category_name As [PG Name],
			t.Generic_Type As [Program Generic Type], t.Created_Type As [Program Created Type]
		FROM  Program_Control_Panel_Options t
			INNER JOIN Group_Template gt
			ON          gt.Template_ID =  t.First_Parent_ID
			AND         gt.Active = 1
			AND         gt.Deleted = 0
			<!--- operator --->
			AND         gt.PG_Group_Type = 3
			AND         gt.Allow_Filter = 1 -- If template is filtered on a group
			AND         gt.PG_Flag = 1
			<!--- It is better to not use "deleted = 0" for "PG_Type" table --->
			INNER JOIN PG_Type pg
			ON          pg.PG_Type_ID = gt.Group_Level_ID
			AND         pg.Is_System = 1
			INNER JOIN Template_Filters tf
			ON          tf.Template_Id = t.ProgramControl_Panel_Options_ID
			AND	    tf.deleted = 0
			INNER JOIN Operator_Group_Template_Selection ogts
			ON          ogts.Template_ID = t.First_Parent_ID
			AND         ogts.Template_Filters_Id = tf.Template_Filters_Id
			AND         ogts.Operator_Group_Level_ID = gt.Group_Level_ID
			AND         ogts.Active = 1
			AND         ogts.Deleted = 0
			AND         ogts.Operator_Group_ID != 'undefined'
			INNER JOIN PG_Operator_Category pgoc
			ON          pgoc.PG_Operator_Category_ID = ogts.Operator_Group_ID
		WHERE
			pgoc.PG_Operator_Category_ID = '#arguments.PGCategoryID#'
	</cfif>
</cfquery>

<cfreturn qryTemplatesForPlanningGroup>

</cffunction>


<cffunction name="PG_No_Members_Excel" returntype="Query" >
	<cfargument name="Category" required="true" type="numeric" default="1" >
	<cfargument name="Active" required="true" type="numeric" default="1" >
<cfquery name="PGNoMembersExcel" datasource="#application.datasource#">
		<cfif arguments.category eq 1>
									SELECT     	 	PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Product_Category.PG_Product_Category_Name
									FROM  	  		PG_Type
									INNER JOIN 	PG_Product_Category
									ON          		PG_Type.PG_Type_ID = PG_Product_Category.PG_Type_ID
									AND         		PG_Product_Category.Deleted = 0
									LEFT JOIN 		PG_Product_Members
									ON          			PG_Product_Members.PG_Product_Category_ID = PG_Product_Category.PG_Product_Category_ID
									AND         		PG_Product_Members.Deleted = 0
									WHERE 			PG_Type.Deleted = 0
									AND         		PG_Product_Members.PG_Product_Category_ID is null

		<cfelseif arguments.category eq 2>
									SELECT      PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Customer_Category.PG_Customer_Category_Name
									FROM  PG_Type
									inner join PG_Customer_Category
									on          PG_Type.PG_Type_ID = PG_Customer_Category.PG_Type_ID
									and         PG_Customer_Category.Deleted = 0
									left join PG_Customer_Members
									on          PG_Customer_Members.PG_Customer_Category_ID = PG_Customer_Category.PG_Customer_Category_ID
									and         PG_Customer_Members.Deleted = 0
									where PG_Type.Deleted = 0
									and         PG_Customer_Members.PG_Customer_Category_ID is null

		<cfelseif arguments.category eq 3>
									SELECT      PG_Type_Code, PG_Type_Name, PG_Group_Type, PG_Type.Active, PG_Operator_Category.PG_Operator_Category_Name
									FROM  PG_Type
									inner join PG_Operator_Category
									on          PG_Type.PG_Type_ID = PG_Operator_Category.PG_Type_ID
									and         PG_Operator_Category.Deleted = 0
									left join PG_Operator_Members
									on          PG_Operator_Members.PG_Operator_Category_ID = PG_Operator_Category.PG_Operator_Category_ID
									and         PG_Operator_Members.Deleted = 0
									where PG_Type.Deleted = 0
									and         PG_Operator_Members.PG_Operator_Category_ID is null

		</cfif>
</cfquery >
<cfreturn PGNoMembersExcel />
</cffunction>

<cffunction name="Volume_Forecast_Duplicates_Excel" returntype="Query" >
	<cfargument name="Category" required="true" type="numeric" default="1" >
<cfquery name="VolumeForecastDuplicates" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products') IS NOT NULL
						DROP TABLE ##tmp_plan_products
						IF OBJECT_ID('tempdb..##tmp_plan_product_dups') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products_distributors') IS NOT NULL
						DROP TABLE ##tmp_plan_products_distributors
						IF OBJECT_ID('tempdb..##tmp_plan_product_dist_dups_final') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dist_dups_final
<cfif arguments.category eq 1>
										SELECT	p.VF_Plan_ID,
														p.VF_Plan_Desc,
														c.VF_Class_Desc,
														bs.Business_Unit_Desc,
														vfpg.PG_Product_Category_ID,
														pgpm.BSA_Foodservice_Items_Master_ID
										INTO		##tmp_dups
										FROM		VF_Plan p
										INNER JOIN  VF_Class c
										ON			c.VF_Class_ID = p.VF_Plan_Class_ID
										AND		c.Deleted = 0
										AND		c.Active = 1 --- Only for active class
										LEFT JOIN Business_Segment bs
										ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
										INNER JOIN VF_Planning_Groups vfpg
										ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
										AND		vfpg.Deleted = 0
										INNER JOIN PG_Product_Members pgpm
										ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
										AND		pgpm.Deleted = 0

										INNER JOIN (

										SELECT	p.VF_Plan_ID, pgpm.BSA_Foodservice_Items_Master_ID, COUNT(*) as cnt
										FROM		VF_Plan p
										INNER JOIN  VF_Class c
										ON			c.VF_Class_ID = p.VF_Plan_Class_ID
										AND		c.Deleted = 0
										AND		c.Active = 1 -- Only for active class
										INNER JOIN VF_Planning_Groups vfpg -- For distributor replace with VF_Distributor_Planning_Groups
										ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
										AND		vfpg.Deleted = 0
										INNER JOIN PG_Product_Members pgpm
										ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
										AND		pgpm.Deleted = 0
										WHERE	p.Deleted = 0
										GROUP BY p.VF_Plan_ID, pgpm.BSA_Foodservice_Items_Master_ID
										HAVING COUNT(*) > 1

										) AS 	Duplicates

									ON			Duplicates.VF_Plan_ID = p.VF_Plan_ID
									AND		Duplicates.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
									WHERE	p.Deleted = 0


									SELECT	dup1.VF_Plan_ID,
													dup1.VF_Plan_Desc,
													dup1.VF_Class_Desc,
													dup1.Business_Unit_Desc,
													pg1.PG_Product_Category_Name AS pg1,
													pg2.PG_Product_Category_Name AS pg2,
													im.Item,
													im.Description
									FROM		##tmp_dups dup1
									INNER JOIN ##tmp_dups dup2
									ON			dup1.VF_Plan_ID = dup2.VF_Plan_ID
									AND		dup1.BSA_Foodservice_Items_Master_ID = dup2.BSA_Foodservice_Items_Master_ID
									AND		CAST(dup1.PG_Product_Category_ID as varchar(50)) > CAST(dup2.PG_Product_Category_ID as varchar(50))
									INNER JOIN BSA_Foodservice_Items_Master im
									ON			im.BSA_Foodservice_Items_Master_ID = dup1.BSA_Foodservice_Items_Master_ID
									INNER JOIN PG_Product_Category pg1
									ON			pg1.PG_Product_Category_ID = dup1.PG_Product_Category_ID
									INNER JOIN PG_Product_Category pg2
									ON			pg2.PG_Product_Category_ID = dup2.PG_Product_Category_ID

<cfelseif arguments.category eq 2>
									SELECT	p.VF_Plan_ID,
													p.VF_Plan_Desc,
													c.VF_Class_Desc,
													bs.Business_Unit_Desc,
													vfpg.PG_Customer_Category_ID,
													pgpm.BSA_Foodservice_Customers_ID
									INTO		##tmp_dups
									FROM		VF_Plan p
									INNER JOIN  VF_Class c
									ON			c.VF_Class_ID = p.VF_Plan_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1
									LEFT JOIN Business_Segment bs
									ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
									INNER JOIN VF_Distributor_Planning_Groups vfpg
									ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
									AND		vfpg.Deleted = 0
									INNER JOIN PG_Customer_Members pgpm
									ON			pgpm.PG_Customer_Category_ID = vfpg.PG_Customer_Category_ID
									AND		pgpm.Deleted = 0
									INNER JOIN (
									SELECT	p.VF_Plan_ID, pgpm.BSA_Foodservice_Customers_ID, COUNT(*) as cnt
									FROM		VF_Plan p
									INNER JOIN  VF_Class c
									ON			c.VF_Class_ID = p.VF_Plan_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1 -- Only for active class
									INNER JOIN VF_Distributor_Planning_Groups vfpg
									ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
									AND		vfpg.Deleted = 0
									INNER JOIN PG_Customer_Members pgpm
									ON			pgpm.PG_Customer_Category_ID = vfpg.PG_Customer_Category_ID
									AND		pgpm.Deleted = 0
									WHERE	p.Deleted = 0
									GROUP BY p.VF_Plan_ID, pgpm.BSA_Foodservice_Customers_ID
									HAVING COUNT(*) > 1

									) AS 	Duplicates
								ON			Duplicates.VF_Plan_ID = p.VF_Plan_ID
								AND		Duplicates.BSA_Foodservice_Customers_ID = pgpm.BSA_Foodservice_Customers_ID
								WHERE	p.Deleted = 0


								SELECT	dup1.VF_Plan_ID,
												dup1.VF_Plan_Desc,
												dup1.VF_Class_Desc,
												dup1.Business_Unit_Desc,
												pg1.PG_Customer_Category_Name AS pg1,
												pg2.PG_Customer_Category_Name AS pg2,
												c.Shr_Ship_To AS Item,
												c.Name AS Description
								FROM	##tmp_dups dup1
								INNER JOIN ##tmp_dups dup2
								ON			dup1.VF_Plan_ID = dup2.VF_Plan_ID
								AND		dup1.BSA_Foodservice_Customers_ID = dup2.BSA_Foodservice_Customers_ID
								AND		CAST(dup1.PG_Customer_Category_ID as varchar(50)) > CAST(dup2.PG_Customer_Category_ID as varchar(50))
								INNER JOIN BSA_Foodservice_Customers c
								ON			c.BSA_Foodservice_Customers_ID = dup1.BSA_Foodservice_Customers_ID
								INNER JOIN PG_Customer_Category pg1
								ON			pg1.PG_Customer_Category_ID = dup1.PG_Customer_Category_ID
								INNER JOIN PG_Customer_Category pg2
								ON			pg2.PG_Customer_Category_ID = dup2.PG_Customer_Category_ID

<cfelseif arguments.category eq 0>

								SELECT	p.VF_Plan_ID,
												p.VF_Plan_Desc,
												p.Forecast_Level,
												c.VF_Class_ID,
												c.VF_Class_Desc,
												bs.Business_Segment_ID,
												bs.Business_Unit_Desc,
												vfpg.PG_Product_Category_ID,
												pg.PG_Product_Category_Name,
												pgpm.BSA_Foodservice_Items_Master_ID
								INTO	##tmp_plan_products
								FROM	VF_Plan p
								INNER JOIN  VF_Class c
								ON			c.VF_Class_ID = p.VF_Plan_Class_ID
								AND		c.Deleted = 0
								AND		c.Active = 1 -- Only for active class
								LEFT JOIN Business_Segment bs
								ON			bs.Business_Segment_ID = p.VF_Plan_Segment_ID
								INNER JOIN VF_Planning_Groups vfpg -- For distributor replace with VF_Distributor_Planning_Groups
								ON			vfpg.VF_Plan_ID = p.VF_Plan_ID
								AND		vfpg.Deleted = 0
								INNER JOIN PG_Product_Members pgpm
								ON			pgpm.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
								AND		pgpm.Deleted = 0
								INNER JOIN PG_Product_Category pg
								ON			pg.PG_Product_Category_ID = vfpg.PG_Product_Category_ID
								AND		pg.Deleted = 0
								WHERE	p.Deleted = 0

								-- Find if any plan is a duplicate for class/segment/product
								SELECT	VF_Class_ID, Business_Segment_ID, BSA_Foodservice_Items_Master_ID, COUNT(DISTINCT VF_Plan_ID) as cnt
								INTO		##tmp_plan_product_dups
								FROM		##tmp_plan_products
								GROUP BY VF_Class_ID, Business_Segment_ID, BSA_Foodservice_Items_Master_ID
								HAVING COUNT(DISTINCT VF_Plan_ID) > 1

								SELECT	p.*,
												CAST(0 as bit) as Distributor_Filter,
												CAST(NULL as uniqueidentifier) as PG_Customer_Category_ID,
												CAST('ALL' as nvarchar(100)) as PG_Customer_Category_Name,
												CAST(NULL as uniqueidentifier) as BSA_Foodservice_Customers_ID
								INTO		##tmp_plan_products_distributors
								FROM		##tmp_plan_products p
								INNER JOIN ##tmp_plan_product_dups dup
								ON			dup.VF_Class_ID = p.VF_Class_ID
								AND		dup.Business_Segment_ID = p.Business_Segment_ID
								AND		dup.BSA_Foodservice_Items_Master_ID = p.BSA_Foodservice_Items_Master_ID
								WHERE	p.Forecast_Level != 4
								AND 	NOT EXISTS(
																		SELECT 	vfdg.VF_Plan_ID
																		FROM	VF_Distributor_Planning_Groups  vfdg
																		WHERE 	vfdg.VF_Plan_ID = P.VF_Plan_ID
																		AND		vfdg.Deleted = 0
																)

								INSERT INTO ##tmp_plan_products_distributors
								SELECT	p.*,
												CAST(1 as bit) as Distributor_Filter,
												vfdg.PG_Customer_Category_ID,
												pg.PG_Customer_Category_Name,
												pgcm.BSA_Foodservice_Customers_ID
								FROM		##tmp_plan_products p
								INNER JOIN ##tmp_plan_product_dups dup
								ON			dup.VF_Class_ID = p.VF_Class_ID
								AND		dup.Business_Segment_ID = p.Business_Segment_ID
								AND		dup.BSA_Foodservice_Items_Master_ID = p.BSA_Foodservice_Items_Master_ID
								INNER JOIN VF_Distributor_Planning_Groups  vfdg
								ON			vfdg.VF_Plan_ID = P.VF_Plan_ID
								AND		vfdg.Deleted = 0
								INNER JOIN PG_Customer_Members pgcm
								ON    		pgcm.PG_Customer_Category_ID = vfdg.PG_Customer_Category_ID
								AND		pgcm.Deleted = 0
								INNER JOIN PG_Customer_Category pg
								ON			pg.PG_Customer_Category_ID = vfdg.PG_Customer_Category_ID
								AND		pg.Deleted = 0

----- Find if any plan is a duplicate for class/segment/product for records without distributor
								SELECT	r1.*,
												r2.VF_Plan_ID as VF_Plan_ID2,
												r2.VF_Plan_Desc as VF_Plan_Desc2,
												r2.PG_Product_Category_ID as PG_Product_Category_ID2,
												r2.PG_Product_Category_Name as PG_Product_Category_Name2,
												r2.PG_Customer_Category_ID as PG_Customer_Category_ID2,
												r2.PG_Customer_Category_Name as PG_Customer_Category_Name2,
												r2.BSA_Foodservice_Customers_ID as BSA_Foodservice_Customers_ID2
								INTO		##tmp_plan_product_dist_dups_final
								FROM		##tmp_plan_products_distributors r1
								INNER JOIN ##tmp_plan_products_distributors r2
								ON			r1.VF_Plan_ID != r2.VF_Plan_ID
								AND		(r2.Distributor_Filter = 1 OR r1.VF_Plan_ID < r2.VF_Plan_ID)
								AND		r1.VF_Class_ID = r2.VF_Class_ID
								AND		r1.Business_Segment_ID = r2.Business_Segment_ID
								AND		r1.BSA_Foodservice_Items_Master_ID = r2.BSA_Foodservice_Items_Master_ID
								WHERE	r1.Distributor_Filter = 0

----- Find if any plan is a duplicate for class/segment/product/distributor
								INSERT INTO ##tmp_plan_product_dist_dups_final
								SELECT	r1.*,
												r2.VF_Plan_ID as VF_Plan_ID2,
												r2.VF_Plan_Desc as VF_Plan_Desc2,
												r2.PG_Product_Category_ID as PG_Product_Category_ID2,
												r2.PG_Product_Category_Name as PG_Product_Category_Name2,
												r2.PG_Customer_Category_ID as PG_Customer_Category_ID2,
												r2.PG_Customer_Category_Name as PG_Customer_Category_Name2,
												r2.BSA_Foodservice_Customers_ID as BSA_Foodservice_Customers_ID2
								FROM		##tmp_plan_products_distributors r1
								INNER JOIN ##tmp_plan_products_distributors r2
								ON			r1.VF_Plan_ID < r2.VF_Plan_ID
								AND		r1.VF_Class_ID = r2.VF_Class_ID
								AND		r1.Business_Segment_ID = r2.Business_Segment_ID
								AND		r1.BSA_Foodservice_Items_Master_ID = r2.BSA_Foodservice_Items_Master_ID
								AND		r1.BSA_Foodservice_Customers_ID = r2.BSA_Foodservice_Customers_ID

								SELECT	COALESCE(c1.Shr_Ship_To, c2.Shr_Ship_To, 'ALL') as Shr_Ship_To,
												COALESCE(c1.Name, c2.Name, 'ALL') as Name,
												i.Item,
												i.Description,
												f.VF_Plan_Desc as Plan1,
												f.PG_Product_Category_Name as Product_PG1,
												f.PG_Customer_Category_Name as Distributor_PG1,
												f.VF_Plan_Desc2 as Plan2,
												f.PG_Product_Category_Name2 as Product_PG2,
												f.PG_Customer_Category_Name2 as Distributor_PG2
								FROM		##tmp_plan_product_dist_dups_final f
								LEFT JOIN BSA_Foodservice_Customers c1
								ON			c1.BSA_Foodservice_Customers_ID = f.BSA_Foodservice_Customers_ID
								LEFT JOIN BSA_Foodservice_Customers c2
								ON			c2.BSA_Foodservice_Customers_ID = f.BSA_Foodservice_Customers_ID2
								INNER JOIN BSA_Foodservice_Items_Master i
								ON			i.BSA_Foodservice_Items_Master_ID = f.BSA_Foodservice_Items_Master_ID

</cfif>


						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products') IS NOT NULL
						DROP TABLE ##tmp_plan_products
						IF OBJECT_ID('tempdb..##tmp_plan_product_dups') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dups
						IF OBJECT_ID('tempdb..##tmp_plan_products_distributors') IS NOT NULL
						DROP TABLE ##tmp_plan_products_distributors
						IF OBJECT_ID('tempdb..##tmp_plan_product_dist_dups_final') IS NOT NULL
						DROP TABLE ##tmp_plan_product_dist_dups_final
</cfquery>
<cfreturn VolumeForecastDuplicates />
</cffunction>

<cffunction name="Accrual_Budget_Duplicates_Excel" returntype="Query" >
	<cfargument name="Category" required="true" type="numeric" default="1" >
<cfquery name="AccrualBudgetDuplicates" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_budget_distributors') IS NOT NULL
						DROP TABLE ##tmp_budget_distributors
<cfif arguments.category eq 1>
					SELECT	b.Budget_ID,
									b.Budget_Desc,
									c.Budget_Class_Desc,
									bs.Business_Unit_Desc,
									bpr.Product_Group_ID as PG_Product_Category_ID,
									pgpm.BSA_Foodservice_Items_Master_ID
					INTO	##tmp_dups
					FROM	Budget b
					INNER JOIN  Budget_Class c
					ON			b.Budget_Class_ID = c.Budget_Class_ID
					AND		c.Deleted = 0
					AND		c.Active = 1
					LEFT JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = b.Business_Segment_ID
					INNER JOIN Budget_Product_Rate bpr
					ON			bpr.Budget_ID = b.Budget_ID
					INNER JOIN PG_Product_Members pgpm
					ON			pgpm.PG_Product_Category_ID = bpr.Product_Group_ID
					AND		pgpm.Deleted = 0
					INNER JOIN (

						SELECT	b.Budget_ID, pgpm.BSA_Foodservice_Items_Master_ID, COUNT(*) as cnt
						FROM		Budget b
						INNER JOIN  Budget_Class c
						ON			b.Budget_Class_ID = c.Budget_Class_ID
						AND		c.Deleted = 0
						AND		c.Active = 1
						INNER JOIN Budget_Product_Rate bpr
						ON			bpr.Budget_ID = b.Budget_ID
						INNER JOIN PG_Product_Members pgpm
						ON			pgpm.PG_Product_Category_ID = bpr.Product_Group_ID
						AND		pgpm.Deleted = 0
						WHERE	b.Deleted = 0
						GROUP BY b.Budget_ID, pgpm.BSA_Foodservice_Items_Master_ID
						HAVING COUNT(*) > 1

						) AS 	Duplicates
					ON			Duplicates.Budget_ID = b.Budget_ID
					AND		Duplicates.BSA_Foodservice_Items_Master_ID = pgpm.BSA_Foodservice_Items_Master_ID
					WHERE	b.Deleted = 0


					SELECT	dup1.Budget_ID,
									dup1.Budget_Desc,
									dup1.Budget_Class_Desc,
									dup1.Business_Unit_Desc,
									pg1.PG_Product_Category_Name AS PG1,
									pg2.PG_Product_Category_Name AS PG2,
									im.Item,
									im.Description
					FROM	##tmp_dups dup1
					INNER JOIN ##tmp_dups dup2
					ON		dup1.Budget_ID = dup2.Budget_ID
					AND		dup1.BSA_Foodservice_Items_Master_ID = dup2.BSA_Foodservice_Items_Master_ID
					AND		CAST(dup1.PG_Product_Category_ID as varchar(50)) > CAST(dup2.PG_Product_Category_ID as varchar(50))
					INNER JOIN BSA_Foodservice_Items_Master im
					ON		im.BSA_Foodservice_Items_Master_ID = dup1.BSA_Foodservice_Items_Master_ID
					INNER JOIN PG_Product_Category pg1
					ON		pg1.PG_Product_Category_ID = dup1.PG_Product_Category_ID
					INNER JOIN PG_Product_Category pg2
					ON		pg2.PG_Product_Category_ID = dup2.PG_Product_Category_ID

<cfelseif arguments.category eq 2>

									SELECT	b.Budget_ID,
													pgcm.BSA_Foodservice_Customers_ID,
													bd.Distributor_Group_Level_ID,
													bd.Distributor_Group_ID
									INTO	##tmp_budget_distributors
									FROM		Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1
									INNER JOIN Budget_Distributor bd
									ON			bd.Budget_ID = b.Budget_ID
									AND		bd.Deleted = 0
									INNER JOIN PG_Customer_Members pgcm
									ON			pgcm.PG_Customer_Category_ID = bd.Distributor_Group_ID
									AND		pgcm.Deleted = 0
									WHERE	b.Deleted = 0
									UNION
									SELECT	b.Budget_ID,
													bd.Distributor_Group_ID as BSA_Foodservice_Customers_ID,
													bd.Distributor_Group_Level_ID,
													bd.Distributor_Group_ID
									FROM		Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1
									INNER JOIN Budget_Distributor bd
									ON			bd.Budget_ID = b.Budget_ID
									AND		bd.Deleted = 0
									AND		bd.Distributor_Group_Level_ID = 0
									WHERE	b.Deleted = 0


									SELECT	b.Budget_ID,
													b.Budget_Desc,
													c.Budget_Class_Desc,
													bs.Business_Unit_Desc,
													bd.Distributor_Group_ID as PG_Customer_Category_ID,
													bd.BSA_Foodservice_Customers_ID
									INTO	##tmp_dups
									FROM	Budget b
									INNER JOIN  Budget_Class c
									ON			b.Budget_Class_ID = c.Budget_Class_ID
									AND		c.Deleted = 0
									AND		c.Active = 1
									LEFT JOIN 	Business_Segment bs
									ON				bs.Business_Segment_ID = b.Business_Segment_ID
									INNER JOIN ##tmp_budget_distributors bd
									ON		bd.Budget_ID = b.Budget_ID
									INNER JOIN (
											SELECT	Distributors.Budget_ID, Distributors.BSA_Foodservice_Customers_ID, COUNT(*) as cnt
											FROM	##tmp_budget_distributors as Distributors
											Group By Distributors.Budget_ID, Distributors.BSA_Foodservice_Customers_ID
											HAVING COUNT(*) > 1

										) AS Duplicates
									ON			Duplicates.Budget_ID = b.Budget_ID
									AND		Duplicates.BSA_Foodservice_Customers_ID = bd.BSA_Foodservice_Customers_ID
									WHERE	b.Deleted = 0

									SELECT	dup1.Budget_ID,
													dup1.Budget_Desc,
													dup1.Budget_Class_Desc,
													dup1.Business_Unit_Desc,
													ISNULL(pg1.PG_Customer_Category_Name, '**Individual distributor') as PG1,
													ISNULL(pg2.PG_Customer_Category_Name, '**Individual distributor') as PG2,
													im.Shr_Ship_To,
													im.Name
									FROM	##tmp_dups dup1
									INNER JOIN ##tmp_dups dup2
									ON			dup1.Budget_ID = dup2.Budget_ID
									AND		dup1.BSA_Foodservice_Customers_ID = dup2.BSA_Foodservice_Customers_ID
									AND		ISNULL(CAST(dup1.PG_Customer_Category_ID as varchar(50)), '') > ISNULL(CAST(dup2.PG_Customer_Category_ID as varchar(50)), '')
									INNER JOIN BSA_Foodservice_Customers im
									ON		im.BSA_Foodservice_Customers_ID = dup1.BSA_Foodservice_Customers_ID
									LEFT JOIN PG_Customer_Category pg1
									ON		pg1.PG_Customer_Category_ID = dup1.PG_Customer_Category_ID
									LEFT JOIN PG_Customer_Category pg2
									ON		pg2.PG_Customer_Category_ID = dup2.PG_Customer_Category_ID

</cfif>

						IF OBJECT_ID('tempdb..##tmp_dups') IS NOT NULL
						DROP TABLE ##tmp_dups
						IF OBJECT_ID('tempdb..##tmp_budget_distributors') IS NOT NULL
						DROP TABLE ##tmp_budget_distributors
</cfquery>
<cfreturn AccrualBudgetDuplicates />
</cffunction>

<cffunction name="Program_Segment_Aligment_Excel" returntype="Query" >
	<cfargument name="Category" required="true" type="numeric" default="1" >
<cfquery name="ProgramSegmentAligment" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..##tmp_program_template_info') IS NOT NULL
						DROP TABLE ##tmp_program_template_info
<cfif arguments.category eq 1>
					SELECT	cm.Contract_Main_ID,
									cm.Contract_Number,
									cm.Contract_Title,
									cm.Business_Segment_ID,
									bs.Business_Unit_Desc,
									t.Created_Type,
									pgts.Product_Group_Level_ID,
									pgts.Product_Group_ID,
									pgpc.PG_Product_Category_Name
					INTO		##tmp_program_template_info
					FROM		Contract_Main cm
					INNER JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = cm.Business_Segment_ID
					INNER JOIN Program_Control_Panel_Options t
					ON			t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Group_Template gt
					ON			gt.Template_ID =  t.First_Parent_ID
					AND		gt.Active = 1
					AND		gt.Deleted = 0
					AND		gt.PG_Group_Type = 1
					AND		gt.Allow_Filter = 1 -- If template is filtered on a group
					AND		gt.PG_Flag = 1
					<!--- It is better to not use "deleted = 0" for "PG_Type" table --->
					INNER JOIN PG_Type pg
					ON		pg.PG_Type_ID = gt.Group_Level_ID
					AND 		pg.Is_System = 1
					INNER JOIN Template_Filters tf
					ON			tf.Template_Filters_Id = cm.Template_Filters_Id
					AND		tf.Deleted = 0
					INNER JOIN Product_Group_Template_Selection pgts
					ON			pgts.Template_ID = t.First_Parent_ID
					AND		pgts.Template_Filters_Id = cm.Template_Filters_Id
					AND		pgts.Product_Group_Level_ID = gt.Group_Level_ID
					AND		pgts.Active = 1
					AND		pgts.Deleted = 0
					AND		pgts.Product_Group_ID != 'undefined'
					INNER JOIN PG_Product_Category pgpc
					ON			pgpc.PG_Product_Category_ID = pgts.Product_Group_ID
					AND		pgpc.Deleted = 0
					WHERE	cm.Deleted = 0
					AND		cm.Manual_Cancel = 0
					AND		cm.Contract_Status_Type_IDX NOT IN (7, 8)-- -- Expired, Lost

					SELECT	p.Contract_Number,
									p.Contract_Title,
									p.Business_Unit_Desc,
									p.Created_Type,
									i.Item,
									i.Description,
									p.PG_Product_Category_Name
					FROM	##tmp_program_template_info p
					INNER JOIN Contract_Products cp
					ON			cp.Contract_Main_ID = p.Contract_Main_ID
					AND		cp.Deleted = 0
					AND		cp.Is_Group = 0 ---- only individual products
					INNER JOIN BSA_Foodservice_Items_Master i
					ON			i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					LEFT JOIN PG_Product_Members m
					ON			m.PG_Product_Category_ID = p.Product_Group_ID
					AND		m.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					AND		m.Deleted = 0
					WHERE  ( m.PG_Product_Category_ID IS NULL )

<cfelseif arguments.category eq 2>
					SELECT	cm.Contract_Main_ID,
									cm.Contract_Number,
									cm.Contract_Title,
									cm.Business_Segment_ID,
									bs.Business_Unit_Desc,
									t.Created_Type,
									cgts.Distributor_Group_Level_ID,
									cgts.Distributor_Group_ID,
									pgcc.PG_Customer_Category_Name
					INTO		##tmp_program_template_info
					FROM		Contract_Main cm
					INNER JOIN Business_Segment bs
					ON			bs.Business_Segment_ID = cm.Business_Segment_ID
					INNER JOIN Program_Control_Panel_Options t
					ON			t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
					INNER JOIN Group_Template gt
					ON			gt.Template_ID =  t.First_Parent_ID
					AND		gt.Active = 1
					AND		gt.Deleted = 0
					AND		gt.PG_Group_Type = 2
					AND		gt.Allow_Filter = 1 -- If template is filtered on a group
					AND		gt.PG_Flag = 1
					<!--- It is better to not use "deleted = 0" for "PG_Type" table --->
					INNER JOIN PG_Type pg
					ON			pg.PG_Type_ID = gt.Group_Level_ID
					AND		pg.Is_System = 1
					INNER JOIN Template_Filters tf
					ON			tf.Template_Filters_Id = cm.Template_Filters_Id
					AND		tf.Deleted = 0
					INNER JOIN Customer_Group_Template_Selection cgts
					ON			cgts.Template_ID = t.First_Parent_ID
					AND		cgts.Template_Filters_Id = cm.Template_Filters_Id
					AND		cgts.Distributor_Group_Level_ID = gt.Group_Level_ID
					AND		cgts.Active = 1
					AND		cgts.Deleted = 0
					AND		cgts.Distributor_Group_ID != 'undefined'
					INNER JOIN PG_Customer_Category pgcc
					ON			pgcc.PG_Customer_Category_ID = cgts.Distributor_Group_ID
					AND		pgcc.Deleted = 0
					WHERE	cm.Deleted = 0
					AND		cm.Manual_Cancel = 0
					AND		cm.Contract_Status_Type_IDX NOT IN (7, 8) -- Expired, Lost

					SELECT	p.Contract_Number,
									p.Contract_Title,
									p.Business_Unit_Desc,
									p.Created_Type,
									c.Shr_Ship_To,
									c.Name,
									p.PG_Customer_Category_Name
					FROM	##tmp_program_template_info p
					INNER JOIN Contract_Distributors cd
					ON			cd.Contract_Main_ID = p.Contract_Main_ID
					AND		cd.Deleted = 0
					AND		cd.Is_Group = 0 -- only individual distributors
					INNER JOIN BSA_Foodservice_Customers c
					ON			c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
					LEFT JOIN PG_Customer_Members m
					ON			m.PG_Customer_Category_ID = p.Distributor_Group_ID
					AND		m.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
					AND		m.Deleted = 0
					WHERE  ( m.PG_Customer_Category_ID IS NULL)

</cfif>


						IF OBJECT_ID('tempdb..##tmp_program_template_info') IS NOT NULL
						DROP TABLE ##tmp_program_template_info
</cfquery>
<cfreturn ProgramSegmentAligment />
</cffunction>

<!--- Check whether the distributor payee does not exist as a member of the planning group.--->
<cffunction name="checkDistributorPayeeOnPGNotPGMember" output="false" returntype="boolean">
	<cfargument name="PGCustomerCategoryID" type="string" required="true" />
	<cfset var bPayeeNotExist = 0>

		<cfquery name="qrycheckDistributorPayeeOnPGNotPGMember" datasource="#application.datasource#">
		if exists
		(
			SELECT PG_Customer_Category.distributor_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.distributor_id NOT IN
			(
				/* distributor payee on the planning group is not a member of the planning group */
				SELECT BSA_Foodservice_Customers_ID
				FROM PG_Customer_Members pg1
				WHERE PG_Customer_Category.PG_Customer_Category_ID = pg1.PG_Customer_Category_ID
				AND pg1.deleted = 0
				AND pg1.Active = 1
			)
		)
		OR
		EXISTS
		(
			SELECT PG_Customer_Category.distributor_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.distributor_id IS NULL
		)
		SELECT 1 As PayeeNotExist
		ELSE
		SELECT 0 As PayeeNotExist
		</cfquery>

		<cfset bPayeeNotExist = qrycheckDistributorPayeeOnPGNotPGMember.PayeeNotExist>
		<cfreturn bPayeeNotExist>
</cffunction>

<!--- Check whether the distributor payee exists. --->
<cffunction name="checkDistributorPayeeExists" output="false" returntype="boolean">
	<cfargument name="PGCustomerCategoryID" type="string" required="true" />
	<cfset var bPayeeExist = 0>

		<cfquery name="qrycheckDistributorPayeeExists" datasource="#application.datasource#">
		if exists
		(
			SELECT PG_Customer_Category.distributor_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.distributor_id IS NOT NULL
		)
		SELECT 1 As PayeeExist
		ELSE
		SELECT 0 As PayeeExist
		</cfquery>

		<cfset bPayeeExist = qrycheckDistributorPayeeExists.PayeeExist>
		<cfreturn bPayeeExist>
</cffunction>

<!--- Check whether the vendor payee does not exist as a member of the planning group.--->
<cffunction name="checkVendorPayeeOnPGNotPGMember" output="false" returntype="boolean">
	<cfargument name="PGCustomerCategoryID" type="string" required="true" />
	<cfset var bPayeeNotExist = 0>

		<cfquery name="qrycheckVendorPayeeOnPGNotPGMember" datasource="#application.datasource#">
		if exists
		(
			SELECT PG_Customer_Category.vendor_master_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.vendor_master_id NOT IN
			(
				/* Check vendor as the default payee for the customer */
				SELECT Vendor_Master.vendor_master_id
				FROM PG_Customer_Members pg1
				INNER JOIN BSA_Foodservice_Customers
				ON    BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = pg1.BSA_Foodservice_Customers_ID
				INNER JOIN Vendor_Master
				ON BSA_Foodservice_Customers.Default_Vendor_ID = Vendor_Master.Vendor_ID
				WHERE PG_Customer_Category.PG_Customer_Category_ID = pg1.PG_Customer_Category_ID
				AND pg1.deleted = 0
				AND pg1.Active = 1

				UNION

				/* Check vendor as the payee for the customer in the "Vendor_Dist_Oper" table */
				SELECT Vendor_Master.vendor_master_id
				FROM PG_Customer_Members pg1
				INNER JOIN BSA_Foodservice_Customers
				ON    BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = pg1.BSA_Foodservice_Customers_ID
				INNER JOIN Vendor_Dist_Oper
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID
				INNER JOIN Vendor_Master
				ON Vendor_Dist_Oper.Vendor_ID = Vendor_Master.Vendor_ID
				WHERE PG_Customer_Category.PG_Customer_Category_ID = pg1.PG_Customer_Category_ID
				AND pg1.deleted = 0
				AND pg1.Active = 1
				AND Vendor_Dist_Oper.Deleted = 0
			)
		)
		OR
		EXISTS
		(
			SELECT PG_Customer_Category.vendor_master_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.vendor_master_id IS NULL
		)
		SELECT 1 As PayeeNotExist
		ELSE
		SELECT 0 As PayeeNotExist
		</cfquery>

		<cfset bPayeeNotExist = qrycheckVendorPayeeOnPGNotPGMember.PayeeNotExist>
		<cfreturn bPayeeNotExist>
</cffunction>

<!--- Check whether the vendor payee exists. --->
<cffunction name="checkVendorPayeeExists" output="false" returntype="boolean">
	<cfargument name="PGCustomerCategoryID" type="string" required="true" />
	<cfset var bPayeeExist = 0>

		<cfquery name="qrycheckVendorPayeeExists" datasource="#application.datasource#">
		if exists
		(
			SELECT PG_Customer_Category.vendor_master_id
			FROM PG_Customer_Category
			WHERE PG_Customer_Category.PG_Customer_Category_ID = '#arguments.PGCustomerCategoryID#'
			AND PG_Customer_Category.vendor_master_id IS NOT NULL
		)
		SELECT 1 As PayeeExist
		ELSE
		SELECT 0 As PayeeExist
		</cfquery>

		<cfset bPayeeExist = qrycheckVendorPayeeExists.PayeeExist>
		<cfreturn bPayeeExist>
</cffunction>

<cffunction name="getPGCategoryID" output="false" returntype="string">
	<cfargument name="PGTypeID" type="string" required="true" />
	<cfargument name="PGCategoryName" type="string" required="true" />

		<cfif arguments.PGTypeID eq "1"> <!--- product ( item ) --->
			<cfquery name="qryGetPGCategoryID" datasource="#application.datasource#">
			SELECT PG_Product_Category_ID AS PG_Category_ID
			FROM PG_Product_Category
			WHERE PG_Product_Category_Name = <cfqueryparam value="#arguments.PGCategoryName#" cfsqltype="cf_sql_varchar" />
			AND Deleted = 0
			</cfquery>
		<cfelseif arguments.PGTypeID EQ "2"> <!--- distributor ( customer ) --->
			<cfquery name="qryGetPGCategoryID" datasource="#application.datasource#">
			SELECT PG_Customer_Category_ID AS PG_Category_ID
			FROM PG_Customer_Category
			WHERE PG_Customer_Category_Name = <cfqueryparam value="#arguments.PGCategoryName#" cfsqltype="cf_sql_varchar" />
			AND Deleted = 0
			</cfquery>
		<cfelseif arguments.PGTypeID EQ "3"> <!--- Operator --->
			<cfquery name="qryGetPGCategoryID" datasource="#application.datasource#">
			SELECT PG_Operator_Category_ID AS PG_Category_ID
			FROM PG_Operator_Category
			WHERE PG_Operator_Category_Name = <cfqueryparam value="#arguments.PGCategoryName#" cfsqltype="cf_sql_varchar" />
			AND Deleted = 0
			</cfquery>
		</cfif>

	<cfreturn qryGetPGCategoryID.PG_Category_ID>

</cffunction>

<cffunction name="membersCount" output="false">
  <cfargument name="PGType" required="true">
  <cfargument name="GroupID" required="true">

  <cfif arguments.PGType EQ "1">    <!--- product ( item ) --->
      <cfquery name="local.qMembers" datasource="#application.datasource#">
        SELECT COUNT(*) AS Count
          FROM PG_Product_Members
              INNER JOIN PG_Product_Category ON PG_Product_Category.PG_Product_Category_ID = PG_Product_Members.PG_Product_Category_ID
              INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = PG_Product_Members.BSA_Foodservice_Items_Master_ID
              <cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
                LEFT JOIN Business_Segment Bus_Seg ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Items_Master.Business_Segment_ID
              </cfif>
         WHERE PG_Product_Members.PG_Product_Category_ID IN ('#arguments.GroupID#') AND PG_Product_Members.Deleted = 0
      </cfquery>
      <cfreturn local.qMembers.count>

  <cfelseif arguments.PGType EQ "2">     <!--- distributor ( customer ) --->
      <cfquery name="local.qMembers" datasource="#application.datasource#">
        SELECT COUNT(*) AS Count
          FROM PG_Customer_Members
              INNER JOIN PG_Customer_Category ON PG_Customer_Category.PG_Customer_Category_ID = PG_Customer_Members.PG_Customer_Category_ID
              INNER JOIN BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = PG_Customer_Members.BSA_Foodservice_Customers_ID
              <cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
                LEFT JOIN Business_Segment Bus_Seg ON Bus_Seg.Business_Segment_ID = BSA_Foodservice_Customers.Business_Segment_ID
              </cfif>
         WHERE PG_Customer_Members.PG_Customer_Category_ID IN ('#arguments.GroupID#')
      </cfquery>
      <cfreturn local.qMembers.count>

  <cfelseif arguments.PGType EQ "3"> <!--- Operator --->
      <cfquery name="local.qMembers" datasource="#application.datasource#">
        SELECT COUNT(*) AS Count
          FROM PG_Operator_Members
              INNER JOIN PG_Operator_Category ON PG_Operator_Category.PG_Operator_Category_ID = PG_Operator_Members.PG_Operator_Category_ID
              INNER JOIN BSA_Operator ON BSA_Operator.BSA_Operator_ID = PG_Operator_Members.BSA_Operator_ID
              <cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
                LEFT JOIN Business_Segment Bus_Seg ON Bus_Seg.Business_Segment_ID = BSA_Operator.Business_Segment_ID
              </cfif>
         WHERE PG_Operator_Members.PG_Operator_Category_ID IN ('#arguments.GroupID#')
      </cfquery>
      <cfreturn local.qMembers.count>

  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>
<!---D81389 :: Tyson - System generated number for Planning Groups---->
<cffunction name="PGSequenceNumber" output="false" returntype="numeric">

  <cfquery name="QPGSNumber" datasource="#application.datasource#">
    SELECT MAX (PG_Sequence_Number) AS PG_Number_Sequence
    FROM Planning_Group_Sequence_Number
  </cfquery>

  <cfif len(QPGSNumber.PG_Number_Sequence)>
    <cfset  PGNumberSequence = QPGSNumber.PG_Number_Sequence + 1>
  <cfelse>
    <cfset PGNumberSequence = appSettings.get_Setting('PG_Number_Sequence') + 1>
  </cfif>

  <cfquery name="IPGSNumber" datasource="#application.datasource#">
    INSERT INTO  Planning_Group_Sequence_Number (PG_Sequence_Number)
    VALUES (#PGNumberSequence#)
  </cfquery>


<cfreturn PGNumberSequence>
</cffunction>
</cfcomponent>