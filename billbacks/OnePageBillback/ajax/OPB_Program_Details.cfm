<cfparam name="form.BBCreate" default="0" >
<cfparam name="form.saveDetailsInfo" default="0" >
<!--- SEARCH FILTERS---->
<cfparam name="form.FILTERworkItemamount" default="1" >
<cfparam name="form.FILTERddAmount" default="" >
<cfparam name="form.FILTERdistributor" default="1" >
<cfparam name="form.FILTERremainingBalance" default="0" >
<cfparam name="form.FILTERremainingAmt" default="" >
<cfparam name="form.FILTERrefnumber" default="1" >
<cfparam name="form.FILTERreferencenumber" default="" >
<cfparam name="form.FILTERtype" default="1" >
<cfparam name="form.FILTERkeyword" default="" >

<cfif form.BBCreate>

	<cfscript>
    qGetProgramDetails = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").createBillblack(stForm = FORM);
		return_columns = [  "BB_Code" 	];
	</cfscript>

	<cfif qGetProgramDetails.recordCount eq 0>
	    <cfoutput>{"ROWS":[]}</cfoutput>
	<cfelse>
	    <cfoutput>{"ROWS":#application.util.query.toDtJSON(qGetProgramDetails, arrayToList( return_columns ))#}</cfoutput>
	</cfif>

<cfelseif form.saveDetailsInfo>

	<cfscript>
    qUpdateDetails = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").UpdateDetails(stForm = FORM);
		return_columns = [
					 "TotalVolume"
					,"TotalXAmount"
					,"PaidTo"
					,"Component_Paid_To"
					];
	</cfscript>

	<cfif qUpdateDetails.recordCount eq 0>
	   <cfoutput>{"ROWS":[]}</cfoutput>
	<cfelse>
	   <cfoutput>{"ROWS":#application.util.query.toDtJSON(qUpdateDetails, arrayToList( return_columns ))#}</cfoutput>
	</cfif>

<cfelseif form.search EQ 'bb'>

	<!--- TOP FILTER FIELDS --->
	<cfparam name="form.payable_search" default="" >
	<cfparam name="form.billback_search" default="" >
	<cfparam name="form.bb_program_search" default="" >
	<cfparam name="form.bb_customer_search" default="" >
	<cfparam name="form.bb_operator_search" default="" >
	<cfparam name="form.bb_item_search" default="" >
	<cfparam name="form.bb_item_group_search" default="" >

	 <!---BOTTOM  FILTER FIELDS--->
	<cfparam name="form.bb_status_list" default="" >
	<cfparam name="form.bb_closing_method" default="" >
	<cfparam name="form.billback_analyst" default="" >
	<cfparam name="form.bb_template_list" default="" >
	<cfparam name="form.bb_component_list" default="" >
	<cfparam name="form.bb_paid_to" default="" >

	<cfscript>
		qGetBBList = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").getBillbacks(stForm = FORM);

		return_columns = [
																	"Closing_Method_Abb"  //0
																	,"BB_Stauts_Abb" // 1
																	,"Deviation" //2
																	,"Payable_ID" //3
																	,"BB_Reference" //4
																	,"Claimed_Amount" //5
																	,"Deviated_Amount" //6
																	,"Approved_Amount" //7
																	,"BB_Date" //8
																	,"Payee_Name" //9
																	,"Payee_ID" //10
																	,"Delivery_start_date" //11
																	,"Delivery_end_date" //12
																	,"Paid_To" //13
																	,"Analyst" //14
																	,"BB_Loc_Duplicate" //15
																	,"Billback_ID" //16
																	,"Locked" //17
																	,"BBCode" //18
																	,"Payee_GUID" //19
																	,"Doc_Count" //20
																	];
	</cfscript>
	<cfif qGetBBList.recordCount eq 0>
	   <cfoutput>{"ROWS":[]}</cfoutput>
	<cfelse>
		<cfoutput>{"ROWS":#application.util.query.toDtJSON(qGetBBList, arrayToList( return_columns ))#}</cfoutput>
	</cfif>

<cfelseif form.search EQ 'ded'>

		<!--- TOP FILTER FIELDS --->
		<cfparam name="form.deduction_search" default="" >
		<cfparam name="form.reference_search" default="" >
		<cfparam name="form.check_search" default="" >
		<cfparam name="form.creference_search" default="" >
		<cfparam name="form.dd_customer_search" default="" >

		 <!---BOTTOM  FILTER FIELDS--->
		<cfparam name="form.dd_status_list" default="" >
		<cfparam name="form.dd_family" default="" >
		<cfparam name="form.dd_analyst" default="" >

	<cfscript>
		qGetDeductions = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").getDeductions(stForm = FORM);
				return_columns = [
					 "DD_Status_Description"
					,"DD_DedID"
					,"DD_Date"
					,"DD_Amount"
					,"DD_Reference"
					,"Customer_ID"
					,"Name"
					,"DD_Check_Number"
					,"Analyst"
					,"Deduction_ID"
					,"DD_Aging_Label"
				];
	</cfscript>

	<cfif qGetDeductions.recordCount eq 0>
	   <cfoutput>{"ROWS":[]}</cfoutput>
	<cfelse>
		  <cfoutput>{"ROWS":#application.util.query.toDtJSON(qGetDeductions, arrayToList( return_columns ))#}</cfoutput>
	</cfif>

<cfelseif form.search EQ 'prg'>

	<!--- TOP FILTER FIELDS --->
<cfparam name="form.customer_search" default="" >
<cfparam name="form.customer_group_search" default="" >
<cfparam name="form.operator_search" default="" >
<cfparam name="form.program_search" default="" >
<cfparam name="form.item_search" default="" >
<cfparam name="form.item_group_search" default="" >

 <!---BOTTOM  FILTER FIELDS--->
<cfparam name="form.template_list" default="" >
<cfparam name="form.planner_template_list" default="" >
<cfparam name="form.paid_to" default="" >
<cfparam name="form.discount_type" default="" >
<cfparam name="form.component_list" default="" >

<!--- DATE SEARCH FIELDS --->
<cfparam name="form.startDate" default="" >
<cfparam name="form.startDateCondition" default="" >
<cfparam name="form.endDate" default="" >
<cfparam name="form.endDateCondition" default="" >
<cfparam name="form.search" default="" >

	<cfscript>
	    qGetProgramDetails = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager").getAllPrograms(stForm = FORM);
	        return_columns = [
						 "Planner_Number"   //0
						,"Program_Number" //1
						,"Program_Title" //2
						,"Customer_ID" //3
						,"Customer_Name" //4
						,"Delivery_Start_Date" //5
						,"Delivery_End_Date" //6
						,"Item_Number" //7
						,"Item_Description" //8
						,"Discount_Type" //9
						,"Component_Name"				 //10
						,"Program_Rate" //11
						,"Rebate_UOM" //12
						,"Volume" //13
						,"Volume_UOM" //14
						,"Extended_Amount"  //15
						,"Operator_ID" //16
						,"Accrued" //17
						,"Settled" //18
						,"Balance" //19
						,"BSA_Foodservice_Customers_ID" //20
						,"BSA_Foodservice_Items_Master_ID" //21
						,"Discount_Type_ID" //22
						,"Component_Paid_To" //23
						,"Rebate_UOM_ID" //24
						,"Component_Name_ID" //25
						,"Max_Program_Count" //26
						,"Program_Count" //27
						,"Detail_Count" //28
						,"Net_Weight" //29
						,"Sleeves_Per_case" //30
						,"Case_Count" //31
						,"Price_CS" //32
						,"Contract_Main_ID" //33
						,"Operator_Name" //34
						,"RowID" //35
						,"Template" //36
						,"Segment" //37
	        ];
	</cfscript>

	<cfif qGetProgramDetails.recordCount eq 0>
	   <cfoutput>{"ROWS":[]}</cfoutput>
	<cfelse>
		  <cfoutput>{"ROWS":#application.util.query.toDtJSON(qGetProgramDetails, arrayToList( return_columns ))#}</cfoutput>
		</cfif>
<cfelse>
	<cfoutput>{"ROWS":[]}</cfoutput>
</cfif>