<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Reassign Deduction</title>
</head>
<body>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
	<cfinclude template="Custom_Deduction_workflow.cfm">
<cfelse>
<STYLE>
	TABLE.underline TD{
		border-bottom:solid #C0C0C0 1px;
	}
</STYLE>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<CFIF FORM.Form_Submitted EQ "">
	<BR><BR>
	<cfset useLakebaseForDD_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDD_Details>
		<cftry>
			<cfset DD_Details = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", {
					"deduction_id" = "eq.#URL.Deduction_ID#"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDD_Details = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDD_Details>
	<CFQUERY NAME="DD_Details" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Deductions WHERE Deduction_ID = '#URL.Deduction_ID#'
	</CFQUERY>
	</cfif>
	<CFQUERY NAME="Analyst_List" DATASOURCE="#Application.Datasource#">
		SELECT 		*
		FROM 		DD_Analyst
		INNER JOIN	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID AND _Users.Deleted=0
		WHERE 		DD_Analyst.Deleted=0
		ORDER BY	_Users.Name_First,_Users.Name_Last
	</CFQUERY>

	<CFQUERY NAME="Get_All" DATASOURCE="#Application.Datasource#">
		SELECT 		Deduction_ID,
					DD_DedID,
					SP_Number,
					DD_Amount,
					BSA_Foodservice_Customers.Name,
					BSA_Foodservice_Customers.Ship_To,
					_Users.Name_First,
					_Users.Name_Last,
					Deductions.Is_Locked,
					Locked_By,
					DD_DedID_SP_Number
		FROM 		Deductions
		LEFT JOIN	BSA_Foodservice_Customers
		ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID
		AND BSA_Foodservice_Customers.Deleted=0
		<!--- Change users left join to Inner join once saru is done with his job. --->
		LEFT JOIN	_Users
		ON _Users.User_ID = Deductions.Analyst_User_ID
		AND _Users.Deleted=0
		WHERE 		DD_DedID = '#DD_Details.DD_DedID#'
		AND 	Deductions.Deleted=0
		AND   Deductions.DD_Status NOT IN (4,5)
		ORDER BY 	SP_Number
	</CFQUERY>

	<FORM NAME="Reassign" ACTION="/deductions/Reassign/Single_DD_Reassign.cfm" METHOD="Post">
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
	<INPUT TYPE="Hidden" NAME="URLDeduction_ID" VALUE="#URL.Deduction_ID#">
	<INPUT TYPE="Hidden" NAME="From_Analyst" VALUE="#DD_Details.Analyst_User_ID#">
	<INPUT TYPE="Hidden" NAME="Is_Parent" VALUE="#DD_Details.DD_IsParent#">
	<CFIF Get_All.recordcount GT 1>
	<INPUT TYPE="Hidden" NAME="HaveSplit" VALUE="1">
	<CFELSE>
	<INPUT TYPE="Hidden" NAME="HaveSplit" VALUE="0">
	</CFIF>
	</CFOUTPUT>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="100%">
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><B><FONT COLOR="Navy" SIZE="2">REASSIGN DEDUCTION</FONT></B><HR COLOR="Navy"><BR><BR></TD>
			</TR>
			<TR>
				<TD ALIGN="Center"><B>Pick analyst:&nbsp;&nbsp;</B>
					<SELECT NAME="To_Analyst">
						<OPTION VALUE="">
						<CFOUTPUT QUERY="Analyst_List">
							<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<CFIF Get_All.recordcount GT 1>
				<TR>
					<TD COLSPAN="100%" VALIGN="Top"><BR><BR><B>Pick From the List:</B></TD>
				</TR>
				<TR>
					<TD COLSPAN="100%">
						<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="underline" WIDTH="100%">
							<TR BGCOLOR="FFE083">
								<TD ID="header">
									<input TYPE="checkbox" NAME="allbox" onClick="javaScript: selectAll(this);">
								</TD>
								<TD STYLE="font-size : 11px;"><B>DEDUCTION #</B></TD>
								<TD STYLE="font-size : 11px;"><B>AMOUNT<BR><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></B></TD>
								<TD STYLE="font-size : 11px;"><B>ANALYST</B></TD>
							</TR>
							<CFOUTPUT QUERY="Get_All">
							<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<TD VALIGN="Top"><INPUT TYPE="CheckBox" NAME="Deduction_ID" VALUE="#Deduction_ID#" <CFIF Is_Locked EQ 1 AND Locked_By NEQ request.AccessStructure.User_ID>DISABLED</CFIF>></TD><!--- <CFIF URL.Deduction_ID EQ Deduction_ID>CHECKED</CFIF> --->
								<TD VALIGN="Top" <CFIF URL.Deduction_ID EQ Deduction_ID>Title="Currently you are on this deduction"</CFIF>><B><FONT COLOR="Red" SIZE="2">[ </FONT>
								<CFIF URL.Deduction_ID EQ Deduction_ID><FONT COLOR="Red">#DD_DedID_SP_Number#<!--- #DD_DedID#-<CFIF SP_Number EQ "">000<CFELSE>#SP_Number#</CFIF>---></FONT>
								<CFELSE>#DD_DedID_SP_Number#<!--- #DD_DedID#-<CFIF SP_Number EQ "">000<CFELSE>#SP_Number#</CFIF>---></CFIF><FONT COLOR="red" SIZE="2"> ]</FONT></B>

									<CFIF SP_Number EQ "">
										<CFSET child_count = recordcount - 1>
										<img src="/Images/parent_New.gif" title="Original deductions." width="13" height="13" border="0">
									<CFELSE>
										<CFSET Original = "#DD_DedID#-000">
										<img src="/Images/child_New.gif" title="Split from original deduction." width="13" height="13" border="0">
									</CFIF>
								</TD>
								<TD VALIGN="Top" <CFIF Name NEQ "">TITLE="#application.returned_customer_setting.shard_ship_to_label#: #Ship_To#"</CFIF>>#DollarFormat(DD_Amount)#<BR><CFIF Name NEQ "">#Name#<CFELSE>None selected.</CFIF></TD>
								<TD VALIGN="Top">#Name_First# #Name_Last#&nbsp;</TD>
							</TR>
							</CFOUTPUT>
						</TABLE>
					</TD>
				</TR>
			<CFELSE>
				<CFOUTPUT><INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#URL.Deduction_ID#"></CFOUTPUT>
			</CFIF>
			<TR>
				<TD ALIGN="Center" COLSPAN="100%"><BR><HR COLOR="Navy"><BR>
					<CF_button
						button_name	=	"reassign"
						button_caption	=	"Reassign"
						button_action	=	"Validate()"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight	=	"bold"
									>
				</TD>
			</TR>
		</TABLE>
	</FORM>
<CFELSE>
	<CFLOOP LIST="#FORM.Deduction_ID#" INDEX="Item">
		<cfset useLakebaseForGetDDDet = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDDDet>
	<cftry>
		<cfset GetDDDet = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Item#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDDDet = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDDDet>
<CFQUERY NAME="GetDDDet" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Deductions WHERE Deduction_ID = '#Item#'
		</CFQUERY>
</cfif>
		<CFSET UnSuccessful = "">
		<CFIF GetDDDet.Is_locked EQ 1 AND GetDDDet.Locked_By NEQ request.AccessStructure.User_ID>
			<CFSET UnSuccessful = "#UnSuccessful##Item#,">
		<CFELSE>
			<cfset useLakebaseForLockBeforeReassign = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForLockBeforeReassign>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Item#"
			},
			{
				"is_locked" = "1",
				"locked_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockBeforeReassign = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockBeforeReassign>
<CFQUERY NAME="LockBeforeReassign" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	Is_Locked = 1,Locked_By = '#request.AccessStructure.User_ID#'
				WHERE 	Deduction_ID = '#Item#'
			</CFQUERY>
</cfif>

			<CFQUERY NAME="Store_Data" DATASOURCE="#Application.Datasource#">
				INSERT INTO		DD_Reassign (	Deduction_ID,
								From_Analyst,
								To_Analyst,
								By_Analyst)
				VALUES		(	'#Item#',
								<CFIF GetDDDet.Analyst_User_ID NEQ "">
								'#GetDDDet.Analyst_User_ID#',
								<CFELSE>
								NULL,
								</CFIF>
								'#FORM.To_Analyst#',
								'#request.AccessStructure.User_ID#'		)
			</CFQUERY>

			<CFQUERY NAME="Update_DD_Analyst" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions
				SET 	Analyst_User_ID = 	'#FORM.To_Analyst#'
						<!--- IF the Deduction Status is New or Open and the Analyst is changing, then set the status back to new --->
						<cfif ListFindNoCase("1,2", GetDDDet.DD_Status) and trim(GetDDDet.Analyst_User_ID) neq trim('#FORM.To_Analyst#')>
						, DD_Status = 1
						</cfif>
				WHERE 	Deduction_ID = '#Item#' AND Deleted=0
			</CFQUERY>
			<CFIF Item NEQ FORM.URLDeduction_ID>
				<CFQUERY NAME="UnLock" DATASOURCE="#Application.Datasource#">
					UPDATE 	Deductions
					SET 	Is_Locked = 0,Locked_By = ''
					WHERE 	Deduction_ID = '#Item#'
				</CFQUERY>
			</CFIF>
		</CFIF>
	</CFLOOP>

	<CFIF UnSuccessful NEQ "">
		<CFSET UnSuccessful = ListQualify(UnSuccessful,"'",",","All")>
		<CFQUERY NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
			SELECT DD_DedID,SP_Number FROM Deductions WHERE Deduction_ID IN (#PreserveSingleQuotes(UnSuccessful)#)
		</CFQUERY>
		<CFSET UnSuccessfulItems = "">
		<CFOUTPUT QUERY="Unavailable_Title">
			<CFIF SP_Number NEQ "">
				<CFSET Split = #SP_Number#>
			<CFELSE>
				<CFSET Split = "000">
			</CFIF>
			<CFSET UnSuccessfulItems = "#UnSuccessfulItems# [ #TRIM(DD_DedID)# - #Split# ]">
		</CFOUTPUT>
	</CFIF>
	<CFIF UnSuccessful EQ "">
		<br><br><br><br>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><FONT COLOR="Red" SIZE="3"><B>Please wait while deductions are being reassigned...</B></FONT></TD>
			</TR>
		</TABLE>
		<SCRIPT language="JavaScript">
			function delayLocate(){
				window.location.href = "/deductions/Reassign/Single_DD_Reassign.cfm?Deduction_ID=<CFOUTPUT>#FORM.URLDeduction_ID#&showScissor=1</CFOUTPUT>";
			}
			window.setTimeout('delayLocate()', 3000);
		</SCRIPT>
	<CFELSE>
		<SCRIPT language="JavaScript">
			function delayLocate(){
				window.location.href = "/deductions/Reassign/Single_DD_Reassign.cfm?Deduction_ID=<CFOUTPUT>#FORM.URLDeduction_ID#&showScissor=1</CFOUTPUT>";
			}
			var unSucc = "<CFOUTPUT>#UnSuccessfulItems#</CFOUTPUT>";
			alert("Deduction(s) " + unSucc + " can't be reassigned (These deductions are currently locked by someother user).");
			window.setTimeout('delayLocate()', 0);
		</SCRIPT>
	</CFIF>
</CFIF>
<SCRIPT language="JavaScript">
function anyCheckBoxChecked(chObj){
	var bChecked = false;
	if(chObj.length){
		var i, chLen;
		chLen = chObj.length;
		for(i=0;i<chLen;i++){
			if(chObj[i].checked){
				bChecked = true;
				break;
			}
		}
	}
	else{
		if(chObj.checked){
			bChecked = true;
		}
	}
	return bChecked;
}
function selectAll(thisobj){
	var bCheck = thisobj.checked;
	var chObjs = document.all.Deduction_ID;

	if(chObjs.length){
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++){
			chObjs[i].checked = bCheck;
		}
	}
	else{
		chObjs.checked = bCheck;
	}
}
function Validate(){
	var x=document.Reassign;
	var submit_Ok = 1;
	if (x.To_Analyst.value == ""){
		alert("Please select an analyst.");
		submit_Ok = 0;
		x.To_Analyst.focus();
		return;
	}
	if	(x.HaveSplit.value == 1){
		if(!anyCheckBoxChecked(x.Deduction_ID)){
			alert("Please pick at least one deduction to reassign.");
			submit_Ok = 0
			return;
		}
	}
	if (submit_Ok == 1){
		document.all.Form_Submitted.value=1;
		document.Reassign.submit();
		disableButton("reassign_table", true, false);
	}

}
</SCRIPT>
</CFIF>
</body>
</html>
