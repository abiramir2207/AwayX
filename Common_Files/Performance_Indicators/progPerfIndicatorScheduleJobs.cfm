
<cfoutput>
<cfif Not isDefined("scheduleFlag")>
	#reportOutput#
	<!--- add for the schedule jobs --->
	<!----------- Get a new report name --------------------->
	<CFSET scheduleHandle = CreateObject("component", "components.programs.performance_indicator.perfIndicatorScheduleJobs") />
	<cfset qPerfIndicScheduleJobs = scheduleHandle.GetReportName() />
	
	<CFIF qPerfIndicScheduleJobs.recordCount GT 0>
		<CFIF qPerfIndicScheduleJobs.maxReport_Type_ID EQ "">
			<CFSET rName="Program Indicator 1">
		<CFELSE>
			<CFSET rName="Program Indicator #Evaluate(qPerfIndicScheduleJobs.maxReport_Type_ID+1)#">
		</CFIF>
	</CFIF>
	<CFSET thisFormName = "perfIndForm">
	<CFSET rStartDate=dateformat(Now(), 'm/d/yyy')>
	<CFSET rEndDate=dateformat(Now(), 'm/d/yyy')>
	<CFSET rStartTime=thisTime>
	<cfset rIntervals="Once,Daily,Weekly,Monthly">
	<CFSET rInterval="once">
	<CFSET rEmailAddress="">
	<cfif isDefined("rID")>
		<cfif rID GT 0>
			<cfset bTitle="Edit This Report Schedule">
			<!---check if session.form is existing, if so, copy it to form--->	
			<cfif isDefined("session.form") and Not StructIsEmpty(session.form)>
				<cfloop collection=#session.form# item="myItem">
					<cfoutput>
						<cfset "form.#trim(myItem)#" = #Evaluate('session.form.' & trim(myItem))# >
					</cfoutput>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset bTitle="Save As Report Schedule">
		</cfif>
	<cfelse>
		<cfset bTitle="Save As Report Schedule">
	</cfif>
	<cfif isDefined("sErr")><cfset showClosed="No"><cfelse><cfset showClosed="Yes"></cfif>
	<div style="width:85%">
		<CF_openLayer
			Border="yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="#bTitle#"  
			TitleClosed="#bTitle#"  
			TitleTooltip="#bTitle#"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="#showClosed#"  
			Width="100%">
				<CFSET repType="programPerformance">
				<CFINCLUDE TEMPLATE="/reportWriter/reportInvoiceScheduleTemplate.cfm">		
		</CF_openLayer>
	</div>
	<br>
	<!--- end schedule jobs--->
</cfif>
</cfoutput>