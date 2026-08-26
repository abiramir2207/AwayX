<html>
<head>
<title>Claim Excel Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<body bgcolor="#CCCCFF">
	<br>
	<cfset crManagerObj = createobject('component', 'components.reports.claimReportManager').init() />
	<cfset claimStatusQry = crManagerObj.getClaimReportProgramStatus() />
<!--- pop up a dialogue window to confirm which claim status need to export to excel spreadsheet --->
	<form name="excelGenFrm" action="excelGen.cfm" method="post">
		<div align="center">
			<table>
				<tr align="left">
					<td><basefont face="Times New Roman, Times, serif" color="#0033FF" size="3"><b>Select Claim Status:</b></basefont></td>
				</tr>
				<tr align="left">
					<td>
						<cfparam name="Status_Default" default="5">
						<select name="claimStatus" id="claimStatus" onKeyUp="javascript:excelGenFrm.submit()" multiple>
							<cfloop query="claimStatusQry">
								<cfoutput><option id="#Billback_Status_ID#" value="#Billback_Status_ID#" <cfif Not isDefined("form.claimStatus") and Billback_Status_ID EQ Status_Default >selected</cfif>>#BB_Status_Description#</option></cfoutput>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>
						<CF_BUTTON
							BUTTON_NAME		=	""
							BUTTON_CAPTION	=	"Generate Excel"
							BUTTON_ACTION	=	"javascript:var  answer = confirm('This may take some time. Do you want to continue?');
												if (answer == false) return false; else excelGenFrm.submit();"		
							BUTTON_TYPE		=	"javascript_link"
							BUTTON_WIDTH	=	"150"
							BUTTON_COLOR	=	"Navy"
							BUTTON_TIP		=	""
							FONT_COLOR		=	"White"
							FONT_SIZE		=	"10"
							FONT_WEIGHT		=	"bold">
					</td>
				</tr>
			</table>
		</div>
	</form>
<!--- retrieve recordset for the required format data ---->
<!--- loop through reords and insert into the file --->

</body>
</html>
