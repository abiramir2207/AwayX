<!------ scorecard_small.cfm ----->
<cfoutput>
<cfset fpRequestManager = CreateObject("component", "components.futures_pricing.RequestManager").init() />
<cfset qGetStatusCount = fpRequestManager.requestStatusCount(request.AccessStructure.User_ID)>

<!------ set expired item ----->
<cfset stSearch = StructNew() />
<cfset stSearch.isExpired = 1 />
<cfset stSearch.restrictAccessUserId = request.AccessStructure.User_ID />
<cfset qRequests = fpRequestManager.search(stSearch)>

<cfset QueryAddRow(qGetStatusCount) />
<cfset QuerySetCell(qGetStatusCount, "FP_Status_ID", 0) />
<cfset QuerySetCell(qGetStatusCount, "FP_Status_Desc", "Expired") />
<cfset QuerySetCell(qGetStatusCount, "Request_Count", qRequests.recordCount) />


<cfset colLen = 3>
<table cellpadding="2" cellspacing="0" border="0" bgcolor="##FFFFEA" style="border:1px solid silver;" width="#FP_TM_TABLE_WIDTH#">
	<cfloop query="qGetStatusCount">	
		<cfif currentRow mod colLen EQ 1>
			<cfif currentRow NEQ 0>
			</tr>
			</cfif>
		<tr>
		</cfif>
		<td align="right" nowrap><B>#FP_Status_Desc#</B></td>
		<td align="right">
		<INPUT CLASS="textbox_input" type="text" size="4" READONLY VALUE="#Request_Count#">
		</td>		
	</cfloop>
	</tr>
</table>
</cfoutput>