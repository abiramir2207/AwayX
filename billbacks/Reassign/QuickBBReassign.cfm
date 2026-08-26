<!-----------------------------------------------------------------------------

FILE NAME:		QuickBBReassign.cfm
DESCRIPTION:	This is a component file for returning creating all the drop downs
              and returns the data for populating the datagrid in the search
              page.	
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
*******************************************************************************
<Add any modifications to this file here>
*******************************************************************************
 
------------------------------------------------------------------------------>


<cfparam name="FORM.Billback_ID" 		default="">
<cfparam name="FORM.Src_Analyst" 		default="">
<cfparam name="FORM.Tar_Analyst" 		default="">
<cfparam name="FORM.Src_Status" 		default="">
<cfparam name="FORM.Distributor_ID"		default="">
<cfparam name="FORM.Operator_ID" 		default="">
<cfparam name="FORM.Distributor_List"		default="">
<cfparam name="FORM.Operator_List" 		default="">
<cfparam name="FORM.Vendor_ID" 		default="">
<cfparam name="FORM.VendorID" 		default="">
<cfparam name="Selected_Distributor" 		default="">
<cfparam name="Selected_Operator" 		default="">
<cfparam name="Selected_Vendor" 		default="">
<cfparam name="FORM.Distributor_Status"	default="A">
<cfparam name="FORM.Operator_Status"	default="A">
<cfparam name="FORM.Vendor_Status" 		default="A">
<cfparam name="FORM.Payable_Number" 	default="">
<cfparam name="FORM.payable_list" 	default="">  
<cfparam name="FORM.pageOrigin" 	default="BB_Reassign"> 

<cfif ((FORM.pageOrigin EQ "BB_Reassign") OR (isDefined("URL.BBIDs") AND URL.BBIDs NEQ ""))>
	<cfset FORM.Billback_ID = URL.BBIDs />
</cfif>

<cfinclude template="/helpsystem/help_link.cfm">

<form name="BB_Reassign" ACTION="BB_Reassign_Action.cfm" METHOD="Post">
    <cfoutput>
		<input type="Hidden" value="#FORM.Billback_ID#" name="Billback_ID">
		<input type="Hidden" value="#FORM.Billback_ID#" name="Selected_Billback_ID">
		
    </cfoutput>

<table border="0" cellpadding="0" cellspacing="0" width="100%" aligh="center">
	<tr>
		<td><font color="navy" size="3"><B>Reassign Billback</B></FONT><HR COLOR="Orange"></td>
	</tr>
	
	<cfif FORM.Billback_ID NEQ "">
			
		<cfquery name="Get_Analyst" datasource="#Application.Datasource#">
			SELECT 		Analyst_User_ID,
						Name_First,
						Name_Last
			FROM 		BB_Analyst
						INNER JOIN _Users ON _Users.User_ID = BB_Analyst.Analyst_User_ID
			WHERE 		BB_Analyst.Deleted=0
			AND			_Users.Deleted=0
			ORDER BY	_Users.Name_First,_Users.Name_Last
		</CFQUERY>
		<cfset Selected_Items = ListQualify(FORM.Billback_ID,"'",",","All")>
			
		<cfquery name="GetBillbackInts" datasource="#Application.Datasource#">
			SELECT	Billback_ID_Int
			FROM	Billback       
			WHERE	Billback_ID IN (#PreserveSingleQuotes(Selected_Items)#)
		</cfquery>
		
				<cfset GetBillbacks = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager").getBillbackHeaderData(userId = request.AccessStructure.User_ID, profiles_Id = request.AccessStructure.profiles_Id, timeZoneDiff = request.AccessStructure.timeZoneOffSet, billbackIdIntList = valueList(GetBillbackInts.Billback_ID_Int), includeAllStatus = "true") />
			<tr bgcolor="C6FFC6" height="30">
				<td>
					<table width="100%" border="0">
					<tr bgcolor="ffce84">
						<td><B>Payable #</B></td>
						<td><B>Status</B></td>
						<td><B>Date<BR>Billback #</B></td>
						<td><B>Payee<BR>Title</B></td>
						<td><B>Start Date<BR>End Date</B></td>
						<td><B>$ Amount</B></td>
						<td align="Center"><b>Target Analyst</b></td>
					</TR>
					<cfoutput query="GetBillbacks">
					<tr bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<td><B>[ #BB_Code# ]</B></td>
						<td>#BB_Status_Abbreviation#</td>
						<td>#DateFormat(BB_Date, "mm/dd/yyyy")#<BR>#BB_Code#</td>
						<td>#Payee#<BR>#BB_Title#</td>
						<td>#DateFormat(BB_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(BB_End_Date,"mm/dd/yyyy")#</td>
						<td>#DollarFormat(BB_Amount)#</td>
						<td>
							<B>Pick Analyst to Reassign:</B>&nbsp;&nbsp;
							<select name="Tar_Analyst" style="width:150px;">
								<cfloop query="Get_Analyst">
									<option value="#Analyst_User_ID#" <cfif FORM.Tar_Analyst EQ Analyst_User_ID>selected</cfif>>#Name_First# #Name_Last#</option>
								</cfloop>
							</select>
						</td>
						</tr>
					</cfoutput>											
					</table>																		
				<td>
			</tr>	
<cfelse>	
	<tr>
		<b>No billback found for reassigning!!</b>
	</tr>
</cfif>	
</table>
	<cfif FORM.Billback_ID NEQ ""><br>
	<br>
	
	<div align="center">
		<CF_button
			button_name		=	""
			button_caption	=	"Reassign Billback"
			button_action	=	"Validate()"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold">
	</div>								
</cfif>
		<input type="hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#Form.Distributor_list#">
		<input type="hidden" ID="Vend_ID" NAME="Vend_ID" VALUE="#Form.Vendor_ID#">
		<input type="hidden" ID="Operator_List" NAME="Operator_List" VALUE="#Form.Operator_list#">
		<input type="hidden" name="payable_list" value="#form.payable_list#">
		<input type="hidden" name="pageOrigin" value="BillbackPage">
</form>	
<script>
function Validate()
{
	var Submit_OK=1;
	var x=document.BB_Reassign;
	if (x.Tar_Analyst.value == "")
	{
		alert("Please select a 'Target' analyst.");
		Submit_OK=0;
		x.Tar_Analyst.focus();
		return;
	}
	if(Submit_OK)
	{
		x.action="BB_Reassign_Action.cfm";
		x.submit();
	}
}

</script>
</script>
