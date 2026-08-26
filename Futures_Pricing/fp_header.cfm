<!------ fp_header.cfm ----->
<cfoutput>

<style>
	.header1
	{
		color:			##000080;
		font-size:		15px;
		font-weight:	bold;
	}
	.header2
	{
		background-color:	##000080;
		color:				##FFFFFF;
		font-size:			15px;
		font-weight:		bold;
	}
	.header3
	{
		background-color:	##000080;
		color:				##FFFFFF;
		font-size:			12px;
		font-weight:		bold;
	}
	.header4
	{
		background-color:	##000080;
		color:				##FFFF00;
		font-size:			12px;	
	}
</style>
<TABLE BORDER="0" CELLPADDING="3" STYLE="border-collapse: collapse" WIDTH="100%" CELLSPACING="1">
	<TR valign="top">
		<TD COLSPAN="4" class="header2">
			<cfset statusDesc = requestObj.getStatusDesc()>
			Title: #requestObj.getTitle()#
			<cfif isDate(requestObj.getCreatedDate())> - #DateDiff("d", requestObj.getCreatedDate(), Now())# day(s) old</cfif>
			<br>
			Status: 
			 <font class="header4">
			 <cfif Len(statusDesc)>#statusDesc#
			 <cfif isDate(requestObj.getStatusAgeDate())> - #DateDiff("d", requestObj.getStatusAgeDate(), Now())# day(s) old</cfif>
			 </cfif>
			 </font>
		</TD>
		<cfset totalVolume = 0>
		<cfset requestProductArray = requestObj.getRequestProduct()>
		<cfset productCount = ArrayLen(requestProductArray)>
		<!------ <cfloop query="qGetProducts"> ----->
		<cfloop index="prodIndex" from="1" to="#productCount#">
			<cfset requestProduct = requestProductArray[prodIndex]>
			<cfset thisVolume = requestProduct.getLbVolume()>
			<cfif IsNumeric(thisVolume) AND thisVolume NEQ "">
				<cfset totalVolume = totalVolume + thisVolume>
			</cfif>
		</cfloop>			
	</TR>
	<TR valign="top">
		<TD class="header3" width="">
			Span: <font class="header4"><cfif isDate(requestObj.getStartDate()) AND isDate(requestObj.getEndDate())> (total #Evaluate(DateDiff("d", requestObj.getStartDate(), requestObj.getEndDate()) + 1)# days)</cfif>
			<br>#DateFormat(requestObj.getStartDate(), "mm/dd/yyyy")# - #DateFormat(requestObj.getEndDate(), "mm/dd/yyyy")#
			<cfif isDate(requestObj.getStartDate())> (#DateDiff("d", Now(), requestObj.getStartDate())# days left)</cfif></font>
		</TD>
		<TD class="header3" width="">
			Customer Deadline: <br><font class="header4">#DateFormat(requestObj.getDeadLineDate(), "mm/dd/yyyy")#<cfif isDate(requestObj.getDeadLineDate())> (#DateDiff("d", Now(), requestObj.getDeadLineDate())# days left)</cfif></font>
		</TD>
		<TD class="header3" width="">
			Good Until: <br><font class="header4">
			<cfif isDate(requestObj.getGoodUntilDate())>
			#DateFormat(requestObj.getGoodUntilDate(), "mm/dd/yyyy")# (#DateDiff("d", Now(), requestObj.getGoodUntilDate())# days left)
			<cfelse>
			N/A
			</cfif>
			</font>
		</TD>
		<TD class="header3" width="">
			Total Volume: <br><font class="header4">#NumberFormat(totalVolume, "___,___,___,___")# Lbs</font>
		</TD>
	</TR>
	<cfif pagePhase>
	<TR>
		<TD WIDTH="100%" COLSPAN="100%" class="header1">
		<cfset statusManager = CreateObject("component", "components.futures_pricing.StatusManager").init() />
		Phase #pagePhase# - #statusManager.getStatusDesc(pagePhase)#			
		</TD>
	</TR>
	</cfif>
</TABLE>
</cfoutput>