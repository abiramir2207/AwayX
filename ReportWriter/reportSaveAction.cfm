<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>

<cfset fromReportSaveAction=true>
<!------------------------Set Defaults--------------------->
<CFPARAM NAME="Form.rReportType" DEFAULT="">

<CFPARAM NAME="Form.reportType" DEFAULT="program">

<CFPARAM NAME="Form.rStatus" DEFAULT="">
<!------<CFPARAM NAME="Form.rProgramTypes" DEFAULT="">----->
<CFPARAM NAME="Form.rGenericTypes" DEFAULT="">
<CFPARAM NAME="Form.rFilter" DEFAULT="">
<CFPARAM NAME="Form.rZones" DEFAULT="">
<CFPARAM NAME="Form.rRegions" DEFAULT="">
<CFPARAM NAME="Form.rBrokers" DEFAULT="">
<CFPARAM NAME="Form.rSortBy" DEFAULT="">
<CFPARAM NAME="Form.StartDate" DEFAULT="">
<CFPARAM NAME="Form.EndDate" DEFAULT="">

<CFPARAM NAME="Form.rFilterItems" DEFAULT="">

<CFPARAM NAME="Form.rTypeGroups" DEFAULT="">
<CFPARAM NAME="Form.rQBrands" DEFAULT="">
<CFPARAM NAME="Form.rTypeCodes" DEFAULT="">
<CFPARAM NAME="Form.rBrands" DEFAULT="">
<CFPARAM NAME="Form.rProductGroups" DEFAULT="">
<CFPARAM NAME="Form.rProducts" DEFAULT="">


<CFPARAM NAME="Form.rFamilys" DEFAULT="">
<CFPARAM NAME="Form.rBuyingGroups" DEFAULT="">
<CFPARAM NAME="Form.rDistributors" DEFAULT="">
<CFPARAM NAME="Form.rOperators" DEFAULT="">


<CFPARAM NAME="Form.rReportOutputType" DEFAULT="h">
<CFPARAM NAME="Form.rColumnHeaderID" DEFAULT="">
<CFSET Form.rColumnHeaderID=ListAppend(fProgramColumnHeaderID,Form.rColumnHeaderID,",")>


<CFPARAM NAME="Form.rName" DEFAULT="">
<CFPARAM NAME="Form.rStartDate" DEFAULT="">
<CFPARAM NAME="Form.rEndDate" DEFAULT="">
<CFPARAM NAME="Form.rStartTime" DEFAULT="">
<CFPARAM NAME="Form.rInterval" DEFAULT="">
<CFPARAM NAME="Form.rEmailAddress" DEFAULT="">

<CFSET userID=request.AccessStructure.user_id>


<!------------------------End Set Defaults--------------------->


<!------------------------Validate--------------------->
<cfset allClear=true>

<!---------------------Validate ID ------------------------->
<CFIF isDefined("Form.rID")>
	<cfif NOT isNumeric(Form.rID)>
		<cfset allClear=false>
	</cfif>
	<cfset dbAction="edit">
<CFELSE>
	<cfset dbAction="add">
</CFIF>
<!--------------------- End Validate ID ------------------------->

<!---------------------Validate Name------------------------->
<cfif Trim(Form.rName) EQ "">
	<cfset allClear=false>
	<cfset writeToErrorMessage("Invalid Report Name","error_ReportName")>
<!------
<cfelseif NOT REFindNoCase("^[A-Za-z0-9_]+$", Form.rName)>
	<cfset allClear=false>
	<cfset writeToErrorMessage("Invalid Report Name","error_ReportName")>
----->
</cfif>

<!---------------------End Validate Name------------------------->



<!---------------------Validate StartDate------------------------->
<cfset dTrue=true>
<cfset daysDiff=0>
<cfif isDateValid(Form.rStartDate) EQ "Yes">
 	<!---------------------Validate Start Date against web server current date------------------------->
	<!----<cfset daysDiff=DateDiff("d", thisDate,getDateFromMMDDYYYYFormat(Form.rStartDate))>---->
	<cfset daysDiff=Day(getDateFromMMDDYYYYFormat(Form.rStartDate))-Day(thisDate)>
	<cfif daysDiff LT 0>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Start Date should be greater than today","error_Start_Date")>
		<cfset dTrue=false>
	</cfif>
 <cfelse>
 	<cfset allClear=false>
	<cfset writeToErrorMessage("Invalid Start Date","error_Start_Date")>
	<cfset dTrue=false>
 </cfif>

<!---------------------End Validate StartDate------------------------->

<!---------------------Validate EndDate------------------------->

<cfif Form.rInterval NEQ "once">	
	<cfif isDateValid(Form.rEndDate)>
		<cfif dTrue>
			<cfif DateDiff("d", getDateFromMMDDYYYYFormat(Form.rStartDate),getDateFromMMDDYYYYFormat(Form.rEndDate)) LT 0>
				<cfset allClear=false>
				<cfset writeToErrorMessage("End Date should be greater than Start Date","error_End_Date")>
			</cfif>
		</cfif>
	<cfelse>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Invalid End Date","error_End_Date")>
	</cfif>	
</cfif>

<!---------------------End Validate EndDate------------------------->


<!-------------------------- Validate time ----------------------->

<cfset rStartTime = getMilitaryTime(Form.rStartTime)>
<cfif daysDiff EQ 0>	
	<cfset aStartTime=ListToArray(rStartTime,":")>
	<cfset rThisTime=timeformat(DateAdd('n',timeIncr,Now()), 'HH:mm:ss')>
	<cfset aThisTime=ListToArray(rThisTime,":")>
	<cfif checkTimelessThan(aStartTime,aThisTime)>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Time should be greater than " & rThisTime & " if you select Start Date as today","error_Start_Time")>
	</cfif>
</cfif>

<!-------------------------- End Validate time ----------------------->

<!--------------------------- Validate Email Address ---------------------->
<cfif Len(Form.rEmailAddress) GT 0>
	<cfset validEmail = makeValidEmails(Form.rEmailAddress)>
	<cfif validEmail NEQ "">
		<cfset allClear=false>
		<cfset writeToErrorMessage("Invalid Email Address " & validEmail,"error_Email_Address")>
	<cfelseif Len(Form.rEmailAddress) GTE 3000>
		<cfset allClear = false>
		<cfset writeToErrorMessage("Email Address exceeds available size limit 3000","error_Email_Address")>
	</cfif>
<cfelse>
	<cfset allClear = false>
	<cfset writeToErrorMessage("Invalid Email Address","error_Email_Address")>
</cfif>

<!--------------------------- End Validate Email Address ---------------------->


<!------------------------End Validate--------------------->


<!---------------------  create report structure --------------------------->
<CFSET sSql="">


<CFOUTPUT><CFIF allClear>
	<CFIF Form.rStatus NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rStatus#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rStatus';">
		<CFELSE>
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rStatus','#Form.rStatus#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<!------<CFIF Form.rProgramTypes NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rProgramTypes#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rProgramTypes';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rProgramTypes','#Form.rProgramTypes#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>----->
	
	<CFIF Form.rGenericTypes NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rGenericTypes#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rGenericTypes';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rGenericTypes','#Form.rGenericTypes#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<CFIF Form.StartDate NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.StartDate#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='StartDate';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'StartDate','#Form.StartDate#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<CFIF Form.EndDate NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.EndDate#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='EndDate';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'EndDate','#Form.EndDate#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<CFIF Form.rFilter NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rFilter#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilter';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilter','#Form.rFilter#');">
		</CFIF>
	<CFELSE>
		<!-----<cfset allClear = false>------->
		<cfset allClear = true>
	</CFIF>
	
	<CFIF Form.rZones NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rZones#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterValue';">
		<CFELSE>				
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterValue','#Form.rZones#');">
		</CFIF>
	<CFELSEIF Form.rRegions NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rRegions#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterValue';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterValue','#Form.rRegions#');">
		</CFIF>
	<CFELSEIF Form.rBrokers NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rBrokers#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterValue';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterValue','#Form.rBrokers#');">
		</CFIF>
	<CFELSE>
		<!-----<cfset allClear = false>
		<cfset writeToErrorMessage("Invalid Geographic Filter","error_rFilter")>------->
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value=null WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterValue';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterValue',null);">
		</CFIF>
	</CFIF>
	
	<CFIF Form.rSortBy NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rSortBy#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rSortBy';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rSortBy','#Form.rSortBy#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<CFIF Form.rReportOutputType NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rReportOutputType#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rReportOutputType';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rReportOutputType','#Form.rReportOutputType#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
	</CFIF>
	
	<CFIF Form.rColumnHeaderID NEQ "">
		<CFIF dbAction EQ "edit">
			<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rColumnHeaderID#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rColumnHeaderID';">
		<CFELSE>			
			<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rColumnHeaderID','#Form.rColumnHeaderID#');">
		</CFIF>
	<CFELSE>
		<cfset allClear = false>
		<cfset writeToErrorMessage("Invalid Geographic Filter","error_rFilter")>
	</CFIF>
	
	
	<!-----<CFIF Form.rReportType EQ "ProductSummary">------->
		<CFIF Form.rFilterItems NEQ "">
			<CFIF dbAction EQ "edit">
				<!-----<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rFilterItems#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItems';">------->
				<CFSAVECONTENT VARIABLE="sSql">
				#sSql#
				DECLARE @StructureCount Int
				SELECT	@StructureCount=Count(Report_Structure_ID)
				FROM	Report_Structure
				WHERE	Report_Type_ID=#Form.rID#
					AND Report_Structure='rFilterItems'
				IF @StructureCount > 0
				   BEGIN
				    UPDATE Report_Structure SET Report_Structure_Value='#Form.rFilterItems#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItems'
				   END
				ELSE
				   BEGIN
				    INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(#Form.rID#,'rFilterItems','#Form.rFilterItems#')
				   END
				   
				</CFSAVECONTENT>
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItems','#Form.rFilterItems#');">
			</CFIF>			
		</CFIF>
		
		<CFIF Form.rTypeGroups NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rTypeGroups#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rTypeGroups#');">
			</CFIF>
		<CFELSEIF Form.rQBrands NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rQBrands#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rQBrands#');">
			</CFIF>
		<CFELSEIF Form.rTypeCodes NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rTypeCodes#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rTypeCodes#');">
			</CFIF>
		<CFELSEIF Form.rBrands NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rBrands#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rBrands#');">
			</CFIF>
		<CFELSEIF Form.rProductGroups NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rProductGroups#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rProductGroups#');">
			</CFIF>
		<CFELSEIF Form.rProducts NEQ "">
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rProducts#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rProducts#');">
			</CFIF>		
		<CFELSEIF Form.rFamilys NEQ "">
			<CFIF dbAction EQ "edit">
				<!-----<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rFamilys#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">------->
				<CFSAVECONTENT VARIABLE="sSql">
				#sSql#
				SELECT	@StructureCount=Count(Report_Structure_ID)
				FROM	Report_Structure
				WHERE	Report_Type_ID=#Form.rID#
					AND Report_Structure='rFilterItemValue'
				IF @StructureCount > 0
				   BEGIN
				    UPDATE Report_Structure SET Report_Structure_Value='#Form.rFamilys#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue'
				   END
				ELSE
				   BEGIN
				    INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(#Form.rID#,'rFilterItemValue','#Form.rFamilys#')
				   END
				   
				</CFSAVECONTENT>
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rFamilys#');">
			</CFIF>
		<CFELSEIF Form.rBuyingGroups NEQ "">
			<CFIF dbAction EQ "edit">
				<!-----<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rBuyingGroups#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">------->
				<CFSAVECONTENT VARIABLE="sSql">
				#sSql#				
				SELECT	@StructureCount=Count(Report_Structure_ID)
				FROM	Report_Structure
				WHERE	Report_Type_ID=#Form.rID#
					AND Report_Structure='rFilterItemValue'
				IF @StructureCount > 0
				   BEGIN
				    UPDATE Report_Structure SET Report_Structure_Value='#Form.rBuyingGroups#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue'
				   END
				ELSE
				   BEGIN
				    INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(#Form.rID#,'rFilterItemValue','#Form.rBuyingGroups#')
				   END
				   
				</CFSAVECONTENT>
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rBuyingGroups#');">
			</CFIF>
		<CFELSEIF Form.rDistributors NEQ "">
			<CFIF dbAction EQ "edit">
				<!-----<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rDistributors#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">------->
				<CFSAVECONTENT VARIABLE="sSql">
				#sSql#				
				SELECT	@StructureCount=Count(Report_Structure_ID)
				FROM	Report_Structure
				WHERE	Report_Type_ID=#Form.rID#
					AND Report_Structure='rFilterItemValue'
				IF @StructureCount > 0
				   BEGIN
				    UPDATE Report_Structure SET Report_Structure_Value='#Form.rDistributors#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue'
				   END
				ELSE
				   BEGIN
				    INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(#Form.rID#,'rFilterItemValue','#Form.rDistributors#')
				   END
				   
				</CFSAVECONTENT>
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rDistributors#');">
			</CFIF>
		<CFELSEIF Form.rOperators NEQ "">
			<CFIF dbAction EQ "edit">
				<!-----<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#Form.rFamilys#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">------->
				<CFSAVECONTENT VARIABLE="sSql">
				#sSql#
				SELECT	@StructureCount=Count(Report_Structure_ID)
				FROM	Report_Structure
				WHERE	Report_Type_ID=#Form.rID#
					AND Report_Structure='rFilterItemValue'
				IF @StructureCount > 0
				   BEGIN
				    UPDATE Report_Structure SET Report_Structure_Value='#Form.rOperators#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue'
				   END
				ELSE
				   BEGIN
				    INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(#Form.rID#,'rFilterItemValue','#Form.rOperators#')
				   END
				   
				</CFSAVECONTENT>
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue','#Form.rOperators#');">
			</CFIF>
		<CFELSE>			
			<!-----<cfset allClear = false>
			<cfset writeToErrorMessage("Invalid Customer Filter","error_rFilterItems")>			------->
			<CFIF dbAction EQ "edit">
				<CFSET sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value=null WHERE Report_Type_ID=#Form.rID# and Report_Structure='rFilterItemValue';">
			<CFELSE>			
				<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'rFilterItemValue',null);">
			</CFIF>	
		</CFIF>
		
	<!-----</CFIF>------->
	
</CFIF>
</CFOUTPUT>

<!---------------------  End create report structure --------------------------->

<!------------------- Do some action ------------------->
<cfoutput>
<cfif allClear>
	All clear
	<!-----------------
	Steps
	1. Insert into db tables - Report_Type, Report_Structure, Report_Template
	2. schedule cfm using cfschedule to send mail
	3. redirect to next page
	---------------------->
	
	<!------------------1. Insert into db tables----------------------------->
	<cfif Form.rInterval NEQ "Once">
		<cfset sEndDate="#Right(Form.rEndDate,4)#/#Left(Form.rEndDate,2)#/#Mid(Form.rEndDate,4,2)#">
	<cfelse>
		<cfset sEndDate="">
	</cfif>
	<cfset sStartDate="#Right(Form.rStartDate,4)#/#Left(Form.rStartDate,2)#/#Mid(Form.rStartDate,4,2)#">
	
	
	
	<cfset commited=false>
	<cfif dbAction EQ "edit">

		<cftransaction action = "begin">
		<cftry>	
	  
		<cfquery name="q_ReportInsert" datasource="#application.datasource#">
			Update	Report_Type		
			Set		Report_Type='#Form.rReportType#', user_ID='#userID#'
			Where	Report_Type_ID=#Form.rID#
		</cfquery>

		<cfset Report_TypeID=Form.rID>
		
		<cfquery name="q_ReportStructureInsert" datasource="#application.datasource#">
			#preserveSingleQuotes(sSql)#
		</cfquery>
		
		<cfquery name="q_ReportTemplateInsert" datasource="#application.datasource#">
			Update 	Report_Template
			Set				
				Report_Name='#Form.rName#',
				Report_StartDate='#sStartDate#',
				Report_EndDate='#sEndDate#',
				Report_StartTime='#rStartTime#',
				Report_Interval='#Form.rInterval#',
				Report_EmailAddress='#Form.rEmailAddress#'
			Where	Report_Type_ID=#Report_TypeID#
		</cfquery>
		
		
		<cftransaction action = "commit"/>
		<cfset commited=true>
		
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<P>#cfcatch.message#</P>
			</cfcatch>	
		</cftry>
		</cftransaction>
	<cfelseif dbAction EQ "add">
		
		<cftransaction action = "begin">
		<cftry>	
	  
		<cfquery name="q_ReportInsert" datasource="#application.datasource#">
			SET NOCOUNT ON
			insert into 	Report_Type		
				(Report_Type,user_ID)
			Values
				('#Form.rReportType#','#userID#')
			SELECT Report_TypeID = @@IDENTITY
			SET NOCOUNT OFF
		</cfquery>
		<cfset Report_TypeID=q_ReportInsert.Report_TypeID>
		
		<cfset sSql=ReplaceNoCase(sSql,"--Report_Type_ID--",Report_TypeID,"All")>
		
		<cfquery name="q_ReportStructureInsert" datasource="#application.datasource#">
			#preserveSingleQuotes(sSql)#
		</cfquery>
		
		<cfquery name="q_ReportTemplateInsert" datasource="#application.datasource#">
			Insert into Report_Template
				(Report_Type_ID,Report_Name,Report_StartDate,Report_EndDate,Report_StartTime,Report_Interval,Report_EmailAddress)
			Values
				(#Report_TypeID#,'#Form.rName#','#sStartDate#','#sEndDate#','#rStartTime#','#Form.rInterval#','#Form.rEmailAddress#')
		</cfquery>
		
		
		
		<cftransaction action = "commit"/>
		<cfset commited=true>
		
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<P>#cfcatch.message#</P>
			</cfcatch>	
		</cftry>
		</cftransaction>
	</cfif>
	<!------------------End 1. Insert into db tables----------------------------->
	
	<!------------------ 2. Schedule the file ------------------------------------>
	<cfif commited>
		<cfset thisPath="#Application.Doc_Path#\data_files\created\reportwriter\schedule\saveReports\">
		<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/ReportWriter/schedule/schReport.cfm?rID=#Report_TypeID#">
		
		<cfset dStartDate=DateFormat(CreateDate(Right(Form.rStartDate,4),Left(Form.rStartDate,2),Mid(Form.rStartDate,4,2)),"MM/DD/YYYY")>
		<cfif isDate(Form.rEndDate)>
			<cfset dEndDate=DateFormat(CreateDate(Right(Form.rEndDate,4),Left(Form.rEndDate,2),Mid(Form.rEndDate,4,2)),"MM/DD/YYYY")>
		<cfelse>
			<cfset dEndDate="">
		</cfif>
		<!---
			D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
			Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
			"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
		--->		
		<cfschedule action = "update"
		  task = "#PREFIX##Form.rReportType##Report_TypeID#" 
		  operation = "HTTPRequest"
		  url = "#scURL#"
		  startDate = "#dStartDate#"
		  enddate = "#dEndDate#"
		  startTime = "#rStartTime#"
		  interval = "#Form.rInterval#"
		  resolveURL = "Yes"
		  publish = "Yes"
		  file = "scReport#Report_TypeID#.log"	<!--- D57544 --->
		  path = "#thisPath#"
		  username = "#rUserName#"
		  password = "#rPassword#"
		  requestTimeOut = "600">
	</cfif>
	<!------------------ 2. End Schedule the file ------------------------------------>
	
	<!------------------End 3. Redirect to next page ----------------------------->
	<CFLOCATION url="#reportDetailsPage#?rID=#Report_TypeID#&action=#dbAction#" ADDTOKEN=false>
	<!------------------End 3. Redirect to next page ----------------------------->
	
<cfelse>
	
	
	<cfset sErr=true>
	<cfset reportType=Form.rReportType>
	<CFINCLUDE TEMPLATE="#reportPage#">
	
</cfif>
</cfoutput>
<!------------------- End Do some action ------------------->

