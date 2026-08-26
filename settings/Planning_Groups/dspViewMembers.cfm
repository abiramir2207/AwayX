

<cfparam name="URL.PGOperatorCategoryID" default="">
<cfset iCounter = 1/>
<cfset  CURRENTROW = 1 />
<cfif isDefined("URL.PGOperatorCategoryID") AND URL.PGOperatorCategoryID NEQ "">
	<cfset useLakebaseForOperatorCategoryDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pg_operator_category")>
<cfif useLakebaseForOperatorCategoryDetails>
	<cftry>
		<cfset OperatorCategoryDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pg_operator_category", {
				"pg_operator_category_id" = "eq.#URL.PGOperatorCategoryID#",
				"select" = "pg_type_id,pg_operator_category_code,pg_operator_category_name"
			}), "pg_type_id,pg_operator_category_code,pg_operator_category_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOperatorCategoryDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOperatorCategoryDetails>
<cfquery name="OperatorCategoryDetails" datasource="#application.datasource#">
		SELECT PG_Type_ID, PG_Operator_Category_Code, PG_Operator_Category_Name FROM PG_Operator_Category where PG_Operator_Category_ID ='#URL.PGOperatorCategoryID#'
	</cfquery>
</cfif>
	<cfstoredproc procedure="Get_Operator_Group_Info_For_PG" datasource="#application.datasource#">
		<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@@PG_Operator_Category_ID" value = "#URL.PGOperatorCategoryID#" null="no">
	  <cfprocresult name="qryPGOperatorCategoryDefinitionByID">    
	</cfstoredproc>
</cfif>
<html>
<head>
	<title>Planning Group</title>
</head>

<body>
<cfoutput>
<center>
<input type="button" onclick="javascript:window.close();" value="Close Window"  title="Close Window"/>
</center><br>

   
       <cfif isDefined("qryPGOperatorCategoryDefinitionByID.RecordCount") AND qryPGOperatorCategoryDefinitionByID.RecordCount EQ 0>
         No Members Found!!
        <cfelse>
		<br>
    	<strong> <u>#OperatorCategoryDetails.PG_Operator_Category_Name#(#OperatorCategoryDetails.PG_Operator_Category_Code#)</u> has the following Members included:</strong>
    	<br><br>
         <table bgcolor="##ffffce" border="1" borderColor="##330099" cellpadding="2" cellspacing="1" width="100%">
          <tr bgcolor="##cc9999">
            <td width="30%" style="font-weight:bold;font-size:8pt">
              <strong>Group/#application.returned_customer_setting.Operator_Label_Singular# Type</strong>
            </td>
            <td width="25%" style="font-weight:bold;font-size:8pt"><strong>Group/#application.returned_customer_setting.Operator_Label_Singular# Name</strong></td>
            <td width="20%" style="font-weight:bold;font-size:8pt"><strong>Group/#application.returned_customer_setting.Operator_Label_Singular# Number</strong></td>
            <td width="10%" style="font-weight:bold;font-size:8pt"><strong>Include/Exclude</strong></td>
					 <cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
					  <td width="15%" style="font-weight:bold;font-size:8pt"><strong>#appsettings.Business_Segment_Label#</strong></td>
					 </cfif>						
          </tr>
       
          <cfloop query = "qryPGOperatorCategoryDefinitionByID">          
          <tr>
            <td>#Trim(qryPGOperatorCategoryDefinitionByID.Group_Desc)#&nbsp;</td>
            <td>#Trim(qryPGOperatorCategoryDefinitionByID.Group_Name)#&nbsp;</td>          
            <td><cfif qryPGOperatorCategoryDefinitionByID.Group_Number EQ "">&nbsp;<cfelse>#qryPGOperatorCategoryDefinitionByID.Group_Number#</cfif></td>          
            <td><cfif (qryPGOperatorCategoryDefinitionByID.Inclusion_Exclusion)>Include<cfelse>Exclude</cfif></td>     
						<cfif (application.returned_customer_setting.Business_Segments_On EQ 1)>
							<td>#qryPGOperatorCategoryDefinitionByID.Business_Unit_Desc#&nbsp;</td>    
						</cfif>						     
          </tr>
          </cfloop> 
          </table>
      </cfif>          
       
      
    <cfset iCounter = iCounter + 1 />
    <cfset CURRENTROW =  CURRENTROW + 1 />    

<br>

<center>
<input type="button" onclick="javascript:window.close();" value="Close Window"  title="Close Window"/>
</center>
</cfoutput>
</body>
</html>
