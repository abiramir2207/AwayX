<!------ billback_status_tool_tip.cfm ----->
<cfif not isDefined("appSettings")>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
</cfif>
<cfquery name="BBStatus" datasource="#application.datasource#">
	SELECT		Billback_Status.Billback_Status_ID,
				Billback_Status.BB_Status_Description
	FROM		Billback_Status
	WHERE		<CFIF LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1>
					<CFIF application.returned_customer_setting.Upload_GL_Code NEQ 1>
						Billback_Status.Billback_Status_ID NOT IN (6,7)
					<CFELSE>
						Billback_Status.Billback_Status_ID IN (1,2,3,4,5,6,7,8)
					</CFIF>
				<CFELSE>
					Billback_Status.Billback_Status_ID NOT IN  (4,6,7)
				</CFIF>
	ORDER BY 	Status_Order_Number
</cfquery>

<cfset iMaxCols = 2>
<cfset currColCount = 0 />
<cfoutput>
<cfsavecontent variable="billbackStatusToolTip">
<!--- The height for the div (tooltip) below works only for IE 10. I removed the height below as even without the height, the tooltip can be seen.
The other option is to add the height which will work for IE 10 onwards.
--->
<DIV ID="divTooltip" STYLE="position:absolute;visibility:hidden;background-color: ##F5F5DC; z-index: 5000;width:230;border:1px solid black;">
<TABLE CELLPADDING="2" CELLPADDING="0" BORDER="0"><TR>
<cfloop query="BBStatus">
	<cfset displayThisStatus = 0 />
	<cfif ListFindNoCase("7", Billback_Status_ID) NEQ 0 AND LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1><!------ Pending Vendor ID ----->
		<cfset displayThisStatus = 1 />
	<cfelseif ListFindNoCase("6", Billback_Status_ID) NEQ 0 AND LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1 AND (application.returned_customer_setting.Upload_GL_Code EQ 1 OR appSettings.getBudgetsFunctionalityOn())><!------ Pending Fund update ----->
		<cfset displayThisStatus = 1 />
	<cfelseif ListFindNoCase("4", Billback_Status_ID) NEQ 0 AND LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1><!------ Payment Request ----->
		<cfset displayThisStatus = 1 />
	<cfelseif ListFindNoCase("4,6,7", Billback_Status_ID) EQ 0>
		<cfset displayThisStatus = 1 />
	</cfif>
	<cfif displayThisStatus>
		<TD nowrap>
			<IMG SRC="#getBBStatusImage(Billback_Status_ID)#" TITLE="#BB_Status_Description#">&nbsp;#BB_Status_Description#
		</TD>
		<cfset currColCount = currColCount + 1 />
		<cfif NOT (currColCount mod iMaxCols)>
		</tr><tr>
		</cfif>
	</cfif>
</cfloop>
</TR></TABLE>
</DIV>
</cfsavecontent>
</cfoutput>

<cffunction name="getBBStatusImageString" output="false">
	<cfargument name="bbStatusId" required="true" type="numeric" />
	<cfoutput>
	<cfsavecontent variable="returnValue">
	<IMG SRC="#getBBStatusImage(arguments.bbStatusId)#" onmouseover="initTheTooltip('')" onmouseout="popOut()">
	</cfsavecontent>
	</cfoutput>
	<cfreturn returnValue />

</cffunction>

<cffunction name="getBBStatusImage" output="false">
	<cfargument name="bbStatusId" required="true" type="numeric" />

	<cfset returnValue = "" />
	<CFSWITCH EXPRESSION="#arguments.bbStatusId#">
		<CFCASE VALUE="1">
			<!--- WIP --->
			<cfset returnValue = "/images/wip.gif" />
		</CFCASE>
		<CFCASE VALUE="2">
			<!--- Ready For Approval --->
			<cfset returnValue = "/images/rfa.gif" />
		</CFCASE>
		<CFCASE VALUE="3">
			<!--- Active Programs --->
			<cfset returnValue = "/images/preactive.gif" />
		</CFCASE>
		<CFCASE VALUE="4">
			<!--- Archived/Expired --->
			<cfset returnValue = "/images/active.gif" />
		</CFCASE>
		<CFCASE VALUE="5">
			<!--- Archived/Expired --->
			<cfset returnValue = "/images/expired.gif" />
		</CFCASE>
		<CFCASE VALUE="6">
			<!--- Pending Fund update --->
			<cfset returnValue = "/images/statusImage2.gif" />
		</CFCASE>
		<CFCASE VALUE="7">
			<!--- Pending Vendor ID --->
			<cfset returnValue = "/images/statusImage1.gif" />
		</CFCASE>
		<CFCASE VALUE="8">
			<!--- Approved/Void --->
			<cfset returnValue = "/images/expiring.gif" />
		</CFCASE>
		<CFCASE VALUE="9">
			<!--- Manual Reject --->
			<cfset returnValue = "/images/layered_approval/Gaya_i12.gif" />   <!--- 56159 --->
		</CFCASE>
	</CFSWITCH>
	<cfreturn returnValue />

</cffunction>