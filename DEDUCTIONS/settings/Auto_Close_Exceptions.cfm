<!--- Save/update values --->
<cfparam name="DistributorExceptions" 	default="">
<cfparam name="blnSubmit" 				default="0">
<cfoutput>
<CFPARAM NAME="URL.StartRow" DEFAULT="1">
<CFPARAM NAME="URL.frompage" DEFAULT="1">
<cfoutput>
<CFPARAM NAME="FORM.StartRow" DEFAULT="#URL.StartRow#">
<CFPARAM NAME="FORM.frompage" DEFAULT="#URL.frompage#">
</cfoutput>

<CFSET StartRow = FORM.StartRow>
<CFSET frompage = FORM.frompage>
<cf_Number_of_Rows maxrows=40>
</cfoutput>
<html>
<head>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
</head>
<!--- save values --->
<cfif blnSubmit IS 1>
	<cfloop list="#DistributorExceptions#" index="Distributor_ID">
		
		<cfset SafeDistributorID = replace(Distributor_ID, "-", "_", "all")>
		
		<cfif isDefined("Amount_#SafeDistributorID#")>
		<cfset AutoCloseAmount = evaluate("Amount_#SafeDistributorID#")> 
		
		<cfset useLakebaseForIsDistributorAlreadyThere = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_close_exception")>
		<cfif useLakebaseForIsDistributorAlreadyThere>
			<cftry>
				<cfset IsDistributorAlreadyThere = application.oLakebase.toQuery(
					application.oLakebase.selectRows("bb_auto_close_exception", {
						"distributor_id" = "eq.#Distributor_ID#",
						"deleted" = "eq.0"
					})
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForIsDistributorAlreadyThere = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForIsDistributorAlreadyThere>
		<cfquery name="IsDistributorAlreadyThere" datasource="#application.datasource#">
		SELECT * FROM
		BB_Auto_Close_Exception
		WHERE Distributor_ID = '#Distributor_ID#'
		AND Deleted = 0
		</cfquery>
		</cfif>
		
		<cfif IsDistributorAlreadyThere.Recordcount GT 0>
		<!--- UPDATE --->
			<cfset useLakebaseForUpdateRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_close_exception")>
			<cfif useLakebaseForUpdateRecord>
				<cftry>
					<cfset application.oLakebase.updateRows("bb_auto_close_exception",
						{ "distributor_id" = "eq.#Distributor_ID#" },
						{ "auto_close_amount" = AutoCloseAmount }
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForUpdateRecord = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForUpdateRecord>
			<cfquery name="UpdateRecord" datasource="#application.datasource#">
			UPDATE BB_Auto_Close_Exception
			SET Auto_Close_Amount = '#AutoCloseAmount#'
			WHERE Distributor_ID = '#Distributor_ID#'
			</cfquery>
			</cfif>
		
		<cfelse>
		<!--- INSERT --->
			<cfset useLakebaseForInsertRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_auto_close_exception")>
			<cfif useLakebaseForInsertRecord>
				<cftry>
					<cfset application.oLakebase.insertRow("bb_auto_close_exception", {
						"auto_close_amount" = AutoCloseAmount,
						"distributor_id" = Distributor_ID
					})>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForInsertRecord = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForInsertRecord>
			<cfquery name="InsertRecord" datasource="#application.datasource#">
			INSERT INTO BB_Auto_Close_Exception
			(
				Auto_Close_Amount,
				Distributor_ID
			)
			VALUES
			(
				#AutoCloseAmount#, 
				'#Distributor_ID#'
			)
			</cfquery>
			</cfif>
		</cfif> 
		</cfif>
	</cfloop>

<cfelseif blnSubmit IS 2>	
	<cfloop list="#Checkbox#" index="Fieldname">
		<cfset FieldLength = len(Fieldname)>
		<cfset DesiredLength = FieldLength - 7>
		<cfset PartialDist = right(Fieldname, DesiredLength)>
		<cfset DeletedDistributor = replace(PartialDist, "_", "-", "all")>
			
		<cfquery name="DeleteDistributor" datasource="#application.datasource#">
		UPDATE BB_Auto_Close_Exception
		SET Deleted = 1,
			Deleted_Date = #now()#
		WHERE Distributor_ID = '#DeletedDistributor#'
		</cfquery>
		
	</cfloop>
		
	<cfquery name="GetUndeletedDistributors" datasource="#application.datasource#">
	SELECT BSA_Foodservice_Customers_ID
	FROM BSA_Foodservice_Customers
		INNER JOIN BB_Auto_Close_Exception
		ON BB_Auto_Close_Exception.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		AND BB_Auto_Close_Exception.Deleted = 0
	--WHERE BSA_Foodservice_Customers_ID IN (#listqualify(DistributorExceptions, "'")#)
	ORDER BY BSA_Foodservice_Customers.Name
	</cfquery>
	
	<cfset DistributorExceptions = valuelist(GetUndeletedDistributors.BSA_Foodservice_Customers_ID)>
	
</cfif>
<!--- end save values --->
<body>

<CFSET URL.PageTitle="Billback Auto Close Exceptions">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- end save --->


<!--- Select distributors --->
<!--- apply same rate to all checked --->
<cfquery name="GetAutoApproveFromBillbacks" datasource="#application.datasource#">
	SELECT Auto_Approve_On, isnull(Auto_Approve_Amount, 0) AS Auto_Approve_Amount, _Users.Name_First, _Users.Name_Last, Auto_Approve_Updated_Date
	FROM Billback_Settings
		INNER JOIN _Users
		ON _Users.User_ID = Billback_Settings.Auto_Approve_Updated_By
	</cfquery>

<!--- save link --->
<table cellpadding="2" cellspacing="0" width="600" border="0">
<form name="AutoCloseExceptions" method="post" action="auto_close_exceptions.cfm">


<tr style="border-bottom: none;">
	<td colspan="2"  valign="bottom"  style="border-bottom: none;">
	<cfoutput><CF_button
		button_name		=	""
		button_caption	=	"select #lcase(application.returned_customer_setting.distributor_label_plural)#"
		button_action	=	"DistributorSearch()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
		class			=	"NotMaintable"
	></cfoutput>
	</td>
	<td  width="150" align="right"  style="border-bottom: none;">
		<input type="text" name="AppliedAmount" value="">
		<CF_button
		button_name		=	""
		button_caption	=	"apply to checked on this page"
		button_action	=	"MassApply()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	</td>
	<td  style="border-bottom: none;">&nbsp;  </td>
</tr>
<!--- Loop through distributors (combination of database values and form values) --->
	<!--- Checkbox, distributor, value, delete --->
<cfif len(trim(DistributorExceptions)) IS 0>
	<cfquery name="GetDistributorExceptionList" datasource="#application.datasource#">
	SELECT * FROM 
	BB_Auto_Close_Exception
	WHERE Deleted = 0
	</cfquery>	
	<cfset DistributorExceptions = valuelist(GetDistributorExceptionList.Distributor_ID)>
</cfif>
<cfset tmpAutoApproveAmount = GetAutoApproveFromBillbacks.Auto_Approve_Amount />
<cfif NOT isnumeric("#tmpAutoApproveAmount#")><cfset tmpAutoApproveAmount = 0></cfif>
<cfquery name="GetDistributorInformation" datasource="#application.datasource#">
SELECT 	BFC.Name, 
		BFC.Shr_Ship_To, 
		BFC.Ship_To, 
		ISNULL(BBExc.Auto_Close_Amount, #tmpAutoApproveAmount#) AS Auto_Close_Amount, 
		BSA_Foodservice_Customers_ID
FROM BSA_Foodservice_Customers BFC
LEFT JOIN BB_Auto_Close_Exception BBExc ON
	BBExc.Distributor_ID = BFC.BSA_Foodservice_Customers_ID AND
	BBExc.Deleted = 0
WHERE <cfif len(trim(DistributorExceptions)) IS 0>1 = 0<cfelse>BSA_Foodservice_Customers_ID IN (#listqualify(DistributorExceptions, "'")#)</cfif>
ORDER BY BFC.Name
</cfquery>


	
	<tr bgcolor="orange">
		<td style="border-bottom:solid ##93BEE2 1px; "><input type="Checkbox" name="checkall" onclick="selectAll()"></td>
		<td style="border-bottom:solid ##93BEE2 1px;"> 		<strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></strong></td>
		<td style="border-bottom:solid ##93BEE2 1px;" align="right"><strong>Amount</strong></td>
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; <!--- delete ---></td>
	</tr>
	
	<cfoutput query="GetDistributorInformation"  startrow="#StartRow#" maxrows="#MaxRows#">
		<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" >
			<td style="border-bottom:solid ##93BEE2 1px; font-size : 10px;">
				<span ID="checkAllDistributors"><input type="checkbox" name="CheckBox" <cfif Auto_Close_Amount EQ GetAutoApproveFromBillbacks.Auto_Approve_Amount>checked</cfif> value="Amount_#replace(BSA_Foodservice_Customers_ID, "-", "_", "all")#"></span>
			</td>
			<td style="border-bottom:solid ##93BEE2 1px; font-size : 10px;">#Name# (<Cfif len(trim(ship_to)) EQ 0>#Shr_Ship_To#<cfelse>#Ship_To#</CFIF>)</td>
			<td style="border-bottom:solid ##93BEE2 1px; font-size : 10px;" align="right"><input type="text" name="Amount_#replace(BSA_Foodservice_Customers_ID, "-", "_", "all")#" value="#Auto_Close_Amount#" onKeyUp="clenseText(this, '-0123456789');"></td>
			<td style="border-bottom:solid ##93BEE2 1px; font-size : 10px;">&nbsp; </td>
		</tr>
	</cfoutput>

<TR>
	<TD COLSPAN="100%" STYLE="Border-Bottom: none;">
		<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	    <CF_Next_Previous_For_Forms
	    formname="AutoCloseExceptions"
	    query="GetDistributorInformation"
	    maxpages="40"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		firstseries		=	"<IMG SRC=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
		lastseries		=	"<IMG SRC=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"	
	    addparams="">
	   </DIV>
	</TD>
</TR>

	
<!--- save link --->
<tr  style="border-bottom: none;">
<td colspan="2"  style="border-bottom: none;">
	<CF_button
		button_name		=	""
		button_caption	=	"delete checked"
		button_action	=	"deleteChecked()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</td>
<td  align="right" style="border-bottom: none;">
	<CF_button
		button_name		=	""
		button_caption	=	"save"
		button_action	=	"Save()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</td>
<td style="border-bottom: none;">&nbsp; </td>
</tr>
<input type="hidden" name="DistributorExceptions" value="<cfoutput>#DistributorExceptions#</cfoutput>">
<input type="hidden" name="blnSubmit" value="1">
<cfoutput><INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#"></cfoutput>
</form>
</table>
</body>
</html>

<SCRIPT>

function DistributorSearch()
	{
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=AutoCloseExceptions&FieldName=DistributorExceptions&SelectSingleSearchResultOnly=0", "distributorwindow", 850, 600, "yes", "yes")
	}
	
function Save()
	{
		
		AutoCloseExceptions.submit();
	}
	
function deleteChecked()
	{
		document.AutoCloseExceptions.blnSubmit.value = 2;
		AutoCloseExceptions.submit();
	}

function selectAll()
	{
		if(window.checkAllDistributors != null)
		{
			if(checkAllDistributors.length)
				{
					for(var x=0; x<checkAllDistributors.length;x++)
					{
						box = getFirstChild(checkAllDistributors[x])
						box.checked = document.all.checkall.checked
					}
				}
			else
				{
					box = getFirstChild(window.checkAllDistributors)
					box.checked = document.all.checkall.checked					
				}
		}
		
	}


//function to get checkboxes in the rebates dataform	
function MassApply() 
{

	var elem = 'CheckBox';
	var newAmount = document.all.AppliedAmount.value;
	var elemVal = "";
	var elemColctn = document.getElementsByTagName("input");
	var myTextBox = "";
			
    for (var i = 0; i<elemColctn.length; i++) 
	{	
		if ((elemColctn[i].name.indexOf(elem) > -1)) 
		{ 
         	if (elemColctn[i].checked) 
			{	
				myTextBox = document.getElementById(elemColctn[i].value)
				
				if(myTextBox)
				{	
					myTextBox.value = newAmount;
				}
				
           	}//end if
		}//end if
	}//end for
		
	return elemVal;
	
}//end cycleDataForm function

</SCRIPT>
