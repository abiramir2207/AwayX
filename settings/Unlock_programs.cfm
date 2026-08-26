<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Unlock_programs.cfm
	Created:	12/22/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		We use this page to unlock Locked Program
		we detrmine locked programed base on this condition 
	
	WHERE Contract_Main.Deleted = 0
	AND Contract_Main.Force_Expiration_Flag = 0
	AND Contract_Main.Approved = 1
	AND Contract_Main.Sent_To_External_Client = 0
---->
<CFPARAM NAME="URL.DOSEARCH" default="0">
<CFPARAM NAME="URL.Program_Desc" DEFAULT="">
<CFPARAM NAME="URL.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="URL.Start_date" DEFAULT="">
<CFPARAM NAME="URL.End_date" DEFAULT="">
<cfparam NAME="URL.Sort_by" 	default="Contract_Number">
<cfparam NAME="URL.Sort_by_previous" 	default="Contract_Number">
<cfparam NAME="URL.Sort_Order" 	default="DESC">
<cfoutput>
<CFPARAM NAME="Form.DOSEARCH" default="#URL.DOSEARCH#">
<CFPARAM NAME="FORM.Program_Desc" DEFAULT="#URL.Program_Desc#">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="#URL.Start_date_Operator#">
<CFPARAM NAME="FORM.Start_date" DEFAULT="#URL.Start_date#">
<CFPARAM NAME="FORM.End_date" DEFAULT="#URL.End_date#">
<CFSET Input_Select_Width = 150>
</cfoutput>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset programManager = CreateObject("component", "components.programs.program") />
<cfif isDefined("url.Program_Number")>
	<cfoutput>	
	<cfquery name="LatestContractMain" datasource="#application.datasource#">
		SELECT TOP 1 Contract_Main_ID FROM Contract_Main WHERE Contract_Number = '#Program_Number#'
		ORDER BY Contract_Main_ID Desc
	</cfquery>
	
	<cfquery name="UndeleteProgram" datasource="#application.datasource#">
		UPDATE          contract_main
		SET             Sent_To_External_Client = 1, 
                        Sending_To_External_Client = 0,
                        External_Client_Ack_Date = getdate(),
                        Unsuccessful_Ack_From_External_Client = 0,
                        Unsuccessful_Ack_Reason_From_External_Client = NULL,
                        External_Client_Error_Ack_Date = NULL
                       <!--- ,Ack_Detail = 'Manually Search unlocking'--->
		WHERE           Sent_To_External_Client = 0
		AND             contract_main_id = #LatestContractMain.Contract_Main_ID#
	</cfquery>

<!--- Dev Note: Milan; D8508 (Unlock the program after undeleting it) --->
	<cfset programManager.setLockStatus(LatestContractMain.Contract_Main_ID,0,request.AccessStructure.User_ID)>
<!--- End Note: Milan; D8508 --->

	</cfoutput>

</cfif>

<HTML>

<BODY>
<CFSET URL.PageTitle="Administration: Deleted/Purged Programs">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


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
function viewContract(program_id)
{
NewWindow('/scorecard/program_display.cfm?display_program=1&CID='+program_id,'ViewProgram','800','600','Yes', 'Yes');
}

function doUnlock(contractNumber)
{
	var bContinue = true;

		bContinue = window.confirm("Do you want to unlock program " + contractNumber + " ?") ;

	if(bContinue)
	{
		var sURL = "Unlock_Programs.cfm?Program_Number=" + contractNumber;
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
	if (SearchForm.Program_Desc.value == "" && SearchForm.Start_date.value == "")
	{
		alert("Please enter at least one search criterion.");
		isError = 1; 
	}
	if (isError == 0)
			{
				SearchForm.submit();
				//statusHandler();
			}
	return false;
}
</script>

<FORM ACTION="unlock_programs.cfm" METHOD="post" NAME="SearchForm" target="mainwindow">
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
  <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Unlock Programs Search</LEGEND>
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
					<center>Search Program #, Title.</center>
			</CF_SmallHelp>
			<span ID="searchItemLabel">Program</span>
		</TD>
		<TD valign="bottom">
			<span ID="searchItemLabel">Start Date</span>
		</TD>
		<TD valign="bottom"></TD>
	</TR>
	<TR>
		<TD valign="top" nowrap="nowrap">
			<input type="text" SIZE="40" Name="Program_Desc" value="<cfoutput>#form.Program_Desc#</cfoutput>">&nbsp;	
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
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: return doSearchNow();">search programs</a><FONT COLOR="#FF0000">]</FONT></B>&nbsp;&nbsp;
		<B><FONT COLOR="#FF0000">[</FONT><a href="unlock_programs.cfm" target="mainwindow">reset</a><FONT COLOR="#FF0000">]</FONT></B>
		</TD>
	</TR>
  </TABLE>
  </center>
</FIELDSET>
</FORM>
	
<CFIF Form.DOSEARCH EQ 1>
	<cfif Sort_by NEQ Sort_by_previous>
		<cfif Sort_by EQ "Contract_Number" OR Sort_by EQ "Approved" OR Sort_by EQ "Contract_Main.Contract_Created_Date"  OR Sort_by EQ "Contract_Main.Deleted_Date">
			<cfset Sort_Order = "DESC"/>
		</cfif>
		<cfset Sort_by_previous = #Sort_by#>
	</cfif>

	<cfquery name="GetUnlockPrograms" datasource="#application.datasource#">
	SELECT Contract_Main.contract_main_id,Contract_Main.Contract_Number, Contract_Main.Contract_Title, Contract_Main.Approved,Approval_Date,revision_version, 
	Contract_Main.contract_lock_date, Contract_Main.Contract_locked_by_user_id,
	Contract_Main.Contract_Created_Date, Contract_Main.Approval_Date, Contract_Main.Contract_Lock_Date, Contract_Main.Contract_Status_Type_IDX, UC.Name_First + ' ' + UC.Name_Last AS User_Created,
	 UE.Name_First + ' ' + UE.Name_Last AS User_Edited, UA.Name_First +  ' ' + UA.Name_Last AS User_Approved, UL.Name_First +  ' ' +UL.Name_Last AS User_Locked, 
	Contract_Main.Contract_Lock_Date, Contract_Main.Deleted_Date,
	Contract_Main.Flagged_As_Purged
	FROM Contract_Main
	LEFT JOIN _Users UA
	ON UA.User_ID = Contract_Main.Approved_By_User_ID
	INNER JOIN _Users UC
	ON UC.User_ID = Contract_Main.Creator_ID
	INNER JOIN _Users UE
	ON UE.User_ID = Contract_Main.Editor_ID
	LEFT JOIN _Users UL
	ON UL.User_ID = Contract_Main.Contract_Locked_By_User_ID
	WHERE Contract_Main.Deleted = 0
	AND Contract_Main.Force_Expiration_Flag = 0
	AND Contract_Main.Approved = 1
	AND Contract_Main.Sent_To_External_Client = 0
	<CFIF FORM.Program_Desc NEQ "">
		AND (Contract_Main.Contract_Number like '%#FORM.Program_Desc#%'
		OR Contract_Main.Contract_Title like '%#FORM.Program_Desc#%' )
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Greater_Or_Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.Contract_Start_Date > '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.Contract_Start_Date > '#FORM.Start_date# 00:00:00.000' 
		AND Contract_Main.Contract_Start_Date < '#FORM.Start_date# 23:59:59.000'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Less_Or_Equal" and FORM.Start_date NEQ "">
		AND Contract_Main.Contract_Start_Date < '#FORM.Start_date#'
	</CFIF>
	<CFIF FORM.Start_date_Operator EQ "Between" and FORM.Start_date NEQ "" and FORM.End_date NEQ "">
		AND Contract_Main.Contract_Start_Date >= '#FORM.Start_date#'
		AND Contract_Main.Contract_Start_Date <= '#FORM.End_date#'
	</CFIF>
	ORDER BY #Sort_by# #Sort_Order#, contract_main_id DESC
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
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=Contract_Number&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Contract Number</strong><cfif sort_by EQ "Contract_Number"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A> </td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=revision_version&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Version</strong><cfif sort_by EQ "revision_version"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=Contract_Title&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Contract Title</strong><cfif sort_by EQ "Contract_Title"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=Approved&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved</strong><cfif sort_by EQ "Approved"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=User_Approved&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Approved By</strong><cfif sort_by EQ "User_Approved"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=User_Created&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Created By<cfif sort_by EQ "User_Created"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
			<br><A HREF="Unlock_Programs.cfm?Sort_by=Contract_Main.Contract_Created_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Created On<cfif sort_by EQ "Contract_Main.Contract_Created_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=User_Edited&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Edited By</strong><cfif sort_by EQ "User_Edited"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></td>
		<td bgcolor="orange" nowrap><A HREF="Unlock_Programs.cfm?Sort_by=User_Deleted&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#"><strong>Locked By<cfif sort_by EQ "User_Deleted"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A>
			<br><A HREF="Unlock_Programs.cfm?Sort_by=Contract_Main.Deleted_Date&Sort_Order=#Sort_Order#&DOSEARCH=#Form.DOSEARCH#&Program_Desc=#Form.Program_Desc#&Start_date_Operator=#Form.Start_date_Operator#&Start_date=#Form.Start_date#&End_date=#Form.End_date#&Sort_by_previous=#Sort_by_previous#">Locked On<cfif sort_by EQ "Contract_Main.Deleted_Date"><IMG ID="SORTIMG" border="0" SRC="\Images\#Sort_Img#"><cfelse>&nbsp;&nbsp;</cfif></A></strong></td>
		<td bgcolor="orange"><strong>Unlock</strong></td>
		</cfoutput>
	</tr>

	<cfoutput query="GetUnlockPrograms">
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<cf_cryp type="en" string ="#GetUnlockPrograms.contract_main_id#" key="#request.key#">
			<cfset ContractID = cryp.value>
			<td nowrap><A STYLE="cursor:pointer;" ONCLICK="viewContract('#ContractID#')">#Contract_Number#</A></td>
			<td>&nbsp;&nbsp;<cfif Approved IS 1>#revision_version#<cfelse>0</cfif></td>
			<td width='200'>#Contract_Title#&nbsp;</td>
			<td><cfif Approved IS 1>Yes<cfelse>No</cfif></td>
			<td>#User_Approved#&nbsp; <br> #dateformat(Approval_Date, 'mm/dd/yy')#</td>
			<td nowrap>#User_Created#<br>#dateformat(Contract_Created_Date, 'mm/dd/yy')#</td>
			<td>#User_Edited#&nbsp;</td>
			<td><Cfif len(trim(User_Locked)) GT 0>#User_Locked#<cfelse>NA</CFIF><br>
			<cfif len(trim(contract_lock_date)) GT 0>#dateformat(contract_lock_date, 'mm/dd/yy')#<cfelse>NA</cfif></td>
			<td align="center"><a href="##" onclick="javaScript: return doUnlock('#Contract_Number#');"><img src="/images/checkmark.gif" border="0" style="cursor: pointer;"></a></td>
		</tr>
	</cfoutput>
	</table>
	<BR>
	<cfif GetUnlockPrograms.recordcount GT 0>
		<FONT COLOR="Red" SIZE="2"><B>There are <cfoutput>#GetUnlockPrograms.recordcount#</cfoutput> programs that match the specified criteria</B></FONT>
	<cfelse>
		<FONT COLOR="Red" SIZE="2"><B>There are no programs that match the specified criteria</B></FONT>
	</cfif>		
</CFIF>

</body>
</html>




