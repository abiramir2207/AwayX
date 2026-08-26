<!-----------------------------------------------------------------------------

FILE NAME:		BillbackList.cfm
DESCRIPTION:	Displays the list of BB that relates to the given Shr_Ship_TO
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	07-Jul-2015	 

------------------------------------------------------------------------------> 
<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
<cfparam name="URL.src" default="" />
<cfparam name="URL.shrShipTo" default="" />

<cfset URL.PageTitle="Billback List">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">
<cfoutput>
	<cfif URL.src EQ "Dist">
		<cfset useLakebaseForshrShipToInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForshrShipToInfo>
	<cftry>
		<cfset shrShipToInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"ship_to" = "eq.#URL.shrShipTo#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForshrShipToInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForshrShipToInfo>
<cfquery name="shrShipToInfo" datasource="#application.datasource#">
			SELECT * FROM BSA_Foodservice_Customers WHERE Ship_To = '#URL.shrShipTo#'
		</cfquery>
</cfif>
		<cfquery name="qryBBList" datasource="#application.datasource#">
			SELECT BB.BB_Code,BB.BB_Title,BB.Billback_ID, CM.Ship_To,CM.Default_Vendor_ID,CM.Default_Billback_Closing_Method_ID
			FROM Billback BB
			INNER JOIN	Billback_Distributor bd  
			ON			bd.Billback_ID = BB.Billback_ID  
			AND			bd.Deleted = 0  
			INNER JOIN	BSA_Foodservice_Customers cm  
			ON			cm.BSA_Foodservice_Customers_ID = bd.Distributor_ID   
			WHERE BB.Deleted = 0
			AND BB.Billback_Payee_Type_ID = 1  
			AND CM.Ship_To = '#URL.shrShipTo#'
		</cfquery>
		<div style="width:100%; margin:5px;font-size:14px;">
			<div style="width:100%;float:left;"><b>Name:</b> #shrShipToInfo.Name#(#URL.shrShipTo#)</div> 
		</div>
	<cfelseif URL.src EQ "Opr">
		<cfquery name="shrShipToInfo" datasource="#application.datasource#">
			SELECT * FROM BSA_Operator WHERE Legacy_ID = '#URL.shrShipTo#'
		</cfquery>
	
		<cfquery name="qryBBList" datasource="#application.datasource#">
			SELECT BB.BB_Code,BB.BB_Title,BB.Billback_ID , BSAOP.Legacy_ID,BSAOP.Default_Vendor_ID,BSAOP.Default_Billback_Closing_Method_ID
			FROM Billback BB
			INNER JOIN	Billback_Operator BO
			ON			BO.Billback_ID = BB.Billback_ID  
			AND			BO.Deleted = 0  
			INNER JOIN	BSA_Operator BSAOP  
			ON			BSAOP.BSA_Operator_ID = BO.Operator_ID  
			WHERE BB.Deleted = 0
			AND BB.Billback_Payee_Type_ID = 2
			AND BSAOP.Legacy_ID = '#URL.shrShipTo#'
		</cfquery>
		<div style="width:100%; margin:5px;font-size:14px;">
			<div style="width:100%;float:left;"><b>Name:</b> #shrShipToInfo.Operator_Name#(#URL.shrShipTo#)</div> 
		</div>
	</cfif>
</cfoutput> 
<br>
<br>
<cfoutput> 
	<!--- <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [5.0, 5.0] )> --->
	<table class="datagrid">
	  <thead>
	    <th class="header" width="25%"><b>BB Code</b></th>
	    <th class="header" width="75%"><b>Title</b></th>
	  </thead>
	  <tbody>
		<cfset getdata_message = '<tr><td colspan="100" style="font-size:16px; text-align:center;">Processing..... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15"></td></tr>'>
	    #getdata_message#
	  </tbody>
	</table>
</cfoutput>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<script>
oTable = $('.datagrid').dataTable( {
      "bServerSide": true
    , "bProcessing": true
    , "bSortClasses": false
	, "bAutoWidth": false
    , "iDisplayLength": 20
    , "oLanguage": {"sSearch": "<b>Search:</b>"} 
    , "sAjaxSource": "ajax/BillbackList.cfm?src=<cfoutput>#URL.src#</cfoutput>&shrShipTo=<cfoutput>#URL.shrShipTo#</cfoutput>"
    , "sDom": "fprti"
    , "aaSorting": []
    , "aoColumns": [  		
						 {"bSearchable": true,  "bSortable":true}
	                    ,{"bSearchable": true, 	"bSortable":true}
	                           ]
} ).fnSetFilteringDelay();
</script> 
