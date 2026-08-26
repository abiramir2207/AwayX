<!---------------------------------------------------------------------------------------------------------------------
      Template: \Templates\Paginate.cfm
      Date:     May 24, 2011
      Author:   Chris Nguyen
      Purpose:  Speed up web page performance by applying Row_Number() to database query and returning only rows 
                needed for a specific page
      
      Parameters:  sql_statement: required, SQL code to gather db records (do not include the order by clause)
                   sql_orderby  : required, SQL order by clause
                   
                   page_size    : optional, default to 25 rows
                   page_number  : optional, default 1 
                   page_count   : optional, recommended value is false (not returning total page count)

                   start_row    : optional, starting row number
                   result       : optional, name of the returning variable (if not specified 'paginate' is used)
                                      
      Example 1: <cfmodule template = "\templates\paginate.cfm"
                      page_number   = 5
                      page_size     = 50
                      page_count    = false
                      result        = "qContacts"
                      sql_statement = "select * from external_contacts"
                      sql_orderby   = "contact_id">

      Example 2: <cfmodule template = "\templates\paginate.cfm"
                      page_number   = 5
                      page_size     = 10
                      page_count    = false
                      result        = "qCodes"
                      sql_statement = "select * from ( select distinct company_code from external_contacts ) ec"
                      sql_orderby   = "company_code">

      Example 3: <cfsavecontent variable="getProducts">
                    SELECT Product_Table.bsa_FoodService_Items_Master_Id
                           , Product_Table.Description
                           , Product_Table.Active_Code
                           , Line_Of_Business.Line_Of_Business_Name
                           , Line_Of_Business.Line_Of_Business
                           , Product_Table.Type_Group_desc_Id
                           , Product_Table.Upc
                           , Product_Table.Item
                           , Type_Code_desc.Type_Code_desc
                           , Brand.Brand_Name
                           , q_Brand_Table.q_Brand_Id
                           , q_Brand_Table.q_Brand
                           , Type_Group_desc.Type_Group_desc
                           , Product_Table.Catch_Weight
                           , Product_Table.Gross_Weight
                           , Product_Table.Net_Weight
                           , Product_Table.Inven_uom
                           , Product_Table.Shelf_Life
                           , Product_Table.Length
                           , Product_Table.Width
                           , Product_Table.Height
                           , Product_Table.Cases_Layer
                           , Product_Table.Layers_Pallet
                           , Product_Table.Cases_Pallet
                           , Product_Table.Case_Cube
                           , Product_Hierarchy.Product_Hierarchy
                           , Product_Hierarchy.Product_Hierarchy_Id
                           , Product_Hierarchy.Product_Hierarchy_Name
                      FROM bsa_FoodService_Items_Master Product_Table
                           INNER JOIN Line_Of_Business ON Line_Of_Business.Line_Of_Business_Id = Product_Table.Line_Of_Business_Id
                           INNER JOIN Type_Code_desc ON Product_Table.Type_Code_desc_Id = Type_Code_desc.Type_Code_desc_Id
                           INNER JOIN Brand ON Product_Table.Brand_Id = Brand.Brand_Id
                           INNER JOIN Product_q_Brand_desc ON Product_Table.bsa_FoodService_Items_Master_Id = Product_q_Brand_desc.bsa_FoodService_Items_Master_Id
                                                              AND Product_q_Brand_desc.Lob = Line_Of_Business.Line_Of_Business
                           INNER JOIN q_Brand_desc q_Brand_Table ON Product_q_Brand_desc.q_Brand_Id = q_Brand_Table.q_Brand_Id
                           INNER JOIN Type_Group_desc ON Product_Table.Type_Group_desc_Id = Type_Group_desc.Type_Group_desc_Id
                           LEFT JOIN Product_Hierarchy ON Product_Table.Product_Hierarchy_Id = Product_Hierarchy.Product_Hierarchy_Id
                                                          AND Product_Hierarchy.Deleted = 0
                     WHERE Product_Table.Deleted = 0
                           AND Product_Table.Category_Id IN ( 'bb5fdb6f-e1a2-4950-bd57-1a1387c65b1d' )
                           AND Product_Table.Active_Code = 'A'
                           AND Product_Table.Description LIKE '%nugget%' 
                 </cfsavecontent>					
                 <cfmodule
                             template      = "/templates/paginate.cfm"
                             page_number   = #url.page#
                             page_size     = 200
                             page_count    = false
                             sql_statement = #getProducts#
                             sql_orderby   = "Product_Table.Item"
                             result        = "qProducts"/>

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="attributes.page_size"       default="25">            <!--- number of rows to display per page        --->
<cfparam name="attributes.page_number"     default="0">             
<cfparam name="attributes.start_row"       default="0">             <!--- if specified, returns rows starting from this 
                                                                          row number --->
<cfparam name="attributes.result"          default="paginate">      <!--- returning variable name --->

<cfparam name="attributes.debug_log_file"  default="">              <!--- debug log file --->
<cfparam name="attributes.append_debug_log_file" default="0">       <!--- append to debug log file? --->
 
<cfscript>
  vars = StructNew();
  // remove the select keyword from sql_statement
  vars.sql_statement = ReplaceNoCase(attributes.sql_statement, "select ", "");
  
  // if page number and start row are not specified starts from row 1
  if ( ( attributes.page_number eq 0 ) and ( attributes.start_row eq 0 ) ) {
    attributes.start_row = 1;
  }
  
  // if page number is specified but not the starting row calculate the starting row
  else if ( attributes.start_row eq 0 ) {
    attributes.start_row = ( attributes.page_number - 1 ) * attributes.page_size + 1;
  }
  
  vars.ending_row = attributes.start_row + attributes.page_size - 1;
</cfscript>

<cfoutput>
<cfquery name="vars.recordSet" datasource="#application.datasource#" result="sqlResult">
  SELECT *
    FROM ( SELECT Row_number() OVER ( ORDER BY #PreserveSingleQuotes(attributes.sql_orderby)# ) AS Paginate_Row_Number
<!--- slow operation - commented it out, use a different query for total rows count
							 <cfif attributes.total_row_count>
                  , Page_Count = CEILING( COUNT(1) OVER() / CAST(#attributes.page_size# AS FLOAT) )
               </cfif>
--->                  
                    , #PreserveSingleQuotes(vars.sql_statement)#
                  ) AS Paginate
   WHERE Paginate_Row_Number >= #attributes.start_row# 
     AND Paginate_Row_Number <= #vars.ending_row#
</cfquery>
</cfoutput>

<cfset caller[attributes.result] = vars.recordSet>

<cfif len(trim(attributes.debug_log_file))>
	<!---start with an empty debug log file --->
	<cfif not attributes.append_debug_log_file>
		<!---delete existing debug log file if it exists--->
		<cfif FileExists(attributes.debug_log_file)>
			<cffile action="delete" file="#attributes.debug_log_file#"> 
		</cfif>
	</cfif>
	
	<!---dump the sql result out to debug log file--->
	<cfdump var="#sqlResult#" output="#attributes.debug_log_file#" format="html" showudfs="false" metainfo="false">
</cfif>