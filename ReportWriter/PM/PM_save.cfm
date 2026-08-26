<CFSET PAGE_TITLE="Project Management">
<CFSET GROUP="pm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="main_style.css">
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFPARAM NAME="Form.PM_Hide" 	DEFAULT=0>

<!--- If the save/create switch is on, update data.... --->
<CFIF Form.update_state EQ 1>

<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForUpdate_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("pm_item_master",
			{
				"pm_item_master_id" = "eq.#Form.RID#"
			},
			{
				"pm_priority_id" = "#Form.PM_Priority_ID#",
				"pm_status_id" = "#Form.PM_Status_ID#",
				"pm_phase_id" = "#Form.PM_Phase_ID#",
				"pm_start_date" = "#Form.PM_Start_Date#",
				"pm_end_date" = "#Form.PM_End_Date#",
				"pm_acct_project" = "#Form.PM_Acct_Project#",
				"pm_value_pounds" = "#Form.PM_Value_Pounds#",
				"pm_value_dollars" = "#Form.PM_Value_Dollars#",
				"pm_far_id" = "#Form.PM_Far_ID#",
				"pm_sponsor_id" = "#Form.PM_Sponsor_ID#",
				"pm_resources" = "#Form.PM_Resources#",
				"pm_support" = "#Form.PM_Support#",
				"pm_ext_budget" = "#Form.PM_Ext_Budget#",
				"pm_cer" = "#Form.PM_CER#",
				"pm_actual" = "#Form.PM_Actual#",
				"pm_date_modified" = "#now()#",
				"pm_modified_by_id" = "#request.AccessStructure.User_ID#",
				"pm_deleted" = "#PM_Deleted#",
				"pm_hide" = "#Form.PM_Hide#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Data>
<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
	UPDATE 		PM_Item_Master

	SET 		PM_Priority_ID		=	'#Form.PM_Priority_ID#',
				PM_Status_ID		=	'#Form.PM_Status_ID#',
				PM_Phase_ID			=	'#Form.PM_Phase_ID#',
				PM_Start_Date		=	'#Form.PM_Start_Date#',
				PM_End_Date			=	'#Form.PM_End_Date#',				
				PM_Acct_Project		=	'#Form.PM_Acct_Project#',
				PM_Value_Pounds		=	'#Form.PM_Value_Pounds#',
				PM_Value_Dollars	=	'#Form.PM_Value_Dollars#',
				PM_Far_ID			=	'#Form.PM_Far_ID#',
				PM_Sponsor_ID		=	'#Form.PM_Sponsor_ID#',
				<!------PM_Owner_ID			=	'#Form.PM_Owner_ID#',----->
				<!-----PM_Position_ID		=	'#Form.PM_Position_ID#',----->
				<!---PM_Notes			=	'#Form.PM_Notes#',---->
				PM_Resources		=	'#Form.PM_Resources#',
				PM_Support			=	'#Form.PM_Support#',
				PM_Ext_Budget		=	'#Form.PM_Ext_Budget#',
				PM_CER				=	'#Form.PM_CER#',
				PM_Actual			=	'#Form.PM_Actual#',
				PM_Date_Modified	=	 #now()#,
				PM_Modified_By_ID	=	'#request.AccessStructure.User_ID#',
				PM_Deleted			=	'#PM_Deleted#',
				PM_Hide				=	#Form.PM_Hide#

	WHERE 		PM_Item_Master_ID	=	'#Form.RID#'

</CFQUERY>
</cfif>


	<!------ Insert notes ----->
	<CFIF Trim(Form.PM_Notes) NEQ "">
	<cfset useLakebaseForSave_Notes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_notes")>
<cfif useLakebaseForSave_Notes>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_notes", {
			"pm_item_master_id" = "#Form.RID#",
			"pm_notes" = "#Form.PM_Notes#",
			"user_id" = "#request.AccessStructure.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Notes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Notes>
<CFQUERY NAME="Save_Notes" datasource="#application.datasource#">
		INSERT	INTO PM_Notes
				(
					PM_Item_Master_ID,
					PM_Notes,
					User_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#Form.PM_Notes#',
					'#request.AccessStructure.User_ID#'
				)
	</CFQUERY>
</cfif>
	</CFIF>

	

	
<!--- Delete all owners that belong to this projects and underneath me --->

<!---  initial user position--->
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
<!--- list of positions underneath supplied --->
<CFSET ListOfPositionsUnderMine = GP_Position_List_From_My_Position_Down>

<CFQUERY NAME="Delete_Owners" datasource="#application.datasource#">
	DELETE FROM 	PM_Owner_Position
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
					AND
					User_Positions_ID IN (#ListOfPositionsUnderMine#)
</CFQUERY>
<CFPARAM NAME="Form.User_Positions_List" DEFAULT="">


<!--- Save the owners list --->
<CFLOOP INDEX="item" LIST="#Form.User_Positions_List#" DELIMITERS=",">
	<cfset useLakebaseForSave_Owners = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_owner_position")>
<cfif useLakebaseForSave_Owners>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_owner_position", {
			"pm_item_master_id" = "#Form.RID#",
			"user_positions_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Owners = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Owners>
<CFQUERY NAME="Save_Owners" datasource="#application.datasource#">
		INSERT	INTO PM_Owner_Position
				(
					PM_Item_Master_ID,
					User_Positions_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>
	
<!--- Delete all programs that belong to this project --->
<cfset useLakebaseForDelete_Programs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_programs")>
<cfif useLakebaseForDelete_Programs>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_programs", {
			"pm_item_master_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Programs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Programs>
<CFQUERY NAME="Delete_Programs" datasource="#application.datasource#">
	DELETE FROM 	PM_Programs
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>


<CFPARAM NAME="Form.PM_Contract_Number" DEFAULT="">


<!--- Save the program list --->
<CFLOOP INDEX="item" LIST="#Form.PM_Contract_Number#" DELIMITERS=",">
	<cfset useLakebaseForSave_Programs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_programs")>
<cfif useLakebaseForSave_Programs>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_programs", {
			"pm_item_master_id" = "#Form.RID#",
			"pm_contract_number" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Programs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Programs>
<CFQUERY NAME="Save_Programs" datasource="#application.datasource#">
		INSERT	INTO PM_Programs
				(
					PM_Item_Master_ID,
					PM_Contract_Number
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>


<!--- Delete all brokers that belong to this project --->
<cfset useLakebaseForDelete_QBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_qbrands")>
<cfif useLakebaseForDelete_QBrands>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_qbrands", {
			"pm_item_master_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_QBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_QBrands>
<CFQUERY NAME="Delete_QBrands" datasource="#application.datasource#">
	DELETE FROM 	PM_Qbrands
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>


<!--- Save the broker list --->
<CFLOOP INDEX="item" LIST="#Form.QBrand_List#" DELIMITERS=",">
	<cfset useLakebaseForSave_QBrands = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_qbrands")>
<cfif useLakebaseForSave_QBrands>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_qbrands", {
			"pm_item_master_id" = "#Form.RID#",
			"q_brand_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_QBrands = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_QBrands>
<CFQUERY NAME="Save_QBrands" datasource="#application.datasource#">
		INSERT	INTO PM_Qbrands
				(
					PM_Item_Master_ID,
					Q_Brand_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>

<!--- Delete all brokers that belong to this project --->
<cfset useLakebaseForDelete_Brokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_brokers")>
<cfif useLakebaseForDelete_Brokers>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_brokers", {
			"pm_item_master_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Brokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Brokers>
<CFQUERY NAME="Delete_Brokers" datasource="#application.datasource#">
	DELETE FROM 	PM_Brokers
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>


<!--- Save the broker list --->
<CFLOOP INDEX="item" LIST="#Form.Broker_List#" DELIMITERS=",">
	<cfset useLakebaseForSave_Brokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_brokers")>
<cfif useLakebaseForSave_Brokers>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_brokers", {
			"pm_item_master_id" = "#Form.RID#",
			"bsa_foodservice_brokers_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Brokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Brokers>
<CFQUERY NAME="Save_Brokers" datasource="#application.datasource#">
		INSERT	INTO PM_Brokers
				(
					PM_Item_Master_ID,
					BSA_Foodservice_Brokers_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>


<!--- Delete all Distributors that belong to this project --->
<cfset useLakebaseForDelete_Distributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_distributors")>
<cfif useLakebaseForDelete_Distributors>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_distributors", {
			"pm_item_master_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Distributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Distributors>
<CFQUERY NAME="Delete_Distributors" datasource="#application.datasource#">
	DELETE FROM 	PM_Distributors
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>

<!--- Save the Distributor list --->
<CFLOOP INDEX="item" LIST="#Form.Distributor_List#" DELIMITERS=",">
	<cfset useLakebaseForSave_Distributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_distributors")>
<cfif useLakebaseForSave_Distributors>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_distributors", {
			"pm_item_master_id" = "#Form.RID#",
			"bsa_foodservice_customers_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Distributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Distributors>
<CFQUERY NAME="Save_Distributors" datasource="#application.datasource#">
		INSERT	INTO PM_Distributors
				(
					PM_Item_Master_ID,
					BSA_Foodservice_Customers_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>

<!--- Delete all Operators that belong to this project --->
<cfset useLakebaseForDelete_Operators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_operators")>
<cfif useLakebaseForDelete_Operators>
	<cftry>
		<cfset application.oLakebase.deleteRows("pm_operators", {
			"pm_item_master_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Operators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Operators>
<CFQUERY NAME="Delete_Operators" datasource="#application.datasource#">
	DELETE FROM 	PM_Operators
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>


<!--- Save the Operator list --->
<CFLOOP INDEX="item" LIST="#Form.Operator_List#" DELIMITERS=",">
	<cfset useLakebaseForSave_Operators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_operators")>
<cfif useLakebaseForSave_Operators>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_operators", {
			"pm_item_master_id" = "#Form.RID#",
			"bsa_operator_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Operators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Operators>
<CFQUERY NAME="Save_Operators" datasource="#application.datasource#">
		INSERT	INTO PM_Operators
				(
					PM_Item_Master_ID,
					BSA_Operator_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>

<!--- Delete all Attached Documents that belong to this project --->
<cfset useLakebaseForDelete_Attachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForDelete_Attachments>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_attachments", {
			"project_id" = "eq.#Form.RID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDelete_Attachments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDelete_Attachments>
<CFQUERY NAME="Delete_Attachments" datasource="#application.datasource#">
	DELETE FROM 	Contract_Attachments
	WHERE 			Project_ID	=	'#Form.RID#'
</CFQUERY>
</cfif>


<!--- Save the Attached Documents --->
<CFIF isdefined("FORM.Doc_ID")>
<CFLOOP INDEX="item" LIST="#Form.Doc_ID#" DELIMITERS=",">
	<cfset useLakebaseForSave_Attachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForSave_Attachments>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"project_id" = "#Form.RID#",
			"doc_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Attachments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Attachments>
<CFQUERY NAME="Save_Attachments" datasource="#application.datasource#">
		INSERT	INTO Contract_Attachments
				(
					Project_ID,
					Doc_ID
				)
		VALUES
				(
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>
</CFIF>

<!--- Otherwise, create a new record --->
<CFELSE>

<cfset useLakebaseForCreate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_item_master")>
<cfif useLakebaseForCreate_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("pm_item_master", {
			"pm_priority_id" = "#Form.PM_Priority_ID#",
			"pm_status_id" = "#Form.PM_Status_ID#",
			"pm_phase_id" = "#Form.PM_Phase_ID#",
			"pm_start_date" = "#Form.PM_Start_Date#",
			"pm_end_date" = "#Form.PM_End_Date#",
			"pm_acct_project" = "#Form.PM_Acct_Project#",
			"pm_value_pounds" = "#Form.PM_Value_Pounds#",
			"pm_value_dollars" = "#Form.PM_Value_Dollars#",
			"pm_far_id" = "#Form.PM_Far_ID#",
			"pm_sponsor_id" = "#Form.PM_Sponsor_ID#",
			"pm_resources" = "#Form.PM_Resources#",
			"pm_support" = "#Form.PM_Support#",
			"pm_ext_budget" = "#Form.PM_Ext_Budget#",
			"pm_cer" = "#Form.PM_CER#",
			"pm_actual" = "#Form.PM_Actual#",
			"pm_created_by_id" = "#request.AccessStructure.User_ID#",
			"pm_modified_by_id" = "#request.AccessStructure.User_ID#",
			"pm_hide" = "#Form.PM_Hide#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForCreate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreate_Data>
<CFQUERY NAME="Create_Data" datasource="#application.datasource#">
	INSERT	INTO PM_Item_Master
				(
				PM_Priority_ID,
				PM_Status_ID,
				PM_Phase_ID,
				PM_Start_Date,
				PM_End_Date,
				PM_Acct_Project,
				PM_Value_Pounds,
				PM_Value_Dollars,
				PM_Far_ID,
				PM_Sponsor_ID,
				<!---PM_Owner_ID,--->
				<!----PM_Position_ID,---->
				<!---PM_Notes,--->
				PM_Resources,
				PM_Support,
				PM_Ext_Budget,
				PM_CER,
				PM_Actual,
				PM_Created_By_ID,
				PM_Modified_By_ID,
				PM_Hide
				)
		VALUES
				(
				'#Form.PM_Priority_ID#',
				'#Form.PM_Status_ID#',
				'#Form.PM_Phase_ID#',
				'#Form.PM_Start_Date#',
				'#Form.PM_End_Date#',
				'#Form.PM_Acct_Project#',
				'#Form.PM_Value_Pounds#',
				'#Form.PM_Value_Dollars#',
				'#Form.PM_Far_ID#',
				'#Form.PM_Sponsor_ID#',
				<!------'#Form.PM_Owner_ID#',----->
				<!----'#Form.PM_Position_ID#',---->
				<!---'#Form.PM_Notes#',--->
				'#Form.PM_Resources#',
				'#Form.PM_Support#',
				'#Form.PM_Ext_Budget#',
				'#Form.PM_CER#',
				'#Form.PM_Actual#',
				'#request.AccessStructure.User_ID#',
				'#request.AccessStructure.User_ID#',
				#Form.PM_Hide#
				)
</CFQUERY>
</cfif>


	<!------ Insert notes ----->
	<CFIF Trim(Form.PM_Notes) NEQ "">
	<CFQUERY NAME="Save_Notes" datasource="#application.datasource#">
		INSERT	INTO PM_Notes
				(
					PM_Item_Master_ID,
					PM_Notes,
					User_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#PM_Notes#',
					'#request.AccessStructure.User_ID#'
				)
	</CFQUERY>
	</CFIF>
	
	
<CFPARAM NAME="Form.User_Positions_List" DEFAULT="">
<!--- Save the owners list --->
<CFLOOP INDEX="item" LIST="#Form.User_Positions_List#" DELIMITERS=",">
	<CFQUERY NAME="Save_Owners" datasource="#application.datasource#">
		INSERT	INTO PM_Owner_Position
				(
					PM_Item_Master_ID,
					User_Positions_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>
	
<CFPARAM NAME="Form.PM_Contract_Number" DEFAULT="">
<!--- Save the program list --->
<CFLOOP INDEX="item" LIST="#Form.PM_Contract_Number#" DELIMITERS=",">
	<CFQUERY NAME="Save_Programs" datasource="#application.datasource#">
		INSERT	INTO PM_Programs
				(
					PM_Item_Master_ID,
					PM_Contract_Number
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>


<!--- Save the broker list --->
<CFLOOP INDEX="item" LIST="#Form.QBrand_List#" DELIMITERS=",">
	<CFQUERY NAME="Save_QBrands" datasource="#application.datasource#">
		INSERT	INTO PM_Qbrands
				(
					PM_Item_Master_ID,
					Q_Brand_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>

<!--- Save the broker list --->
<CFLOOP INDEX="item" LIST="#Form.Broker_List#" DELIMITERS=",">
	<CFQUERY NAME="Save_Programs" datasource="#application.datasource#">
		INSERT	INTO PM_Brokers
				(
					PM_Item_Master_ID,
					BSA_Foodservice_Brokers_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>


<!--- Save the Distributor list --->
<CFLOOP INDEX="item" LIST="#Form.Distributor_List#" DELIMITERS=",">
	<CFQUERY NAME="Save_Programs" datasource="#application.datasource#">
		INSERT	INTO PM_Distributors
				(
					PM_Item_Master_ID,
					BSA_Foodservice_Customers_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>

<!--- Save the Distributor list --->
<CFLOOP INDEX="item" LIST="#Form.Operator_List#" DELIMITERS=",">
	<CFQUERY NAME="Save_Programs" datasource="#application.datasource#">
		INSERT	INTO PM_Operators
				(
					PM_Item_Master_ID,
					BSA_Operator_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>
<!--- Save Attached Documents --->
<CFLOOP INDEX="item" LIST="#Form.Attachment_List#" DELIMITERS=",">
	<cfset useLakebaseForAttachment_details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForAttachment_details>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"project_id" = "#Create_Data.PM_Item_Master_ID#",
			"doc_id" = "#item#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForAttachment_details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAttachment_details>
<CFQUERY NAME="Attachment_details" datasource="#application.datasource#">
		INSERT	INTO Contract_Attachments
				(					
					Project_ID,
					Doc_ID
				)
		VALUES
				(
					'#Create_Data.PM_Item_Master_ID#',
					'#item#'
				)
	</CFQUERY>
</cfif>
</CFLOOP>


</CFIF>

<!---- unlock project ---->
<CFSET PRESENT_LOCK_STATUS = 1>
<CFIF IsDefined("Create_Data.PM_Item_Master_ID")>
	<CFSET FORM.LOCK_RID = Create_Data.PM_Item_Master_ID>
<CFELSE>
	<CFSET FORM.LOCK_RID = Form.RID>
</CFIF>
<CFSET No_Redirect = 1>
<CFINCLUDE TEMPLATE="PM_Lock.cfm">

<CFPARAM NAME="FORM.FID" 	DEFAULT="">
<CFLOCATION URL="PM_Create.cfm?RID=#FORM.LOCK_RID#&FID=#FORM.FID#" ADDTOKEN="No">


</BODY>
</HTML>



