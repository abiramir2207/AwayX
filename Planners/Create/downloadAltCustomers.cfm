<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/downloadAltCustomers.cfm
Copyright    :  (c) 2022 Blacksmith Applications, Inc.
Created Date :  02-Mar-2022
Created By   :  Anand Rao
Description  :  File for downloading the alternate customers.
---------------------------------------------------------------------------------->

<cfparam name="URL.programID" default="0" />
<cfquery name="getGroups" datasource="#application.datasource#">
	SELECT
		BSA_Foodservice_Customers.Name 	Customer_Group_Description,
		BSA_Foodservice_Customers.Shr_Ship_To,
		BSA_Foodservice_Customers.Ship_To Customer_Group_Number,
		BSA_Foodservice_Customers.City,
		BSA_Foodservice_Customers.State,
		BSA_Foodservice_Customers.Address_1,
		BSA_Foodservice_Customers.zipcode,
		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
		Contract_Distributors.Distributor_Group_Level_ID ,
		Contract_Distributors.Distributor_Group_ID,
		Contract_Distributors.Is_Group,
		Contract_Distributors.Alternate_Customer_Flag,
		DGL.Group_Level_Desc Customer_Group_Type_Description
  
	FROM	Contract_Distributors
			INNER JOIN	BSA_Foodservice_Customers
			ON
			Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
            LEFT JOIN BSA_Foodservice_Brokers
			ON
			BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID   				
			INNER JOIN Distributor_Group_Level DGL ON DGL.Distributor_Group_Level_ID = Contract_Distributors.Distributor_Group_Level_ID
	WHERE
			Contract_Distributors.Contract_Main_ID = '#URL.programID#'
			AND Contract_Distributors.Deleted = 0
			AND Captured_From_Group = 0
			AND Is_Group = 1
			AND Contract_Distributors.Alternate_Customer_Flag = 1
			ORDER BY BSA_Foodservice_Customers.Name
</cfquery>
<cfquery name="getIndDists" datasource="#application.datasource#"> 
	SELECT  BSA_Foodservice_Customers.Name AS Customer_Name ,
	        BSA_Foodservice_Customers.Shr_Ship_To ,
	        BSA_Foodservice_Customers.Ship_To AS Customer_Number,
	        BSA_Foodservice_Customers.City ,
	        BSA_Foodservice_Customers.State ,
	        BSA_Foodservice_Customers.Address_1 ,
	        BSA_Foodservice_Customers.ZipCode ,
	        BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID ,
	        Contract_Distributors.Distributor_Group_Level_ID ,
			CASE WHEN Contract_Distributors.Distributor_Group_ID IS NULL 
					THEN 'Distributor'
				ELSE 	BSAFC2.Name 
				END AS Customer_Description,
			CASE WHEN BSAFC2.ship_to IS NULL
					THEN 'N/A'
					ELSE BSAFC2.ship_to
					END AS Customer_Group_Number,
	        Contract_Distributors.Is_Group ,
	        Contract_Distributors.Is_On_Quote_Letter ,
	        Contract_Distributors.Alternate_Customer_Flag
	 
	FROM    Contract_Distributors
	        INNER JOIN BSA_Foodservice_Customers ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	        LEFT JOIN BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
			LEFT JOIN Distributor_Group_Level DGL ON DGL.Distributor_Group_Level_ID = Contract_Distributors.Distributor_Group_Level_ID
			LEFT JOIN BSA_Foodservice_Customers BSAFC2 ON BSAFC2.BSA_Foodservice_Customers_ID = Contract_Distributors.Distributor_Group_ID
	WHERE    Contract_Distributors.Contract_Main_ID = '#URL.programID#' 
	        AND Contract_Distributors.Deleted = 0 
	        AND Is_Group = 0
	ORDER BY BSA_Foodservice_Customers.Name
</cfquery>

<cfscript>
    output_file     = "Alternate_customers.xls";
    output_fullpath = expandPath( '/common_documents/temp_files/' ) & output_file;
</cfscript>

<cfquery name="qoqInd" dbtype="query">
    SELECT  Customer_Description,
		 Customer_Group_Number,
		 Customer_Number,
		 Customer_Name
    FROM getIndDists
</cfquery>  
<cfloop query="qoqInd">
	<cfscript>
		qoqInd[ "Customer_Description" ][ qoqInd.currentRow ] = application.util.string.stripHTML(qoqInd[ "Customer_Description" ][ qoqInd.currentRow ]);
		qoqInd[ "Customer_Group_Number" ][ qoqInd.currentRow ]      = application.util.string.stripHTML(qoqInd[ "Customer_Group_Number" ][ qoqInd.currentRow ]);
       	qoqInd[ "Customer_Number" ][ qoqInd.currentRow ]      = application.util.string.stripHTML(qoqInd[ "Customer_Number" ][ qoqInd.currentRow ]);
       	qoqInd[ "Customer_Name" ][ qoqInd.currentRow ]        = application.util.string.stripHTML(qoqInd[ "Customer_Name" ][ qoqInd.currentRow ]);
   </cfscript>
</cfloop>
<cfscript>
	sheet_name = "Customer Members";
	sheet[1] = application.util.query.createExcelSheet(query=qoqInd, sheet_name=sheet_name);
</cfscript>  

<cfif (isDefined("getGroups") AND getGroups.RecordCount GTE 1)>
	<cfquery name="qoqGrp" dbtype="query">
	     SELECT Customer_Group_Type_Description,
				Customer_Group_Number,
				Customer_Group_Description
	     FROM getGroups
	 </cfquery>
	<cfloop query="qoqGrp">
	    <cfscript>
	        qoqGrp[ "Customer_Group_Type_Description" ][ qoqGrp.currentRow ] = application.util.string.stripHTML(qoqGrp[ "Customer_Group_Type_Description" ][ qoqGrp.currentRow ]);
	        qoqGrp[ "Customer_Group_Number" ][ qoqGrp.currentRow ]      	= application.util.string.stripHTML(qoqGrp[ "Customer_Group_Number" ][ qoqGrp.currentRow ]);
	        qoqGrp[ "Customer_Group_Description" ][ qoqGrp.currentRow ]      = application.util.string.stripHTML(qoqGrp[ "Customer_Group_Description" ][ qoqGrp.currentRow ]);
	    </cfscript>
	</cfloop>
	
	<cfscript>
	    sheet_name = "Groups";
	    sheet[2] = application.util.query.createExcelSheet(query=qoqGrp, sheet_name=sheet_name);
	</cfscript> 	 
</cfif>
<!--- generate excel file from query --->
<cfscript>
    single_sheet = sheet[1];
    cfspreadsheet( action="write", fileName="#output_fullpath#", name="single_sheet", overwrite=true );
</cfscript>
<cfif (isDefined("getGroups") AND getGroups.RecordCount GTE 1)>
	<cfscript>
	 single_sheet = sheet[2];
    cfspreadsheet( action="update", fileName="#output_fullpath#", name="single_sheet" );
	</cfscript>
</cfif>
<!--- download excel file to browser --->
<cfoutput>
<cfheader  name = "Content-Disposition" value = "attachment;filename=#output_file#">
<cfcontent type = "application/vnd.ms-excel" file = "#output_fullpath#" deletefile = "true">
</cfoutput>