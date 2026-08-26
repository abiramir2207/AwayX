<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
      Template:  \billbacks\common\settlement.cfm
          Date:  Mar 15 2012
        Author:  Chris Nguyen
       Purpose:  Edit Settlement Information (Check Date, Check Number)

         Notes:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
</head>
<body>

<cfset Billback_ID = URL.BBID>

<cfif structKeyExists(form, "formSubmitted")>
	<cfquery name="setcheckinfo" datasource="#application.datasource#">
		UPDATE	BB_Approved
			 SET   BB_Approved.Check_Number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.check_number#">
			     , BB_Approved.Check_Date   = <cfqueryparam cfsqltype="cf_sql_date" value="#form.check_date#">
		 WHERE 	Billback_ID = '#Billback_ID#'
	</cfquery>

	<cflocation url="/billbacks/capture/Billback_Summary.CFM?#cgi.query_string#">
</cfif>

<cfquery name="Get_Billback_Info" datasource="#application.datasource#">
	SELECT	  	isnull(Billback_Program.Program_ID,'') AS ProgramID,
				isNull(Billback.Claim_Cases, 0.00) as Claim_Cases,
				isNull(Billback.Claim_Pounds, 0.00) as Claim_Pounds,
				isNull(cast(Billback.BB_Amount as decimal(18,2)), 0.00) as BB_Amount,
				Uploaded_Billback,
				Billback.*,
				Billback_Allied.BB_Is_Locked,
				Billback_Allied.BB_Locked_By_User_ID,
				Billback_Status.BB_Status_Description,
				cast(Billback_Settings.Auto_Approve_Amount as decimal(18,2)) as Auto_Approve_Amount,
				Billback_Settings.Auto_Approve_On,
        Billback_Settings.Auto_Approve_BB_Types,
        Billback_Settings.Auto_Approved_BB_Status,
        Billback_Closing_Methods.Abbreviation,
        Billback_Closing_Methods.vchBillback_Closing_Method_Desc,
				DateDiff(d, Billback.Created_Date, getDate()) as Billback_Age,
				Billback_Settings.Auto_Appr_Consider_Created_Date,
				Billback_Settings.Auto_Appr_Age
	FROM		Billback
        LEFT JOIN Billback_Closing_Methods
          ON (Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID)
				LEFT JOIN Billback_Settings ON 1 = 1
				LEFT JOIN Billback_Allied ON
				Billback_Allied.Billback_ID = Billback.Billback_ID
				LEFT JOIN Billback_Program ON
				Billback_Program.billback_id = 	Billback.billback_id
				AND Billback_program.deleted = 0
				LEFT JOIN   Billback_Status ON
				Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
	WHERE		Billback.Deleted = 0
	AND			Billback.Billback_ID = '#Billback_ID#'
</cfquery>

<cfquery name="GetApprovedInfo" datasource="#application.datasource#">
	SELECT 	BB_Approved.*,
			isnull(cast(BB_Approved.Expected_Amount as decimal(18,2)), 0) as BB_Expected_Amount,
			isnull(cast(BB_Approved.Approved_Amount as decimal(18,2)), 0) as BB_Approved_Amount,
			isnull(cast(BB_Approved.Paid_Amount as decimal(18,2)), 0) as BB_Paid_Amount,
			_Users.Name_First,
			_Users.Name_Last,
			BB_Approved.Check_Number,
			BB_Approved.Check_Date,
			BB_Approved.Check_Amount,
			BB_Check_Status_ID,
			BB_Approved.Vendor_master_ID,
			isnull(cast(BB_Settlement.withHold_amt as decimal(18,2)),0) as  withHold_amt,
			SP_Reason_Description,
			SP_Reason_Code,
			Billback.Payment_Notes AS PaymentNotes<!---D31841 --->
	FROM 	BB_Approved
	INNER JOIN Billback on Billback.Billback_id = BB_Approved.Billback_ID
	LEFT JOIN	BB_Settlement ON BB_Settlement.Billback_ID = BB_Approved.Billback_ID
	LEFT JOIN  	BB_ShortPay_Reason ON BB_ShortPay_Reason.BB_ShortPay_Reason_ID = BB_Settlement.BB_ShortPay_Reason_ID
			LEFT JOIN _users ON
			_Users.User_ID = BB_Approved.User_Approved
	WHERE 	BB_Approved.Billback_ID = <CFIF Get_Billback_Info.BB_Is_Child EQ 1>'#Get_Billback_Info.BB_parent_ID#'<CFELSE>'#Billback_ID#'</CFIF>
</cfquery>

<CFQUERY NAME="GetCheckInfo" DATASOURCE="#Application.Datasource#">
	SELECT  	BB_Approved.BB_Check_Status_ID,
				BB_Approved.Check_Number,
				BB_Approved.Check_Date,
				BB_Approved.Check_Amount,
				BB_Check_Status.BB_Check_Status
	FROM 		BB_Approved
	INNER JOIN 	BB_Check_Status ON BB_Check_Status.BB_Check_Status_ID = BB_Approved.BB_Check_Status_ID
	WHERE 		Billback_ID = '#Billback_ID#'
</CFQUERY>

<cfoutput>
<TABLE border=0 cellSpacing=0 cellPadding=1 width="99%" align=center style="margin-top:30px;">
		<caption align="left">
			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">#application.returned_customer_setting.company_name#</FONT>
		</caption>
		<tr>
			<td colspan="100%" bgcolor="">
				<B><FONT SIZE="+1" COLOR="Navy">Payable Number: #Get_Billback_Info.BB_Code#</FONT></B>&nbsp;&nbsp;&nbsp;
			</td>
		</tr>
	<tr>
		<td COLSPAN="100%" BGCOLOR=""><BR><B><FONT SIZE="2" COLOR="Navy">Settlement Information</FONT></B><HR COLOR="Navy">	</td>
	</tr>
	<tr>
		<td colspan="3">
			<form name="settlement" action="#cgi.script_name#?#cgi.query_string#" method="post">
			<input type="hidden" name="formSubmitted" value="1">
			<table width="430" border="0" cellspacing="2" cellpadding="2"><!--- start table --->
				<tr>
					<td ID="cellLabel">Status:</td>
					<td ID="dataStyle">#GetCheckInfo.BB_Check_Status#</td>
				</tr>
				<CFIF GetCheckInfo.BB_Check_Status_ID EQ 2 OR GetCheckInfo.BB_Check_Status_ID EQ 4>
					<tr>
						<td ID="cellLabel">Amount:</td>
						<td ID="dataStyle">#DOLLARFORMAT(GetCheckInfo.Check_Amount)#</td>
					</tr>
					<tr>
						<td ID="cellLabel">Date:</td>
						<td ID="dataStyle"><input type="text" name="check_date" value="#DATEFORMAT(GetCheckInfo.Check_Date,"mm/dd/yyyy")#" style="font-size:10px;"></td>
					</tr>
					<tr valign="top">
						<td ID="cellLabel">Settlement ID:<sup style="color:red">*</sup></td>
						<td ID="dataStyle"><input type="text" name="check_number" value="#GetCheckInfo.Check_Number#" style="font-size:10px;"></td>
					</tr>
					<tr>
						<td colspan="2" style="color:red">
						The Settlement ID represents either the check number or credit memo number, depending upon the closing method
						</td>
					</tr>
				</CFIF>
			</table>

			<br/><br/>

	<CF_button
		button_name		=	""
		button_caption	=	"save"
		button_action	=	"formSubmit();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>

			</form>
		</td>
	</tr>
</table>
</cfoutput>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<script>
formSubmit = function() {
	if ($.IsDate( $('input[name=check_date]').val() )) {
		settlement.submit();
	}
	else {
		alert( 'Date is not valid, please reenter.' );
		return false;
	}
}
</script>
</body>
</html>
