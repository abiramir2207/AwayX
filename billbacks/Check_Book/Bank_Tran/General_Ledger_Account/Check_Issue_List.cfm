<HTML>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>


<!--- Including "Form" as a part of the variable name in "Form_Submitted" was creating a problem. I changed the name from "form_submit" 
			to "SubmittedFrm" for this purpose. --->
<CFPARAM NAME="SubmittedFrm" DEFAULT="0">

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

<!--- Milan; Label(9748):START- Add/Delete billbacks passed from page to page --->
<CFPARAM NAME="FORM.Signed_Paid" DEFAULT="">
<CFPARAM NAME="FORM.Final_Signed_Paid" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelected_Signed_Paid" DEFAULT="">

<CFSET listofitemstodelete = "">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset profile = CreateObject("component","components.user.Profile").init() />
<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
<!--- loop through the pages selected bilbacks and if it is not in the selected list that means it was removed to queue it for deletetion --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelected_Signed_Paid#" DELIMITERS=",">
	<CFIF listfind(FORM.Signed_Paid, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<!--- if a selected billback isnt already in the final list then add it --->
<CFLOOP INDEX="ListItem" LIST="#Form.Signed_Paid#" DELIMITERS=",">
	<CFIF listfind(FORM.Final_Signed_Paid, ListItem, ",") EQ 0> 
			<CFSET Form.Final_Signed_Paid = listappend(Final_Signed_Paid, ListItem, ",")>
	</CFIF>
</CFLOOP>

<!--- delete the queued billbacks --->
<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.Final_Signed_Paid,ListItem, ",") GT 0>
		<CFSET Form.Final_Signed_Paid = listdeleteat(FORM.Final_Signed_Paid, listfind(FORM.Final_Signed_Paid,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>
<!--- Milan; Label(9748):END- Add/Delete values of billbacks passed from page to page --->

<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=10>

<CFIF SubmittedFrm NEQ 1>
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	 <br><br><br>
	 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	 <br><br><br>
	</SPAN>
	
	<CFFLUSH>
	
	<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>

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
		<!--- Prepared On --->
		<CFCASE value="PREP">
			<CFSET sql_Sort_By="Prepared_Date">
		</CFCASE>
		<!--- Approved oN --->
		<!------<CFCASE value="PR_A">
			<CFSET sql_Sort_By="Approved_Date">
		</CFCASE>----->	
		<CFCASE value="BBREFN">
            			<cfset sql_Sort_By="Billback.referenceNum">
		</CFCASE>	
	</CFSWITCH>
	
	<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">
	
	<CFIF URL.SORTORDER EQ "DESC">
		<CFSET sql_Sort_By="#sql_Sort_By# DESC">
	<CFELSE>
		<CFSET sql_Sort_By="#sql_Sort_By# ASC">
	</CFIF>
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
		<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
			#PreserveSingleQuotes(AllowBillbackIDs)#
		 	SELECT 		DISTINCT
						Billback.Billback_ID,
						Billback.BB_Code,
						Billback.BB_Date,
						Billback.BB_Reference,
						Customer_Name,
						BB_Title,		
						Paid_Amount Tot_Amount,		
						Payment_Type,
						Signed,
						Check_Issued,
						Prepared_Date,
						Prepared_By_First_Name,
						Prepared_By_Last_Name,
						Pay_Multi_Billbacks_ID,
						Payment_Data_Export_1.Payment_Data_Export_1_ID,
						Signed_Date,
						Signed_By_First_Name,
						Signed_By_Last_Name,
						ReferenceNum
			
			FROM 		Billback 
			INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			LEFT JOIN	Payment_Data_Export_2 ON Payment_Data_Export_2.Billback_ID = Billback.Billback_ID AND
						Payment_Data_Export_2.Deleted = 0
			LEFT JOIN 	Payment_Data_Export_1 ON Payment_Data_Export_1.Payment_Data_Export_1_ID = Payment_Data_Export_2.Payment_Data_Export_1_ID AND
						Payment_Data_Export_1.Deleted = 0
			AND Payment_Data_Export_1.Paid = 0 AND Payment_Data_Export_1.Saved = 1
			WHERE 		Billback_Status_ID = 4 AND Billback.Deleted = 0 
						AND (Billback.BB_Creator_User_Position_ID IN (#preserveSingleQuotes(UserPositionList)#)
						<cfif listlen(BillbackIDs) GT 0>
						OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
						</cfif>
						)
			ORDER BY 	#sql_Sort_By#
		</CFQUERY>

	<CFINCLUDE TEMPLATE="/Billbacks/scorecard/billback_Table_Measures.cfm">
	
	
	<FORM NAME="Status_Change" ID="Status_Change" ACTION="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/Check_Issue_List.cfm" METHOD="POST" STYLE="DISPLAY:INLINE;">
	<TABLE BORDER="0" WIDTH="<CFOUTPUT>#table_Width#</CFOUTPUT>" CELLSPACING="0" CELLPADING="0" CLASS="Maintable">
	<!------
	<TR>
		<TD COLSPAN="100%"><HR COLOR="Orange"></TD>
	</TR>
	----->
	<!---
	<TR BGCOLOR="ffce84">	
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD> --->
		<!--- <TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD> --->
		<!---
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Invoice No.</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Payee Name</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>$ Amount</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Prepared By</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Approved By</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;"><B>Status</B></TD>
		<TD STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp;</TD>
	</TR>
	--->
	<CFSET Pay_Multi_Billbacks_IDs = "" />
	<CFSET FORM.AlreadySelected_Signed_Paid = "">
	<CFOUTPUT QUERY="Get_data" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfif NOT ListFindNoCase(Pay_Multi_Billbacks_IDs, Pay_Multi_Billbacks_ID, ",") AND Len(Pay_Multi_Billbacks_ID) GT 0>
			<cfset Pay_Multi_Billbacks_IDs = ListAppend(Pay_Multi_Billbacks_IDs, Pay_Multi_Billbacks_ID, ",") />
		</cfif>
		<TR BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<!---<TD NOWRAP WIDTH="13%"STYLE="Border-bottom: solid 4ECEDC 1px;">&nbsp; 
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
			</TD>--->
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
			<BR>
			#ReferenceNum#
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
			<CFIF Signed EQ 0>
			New
			<CFELSEIF Signed EQ 1>
			<CFSET count = count + 1>
				<CFIF Count EQ 1>
				<!--- Milan; Label(9748) - This used to be "1", but I changed it to "0". Now I set it to "1" from the javascript function (Confirm_Payment) below --->
				<INPUT TYPE="Hidden" NAME="SubmittedFrm" VALUE="0">
				</CFIF>
				<!--- <INPUT TYPE="Hidden" NAME="BBID" VALUE="#Billback_ID#">		 --->									
				<CFIF Payment_Type EQ 2>
				<INPUT TYPE="CheckBox" NAME="Signed_Paid_#Pay_Multi_Billbacks_ID#" VALUE="2" ONCLICK="javaScript: check_Any_2_Paid(this,#Pay_Multi_Billbacks_ID#);">Paid
					<!--- <SELECT name="Signed_Paid_#Pay_Multi_Billbacks_ID#" onChange="javaScript: check_Any_2_Paid(this,#Pay_Multi_Billbacks_ID#);">
						<OPTION VALUE="1" SELECTED>Open</OPTION>
						<OPTION VALUE="2">Paid</OPTION>
					</SELECT> --->
				<CFELSE>
				<INPUT TYPE="Hidden" NAME="BBID" VALUE="#Billback_ID#">		
				<cfif Get_Profile_Settings.Mass_Billback_Pay EQ 1 AND appSettings.Mass_Pay_Billback IS NOT 0>
					<INPUT TYPE="CheckBox" NAME="Signed_Paid" VALUE="#Billback_ID#" ONCLICK="Javascript: activateSubmit()">Paid				
				<cfelse>
					Signed
				</cfif>
					<!--- <SELECT name="Signed_Paid" onChange="javaScript: check_Any_2_Paid(this);">
						<OPTION VALUE="1" SELECTED>Open</OPTION>
						<OPTION VALUE="2">Paid</OPTION>
					</SELECT>	 --->			
				</CFIF>				
			<CFELSEIF Signed EQ 1 AND Check_issued EQ 1>
			Paid
			</CFIF>
			</TD>
			<TD WIDTH="#Evaluate(PR_Prepared_By -20)#">
			#DateFormat(Prepared_Date, "mm/dd/yyyy")#&nbsp;
			<BR>
			#Prepared_By_First_Name# #Prepared_By_Last_Name#
			</TD>
			<TD WIDTH="#PR_Approved_By#">
			<CFIF Signed EQ 1>
			#DateFormat(Signed_Date,"mm/dd/yyyy")#
			<BR>
			#Signed_By_First_Name# #Signed_By_Last_Name#
			<CFELSE>&nbsp;</CFIF>
			<BR>
			#DOLLARFORMAT(Tot_Amount)#
			</TD>	
			<!--- Segment/Analyst --->
			<td width="#PR_Approved_By#">&nbsp;</td>
			<!--- paid bb checkbox cell --->
			<td width="15">&nbsp; </td>	
			<!---
			<TD STYLE="Border-bottom: solid 4ECEDC 1px;">			
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve_Content.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&Send_Mail=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" TITLE="">email</A></FONT>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>&nbsp;
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve_Content.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&Send_Fax=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" TITLE="">fax</A></FONT>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>&nbsp;				
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<FONT SIZE="2" COLOR="Blue"><A Href="View_Edit_Approve_Content.cfm?BBID=#Billback_ID#&Payment_Trans_ID=#Payment_trans_ID#&Print=1" onclick="NewWindow(this.href,'v_e_a','800','600','Yes', 'No');return false;" TITLE="">print</A></FONT>
				<FONT SIZE="2" COLOR="Red">]</FONT>
				</B>
			</TD>
			--->
		</TR>
		</CFOUTPUT>
		<CFIF Count NEQ 0>
		<TR>
			<TD COLSPAN="100%" ALIGN="Center" STYLE="BORDER:NONE;">
			<SPAN ID="Change_To_Pay_1" STYLE="DISPLAY:NONE">
			<B><FONT SIZE="2" COLOR="FF0000">[</FONT><a HREF="void(0);" onClick="Confirm_Payment();return false;"><FONT SIZE="2">submit</FONT></a><FONT SIZE="2" COLOR="FF0000">]</FONT></B>
			</SPAN>
			<SPAN ID="Change_To_Pay_2">
			<B><FONT SIZE="2" COLOR="CCCCCC">[</FONT><FONT SIZE="2" COLOR="999999">submit</FONT><FONT SIZE="2" COLOR="CCCCCC">]</FONT></B>
			</SPAN>
			</TD>
		</TR>
		</CFIF>
	</TABLE>
	<cfoutput>
	<INPUT TYPE="hidden" NAME="Pay_Multi_Billbacks_IDs" VALUE="#Pay_Multi_Billbacks_IDs#">
	<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
	<INPUT TYPE="Hidden" NAME="SORTBY" VALUE="#SORTBY#">
	<INPUT TYPE="Hidden" NAME="SORTORDER" VALUE="#SORTORDER#">
	<INPUT TYPE="Hidden" NAME="Final_Signed_Paid" VALUE="#Form.Final_Signed_Paid#">
	<INPUT TYPE="Hidden" NAME="AlreadySelected_Signed_Paid" VALUE="#Form.AlreadySelected_Signed_Paid#">
	</cfoutput>
	</FORM>
		<TABLE WIDTH="98%" CELLSPACING="0" CELLPADDING="0">
		<TR>
			<TD>
			<CF_Next_Previous_For_Forms
			formname="Status_Change"
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
		<BR><BR>
		<TABLE BORDER="0" WIDTH="30%" CELLSPACING="0" CELLPADING="0">
			<TR>
				<TD><B><FONT SIZE="2" COLOR="FF0000">[</FONT><a HREF="Approve_All.cfm"><FONT SIZE="2">approve all</FONT></a><FONT SIZE="2" COLOR="FF0000">]</FONT></B></TD>
				<TD><B><FONT SIZE="2" COLOR="FF0000">[</FONT><a HREF="Payment_Email_All_Create.cfm?Email_All=1" onclick="NewWindow(this.href,'e_a','800','600','Yes', 'No');return false;" TITLE=""><FONT SIZE="2">email all</FONT></a><FONT SIZE="2" COLOR="FF0000">]</FONT></B></TD>
				<TD><B><FONT SIZE="2" COLOR="FF0000">[</FONT><a HREF="Payment_Fax_All_Create.cfm?Fax_All=1" onClick="NewWindow(this.href,'f_a','800','600','Yes', 'No');return false;" TITLE=""><FONT SIZE="2">fax all</FONT></a><FONT SIZE="2" COLOR="FF0000">]</FONT></B></TD>
				<TD><B><FONT SIZE="2" COLOR="FF0000">[</FONT><a HREF="javascript: alert_landscape();" <!--- Payment_Print_All_Create.cfm?Print_All=1 onClick="NewWindow(this.href,'p_a','800','600','Yes', 'No');return false;" TITLE="""--->><FONT SIZE="2">print all</FONT></a><FONT SIZE="2" COLOR="FF0000">]</FONT></B></TD>
			</TR>
		</TABLE>
<CFELSE>

	<CFSET Count = 0>
	<CFIF ISDefined("FORM.Final_Signed_Paid")>
		<CFLOOP INDEX = "Item" LIST = "#FORM.Final_Signed_Paid#" DELIMITERS = ",">
		<cfset Update_BBID =  Item>
			<!--- <CFSET Count = Count + 1>	--->
			<CFSET Unsuccess_Count = 0> 
			<CFIF Item NEQ "">
			<CFSET Update_BBID = Item>
				<CFOUTPUT>
				<CFQUERY NAME="Check_Lock" DATASOURCE="#Application.Datasource#">
					SELECT 		BB_Is_Locked,BB_Code 
					
					FROM 		Billback_Allied
					INNER JOIN	Billback ON Billback.Billback_ID = Billback_Allied.Billback_ID
								AND Billback.Deleted=0
								
					WHERE Billback_Allied.Billback_ID	=	'#Update_BBID#'
				</CFQUERY>
				<CFIF Check_Lock.BB_Is_Locked EQ 0>
					<cfset useLakebaseForLock_BB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForLock_BB>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#Update_BBID#"
			},
			{
				"bb_is_locked" = "1",
				"bb_locked_by_user_id" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLock_BB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLock_BB>
<CFQUERY NAME="Lock_BB" DATASOURCE="#Application.Datasource#">
						UPDATE 		Billback_Allied
						SET 		BB_Is_Locked = 1,
									BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
									
						WHERE 		Billback_ID = '#Update_BBID#' 
					</CFQUERY>
</cfif>
					
					
					<cfset useLakebaseForUpdate_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForUpdate_Status>
	<cftry>
		<cfset application.oLakebase.updateRows("payment_data_export_1",
			{
				"billback_id" = "eq.#Update_BBID#",
				"deleted" = "eq.0",
				"saved" = "eq.1"
			},
			{
				"paid" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Status>
<CFQUERY NAME="Update_Status" DATASOURCE="#Application.Datasource#">
						UPDATE Payment_Data_Export_1
						
						SET		Paid	=	1
						
						WHERE Billback_ID = '#Update_BBID#' AND Deleted=0 AND Saved=1
					</CFQUERY>
</cfif>
					<cfset useLakebaseForStatus_Paid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForStatus_Paid>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Update_BBID#",
				"billback_status_id" = "eq.4",
				"deleted" = "eq.0"
			},
			{
				"billback_status_id" = "5"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForStatus_Paid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForStatus_Paid>
<CFQUERY NAME="Status_Paid" DATASOURCE="#Application.Datasource#">			
						UPDATE	Billback
						
						SET		Billback_Status_ID = 5
						
						WHERE	Billback.Billback_ID = '#Update_BBID#'
								AND	Billback.Billback_Status_ID = 4 AND Deleted=0
					</CFQUERY>
</cfif>
					
					<CFQUERY NAME="Un_Lock_BB" DATASOURCE="#Application.Datasource#">
						UPDATE 		Billback_Allied
						
						SET 		BB_Is_Locked = 0,
									BB_Locked_By_User_ID = NULL
									
						WHERE 		Billback_ID = '#Update_BBID#' 
									AND BB_Locked_By_User_ID = '#request.AccessStructure.user_id#'
									AND BB_Locked_By_Match_Central = 0
									
					</CFQUERY>								
				<CFELSE>
					<CFSET Unsuccess_Count = Unsuccess_Count + 1>
					<CFIF Unsuccess_Count EQ 1>
						<CFSET Locked_BB = "[#Check_Lock.BB_Code#]"> 
					<CFELSE>
						<CFSET Locked_BB = "#Locked_BB#, [#Check_Lock.BB_Code#]"> 
					</CFIF>
				</CFIF>
				</CFOUTPUT>
			</CFIF>
		</CFLOOP>	
	</CFIF>
	
	<CFIF IsDefined("FORM.Pay_Multi_Billbacks_IDs")>
		<CFLOOP LIST="#FORM.Pay_Multi_Billbacks_IDs#" INDEX="IDList">
			<CFIF IsDefined("FORM.Signed_Paid_#IDList#")>			
				<CFSET GetVarValue = LISTFIRST(#EVALUATE("FORM.Signed_Paid_#IDList#")#,",")>
					
				<CFIF GetVarValue EQ 2>
					
					<CFQUERY NAME="GetAllBB" DATASOURCE="#Application.Datasource#">
						SELECT 		Pay_Multi_Billbacks_List.Billback_ID,
									BB_Is_Locked,
									BB_Locked_By_User_ID,
									BB_Code
									
						FROM 		Pay_Multi_Billbacks_List
						
						INNER JOIN 	Billback_Allied ON Billback_Allied.Billback_Id = Pay_Multi_Billbacks_List.Billback_ID				
						INNER JOIN 	Billback ON Billback.Billback_ID = Pay_Multi_Billbacks_List.Billback_ID	
						
						WHERE 		Pay_Multi_Billbacks_ID = '#IDList#' AND 
									Pay_Multi_Billbacks_List.Deleted = 0
					</CFQUERY>	
					
					<CFSET UnSuccessList = VALUELIST(GetAllBB.BB_Code)>			
					<CFSET PayMultiBBIdList = VALUELIST(GetAllBB.Billback_ID)>
					
					<CFIF GetAllBB.BB_Is_Locked EQ 0 OR (GetAllBB.BB_Is_Locked EQ 1 AND GetAllBB.BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
						<CFQUERY NAME="Lock_BB" DATASOURCE="#Application.Datasource#">
							UPDATE 		Billback_Allied
							
							SET 		BB_Is_Locked = 1,
										BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
										
							WHERE 		Billback_ID IN (#LISTQUALIFY(PayMultiBBIdList,"'",",","All")#)
						</CFQUERY>
						
						<cfset useLakebaseForChangeStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_data_export_1")>
<cfif useLakebaseForChangeStatus>
	<cftry>
		<cfset application.oLakebase.updateRows("payment_data_export_1",
			{
				"pay_multi_billbacks_id" = "eq.#IDList#"
			},
			{
				"paid" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForChangeStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForChangeStatus>
<CFQUERY NAME="ChangeStatus" DATASOURCE="#Application.Datasource#">
							UPDATE 	Payment_Data_Export_1
							
							SET 	Paid	=	1
							
							WHERE 	Pay_Multi_Billbacks_ID = '#IDList#'
						</CFQUERY>
</cfif>
						
						<CFQUERY NAME="Status_Paid" DATASOURCE="#Application.Datasource#">			
							UPDATE	Billback
							
							SET		Billback_Status_ID = 5
							
							WHERE	Billback.Billback_ID IN (#LISTQUALIFY(PayMultiBBIdList,"'",",","All")#) AND
									Billback.Billback_Status_ID = 4 AND 
									Deleted=0
						</CFQUERY>
						
						<CFQUERY NAME="UNLock_BB" DATASOURCE="#Application.Datasource#">
							UPDATE 		Billback_Allied
							
							SET 		BB_Is_Locked = 0,
										BB_Locked_By_User_ID = NULL
										
							WHERE 		Billback_ID IN (#LISTQUALIFY(PayMultiBBIdList,"'",",","All")#)
							AND BB_Locked_By_Match_Central = 0 
						</CFQUERY>
					<CFELSE>
						<CFLOOP LIST="#UnSuccessList#" INDEX="Deli">						
							<CFSET Unsuccess_Count = Unsuccess_Count + 1>
							<CFIF Unsuccess_Count EQ 1>
								<CFSET Locked_BB = "[#Deli#]"> 
							<CFELSE>
								<CFSET Locked_BB = "#Locked_BB#, [#Deli#]"> 
							</CFIF>
						</CFLOOP>
					</CFIF>
								
				</CFIF>
			</CFIF>	
		</CFLOOP>
	</CFIF>
	<CFIF isdefined("Locked_BB")>
		<SCRIPT language="JavaScript">
			var unsuccessful = "<CFOUTPUT>#Locked_BB#</CFOUTPUT>";
			alert("Billback(s) " + unsuccessful + " is/are currently locked. Please try again later.");
			window.setTimeout('goBackToThisPage()', 0);				
			
			function goBackToThisPage()
			{	
				window.location.href = "Check_Issue_List.cfm?<CFOUTPUT>StartRow=#StartRow#&frompage=#frompage#&SORTBY=#SORTBY#&SORTORDER=#SORTORDER#</CFOUTPUT>";	
			}
		</SCRIPT>
	<CFELSE>

		<CFLOCATION URL="Check_Issue_List.cfm" ADDTOKEN="No">
		<!--- <SCRIPT language="JavaScript">
			window.setTimeout('goBackToThisPage()', 0);	
		</SCRIPT> --->
	</CFIF> 
</CFIF>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<SCRIPT language="JavaScript">
function check_Any_2_Paid(thisObj,ID)
{
	var paidIdValue = 2;
	if(ID)
	{
		var selObjColl =  eval("document.all.Signed_Paid_" + ID);
		var selLen = selObjColl.length;
		if(selLen)
		{
			for(i=0;i<selLen;i++)
			{
				selObjColl[i].selectedIndex = thisObj.selectedIndex;
			}
		}
		else
		{
			selObjColl.selectedIndex = thisObj.selectedIndex;
		}			
	}
	var bShow = false;
	if(thisObj.value == 2)
	{
		bShow = true;
	}
	else
	{
		 bShow = false;
		 bShow = bShow || Any_Object_Property_Match(document.all.Signed_Paid, "value", paidIdValue);
		 var arPay_Multi_Billbacks_IDs = document.all.Pay_Multi_Billbacks_IDs.value.split(",");
		 var j;
		 for(j=0;j<arPay_Multi_Billbacks_IDs.length;j++)
		 {
		 	bShow = bShow || Any_Object_Property_Match(eval("document.all.Signed_Paid_" + arPay_Multi_Billbacks_IDs[j]), "value", paidIdValue);
			if(bShow)
			{
				break;
			}
		 }
	}
	if(bShow)
	{			
		changeDisplay(document.all.Change_To_Pay_1, "");
		changeDisplay(document.all.Change_To_Pay_2, "none");
	}
	else
	{
		changeDisplay(document.all.Change_To_Pay_1, "none");
		changeDisplay(document.all.Change_To_Pay_2, "");
	}		
}

function changeDisplay(obj, displayVal)
{
	if(obj)
	{
		if(obj.lemgth)
		{
		}
		else
		{
			obj.style.display = displayVal;
		}			
	}
}


function Confirm_Payment()
{
	var anySelected = false;
	<!--- Milan; Label(9748) - I set the value of "SubmittedFrm" to "1" from here now. Earlier the value of "1" 
				was being passed from the form --->
	document.all.SubmittedFrm.value =1;
	if(Any_Object_Checked(document.all.Signed_Paid))
	{
	anySelected = true;
	}
	//anySelected = anySelected || Any_Object_Property_Match(document.all.Signed_Paid, "value", "2");
	var arPay_Multi_Billbacks_IDs = document.all.Pay_Multi_Billbacks_IDs.value.split(",");
	 var j;
	 for(j=0;j<arPay_Multi_Billbacks_IDs.length;j++)
	 {
	 	anySelected = anySelected || Any_Object_Property_Match(eval("document.all.Signed_Paid_" + arPay_Multi_Billbacks_IDs[j]), "value", "2");
		if(anySelected)
		{
			break;
		}
	 }
	if(anySelected)
	{
		var com_paid =confirm("Press OK to change the staus as PAID.");
		if (com_paid == true)
		{
			document.Status_Change.submit();
		} 
	}
}
function activateSubmit()
{
	if(Any_Object_Checked(document.all.Signed_Paid))
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
function alert_landscape()
{
	alert("Please select LANDSCAPE LAYOUT to get clear Payment Request printout");
	NewWindow("Payment_Print_All_Create.cfm?Print_All=1", 'P_A', '800', '600', 'Yes', 'No', true);

}

</SCRIPT>
</BODY>
</HTML>