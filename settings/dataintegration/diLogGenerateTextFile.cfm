<CFPARAM NAME="URL.logitem" DEFAULT="">
<cfcontent type="text/plain">
<cfheader name="Content-Disposition" value="attachment;filename=DataIntegration#URL.logitem#Log.txt">
<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<CFIF NOT isDefined("DI_IncludeFile")>
	<CFINCLUDE template="diLog_Include.cfm">
</CFIF>
<cfset anyRecord=false>
<cfset separator=44>

<cfset logTableThisContext="">
<cfif Len(URL.logitem) GT 0>
	<cfset logIndex=ListFindNoCase(logItems,URL.logitem,",")>
	<cfif logIndex>
		<cfset logTableThisContext=ListGetAt(logTables,logIndex,",")>
	<cfelse>
		<cfoutput>No data integration Log entry</cfoutput>
		<cfabort>
	</cfif>
<cfelse>
	<cfset logTableThisContext=logTables>
</cfif>

<CFIF (ListLen(logTables,",") EQ ListLen(logItems,",")) AND (ListLen(logTables,",") EQ ListLen(originalDB,","))>
	<cfloop index="i" list="#logTableThisContext#" delimiters=",">		
		<cfset j=ListFindNoCase(logTables,i,",")>
		<CFQUERY NAME="q_diLogData" datasource="#application.datasource#">
			SELECT *
		    FROM #i#
		</CFQUERY>
		<cfset thisRecID=0>
		
		<CFIF q_diLogData.recordCount GT 0>			
			<cfset idName="Log_#ListGetAt(logItems,j,",")#_id">
			<cfoutput>#ListGetAt(logItems,j,",")##chr(13)##chr(10)##chr(13)##chr(10)#</cfoutput>
			<cfif isDefined("q_diLogData.#idName#")>
				<CFQUERY NAME="q_diLogFields" datasource="#application.datasource#">
				SELECT lower(column_name) as column_name,data_type,character_maximum_length
			    FROM information_schema.columns 
			    WHERE table_name='#i#'
				</CFQUERY>
				<cfset firstField=true>
				<!----<cfloop index="field" list="#q_diLogData.columnList#" delimiters=",">---->
				<cfset logTableFields="">
				<cfloop query="q_diLogFields">
					<cfset field=column_name>					
					<cfif isDefined("q_diLogData.#field#")>
						<!-----
						<cfloop index="takeFields" list="#lookForFields#" delimiters=",">
							<cfif FindNoCase(takeFields, field)>
							-------->
							<cfif NOT FindNoCase("#idName#", field)>
								<cfif NOT ListFindNoCase(logRestrictedFieldList,field,",")>
									<cfset logTableFields=ListAppend(logTableFields,column_name,",")>
									<cfif NOT firstField>
										<cfoutput>#chr(separator)#</cfoutput>
									<cfelse>
										<cfset firstField=false>
									</cfif>
									<cfoutput>#UCase(field)#</cfoutput>
								</cfif>
							</cfif>
								<!-----
							</cfif>
						</cfloop>
						----->
					</cfif>
				</cfloop>				
			</cfif>
			<cfoutput>#chr(13)##chr(10)#</cfoutput>

			<cfloop query="q_diLogData" startrow=1>
			<cfif isDefined("#idName#")>
				<cfset thisRecID=Evaluate("#idName#")>\
				<cfset firstField=true>		
				<!----<cfloop index="field" list="#q_diLogData.columnList#" delimiters=",">---->
				<cfloop index="field" list="#logTableFields#" delimiters=",">				
				<!----<cfloop query="q_diLogFields" >
					<cfset field=column_name>----->
					<cfif isDefined("q_diLogData.#field#")>
						<!--------
						<cfloop index="takeFields" list="#lookForFields#" delimiters=",">
							<cfif FindNoCase(takeFields, field)>
							---->
							<!-----
							<cfif NOT FindNoCase("#idName#", field)>
								<cfif NOT ListFindNoCase(logRestrictedFieldList,field,",")>---->
								<cfif NOT firstField>
									<cfoutput>#chr(separator)#</cfoutput>
								<cfelse>
									<cfset firstField=false>
								</cfif>
								<cfoutput>#Evaluate("q_diLogData.#field#")#</cfoutput>
								<cfset anyRecord=true>
								<!----</cfif>
							</cfif>---->
							<!------
							</cfif>
						</cfloop>
						-------->
					</cfif>					
				</cfloop>
				<cfoutput>#chr(13)##chr(10)#</cfoutput>
			</cfif>
			</cfloop>
			<cfoutput>#chr(13)##chr(10)#----------------------------------------------------------------------#chr(13)##chr(10)##chr(13)##chr(10)#</cfoutput>
		</CFIF>
	</cfloop>
</CFIF>
<CFIF NOT anyRecord>
		<cfoutput>No data integration Log entry</cfoutput>
</CFIF>


