<!--- 52840-22364-22102-87888 --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- rebuild the id that was passed by the url by taking its cubic root ---------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset rebuilt_id	=	url.id-12345>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- basic program details ------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_program_details" datasource="#Application.Datasource#">

SELECT		dbo.Contract_Main.Contract_Main_ID,
            dbo.Contract_Main.Contract_Number,
            dbo.Contract_Main.Contract_Title,
            dbo.Contract_Main.Contract_Start_Date,
            dbo.Contract_Main.Contract_End_Date,
            dbo.Contract_Main.ProgramType_ID,
            dbo.Program_Control_Panel_Options.Created_Type,
            dbo.Program_Control_Panel_Options.Program_Description,
            dbo._Users.Name_First + ' ' + dbo._Users.Name_Last as responsible_person

FROM		dbo.Contract_Main

INNER JOIN	dbo.Program_Control_Panel_Options ON dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = dbo.Contract_Main.ProgramType_ID
INNER JOIN	dbo._Users ON dbo._Users.User_ID = dbo.Contract_Main.Responsible_User_ID

WHERE		dbo.Contract_Main.Deleted = 0 
            AND
            Contract_Main_ID	=	#rebuilt_id#

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- estimated volume ------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_estimated_volume" datasource="#Application.Datasource#">
SELECT		ISNULL(Sum(Cast(IsNull(Volume_cs, 0) * (Datediff(d, Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date) + 1) / 7 AS DECIMAL(20,0 ))), 0) As Cases

FROM 		Contract_Main

INNER JOIN	Program_Product_Volume ON Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID
			AND
            Program_Product_Volume.Deleted = 0
			AND
            Program_Product_Volume.Is_Group = 0
			AND EXISTS 
            	( 
                	SELECT 1
                    FROM 	CONTRACT_PRODUCTS cp
                    WHERE	cp.Contract_Main_Id = Program_Product_Volume.Program_Id
                    AND		cp.Deleted = 0
                    AND		cp.bsa_FoodService_Items_Master_Id = Program_Product_Volume.bsa_FoodService_Items_Master_Id 
                )

WHERE		Contract_Main_ID	=	#rebuilt_id#

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- actual cases ------------------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
		<cfset ProgTotalVolQty 	= CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager").getsummarypaymentdetails(contract_number=get_program_details.Contract_Number, contractMainID=get_program_details.Contract_Main_ID)>
		<cfset Total_Program_Qtg_Cases	= ProgTotalVolQty.volume_cs>		
<!--- ----------------------------------------------------------------------------------------- --->







<!--- ----------------------------------------------------------------------------------------- --->
<!--- committed dollars ----------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->





<!--- ----------------------------------------------------------------------------------------- --->
<!--- name of the budget (if there is one) amd committed dollars ------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_budget_name" datasource="#Application.Datasource#">

SELECT	Contract_Main.Contract_Number,
		Budget.Budget_desc, budget_class.budget_class_desc,
        Sum ( CASE WHEN Isnull( Budget.Allocation_Position_Level, 0 ) = 4 THEN Budget_Distributor_Program.Actual_Dollar ELSE Budget_Position_Program.Actual_Dollar END ) AS Actual_Dollar,
        Sum ( CASE WHEN Isnull( Budget.Allocation_Position_Level, 0 ) = 4 THEN Budget_Distributor_Program.Committed_Dollar ELSE Budget_Position_Program.Committed_Dollar END ) AS Committed_Dollar

FROM	Contract_Main

        INNER JOIN Contract_Main All_Versions -- We will get budget and actual dollar from all versions of the program
        ON All_Versions.Contract_Number = Contract_Main.Contract_Number
        AND All_Versions.Approved = 1

        INNER JOIN Budget_Program_Selection
        ON Budget_Program_Selection.Program_Id = All_Versions.Contract_Main_Id

        INNER JOIN Budget
        ON Budget.Budget_Id = Budget_Program_Selection.Budget_Id
        
        INNER JOIN budget_class ON budget_class.budget_class_id = budget.budget_class_id

        LEFT JOIN Budget_Position_Program
        ON Budget_Position_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
		AND Budget_Position_Program.Budget_ID = Budget_Program_Selection.Budget_ID
        AND Isnull( Budget.Allocation_Position_Level, 0 ) != 4

        LEFT JOIN Budget_Distributor_Program
        ON Budget_Distributor_Program.Contract_Main_Id = All_Versions.Contract_Main_Id
		AND Budget_Distributor_Program.Budget_ID = Budget_Program_Selection.Budget_ID
        AND Isnull( Budget.Allocation_Position_Level, 0 ) = 4

WHERE	Contract_Main.Contract_Main_Id = #reBuilt_Id#

GROUP BY Contract_Main.Contract_Number, Budget.Budget_desc,  budget_class.budget_class_desc

ORDER BY  budget_class.budget_class_desc 






</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the operators that are part of this contract ---------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- PRG-1000445 --->

<cfquery name="get_operators" datasource="#Application.Datasource#">
SELECT	dbo.Contract_Operators.Contract_Main_ID,
        dbo.BSA_Operator.Operator_Name,
        dbo.BSA_Operator.Operator_Address,
        dbo.BSA_Operator.Operator_Address2,
        dbo.BSA_Operator.Operator_City,
        dbo.BSA_Operator.Operator_State,
        dbo.BSA_Operator.Operator_Zip,
        dbo.BSA_Operator.Eshark_RecordID

FROM	dbo.Contract_Operators
		INNER JOIN dbo.BSA_Operator ON dbo.BSA_Operator.BSA_Operator_ID = dbo.Contract_Operators.BSA_Operator_ID

WHERE	dbo.Contract_Operators.Contract_Main_Id = #reBuilt_Id#

ORDER BY dbo.BSA_Operator.Operator_Name
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get distributors that are part of this contract ----------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_distributors" datasource="#Application.Datasource#">
SELECT	dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
		dbo.BSA_Foodservice_Customers.Ship_To,
        dbo.BSA_Foodservice_Customers.Name,
        dbo.BSA_Foodservice_Customers.Address_1,
        dbo.BSA_Foodservice_Customers.Address_2,
        dbo.BSA_Foodservice_Customers.City,
        dbo.BSA_Foodservice_Customers.State,
        dbo.BSA_Foodservice_Customers.ZipCode

FROM	dbo.Contract_Distributors

INNER JOIN dbo.BSA_Foodservice_Customers ON dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = dbo.Contract_Distributors.BSA_Foodservice_Customers_ID

WHERE	dbo.Contract_Distributors.Contract_Main_Id = #reBuilt_Id#

ORDER BY dbo.BSA_Foodservice_Customers.Name
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the types of incentives for this program -------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="get_incentive_types" datasource="#Application.Datasource#">
SELECT distinct
dbo.Contract_Products.Contract_Main_ID,
dbo.Contract_Products.Product_Type_ID,
dbo.Discount_Type.Discount_Type_Desc

FROM
dbo.Contract_Products
INNER JOIN dbo.Discount_Type ON dbo.Discount_Type.Discount_Type_ID = dbo.Contract_Products.Product_Type_ID

where 
dbo.Contract_Products.Contract_Main_Id = #reBuilt_Id#
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->



<style>
fieldset.frame
{
	color:					#333333;
	font-size:				11px;
	font-weight:			bold;
	padding:				10px 10px 10px 10px;
	margin:					15px 10px 0px 10px;
	border:					0px #2989D8 solid;
	border-top:				3px #2989D8 solid;
	text-align:				left;
	width:					850px;
}

legend.frame
{
	color:					#FFFFFF;
	font-size:				12px;
	font-weight:			bold;
	padding:				7px 10px 7px 10px;
	margin:					0px 0px 0px 5px;
	border:					0px #2989D8 solid;
	text-align:				left;
	text-transform:			uppercase;
	cursor:					pointer;
	width:					150px;

/* IE9 SVG, needs conditional override of 'filter' to 'none' */
background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzFlNTc5OSIgc3RvcC1vcGFjaXR5PSIwIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjE1JSIgc3RvcC1jb2xvcj0iIzFlNTc5OSIgc3RvcC1vcGFjaXR5PSIwLjgiLz4KICAgIDxzdG9wIG9mZnNldD0iMTklIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjEiLz4KICAgIDxzdG9wIG9mZnNldD0iMjAlIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjEiLz4KICAgIDxzdG9wIG9mZnNldD0iNTAlIiBzdG9wLWNvbG9yPSIjMjk4OWQ4IiBzdG9wLW9wYWNpdHk9IjEiLz4KICAgIDxzdG9wIG9mZnNldD0iODAlIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjEiLz4KICAgIDxzdG9wIG9mZnNldD0iODElIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjEiLz4KICAgIDxzdG9wIG9mZnNldD0iODUlIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjAuOCIvPgogICAgPHN0b3Agb2Zmc2V0PSIxMDAlIiBzdG9wLWNvbG9yPSIjMWU1Nzk5IiBzdG9wLW9wYWNpdHk9IjAiLz4KICA8L2xpbmVhckdyYWRpZW50PgogIDxyZWN0IHg9IjAiIHk9IjAiIHdpZHRoPSIxIiBoZWlnaHQ9IjEiIGZpbGw9InVybCgjZ3JhZC11Y2dnLWdlbmVyYXRlZCkiIC8+Cjwvc3ZnPg==);
background: -moz-linear-gradient(top,  rgba(30,87,153,0) 0%, rgba(30,87,153,0.8) 15%, rgba(30,87,153,1) 19%, rgba(30,87,153,1) 20%, rgba(41,137,216,1) 50%, rgba(30,87,153,1) 80%, rgba(30,87,153,1) 81%, rgba(30,87,153,0.8) 85%, rgba(30,87,153,0) 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(30,87,153,0)), color-stop(15%,rgba(30,87,153,0.8)), color-stop(19%,rgba(30,87,153,1)), color-stop(20%,rgba(30,87,153,1)), color-stop(50%,rgba(41,137,216,1)), color-stop(80%,rgba(30,87,153,1)), color-stop(81%,rgba(30,87,153,1)), color-stop(85%,rgba(30,87,153,0.8)), color-stop(100%,rgba(30,87,153,0))); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  rgba(30,87,153,0) 0%,rgba(30,87,153,0.8) 15%,rgba(30,87,153,1) 19%,rgba(30,87,153,1) 20%,rgba(41,137,216,1) 50%,rgba(30,87,153,1) 80%,rgba(30,87,153,1) 81%,rgba(30,87,153,0.8) 85%,rgba(30,87,153,0) 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  rgba(30,87,153,0) 0%,rgba(30,87,153,0.8) 15%,rgba(30,87,153,1) 19%,rgba(30,87,153,1) 20%,rgba(41,137,216,1) 50%,rgba(30,87,153,1) 80%,rgba(30,87,153,1) 81%,rgba(30,87,153,0.8) 85%,rgba(30,87,153,0) 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  rgba(30,87,153,0) 0%,rgba(30,87,153,0.8) 15%,rgba(30,87,153,1) 19%,rgba(30,87,153,1) 20%,rgba(41,137,216,1) 50%,rgba(30,87,153,1) 80%,rgba(30,87,153,1) 81%,rgba(30,87,153,0.8) 85%,rgba(30,87,153,0) 100%); /* IE10+ */
background: linear-gradient(to bottom,  rgba(30,87,153,0) 0%,rgba(30,87,153,0.8) 15%,rgba(30,87,153,1) 19%,rgba(30,87,153,1) 20%,rgba(41,137,216,1) 50%,rgba(30,87,153,1) 80%,rgba(30,87,153,1) 81%,rgba(30,87,153,0.8) 85%,rgba(30,87,153,0) 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#001e5799', endColorstr='#001e5799',GradientType=0 ); /* IE6-8 */

}

.rounded_corners
{
	-webkit-border-radius:	15px;
	border-radius: 			15px; 	
}


/*
orange						ff9900
gark green					004b00
dark blue					0000c8
*/


td.name
{
	color:					#FFFF00;
	background-color:		#222222;
	text-align:				right;
	padding:				5px 5px 5px 5px;
	width:					15%;
	border-bottom:			2px #000000 solid;
	text-transform:			uppercase;
	font-size:				10px;
}

td.data
{
	color:					#FFFFFF;
	background-color:		#222222;
	text-align:				left;
	padding:				5px 5px 5px 5px;
	width:					35%;
	border-bottom:			2px #000000 solid;
	text-transform:			uppercase;
	font-size:				10px;
}


td.name_discount_grid
{
	color:					#FFFF00;
	background-color:		#222222;
	padding:				5px 5px 5px 5px;
	border-bottom:			2px #990000 solid;
	text-transform:			uppercase;
	font-size:				10px;
	font-weight:			bold;
}

td.data_discount_grid
{
	color:					#FFFFFF;
	background-color:		#222222;
	padding:				5px 5px 5px 5px;
	border-bottom:			1px #990000 dotted;
	text-transform:			uppercase;
	font-size:				10px;
}

.center, td.center
{
	text-align:				center;
}

.left, td.left
{
	text-align:				left;
}

.right, td.right
{
	text-align:				right;
}


span.item_name
{
	color:					#FFFF00;
} 
 
div.incentive_title
{
	color:					#FFFF00;
	font-size:				14px;
	padding:				0px 0px 5px 0px;
	margin:					5px 0px 0px 0px;
	border-bottom:			0px #FFFFFF solid;
	list-style:				none;	
}
</style>



<script type="text/javascript">
<!--
    function toggle_visibility(id) {
       var e = document.getElementById(id);
       if(e.style.display == 'none')
          e.style.display = 'block';
       else
          e.style.display = 'none';
    }
//-->
</script>


<div class="section_title gradient_fix">Program Details</div>
<br />

<div class="nav rounded_corners dark_gradient gradient_fix" style="float:right;" onclick="javascript:history.back();">back to program list</div>
<div class="nav rounded_corners dark_gradient gradient_fix" style="float:right;" onclick="javascript: history.go(-2);">back to program search</div>


<!--- <div align="center"> --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- program details ------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<fieldset class="frame">
<legend class="frame rounded_corners gradient_fix" onclick="toggle_visibility('programs');">program</legend>
<div id="program">
<table width="100%" style="margin:0px auto 0px auto; border-collapse:collapse;">

	<tr>
    	<td class="name">program number:</td>
    	<td class="data"><cfoutput>#get_program_details.Contract_Number# - #rebuilt_id#</cfoutput></td>
        <td></td>
    	<td class="name">program title:</td>
    	<td class="data"><cfoutput>#get_program_details.Contract_Title#</cfoutput></td>
	</tr>
	<tr>
    	<td class="name">template name:</td>
    	<td class="data"><cfoutput>#get_program_details.ProgramType_ID# - #get_program_details.Program_Description#</cfoutput></td>
        <td></td>
    	<td class="name">resp. person:</td>
    	<td class="data"><cfoutput>#CapFirst(get_program_details.responsible_person)#</cfoutput></td>
    </tr>
	<tr>
    	<td class="name">start date:</td>
    	<td class="data"><cfoutput>#dateformat(get_program_details.Contract_Start_Date, 'mm/dd/yyyy')#</cfoutput></td>
        <td></td>
    	<td class="name">end date:</td>
    	<td class="data"><cfoutput>#dateformat(get_program_details.Contract_End_Date, 'mm/dd/yyyy')#</cfoutput></td>
    </tr>
	<tr>
    	<td class="name">estimated volume:</td>
    	<td class="data"><cfoutput>#numberformat(get_estimated_volume.cases, ',')# case(s)</cfoutput></td>
        <td></td>
    	<td class="name">actual cases:</td>
    	<td class="data"><cfoutput>#numberformat(Total_Program_Qtg_Cases, ',')#</cfoutput></td>
    </tr>

<!---

	<tr>
    	<td class="name">actual dollars:</td>
    	<td class="data"><cfoutput>#mydollarformat(get_budget_name.Actual_Dollar)#</cfoutput></td>
        <td></td>
    </tr>
	<tr>
    	<td class="name">actual cases:</td>
    	<td class="data"><cfoutput>#numberformat(Total_Program_Qtg_Cases, ',')#</cfoutput></td>
        <td></td>
    </tr>
	<tr>
    	<td class="name">estimated volume:</td>
    	<td class="data"><cfoutput>#numberformat(get_estimated_volume.cases, ',')# case(s)</cfoutput></td>
        <td></td>
    	<td class="name">&nbsp;</td>
    	<td class="data">&nbsp;</td>
    </tr>

--->
</table>
</div>
</fieldset>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- budgeting details ------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif get_budget_name.recordcount GT 0>
<fieldset class="frame">
<legend class="frame rounded_corners gradient_fix" onclick="toggle_visibility('budgets');">budgets</legend>
<div id="budgets" style="display:none;">
<table width="100%" style="margin:0px auto 0px auto; border-collapse:collapse;">
    <tr>
    	<td class="name" style="text-align:left; white-space:nowrap; width:10%;">Budget Class</td>
    	<td class="name" style="text-align:left;white-space:nowrap; width:50%;">Budget Description</td>
    	<td class="name" style="text-align:left; white-space:nowrap; width:20%;">Acutal Dollars</td>
    	<td class="name" style="text-align:left; white-space:nowrap; width:20%;">Committed Dollars</td>
    </tr>
<cfoutput query="get_budget_name">
    <tr>
    	<td class="data">#Budget_Class_Desc#</td>
    	<td class="data">#Budget_desc#</td>
    	<td class="data">#mydollarformat(Actual_Dollar)#</td>
    	<td class="data">#mydollarformat(Committed_Dollar)#</td>
    </tr>
</cfoutput>

</table>
</div>
</fieldset>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->







<!--- ----------------------------------------------------------------------------------------- --->
<!--- operators ------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif get_operators.recordcount GT 0>
<fieldset class="frame">
<legend class="frame rounded_corners gradient_fix" onclick="toggle_visibility('operators');">operators</legend>
<div id="operators" style="display:none;">
<table width="100%" style="margin:0px auto 0px auto; border-collapse:collapse;">
    <tr>
		<CFOUTPUT QUERY="get_operators">
        <td class="data" style="width:20%; border-right:2px ##000000 solid; vertical-align:top;"><span class="item_name">#Eshark_RecordID#<br />#Operator_Name#</span><br />#Operator_Address# #Operator_Address2#<br />#Operator_City# #Operator_state# #Operator_zip#</td>
        <CFIF get_operators.CurrentRow MOD 5 IS 0></TR><TR></TR></CFIF>
        </cfoutput>
</table>
</div>
</fieldset>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- distributors ---------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif get_distributors.recordcount GT 0>
<fieldset class="frame">
<legend class="frame rounded_corners gradient_fix" onclick="toggle_visibility('distributors');">distributors</legend>
<div id="distributors" style="display:none;">
<table width="100%" style="margin:0px auto 0px auto; border-collapse:collapse;">
    <tr>
		<CFOUTPUT QUERY="get_distributors">
        <td class="data" style="width:20%; border-right:2px ##000000 solid; vertical-align:top;"><span class="item_name">#Ship_To#<br />#Name#</span><br />#Address_1# #Address_2#<br />#City# #state# #zipcode#</td>
        <CFIF get_distributors.CurrentRow MOD 5 IS 0></TR><TR></TR></CFIF>
        </cfoutput>
</table>
</div>
</fieldset>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- ----------------------------------------------------------------------------------------- --->
<!--- display discounts ----------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif get_incentive_types.recordcount GT 0>
<fieldset class="frame">
<legend class="frame rounded_corners gradient_fix"  onclick="toggle_visibility('discounts');">discounts</legend>

    <div id="discounts" style="display:none;">


        <cfloop query="get_incentive_types">
        <cfoutput><div class="incentive_title"><cfoutput>#Discount_Type_Desc#</cfoutput></div></cfoutput>
        
        
		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 1 = fixed price --->
        <!--- ----------------------------------------------------------------------------------------- --->
        <cfif Product_Type_ID EQ 1>
        <cfquery name="get_fixed_price_info" datasource="#Application.Datasource#">
        SELECT DISTINCT
        dbo.Program_Fixed_Component_Name.Program_Fixed_Component_Name,
        dbo.BSA_Foodservice_Items_Master.Item,
        dbo.BSA_Foodservice_Items_Master.Description,
        dbo.Program_Fixed_Price_Product_Data.Fixed_Price_Value,
        dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID,
        dbo.Units_of_Measure.Unit_Of_Measure_Desc,
        dbo.BSA_Foodservice_Items_Master.Net_Weight,
        dbo.Units_of_Measure.Abbreviation
        FROM
        dbo.Contract_Products
        INNER JOIN dbo.Program_Fixed_Component ON dbo.Program_Fixed_Component.Program_ID = dbo.Contract_Products.Contract_Main_ID
        INNER JOIN dbo.Program_Fixed_Component_Name ON dbo.Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = dbo.Program_Fixed_Component.Program_Fixed_Component_Name_ID
        INNER JOIN dbo.Program_Fixed_Price_Product_Data ON dbo.Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = dbo.Program_Fixed_Component.Program_Fixed_Component_ID AND dbo.Program_Fixed_Price_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID AND dbo.Program_Fixed_Price_Product_Data.Program_ID = dbo.Contract_Products.Contract_Main_ID
        INNER JOIN dbo.BSA_Foodservice_Items_Master ON dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = dbo.Contract_Products.BSA_Foodservice_Items_Master_ID
        INNER JOIN dbo.Units_of_Measure ON dbo.Units_of_Measure.Unit_Of_Measure_ID = dbo.Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID
        WHERE	dbo.Contract_Products.Contract_Main_ID = #reBuilt_Id#
        </cfquery>
        <table cellpadding="0" cellspacing="0" width="100%" align="center">
        <tr>
        <td class="name_discount_grid dark_gradient">item</td>
        <td class="name_discount_grid dark_gradient">description/size</td>
        <td class="name_discount_grid dark_gradient right"><cfoutput>#get_fixed_price_info.Program_Fixed_Component_Name#</cfoutput></td>
        </tr>
        <cfoutput query="get_fixed_price_info">
        <tr>
        <td class="data_discount_grid">#Item#</td>
        <td class="data_discount_grid" nowrap="nowrap">#Description#</td>
        <td class="data_discount_grid right" nowrap="nowrap">#dollarformat(Fixed_Price_Value)#/#Abbreviation#<!--- &nbsp;&nbsp;-&nbsp;&nbsp;#dollarformat(Fixed_Price_Value/Net_Weight)#/lbs. ---></td>
        </tr>
        </cfoutput>
        </table>
        <br />
		<!--- ----------------------------------------------------------------------------------------- --->

		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 2 = rebate --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 2>
        <cfquery name="get_rebate_info" datasource="#Application.Datasource#">
        select	contract_number, contract_main.revision_version,
                program_rebates_component_name.program_rebates_component_name,
                bsa_foodservice_items_master.item,
                bsa_foodservice_items_master.description,
                isnull(bsa_foodservice_items_master.item, All_Product_Group_Types.Group_Number), 
                isnull(bsa_foodservice_items_master.description, All_Product_Group_Types.Group_Desc), 
                program_rebates_component_data.rate, program_rebates_component_data.unit_of_measure_id
                
        from  contract_main
        
        inner join program_rebates_component
        on    program_rebates_component.deleted = 0
        and   program_rebates_component.program_id = contract_main.contract_main_id
        
        inner join program_rebates_component_name
        on    program_rebates_component_name.program_rebates_component_name_id = program_rebates_component.program_rebates_component_name_id
        
        inner join contract_products
        on    contract_products.deleted = 0
        and   contract_products.contract_main_id = contract_main.contract_main_id
        and   contract_products.product_type_id = 2
        and   contract_products.captured_from_group = 0
        
        left join bsa_foodservice_items_master
        on    bsa_foodservice_items_master.bsa_foodservice_items_master_id = contract_products.bsa_foodservice_items_master_id
        
        left join All_Product_Group_Types
        on    All_Product_Group_Types.Group_GUID = contract_products.bsa_foodservice_items_master_id
        
        left join program_rebates_product_data
        on    program_rebates_product_data.deleted = 0
        and   program_rebates_product_data.contract_products_id = contract_products.contract_products_id
        
        left join program_rebates_component_data
        on    program_rebates_component_data.deleted = 0
        and   program_rebates_component_data.program_rebates_component_id = program_rebates_component.program_rebates_component_id
        and   program_rebates_component_data.program_rebates_product_data_id = program_rebates_product_data.program_rebates_product_data_id

        where contract_main.contract_main_id in (#reBuilt_Id#)
        
        order by program_rebates_component_name.program_rebates_component_name, contract_main.contract_main_id, contract_number, bsa_foodservice_items_master.item, All_Product_Group_Types.Group_Number
        </cfquery>


        <table cellpadding="0" cellspacing="0" width="100%" align="center">
            <tr>
                <td class="name_discount_grid dark_gradient">Item</td>
                <td class="name_discount_grid dark_gradient">Description</td>
                <td class="name_discount_grid dark_gradient" style="text-align:right;">Rate</td>
            </tr>
            
            <cfoutput query="get_rebate_info" group="program_rebates_component_name">
            <tr><td colspan="100%" class="data_discount_grid" style="color:##FFFF00;"><br />#program_rebates_component_name#</td></tr>
			<cfoutput>
            <tr>
                <td class="data_discount_grid">&nbsp;&nbsp;&nbsp;&nbsp;#item#</td>
                <td class="data_discount_grid">#description#</td>
                <td class="data_discount_grid right">#dollarformat(rate)#/cs</td>
            </tr>
			</cfoutput>
            </cfoutput>
        </table>
        <br />
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 3 = lump sum --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 3>


		<cfquery name="get_lump_sum_info"  datasource="#Application.Datasource#">
        SELECT		top 10 Program_Lump_Sums.Program_ID, 
                	Program_Lump_Sums.Program_Lump_Sum_ID, 
                	Program_Lump_Sum_Name.Program_Lump_Sum_Name, 
                	GL_Account.GL_Account,
                	Program_Lump_Sums.Lump_Sum_Amount
        FROM  		Program_Lump_Sums
        
        INNER JOIN	Program_Lump_Sum_Name
        			ON	Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
        
        LEFT JOIN	GL_Account
        			ON	GL_Account.GL_Account_ID = Program_Lump_Sums.GL_Account_ID

        WHERE		Program_Lump_Sums.Deleted = 0
        			AND
                    Program_Lump_Sums.Program_ID = #reBuilt_Id#
        </cfquery>

		<cfloop query="get_lump_sum_info">
        
        <cfquery name="get_lump_sum_products"  datasource="#Application.Datasource#">
        SELECT      * 
		FROM fn_GetLumpSumProducts(#reBuilt_Id#, '#get_lump_sum_info.Program_Lump_Sum_ID#')
        </cfquery>
        
        
                
        <table cellpadding="0" cellspacing="0" width="100%" align="center">
            <tr>
                <td class="name_discount_grid dark_gradient" style="width:25%;">Component: <cfoutput>#Program_Lump_Sum_Name#</cfoutput>            
                </td>
                <td class="name_discount_grid dark_gradient" style="width:75%;">Lump Sum Amount: <cfoutput>#dollarformat(Lump_Sum_Amount)#</cfoutput>
                <cfif get_lump_sum_products.recordcount EQ 0><span style="margin-left:250px; font-style:italic;">No Products Included</span></cfif>
                </td>
            </tr>
			
			<cfloop query="get_lump_sum_products">
            <tr>
                <td class="data_discount_grid"><cfoutput>#item#</cfoutput></td>
                <td class="data_discount_grid"><cfoutput>#description#</cfoutput></td>
            </tr>
            </cfloop>
        </table>
        <br />
        
        </cfloop>

        <br />
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 4 = growth --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 4>

        <table cellpadding="0" cellspacing="0" width="100%" align="center">
            <tr>
                <td class="name_discount_grid dark_gradient">xxxxx</td>
                <td class="name_discount_grid dark_gradient">xxxxx</td>
                <td class="name_discount_grid dark_gradient">xxxxx</td>
                <td class="name_discount_grid dark_gradient">xxxxx</td>
            </tr>
            <cfloop index="i" from="1" to="5" step="1">
            <tr>
                <td class="data_discount_grid">xxxxxxx</td>
                <td class="data_discount_grid">xxxxxxx</td>
                <td class="data_discount_grid">xxxxxxx</td>
                <td class="data_discount_grid">xxxxxxx</td>
            </tr>
            </cfloop>
        </table>
        <br />
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 5 = formula pricing = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 5>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 6 = other = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 6>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 7 = don't know = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 7>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 8 = off invoice --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 6>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 9 = bid = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 7>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 10 = bid request = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
		<cfelseif Product_Type_ID is 8>
        <!--- ----------------------------------------------------------------------------------------- --->


		<!--- ----------------------------------------------------------------------------------------- --->
        <!--- Product_Type_ID = 11 = BB-Claim Adjustment = IGNORE --->
        <!--- ----------------------------------------------------------------------------------------- --->
        <cfelse>
		<!--- ----------------------------------------------------------------------------------------- --->



		</cfif>

        </cfloop>
    </div>


</fieldset>
</cfif>

<!--- </div> --->


<script type="text/JavaScript">
function toggle(d)
{
	var o=document.getElementById(d);
	o.style.display=(o.style.display=='none')?'block':'none';
}
</script>
