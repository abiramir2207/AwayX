<HTML>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>

<CFPARAM NAME="Form_Submitted" DEFAULT="0">
<cfparam name="TransactionType" default="Release">

<CFPARAM NAME="FORM.ApproveBB" DEFAULT="">
<CFPARAM NAME="FORM.Final_Signed_Paid" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelected_Signed_Paid" DEFAULT="">
<cfparam name="form.AllEligibleBBs" default="">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFSET count = 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Select billback that are ready to be signed for payment ---> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">

<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">

<CFPARAM NAME="FORM.SORTBY" 	DEFAULT="">
<CFPARAM NAME="FORM.SORTORDER" 	DEFAULT="">

<CFPARAM NAME="URL.SORTBY" 	DEFAULT="#FORM.SORTBY#">
<CFPARAM NAME="URL.SORTORDER" 	DEFAULT="#FORM.SORTORDER#">

	<!---How the data is sorted--->
	<CFSET sql_Sort_By="Billback.BB_Title">
	<CFSWITCH expression="#URL.SORTBY#">
		<!---Payable number--->
		<CFCASE value="BBI">
			<CFSET sql_Sort_By="Billback.BB_Code">
		</CFCASE>
		<!---Billback number--->
		<CFCASE value="BBNUM">
			<CFSET sql_Sort_By="Billback.BB_Reference">
		</CFCASE>	
		<!---Billback title--->
		<CFCASE value="BBT">
			<CFSET sql_Sort_By="Billback.BB_Title">
		</CFCASE>
		<!---Billback title--->
		<CFCASE value="Pay">
			<CFSET sql_Sort_By="Customer_Name">
		</CFCASE>
		<!---Billback Date--->
		<CFCASE value="BBD">
			<CFSET sql_Sort_By="dbo.Billback.BB_Date">
		</CFCASE>	
		<!--- Amount--->
		<CFCASE value="PR_A">
			<CFSET sql_Sort_By="Tot_Amount">
		</CFCASE>
		<!--- Amount--->
		<CFCASE value="PR_STATUS">
			<CFSET sql_Sort_By="Signed">
		</CFCASE>
		<!--- Start Date --->
		<CFCASE value="BBSD">
			<CFSET sql_Sort_By="Billback.BB_Start_Date">
		</CFCASE>
		<CFCASE value="BBED">
			<CFSET sql_Sort_By="Billback.BB_End_Date">
		</CFCASE>
		<CFCASE value="BBAMT">
			<CFSET sql_Sort_By="Billback.BB_Amount">
		</CFCASE>
		<!--- Approved oN --->
		<!------<CFCASE value="PR_A">
			<CFSET sql_Sort_By="Approved_Date">
		</CFCASE>----->	
	</CFSWITCH>

	
	<CFIF URL.SORTORDER EQ "DESC">
		<CFSET sql_Sort_By="#sql_Sort_By# DESC">
	<CFELSE>
		<CFSET sql_Sort_By="#sql_Sort_By# ASC">
	</CFIF>
	
	<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">

	<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
		#PreserveSingleQuotes(AllowBillbackIDs)#
		
		SELECT 		DISTINCT
					Billback.Billback_ID,
					Billback.BB_Code,
					Billback.BB_Date,
					Billback.BB_Start_Date,
					Billback.BB_End_Date,
					Billback.BB_Amount,
					Billback.BB_Reference,
					CASE
						WHEN Billback.Billback_Payee_Type_ID=1 THEN  
						ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)
						
						WHEN Billback.Billback_Payee_Type_ID=2 THEN
						BSA_Operator.Operator_Name  

						
						WHEN Billback.Billback_Payee_Type_ID=3 THEN 
						BSA_Foodservice_Brokers.Broker_Name
						 
						WHEN Billback.Billback_Payee_Type_ID=4 THEN
						Billback_Unidentified_Payee.BB_UP_Name
						
						WHEN Billback.Billback_Payee_Type_ID=5 THEN
						Billback_Distributor.BB_Distributor_Name
						
						WHEN Billback.Billback_Payee_Type_ID=6 THEN
						Billback_Operator.BB_Operator_Name
						
						WHEN Billback.Billback_Payee_Type_ID=7 THEN
						Billback_Broker.BB_Broker_Name
						 
					END AS Customer_Name,					
					BB_Title,						
					Paid_Amount Tot_Amount,		
					1 AS Payment_Type,
					BB_Payment_Request_Sent AS Check_Issued,
					BB_Payment_Request_Prepared_Date Prepared_Date,
					aaa.Name_First Prepared_By_First_Name,
					aaa.Name_Last Prepared_By_Last_Name,
					BB_Payment_Request_Approved Signed,
					BB_Payment_Request_Approved_Date Signed_Date,
					_Users.Name_First Signed_By_First_Name,
					_Users.Name_Last Signed_By_Last_Name,
					ISNULL(Gl_Code_Allocation.Approved, 0) as Payment_Request_Approved
		FROM 		Billback 
		LEFT JOIN	Billback_Allied ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
		LEFT JOIN 	( Billback_Broker LEFT JOIN BSA_Foodservice_Brokers ON (Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)) ON ((Billback_Broker.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 3) OR (Billback.Billback_Payee_Type_ID = 7)) AND (Billback_Broker.Deleted = 0)) 
		LEFT JOIN 	( Billback_Distributor LEFT JOIN BSA_Foodservice_Customers ON (Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)) ON ((Billback_Distributor.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 1) OR	(Billback.Billback_Payee_Type_ID = 5)) AND (Billback_Distributor.Deleted = 0)) 
		LEFT JOIN 	( Billback_Operator LEFT JOIN BSA_Operator ON (Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)) ON ((Billback_Operator.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 2) OR (Billback.Billback_Payee_Type_ID = 6)) AND (Billback_Operator.Deleted = 0))  
		LEFT JOIN 	Billback_Unidentified_Payee ON ((Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID) AND (Billback.Billback_Payee_Type_ID = 4) AND (Billback_Unidentified_Payee.Deleted = 0))
		LEFT JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		LEFT JOIN 	Gl_Code_Allocation ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID AND Gl_Code_Allocation.Deleted = 0
		LEFT JOIN	_Users	ON _Users.User_ID = Billback.BB_Payment_Request_Approved_By AND _Users.Deleted = 0
		LEFT JOIN 	_Users aaa ON aaa.User_ID = Billback.BB_Payment_Request_Prepared_By AND aaa.deleted = 0
		LEFT JOIN Vendor_Master VM ON ---added VM join for Auto Pay w/multiple distributors
					Billback.Billback_Payee_Type_ID = 1 AND 
					VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
		WHERE 		Billback_Status_ID = 4 AND Billback.Deleted = 0 --AND Billback.BB_Payment_Request_Prepared = 1
					AND (
					<cfif UserIsAnalyst EQ 0>
					Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
					<cfif listlen(BillbackIDs) GT 0>
					OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
					</cfif>
				<cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
					<cfif AnalystList NEQ "">
					OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
					OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
					</cfif>
				</cfif>
					<cfif listlen(BillbackIDs) GT 0>
					OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
					</cfif>
					 )
		ORDER BY 	#sql_Sort_By#		 	
	</CFQUERY>
	 


<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>


<cf_Number_of_Rows maxrows=25>

<CFSET listofitemstodelete = "">

	<!--- BJF: Need a list of all the approvable billbacks for this user for select all --->

	
	<cfquery name="AllEligibleBBs" dbtype="Query">
	SELECT Billback_ID 
	FROM Get_Data
	WHERE 0 = 0
	<CFIF Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">AND Tot_Amount <= #Get_Profile_Settings.BB_Pay_Req_Approval_Amount#</cfif>
	</cfquery>
	
	<cfset EligibleBBList = valuelist(AllEligibleBBs.Billback_ID)>
	
	<CFIF Form_Submitted EQ 1 >
	
	<CFIF (TransactionType EQ "Release" OR TransactionType EQ "Hold")>
		<cfset EligibleBBList = billback_id>
	</CFIF>
	
	<CFQUERY NAME="ApproveThis" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		
		SET 	Approved = 1,
				Approved_Date = getdate(),
				Approved_By = '#Request.AccessStructure.User_ID#'
				
		WHERE	Billback_ID IN (#listqualify(EligibleBBList, "'")#)
	</CFQUERY>
	
	<CFQUERY NAME="UpDateBillback" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback
		
		SET 	BB_Payment_Request_Approved = <CFIF TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">1<CFELSE>0</CFIF>,
				BB_Payment_Request_Approved_Date = <CFIF TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">getdate()<CFELSE>NULL</CFIF>,
				BB_Payment_Request_Approved_By = <CFIF TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">'#Request.AccessStructure.User_ID#'<CFELSE>NULL</CFIF>
				
		WHERE	Billback_ID IN (#listqualify(EligibleBBList, "'")#)
	</CFQUERY>

	<CFIF TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">
		<cfoutput>
		<CFLOOP index = "BBID_ForPrinting" list = "#EligibleBBList#">
			<script>
				NewWindow('/billbacks/common/bb_printer_friendly.cfm?BBID=#BBID_ForPrinting#','name','1000','600','Yes', 'No');
			</script>
		</CFLOOP>
		</cfoutput>	
	</CFIF>
	<CFIF TransactionType EQ "Release" OR TransactionType EQ "Hold">
		<CFLOCATION URL="SC_Payment_Request.cfm?StartRow=#form.StartRow#"> 
	<CFELSE>
		<CFLOCATION URL="SC_Payment_Request.cfm" ADDTOKEN="No">
	</CFIF>
</CFIF>

<CFIF Form_Submitted NEQ 1>
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
	
	<CFFLUSH>
	
	<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>


	<!--- 
	<CFQUERY NAME="Get_data" DATASOURCE="#Application.Datasource#">
		SELECT 		Payment_Data_Export_1.*, 
					Payment_Data_Export_1.BB_Code, 
					Billback.BB_Title
				
		FROM 		Payment_Data_Export_1
		
		INNER JOIN 	Billback ON Billback.Billback_ID = Payment_Data_Export_1.Billback_ID
					AND Billback.Deleted=0
					
		WHERE 		Paid = 0 AND Payment_Data_Export_1.Deleted=0 AND Payment_Data_Export_1.Saved=1
		ORDER BY 	#sql_Sort_By#
	</CFQUERY>
	 --->
	
	

	<CFINCLUDE TEMPLATE="/Billbacks/scorecard/billback_Table_Measures.cfm">
	
	
	<FORM NAME="MyForm" ACTION="/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request.cfm" METHOD="POST" STYLE="DISPLAY:INLINE;">
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
	
	<TABLE BORDER="0" WIDTH="<CFOUTPUT>#table_Width#</CFOUTPUT>" CELLSPACING="0" CELLPADING="0" CLASS="Maintable">
	<!------
	<TR>
		<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
	</TR>
	----->
	<!------
	<TR BGCOLOR="ffce84">	
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD>
		<!--- <TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD> --->
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Invoice No.</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Payee Name</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>$ Amount</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Prepared By</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Approved By</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Status</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD>
	</TR>
	----->
	<!--- <CFSET FORM.AlreadySelected_Signed_Paid = ""> --->
	<cfset Pay_Multi_Billbacks_IDs = "" />
	<CFOUTPUT QUERY="Get_data" startrow="#StartRow#" maxrows="#MaxRows#">
		<!--- <cfif NOT ListFindNoCase(Pay_Multi_Billbacks_IDs, Pay_Multi_Billbacks_ID, ",") AND Len(Pay_Multi_Billbacks_ID) GT 0>
			<cfset Pay_Multi_Billbacks_IDs = ListAppend(Pay_Multi_Billbacks_IDs, Pay_Multi_Billbacks_ID, ",") />
		</cfif> --->
		<TR BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<!------<TD NOWRAP WIDTH="13%"STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp; 
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&view=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" TITLE="">view</A></FONT>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>&nbsp;		
				<CFIF Signed EQ 0>
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&Approve=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" TITLE="">approve</A></FONT>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>
				</CFIF>
			</TD>----->
			<TD nowrap  WIDTH="62" valign="middle">&nbsp;</TD>
			<TD nowrap  WIDTH="62" valign="middle">&nbsp;</TD>
			<TD NOWRAP WIDTH="#Evaluate(PR_Number_Width - 10)#">
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
			<CFIF Payment_Type EQ 1>
			<A TARGET="_parent" Href="/Billbacks/capture/index.cfm?BBID=#Billback_ID#" STYLE="FONT-SIZE:10PX;" TITLE="View billback #BB_Code#">#BB_Code#</A>	
			<CFELSE>
			<!--- <A TARGET="_parent" Href="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/View_Edit_Approve.cfm?BBID=#Billback_ID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#" STYLE="FONT-SIZE:10PX;" TITLE="View billback #BB_Code#">#BB_Code#</A> --->
			<A TARGET="_parent" Href="/Billbacks/Multi_BB_Payment/Distributor_And_BB_Form.cfm?BBID=#Billback_ID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#" STYLE="FONT-SIZE:10PX;" TITLE="View billback #BB_Code#">#BB_Code#</A>
			</CFIF>
			<!--- <A Href="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/View_Edit_Approve.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&view=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" STYLE="FONT-SIZE:10PX;" TITLE="View the payment request of billback #BB_Code#">#BB_Code#</A> --->
			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
			<a href="/billbacks/capture/bb_preview.cfm?BBID=#Billback_ID#" style="color:RGB(0,0,0)" id="previewlink" target="preview_window">preview</a><br />
			<a href="javascript:void(0)" onClick="javascript:openDetails('#Billback_ID#')" style="color:RGB(0,0,0)" id="detailslink">details</a>

			<CFQUERY NAME="Check_Lock" DATASOURCE="#Application.Datasource#">
				SELECT 		BB_Is_Locked,Name_First, Name_Last 
				
				FROM 		Billback_Allied 
				INNER JOIN	_Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID
							AND _Users.Deleted=0
							
				WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
			<CFIF Check_Lock.BB_Is_Locked EQ 1>
				<IMG SRC="/images/lock.gif" TITLE="This billback is currently being viewed by #Check_Lock.Name_First# #Check_Lock.Name_Last#" height="16" width="12">
			<CFELSE>
				<img src="/images/fill.gif" width="12" border="0">
			</CFIF>
			</TD>
			<TD NOWRAP WIDTH="#Evaluate(PR_BBD_Width + PR_BB_Width + 10)#" COLSPAN="2" TITLE="Billback Number: #BB_Reference#">
			#dateformat(BB_Date, 'mm/dd/yyyy')#
			<BR>
			<CFSET display_Title=Left(BB_Reference, PR_Ref_Num_Len)>
			<CFIF LEN(display_Title) LT Len(BB_Reference)>
				<CFSET display_Title="#display_Title#...">
			</CFIF>
			<CFIF len(trim(display_Title)) EQ 0>
				<CFSET display_Title=" ">
			</CFIF>
	 		#HTMLEditFormat(display_Title)#
			</TD>
			<TD COLSPAN="2" WIDTH="#Evaluate(PR_Title_Width + PR_Payee_Width - 5)#" TITLE="Payee: #Customer_Name##chr(13)#Title: #HTMLEditFormat(BB_Title)#">
			<CFSET display_Title=Left(Customer_Name, PR_Payee_Len)>
			<CFIF LEN(display_Title) LT Len(Customer_Name)>
				<CFSET display_Title="#display_Title#...">
			</CFIF>
			<CFIF len(trim(display_Title)) EQ 0>
				<CFSET display_Title=" ">
			</CFIF>
	 		#HTMLEditFormat(display_Title)#
			<BR>
			<CFSET display_Title=Left(BB_Title,PR_Title_Len)>
			<CFIF LEN(display_Title) LT Len(BB_Title)>
				<CFSET display_Title="#display_Title#...">
			</CFIF>
			<CFIF len(trim(display_Title)) EQ 0>
				<CFSET display_Title=" ">
			</CFIF>
	 		#HTMLEditFormat(display_Title)#
			</TD>		
			<!---<TD NOWRAP WIDTH="#PR_Amount_Width#" TITLE="#Tot_Amount#">
			$ #NumberFormat(Tot_Amount,"_.__")#
			</TD>--->
			<TD WIDTH="#PR_Status_Width#">
			<!--- Can you adjust the status of this payment request? --->
			<CFSET Permit_Approval = 0>
				<CFIF Get_Profile_Settings.BB_Pay_Req_Approval_Amount NEQ "*">
					<CFIF Tot_Amount LTE Get_Profile_Settings.BB_Pay_Req_Approval_Amount>
						<CFSET Permit_Approval = 1>	
					<CFELSE>
						<CFSET Permit_Approval = 0>
					</CFIF>
				<CFELSE>
					<CFSET Permit_Approval = 1>
				</CFIF>
			
			<CFIF Payment_Request_Approved EQ 0>
				<!--- D13342: If the payement request is not yet approved do not give hold/release options, user will need to go inside the billback, lock it and approve the payment request --->
				&nbsp;
			<CFELSE>
				<!--- which status is this payment request in --->	
				<CFIF Signed EQ 0>
					<CFSET Count = Count + 1>				
					
					<CFIF Permit_Approval EQ 1>
					<b><font size="1">HOLD</font></b><br><A href="SC_Payment_Request.cfm?Billback_ID=#Billback_ID#&TransactionType=Release&Form_Submitted=1&StartRow=#Startrow#">release</A>
					<cfelse>
					<b><font size="1">HOLD</font></b>
					</CFIF>
	
				<CFELSEIF Signed EQ 1 AND Check_Issued NEQ 1>
					<CFIF Permit_Approval EQ 1>
					<A href="SC_Payment_Request.cfm?Billback_ID=#Billback_ID#&TransactionType=Hold&Form_Submitted=1&StartRow=#Startrow#">hold</A><br><b><font size="1">RELEASE</font></b>
					<cfelse>
					<b><font size="1">RELEASE</font></b>
					</CFIF>
					
				<CFSET count = count + 1>
					
				<CFELSEIF Signed EQ 1 AND Check_issued EQ 1>
				RELEASED
				</CFIF>
			</CFIF>
			</TD>
			<TD WIDTH="#Evaluate(PR_Prepared_By -20)#">
			#DateFormat(BB_Start_Date, "mm/dd/yyyy")#&nbsp;
			<BR>
			#DateFormat(BB_End_Date, "mm/dd/yyyy")#&nbsp;
			</TD>
			<TD WIDTH="#Evaluate(PR_Amount_Width + 20)#">
			#DOLLARFORMAT(BB_Amount)#
			<BR>
			#DOLLARFORMAT(Tot_Amount)#
			</TD>	
			<!--- Segment/Analyst --->
			<td width="#PR_Approved_By#">&nbsp;</td>
			<!--- paid bb checkbox cell --->
			<td width="15">&nbsp; </td>
	
		</TR>
		</CFOUTPUT>

	</TABLE>
	<cfoutput>
	<input type="hidden" name="Pay_Multi_Billbacks_IDs" value="#Pay_Multi_Billbacks_IDs#">
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
	<INPUT TYPE="Hidden" NAME="SORTBY" VALUE="#SORTBY#">
	<INPUT TYPE="Hidden" NAME="SORTORDER" VALUE="#SORTORDER#">
	<INPUT TYPE="hidden" NAME="Final_Signed_Paid" VALUE="#Form.Final_Signed_Paid#">
	<INPUT TYPE="hidden" NAME="AlreadySelected_Signed_Paid" VALUE="#Form.AlreadySelected_Signed_Paid#">
	</FORM>
	</CFOUTPUT>
		<TABLE WIDTH="98%" CELLSPACING="0" CELLPADDING="0">
		<TR>
			<TD>
			<CF_Next_Previous_For_Forms
			formname="MyForm"
			query="Get_data"
			maxpages="30"
			previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
			lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"		
			addparams="">
			</TD>
			<CFSET SECTION_RECORDCOUNT = Get_data.RecordCount>
			<TD ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <CFIF SECTION_RECORDCOUNT EQ 1>Is<CFELSE>Are</CFIF><CFOUTPUT>&nbsp;#SECTION_RECORDCOUNT#</CFOUTPUT> <CFIF SECTION_RECORDCOUNT EQ 1>Billback<CFELSE>Billbacks</CFIF> In This Status</B></FONT>
			</TD>
		</TR>
		</TABLE>	
	
<CFELSE>

</CFIF>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT language="JavaScript">

var Final_Signed_Paid = <cfoutput>"#form.Final_Signed_Paid#"</cfoutput>

<cfif #len(trim(form.Final_Signed_Paid))# GT 0>
	Change_To_Pay_1.style.display="";
	Change_To_Pay_2.style.display="none";
</cfif>

function activateSubmit()
{
	if(Any_Object_Checked(document.all.ApproveBB))
	{
		Change_To_Pay_1.style.display="";
		Change_To_Pay_2.style.display="none";
	}
	else
	{
		Change_To_Pay_1.style.display="none";
		Change_To_Pay_2.style.display="";
	}
}
function Confirm_Payment()
{
	document.all.Form_Submitted.value = 1
	document.MyForm.submit()
}

function addRemoveBillback(thisObj)
			{	var thisAmount = 0
				
				if(thisObj.checked)
					{
							addToSelectedList(thisObj);
					}
					else
					{
							removefromSelectedList(thisObj);
					}	
				
			}
			
			function addToSelectedList(selectedBB)
				{
					//add to list
					if(Final_Signed_Paid.length == 0)
						{Final_Signed_Paid = selectedBB.value;}
					else 
						{Final_Signed_Paid = Final_Signed_Paid + ',' + selectedBB.value;}
						
					if(MyForm.Final_Signed_Paid.value != undefined)
						MyForm.Final_Signed_Paid.value = Final_Signed_Paid;
						
				}
			
				function removefromSelectedList(selectedBB)
				{					
					//remove from list
					var tempArray = Final_Signed_Paid.split(",");
					var tempcurrentBillbackList = "";
				
					for(var x=0; x<tempArray.length; x++) 
					{
						if(tempArray[x] != selectedBB.value) 
						{
							if(tempcurrentBillbackList.length == 0)
							{
								tempcurrentBillbackList = tempArray[x];
							}
							else
							{
								tempcurrentBillbackList = tempcurrentBillbackList + ',' + tempArray[x];
							}				
						}
					}
					
					Final_Signed_Paid = tempcurrentBillbackList;
					if(MyForm.Final_Signed_Paid.value != undefined)
						MyForm.Final_Signed_Paid.value = Final_Signed_Paid;
				}

				function openDetails(BBID){
					NewWindow('/billbacks/scorecard/billback_details.cfm?BBID='+BBID, 'billback_details', 800, 600, 'yes', 'yes');
				}
</SCRIPT>
</BODY>
</HTML>