<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="margin:0; border: 0px; background-color:transparent" allowTransparency="true">

<!--- <CFDUMP VAR="#FORM#"> --->
<!---User profile--->
<!--- <CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
</cfquery> --->
<!--- <CFDUMP VAR="#FORM#"> --->

<!---
/////////////////////////////////////////////////////////////
// save search criteria into a temporary object file on disk
/////////////////////////////////////////////////////////////
--->
<cfscript>
	variables.savedFormFileName = application.util.io.TempFileName( prefix='object_save' );
	variables.searchCriteria = structNew();
	structAppend(variables.searchCriteria, form, true);

	objectSave(variables.searchCriteria, variables.savedFormFileName);
</cfscript>


<CFSET FORM.apply_pagination = 1 />

<STYLE>
TABLE.BorderTable TD
{
	border-bottom:solid #93BEE2 1px;
}
#act859a, #act859b { float: right; margin: 5px; }
#act859a a { margin:0 8px; }
</STYLE>


<CFINCLUDE TEMPLATE="Ded_Search_Query.cfm">

<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<CFIF FORM.Form_Submitted NEQ "">
	<CFIF Isdefined("FORM.FromSmallSearch")>
		<!--- <BR>
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="950">
			<TR>
				<TD ALIGN="Right"><B><FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="/deductions/search_screens/Ded_Advanced_Search.cfm"><FONT SIZE="2">search deductions</FONT></A><FONT SIZE="2" COLOR="Red"> ]</FONT></B></TD>
			</TR>
		</TABLE>
		<BR> --->
		<cfoutput>
		<div id="act859a">
			<a href="/deductions/search_screens/ded_advanced_search.cfm">#application.util.string.actionlinkformat2('search deductions')#</a>
			<a href="##" id="dnload012">#application.util.string.actionlinkformat2('download data')#</a>
		</div></cfoutput>
	<cfelse>
		<cfoutput>
		<div id="act859b">
			<a href="##" id="dnload012">#application.util.string.actionlinkformat2('download data')#</a>
		</div></cfoutput>
	</CFIF>

	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="100%" CLASS="MainTable" ALIGN="Center"><!--- BorderTable --->



	<FORM NAME="JustForPaging" ACTION="Ded_Advanced_Search_Result.cfm" METHOD="Post">
   <CFOUTPUT>
   	<INPUT TYPE="Hidden" NAME="pageLength" VALUE="#FORM.pageLength#">
   	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
	<INPUT TYPE="Hidden" NAME="Broker_List" VALUE="#FORM.Broker_List#">
	<INPUT TYPE="Hidden" NAME="DD_Number" VALUE="#FORM.DD_Number#">
	<INPUT TYPE="Hidden" NAME="Dollar_Operator" VALUE="#FORM.Dollar_Operator#">
	<INPUT TYPE="Hidden" NAME="DD_Amount" VALUE="#FORM.DD_Amount#">
	<CFIF Isdefined("FORM.DD_To_Amount")>
	<INPUT TYPE="Hidden" NAME="DD_To_Amount" VALUE="#FORM.DD_To_Amount#">
	</CFIF>
	<INPUT TYPE="Hidden" NAME="Date_Operator" VALUE="#FORM.Date_Operator#">
	<INPUT TYPE="Hidden" NAME="Date_Time" VALUE="#FORM.Date_Time#">
	<CFIF Isdefined("FORM.To_Date_Time")>
	<INPUT TYPE="Hidden" NAME="To_Date_Time" VALUE="#FORM.To_Date_Time#">
	</CFIF>
	<CFIF Isdefined("FORM.C1Cust_RefNo")>
		<INPUT TYPE="Hidden" NAME="C1Cust_RefNo" VALUE="#FORM.C1Cust_RefNo#">
	</CFIF>
	<CFIF Isdefined("FORM.C1AR_Reference")>
		<INPUT TYPE="Hidden" NAME="C1AR_Reference" VALUE="#FORM.C1AR_Reference#">
	</CFIF>

	<INPUT TYPE="Hidden" NAME="InvoiceNo" VALUE="#FORM.InvoiceNo#">
	<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
		<INPUT TYPE="Hidden" NAME="OrderNo" VALUE="#FORM.OrderNo#">
	</cfif>
	<INPUT TYPE="Hidden" NAME="Check_No" VALUE="#FORM.Check_No#">
	<INPUT TYPE="Hidden" NAME="Service_Market_ID" VALUE="#FORM.Service_Market_ID#">
	<INPUT TYPE="Hidden" NAME="Distributor" VALUE="#FORM.Distributor#">
	<INPUT TYPE="Hidden" NAME="Family_ID" VALUE="#FORM.Family_ID#">
	<INPUT TYPE="Hidden" NAME="Analyst_User_ID" VALUE="#FORM.Analyst_User_ID#">
	<INPUT TYPE="Hidden" NAME="Service_Region_ID" VALUE="#FORM.Service_Region_ID#">
	<INPUT TYPE="Hidden" NAME="Broker" VALUE="#FORM.Broker#">
	<INPUT TYPE="Hidden" NAME="DD_Stage_ID" VALUE="#FORM.DD_Stage_ID#">
	<INPUT TYPE="Hidden" NAME="DD_Aging" VALUE="#FORM.DD_Aging#">
	<INPUT TYPE="Hidden" NAME="Service_Zone_ID" VALUE="#FORM.Service_Zone_ID#">
	<INPUT TYPE="Hidden" NAME="DD_Reason_Code_ID" VALUE="#FORM.DD_Reason_Code_ID#">
	<INPUT TYPE="Hidden" NAME="DD_Status" VALUE="#FORM.DD_Status#">
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="#FORM.Form_Submitted#">
	<INPUT TYPE="Hidden" NAME="Distributor_Bill_To_ID" VALUE="#FORM.Distributor_Bill_To_ID#">
	<INPUT TYPE="Hidden" NAME="Distributor_Bill_To" VALUE="#FORM.Distributor_Bill_To#">
	<INPUT TYPE="Hidden" NAME="Line_Of_Business_ID" VALUE="#FORM.Line_Of_Business_ID#">
	<INPUT TYPE="Hidden" NAME="Q_Brand_ID" VALUE="#FORM.Q_Brand_ID#">
	<INPUT TYPE="Hidden" NAME="DD_Operator_ID" VALUE="#FORM.DD_Operator_ID#">
	<INPUT TYPE="Hidden" NAME="IsBusEnabled" VALUE="#FORM.IsBusEnabled#">
	<INPUT TYPE="Hidden" NAME="AccessAllDeductions" VALUE="#FORM.AccessAllDeductions#">
	<INPUT TYPE="Hidden" NAME="IsParentDeduction" VALUE="#FORM.IsParentDeduction#">
	<INPUT TYPE="Hidden" NAME="Filter_Closed" VALUE="#FORM.Filter_Closed#">
	<INPUT TYPE="Hidden" NAME="Rebill_Number" VALUE="#FORM.Rebill_Number#">
	<INPUT TYPE="Hidden" NAME="Classification" VALUE="#FORM.Classification#">    <!---26472--->
	<INPUT TYPE="Hidden" NAME="DeductionType" VALUE="#FORM.DeductionType#">      <!---26487--->

	<CFIF Isdefined("FORM.ClDate_Time")>
		<INPUT TYPE="Hidden" NAME="ClDate_Time" VALUE="#FORM.ClDate_Time#">
		<INPUT TYPE="Hidden" NAME="ClDate_Operator" VALUE="#FORM.ClDate_Operator#">
		<CFIF FORM.ClDate_Operator EQ "Between">
			<INPUT TYPE="Hidden" NAME="ClTo_Date_Time" VALUE="#FORM.ClTo_Date_Time#">
		</CFIF>
	</CFIF>

	<INPUT TYPE="Hidden" NAME="Only_DD_With_Inactive_Relations" VALUE="#FORM.Only_DD_With_Inactive_Relations#">
	<CFIF Isdefined("FORM.FromSmallSearch")>
	<INPUT TYPE="Hidden" NAME="FromSmallSearch" VALUE="#FORM.FromSmallSearch#">
	</CFIF>
	</CFOUTPUT>

	<TR BGCOLOR="FFE083">
		<TD WIDTH="15">&nbsp;</TD>
		<CFSET A_Header_Name_List = "DEDUCTION ##,STATUS, UPDATED BY,$ AMOUNT,#ucase(application.returned_customer_setting.distributor_label_singular)#,REASON CODE,CLASSIFICATION,DATE,CHECK ##,#UCase(stDeductionLabels["Reference"])# ##,&nbsp;AGE,&nbsp;#UCase(stDeductionLabels['Action'])#,BROKER,REGION,&nbsp;ANALYST"><!--- D26987 Deduction Search Results --->
		<CFSET A_Header_Value_List = "DD_DedID_SP_Number,DD_Status,DD_UPDATE,DD_Amount,Name,DD_Reason_Code,CLASSIFICATION,DD_Date,DD_Check_Number,DD_Reference,NumberOfDays,DD_Stage_Description,Broker_Name,Region_Name,_Users.Name_First"><!--- D26987 Deduction Search Results --->
		<!--- <CFSET Header_Width_List = "90,140,83,110,150,190,86,88"> --->
		<CFSET Counter = 1>
		<CFOUTPUT>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>

			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>

			<CFIF ThisHeaderItem EQ "Name" OR ThisHeaderItem EQ "DD_Stage_Description" OR ThisHeaderItem EQ "Region_Name" OR ThisHeaderItem EQ "DD_Check_Number"  OR ThisHeaderItem EQ "CLASSIFICATION" OR ThisHeaderItem EQ "DD_UPDATE" OR ThisHeaderItem EQ "DD_Reference" ><!--- D26987 Deduction Search Results --->
				<BR>
			<CFELSE>
				<TD ID="header" STYLE="font-size : 8pt" nowrap>
			</CFIF>

			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>

			<CFIF ThisHeaderItem NEQ "DD_Amount" AND ThisHeaderItem NEQ "DD_Date" AND ThisHeaderItem NEQ "DD_Check_Number" AND ThisHeaderItem NEQ "Broker_Name" AND ThisHeaderItem NEQ "NumberOfDays" AND ThisHeaderItem NEQ "DD_Reason_Code" AND ThisHeaderItem NEQ "DD_Status" ><!--- D26987 Deduction Search Results --->
			</TD>
			</CFIF>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>

 		<!--- <TR BGCOLOR="FFE083">
			<TD><A HREF="" ONCLICK="Javascript: sortParam()"><B>DEDUCTION #</B></A></TD>
			<TD><B>PARENT / CHILD</B></TD>
			<TD><B>AMOUNT</B></TD>
			<TD><B>STATUS</B></TD>
			<TD><B>AGE</B></TD>
			<TD><B>ACTION</B></TD>
			<TD><B>ANALYST</B></TD>
			<TD><B>CREATED ON</B></TD>
			<TD><B>MODIFIED ON</B></TD>
		</TR>	 --->

		<CFSET ReopenMessageDisplay = 0 />
		<CFSET ReopenNotAckRowColor = "FFDDDD" />
		<CFOUTPUT QUERY="Get_Data">
		<CFSET sBGColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6')) />
		<cfif (ReOpened EQ 1 AND Ack_received_Reopen EQ 0) AND appSettings.getDD_Reopen_Interface() EQ 0>
			<cfset sBGColor = ReopenNotAckRowColor />
			<CFSET ReopenMessageDisplay = 1 />
		</cfif>
		<TR BGCOLOR="#sBGColor#">
			<TD WIDTH="20" nowrap>
				<CFIF attachment_count GT 0>
					<IMG SRC="/images/doc.gif" width="13" height="16" TITLE="This program has #attachment_count# attached document(s)" height="16" width="13">
				<CFELSE>
					<IMG SRC="/images/fill.gif" width="13" height="16">
				</CFIF>
				<CFIF Is_Locked EQ 1>
					<cfset useLakebaseForGetLockedBy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
					<cfif useLakebaseForGetLockedBy>
						<cftry>
							<cfset GetLockedBy = application.oLakebase.toQuery(
								application.oLakebase.selectRows("_users", {
									"select" = "name_first,name_last",
									"user_id" = "eq.#Locked_By#",
									"deleted" = "eq.0"
								}),
								"name_first,name_last"
							)>
							<cfcatch type="any">
								<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
								<cfset useLakebaseForGetLockedBy = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForGetLockedBy>
					<CFQUERY NAME="GetLockedBy" DATASOURCE="#Application.Datasource#">
						SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#Locked_By#' AND Deleted=0
					</CFQUERY>
					</cfif>
					<IMG SRC="/images/lock.gif" TITLE="This deduction is locked by user #ucase(GetLockedBy.Name_First)# #ucase(GetLockedBy.Name_Last)#" height="16" width="12">
				<CFELSE>
				&nbsp;
				</CFIF>
			</TD>
			<TD WIDTH="140">
				<B>
					<FONT COLOR="red" SIZE="2">[ </FONT><A HREF="/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#" target="_parent">#DD_DedID_SP_Number#</A><FONT COLOR="red" SIZE="2"> ]</FONT>
				</B><br>
			<!---Tim Ford 05/04/2010 - Label D20774: Adding update and preview links to Deduction Search screens--->
			<A onClick="javaScript: NewWindow(this.href , 'Preview' , 850 , 600 , 'yes' , 'yes'); return false;" target="_blank" HREF="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#&Display=Preview" STYLE="FONT-SIZE:10PX;" TITLE="View the details for deduction #DD_DedID#">
				<font style="font-weight:bold; color:660033">Preview</font>
			</A>
			<cfif
			(	( ( (DD_Status LTE 3 OR DD_Status EQ 8) AND appSettings.get_Setting('deduction_Quick_Update_For_New_Open_RFA') eq '1') )
			OR ( DD_Status EQ 4 AND appSettings.getDeductionQuickUpdate() ) )
			AND (Is_Locked EQ 0 OR Locked_By EQ '#request.AccessStructure.user_ID#')>
				<font color="660033"> / </font>
				<A onClick="javaScript: NewWindow(this.href , 'Update' , 850 , 600 , 'yes' , 'yes'); return false;" target="_blank" HREF="/deductions/update_status.cfm?Deduction_ID=#Deduction_ID#" STYLE="FONT-SIZE:10PX;" TITLE="Quick update for deduction #DD_DedID#">
					<font style="font-weight:bold; color:660033">
						Update
					</font>
				</A>
			</cfif>
			<cfif appSettings.get_Setting('Quick_Pay_in_Program_Search') eq '2' AND Get_Profile_Settings.AQP_Available EQ 1 AND (DD_ISParent EQ 0 OR Split_Count EQ 0) AND DD_Status LT 3	AND (Is_Locked EQ 0 OR Locked_By EQ '#request.AccessStructure.user_ID#') AND NOT (ReOpened EQ 1 AND Ack_received_Reopen EQ 0 AND appSettings.getDD_Reopen_Interface() EQ 0)>
				<font color="660033"> / </font>
				<a onClick="javaScript:QuickPay('#Deduction_ID#')"><font style="font-weight:bold; color:660033">Quick Pay</font></a>
			</cfif>
				<table border="0" cellpadding="0" cellspacing="0" width="100%" STYLE="Border-botton: none">
					<TR>
						<TD HEIGHT="10" STYLE="Border-bottom: none">
						<CFIF DD_IsParent EQ 1>
							<!--- <CFQUERY NAME="Check_Child" DATASOURCE="#Application.Datasource#">
								SELECT * FROM Deductions WHERE DD_DedID = '#DD_DedID#' AND Deleted=0
							</CFQUERY> --->
							<CFIF Split_Count GT 0>
								<img src="/Images/parent_New.gif" alt="" width="13" height="13" border="0">
							</CFIF>
						<CFELSE>
							<A HREF="/deductions/deduction.cfm?Deduction_ID=#DD_Parent_ID#"><img src="/Images/child_New.gif" alt="" width="13" height="13" border="0"></A>
						</CFIF>
						</TD>
						<!--- Ana D19384 Rebill Interface Arrows --->
						<TD Align="Right" STYLE="Border-bottom: none">
						<CFIF DD_Status EQ 8 OR DD_Status EQ 9>
							<CFSET DD_Type = "Credit">
						<CFELSEIF DD_Status EQ 7 OR Is_Last_Status_Rebill EQ 1>
							<CFSET DD_Type = "Rebill">
						<CFELSE>
							<CFSET DD_Type = "Deduction">
						</CFIF>
						<CFIF DD_Closure_Sent EQ 1 OR Ack_received_Closure EQ 1 OR Ack_received_Reopen EQ 1 OR DD_Reopened_Sent EQ 1>
							<cfset useLakebaseForDD_SentDate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
							<cfif useLakebaseForDD_SentDate>
								<cftry>
									<cfset DD_SentDate = application.oLakebase.toQuery(
										application.oLakebase.selectRows("dd_closure_detail", {
											"select" = "interfaced_on",
											"deduction_id" = "eq.#Deduction_ID#",
											"interfaced_on" = "not.is.null",
											"deleted" = "eq.0",
											"limit" = "1"
										}),
										"interfaced_on"
									)>
									<cfcatch type="any">
										<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
										<cfset useLakebaseForDD_SentDate = false>
									</cfcatch>
								</cftry>
							</cfif>
							<cfif NOT useLakebaseForDD_SentDate>
							<CFQUERY NAME="DD_SentDate" DATASOURCE="#Application.Datasource#">
							SELECT TOP 1 Interfaced_On FROM DD_Closure_Detail WHERE Deduction_ID = '#Deduction_ID#' AND Interfaced_On IS NOT NULL AND Deleted = 0
							</CFQUERY>
							</cfif>
						<CFELSEIF Rebill_Ack_Status EQ 3 OR Rebill_Ack_Status EQ 2>
							<CFSET DD_SentDate.Interfaced_On = Rebill_Sent_On>
						</CFIF>
						<CFIF Ack_received_Closure EQ 1 OR Ack_received_Reopen EQ 1 OR Rebill_Ack_Status EQ 3>
							<CFIF Ack_received_Closure EQ 1>
								<CFSET Ack_Date_Disp = Ack_Closure_Date>
							<CFELSEIF Ack_received_Reopen EQ 1>
								<CFSET Ack_Date_Disp = Ack_Reopen_Date>
							<CFELSE>
								<CFSET Ack_Date_Disp = Rebill_Ack_On>
							</CFIF>
							<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This #DD_Type# has been successfully loaded in ERP <CFIF Rebill_Number NEQ "">#chr(13)##chr(10)#Rebill Num: #Rebill_Number#</CFIF>#chr(13)##chr(10)#Send Date: <cfif Is_Write_off EQ 1>#DD_Ack_Sent_Date#<cfelse>#DD_SentDate.Interfaced_On#</cfif> #chr(13)##chr(10)#Acknowledge Date: #Ack_Date_Disp#">&nbsp;&nbsp;
						<CFELSEIF (DD_Closure_Sent EQ 1 AND Ack_received_Closure EQ 0) OR (DD_Reopened_Sent EQ 1 AND Ack_received_Reopen EQ 0) OR (Rebill_Ack_Status EQ 2)>
							<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This #DD_Type# is being sent to ERP <CFIF Rebill_Number NEQ "">#chr(13)##chr(10)#Rebill Num: #Rebill_Number#</CFIF>#chr(13)##chr(10)#Send Date: #DD_SentDate.Interfaced_On#">&nbsp;&nbsp;
						</CFIF>
						</TD>
					</TR>
				</table>
			</TD>

			<TD WIDTH="65" NOWRAP <CFIF DD_Status_ID EQ "3">TITLE="Request for Approval"</CFIF>>
				#DD_Status_Description#
				<br>
				#DD_UPDATE#
			</TD>
			<TD TITLE="Bill To Name: #Name##Chr(13)##application.returned_customer_setting.billto_label# Number: #Shr_Bill_To##Chr(13)##application.returned_customer_setting.shard_ship_to_label#: #Shr_ship_to#" WIDTH="150">#DollarFormat(DD_Amount)#<cfif len(trim(Cleared_Amount)) GT 0 AND Cleared_Amount NEQ 0 AND Cleared_Amount NEQ DD_Amount AND DD_Status GT 3 AND DD_Status NEQ 7>&nbsp; &nbsp; &nbsp;  Cleared: #DollarFormat(Cleared_Amount)#</cfif><BR>
				<CFSET DisplayThis = TRIM(Distributor_Name)>
				<CFSET NoOfCharInName = Len(DisplayThis)>
				<CFIF NoOfCharInName GT 20>
					<CFSET DisplayName = LEFT(DisplayThis,20)>
					#DisplayName#...
				<CFELSE>
					#DisplayThis#
				</CFIF>
			</TD>
						<!--- D26987 Deduction Search Results START --->
						<TD TITLE="Reason Code: #DD_Reason_Code# - #DD_Reason_Code_Description##chr(13)#Classification: #DD_Classification_Desc#">
									#DD_Reason_Code# - <cfif len(DD_Reason_Code_Description) GT 30>#left(DD_Reason_Code_Description, 30)#...<cfelse>#DD_Reason_Code_Description#</cfif>
									<br>
									<!--- #DD_Classification_ID# - ---> <cfif len(DD_Classification_Desc) GT 30>#left(DD_Classification_Desc, 30)#...<cfelse>#DD_Classification_Desc#</cfif>
						</TD>
						<!--- D26987 Deduction Search Results END --->
			<TD width="50">
			#DateFormat(DD_Date, "MM/DD/YYYY")#<br>
			#DD_Check_Number#<!--- D26987 Deduction Search Results ---><br>
			#DD_Reference#
			</TD>
			<TD WIDTH="90">
				<!--- <CFSET NumberOfDays = DateDiff("d",DateFormat(DD_Date,"mm/dd/yyyy"),DateFormat(now(),"mm/dd/yyyy"))>
				<CFIF NumberOfDays GTE LastAgeEndRange>
					#LastAgeLabel# (#NumberOfDays# days)
				<CFELSE>
				<CFQUERY NAME="Get_Aging_Details" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Aging WHERE Deleted=0 AND Start_Range <= '#NumberOfDays#' AND End_Range >= '#NumberOfDays#'
				</CFQUERY>	 --->
				#DD_Aging_Label# (#NumberOfDays# days)
				<!--- </CFIF> ---> <BR>
				#DD_Stage_Description#
			</TD>
			<CFSET DisplayBroker = TRIM(Broker_Name)>
			<CFSET DisplayRegion = TRIM(Region_Name)>
			<TD WIDTH="200" TITLE="Broker Name: #TRIM(DisplayBroker)##chr(13)#Region Name: #TRIM(DisplayRegion)#">

				<CFSET BrokerLen = LEN(DisplayBroker)>
				<CFIF BrokerLen GT 25>
					<CFSET DisplayBroker = LEFT(DisplayBroker,25)>
					#DisplayBroker#...
				<CFELSE>
				#DisplayBroker#
				</CFIF>
				<!--- #Broker_Name# ---><BR>
				<CFSET RegionLen = LEN(DisplayRegion)>
				<CFIF RegionLen GT 25>
					<CFSET DisplayRegion = LEFT(DisplayRegion,25)>
					#DisplayRegion#...
				<CFELSE>
				#DisplayRegion#
				</CFIF>
				<!--- #Region_Name# --->
			</TD>
			<TD>#Name_First# #Name_Last#&nbsp;</TD>
		</TR>
		</CFOUTPUT>
	</FORM>
</TABLE>
<cfset recCnt = Get_Data.record_count />
<cfif Get_Data.recordcount EQ 0>
	<cfset recCnt = 0>
</cfif>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1250" ALIGN="right">
	<TR>
		<TD>
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <CF_Next_Previous_For_Forms
				    formname="JustForPaging"
				    query="Get_Data"
				    record_count="#recCnt#"
				    maxpages="25"
				    previous		= "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				    next			= "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				    previousseries	= "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				    nextseries		= "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				    addparams="">
			</DIV>
		</TD>
		<TD ALIGN="Right" style="font-size: 12px;"><B><FONT SIZE="2" COLOR="Red"><CFIF recCnt NEQ 1>There Are <CFOUTPUT>#recCnt#</CFOUTPUT> Deductions That Match The Search Criteria<CFELSE>There is 1 Deduction that Match The Search Criteria</CFIF></FONT></B>
		<cfoutput>
		<cfif ReopenMessageDisplay><br><span style="background-color:#ReopenNotAckRowColor#">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> Highlighted deductions have been reopened but not yet acknowledged</cfif>
		</cfoutput>
		</TD>
	</TR>
</TABLE>
</CFIF>

<cfinclude template="/common_files/jQuery.cfm">
<script src="/script/javascript/jquery.noty.packaged.min.js"></script>

<SCRIPT language="JavaScript">
function sort_by_this_order(fieldName, sOrder)
	{
		var oForm = document.JustForPaging;
		oForm.SORT_BY.value = fieldName;
		oForm.SORT_ORDER.value = sOrder;
		oForm.submit();
		return false;
	}
	$('#dnload012').click(function() {
		noty( { text: "Downloading..."
	        	,layout:'topRight'
	        	,type:'information'
	        	,killer:true
	        	,timeout:3500	});

		window.open( "/Common_Files/exportAll.cfm?" + "type=dd_search"
													+ "&friendlyFileName=Deduction_Search"
													+ "&savedSearch=" + '<cfoutput>#urlEncodedFormat(variables.savedFormFileName)#</cfoutput>'
		              ,"_blank"
		              ,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
	});

	function QuickPay(DDID){
	var QuickPayHeight =  window.screen.height;
	var QuickPayWidth =  window.screen.width;
	window.open('/Scorecard/adv_quick_pay_DD.cfm?<cfoutput>Overspend=#Get_Profile_Settings.AQP_Max_Overspend#</cfoutput>&Deduction_ID='+DDID,'AdvanceQuickPay','width='+QuickPayWidth+',height='+QuickPayHeight+',scrollbars=1');
}
</SCRIPT>

</BODY>
