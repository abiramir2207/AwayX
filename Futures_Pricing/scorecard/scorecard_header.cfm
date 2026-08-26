<cfoutput>
<table cellpadding="2" cellspacing="0" border="0" width="#FP_TM_TABLE_WIDTH#" bgcolor="#selectedBgColor#" class="maintable">
	<tr valign="top">
		<td class="tableheaders" width="#FP_VIEW_IMG#">&nbsp;</td>
		<td class="tableheaders" width="#FP_REMINDER#">&nbsp;</td>		
		<cf_scorecard_header_item
			title="Status"
			width="#FP_STATUS#"
			sortToken="STATUS"
			currentSort="#sortBy#"
			currentSortImage="#currentSortImage#"
			>			
		<cf_scorecard_header_item
			title="Title"
			width="#FP_TITLE#"
			sortToken="TITLE"
			currentSort="#sortBy#"
			currentSortImage="#currentSortImage#"
			>
		<td class="tableheaders" width="#FP_SRATE_END_DATE#">
			<table cellpadding="0" cellspacing="0" border="0" width="100%" class="NotMainTable">
			<tr>
				<td>
				<cf_scorecard_header_item
					title="Start Date"
					width="#FP_SRATE_END_DATE#"
					sortToken="SD"
					currentSort="#sortBy#"
					currentSortImage="#currentSortImage#"
					>
				</td>
			</tr>
			<tr>
				<td>
				<cf_scorecard_header_item
					title="End Date"
					width="#FP_SRATE_END_DATE#"
					sortToken="ED"
					currentSort="#sortBy#"
					currentSortImage="#currentSortImage#"
					>
				</td>
			</tr>
			</table>
		</td>
		<cf_scorecard_header_item
			title="Customer Deadline"
			width="#FP_CUST_DEADLINE#"
			sortToken="CUST_DEADLINE"
			currentSort="#sortBy#"
			currentSortImage="#currentSortImage#"
			>
		<cf_scorecard_header_item
			title="Good Until Date"
			width="#FP_GOOD_UNTIL_DATE#"
			sortToken="GOOD_UNTIL_DATE"
			currentSort="#sortBy#"
			currentSortImage="#currentSortImage#"
			>
		<cf_scorecard_header_item
			title="Created By"
			width="#FP_CREATED_BY#"
			sortToken="CREATED_BY"
			currentSort="#sortBy#"
			currentSortImage="#currentSortImage#"
			>
	</tr>
</table>
</cfoutput>