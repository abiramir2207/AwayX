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
					'#Form.RID#',
					'#Form.PM_Notes#',
					'#request.AccessStructure.User_ID#'
				)
	</CFQUERY>
	</CFIF>

	

	
<!--- Delete all owners that belong to this projects and underneath me --->

<!---  initial user position--->
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
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
</CFLOOP>
	
<!--- Delete all programs that belong to this project --->
<CFQUERY NAME="Delete_Programs" datasource="#application.datasource#">
	DELETE FROM 	PM_Programs
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>


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
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>


<!--- Delete all brokers that belong to this project --->
<CFQUERY NAME="Delete_QBrands" datasource="#application.datasource#">
	DELETE FROM 	PM_Qbrands
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>


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
					'#Form.RID#',
					'#item#'
				)
	</CFQUERY>
</CFLOOP>

<!--- Delete all brokers that belong to this project --->
<CFQUERY NAME="Delete_Brokers" datasource="#application.datasource#">
	DELETE FROM 	PM_Brokers
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>


<!--- Save the broker list --->
<CFLOOP INDEX="item" LIST="#Form.Broker_List#" DELIMITERS=",">
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
</CFLOOP>


<!--- Delete all Distributors that belong to this project --->
<CFQUERY NAME="Delete_Distributors" datasource="#application.datasource#">
	DELETE FROM 	PM_Distributors
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>

<!--- Save the Distributor list --->
<CFLOOP INDEX="item" LIST="#Form.Distributor_List#" DELIMITERS=",">
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
</CFLOOP>

<!--- Delete all Operators that belong to this project --->
<CFQUERY NAME="Delete_Operators" datasource="#application.datasource#">
	DELETE FROM 	PM_Operators
	WHERE 			PM_Item_Master_ID	=	'#Form.RID#'
</CFQUERY>


<!--- Save the Operator list --->
<CFLOOP INDEX="item" LIST="#Form.Operator_List#" DELIMITERS=",">
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
</CFLOOP>

<!--- Delete all Attached Documents that belong to this project --->
<CFQUERY NAME="Delete_Attachments" datasource="#application.datasource#">
	DELETE FROM 	Contract_Attachments
	WHERE 			Project_ID	=	'#Form.RID#'
</CFQUERY>


<!--- Save the Attached Documents --->
<CFIF isdefined("FORM.Doc_ID")>
<CFLOOP INDEX="item" LIST="#Form.Doc_ID#" DELIMITERS=",">
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
</CFLOOP>
</CFIF>

<!--- Otherwise, create a new record --->
<CFELSE>

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



