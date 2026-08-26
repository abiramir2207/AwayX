<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.SubmitLockStatus" DEFAULT="0">
<CFPARAM NAME="FORM.Lock_Status" DEFAULT="0">

<CFSET Locked_Img = "/Images/Deviations/lock_yes.jpg">
<CFSET UnLocked_Img = "/Images/Deviations/lock_no.jpg">

<CFOUTPUT>
<FORM NAME="LockDeduction" ACTION="/Billbacks/Multi_BB_Payment/Lock_BB.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="SubmitLockStatus" VALUE="1">
<CFIF IsDefined("URL.FromFirstPage")>
<INPUT TYPE="Hidden" NAME="FromFirstPage" VALUE="1">
</CFIF>

<CFIF IsDefined("URL.Pay_Multi_Billbacks_ID")>
<INPUT TYPE="Hidden" NAME="Pay_Multi_Billbacks_ID" VALUE="#URL.Pay_Multi_Billbacks_ID#">
<CFIF IsDefined("URL.Payment_Data_Export_1_ID")>
<INPUT TYPE="Hidden" NAME="Payment_Data_Export_1_ID" VALUE="#URL.Payment_Data_Export_1_ID#">
</CFIF>
<INPUT TYPE="Hidden" NAME="BBID" VALUE="#URL.BBID#"> 
</CFIF>
<CFIF IsDefined("URL.New_BB_Check") OR IsDefined("URL.RID")>
<CFIF IsDefined("URL.LRID")>
<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.LRID#">
<CFELSE>
<INPUT TYPE="Hidden" NAME="RID" VALUE="#URL.RID#">
</CFIF>
</CFIF>
<!--- <INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#Deduction_ID#"> --->
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" <CFIF IsDefined("FORM.Pay_Multi_Billbacks_ID")>WIDTH="85%"<CFELSE>WIDTH="700"</CFIF>>
<TR>
	<!--- <TD WIDTH="100">&nbsp;</TD> --->
	<TD WIDTH="40" nowrap style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; padding: 0">
		<CFIF FORM.Lock_Status EQ 2>
			<img src="/Images/Deviations/lock_yes.jpg" alt="" width="40" height="40" border="0">
		<CFELSEIF FORM.Lock_Status EQ 1>
			<INPUT TYPE="Hidden" NAME="Lock_Status" VALUE="0">  					
			<CFOUTPUT><INPUT TYPE="Hidden" NAME="Locked_By" VALUE=""></CFOUTPUT>
			<INPUT TYPE="Image" SRC="#Locked_Img#" ONMOUSEOVER="this.src='#UnLocked_Img#';" ONMOUSEOUT="this.src='#Locked_Img#';" ONCLICK="Javascript: LockUnLock();">
		<CFELSEIF FORM.Lock_Status EQ 0>	
			<INPUT TYPE="Hidden" NAME="Lock_Status" VALUE="1">
			<INPUT TYPE="Hidden" NAME="Locked_By" VALUE="#request.AccessStructure.user_ID#">
			<INPUT TYPE="Image" SRC="#UnLocked_Img#" ONMOUSEOVER="this.src='#Locked_Img#';" ONMOUSEOUT="this.src='#UnLocked_Img#';" ONCLICK="Javascript: LockUnLock();">						
		</CFIF>			
	</TD>
	<TD STYLE="font-size : 9pt; color : Blue; font-weight:bold;">	
		<CFIF FORM.Lock_Status EQ 1 OR FORM.Lock_Status EQ 2>
			LOCKED
		<CFELSE>
			UNLOCKED
		</CFIF>		
	</TD>
</TR>
</TABLE>
</FORM>
<SCRIPT language="JavaScript">
function LockUnLock()
{	
	document.all.SubmitLockStatus.value=1;
	document.LockDeduction.submit();
}
</SCRIPT>

<CFIF Not IsDefined("Pay_Multi_Billbacks_ID")>
	<CFIF IsDefined("FORM.RID")>
		<cfset useLakebaseForGetMultiID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForGetMultiID>
	<cftry>
		<cfset GetMultiID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#FORM.RID#",
				"select" = "pay_multi_billbacks_id"
			}), "pay_multi_billbacks_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetMultiID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetMultiID>
<CFQUERY NAME="GetMultiID" DATASOURCE="#Application.Datasource#">
			SELECT 	Pay_Multi_Billbacks_ID 
			FROM 	Ledger_Table
			WHERE 	Ledger_ID = '#FORM.RID#'
		</CFQUERY>
</cfif>
	</CFIF>
</CFIF>
<CFIF FORM.Lock_Status EQ 0>
	<CFQUERY NAME="UnLock" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Allied
		SET 	BB_Is_Locked = 0,
				BB_Locked_By_User_ID = Null
				
		WHERE 	Billback_ID IN ( 	SELECT 	Billback_ID 
									FROM 	Pay_Multi_Billbacks_List
									WHERE 	Pay_Multi_Billbacks_ID = <CFIF IsDefined("Pay_Multi_Billbacks_ID")>
																		'#Pay_Multi_Billbacks_ID#'
																	 <CFELSE>
																		'#GetMultiID.Pay_Multi_Billbacks_ID#'
																	 </CFIF> AND 
											Deleted = 0		) AND
				BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
				AND BB_Locked_By_Match_Central = 0
	</CFQUERY>
<CFELSE>	
	<CFQUERY NAME="Lock" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Allied
		SET 	BB_Is_Locked = 1,
				BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
				BB_Lock_Date = '#DATEFORMAT(Now(),"mm/dd/yyyy")#'
				
		WHERE 	Billback_ID IN ( 	SELECT 	Billback_ID 
									FROM 	Pay_Multi_Billbacks_List
									WHERE 	Pay_Multi_Billbacks_ID = <CFIF IsDefined("Pay_Multi_Billbacks_ID")>
																		'#Pay_Multi_Billbacks_ID#'
																	 <CFELSE>
																		'#GetMultiID.Pay_Multi_Billbacks_ID#'
																	 </CFIF> AND 
											Deleted = 0			)			
	</CFQUERY>
</CFIF>

<CFIF IsDefined("FORM.RID")>
	<CFQUERY NAME="GetURLVar" DATASOURCE="#Application.Datasource#">
		SELECT 		Pay_Multi_Billbacks_List.Billback_ID,
					Pay_Multi_Billbacks_List.Pay_Multi_Billbacks_ID
					
		FROM 		ledger_table 
		
		INNER JOIN	Pay_Multi_Billbacks_List ON Pay_Multi_Billbacks_List.Pay_Multi_Billbacks_ID	= ledger_table.Pay_Multi_Billbacks_ID AND
					Pay_Multi_Billbacks_List.Deleted = 0 
					
		WHERE 		ledger_ID = '#FORM.RID#'  
	</CFQUERY>
<CFELSEIF IsDefined("FORM.BBID") AND FORM.BBID EQ "">
	<CFQUERY NAME="GetURLVar" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 Billback_ID
		FROM 	Pay_Multi_Billbacks_List
		WHERE 	Pay_Multi_Billbacks_ID = '#FORM.Pay_Multi_Billbacks_ID#' AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF FORM.Lock_Status EQ 1 AND IsDefined("FORM.Pay_Multi_Billbacks_ID") AND NOT IsDefined("FORM.RID") AND IsDefined("FORM.Payment_Data_Export_1_ID")>		
	<CFLOCATION URL="/Billbacks/Check_Book/Bank_Tran/General_Ledger_Account/View_Edit_Approve.cfm?BBID=#FORM.BBID#&Pay_Multi_Billbacks_ID=#FORM.Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#" ADDTOKEN="NO">	
<CFELSEIF FORM.Lock_Status EQ 1 AND IsDefined("FORM.Pay_Multi_Billbacks_ID") AND NOT IsDefined("FORM.RID")>
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&ShowButton=1" ADDTOKEN="No">
<CFELSEIF FORM.Lock_Status EQ 1 AND IsDefined("FORM.Pay_Multi_Billbacks_ID") AND IsDefined("FORM.RID")>
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#GetURLVar.Billback_ID#&Pay_Multi_Billbacks_ID=#GetURLVar.Pay_Multi_Billbacks_ID#&ShowButton=1" ADDTOKEN="No">
<CFELSEIF FORM.SubmitLockStatus EQ 1 AND FORM.Lock_Status EQ 0 AND NOT IsDefined("FORM.RID") AND IsDefined("URL.FromFirstPage")>
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#" ADDTOKEN="No">
<CFELSEIF FORM.SubmitLockStatus EQ 1 AND FORM.Lock_Status EQ 0 AND IsDefined("FORM.RID")>		
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?New_BB_Check=1&RID=#FORM.RID#&BBID=#GetURLVar.Billback_ID#&Pay_Multi_Billbacks_ID=#GetURLVar.Pay_Multi_Billbacks_ID#" ADDTOKEN="No">
<CFELSEIF FORM.SubmitLockStatus EQ 1 AND FORM.Lock_Status EQ 0 AND IsDefined("FORM.FromFirstPage")>
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#BBID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#" ADDTOKEN="No">
<CFELSEIF IsDefined("FORM.BBID") AND FORM.BBID EQ "">
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#GetURLVar.Billback_ID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#" ADDTOKEN="No">
<CFELSEIF FORM.Lock_Status EQ 0 AND IsDefined("FORM.Pay_Multi_Billbacks_ID") AND NOT IsDefined("FORM.RID") AND IsDefined("FORM.Payment_Data_Export_1_ID")>		
	<CFLOCATION URL="Distributor_And_BB_Form.cfm?BBID=#FORM.BBID#&Pay_Multi_Billbacks_ID=#FORM.Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#" ADDTOKEN="NO">	
</CFIF>
</CFOUTPUT>




</body>
</html>
