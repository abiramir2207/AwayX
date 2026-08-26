<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
</HEAD>

<BODY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- General --->
<cfparam name="No_Routing_Required_A" 		default="0">
<cfparam name="No_Routing_Required_B" 		default="0">
<cfparam name="No_Routing_Required_C" 		default="0">

<!--- Basic info Changes --->
<cfparam name="Other_Program_Changes_Approval_Type" 		default="0">
<cfparam name="Title_Changes_Approval_Type" 				default="0">
<cfparam name="Start_Date_Change_Approval_Type"				default="0">
<cfparam name="End_Date_Change_Approval_Type" 				default="0">
<cfparam name="Program_Reference_Number_Changes_Approval_Type" 	default="0">
<cfparam name="Program_Notes_Change_Approval_Type"			default="0">
<cfparam name="No_Changes_Approval_Type"					default="0">
<cfparam name="Program_Date_Changed_Same_Duration_Type"		default="0">

<!--- Products & Rates --->
<cfparam name="Products_Added_Approval_Type" 				default="0">
<cfparam name="Prod_Add_FixedEqPricelist_Approval_Type"		default="0">
<cfparam name="Products_Removed_Approval_Type" 				default="0">
<cfparam name="Products_Rates_Changes_Approval_Type" 		default="0">
<cfparam name="Products_Rates_Decreased_Approval_Type" 		default="0"><!--- D34880: Max Rate Easy Button and Short Cut Routing--->
<cfparam name="Products_UOM_Changes_Approval_Type" 			default="0">
<cfparam name="Component_ClaimMech_Change_Approval_Type"	default="0">
 
<!--- Customers & Freight --->
<cfparam name="Distributors_Added_Approval_Type" 			default="0">
<cfparam name="Distributors_Removed_Approval_Type" 			default="0">
<cfparam name="Operators_Added_Approval_Type"				default="0">
<cfparam name="Operators_Removed_Approval_Type"				default="0">
<cfparam name="Freight_Change_Approval_Type"				default="0">


<!--- Treat both statements as a one... ---> 
<cftransaction>

	<!--- First set the deleted bit to one for all the entries in the table --->
	<CFQUERY NAME="Set_Deleted" DATASOURCE="#application.datasource#">
		UPDATE	Revision_Settings
		SET		Revision_Setting_Deleted = 1
	</CFQUERY>
	
	
	<!--- Then insert the latest settings... --->
	<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
		INSERT INTO 	Revision_Settings
			(
				Revision_Setting_Created_By,
				
				<!--- General --->
				No_Routing_Required_A,
				No_Routing_Required_B,
				No_Routing_Required_C,
				
				<!--- Basic info section --->
				Other_Program_Changes_Approval,
				Other_Program_Changes_Approval_Type,				
				Title_Changes_Approval,
				Title_Changes_Approval_Type,
				Start_Date_Change_Approval,
				Start_Date_Change_Approval_Type,
				End_Date_Change_Approval,
				End_Date_Change_Approval_Type,
				Program_Reference_Number_Changes_Approval,
				Program_Reference_Number_Changes_Approval_Type,
				Program_Notes_Change_Approval,
				Program_Notes_Change_Approval_Type,
				No_Changes_Approval,
				No_Changes_Approval_Type,
				
				
				<!--- Products & Rates --->
				Products_Added_Approval,
				Products_Added_Approval_Type,
				Prod_Add_FixedEqPricelist_Approval,				
				Prod_Add_FixedEqPricelist_Approval_Type,
				Products_Removed_Approval,
				Products_Removed_Approval_Type,
				Products_Rates_Changes_Approval,
				Products_Rates_Changes_Approval_Type,
				Products_Rates_Decreased_Approval, ---D34880: Max Rate Easy Button and Short Cut Routing
				Products_Rates_Decreased_Approval_Type,---D34880: Max Rate Easy Button and Short Cut Routing
				Products_UOM_Changes_Approval,
				Products_UOM_Changes_Approval_Type,
				Component_ClaimMech_Change_Approval,
				Component_ClaimMech_Change_Approval_Type,
				
				<!--- Customers & Freight --->
				Distributors_Added_Approval,
				Distributors_Added_Approval_Type,
				Distributors_Removed_Approval,
				Distributors_Removed_Approval_Type,
				Operators_Added_Approval,
				Operators_Added_Approval_Type,
				Operators_Removed_Approval,
				Operators_Removed_Approval_Type,
				Freight_Change_Approval,
				Freight_Change_Approval_Type,
				Program_Date_Changed_Same_Duration,
				Program_Date_Changed_Same_Duration_Type
			)
		VALUES
			(
				<cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">,
				
				<!--- General --->
				<cfqueryparam value="#No_Routing_Required_A#" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="#No_Routing_Required_B#" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="#No_Routing_Required_C#" cfsqltype="cf_sql_bit">,
				
				<!--- Basic info section --->
				<cfqueryparam value="#Other_Program_Changes_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Other_Program_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,				
				<cfqueryparam value="#Title_Changes_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Title_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Start_Date_Change_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Start_Date_Change_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#End_Date_Change_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#End_Date_Change_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Program_Reference_Number_Changes_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Program_Reference_Number_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Program_Notes_Change_Approval#" cfsqltype="cf_sql_integer">,		
				<cfqueryparam value="#Program_Notes_Change_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#No_Changes_Approval#" cfsqltype="cf_sql_integer">,		
				<cfqueryparam value="#No_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,
				
				<!--- Products & Rates --->
				<cfqueryparam value="#Products_Added_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Added_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Prod_Add_FixedEqPricelist_Approval#" cfsqltype="cf_sql_integer">,				
				<cfqueryparam value="#Prod_Add_FixedEqPricelist_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Removed_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Removed_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Rates_Changes_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Rates_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_Rates_Decreased_Approval#" cfsqltype="cf_sql_integer">, ---D34880: Max Rate Easy Button and Short Cut Routing
				<cfqueryparam value="#Products_Rates_Decreased_Approval_Type#" cfsqltype="cf_sql_integer">,---D34880: Max Rate Easy Button and Short Cut Routing
				<cfqueryparam value="#Products_UOM_Changes_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Products_UOM_Changes_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Component_ClaimMech_Change_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Component_ClaimMech_Change_Approval_Type#" cfsqltype="cf_sql_integer">,
				
				<!--- Customers & Freight --->
				<cfqueryparam value="#Distributors_Added_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Distributors_Added_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Distributors_Removed_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Distributors_Removed_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Operators_Added_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Operators_Added_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Operators_Removed_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Operators_Removed_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Freight_Change_Approval#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Freight_Change_Approval_Type#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Program_Date_Changed_Same_Duration#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#Program_Date_Changed_Same_Duration_Type#" cfsqltype="cf_sql_integer">
			)
	</CFQUERY>

</cftransaction> 


<CFLOCATION URL="edit_revise_program.cfm" ADDTOKEN="No">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>