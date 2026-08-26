<!-----------------------------------------------------------------------------

FILE NAME:		EZ_Rates.cfm
DESCRIPTION:	Display the various versions of the Program with their statuses.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	05-Jan-2015		Select the various versions of the Program
							and offer a download link on each.

------------------------------------------------------------------------------> 
 
<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<cfset URL.Contract_Main_ID = cryp.value>
<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init() />
<cfset programInfo =  programManager.getProgramInfoComplete(URL.Contract_Main_ID) />
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
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 11px;}
	
	#Summary {border-top:double solid #93BEE2;border-bottom:double solid #93BEE2; font-size : 12px; color: black; font-weight : bold;}
	#header {font-size: 12px; color: black;}
</STYLE>

	<table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td colspan="100%" bgcolor="">
				<DIV STYLE="font: 20px serif; font-weight: bold; color: red; font-family: Times New Roman"> EZ Rates Report</DIV>
				<cfoutput><B><font size="+1" color="Navy">[#programInfo.Program_Number#] - #programInfo.Contract_Title#</FONT></B></cfoutput>
			</td>
		</tr>
	</table>
	<br>

	<cfset lstContractVersions = programManager.getContractVersions(URL.Contract_Main_ID) />
	
	<table width="100%" cellpadding="2" cellspacing="0" border="0" class="maintable">
		<tr style="vertical-align:bottom;">
		<td bgcolor="orange" ID="header"><strong>No.</strong></td>
		<td bgcolor="orange" ID="header"><strong>Program No.</strong></td>
		<td bgcolor="orange" ID="header"><strong>Status</strong></td>
		<td bgcolor="orange" ID="header"><strong>Approved By</strong></td>
		<td bgcolor="orange" ID="header"><strong>Profile Name</strong></td>
		<td bgcolor="orange" ID="header"><strong>Approved Date</strong></td>
		<td bgcolor="orange" ID="header"> &nbsp; </td>
		</tr>
		<tr>
			<td colspan="100%"><hr width="100%" color="navy"></td>
		</tr>

		<cfoutput query="lstContractVersions">
			<CF_CRYP type="en" string="#lstContractVersions.Contract_Main_ID#" key="#request.key#" return="Enc">
			<cfset EncryptedCID = Enc.value>
			<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<td><strong>#CurrentRow#.</strong></td>
				<td><cfif lstContractVersions.Contract_Status_Type_IDX EQ 2>#lstContractVersions.Program_Number#<cfelse>#lstContractVersions.Program_Number_Full#</cfif></td>
				<td>#lstContractVersions.Contract_Status_Type_Desc#</td>
				<td>#lstContractVersions.Approved_user#&nbsp;</td>
				<td>#lstContractVersions.Profiles_Desc#&nbsp;</td>
				<td>#Dateformat(Approval_Date, "mm/dd/yyyy")#&nbsp;</td>
		 		<td>
					<a href="##" onclick="javascript:window.open('EzRatesDownload.cfm?CID=#EncryptedCID#','Generate_Report','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Generate Report")#</a>
				</td>
			</tr>
		</cfoutput>
	</table>
	<br>
	<div style="text-align:center;"><input type="button" onclick="javascript:window.close();" value="Close Window"></div>
 </body>
 </html>