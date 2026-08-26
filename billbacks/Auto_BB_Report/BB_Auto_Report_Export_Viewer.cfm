<!--- Report Export View --->
<cfparam name="URL.BB_ID" default="0" />
<cfparam name="URL.PP_ID" default="0" />
<cfset appSettings = application.appSettingsGet>
<cfset qExportBBDetails = application.oBBReportGet.getExportBBDetails(URL.Report,URL.BB_ID,URL.PP_ID) />
<cfset qExportPullDetails = application.oBBReportGet.getExportPullDetails(URL.Report,URL.BB_ID,URL.PP_ID) />

<cfset qExportBBLabels = application.oBBReportGet.getExportBBLabels() />
<cfset qExportBBLabelsColumnList = valueList(qExportBBLabels.DB_Col_Name) >

<cfset qExportPullLabels = application.oBBReportGet.getExportPullLabels() />
<cfset qExportPullLabelsColumnList = valueList(qExportPullLabels.DB_Col_Name) >

<cfset useLakebaseForqExportBBDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qexportbbdetails")>
<cfif useLakebaseForqExportBBDetails>
	<cftry>
		<cfset qExportBBDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qexportbbdetails", {
				"select" = "#qexportbblabelscolumnlist#,unit_of_measure_desc"
			}), "#qexportbblabelscolumnlist#,unit_of_measure_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqExportBBDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqExportBBDetails>
<cfquery name="qExportBBDetails" dbtype="query">
	SELECT #qExportBBLabelsColumnList#,Unit_Of_Measure_Desc
	FROM qExportBBDetails
</cfquery>
</cfif>

<cfset useLakebaseForqExportPullDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qexportpulldetails")>
<cfif useLakebaseForqExportPullDetails>
	<cftry>
		<cfset qExportPullDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qexportpulldetails", {
				"select" = "#qexportpulllabelscolumnlist#,unit_of_measure_desc"
			}), "#qexportpulllabelscolumnlist#,unit_of_measure_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqExportPullDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqExportPullDetails>
<cfquery name="qExportPullDetails" dbtype="query">
	SELECT #qExportPullLabelsColumnList#,Unit_Of_Measure_Desc
	FROM qExportPullDetails
</cfquery>
</cfif>

<!--- Create list of columns to pull data in the order desired --->
<cfset BBcolList = qExportBBLabelsColumnList>
<cfset PullColList = qExportPullLabelsColumnList>

<cfif URL.PP_ID NEQ 0> <!--- We are only showing  1 BB --->
		<cfset qBBinfo = application.oBBReportGet.getBBinfo(0,URL.PP_ID)>
		<!--- <cfset BB_code = qBBinfo.BB_code />
		<cfset BB_Title = qBBinfo.BB_Title /> --->
<cfelse>
		<cfset qBBinfo = application.oBBReportGet.getReportBBIds(URL.Report)>
		<!--- <cfset BB_code = qBBinfo.BB_code />
		<cfset BB_Title = qBBinfo.BB_Title /> --->
</cfif>

<div>
<CF_smallLink 
	title = "Go Back" 
	url = "##"
	parameters = "onClick=""javascript: history.back();"""
>
</div>

<!---XXXXXXXXXXXXXXXXXXXXXXXXXXXXX    BILLBACK DETAILS    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
<table border="0" style="margin-top:5px;" cellspacing="0" cellpadding="2" class="NoBorder">
  <tr>
	<td colspan="100%" align="left" class="NoBorder">
		<span style="color:navy;">BillBack List:</span>
	</td>
  </tr>

<!--- <cfif URL.BB_ID NEQ 0 OR URL.PP_ID NEQ 0> --->
	 <tr>
 	<cfoutput query="qBBinfo">
		<td class="NoBorder">#application.oBBReportGet.getDetailExportLink(variables.lockedByMe,URL.Report,qBBinfo.billback_id,URL.PP_ID,1)#<cfif qBBinfo.CurrentRow NEQ qBBinfo.recordcount> :: </cfif></td>
		<cfif qBBinfo.CurrentRow MOD 10 IS 0>
		  </tr>
		  <tr>
		</cfif>
	</cfoutput>
	</tr>
<!--- </cfif> --->
</table>
<!--- only show 1 bb at a time --->
<cfif URL.BB_ID NEQ 0>
	<table border="0" cellspacing="0" cellpadding="3">
	<cfoutput>
	<tr>
		<td colspan="100%">
			#application.oBBReportGet.getDeviationReportLink(URL.BB_ID)#
		</td>
	</tr>
	
	  <tr>
		<cfloop list="#BBcolList#" index="i">
			<cfquery name="BBheaderLabel" dbtype="query">
				SELECT custom_col_name, default_col_name, db_col_name
				FROM qExportBBLabels
		WHERE db_col_name = '#ucase(i)#'
			</cfquery>
			<td class="rowHead" valign="top">
				<cfif BBheaderLabel.custom_col_name NEQ "">
					#BBheaderLabel.custom_col_name#
				<cfelseif BBheaderLabel.default_col_name NEQ "">
					#BBheaderLabel.default_col_name#
				<cfelse>
					#BBheaderLabel.db_col_name#
				</cfif>&nbsp;
			</td>
		</cfloop>
	  </tr>
	</cfoutput>
	<cfoutput query="qExportBBDetails">
	  <tr bgcolor="###Iif(((qExportBBDetails.CurrentRow MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
			<cfloop list="#BBcolList#" index="i">
				<cfif i EQ "Discount_Offered">
					<td>#evaluate("#i#")# #Unit_Of_Measure_Desc#</td>
				<cfelseif i EQ "Invoice_date">
					<cfset invDate = evaluate("#i#")>
					<td>#application.oBBReportGet.FormatDate(invDate)#</td>
				<cfelse>
					<td>#evaluate("#i#")#</td>
				</cfif>
			</cfloop>
	  </tr>
	</cfoutput>
	</table>
	<br>
		
	<!---XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   PULLBACKS   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
	<cfif qExportPullDetails.recordcount gt 0>
	<h4 style="color:#000066"><cfoutput>#UCase(application.appSettingsGet.getPullbackLabel())#</cfoutput></h4>
<cfif application.appSettingsGet.getBrokerage_Functionality_On()> <!--- Display Brokerage Pullbacks --->
	<cfif URL.BB_ID NEQ 0 OR URL.PP_ID NEQ 0>
		<!--- <cfloop query="qBBinfo"> --->
			<cfset qBrkPBData = CreateObject("component","components.Brk_Pullback.Brk_Pullback_Get").init().GetPBApplied(URL.BB_ID<!--- qBBinfo.Billback_ID --->) />
			<cfif qBrkPBData.recordcount GT 0>
				<cfoutput query="qBrkPBData">
					#qBrkPBData.BB_Code#  ::  #qBrkPBData.Applied_Dollars# <br>
				</cfoutput>
			</cfif>
		<!--- </cfloop> --->
	</cfif>
</cfif>
	<table border="0" cellspacing="0" cellpadding="3">
	<cfoutput>
	  <tr>
		<cfloop list="#PullColList#" index="i">
			<cfquery name="PullheaderLabel" dbtype="query">
				SELECT custom_col_name, default_col_name, db_col_name
				FROM qExportPullLabels
				WHERE db_col_name = '#ucase(i)#'
			</cfquery>
			<td class="rowHead" valign="top">
				<cfif PullheaderLabel.custom_col_name NEQ "">
					#PullheaderLabel.custom_col_name#
				<cfelseif PullheaderLabel.default_col_name NEQ "">
					#PullheaderLabel.default_col_name#
				<cfelse>
					#PullheaderLabel.db_col_name#
				</cfif>&nbsp;
			</td>
		</cfloop>
	  </tr>
	</cfoutput> 
	<cfoutput query="qExportPullDetails">
	  <tr bgcolor="###Iif(((qExportBBDetails.CurrentRow MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#">
			<cfloop list="#PullColList#" index="i">
				<cfif i EQ "PB_From_Program_Rate">
					<td>#evaluate("#i#")# #Unit_Of_Measure_Desc#</td>
				<cfelse>
					<td>#evaluate("#i#")#</td>
				</cfif>
			</cfloop>
	  </tr>
	</cfoutput>
	</cfif>
<!--- cfif qBBinfo.Recordcount END --->
</cfif>
<script>
function vDeviations(id)
 {
  NewWindow('/billbacks/deviation/deviation_detail_report.cfm?applied=1&BBID='+id,'BB_Preview','800','600','Yes', 'Yes');
 }
 </script>
</table>
