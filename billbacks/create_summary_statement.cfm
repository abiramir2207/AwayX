<!--- 
/billbacks/summaryReport.cfm
Created By: Brenda Flynn
Created On: October 7, 2009

Expected Parameters:
	*Billback_ID (Billback.Billback_ID)

For RFA+ billbacks

	
Purpose:
This generates a formatted PDF report containing a backup report to be given to the payees to support payments. 
This functionality was developed custom for Solo and can only be accessed with the Appsetting Show_BB_Summary_Statement
from the left side of the billback links.

Document Outline:
1) Set variables and parameters
2) Execute appropriate queries and database calls
3) Establish document location and name
4) Custom stylesheet for the PDF
5) Document information
	-Cfdocument tag
	-Document header
	-Summary information
	-Detailed information
	-Document footer
	
This document should pass back information on where the PDF has been stored.
--->

<!--- 1) Set variables and parameters --->
<cfparam name="Billback_ID"				default="">
<cfparam name="Stripped_BB_Code"		default="">

<cfparam name="TotalClaimCases" 		default=0>
<cfparam name="TotalApprovedCases" 		default=0>
<cfparam name="TotalClaimAmount" 		default=0>
<cfparam name="TotalApprovedAmount" 	default=0>
<cfparam name="TotalVariance" 			default=0>
<!--- Totals --->

<cfset Document_Width="1000">

<!--- Sets variables based on appsetting --->
<cfif application.appSettingsget.getViewProgramVolumeUOM() IS 1>
	<!--- only show cases --->
	<cfset ShowPounds = 0>
</cfif>
<cfif application.appSettingsget.getViewProgramVolumeUOM() IS 2>
	<!--- only show cases --->
	<cfset ShowCases = 0>
</cfif>
<!--- If getViewProgramVolumeUOM is 3 then the defaults are appropriate --->


<!--- 2) Execute appropriate queries and database calls --->
<cfset qSummaryStatementHeader = createObject("component", "components.billback.BillbackDeviationDetailReport").getSummaryStatementHeader(Billback_ID) />
<!--- NOTE: This detail information comes largely from the table:
	BB_Item_Invoice_Level
	
	This table is only populated once deviations have been run. Therefore this may not be populated
	for some RFA programs or for auto pay programs. At this point it is not clear if all enviroments will 
	have this table populated. Please check on these if you are debugging an issue with this report
	not displaying expected information.
	--->
	
<cfset qSummaryStatementDetailNot0 = createObject("component", "components.billback.BillbackDeviationDetailReport").getSummaryStatementDetailNot0(Billback_ID) />
<cfset qSummaryStatementDetail0 = createObject("component", "components.billback.BillbackDeviationDetailReport").getSummaryStatementDetail0(Billback_ID) />
<cfset qGetSummaryStatementPayeeInfo = createObject("component", "components.billback.BillbackDeviationDetailReport").getSummaryStatementPayeeInfo(Billback_ID,qSummaryStatementHeader.Billback_Payee_Type_ID) />
<!--- <cfset qGetSummaryStatementCompanyInfo = createObject("component", "components.billback.BillbackDeviationDetailReport").GetSummaryStatementCompanyInfo() /> --->

<!--- In-page variables --->
<cfset Stripped_BB_Code = replace(qSummaryStatementHeader.bb_code, "-", "", "all")>

<cfset TotalRows = 1> <!--- Add a row per program --->

<!--- 3) Establish document location and name --->

<cfset PDFFileName		= "SummaryStatement_#Stripped_BB_Code#.pdf" />
<cfset PDFLocation = application.Doc_Path & "\Temp_Files\Billback\"  & PDFFileName />
<cfset PDFPath = application.HTTPVar & cgi.SERVER_NAME & "/common_documents/Temp_Files/Billback/" & PDFFileName />

<!--- Check to see if it exists before we go through all this again --->
<cfif NOT FileExists(PDFPath)>

<!---5) Document goes here --->

<CFDOCUMENT FORMAT="PDF"
			FILENAME="#PDFLocation#"	
			OVERWRITE="Yes"
			ORIENTATION="landscape"
			MarginTop="1.55"
			MarginBottom=".75">

<!--- 4) Custom stylesheet for the PDF (must be within cfdocument tags) --->
<style type="text/css">
.larger
{
	font-size: 16px;
	font-family: arial;
}


.normal
{
	font-size: 10px;
	font-family: arial;
	border-bottom: 1px dashed;
}

.normalStrong
{
	font-size: 11px;
	font-family: arial;
	font-decoration: bold;
	text-align: right;
	border-bottom: 2px solid;
	border-top: 2px solid;
	vertical-align: center;
}

.normalStrongLeft
{
	font-size: 11px;
	font-family: arial;
	font-decoration: bold;
	text-align: left;
	border-top: 2px solid;
	border-bottom: 2px solid;
}

.subTotal
{
	font-size: 11px;
	font-family: arial;
	font-decoration: bold;
	text-align: right;
	border-bottom: 2px solid;
	background-color: #cccccc;
}

.totalSubTotal
{
	font-size: 11px;
	font-family: arial;
	font-decoration: bold;
	text-align: left;
	border-bottom: 2px solid;
	background-color: #cccccc;
}

.regular
{
	font-size: 10px;
	font-family: arial;
}

.reallySmall
{
	font-size: 8px;
	font-family: arial;
}

.tiny
{
	font-size: 6px;
	font-family: arial;
}


.strong
{
	font-weight: bold;
	font-size: 10px;
	font-family: arial;
}

.box
{
	border-top: 1px solid;
	border-bottom: 1px solid;
	border-right: 1px solid;
	border-left: 1px solid;
	font-size: 10px;
	font-family: arial;
}

.BigAndStrong
{
	font-weight: bold;
	font-size: 12px;
	font-family: arial;
}

</style>
<!--- HEADER --->
<cfdocumentitem type="header" evalAtPrint="true">


<style type="text/css">
.BigAndStrong
{
	font-weight: bold;
	font-size: 12px;
	font-family: arial;
}

.header
{
	font-size: 10px;
	font-family: arial;
}
.normalStrong
{
	font-size: 11px;
	font-family: arial;
	font-weight: bold;
	text-align: right;
	border-bottom: 2px solid;
	border-top: 2px solid;
	vertical-align: center;
}

.normalStrongLeft
{
	font-size: 11px;
	font-family: arial;
	font-weight: bold;
	text-align: left;
	border-top: 2px solid;
	border-bottom: 2px solid;
}
.regular
{
	font-size: 10px;
	font-family: arial;
}
</style>

<cfif cfdocument.currentpagenumber IS NOT 1>
	<!--- Only displays after first page --->

<cfoutput>
	<table border="0" cellpadding="2" cellspacing="0" width="#Document_Width#">
	<tr>
		<td nowrap valign="top" class="BigAndStrong" style="font-size:20px;">
			Customer Ref ##:<Br>
			Billback ##:<br>
			Start Date:<br>
			End Date:<br>
		</td>
		<td valign="top" class="regular" style="font-size:20px;">
			#qSummaryStatementHeader.BB_Reference#<br>
			#qSummaryStatementHeader.BB_Code#<br>
			#dateformat(qSummaryStatementHeader.BB_Start_Date, 'mm/dd/yyyy')#<br>
			#dateformat(qSummaryStatementHeader.BB_End_Date, 'mm/dd/yyyy')#
		</td>
		<td width="70%">&nbsp;</td>
		<cfif len(trim(qSummaryStatementHeader.Check_Number)) GT 0>
		<td valign="top" class="BigAndStrong" nowrap style="font-size:20px;">
			Credit Memo ##:<br>
			Credit Memo Date:<br>
			Amount:
		</td>
		<td class="regular" nowrap style="font-size:20px;">
			#qSummaryStatementHeader.Check_Number#<br>
			#dateformat(qSummaryStatementHeader.Check_Date)#<br>
			#lscurrencyformat(qSummaryStatementHeader.Check_Amount)#
		</td>
		<cfelse>
		<td class="regular" colspan="2" nowrap valign="top" style="font-size:20px;">
			No payment data available
		</td>
		</cfif>
	</tr>
	</table>
	<table  width="#Document_Width#" border="0" cellpadding="3" cellspacing="0">
	<tr>
		<td class="normalStrongLeft" nowrap>Line&nbsp;##</td>
		<td class="normalStrongLeft" width="100" nowrap>Program&nbsp;Info</td>
		<td class="normalStrongLeft" width="75" nowrap>Item&nbsp;Number</td>
		<td class="normalStrong" nowrap width="60" >Approved<Br>Rate</td>
		<td class="normalStrong" nowrap width="50">Claim<Br>Rate</td>
		<td class="normalStrong" nowrap  width="60">Approved<Br>Cases</td>
		<td class="normalStrong" nowrap width="50">Claim<Br>Cases</td>
		<td class="normalStrong" nowrap>Approved<Br>Invoice Price</td>
		<td class="normalStrong" nowrap>Claim<Br>Invoice Price</td>
		<td class="normalStrong" nowrap>Approved<Br>Contract Price</td>
		<td class="normalStrong" nowrap>Claim<Br>Contract Price</td>		
		<td class="normalStrong" nowrap>Approved<Br>Amount</td>		
		<td class="normalStrong" nowrap>Claim<Br>Amount</td>
		<td class="normalStrong" nowrap>Variance</td>
		<td class="normalStrong" nowrap>Deviation</td>
	</tr>
</table>
</cfoutput>
<cfelse>
<cfoutput>
<!--- First page header --->
	<table border="0"  width="100%">
	<tr><td colspan="5">&nbsp;</td>
		<td><img src="file:///#ExpandPath(application.appSettingsget.getletterscompanylogopath())#"></td>
	</tr>
	<tr>
		<td valign="top" class="BigAndStrong" nowrap style="font-size:20px;">Customer: &nbsp;&nbsp;&nbsp;</td>
		<td nowrap class="regular" style="font-size:20px;">
			#qGetSummaryStatementPayeeInfo.Payee_Number#<br>
			#qGetSummaryStatementPayeeInfo.Payee_Name#<br>
			#qGetSummaryStatementPayeeInfo.Address1#<br>
			<cfif len(trim(qGetSummaryStatementPayeeInfo.Address2)) GT 0>#qGetSummaryStatementPayeeInfo.Address2#<br></cfif>
			#qGetSummaryStatementPayeeInfo.City# #qGetSummaryStatementPayeeInfo.State#, #qGetSummaryStatementPayeeInfo.PostalCode#
		</td>
		<!---Spacer --->
		<td width="100%" colspan="3">&nbsp;</td>
		<td valign="top" nowrap colspan="2" class="regular" style="font-size:20px;">
			#application.appSettingsget.getLettersAddress()#
		</td>
	</tr>
	
	<tr>
		<td nowrap valign="top" class="BigAndStrong" style="font-size:20px;">
			Customer Ref ##:<Br>
			Billback ##:<br>
			
		</td>
		<td valign="top" class="regular" style="font-size:20px;">
			#qSummaryStatementHeader.BB_Reference#<br>
			#qSummaryStatementHeader.BB_Code#<br>
		</td>
		
		
		<td nowrap valign="top" class="BigAndStrong" style="font-size:20px;">Start&nbsp;Date:<br>
			End Date:<br></td>
		<td class="regular" valign="top" style="font-size:20px;">#dateformat(qSummaryStatementHeader.BB_Start_Date, 'mm/dd/yyyy')#<br>
			#dateformat(qSummaryStatementHeader.BB_End_Date, 'mm/dd/yyyy')#</td>
			<td width="70%">&nbsp;</td>
		<cfif len(trim(qSummaryStatementHeader.Check_Number)) GT 0>
			<td valign="top" class="BigAndStrong" nowrap style="font-size:20px;">
				Credit Memo ##:<br>
				Credit Memo Date:<br>
				Amount:
			</td>
			<td class="regular" nowrap style="font-size:20px;">
				#qSummaryStatementHeader.Check_Number#<br>
				#dateformat(qSummaryStatementHeader.Check_Date)#<br>
				#lscurrencyformat(qSummaryStatementHeader.Check_Amount)#
			</td>
		<cfelse>
			<td class="regular" nowrap colspan="2" style="font-size:20px;">No payment data available</td>
		</cfif>
	</tr>
</table>
</cfoutput>
<!--- First page or not --->
</cfif>
</cfdocumentitem> 
<!--- No header for this file --->
<cfoutput>

<!--- Body information ---->

<table  width="#Document_Width#" border="0"  cellpadding="3" cellspacing="0">
	<tr>
		<td class="normalStrongLeft" nowrap>Line&nbsp;##</td>
		<td class="normalStrongLeft" width="100" nowrap>Program&nbsp;Info</td>
		<td class="normalStrongLeft" width="75" nowrap>Item&nbsp;Number</td>
		<td class="normalStrong" width="60" nowrap>Approved<Br>Rate</td>
		<td class="normalStrong" width="50" nowrap>Claim<Br>Rate</td>
		<td class="normalStrong" width="60" nowrap>Approved<Br>Cases</td>
		<td class="normalStrong" width="50" nowrap>Claim<Br>Cases</td>
		<td class="normalStrong" nowrap>Approved<Br>Invoice Price</td>
		<td class="normalStrong" nowrap>Claim<Br>Invoice Price</td>
		<td class="normalStrong" nowrap>Approved<Br>Contract Price</td>
		<td class="normalStrong" nowrap>Claim<Br>Contract Price</td>
		<td class="normalStrong" nowrap>Approved<Br>Amount</td>		
		<td class="normalStrong" nowrap>Claim<Br>Amount</td>
		<td class="normalStrong" nowrap>Variance</td>
		<td class="normalStrong" nowrap>Deviation</td>

	</tr>
	<!--- Make sure totals are set to 0 --->
	<cfset TotalClaimCases 		= 0>
	<cfset TotalApprovedCases 	= 0>
	<cfset TotalClaimAmount 	= 0>
	<cfset TotalApprovedAmount 	= 0>
	<cfset TotalVariance 		= 0>
	
	<!--- First loop through the non-zero values --->
	<tr><td colspan="15" class="normalStrongLeft"><strong>Authorized</strong></td></tr>
	<cfloop query ="qSummaryStatementDetailNot0">
	<tr>
		<td class="normal">#qSummaryStatementDetailNot0.CurrentRow#</td>
		<td class="normal">#Contract_Number# - <br>#Operator_Name# #Operator_Number#</td>
		<td class="normal"><cfif len(trim(Item)) GT 0>#Item#<cfelse>#Invalid_Product#</cfif></td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Rate)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Rate)#</td>
		<td class="normal" align="right">#numberformat(Approved_CS)#</td>
		<td class="normal" align="right">#numberformat(Claim_CS)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Invoice_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Invoice_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Contract_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Contract_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Amount)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Amount)#</td>
		<td class="normal" align="right">#lscurrencyformat(Variation)#</td>
		<td class="normal" align="center"><cfif Variation NEQ 0><cfinclude template="/billbacks/Find_Deviation_Type.cfm"></cfif>&nbsp;</td>
	</tr>
	
	<cfset TotalClaimCases 		= TotalClaimCases + Claim_CS>
	<cfset TotalApprovedCases 	= TotalApprovedCases + Approved_CS>
	<cfset TotalClaimAmount 	= TotalClaimAmount + Claim_Amount>
	<cfset TotalApprovedAmount 	= TotalApprovedAmount + Approved_Amount>
	<cfset TotalVariance 		= TotalVariance + Variation>
	</cfloop>
	
	<tr><td colspan="15" class="normalStrongLeft"><strong>Rejected</strong></td></tr>
	<cfloop query ="qSummaryStatementDetail0">
	<tr>
		<td class="normal">#qSummaryStatementDetail0.CurrentRow#</td>
		<td class="normal">#Contract_Number# - <br>#Operator_Name# #Operator_Number#</td>
		<td class="normal"><cfif len(trim(Item)) GT 0>#Item#<cfelse>#Invalid_Product#</cfif></td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Rate)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Rate)#</td>
		<td class="normal" align="right">#numberformat(Approved_CS)#</td>
		<td class="normal" align="right">#numberformat(Claim_CS)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Invoice_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Invoice_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Contract_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Contract_Price)#</td>
		<td class="normal" align="right">#lscurrencyformat(Approved_Amount)#</td>
		<td class="normal" align="right">#lscurrencyformat(Claim_Amount)#</td>
		<td class="normal" align="right">#lscurrencyformat(Variation)#</td>
		<!--- This includes logic to find out why the item deviated --->
		<td class="normal" align="center"><cfif Variation NEQ 0><cfinclude template="/billbacks/Find_Deviation_Type.cfm"></cfif>&nbsp;</td>
	</tr>
	
	<cfset TotalClaimCases 		= TotalClaimCases + Claim_CS>
	<cfset TotalApprovedCases 	= TotalApprovedCases + Approved_CS>
	<cfset TotalClaimAmount 	= TotalClaimAmount + Claim_Amount>
	<cfset TotalApprovedAmount 	= TotalApprovedAmount + Approved_Amount>
	<cfset TotalVariance 		= TotalVariance + Variation>
	</cfloop>
	
	<tr>
		<td class="totalSubTotal">TOTALS:</td>
		<td class="subTotal">&nbsp;</td>
		<td class="subTotal">&nbsp;</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">#numberformat(TotalApprovedCases)#</td>
		<td class="subTotal" align="right">#numberformat(TotalClaimCases)#</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">&nbsp;</td>
		<td class="subTotal" align="right">#lscurrencyformat(TotalApprovedAmount)#</td>
		<td class="subTotal" align="right">#lscurrencyformat(TotalClaimAmount)#</td>
		<td class="subTotal" align="right">#lscurrencyformat(TotalVariance)#</td>
		<td class="subTotal">&nbsp;</td>
	</tr>
	
</table>

<!--- End Body Information --->


</cfoutput>
	

<!--- Footer --->
<cfdocumentitem type="footer">
<style>
.ProvidedBy
{
	background-color: #cccccc;
	font-size: 14px;
	font-family: arial;
	border-top: 2px solid;
}

.regular
{
	font-size: 12px;
	font-family: arial;
}


</style>
<cfoutput>
	<table border="0" cellpadding="2" cellspacing="0" class="regular" width="900">
		<tr>
			<td nowrap>1 - Distributor Not Authorized</td>
			<td nowrap>2 - Unauthorized Product</td>
			<td nowrap>3 - Claim Outside Program Period</td>
			<td nowrap>4 - Overlapping Claim</td>
			<td nowrap>5 - Volume</td>
			<td nowrap>6 - Rate</td>
			<td nowrap>7 - Invoice Price less than Contract</td>
		</tr>
	</table>
	<p></p>
	<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<!--- Provided by --->
	<tr>
		<td colspan="3" class="ProvidedBy" align="center">
			Provided by Blacksmith Applications FORGE Suite
		</td>
	</tr>
	
	<!--- Basic info --->
	<tr class="regular">
		<td width="200" class="footer" align="left" >
			#Dateformat(now(), 'mmm dd, yyyy')#
		</td>
		<td  class="regular" align="center" >
			#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#
		</td>
		<td width="200" class="regular" align="right">
			#application.returned_customer_setting.Company_Name#
		</td>
		
	</tr>

	</table>
</cfoutput>
 </cfdocumentitem >

</CFDOCUMENT>

<!--- Check to see if it exists before we go through all this again --->
</cfif>
 <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset vars.bb_statement_type = appSettings.getBillBack_Statement_Type() />
<cfif vars.bb_statement_type eq "pdf-v2">
	<fieldset id="mainfieldset" style="padding:10px; border:1px solid blue;">
	  <legend style="font: bold 14px sans-serif; color: red;">Summary Statement</legend>
	
	<div style="text-align:center; margin:30px; font-size:10pt;">
	Your statement has been generated.&nbsp;&nbsp;&nbsp;Please choose one of these options.
	</div>
	
	<cfoutput>
	<div style="text-align:center; margin:30px;">
	 <a href="#PDFPath#">#actionLinkFormat("download")#</a>
	 <a href="email_statement.cfm?attachments=#PDFPath#&billback_id=#billback_id#" style="margin:0 20px;">#actionLinkFormat("email")#</a>
	 <a href="javascript:window.close()">#actionLinkFormat("cancel")#</a>
	</div>
	</cfoutput>
	</fieldset>
</cfif>



<cffunction name="actionLinkFormat" access="public" returntype="string" output="false">
	<cfargument name="action" type="string" required="true" />
	<cfargument name="style" type="string" required="false" default="classic"/>
	
	<cfscript>
		switch (arguments.style) {
			case "classic": 
				return "<b><font color='red'>[ </font>" & arguments.action & " <font color='red'> ]</font></b>"; break;
			default: 
				return arguments.action;
		}
	</cfscript>
</cffunction>