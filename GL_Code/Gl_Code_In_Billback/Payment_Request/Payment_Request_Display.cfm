<cfparam name="HoldStatus" default="0">
<cfparam name="FORM.DD_Reason_Code_ID" default ="0">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF IsDefined("URL.ApproveThisPR")>
		<!--- <!------ D13515: Guard against refresh and back button creating duplicate entries in the log  -------->
<!------ We will maintain a flag till this whole page finishes executing,a nd do nto let the user process this page multiple times -------->
<CFQUERY NAME="GetBBProcessingFlag" DATASOURCE="#Application.Datasource#">
	SELECT	Log_Processing
	FROM	Billback
	where Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_ID#" />
</CFQUERY> --->
<!--- 
----- Commenting the below for D25420 - The system is already processing some action...message disable ------
<cfif GetBBProcessingFlag.Log_Processing eq 1>
	<br><br>

	<div align="center">
	<div style="color:red;font-weight:bold;">
	The system is already processing some action for this Billback, please wait.
	If this continues please contact the system administrator.
	<br><br>
	<CF_button
			button_name		=	""
			button_caption	=	"go back to summary"
			button_action	=	"window.parent.location.href = '/billbacks/capture/index.cfm?bbid=#Billback_ID#'; return false;"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</div>
	</div>
	<cfabort>
</cfif> --->
	<cftry>
	<!--- <cfquery name="setBBLogProcessing" datasource="#application.datasource#">
	 Update billback
	 set Log_Processing = 1
	 where Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_ID#" />
	 </cfquery> --->
	 
	<CFQUERY NAME="getPayeeType" DATASOURCE="#Application.Datasource#">
		SELECT Billback_Payee_Type_ID,BB_Closing_Method FROM Billback WHERE Billback_ID = '#Billback_ID#'
	</CFQUERY>

	<CFQUERY NAME="ApproveThisPR" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		
		SET 	--Approved = 1,
				Approved_Date = getdate(),
				Approved_By = '#request.AccessStructure.User_ID#'
				
		WHERE	Billback_ID = '#Billback_ID#'
	</CFQUERY>	

	<CFSET DateTimeHolder = now()>
	
	<CFIF getPayeeType.BB_Closing_Method NEQ 3 AND getPayeeType.BB_Closing_Method NEQ 4>
	<CFSET Log_700_DataInsert = CreateObject("component", "components.Interfaces.Log700").init(Billback_ID,DateTimeHolder) />
	<CFSET Log_700_DataInsert.AddtoLog()>
	</CFIF>
	<CFSET Log_900_DataInsert = CreateObject("component", "components.Interfaces.Log900").init(Billback_ID, 1,DateTimeHolder) />
	<CFSET Log_900_DataInsert.AddtoLog()>
	
	<CFSET Log_910_DataInsert = CreateObject("Component", "Components.Interfaces.Log910").init(Billback_ID, 1, Log_900_DataInsert.getLog_900_ID(),DateTimeHolder) />
	<CFSET Log_910_DataInsert.AddtoLog()>

	<CFSET Log_920_DataInsert = CreateObject("Component", "Components.Interfaces.Log920").init(Billback_ID, 1, Log_900_DataInsert.getLog_900_ID(),DateTimeHolder) />
	<CFSET Log_920_DataInsert.AddtoLog()>
	
	
	<!----- we will let the entries valid only if teh vendor id is not empty ----->
	<!----- if the vendor id is empty the billback should be set to 'vendor id null' status. ----->
	<cfquery name="qGetVendorIdFrom900Table" datasource="#application.datasource#">
		select	TOP 1 Vendor_ID
		from	Log_900
		where	deleted = 0
		--and		Current_Insert = 1
		and		Billback_ID = '#Billback_ID#'
		ORDER BY Log_900_ID DESC
	</cfquery>
	
	<cfquery name="qGetVendorIdFromApproved" datasource="#application.datasource#">
		select Vendor_Master_ID
		FROM	BB_Approved
		WHERE 	Billback_ID = '#Billback_ID#'
	</cfquery>
	<!--- Check 900 first.  Some templates do not populate 900 so look in bb_approved if no data in 900 --->
	<cfif (qGetVendorIdFrom900Table.RecordCount GT 0 AND qGetVendorIdFrom900Table.Vendor_ID EQ "") OR qGetVendorIdFromApproved.Vendor_Master_ID EQ "">
		<!----- if vendor id is either null or empty, set the billback to 'vendor id null' status  ----->
		<cfquery name="qUpdateBillbackToPendingVendorStatus" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback_Status_ID = 7
			WHERE	Billback_ID = '#Billback_ID#'
		</cfquery>
	
	<cfelse>
	
		<CFSET Close_700 = 1>
		<CFSET Close_900 = 1>
		<CFSET Close_910 = 1>
		<CFSET Close_920 = 1>
		<!--- Ana 15454 - Commentting to avoid DeadLock
		<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Close_All_Interface_Insert.cfm"> --->
		
	</cfif>


	<CFQUERY NAME="ApproveThisPR" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		
		SET 	Approved = 1
		
		WHERE	Billback_ID = '#Billback_ID#'
	</CFQUERY>	
	
	<cfif HoldStatus NEQ 1>
		<!--- print the approved billback --->
		<cfoutput>
			<script>
				NewWindow('/billbacks/common/bb_printer_friendly.cfm?BBID=#Billback_ID#','name','1000','600','Yes', 'No');
			</script>
		</cfoutput>	

		<cfquery name="DefaultSignedToOn" datasource="#application.datasource#">
			UPDATE Billback
			SET		BB_Payment_Request_Approved = 1,
					BB_Payment_Request_Approved_Date = getdate(),
					BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#'
			WHERE Billback_ID = '#Billback_ID#'
		</cfquery>
	</cfif>
	<!--- 
	<!-----  reset the flag -------->
<cfquery name="UpdateBillbackAfterPopulatingLogTables" datasource="#application.datasource#">
   UPDATE 	Billback
   SET 	Log_Processing = 0
   where Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_ID#" />
   </cfquery>
 --->
<cfcatch>

	<!-----  reset the flag -------->
	<cfquery name="UpdateBillbackAfterPopulatingLogTables" datasource="#application.datasource#">
	UPDATE 	Billback
	   SET 	Log_Processing = 0
   where Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Billback_ID#" />
	</cfquery> 

	<cfrethrow>

</cfcatch>
	</cftry>
	<CFLOCATION URL="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#&FinalAllocationDisp=1&payeeType=#getPayeeType.Billback_Payee_Type_ID#" ADDTOKEN="No">
		
	<!-----
	<CFIF IsDefined("Deduction_ID")>
		<cfquery name="SetBillbacktoPaid" datasource="#application.datasource#">
			UPDATE Billback
			SET Billback_Status_ID = 5
			WHERE Billback_ID = '#Billback_ID#'
		</cfquery>
		<BR><BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="2">This billback status will be changed as Paid and you will be directed to the deduction.</FONT></B></TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
		function redirectToBB()
		{
			window.parent.location.href = "/deductions/deduction.cfm?Deduction_ID=<CFOUTPUT>#Deduction_ID#</CFOUTPUT>&BBPaid=1";
		}
		window.setTimeout('redirectToBB()', 4000);
		</SCRIPT>
		<CFABORT>
	</CFIF>
	---->
</CFIF>
<CFIF IsDefined("FORM.Vendor_Master_ID")>
	<cfparam name="form.NextAction" default="">
	<!--- 9286: Check Duplicate Vendor_ID, BB_Reference --->
	<CFIF appSettings.getBB_Pay_Req_Dup_Check()>
	<CFINCLUDE TEMPLATE = "BB_Ref_Vendor_ID_Duplicate_Check.cfm">
	</CFIF>
	
	<CFSET ReplacedID = REPLACE(Vendor_Master_ID,"-","_","All")>
	<CFQUERY NAME="VendorID" DATASOURCE="#Application.Datasource#">
		UPDATE 	BB_Approved
		SET 	Vendor_Master_ID = '#FORM.Vendor_Master_ID#'
		WHERE 	Billback_ID = '#Billback_ID#'
	</CFQUERY>
	<CFQUERY NAME="CheckParent" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback WHERE Billback_ID = '#Billback_ID#' 
	</CFQUERY>
	<CFIF CheckParent.Billback_Status_ID NEQ 4>
		<CFQUERY NAME="PaymentRequested" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback 
			SET 	Billback_Status_ID = 4
			WHERE 	Billback_ID = '#Billback_ID#' AND
					Billback_Status_ID NOT IN (4,5)
		</CFQUERY>
	</CFIF>
	
	<CFIF CheckParent.BB_parent_ID NEQ "">
		<CFQUERY NAME="AnyUnclosedSplit" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Billback
			WHERE 	BB_Parent_ID = '#CheckParent.BB_Parent_ID#' AND
					(	(BB_Closing_Method = 2 AND BB_Associated_To_DD = 0) OR
						(BB_Closing_Method = 1 AND Billback_Status_ID NOT IN (4,5))
					) AND
					Deleted = 0						
	 	</CFQUERY>
	
		<CFIF AnyUnclosedSplit.RecordCOunt EQ 0>
			<CFQUERY NAME="CloseParent" DATASOURCE="#Application.Datasource#">
				UPDATE Billback
				SET Billback_Status_ID = 4
				WHERE Billback_ID = '#CheckParent.BB_Parent_ID#'
			</CFQUERY>
		</CFIF>
	</CFIF>

<!--- If a reasoncode exists (If app setting on-[BB Approval Screen will display reason code], then the user is forced to choose one) --->
<cfif FORM.DD_Reason_Code_ID neq 0>
 <CFQUERY NAME="UpdateReasonCode" DATASOURCE="#Application.Datasource#">
		UPDATE 	BB_Approved
		SET 	BB_Reason_Code_ID = '#ListFirst(FORM.DD_Reason_Code_ID)#'
		WHERE 	Billback_ID = '#Billback_ID#'
	</CFQUERY>
</cfif>
<!--- save selected reason code --->
<!--- this is outside above if condition because if nothign selected, we want the function to delete any existing entry --->
<cfset CreateObject("component", "components.billback.BillbackManager").saveBillbackClosingMethod(billbackID = Billback_ID, BBReasonCodeIDList = FORM.DD_Reason_Code_ID) />

	<!--- Ana: D15168 - Disable Reset link --->
	<cfset local_bbid = Billback_ID>
	<cfinclude template="/Billbacks/Capture/bb_menu_stats.cfm">
	<CFIF appSettings.getVendor_Selection_Pay_Req()>
		<CFLOCATION URL="/GL_Code/GL_Code_In_Billback/Payment_Request/Approve_VendorID_Selection_Pay_Req.cfm?Billback_ID=#Billback_ID#&NextAction=#form.NextAction#" ADDTOKEN="No">
	</CFIF>
</CFIF>



<CFSET FinalAllocationDisp = 1>
<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm">
<script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
	try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>
