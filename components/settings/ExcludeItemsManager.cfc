<!-----------------------------------------------------------------------------

FILE NAME:		ExcludeItemsManager.cfc
DESCRIPTION:	This is a component that handles the Margin - Exclusion Items
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	11-Aug-2010	 Created
------------------------------------------------------------------------------>


<cfcomponent displayname="ExcludeItemsManager" hint="Handles Excludes Item Methods" output="false">

	<!--- Init --->
	<cffunction name="init" output="false" returntype="components.settings.LDAPSettingsManager">
		<cfreturn this />
	</cffunction>

  <!--- This function add an item in the DB --->
  <cffunction name="AddItemsExclude" output="false" returntype="string" >
    <cfargument name="UserID"                  type="string" required="true" />
    <cfargument name="MarginItemExclusionCode" type="string" required="false" default="" />
		<cfargument name="MarginItemExclusionName" type="string" required="true" />
    <cfargument name="IncludeOnVolume"         type="string"    required="true" />
    <cfargument name="ProductList"             type="string"    required="true" />
    <cfargument name="GroupLevel"              type="string"    required="true" />
    <cfargument name="GroupList"               type="string"    required="true" />
    <cfargument name="TemplateList"            type="string"    required="true" />
    <cfset returnValue = "" />
    <cfset ProductListVL  = arguments.ProductList />
    <cfset GroupListVL    = arguments.GroupList />
    <cfset TemplateListVL = arguments.TemplateList />

    <cfquery name="qSelNameCheck" datasource="#application.datasource#">
      SELECT
        Margin_Item_Exclusion_Code,
        Margin_Item_Exclusion_Name,
        Include_On_Volume
      FROM
        Margin_Item_Exclusion
      WHERE
        Margin_Item_Exclusion_Name = Ltrim(RTrim('#arguments.MarginItemExclusionName#'))
        AND Deleted = 0
    </cfquery>

    <cfif  (qSelNameCheck.RecordCount EQ 0)>
      <cfquery name="qInsAddItemsExclude" datasource="#application.datasource#">
        DECLARE @Margin_Item_Exclusion_ID int
        INSERT INTO Margin_Item_Exclusion
          (Margin_Item_Exclusion_Code, Margin_Item_Exclusion_Name, Include_On_Volume, Created_By)
        VALUES
          (
            <cfqueryparam value="#arguments.MarginItemExclusionCode#" cfsqltype="cf_sql_varchar"/>,
            <cfqueryparam value="#arguments.MarginItemExclusionName#" cfsqltype="cf_sql_varchar"/>,
            <cfqueryparam value="#arguments.IncludeOnVolume#" cfsqltype="cf_sql_bit"/>,
            <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>
          )
          SET @Margin_Item_Exclusion_ID = SCOPE_IDENTITY()
          SELECT Margin_Item_Exclusion_ID = @Margin_Item_Exclusion_ID
      </cfquery>

      <!--- INSERT THE GROUP IDs --->
      <cfloop index = "Group_ID"  list ="#GroupListVL#">
        <cfquery name="qInsAddItemsExcludeProducts" datasource="#application.datasource#">
          INSERT INTO Margin_Item_Exclusion_Products
          (
            Margin_Item_Exclusion_ID,
            Product_Group_Level_ID,
            Product_Group_ID
          )
          VALUES
          (
            <cfqueryparam value="#qInsAddItemsExclude.Margin_Item_Exclusion_ID#" cfsqltype="cf_sql_integer"/>,
            <cfqueryparam value="#arguments.GroupLevel#" cfsqltype="cf_sql_integer"/>,
             <cfqueryparam value="#Group_ID#" cfsqltype="cf_sql_varchar"/>
          )
        </cfquery>
      </cfloop>
      <!--- INSERT THE PRODUCTS --->
      <cfloop index = "Product_ID"  list ="#ProductListVL#">
        <cfquery name="qInsAddItemsExcludeProducts" datasource="#application.datasource#">
          INSERT INTO Margin_Item_Exclusion_Products
          (
            Margin_Item_Exclusion_ID,
            Product_Group_ID
          )
          VALUES
          (
            <cfqueryparam value="#qInsAddItemsExclude.Margin_Item_Exclusion_ID#" cfsqltype="cf_sql_integer"/>,
             <cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar"/>
          )
        </cfquery>
      </cfloop>

      <!--- INSERT THE TEMPLATES --->
     <cfloop index = "Template_ID"  list ="#TemplateListVL#">
      <cfquery name="qInsAddItemsExcludeTemplate" datasource="#application.datasource#">
        INSERT INTO Margin_Item_Exclusion_Template
        (
          Margin_Item_Exclusion_ID,
          Program_Template_ID
        )
        VALUES
        (
           <cfqueryparam value="#qInsAddItemsExclude.Margin_Item_Exclusion_ID#" cfsqltype="cf_sql_integer"/>,
           <cfqueryparam value="#Template_ID#" cfsqltype="cf_sql_varchar"/>
        )
      </cfquery>
    </cfloop>

    <cfset StructDelete(Session, "FormData")>
  <cfelse>
    <cfset returnValue = "1" />
  </cfif>
     <cfreturn returnValue />
  </cffunction>

  <!--- This function gets the Active items in the Exclusion List --->
	<cffunction name="getActiveItemsExclude" output="false" returntype="Query" >
		<cfset useLakebaseForqGetItemsExclude = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_item_exclusion")>
<cfif useLakebaseForqGetItemsExclude>
	<cftry>
		<cfset qGetItemsExclude = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_item_exclusion", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "margin_item_exclusion_id,margin_item_exclusion_code,margin_item_exclusion_name,include_on_volume,created_date,active,deleted,created_by,updated_by,updated_on"
			}), "margin_item_exclusion_id,margin_item_exclusion_code,margin_item_exclusion_name,include_on_volume,created_date,active,deleted,created_by,updated_by,updated_on"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetItemsExclude = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetItemsExclude>
<cfquery name="qGetItemsExclude" datasource="#application.datasource#">
			SELECT
        Margin_Item_Exclusion_ID,
        Margin_Item_Exclusion_Code,
        Margin_Item_Exclusion_Name,
        Include_On_Volume,
        Created_Date,
        Active,
        Deleted,
        Created_By,
        Updated_By,
        Updated_On
      FROM Margin_Item_Exclusion
      WHERE Deleted = 0
      AND Active = 1
    	</cfquery>
</cfif>
		<cfreturn qGetItemsExclude />
  </cffunction>

  <!--- This function gets the InActive items in the Exclusion List --->
	<cffunction name="getInActiveItemsExclude" output="false" returntype="Query" >
		<cfset var qGetLDAPSettings = "" />
		<cfquery name="qGetItemsExclude" datasource="#application.datasource#">
			SELECT
        Margin_Item_Exclusion_ID,
        Margin_Item_Exclusion_Code,
        Margin_Item_Exclusion_Name,
        Include_On_Volume,
        Created_Date,
        Active,
        Deleted,
        Created_By,
        Updated_By,
        Updated_On
      FROM Margin_Item_Exclusion
      WHERE Deleted = 0
      AND Active = 0
    	</cfquery>
		<cfreturn qGetItemsExclude />
  </cffunction>

  <!--- This function Activates an Exclusion record --->
  <cffunction   name="activate" output="false" returntype="void">
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
  	<cfquery name="qGetItemsExclude" datasource="#application.datasource#">
      UPDATE Margin_Item_Exclusion
      SET Active = 1
      WHERE Margin_Item_Exclusion_ID in (#arguments.MarginItemExclusionID#)
    </cfquery>
  </cffunction>

  <!--- This function Deactivates an Exclusion record --->
  <cffunction   name="deactivate" output="false" returntype="void">
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
  	<cfquery name="qGetItemsExclude" datasource="#application.datasource#">
      UPDATE Margin_Item_Exclusion
      SET Active = 0
      WHERE Margin_Item_Exclusion_ID in (#arguments.MarginItemExclusionID#)
    </cfquery>
  </cffunction>

  <!--- When an ID is Passed get all the data related to that ID --->
 	<cffunction name="getActiveItemsExcludeOnID" output="false" returntype="Query" >
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
		<cfquery name="qGetItemsExcludeOnID" datasource="#application.datasource#">
      SELECT
        MIE.Margin_Item_Exclusion_ID,
      	MIE.Margin_Item_Exclusion_Code,
      	MIE.Margin_Item_Exclusion_Name,
      	MIE.Include_On_Volume,
        MIE.Deleted,
        MIE.Created_Date,
        MIE.Active,
        MIE.Created_By,
	      MIE.Updated_By,
  	    MIE.Updated_On,
        _Users.Name_First + ' ' + _Users.Name_Last As UpdatedByFullName
      FROM Margin_Item_Exclusion MIE
      LEFT JOIN _Users ON _Users.User_ID = MIE.Updated_By
      WHERE MIE.Deleted = 0
      AND MIE.Active = 1
      AND MIE.Margin_Item_Exclusion_ID =  <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
    	</cfquery>
		<cfreturn qGetItemsExcludeOnID />
  </cffunction>

 <!--- Get all the products --->
  <cffunction name="getItemExclusionProducts" output="false" returntype="Query" >
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
		<cfquery name="qGetItemsExcludeProducts" datasource="#application.datasource#">
      SELECT
        Margin_Item_Exclusion_Products_ID,
        Margin_Item_Exclusion_ID,
        Product_Group_Level_ID,
        Product_Group_ID,
        Created_Date,
        Deleted
      FROM Margin_Item_Exclusion_Products
      WHERE Deleted = 0 AND Product_Group_Level_ID IS NULL
      AND Margin_Item_Exclusion_ID =  <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
    </cfquery>
		<cfreturn qGetItemsExcludeProducts />
  </cffunction>

  <!--- Get all the Groups --->
  <cffunction name="getItemExclusionGroups" output="false" returntype="Query" >
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
		<cfquery name="qGetItemsExcludeGroups" datasource="#application.datasource#">
      SELECT
        Margin_Item_Exclusion_Products_ID,
        Margin_Item_Exclusion_ID,
        Product_Group_Level_ID,
        Product_Group_ID,
        Created_Date,
        Deleted
      FROM Margin_Item_Exclusion_Products
      WHERE Deleted = 0  AND Product_Group_Level_ID IS NOT NULL
      AND Margin_Item_Exclusion_ID =  <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
    </cfquery>
		<cfreturn qGetItemsExcludeGroups />
  </cffunction>

  <!--- Get all the Templates for the given ID --->
  <cffunction name="getItemExclusionTemplates" output="false" returntype="Query" >
    <cfargument name="MarginItemExclusionID" type="string" required="true" />
		<cfquery name="qGetItemsExcludeTemplates" datasource="#application.datasource#">
      SELECT
        Margin_Item_Exclusion_Template_ID,
        Margin_Item_Exclusion_ID,
        Program_Template_ID,
        Created_Date,
        Deleted
      FROM Margin_Item_Exclusion_Template
      WHERE Deleted = 0
      AND Margin_Item_Exclusion_ID =  <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
    </cfquery>
		<cfreturn qGetItemsExcludeTemplates />
  </cffunction>

  <!--- GET ALL MARGIN PAGE -ITEMS TO EXCLUDE WITH THE TEMPLATE IDS --->
  <cffunction name="getActiveItemsExcludeTemplate" output="false" returntype="Query" >
		<cfquery name="qGetActiveItemsExcludeTemplate" datasource="#application.datasource#">
      SELECT
            MIE.Margin_Item_Exclusion_ID,
            MIE.Margin_Item_Exclusion_Code,
            MIE.Margin_Item_Exclusion_Name,
            MIE.Include_On_Volume,
            MIE.Created_Date,
            MIE.Active,
            MIE.Deleted,
            MIE.Created_By,
            MIE.Updated_By,
            MIE.Updated_On,
    		    MIET.Margin_Item_Exclusion_Template_ID,
    		    MIET.Program_Template_ID
      FROM Margin_Item_Exclusion  MIE
           INNER JOIN Margin_Item_Exclusion_Template MIET ON  MIE.Margin_Item_Exclusion_ID = MIET.Margin_Item_Exclusion_ID AND MIET.Deleted = 0
      WHERE MIE.Deleted = 0
          AND MIE.Active = 1
    </cfquery>
		<cfreturn qGetActiveItemsExcludeTemplate />
  </cffunction>



  <!---  Update the Exclusion Record --->
  <cffunction name="updateItemsExclude" output="false" returntype="string">
    <cfargument name="UserID"                  type="string" required="true" />
    <cfargument name="MarginItemExclusionCode" type="string" required="false" default="" />
  	<cfargument name="MarginItemExclusionName" type="string" required="true" />
    <cfargument name="IncludeOnVolume"         type="string" required="true" />
    <cfargument name="ProductList"             type="string" required="true" />
    <cfargument name="GroupLevel"              type="string" required="true" />
    <cfargument name="GroupList"               type="string" required="true" />
    <cfargument name="TemplateList"            type="string" required="true" />
    <cfargument name="MarginItemExclusionID"   type="string" required="true" />

    <cfset returnValue = "" />
    <cfset ProductListVL  = arguments.ProductList />
    <cfset GroupListVL    = arguments.GroupList />
    <cfset TemplateListVL = arguments.TemplateList />

    <cfquery name="qSelNameCheck" datasource="#application.datasource#">
      SELECT
        Margin_Item_Exclusion_Code,
        Margin_Item_Exclusion_Name,
        Include_On_Volume
      FROM
        Margin_Item_Exclusion
      WHERE
        Margin_Item_Exclusion_Name = Ltrim(RTrim('#arguments.MarginItemExclusionName#'))
        AND Deleted = 0
        AND Margin_Item_Exclusion_ID <>  <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
    </cfquery>

    <cfif  (qSelNameCheck.RecordCount EQ 0)>
      <cfquery name="qUpdItemsExclude" datasource="#application.datasource#">
        UPDATE Margin_Item_Exclusion
        SET Margin_Item_Exclusion_Code = <cfqueryparam value="#arguments.MarginItemExclusionCode#" cfsqltype="cf_sql_varchar"/>,
            Margin_Item_Exclusion_Name = <cfqueryparam value="#arguments.MarginItemExclusionName#" cfsqltype="cf_sql_varchar"/>,
            Include_On_Volume = <cfqueryparam value="#arguments.IncludeOnVolume#" cfsqltype="cf_sql_bit"/>,
            Updated_By = <cfqueryparam value="#arguments.UserID#" cfsqltype="cf_sql_varchar"/>,
            Updated_On = GetDate()
        WHERE
            Margin_Item_Exclusion_ID = <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>

      <!--- UPDATE ALL THE PRODUCTS/GROUPS SET DELETED = 1 AND THEN REINSERT THEM INTO THE TABLES --->

     	<cfquery name="qUpdItemsExcludeProducts" datasource="#application.datasource#">
       /*  UPDATE Margin_Item_Exclusion_Products
        SET DELETED = 1
        WHERE Margin_Item_Exclusion_ID =
       */
        DELETE FROM  Margin_Item_Exclusion_Products
        WHERE Margin_Item_Exclusion_ID =
        <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>

      <!--- UPDATE ALL THE TEMPLATES SET DELETED = 1 AND THEN REINSERT THEM INTO THE TABLES --->

      <cfquery name="qUpdItemsExcludeTemplates" datasource="#application.datasource#">
        /* UPDATE Margin_Item_Exclusion_Template
        SET DELETED = 1
        */
        DELETE FROM Margin_Item_Exclusion_Template
        WHERE Margin_Item_Exclusion_ID = <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>

       <!--- INSERT THE GROUP IDs --->
    <cfloop index = "Group_ID"  list ="#GroupListVL#">
      <cfquery name="qInsAddItemsExcludeProducts" datasource="#application.datasource#">
        INSERT INTO Margin_Item_Exclusion_Products
        (
          Margin_Item_Exclusion_ID,
          Product_Group_Level_ID,
          Product_Group_ID
        )
        VALUES
        (
          <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>,
          <cfqueryparam value="#arguments.GroupLevel#" cfsqltype="cf_sql_integer"/>,
          <cfqueryparam value="#Group_ID#" cfsqltype="cf_sql_varchar"/>
        )
      </cfquery>
    </cfloop>
    <!--- INSERT THE PRODUCTS --->
    <cfloop index = "Product_ID"  list ="#ProductListVL#">
      <cfquery name="qInsAddItemsExcludeProducts" datasource="#application.datasource#">
        INSERT INTO Margin_Item_Exclusion_Products
        (
          Margin_Item_Exclusion_ID,
          Product_Group_ID
        )
        VALUES
        (
          <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>,
          <cfqueryparam value="#Product_ID#" cfsqltype="cf_sql_varchar"/>
        )
      </cfquery>
    </cfloop>

    <!--- INSERT THE TEMPLATES --->
    <cfloop index = "Template_ID"  list ="#TemplateListVL#">
      <cfquery name="qInsAddItemsExcludeTemplate" datasource="#application.datasource#">
        INSERT INTO Margin_Item_Exclusion_Template
        (
          Margin_Item_Exclusion_ID,
          Program_Template_ID
        )
        VALUES
        (
          <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>,
          <cfqueryparam value="#Template_ID#" cfsqltype="cf_sql_varchar"/>
        )
      </cfquery>
    </cfloop>
    <cfset StructDelete(Session, "FormData")>
  <cfelse>
    <cfset returnValue = "1" />
  </cfif>

    <cfreturn returnValue />
  </cffunction>

  <!--- This function deletes an exclusion record --->
    <cffunction name="delete" output="false" returntype="void" >
      <cfargument name="MarginItemExclusionID" type="string" required="true" />

     	<cfquery name="qUpdItemsExclude" datasource="#application.datasource#">
        UPDATE Margin_Item_Exclusion
        SET DELETED = 1
        WHERE Margin_Item_Exclusion_ID = <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>

     	<cfquery name="qUpdItemsExcludeProducts" datasource="#application.datasource#">
        UPDATE Margin_Item_Exclusion_Products
        SET DELETED = 1
        WHERE Margin_Item_Exclusion_ID = <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>

      <!--- UPDATE ALL THE TEMPLATES SET DELETED = 1 AND THEN REINSERT THEM INTO THE TABLES --->

      <cfquery name="qUpdItemsExcludeTemplates" datasource="#application.datasource#">
        UPDATE Margin_Item_Exclusion_Template
        SET DELETED = 1
        WHERE Margin_Item_Exclusion_ID = <cfqueryparam value="#arguments.MarginItemExclusionID#" cfsqltype="cf_sql_integer"/>
      </cfquery>
     </cffunction>

</cfcomponent>