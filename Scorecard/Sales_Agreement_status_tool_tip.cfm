
<!------ program_status_tool_tip.cfm ----->
<cfquery name="ProgramStatus" datasource="#application.datasource#">
	SELECT		Contract_Status_Types.Contract_Status_Type_ID,
				Contract_Status_Types.Contract_Status_Type_Desc
	FROM		Contract_Status_Types
	WHERE		Contract_Status_Types.Contract_Status_Type_ID IN  (1,2,4,5,7)
	Order By    Contract_Status_Order
</cfquery>
<cfset iMaxCols = 2>
<cfset currColCount = 0 />
<cfoutput>

<cfsavecontent variable="programStatusToolTip">
<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: F5F5DC; z-index: 5000;width:230;height:50;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0"><TR>
<cfloop query="ProgramStatus">	
	<TD nowrap>
		<IMG SRC="#getProgramStatusImage(Contract_Status_Type_ID)#" ALT="#Contract_Status_Type_Desc#">&nbsp;#Contract_Status_Type_Desc#
	</TD>
	<cfset currColCount = currColCount + 1 />	
	<cfif NOT (currColCount mod iMaxCols)>
	</tr><tr>
	</cfif>
</cfloop>
</TR></TABLE>
</DIV>
</cfsavecontent>
</cfoutput>

<cffunction name="getProgramStatusImageString" output="false">
	<cfargument name="programStatusId" required="true" type="numeric" />
	<cfoutput>
	<cfsavecontent variable="returnValue">
	<IMG SRC="#getProgramStatusImage(arguments.programStatusId)#" onmouseover="initTheTooltip('')" onmouseout="popOut()">	
	</cfsavecontent>
	</cfoutput>
	<cfreturn returnValue />
	
</cffunction>

<cffunction name="getProgramStatusImage" output="false">
	<cfargument name="programStatusId" required="true" type="numeric" />
	
	<cfset returnValue = "" />
	<CFSWITCH EXPRESSION="#arguments.programStatusId#">
		<CFCASE VALUE="1">
			<!--- WIP --->
			<cfset returnValue = "/images/wip.gif" />
		</CFCASE>
		<CFCASE VALUE="2">
			<!--- Ready For Approval --->
			<cfset returnValue = "/images/rfa.gif" />
		</CFCASE>				
		<CFCASE VALUE="4">
			<!--- Pre-Active --->
			<cfset returnValue = "/images/preactive.gif" />
		</CFCASE>
		<CFCASE VALUE="5">
			<!--- Active --->
			<cfset returnValue = "/images/active.gif" />
		</CFCASE>
		<CFCASE VALUE="7">
			<!--- Expired --->
			<cfset returnValue = "/images/expired.gif" />
		</CFCASE>
	</CFSWITCH>
	<cfreturn returnValue />
	
</cffunction>