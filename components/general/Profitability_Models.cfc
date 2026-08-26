<!--------------------------------------------------------------------------------------------------------------------------------------------------------
  Component: \components\general\Profitability_Models.cfc
  Date:      Feb 2013
  Author:    Chris Nguyen
    
  Remarks:  
  
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Profitability Model" output="no" hint="Houses all the profitability model functions.">

  <!--- TODO: remember to change this to zero prior to checking into CVS --->
  <cfset developer.mode = 0>
  <cfset developer.maxRecords = 450>

	<cffunction name="isHeadQuarters" output="false" access="public" returnType="boolean" hint="Return true if current user has headquarters position">
		<cfquery name="local.query" Datasource="#application.datasource#">
			SELECT 1
			  FROM USER_POSITION_HOLDERS a
			       INNER JOIN USER_POSITIONS b ON b.User_Positions_Id = a.User_Positions_Id
			 WHERE a.Deleted = 0
			       AND a.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">
			       AND b.Position_Label = 'headquarters'
		</cfquery>

		<cfreturn (local.query.recordCount gt 0)>
	</cffunction>
	
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getPositionBelowMe" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT Below_User_Positions_Id
        FROM POSITIONS_BELOW_ME pbm
       WHERE Below_User_Positions_Id IS NOT NULL
             AND pbm.User_Positions_Id IN ( SELECT uph.User_Positions_Id
                                              FROM USER_POSITION_HOLDERS uph
                                             WHERE uph.Deleted = 0
                                                   AND Uph.User_Id = <cfqueryparam value="#request.AccessStructure.user_ID#" cfsqltype="cf_sql_varchar">)    
		</cfquery> 
    <cfreturn local.query>  
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getSettings" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT *
        FROM Profit_Settings
    </cfquery> 
    <cfreturn local.query>  
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveSettings" access="public" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      UPDATE Profit_Settings
         SET Marketing_Cost_Percentage = <cfqueryparam value="#form.Marketing_Cost_Percentage#" cfsqltype="cf_sql_decimal">
             ,SGA_Cost_Percentage = <cfqueryparam value="#form.SGA_Cost_Percentage#" cfsqltype="cf_sql_decimal">
             ,Other_SGA_Cost_Percentage = <cfqueryparam value="#form.Other_SGA_Cost_Percentage#" cfsqltype="cf_sql_decimal">
    </cfquery> 
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getOperatorDistributorSpend" access="public" returntype="query" output="false">
    <cfargument name="operatorNumber" required="true" hint="BSA_Operator_ID for individual operator, PG_Operator_Category_ID for planning group">
    <cfargument name="productGroupID" required="true" hint="group GUID, for All value use '00000000-0000-0000-0000-000000000000'">
    <cfargument name="productClass" required="true" hint="total | branded | private label">
    
    <cfquery name="local.query" datasource="#application.datasource#">
    	SELECT Classification_Name
    	       , Abs_ty = SUM( ISNULL(Abs_ty, 0) )
    	       , Abs_ly = SUM( ISNULL(Abs_ly, 0) )
    	       , Abs_ch = SUM( ISNULL(Abs_ch, 0) )
    	       , Abs_pct_ch = SUM( ISNULL(Abs_pct_ch, 0) )
    	  FROM Prof_Model_Operator_Report_Distributor_Spend a
       WHERE a.Operator_Group_ID = <cfqueryparam value="#arguments.operatorNumber#">
             AND a.Product_Class = <cfqueryparam value="#arguments.productClass#">
             AND a.Product_Group_ID  = <cfqueryparam value="#arguments.productGroupID#">    
        GROUP BY Classification_Name
    </cfquery> 

    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getOperatorProfitReport" access="public" returntype="query" output="false">
    <cfargument name="operatorNumber" required="true" hint="BSA_Operator_ID for individual operator, PG_Operator_Category_ID for planning group">
    <cfargument name="productGroupID" required="true" hint="group GUID, for All value use '00000000-0000-0000-0000-000000000000'">
    <cfargument name="productClass" required="true" hint="total | branded | private label">
    
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT a.*
             ,b.Position_Label
        FROM Prof_Model_Operator_Report  a
        LEFT JOIN USER_POSITIONS b ON b.User_Positions_Id = a.User_Position_Id
       WHERE a.Operator_Group_ID = <cfqueryparam value="#arguments.operatorNumber#">
             AND a.Product_Class = <cfqueryparam value="#arguments.productClass#">    <!--- total | branded | private label --->
             AND a.Product_Group_ID  = <cfqueryparam value="#arguments.productGroupID#">    
    </cfquery>

    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getOperatorProfitDetail" access="public" returntype="query" output="false">
    <cfargument name="operatorNumber" required="true" hint="BSA_Operator_ID for individual operator, PG_Operator_Category_ID for planning group">
    <cfargument name="productGroupID" required="true" hint="group GUID, for All value use '00000000-0000-0000-0000-000000000000'">
    <cfargument name="productClass" required="true" hint="total | branded | private label">
    
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT *
        FROM Prof_Model_Operator_Report_Detail a
       WHERE a.Operator_Group_ID = <cfqueryparam value="#arguments.operatorNumber#">
             AND a.Product_Class = <cfqueryparam value="#arguments.productClass#">    <!--- total | branded | private label --->
             AND a.Product_Group_ID  = <cfqueryparam value="#arguments.productGroupID#">    
        ORDER BY Distributor_Name
    </cfquery>

    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="pullProducts" access="remote" returntype="string" output="false" hint="This Ajax function returns products based on argument filter">
      <cfargument name="searchInput" type="string" required="yes" hint="filtering string (multiple words) input">
      <cfargument name="page" type="numeric" required="true" hint="current displaying page number">
      <cfargument name="page_limit" type="numeric" default="10" hint="number of entries on a page">

      <cfscript>
				var loc = {};
				
       loc.startRow  = (arguments.page * arguments.page_limit) - arguments.page_limit + 1;
       loc.endRow    = loc.startRow + arguments.page_limit;
       loc.words     = reMatch("[[:word:]]+", arguments.searchInput);   // parse filtering string into an array of words
       loc.wordsList = arrayToList(loc.words, "%");

       loc.results = {};
       loc.products = [];
      </cfscript>
      
      <!--- search for entries that match the filtering string (multiple words) --->
      <cfquery name="loc.getProducts" datasource="#application.datasource#">
        SELECT t.Group_GUID
              ,t.Group_Desc
              ,t.Group_Number
          FROM ALL_PRODUCT_GROUP_TYPES t
               INNER JOIN PRODUCT_GROUP_LEVEL l ON l.Product_Group_Level_Id = t.Product_Group_Level_Id
                                               AND l.Product_Group_Level_Id = 12
         WHERE t.Deleted = 0 
                 AND ( t.Group_Desc LIKE '%#loc.wordsList#%'
                        OR t.Group_Number LIKE '%#loc.wordsList#%' )
               ORDER BY t.Group_Desc 
      </cfquery>

			<!--- narrow down the matching entries to just what is needed on the page --->
      <!--- use default keys: "id" and "text" --->  
      <cfloop query="loc.getProducts" startRow="#loc.startRow#" endRow="#loc.endRow#">
        <cfscript>
          loc.elem = {};
          loc.elem["id"] = loc.getProducts.Group_GUID;
          loc.elem["text"] = loc.getProducts.Group_Desc & ' ( ' & loc.getProducts.Group_Number & ' )';
          arrayAppend(loc.products, loc.elem);
        </cfscript>
      </cfloop>

       <!--- package the loc.results into a structure --->  
      <cfset loc.results["total"] = loc.getProducts.recordCount>
      <cfset loc.results["products"] = loc.products>

      <cfcontent type="application/json" reset="true">
      <cfoutput>#serializeJSON(loc.results)#</cfoutput>
			<cfabort>      
    </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="pullOperators" access="remote" returntype="string" output="false">
      <cfargument name="searchInput" type="string" required="yes">
      <cfargument name="searchCategory" type="string" required="true">
      <cfargument name="page" type="numeric" required="true">
      <cfargument name="page_limit" type="numeric" default="10">
      <cfargument name="below_me_positions" type="string" default="">  <!---HQ position should have "ALL" value for this argument--->

      <cfscript>
       var loc = {};
       loc.startRow = (arguments.page * arguments.page_limit) - arguments.page_limit + 1;
       loc.endRow = loc.startRow + arguments.page_limit;

       loc.results = {};
       loc.operators = [];
       loc.words = reMatch("[[:word:]]+", arguments.searchInput);
       loc.wordsList = arrayToList(loc.words, "%");
      </cfscript>
      
      <cfquery name="loc.getOperators" datasource="#application.datasource#">
        <cfif arguments.searchCategory eq 'group'>
					SELECT DISTINCT pg.pg_Operator_Category_Name
					                ,pg.pg_Operator_Category_Id
					  FROM CONTRACT_MAIN cm
					       INNER JOIN CONTRACT_OPERATORS co ON co.Contract_Main_Id = cm.Contract_Main_Id
					                                           AND co.Deleted = 0
					       INNER JOIN PG_OPERATOR_MEMBERS m ON m.bsa_Operator_Id = co.bsa_Operator_Id
					                                           AND m.Deleted = 0
					       INNER JOIN PG_OPERATOR_CATEGORY pg ON pg.pg_Operator_Category_Id = m.pg_Operator_Category_Id
					                                             AND pg.Deleted = 0
					                                             AND pg.pg_Operator_Category_Name LIKE '%#loc.wordsList#%'
					 WHERE cm.Deleted = 0
					       AND cm.Contract_End_Date >= Dateadd( d, -365, Getdate() ) 
									<cfif len( arguments.below_me_positions ) and arguments.below_me_positions neq "ALL">
											AND cm.Creating_User_Position_ID IN ( <cfqueryparam value="#arguments.below_me_positions#" list="true" cfsqltype="numeric"> )
									</cfif>
                ORDER BY pg.PG_Operator_Category_Name
        <cfelse>
						SELECT DISTINCT bo.bsa_Operator_Id
						                ,bo.Operator_Name
						                ,bo.Legacy_Id
						  FROM CONTRACT_MAIN cm
						       INNER JOIN CONTRACT_OPERATORS co ON co.Contract_Main_Id = cm.Contract_Main_Id
						                                           AND co.Deleted = 0
						       INNER JOIN dbo.BSA_OPERATOR bo ON co.bsa_Operator_Id = bo.bsa_Operator_Id
						 WHERE cm.Deleted = 0
						       AND cm.Contract_End_Date >= Dateadd( d, -365, Getdate() ) 
                  AND ( bo.Operator_Name LIKE '%#loc.wordsList#%' 
                        <cfif arrayLen(loc.words) eq 1>
                         OR bo.Legacy_ID LIKE '%#arguments.searchInput#%' 
                        </cfif>
                      )
										<cfif len( arguments.below_me_positions ) and arguments.below_me_positions neq "ALL">
												AND cm.Creating_User_Position_ID IN ( <cfqueryparam value="#arguments.below_me_positions#" list="true" cfsqltype="numeric"> )
										</cfif>
                 ORDER BY Operator_Name       
        </cfif>
      </cfquery>


      <!--- use default keys: "id" and "text" --->  
      <cfloop query="loc.getOperators" startRow="#loc.startRow#" endRow="#loc.endRow#">
        <cfscript>
          loc.elem = {};
          if ( arguments.searchCategory eq 'group' ) {
            loc.elem["id"] = loc.getOperators.PG_Operator_Category_ID;
            loc.elem["text"] = loc.getOperators.PG_Operator_Category_Name;
          }
          else {
            loc.elem["id"] = loc.getOperators.BSA_Operator_ID;
            loc.elem["text"] = loc.getOperators.operator_name & ' ( ' & loc.getOperators.Legacy_ID & ' )';
          }
          arrayAppend(loc.operators, loc.elem);
        </cfscript>
      </cfloop>

       <!--- package the results into a structure --->  
      <cfset loc.results["total"] = loc.getOperators.recordCount>
      <cfset loc.results["operators"] = loc.operators>

      <cfcontent type="application/json" reset="true">
      <cfoutput>#serializeJSON(loc.results)#</cfoutput><cfabort />
    </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getCustomerPG" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT a.PG_Customer_Category_ID
             ,a.PG_Customer_Category_Code
             ,a.PG_Customer_Category_Name
        FROM PG_CUSTOMER_CATEGORY a
       WHERE a.Active = 1
             AND a.Deleted = 0
             AND a.pg_Type_Id IN ( SELECT a2.pg_Type_Id
                                        FROM PROF_MODEL_XREF a2
                                             INNER JOIN PG_TYPE b ON b.pg_Type_Id = a2.pg_Type_Id
                                                                     AND b.Deleted = 0
                                                                     AND b.Active = 1
                                       WHERE     a2.Deleted = 0
                                             AND a2.Is_Included = 1 )
       ORDER BY a.PG_Customer_Category_Name ASC 
    </cfquery>

    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="getOperatorPG" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT a.PG_Operator_Category_ID
             ,a.PG_Operator_Category_Code
             ,a.PG_Operator_Category_Name
        FROM PG_OPERATOR_CATEGORY a
       WHERE a.Active = 1
             AND a.Deleted = 0
             AND a.pg_Type_Id IN ( SELECT a2.pg_Type_Id
                                        FROM PROF_MODEL_XREF a2
                                             INNER JOIN PG_TYPE b ON b.pg_Type_Id = a2.pg_Type_Id
                                                                     AND b.Deleted = 0
                                                                     AND b.Active = 1
                                       WHERE     a2.Deleted = 0
                                             AND a2.Is_Included = 1 )
       ORDER BY a.PG_Operator_Category_Name ASC 
    </cfquery>

    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getItemPG" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT a.PG_Product_Category_ID
             ,a.pg_Product_Category_Code
             ,a.pg_Product_Category_Name
        FROM PG_PRODUCT_CATEGORY a
       WHERE a.Active = 1
             AND a.Deleted = 0
             AND a.pg_Type_Id IN ( SELECT a2.pg_Type_Id
                                        FROM PROF_MODEL_XREF a2
                                             INNER JOIN PG_TYPE b ON b.pg_Type_Id = a2.pg_Type_Id
                                                                     AND b.Deleted = 0
                                                                     AND b.Active = 1
                                       WHERE     a2.Deleted = 0
                                             AND a2.Is_Included = 1 )
       ORDER BY a.pg_Product_Category_Name ASC 
    </cfquery>

    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getItems" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT 
             <cfif developer.mode>TOP <cfoutput>#developer.maxRecords#</cfoutput></cfif>
             a.Prof_Model_Item_Excludes_Id
            <!---,a.Bsa_Foodservice_Items_Master_Id--->
            ,a.Is_Excluded
            ,b.Item
            ,b.Description
            ,d.Type_Code_Desc
            ,g.Type_Group_Desc
            ,b.Active_Code
        FROM Prof_Model_Item_Excludes a 
             INNER JOIN Bsa_Foodservice_Items_Master b ON a.Bsa_Foodservice_Items_Master_Id = b.Bsa_Foodservice_Items_Master_Id 
                                                          AND b.Deleted = 0
                                                          AND b.Item is NOT NULL
             INNER JOIN TYPE_GROUP_DESC g ON g.Type_Group_desc_Id = b.Type_Group_desc_Id                                                          
             INNER JOIN TYPE_CODE_DESC d ON d.Type_Code_desc_Id = b.Type_Code_desc_Id
       WHERE a.Deleted = 0
       ORDER BY b.Description
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="saveItems" access="public" returntype="void" output="false">
    <cfargument name="form" required="true">
    <cfargument name="category" required="false" default="excludes">
    
    <cfloop list="#arguments.form.updated_rows#" index="local.item">
      <!--- remove the leading character from item number --->
      <cfset local.item_ID = right(local.item, len(local.item) - 1)>
      <cfif arguments.category eq "xref">
        <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
            UPDATE  Prof_Model_Item_Xref
              SET  <cfif arguments.form.PG_Operator_Category_ID eq ''>
                      PG_Operator_Category_ID = NULL
                   <cfelse>
                      PG_Operator_Category_ID = <cfqueryparam value="#arguments.form.PG_Operator_Category_ID#">
                   </cfif>
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Item_Xref_Id = <cfqueryparam value="#local.item_ID#" CFSQLType="CF_SQL_NUMERIC">  
        </cfquery>
      <cfelseif arguments.category eq "excludes">
        <!--- if the exclude? checkbox for item is checked the item element in the form would exist; 
              if form item element does NOT exist it means the item was flagged as NOT excluded by users --->
        <cfset local.is_Excluded = structKeyExists(arguments.form, local.item) ? 1 : 0>
        
        <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
            UPDATE  Prof_Model_Item_Excludes
              SET  Is_Excluded = <cfqueryparam value="#local.is_Excluded#" CFSQLType="CF_SQL_BIT">
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Item_Excludes_Id = <cfqueryparam value="#local.item_ID#" CFSQLType="CF_SQL_NUMERIC">  
        </cfquery>
      </cfif>
      <!---<cfdump var="#local#" abort=true>--->
    </cfloop>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getTypeCodes" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Type_Code_Desc
        FROM TYPE_CODE_DESC 
       WHERE Deleted = 0 
            AND RTRIM( COALESCE(Type_Code_Desc, '') ) > ''
       ORDER BY Type_Code_Desc
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getTypeGroups" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Type_Group_Desc
        FROM TYPE_GROUP_DESC 
       WHERE Deleted = 0 
            AND RTRIM( COALESCE(Type_Group_Desc, '') ) > ''
       ORDER BY Type_Group_Desc
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getDistributors" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT 
             <cfif developer.mode>TOP <cfoutput>#developer.maxRecords#</cfoutput></cfif>
             a.Prof_Model_Distributor_Excludes_Id
            ,a.Is_Excluded
            ,b.Ship_To
            ,b.Name
            ,b.Family_Name
            ,b.Buying_Group_Name
            ,b.Active_Code
        FROM Prof_Model_Distributor_Excludes a 
             INNER JOIN Bsa_Foodservice_Customers b ON a.bsa_FoodService_Customers_Id = b.bsa_FoodService_Customers_Id 
                                                          AND b.Deleted = 0
       WHERE a.Deleted = 0
       ORDER BY b.Name
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getFamilyNames" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Family_Name
        FROM Bsa_Foodservice_Customers 
       WHERE Deleted = 0 
            AND RTRIM( COALESCE(Family_Name, '') ) > ''
       ORDER BY Family_Name
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getBuyingGroups" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Buying_Group_Name
        FROM Bsa_Foodservice_Customers 
       WHERE Deleted = 0 
            AND RTRIM( COALESCE(Buying_Group_Name, '') ) > ''
       ORDER BY Buying_Group_Name
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveDistributors" access="public" returntype="void" output="false">
    <cfargument name="form" required="true">
    
    <cfloop list="#arguments.form.updated_rows#" index="local.distributor">
      <!--- if the exclude? checkbox for distributor is checked the input element in the form would exist; 
            if form input element does NOT exist it means the distributor was flagged as NOT excluded by users --->
      <cfset local.is_Excluded = structKeyExists(arguments.form, local.distributor) ? 1 : 0>
      <!--- remove the leading character from distributor number --->
      <cfset local.row_ID = right(local.distributor, len(local.distributor) - 1)>
      
      <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
          UPDATE  Prof_Model_Distributor_Excludes
            SET  Is_Excluded = <cfqueryparam value="#local.is_Excluded#" CFSQLType="CF_SQL_BIT">
                ,Last_Updated_Date = GETDATE()
                ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
           WHERE Prof_Model_Distributor_Excludes_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC">  
      </cfquery>
      <!---<cfdump var="#local#" abort=true>--->
    </cfloop>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getOperators" access="public" returntype="query" output="false">
    <cfargument name="category" required="false" default="excludes">

    <cfquery name="local.query" datasource="#application.datasource#">
      <cfoutput>
      <cfswitch expression="#arguments.category#">
        <cfcase value="excludes">
          SELECT 
                <cfif developer.mode>TOP #developer.maxRecords#</cfif>
                 a.Prof_Model_Operator_Excludes_Id
                ,a.Is_Excluded
                ,b.Operator_Name
                ,b.Legacy_ID
                ,b.Operator_Location_Type
                ,b.Display_Code as Active_Code
            FROM Prof_Model_Operator_Excludes a 
                 INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
                                              AND b.Deleted = 0
           WHERE a.Deleted = 0
           ORDER BY b.Operator_Name
        </cfcase>

        <cfcase value="classifications">
          SELECT 
                <cfif developer.mode>TOP #developer.maxRecords#</cfif>
                 a.Prof_Model_Operator_Classifications_Id
                ,c.Classification_Name
                ,b.Operator_Name
                ,b.Legacy_ID
                ,b.Operator_Location_Type
                ,b.Display_Code as Active_Code
            FROM Prof_Model_Operator_Classifications a 
                 INNER JOIN Bsa_Operator b ON a.bsa_Operator_Id = b.bsa_Operator_Id 
                                              AND b.Deleted = 0
                 LEFT JOIN Prof_Model_Classification c ON a.Prof_Model_Classification_Id = c.Prof_Model_Classification_Id                             
                                              AND c.Deleted = 0
           WHERE a.Deleted = 0
           ORDER BY b.Operator_Name
        </cfcase>
      </cfswitch>
      </cfoutput>
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="saveOperators" access="public" returntype="void" output="true">
    <cfargument name="form" required="true">
    <cfargument name="category" required="false" default="excludes">
    
    <cfloop list="#arguments.form.updated_rows#" index="local.operator">
      <!--- remove the leading character from operator number --->
      <cfset local.row_ID = right(local.operator, len(local.operator) - 1)>
      
      <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
        <cfswitch expression="#arguments.category#">
          <cfcase value="xref">
            UPDATE  Prof_Model_Operator_Xref
              SET  <cfif arguments.form.PG_Customer_Category_ID eq ''>
                      PG_Customer_Category_ID = NULL
                   <cfelse>
                      PG_Customer_Category_ID = <cfqueryparam value="#arguments.form.PG_Customer_Category_ID#">
                   </cfif>
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Operator_Xref_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC"> 
          </cfcase>

          <cfcase value="excludes">
            <!--- if the exclude? checkbox for operator is checked the input element in the form would exist; 
                  if form input element does NOT exist it means the operator was flagged as NOT excluded by users --->
            <cfset local.is_Excluded = structKeyExists(arguments.form, local.operator) ? 1 : 0>

            UPDATE  Prof_Model_Operator_Excludes
              SET  Is_Excluded = <cfqueryparam value="#local.is_Excluded#" CFSQLType="CF_SQL_BIT">
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Operator_Excludes_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC"> 
          </cfcase>

          <cfcase value="classifications">
            UPDATE  Prof_Model_Operator_Classifications
              SET  <cfif arguments.form.Prof_Model_Classification_Id eq ''>
                      Prof_Model_Classification_Id = NULL
                   <cfelse>
                      Prof_Model_Classification_Id = <cfqueryparam value="#arguments.form.Prof_Model_Classification_Id#" CFSQLType="CF_SQL_NUMERIC">
                   </cfif>
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Operator_Classifications_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC">  
          </cfcase>
        </cfswitch>
      </cfquery>
      <!---<cfdump var="#local#" abort=true>--->
    </cfloop>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getOperatorLocationTypes" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Operator_Location_Type
        FROM BSA_OPERATOR
       WHERE Deleted = 0
             AND Rtrim( COALESCE( Operator_Location_Type, '' ) ) > ''
       ORDER BY Operator_Location_Type 
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getTemplates" access="public" returntype="query" output="true">
    <cfargument name="category" required="false" default="excludes">

    <cfquery name="local.query" datasource="#application.datasource#">
      <cfswitch expression="#arguments.category#">
        <cfcase value="excludes">
          SELECT 
                 <cfif developer.mode>TOP #developer.maxRecords#</cfif>
                 a.Prof_Model_Template_Excludes_Id
                ,b.Created_Type
                ,b.Generic_Type
                ,a.Is_Excluded
            FROM Prof_Model_Template_Excludes a 
                 INNER JOIN Program_Control_Panel_Options b ON a.ProgramControl_Panel_Options_ID = b.ProgramControl_Panel_Options_ID 
                                              AND b.Deleted = 0
                                                 AND b.IsDominant = 1
           WHERE a.Deleted = 0
           ORDER BY b.Generic_Type, b.Created_Type
        </cfcase>

        <cfcase value="classifications">
          SELECT 
                 <cfif developer.mode>TOP #developer.maxRecords#</cfif>
                 a.Prof_Model_Template_Classifications_Id
                ,b.Generic_Type
                ,b.Created_Type
                ,c.Classification_Name
            FROM Prof_Model_Template_Classifications a 
                 INNER JOIN Program_Control_Panel_Options b ON a.ProgramControl_Panel_Options_ID = b.ProgramControl_Panel_Options_ID 
                                              AND b.Deleted = 0
                                                 AND b.IsDominant = 1
                 LEFT JOIN Prof_Model_Classification c ON a.Prof_Model_Classification_Id = c.Prof_Model_Classification_Id                             
                                              AND c.Deleted = 0
           WHERE a.Deleted = 0
           ORDER BY b.Generic_Type, b.Created_Type
        </cfcase>
      </cfswitch>
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="saveTemplates" access="public" returntype="void" output="true">
    <cfargument name="form" required="true">
    <cfargument name="category" required="false" default="excludes">
    
    <cfloop list="#arguments.form.updated_rows#" index="local.template">
      <!--- remove the leading character from template number --->
      <cfset local.row_ID = right(local.template, len(local.template) - 1)>
      
      <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
        <cfswitch expression="#arguments.category#">
          <cfcase value="excludes">
            <!--- if the exclude? checkbox for template is checked the input element in the form would exist; 
                  if form input element does NOT exist it means the template was flagged as NOT excluded by users --->
            <cfset local.is_Excluded = structKeyExists(arguments.form, local.template) ? 1 : 0>

            UPDATE  Prof_Model_Template_Excludes
              SET  Is_Excluded = <cfqueryparam value="#local.is_Excluded#" CFSQLType="CF_SQL_BIT">
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Template_Excludes_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC"> 
          </cfcase>

          <cfcase value="classifications">
            UPDATE  Prof_Model_Template_Classifications
              SET  <cfif arguments.form.Prof_Model_Classification_Id eq ''>
                      Prof_Model_Classification_Id = NULL
                   <cfelse>
                      Prof_Model_Classification_Id = <cfqueryparam value="#arguments.form.Prof_Model_Classification_Id#" CFSQLType="CF_SQL_NUMERIC">
                   </cfif>
                  ,Last_Updated_Date = GETDATE()
                  ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
             WHERE Prof_Model_Template_Classifications_Id = <cfqueryparam value="#local.row_ID#" CFSQLType="CF_SQL_NUMERIC">  
          </cfcase>
        </cfswitch>
      </cfquery>
      <!---<cfdump var="#local#" abort=true>--->
    </cfloop>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getGenericTypes" access="public" returntype="query" output="false">
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT DISTINCT Generic_Type
        FROM Program_Control_Panel_Options
       WHERE Deleted = 0
            AND IsDominant = 1
             AND Rtrim( COALESCE( Generic_Type, '' ) ) > ''
       ORDER BY Generic_Type
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>
  
  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getClassifications" access="public" returntype="query" output="false">
    <cfargument name="classification_id" type="numeric" required="false">
    
    <cfquery name="local.query" datasource="#application.datasource#">
      SELECT 
             <cfif developer.mode>TOP <cfoutput>#developer.maxRecords#</cfoutput></cfif>
             a.Prof_Model_Classification_Id
            ,a.Classification_Name
        FROM Prof_Model_Classification a 
       WHERE 1 = 1
             <cfif structKeyExists(arguments, "classification_id")>
              AND a.Prof_Model_Classification_Id = <cfqueryparam value="#arguments.classification_id#" cfsqltype="cf_sql_numeric">
             <cfelse>
              AND a.Deleted = 0
            </cfif>
       ORDER BY a.Classification_Name
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="saveClassification" access="public" returntype="void" output="false">
    <cfargument name="classification_id" type="numeric" required="true">
    <cfargument name="classification_name" type="string" required="true">

    <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
      UPDATE Prof_Model_Classification
         SET Classification_Name = <cfqueryparam value="#arguments.classification_name#" cfsqltype="cf_sql_varchar">
       WHERE Prof_Model_Classification_Id = <cfqueryparam value="#arguments.classification_id#" cfsqltype="cf_sql_numeric">
    </cfquery>
    
    <cfif local.result.recordCount eq 0>
      <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
         INSERT Prof_Model_Classification ( Classification_Name )
                VALUES ( <cfqueryparam value="#arguments.classification_name#" cfsqltype="cf_sql_varchar"> )
      </cfquery>
    </cfif>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="deleteClassification" access="public" returntype="void" output="false">
    <cfargument name="classification_id" type="numeric" required="true">

    <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
      UPDATE Prof_Model_Classification
         SET Deleted = 1
       WHERE Prof_Model_Classification_Id = <cfqueryparam value="#arguments.classification_id#" cfsqltype="cf_sql_numeric">
    </cfquery>

  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->
  
  <cffunction name="getXrefs" access="public" returntype="query" output="false">
    <cfargument name="Prof_Model_Xref_Id" type="numeric" required="false">
    <cfargument name="Is_Included" type="numeric" required="false">
    
    <cfquery name="local.query" datasource="#application.datasource#">
      <!--- find new planning group types and load them in --->
      INSERT INTO PROF_MODEL_XREF
                  (pg_Type_Id)
        SELECT a.pg_Type_Id
          FROM dbo.PG_TYPE a
               LEFT OUTER JOIN PROF_MODEL_XREF b ON a.pg_Type_Id = b.pg_Type_Id
         WHERE a.Deleted = 0
               AND a.Active = 1
               AND b.pg_Type_Id IS NULL

      SELECT 
             a.Prof_Model_Xref_Id
            ,a.Is_Included
            ,a.Pg_Type_Id
            ,b.pg_Type_Name
            ,b.pg_Type_Code
        FROM Prof_Model_Xref a 
             INNER JOIN PG_TYPE b ON b.Pg_Type_Id = a.Pg_Type_Id
                                 AND b.Deleted = 0
                                 AND b.Active = 1
       WHERE 1 = 1
             <cfif structKeyExists(arguments, "Prof_Model_Xref_Id")>
              AND a.Prof_Model_Xref_Id = <cfqueryparam value="#arguments.Prof_Model_Xref_Id#" cfsqltype="cf_sql_numeric">
             <cfelse>
              AND a.Deleted = 0
            </cfif>
             <cfif structKeyExists(arguments, "Is_Included")>
              AND a.Is_Included = <cfqueryparam value="#arguments.Is_Included#" cfsqltype="cf_sql_bit">
            </cfif>
       ORDER BY b.pg_Type_Name
    </cfquery>
    
    <cfreturn local.query>
  </cffunction>

  <!--------------------------------------------------------------------------------------------------------------------------------------------------------->

  <cffunction name="saveXrefs" access="public" returntype="void" output="false">
    <cfargument name="form" required="true">
    
    <cfloop list="#arguments.form.updated_rows#" index="local.item">
      <!--- if the exclude? checkbox for item is checked the item element in the form would exist; 
            if form item element does NOT exist it means the item was flagged as NOT excluded by users --->
      <cfset local.is_Included = structKeyExists(arguments.form, local.item) ? 1 : 0>
      <!--- remove the leading character from item number --->
      <cfset local.item_ID = right(local.item, len(local.item) - 1)>
      
      <cfquery name="local.query" datasource="#application.datasource#" result="local.result">
          UPDATE Prof_Model_Xref
            SET  Is_Included = <cfqueryparam value="#local.is_Included#" CFSQLType="CF_SQL_BIT">
                ,Last_Updated_Date = GETDATE()
                ,Last_Updated_By   = <cfqueryparam value="#request.AccessStructure.User_ID#">
           WHERE Prof_Model_Xref_Id = <cfqueryparam value="#local.item_ID#" CFSQLType="CF_SQL_NUMERIC"> 
      </cfquery>
      <!---<cfdump var="#local#" abort=true>--->
    </cfloop>
  </cffunction>

</cfcomponent>