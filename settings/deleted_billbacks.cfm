<!---
	Copyright (c)2013 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\deleted_billbacks.cfm
	Created:		12/16/2013
	Developer:		drachala
	Description:	This page provide an option to view and un-delete all deleted billbacks.
	Label : D40664 :: Settings page to show Deleted Billbacks
--->
<CFPARAM NAME="URL.DOSEARCH" DEFAULT="0">
<CFPARAM NAME="URL.Billback_Desc" DEFAULT="">
<CFPARAM NAME="URL.START_DATE_OPERATOR" DEFAULT="">
<CFPARAM NAME="URL.START_DATE" DEFAULT="">
<CFPARAM NAME="URL.END_DATE" DEFAULT="">
<CFPARAM NAME="URL.SORT_BY" 	DEFAULT="BB_CODE">
<CFPARAM NAME="URL.SORT_BY_PREVIOUS" 	DEFAULT="BB_TITLE">
<CFPARAM NAME="URL.SORT_ORDER" 	DEFAULT="DESC">
<CFOUTPUT>
<CFPARAM NAME="FORM.DOSEARCH" DEFAULT="#URL.DOSEARCH#">
<CFPARAM NAME="FORM.Billback_Desc" DEFAULT="#URL.Billback_Desc#">
<CFPARAM NAME="FORM.START_DATE_OPERATOR" DEFAULT="#URL.START_DATE_OPERATOR#">
<CFPARAM NAME="FORM.START_DATE" DEFAULT="#URL.START_DATE#">
<CFPARAM NAME="FORM.END_DATE" DEFAULT="#URL.END_DATE#">
<CFSET INPUT_SELECT_WIDTH = 150>
</CFOUTPUT>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfif isDefined("url.Billback_ID")>
	
	<cfquery name="UndeleteBillback" datasource="#application.datasource#">
					UPDATE 	Billback
					SET			Deleted = 0,
									Un_Deleted_By_User_id = '#request.AccessStructure.user_id#',
									Un_Deleted_Date = GetDate(),
									Deviation_Ran_Date = NULL,
									Deviation_Ran_By = NULL
					WHERE Billback_ID = '#trim(url.Billback_ID)#'
	</cfquery>

	<cfif url.Billback_Status_ID GTE 3>

			<cfstoredproc datasource="#application.datasource#" procedure="Reset_Billback">
    		<cfprocparam type = "IN" CFSQLType="cf_sql_varchar" value="#trim(url.Billback_ID)#" dbvarname="@Billback_ID">
			<cfprocparam type = "IN" CFSQLType="cf_sql_varchar" value="#request.AccessStructure.user_id#" dbvarname="@User_ID">
 		</cfstoredproc>

	</cfif>
		
</cfif>	


<HTML>

<BODY>
<STYLE TYPE="text/css">
		Body, 
		TD
		{
			font: 12px Arial;
		},
		a 
		{
			color: Blue;
			text-decoration: none;
		}
</STYLE>
<script>
		function viewBillback(Billback_ID)
		{
		NewWindow('/billbacks/capture/bb_preview.cfm?deleted_billback=1&display_billback=1&BBID='+Billback_ID,'ViewBillback','800','600','Yes', 'Yes');
		}
		function doUndelete(Billback_ID, BB_Code, Billback_Status)
		{
			var bContinue =  window.confirm("Do you want to undelete billback " + BB_Code + " ?") ;

			if(bContinue)
			{
				var sURL = "deleted_billbacks.cfm?Billback_ID=" + Billback_ID +"&Billback_Status_ID="+Billback_Status;
				window.location.href = sURL;
			}
			
			return false;
		}
		function enableEndDate(thisObj)
		{
			var spName = "SP_End_date";
			var bDis = (thisObj.selectedIndex != 3) ? true: false;
			disableDiv(spName,bDis,false);
		}
		function disableEndDate()
		{
				enableEndDate(document.all.Start_date_Operator);
				document.all.Start_date.style.fontSize=10;
				document.all.End_date.style.fontSize=10;
				document.all.Start_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
				document.all.End_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
		}

		document.body.onload=new Function ("disableEndDate();")
		function doSearchNow()
{
	var isError = 0;
	var selected_index = SearchForm.elements["Start_date_Operator"].selectedIndex; 
	var selected_option_value = SearchForm.elements["Start_date_Operator"].options[selected_index].value;
	if (SearchForm.Billback_Desc.value == "" && SearchForm.Start_date.value == "")
	{
		alert("Please enter at least one search criterion.");
		isError = 1; 
	}
	if (isError == 0)
			{
				SearchForm.submit();
			}
	return false;
}
</script>
<CFSET URL.PageTitle="Administration: Deleted Billbacks">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<FORM ACTION="deleted_billbacks.cfm" METHOD="post" NAME="SearchForm" target="mainwindow">
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
  <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Deleted Billback Search</LEGEND>
	<center>
	<TABLE  CELLPADDING="1" CELLSPACING="0" >
			<TR>
				<TD valign="bottom">
					<CF_SmallHelp
							width="200"
							displayShifyX = "-20"
							imgPath="/images/help_small.gif"
							imgWidth="14"
							imgHeight="13"
							dropdownCheck="0"
							>
							<center>Search Payable #, Title.</center>
					</CF_SmallHelp>
					<span ID="searchItemLabel">Payable</span>
				</TD>
				<TD valign="bottom">
					<span ID="searchItemLabel">Deleted Date</span>
				</TD>
				<TD valign="bottom"></TD>
		</TR>
		<TR>
			<TD valign="top" nowrap="nowrap">
				<input type="text" SIZE="40" Name="Billback_Desc" value="<cfoutput>#form.Billback_Desc#</cfoutput>">&nbsp;	
			</TD>
		<CFSET Date_Operators="Equal,Less_Or_Equal,Greater_Or_Equal,between">
		<CFSET Date_Operator_Symbols="=,<,>,between">
		<TD valign="top" nowrap="nowrap">
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD><cfoutput>
						<SELECT OnChange="JavaScript: enableEndDate(this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:68px">
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
						</cfoutput>
					</TD>
					<TD>
						<SPAN ID="SP_Start_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
						</SPAN>
					</TD>
					<TD>&nbsp;&nbsp;&nbsp;</TD>
					<TD>
						<SPAN ID="SP_End_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
						</SPAN>
					</TD>
				</TR>
			</TABLE>
		</TD>
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
		<TD ALIGN="left" valign="bottom" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search billbacks</a><FONT COLOR="#FF0000">]</FONT></B>&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a href="deleted_billbacks.cfm" target="mainwindow">reset</a><FONT COLOR="#FF0000">]</FONT></B>
		</TD>
	</TR>
  </TABLE>
  </center>
</FIELDSET>
</FORM>
<!---Search Results --->
<CFIF Form.DOSEARCH EQ 1>
	<cfif Sort_by NEQ Sort_by_previous>
		<cfif Sort_by EQ "Contract_Number" OR Sort_by EQ "Approved" OR Sort_by EQ "Contract_Main.Contract_Created_Date"  OR Sort_by EQ "Contract_Main.Deleted_Date">
			<cfset Sort_Order = "DESC"/>
		</cfif>
		<cfset Sort_by_previous = #Sort_by#>
	</cfif>

	<cfquery name="GetDeletedBillbacks" datasource="#application.datasource#">
		SELECT B.Billback_id,B.BB_Code, B.BB_Title, U1.Name_First + '' +U1.Name_Last AS Creator, U2.Name_First + '' +U2.Name_Last AS deletedBy, 
		U3.Name_First + '' +U3.Name_Last,'N/A' AS approvedBy, B.Created_Date, B.Deleted_Date,Billback_Status_ID
		FROM Billback B
		LEFT JOIN BB_Approved BBA
		ON BBA.Billback_id = B.Billback_id
		INNER JOIN _Users U1
		ON U1.User_ID = B.BB_Creator_ID
		INNER JOIN _Users U2
		ON U2.User_ID = Deleted_By_User_id
		LEFT JOIN _Users U3
		ON U3.User_ID = BBA.User_Approved
		WHERE B.Deleted = 1
		AND B.Auto_billback = 0
		AND B.BB_Parent_ID IS NULL
	<CFIF FORM.Billback_Desc NEQ "">
		AND (B.BB_Code like '%#FORM.Billback_Desc#%'
		OR B.BB_Title like '%#FORM.Billback_Desc#%' )
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Greater_Or_Equal" and FORM.Start_date NEQ "">
		AND B.Deleted_Date > '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Equal" and FORM.Start_date NEQ "">
		AND B.Deleted_Date > '#FORM.Start_date# 00:00:00.000' 
		AND B.Deleted_Date < '#FORM.Start_date# 23:59:59.000'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Less_Or_Equal" and FORM.Start_date NEQ "">
		AND B.Deleted_Date < '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Between" and FORM.Start_date NEQ "" and FORM.End_date NEQ "">
		AND B.Deleted_Date >= '#FORM.Start_date#'
		AND B.Deleted_Date <= '#FORM.End_date#'
	</CFIF>
	ORDER BY #Sort_by# #Sort_Order# 
	</cfquery>

	<cfif FindNoCase("DESC", "#Sort_Order#")>
		<cfset Sort_Img = "up_1.gif">
		<cfset Sort_Order =""/>
	<cfelse>
		<cfset Sort_Img = "down_1.gif">
		<cfset Sort_Order ="DESC"/>
	</cfif>

	<table width="100%" cellpadding="2" cellspacing="0" border="0" class="maintable">
	<tr>
		<cfoutput>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=bb_code&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Payable</strong><cfif sort_by EQ "bb_code"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A> </td>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=bb_Title&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Title</strong><cfif sort_by EQ "bb_Title"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=Billback_Status_ID&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved<cfif sort_by EQ "Billback_Status_ID"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=approvedBy&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved By<cfif sort_by EQ "approvedBy"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=Creator&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Created By<cfif sort_by EQ "Creator"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
		<br><A HREF="deleted_billbacks.cfm?Sort_by=Created_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Created On<cfif sort_by EQ "Created_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
		<td bgcolor="orange" nowrap><A HREF="deleted_billbacks.cfm?Sort_by=DeletedBy&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Deleted By<cfif sort_by EQ "DeletedBy"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
		<br><A HREF="deleted_billbacks.cfm?Sort_by=Deleted_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Billback_Desc=#Form.Billback_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Deleted On<cfif sort_by EQ "Deleted_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
		<cfif Get_Profile_Settings.Re_instate_deleted_billbacks>
			<td bgcolor="orange"><strong>Undelete</strong></td>
		</cfif>
		</cfoutput>
	</tr>

	<cfoutput query="GetDeletedBillbacks">
		<cfif len(approvedBy) EQ 0>
			<cfset approvedBy = 'N/A'>
		</cfif>
		<cfif Billback_Status_ID GTE 3>
			<cfset BB_Status_Description = 'Yes'>
		<cfelse>
			<cfset BB_Status_Description = 'No'>
		</cfif>
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<td nowrap><A STYLE="cursor:pointer;" ONCLICK="viewBillback('#Billback_ID#')">#bb_code#</A></td>
			<td>#bb_Title#&nbsp;</td>
			<td>#BB_Status_Description#&nbsp;</td>
			<td>#approvedBy#&nbsp;</td>
			<td nowrap>#Creator#<br>#dateformat(Created_Date, 'mm/dd/yy')#</td>
			<td>
				<CFIF len(trim(deletedBy)) GT 0>#deletedBy#<CFELSE>NA</CFIF><br>
				<CFIF len(trim(Deleted_Date)) GT 0>#dateformat(Deleted_Date, 'mm/dd/yy')#<CFELSE>NA</CFIF>
			</td>
			<cfif Get_Profile_Settings.Re_instate_deleted_billbacks>
				<td><a href="##" onclick="javaScript: return doUndelete('#Billback_ID#', '#BB_Code#','#Billback_Status_ID#');"><img src="/images/checkmark.gif" border="0" style="cursor: pointer;"></a></td>
			</cfif>	
		</tr>
	</cfoutput>
	</table>
	<BR>
	<cfif GetDeletedBillbacks.recordcount GT 0>
		<FONT COLOR="Red" SIZE="2"><B>There are <cfoutput>#GetDeletedBillbacks.recordcount#</cfoutput> billbacks that match the specified criteria</B></FONT>
	<cfelse>
		<FONT COLOR="Red" SIZE="2"><B>There are no billbacks that match the specified criteria</B></FONT>
	</cfif>		
</CFIF>


</BODY>
</HTML>
