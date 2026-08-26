<!-----------------------------------------------------------------------------

FILE NAME:		ResetOrDelete.cfm
DESCRIPTION:	This file will get the iAction parameter and decide whether to 
reset or Delete based on it.
CREATED BY:		Anand Rao - 9-Dec-2008

MODIFIED BY:	Milan Mushran - 3/6/2017
DESCRIPTION:	Allow delete/reset of multiple billbacks. Earlier it was for a single billback at a time. 
				Allow billbacks in any status. Earlier it was for approved or higher status.
				Allow deleting of Auto Billbacks.
				Do not Allow reset of  Auto Billbacks.
------------------------------------------------------------------------------> 
<cfparam name="FORM.txtSearchBB" default="">
<cfif ((NOT isDefined("URL.iAction"))OR (isDefined("URL.iAction") AND URL.iAction EQ "")) >
	<font size="3px" color="red">
		Required Parameter Missing...
	</font>
	<cfabort>
</cfif>

<cfif URL.iAction EQ 1>
	<cfset PAGETITLE = "Reset billbacks"  />
<cfelseif URL.iAction EQ 2>
 	<cfset PAGETITLE = "Delete billbacks"  />
</cfif>
 
<html>
<head>
	<title><cfoutput>::#PAGETITLE#::</cfoutput></title>
	<style>
		TABLE.Maintable TD 
		{
			border-bottom:solid #93BEE2 1px; font-size : 10px;
		}
		#header 
		{
			font-size: 12px;
			font-weight:Bold;
		}
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
	<script language="javascript">
	function selectAll(thisObj, objToChk)
	{
		var chObjs = eval("document.all." + objToChk);
		var bCheck = thisObj.checked;
		var i;
		if(chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}
	}
	function fnResetDeleteSubmit(formObj)
	{
		formObj.submit();
	}
	</script>
</head>
<body bgcolor="Whitesmoke" text="Black" link="Blue" vlink="Blue" alink="Red">
	<cfif URL.iAction EQ 1>
		<cfset formName = "frmReset" />
		<cfset strAction = "Reset" />
		<cfset strAction2 = "Reset" />
	<cfelseif URL.iAction EQ 2>
		<cfset formName = "frmDelete" />
		<cfset strAction = "Delete" />
		<cfset strAction2 = "Deleted" />
	</cfif>
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>
<cfset thisPage = "ResetOrDelete.cfm?iAction=#URL.iAction#">
<cfset billbackSearch = CreateObject("component", "components.billback.BillbackSearch") />
<cfset billbackManager = CreateObject("component", "components.billback.BillbackManager") />
<cfif isDefined("FORM.chkBBRow") AND FORM.chkBBRow NEQ "">
	<cfif isDefined("FORM.performAction")>
		<cfset iCounter = 0 />
		<cfloop from="1" to="#ListLen(FORM.chkBBRow)#" index="indxBB">
			<cfset variables.Billback_ID	= 	Replace(ListGetAt(FORM.chkBBRow,indxBB),"_","-","ALL") />
 			<cfset variables.User_ID = 			request.AccessStructure.User_ID />
			<cfif FORM.performAction EQ 1>
				<cfset IsBBApproved = 0>
				<cfset useLakebaseForGetBBInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
				<cfif useLakebaseForGetBBInfo>
					<cftry>
						<cfset GetBBInfo = application.oLakebase.toQuery(
							application.oLakebase.selectRows("billback", {
								"select" = "billback_status_id",
								"billback_id" = "eq.#variables.Billback_ID#"
							}),
							"billback_status_id"
						)>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForGetBBInfo = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForGetBBInfo>
				<cfquery name="GetBBInfo" datasource="#application.datasource#">
					SELECT billback_status_id
					FROM Billback
					WHERE Billback_ID = '#variables.Billback_ID#'
				</cfquery>
				</cfif>

				<cfif GetBBInfo.billback_status_id GTE 3>
					<cfset IsBBApproved = 1>
				</cfif>

				<cfset billbackManager.resetBillback(variables.Billback_ID,variables.User_ID,IsBBApproved,0) />
			<cfelseif FORM.performAction EQ 2>
				<cfset billbackManager.deleteBillback(variables.Billback_ID,variables.User_ID) />
			</cfif>
			<cfset iCounter = iCounter + 1 />	
		</cfloop>
		
		<font size="2px" color="red">
			&nbsp;&nbsp;&nbsp; #iCounter# Billback<cfif iCounter EQ 1> was<cfelse>s were</cfif> #strAction2#.<br><br>
		</font>
	</cfif>
	
	<!--- after Deleteing/Resetting the Billbacks remove the search criteria --->
	<cfset FORM.txtSearchBB = "" />
	<cfset FORM.chkBBRow 	= "" />
</cfif>

<cfif isDefined("FORM.txtSearchBB") AND  FORM.txtSearchBB NEQ "">
	<!--- <cfset searchCriteria = ListChangeDelims(FORM.txtSearchBB, "#chr(13)##chr(10)#", ",")>--->
	<!--- Replace "new line" character with comma.
	Note: We can also use "\r\n" instead of "#chr(13)##chr(10)#".
	--->
	<cfset searchCriteria = Replace(FORM.txtSearchBB, "#chr(13)##chr(10)#", ",", "all")>
	<cfset qryBBResult = billbackSearch.BBSearchByBBCode("#searchCriteria#",request.AccessStructure.User_ID,URL.iAction) />
</cfif>

<!--- Reset/Delete an Approved Billback --->
	<form action="#thisPage#" method="post" name="#formName#" style="display:inline;">
		<br>
		<table border="0">
			<tr>
				<td valign="top"><strong>&nbsp;&nbsp;&nbsp;Search Billbacks:<img src="/images/help_small.gif"
				Title="Enter one or multiple Billback Codes to do a Search. Enter each billback in a new line."/></strong>
				<br />
				<textarea name="txtSearchBB" cols="20" rows="5">#FORM.txtSearchBB#</textarea></td>
				<td valign="bottom"><input type="submit" value="Search" /></td>
			</tr>
		</table>

		<cfif (isDefined("qryBBResult") AND qryBBResult.RecordCount GTE 1)><br>
			<br>
			<font size="2px">
				&nbsp;&nbsp;&nbsp;The below Billbacks match your search criteria.  Pick the Billbacks that needs to be #strAction2#:<br><br>
			</font>
				
			<table border="0" CLASS="Maintable" WIDTH="750" align="center" CELLPADDING="1" CELLSPACING="0"> 
				<tr BGCOLOR= "00ff66" >
					<td><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'chkBBRow');"></td>
					<td ID="header">Payable ##</td>
					<td ID="header">Billback ##</td>
					<td ID="header">Title</td>
					<td ID="header">Date</td>
					<td ID="header">$Amount</td>
					<td ID="header">Start Date</td>
					<td ID="header">End Date</td>
				</tr>
				<cfloop query="qryBBResult">
				<cfset TRBGColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))>
					<tr bgcolor="#TRBGColor#">
						<td><INPUT TYPE="checkbox" NAME="chkBBRow" value="#Replace(qryBBResult.Billback_ID,'-','_','ALL')#"></td>
						<td>#qryBBResult.BB_Code#&nbsp;</td>
						<td>#qryBBResult.BB_Reference#&nbsp;</td>
						<td>#qryBBResult.BB_Title#&nbsp;</td>
						<td>#DateFormat(qryBBResult.BB_Date,"MM/DD/YYYY")#&nbsp;</td>
						<td>#qryBBResult.BB_Amount#&nbsp;</td>
						<td>#DateFormat(qryBBResult.BB_Start_Date,"MM/DD/YYYY")#&nbsp;</td>
						<td>#DateFormat(qryBBResult.BB_End_Date,"MM/DD/YYYY")#&nbsp;</td>
					</tr>
				</cfloop>	
			</table><br>
				
			<table>
				<tr>
					<td>&nbsp;</td>
	 				<td>
						<CF_button
						button_name		=	""
						button_caption	=	"#strAction# selected Billbacks"
						button_action	=	"fnResetDeleteSubmit(#formName#);"
						button_type		=	"javascript_link"
						button_width	=	"150"
						button_color	=	"Navy"
						button_tip		=	"Save"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						>	
					</td>
				</tr>
			</table>
		<cfelseif ((isDefined("qryBBResult"))  AND (qryBBResult.RecordCount EQ 0))><br>
		<br>
		<font size="2px" color="red">
			<strong>Your Search did not return any results.  Please try again.</strong>
		</font>
		</cfif>

	 	<input type="hidden" name="performAction" value="#URL.iAction#" />
	</form>
</cfoutput>
