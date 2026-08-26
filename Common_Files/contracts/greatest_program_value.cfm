<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\greatest_program_value.cfm
      Date:     Oct 4 2012
      Author:   Chris Nguyen
      Purpose:  Validate fixed price item based on greatest program value

																																CMP1	CMP2	CMP3	CMP4
						Scenario									Outcome										ON		ON		OFF		OFF
						------------------------	----------------------		----	----	----	----
						One component = ON				No validation required		10
						One component = OFF				No validation required	 	 						10
						Two components - both ON	No validation required		10		11
						Two components - both OFF	No validation required	 						 	11		12
						On greater than Off				PASS - On > Off is right	10		 			9
						On equal to Off						FAILS - On = or < Off			10		10
						On less than Off					FAILS - On = or < Off			10		11
						One On less than an Off		FAILS - On = or < Off			10		11		11
						One On less than an Off		FAILS - On = or < Off			10		11		10.5	8

----------------------------------------------------------------------------------------------------------------------->

<!--- gather all fixed price components --->
<cfquery name="allFixedPrice" datasource="#application.datasource#">
	SELECT Item
	       ,Description
	       ,PROGRAM_FIXED_COMPONENT_NAME.Greatest_Program_Value
	       ,PROGRAM_FIXED_COMPONENT_NAME.Program_Fixed_Component_Name
	       ,Case_Value = ( CASE PROGRAM_FIXED_PRICE_PRODUCT_DATA.Unit_Of_Measure_Id
	                         WHEN 1 THEN IsNull( Cast( PROGRAM_FIXED_PRICE_PRODUCT_DATA.Fixed_Price_Value AS FLOAT ), 0 )
	                         ELSE IsNull( Cast( PROGRAM_FIXED_PRICE_PRODUCT_DATA.Fixed_Price_Value AS FLOAT ), 0 ) * IsNull( BSA_FOODSERVICE_ITEMS_MASTER.Net_Weight, 0 )
	                       END )
	  FROM PROGRAM_FIXED_PRICE_PRODUCT_DATA
	       INNER JOIN PROGRAM_FIXED_COMPONENT ON PROGRAM_FIXED_COMPONENT.Program_Fixed_Component_Id = PROGRAM_FIXED_PRICE_PRODUCT_DATA.Program_Fixed_Component_Id
	       INNER JOIN PROGRAM_FIXED_COMPONENT_NAME ON PROGRAM_FIXED_COMPONENT_NAME.Program_Fixed_Component_Name_Id = PROGRAM_FIXED_COMPONENT.Program_Fixed_Component_Name_Id
	       INNER JOIN CONTRACT_PRODUCTS ON CONTRACT_PRODUCTS.Contract_Products_Id = PROGRAM_FIXED_PRICE_PRODUCT_DATA.Contract_Products_Id
	                                       AND CONTRACT_PRODUCTS.Contract_Main_Id = PROGRAM_FIXED_PRICE_PRODUCT_DATA.Program_Id
	       INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = CONTRACT_PRODUCTS.bsa_FoodService_Items_Master_Id
	 WHERE PROGRAM_FIXED_PRICE_PRODUCT_DATA.Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.program_id#">
	       AND PROGRAM_FIXED_PRICE_PRODUCT_DATA.Deleted = 0
	       AND PROGRAM_FIXED_COMPONENT.Deleted = 0
	       AND CONTRACT_PRODUCTS.Deleted = 0
	       AND CONTRACT_PRODUCTS.Product_Type_Id = 1       <!---fixed components--->
</cfquery>

<!--- gather gpv with minimum price per item --->
<cfquery name="qGPV" dbtype="query">
	SELECT Item
				 , MIN(case_value) AS Case_Value
				 , 0 AS Failed
	  FROM allFixedPrice
	 WHERE Greatest_Program_Value = 1
	 GROUP BY Item
</cfquery>

<!--- starts comparison of gpv price with other non-gpv prices --->
<cfset greatestProgramValue.failedValidation = false>
<cfloop query="qGPV">
	<!--- find non-gpv with price greater than or equal to gpv price --->
	<cfquery name="qFailure" dbtype="query">
		SELECT 1
		  FROM allFixedPrice
		 WHERE allFixedPrice.Item = '#qGPV.Item#'
		   AND allFixedPrice.Greatest_Program_Value <> 1
		   AND allFixedPrice.Case_Value >= #qGPV.Case_Value#
	</cfquery>

	<cfif qFailure.recordCount>
		<cfscript>
			qGPV.Failed = 1;    // flag this gpv as failed
			greatestProgramValue.failedValidation = true;
		</cfscript>
	</cfif>
</cfloop>

<!--- bailed out when there is no validation error --->
<cfif not greatestProgramValue.failedValidation>
	<cfreturn>
</cfif>

<!--------------------------------------------------------------------------------------------------------------------->



<!--- display items that failed validation --->
<!DOCTYPE>
<html lang="en">
<head>
 <meta http-equiv="content-type" content="text/html; charset=utf-8">
 <title><cfoutput>#Application.FixedPriceLabel#</cfoutput> | Greatest Program Value</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style type="text/css">
	#fs727 { margin:0; padding:0 0px 0 0; border:0 none; border-top:1px solid; width:100%; clear:both; }
	#fs727 legend { margin:3px 0 0 0; padding:0 5px; font-size:1.6em; font-weight:bold; }
	#hdr727 { font-size:2.1em; font-weight:bold; font-family:"Times New Roman" serif; color:red; margin:0; float:left;}
	#tp727 { font-size:1.4em; float:right; position:relative; top:10px; }
	#actp727 { margin-top:15px; text-align:center }
	#actp1047 { margin:0; padding:0; }
	p { font-size:1.0em; }
	.failure { font-weight:bold; color:red !important; }
	.dollar { text-align:right; font-weight:bold; }
	.tac { text-align:center; }
	p { font-size:1.1em; }
	h3 { margin:11px 0; padding: 0; }
	</style>
</head>

<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<body>
<cfset program = CreateObject("component", "components.programs.Program") />
<cfset qGetProgramInfo = program.getProgramInfo(attributes.Program_ID) />
<div id="hdr727">#application.returned_customer_setting.company_name#</div>
<div id="tp727"><b>Template:</b> #qGetProgramInfo.Created_Type#</div>

<fieldset id="fs727">
<legend>#qGetProgramInfo.Contract_Number#</legend>

<H3>#Application.FixedPriceLabel# - Greatest Program Value (GPV) Validation Failures</H3>
<!--- if there is too many rows add another link at the top to allow users to bail out, the other same link is displayed at the bottom --->
<cfif qGPV.recordCount gt 40>
	<div id="actp1047">
	 <a href="##" class="cancel729">#application.util.string.actionLinkFormat("return to view program")#</a>
	</div>
</cfif>

<p>The purpose of this validation is to notify the user if certain prices are greater than others. The following items failed the Greatest Program Value (GPV) validation.  For each of the components considered, the values below indicate which of the components in your program fail that validation.</p>
<table class="datagrid" id="datagrid">
<thead>
<tr>
 <th>Item</th>
 <th>Description</th>
 <th>Component</th>
 <th class="tac">Price</th>
 <th>GPV Component</th>
 <th class="tac">GPV Price</th>
</tr>
</thead>
<tbody>
<cfloop query="qGPV">
	<cfif qGPV.failed eq "1">
		<!--- gathering detail --->
		<cfset useLakebaseForgpvDetail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("allfixedprice")>
<cfif useLakebaseForgpvDetail>
	<cftry>
		<cfset gpvDetail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("allfixedprice", {
				"item" = "eq.#qGPV.Item#",
				"greatest_program_value" = "eq.1",
				"case_value" = "eq.#qGPV.Case_Value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgpvDetail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgpvDetail>
<cfquery name="gpvDetail" dbtype="query">
			SELECT *
			  FROM allFixedPrice
			 WHERE allFixedPrice.Item = '#qGPV.Item#'
			   AND allFixedPrice.Greatest_Program_Value = 1
			   AND allFixedPrice.Case_Value = #qGPV.Case_Value#
		</cfquery>
</cfif>
		<cfquery name="otherDetail" dbtype="query">
			SELECT *
			  FROM allFixedPrice
			 WHERE allFixedPrice.Item = '#qGPV.Item#'
			   AND allFixedPrice.Greatest_Program_Value <> 1
			   AND allFixedPrice.Case_Value >= #qGPV.Case_Value#
			   ORDER BY Case_Value DESC
		</cfquery>
		<cfloop query="otherDetail">
			<tr>
				<td>#otherDetail.Item#</td>
				<td>#otherDetail.Description#</td>
				<td>#otherDetail.Program_Fixed_Component_Name#</td>
				<td class="failure dollar">#dollarFormat(otherDetail.Case_Value)#/CS</td>
				<td>#gpvDetail.Program_Fixed_Component_Name#</td>
				<td class="dollar">#dollarFormat(gpvDetail.Case_Value)#/CS</td>
			</tr>
		</cfloop>
	</cfif>
</cfloop>
</tbody>
</table>

<div id="actp727">
 <a href="##" class="cancel729">#application.util.string.actionLinkFormat("return to view program")#</a>
</div>
</fieldset>

<!-------------------------------------------------------------------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">

<script>
$('.cancel729').click(function(e) {
 e.preventDefault();
 <cfparam name="attributes.return_To_Page" default="">
 <cfif len(attributes.return_To_Page)>
 		window.location = "#attributes.return_To_Page#";
 	<cfelse>
 		window.close();
 	</cfif>
});
$('table tr').hover( function() { $(this).addClass("over"); }, function() { $(this).removeClass("over"); } );
$('tr:even').css('background-color','##eeffee');
</script>
</body>
</cfoutput>
</html>

<cfabort>

