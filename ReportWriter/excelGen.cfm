<html>
<head>
	<cfcontent type="application/msexcel">
	<cfheader name="Content-Disposition" value="attachment;filename=excelGen.xls">
	<cfparam name="headerHeight" default="25">
	<!---<link type="text/css" rel="stylesheet" href="excelGen.css">--->
	<cfinclude template="/reportWriter/excelGen.css">
</head>
<body bgcolor="#99CCCC">
	<cfoutput>	

		<!-- retrieve claim product list --->
		<cfset excelGenObj = createobject('component', 'components.reports.ExcelGen').init(#form.claimStatus#) />
		<cfset excelGenHeader = excelGenObj.getReportHeader() />
		<cfset claimProductDetailQry = excelGenObj.getClaimDetail() />
		<div align="center" class="claimCaption" style="width:255%">#excelGenObj.getReportCaption()#</div>
		<table cellpadding="0" cellspacing="0" border="0" width="255%" class="Maintable">
			<thead>
				<tr class="claimSummaryHeader">
					<cfloop list="#excelGenHeader#" index="thisColumnName" delimiters=",">
						<td nowrap>#thisColumnName#</td>
					</cfloop>
				</tr>
			</thead>
			<tbody>
				<cfloop query="claimProductDetailQry">
					<tr class="claimSummaryData">
						<cfloop list="#excelGenObj.getMappedReportHeader()#" index="mappedColumn">
						<td nowrap>
						<cfif IsDate(Evaluate(mappedColumn))>
							#DateFormat(Evaluate(mappedColumn), "mm/dd/yyyy")#
						<cfelseif IsNumeric(Evaluate(mappedColumn))>
							#NumberFormat(Evaluate(mappedColumn),'_____.__')#
						<cfelse>
							<cfif len(Evaluate(mappedColumn)) GT 100>
								#left(Evaluate(mappedColumn),100)#
							<cfelse>
								#Evaluate(mappedColumn)#
							</cfif>
						</cfif>
						</td>
						</cfloop>
					</tr>
				</cfloop>
				<!--- lump sum if any --->
				<!--- growth if any --->
			</tbody>
			<tfoot>
				<tr>
					<cfloop list="#excelGenObj.getMappedReportHeader()#" index="mappedColumn">
						<td style="border-bottom:1px solid Gray;border-right:1px solid Gray;">&nbsp;</td>
					</cfloop>
				</tr>
			</tfoot>
		</table>
	</cfoutput>
</body>
</html>
