<cfcomponent hint="Methods that interface with Ajax calls and use arrays for i/o">
	<cffunction name="init" output="false" returntype="components.billback.BBAutoReportAjaxCaller">
		<cfreturn this />
	</cffunction>
	<cffunction name="setObject" output="false" returntype="Void">
	<!--- Initialize Main Objects --->
		<cfif NOT structKeyExists(application,"oBBReportGet")>
				<cfset application.oBBReportGet = CreateObject("component","components.Billback.BBAutoReportGet").init() />
				<cfset application.oBBReportUpdate = CreateObject("component","components.Billback.BBAutoReportUpdate").init() />
		</cfif>
			<cfset This.oGet	= application.oBBReportGet />
			<cfset This.oUpdate	= application.oBBReportUpdate />
	</cffunction>

<!--- 
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXX		Action Callers used by ajax
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--->
<!--- USAGE:
The Calling Javascript expects an array(4) returned -> retvar[].
1 Action = the html to populate the action td
2 reportid used to hide the "loading" image
3 Html describing updated user and date
4 Html containing the report status	 --->
<!--- XXXXXXXXXXXX	Cancel Report Caller	XXXXXXXXXXXX --->
	<cffunction name="cancelReportCaller" access="public" returntype="array" output="true">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var reportId	= argArray[1] />
		<cfset var userId	= argArray[2] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var cancel = this.oUpdate.cancelReport(	reportID=reportID,
														userId=userId) />
		<cfset var report = this.oGet.getReportPeriod(reportId) />
		<!--- send an empty status and 0 reportid since we just cancelled --->
		<cfset retVar[1] = This.oGet.getCreateReportIcon(1) />
		<!--- <cfset retVar[1] = This.oGet.getAction(reportID = 0,
												periodId = report.bb_auto_report_period_id,
												status = '') /> --->
		<cfset retVar[2] = reportId /><!--- report.bb_auto_report_period_id --->
		<cfset retVar[3] = report.last&": "&this.oGet.formatDate(report.updated_date)/>
		<cfset retVar[4] = this.oGet.getReportStatus(0) />
		<cfreturn retVar />
	</cffunction>
	
<!--- XXXXXXXXXXXX	Create Report Caller	XXXXXXXXXXXX --->
	<cffunction name="createReportCaller" access="public" returntype="array" output="true">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var periodId	= argArray[1] />
		<cfset var userId	= argArray[2] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var reportID = this.oUpdate.createReport(	periodId=periodId,
														userId=userId)>
		<cfset var updated = this.oGet.getReportPeriod(reportID) />
		<!--- send 1 status since we just created --->
		<cfset retVar[1] = This.oGet.getAction(	reportID = reportID,
												periodId = periodId,
												status = 1) />
		<cfset retVar[2] = reportID />
		<cfset retVar[3] = updated.last&": "&this.oGet.formatDate(updated.updated_date) />
		<cfset retVar[4] = this.oGet.getReportStatus(1) />
		<cfset retVar[5] = dateformat(this.oGet.getReportPeriod(reportID).end_date,"mmmm yy") />
		<cfset retVar[6] = This.oGet.getCreateReportIcon(0) />
		<cfreturn retVar />
	</cffunction>
<!--- XXXXXXXXXXXX	Save Programs Caller XXXXXXXXXXXX --->
	<cffunction name="saveProgramCaller" access="public" returntype="array">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var reportID	= argArray[1] />
		<cfset var userId	= argArray[2] />
		<cfset var programList	= argArray[3] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var save = this.oUpdate.saveBBReportProgram(reportID = reportID,
														userId = userId,
														programList = programList) />
		<cfset var updated = this.oGet.getReportPeriod(reportID) />
		<!--- send 4 status since we just approved --->
		<cfset retVar[1] = This.oGet.getAction(	reportID = reportID,
												periodId = updated.bb_auto_report_period_id,
												status = 1) />
		<cfset retVar[2] = reportID />
		<cfset retVar[3] = updated.last&": "&this.oGet.formatDate(updated.updated_date) />
		<cfset retVar[4] = this.oGet.getReportStatus(1) />
		<cfreturn retVar />
  	</cffunction> 

<!--- XXXXXXXXXXXX	Approve Report	Caller XXXXXXXXXXXX --->
	<cffunction name="approveReportCaller" access="public" returntype="array">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var reportID	= argArray[1] />
		<cfset var userId	= argArray[2] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var approve = this.oUpdate.approveReport(reportID=reportID,
														userId=userId) />
		<cfset var updated = this.oGet.getReportPeriod(reportID) />
		<!--- send 4 status since we just approved --->
		<cfset retVar[1] = This.oGet.getAction(	reportID = reportID,
												periodId = updated.bb_auto_report_period_id,
												status = 4) />
		<cfset retVar[2] = reportID />
		<cfset retVar[3] = updated.last&": "&this.oGet.formatDate(updated.updated_date) />
		<cfset retVar[4] = this.oGet.getReportStatus(4) />
		<cfreturn retVar />
  	</cffunction> 
	
<!--- XXXXXXXXXXXX	Delete Report	Caller XXXXXXXXXXXX --->
	<cffunction name="deleteReportCaller" access="public" returntype="array">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var reportID	= argArray[1] />
		<cfset var periodId	= argArray[2] />
		<cfset var userId	= argArray[3] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var delete = this.oUpdate.deleteReport(	reportID	= reportID,
														periodId	= periodId,
														userId		= userId) />
		<cfset var updated = this.oGet.getReportPeriod(reportID) />											
		<!--- send 0 status since we just deleted --->
		<cfset retVar[1] = updated />
												<!--- getAction(	reportID = 0,
												periodId = periodId,
												status = 0) --->
		<cfset retVar[2] = reportID />
		<cfset retVar[3] = "Create: "& this.oGet.formatDate(now()) />
		<cfset retVar[4] = this.oGet.getReportStatus(0) />
		<cfset retVar[5] = delete />
		<cfreturn retVar />
  	</cffunction>
	
<!--- XXXXXXXXXXXX    Pause ReCalc  Caller XXXXXXXXXXXX --->	
	<cffunction name="pauseReportCaller" access="public" returntype="array" output="true">
		<cfset var setObject = this.setObject() />
		<cfset var argArray = arguments[1] />
		<cfset var reportID	= argArray[1] />
		<cfset var periodId	= argArray[2] />
		<cfset var userId	= argArray[3] />
		<cfset var pause	= argArray[4] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var setRecalc = this.oUpdate.setRecalcReport(reportID	= reportID,
														userId		= userId,
														pause		= pause) />
		<cfset var updated = this.oGet.getReportPeriod(reportID) />
		<!--- send 2 status for recalc --->
		<cfset retVar[1] = This.oGet.getAction(	reportID= reportID,
												periodId= periodId,
												status	= 2,
												pause	= updated.Pause_Schedule) />
		<cfset retVar[2] = reportID />
		<cfset retVar[3] = updated.last&": "&this.oGet.formatDate(updated.updated_date) />
		<cfset retVar[4] = this.oGet.getReportStatus(2,updated.Pause_Schedule) />
		<cfreturn retVar />
	</cffunction>
	
<!--- XXXXXXXXXXXX    Resume Re-Calc Caller XXXXXXXXXXXX --->


<!--- 
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX    REPORT DETAIL LEVEL CALLERS      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
	
<!--- XXXXXXXXXXXX	Remove BB Caller XXXXXXXXXXXX --->
	<cffunction name="removeBBCaller"  access="remote" returntype="any" returnformat="JSON">
		<cfargument name="arg" type="any"> 
		<cfset var setObject 	= this.setObject() />
		   <!---	<cfdump var="#arg#" output="c:\dump.log"/>
		   	 ChromeFix ::  needed to switch to jquery for ajax.  2 deserialize calls were needed.  The first one removes escapes.  seems shakey but only way I could get it to work, --->
		<cfset x = DeserializeJSON(arg)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> --->
		<cfset x = DeserializeJSON(x)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> ChromeFix :: --->
		<cfset var argArray 	= x />
		<cfset var reportID		= argArray[1] />
		<cfset var userId		= argArray[2] />
		<cfset var BBId			= argArray[3] />
		<cfset var PayPeriodId	= argArray[4] />
		<cfset var retVar = ArrayNew(1) />
		<!--- should we try catch this? --->
		<cfset var delBB = this.oUpdate.removeBB(	reportID	= reportID,
													userId		= userId,
													PayPeriodId	= PayPeriodId)>
		<cfset var removed = this.oGet.getBBDetail(
													PayPeriodId	= PayPeriodId,
													Summary = 1) />
		<!--- send deleted bb num --->
		<cfset retVar[1] = "gray" />
		<cfset retVar[2] = PayPeriodId />
		<cfif application.oBBReportGet.getAutoPayType() EQ 1>
			<cfset retVar[3] = " Deleted::  "&removed.last&": "&this.oGet.formatDate(removed.updated_date) />
		<cfelse>
			<cfset retVar[3] = " Deleted::  "&this.oGet.formatDate(now()) />
		</cfif>
		<!--- <cfset retVar[4] = this.oGet.getBBStatus(3) /> --->
		<cfreturn retVar />
  	</cffunction>
	
<!--- XXXXXXXXXXXX	Recalc BB Caller XXXXXXXXXXXX --->
	<cffunction name="recalcBBCaller"  access="remote" returntype="any" returnformat="JSON">
		<cfargument name="arg" type="any"> 
		<cfset var setObject 	= this.setObject() />
		   <!---	<cfdump var="#arg#" output="c:\dump.log"/>
		   	 ChromeFix ::  needed to switch to jquery ofr ajax.  2 deserialize calls were needed.  The first one removes escapes.  seems shakey but only way I could get it to work, --->
		<cfset x = DeserializeJSON(arg)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> --->
		<cfset x = DeserializeJSON(x)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> ChromeFix :: --->
		<cfset var argArray 	= x />
		<cfset var reportID		= argArray[1] />
		<cfset var userId		= argArray[2] />
		<cfset var BBId			= argArray[3] />
		<cfset var PayPeriodId	= argArray[4] />
		<cfset var CalcNow		= argArray[5] />
		<cfset var retVar = ArrayNew(1) />
		<!--- should we try catch this? --->
		<cfset var recalcBB = this.oUpdate.recalcBB(reportID	= reportID,
													userId		= userId,
													CalcNow		= CalcNow,
													PayPeriodId	= PayPeriodId)>
		<cfset var recalc = this.oGet.getBBDetail(PayPeriodId	= PayPeriodId,
													Summary = 1) />
		<cfset var action = this.oGet.getBBDetailAction(reportID		= reportID,
															userId		= userId,
															BBId		= 0,
															PayPeriodId	= PayPeriodId,
															reportStatus= recalc.ReportStatus) />
		<!--- send deleted bb num --->
		<cfset retVar[1] = "green" />
		<cfset retVar[2] = recalc.BB_Auto_Program_Pay_Period_Id />
		<cfset retVar[3] = " Re-Calc::  "&recalc.last&": "&this.oGet.formatDate(recalc.updated_date) />
		<cfif recalc.BB_code EQ 'ReCalc'>
			<cfset retVar[4] = " Re-Calc" /> 
			<!---<cfset retVar[4] = recalc.Contract_Number />--->
		<cfelse>
			<cfset retVar[4] = #this.oGet.getBBLink(recalc.BB_Auto_Program_Pay_Period_Id)# />
		</cfif>
		<cfset retVar[5] = recalc.BB_Amount />
		<cfset retVar[6] = action />
		<cfset retVar[7] = recalc.Pullback_Applied_Amount />
		<!--- <cfset retVar[4] = this.oGet.getBBStatus(3) /> --->
		<cfreturn retVar />
  	</cffunction>

<!--- XXXXXXXXXXXX	Reverse BB Caller XXXXXXXXXXXX --->
	<cffunction name="reverseBBCaller" access="remote" returntype="any" returnformat="JSON" >
		<cfargument name="arg" type="any"> 
		<cfset var setObject 	= this.setObject() />
		   <!---	<cfdump var="#arg#" output="c:\dump.log"/>
		   	 ChromeFix ::  needed to switch to jquery for ajax.  2 deserialize calls were needed.  The first one removes escapes.  seems shakey but only way I could get it to work, --->
		<cfset x = DeserializeJSON(arg)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> --->
		<cfset x = DeserializeJSON(x)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> ChromeFix :: --->
		<cfset var argArray 	= x/>
		<cfset var reportID		= argArray[1] />
		<cfset var userId		= argArray[2] />
		<cfset var BBId			= argArray[3] />
		<cfset var PayPeriodId	= argArray[4] />
		<cfset var retVar = ArrayNew(1) />
		<cfset var reverseBB = this.oUpdate.reverseBB(reportID	= reportID,
													userId		= userId,
													PayPeriodId	= PayPeriodId)>
		<cfset var reverse = this.oGet.getBBDetail(PayPeriodId	= PayPeriodId,
													Summary = 1) />
		<!--- 
		<cfset var action = this.oGet.getBBDetailAction(reportID		= reportID,
															userId		= userId,
															BBId		= 0,
															PayPeriodId	= PayPeriodId,
															reportStatus= reverse.ReportStatus) />
		 --->
		<!--- send deleted bb num --->
		<cfset retVar[1] = "green" />
		<cfset retVar[2] = reverse.BB_Auto_Program_Pay_Period_Id />
		<cfset retVar[3] = " Reversed:: " & reverse.last & ": "&this.oGet.formatDate(reverse.updated_date) />
		<!--- 
		<cfif reverse.BB_code EQ 'ReCalc'>
			<cfset retVar[4] = reverse.Contract_Number />
		<cfelse>
			<cfset retVar[4] = #this.oGet.getBBLink(reverse.BB_Auto_Program_Pay_Period_Id, reportID)# />
		</cfif>
		<cfset retVar[5] = reverse.BB_Amount />
		<cfset retVar[6] = action />
		<cfset retVar[7] = reverse.Pullback_Applied_Amount />
		 --->
		<cfreturn retVar />
  	</cffunction>
  	<!--- XXXXXXXXXXXX	Approve BB Caller XXXXXXXXXXXX --->
	<cffunction name="approvePayPeriodCaller"  access="remote" returntype="any" returnformat="JSON">
		<cfargument name="arg" type="any"> 
		<cfset var setObject 	= this.setObject() />
		   <!---	<cfdump var="#arg#" output="c:\dump.log"/>
		   	 ChromeFix ::  needed to switch to jquery ofr ajax.  2 deserialize calls were needed.  The first one removes escapes.  seems shakey but only way I could get it to work, --->
		<cfset x = DeserializeJSON(arg)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> --->
		<cfset x = DeserializeJSON(x)/>
			<!--- <cfdump var="#x#" output="c:\dump.log"/> ChromeFix :: --->
		<cfset var argArray 	= x />
		<cfset var reportID		= argArray[1] />
		<cfset var userId		= argArray[2] />
		<cfset var PayPeriodId	= argArray[3] />
		<cfset var retVar = ArrayNew(1) />
		<!--- <cfdump var="#arguments#" output="c:\dump.log" > --->
		<!--- should we try catch this? --->
		<cfset var approveBB = this.oUpdate.approvePayPeriod(	reportID	= reportID,
													periodId	= PayPeriodId,
													userId		= userId)>
		<cfset var approve = this.oGet.getBBDetail(
													PayPeriodId	= PayPeriodId,
													Summary = 1) />
		<cfset var action = this.oGet.getBBDetailAction(reportID		= reportID,
															userId		= userId,
															BBId		= "BB",
															PayPeriodId	= PayPeriodId,
															reportStatus= approve.ReportStatus,
															BBStatus = 4) />
		<!--- send deleted bb num --->
		<cfset retVar[1] = "green" />
		<cfset retVar[2] = approve.BB_Auto_Program_Pay_Period_Id />
		<cfset retVar[3] = " Re-Calc" />   <!---::  "&approve.last&": "&this.oGet.formatDate(approve.updated_date) />--->
		<cfif approve.BB_code EQ 'ReCalc'>
			<cfset retVar[4] = " Re-Calc" />   <!---approve.Contract_Number--->
		<cfelse>
			<cfset retVar[4] = #this.oGet.getBBLink(approve.BB_Auto_Program_Pay_Period_Id,reportID)# />
		</cfif>
		<cfset retVar[5] = approve.BB_Amount />
		<cfset retVar[6] = action />
		<cfset retVar[7] = approve.Pullback_Applied_Amount />
		<!--- <cfset retVar[4] = this.oGet.getBBStatus(3) /> --->
		<cfreturn retVar />
  	</cffunction>
  	
  	<cffunction name="BBUpdate" access="remote" returntype="any" returnformat="JSON" hint="THIS FUNCTION IS USED TO UPDATE BB NUMBER AND REFERENECE NUMBER">
  		<cfargument name="arg" type="any">
  		<cfargument name="type" type="integer">
		<cfargument name="value" type="any">
		
		<cfset x = DeserializeJSON(arg)/>
		<cfset x = DeserializeJSON(x)/>
		<cfset BBIDs = ArrayToList(x)>
		
			<CFQUERY NAME="qEmberInfo" datasource="#application.datasource#">
				UPDATE 	Billback
				SET  <cfif type EQ 1>BB_Reference <cfelse>referenceNum</cfif> = '#value#'
				Where 		Billback_ID IN  ( <cfqueryparam list="true" value="#BBIDs#">)
				AND 		deleted = 0
			</CFQUERY>
			<cfreturn 1 />
  	</cffunction>
  	
</cfcomponent>