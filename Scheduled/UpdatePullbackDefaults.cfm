


<cfset u = '0724C1EF-19B9-E720-2298C1208F9F9836'>


<CFQUERY NAME="getOprContarcts" datasource="#application.datasource#">
	SELECT Contract_Main_Id,generic_type,Pullbacks_On,Contract_Number
	FROM Contract_Main CM
	JOIN dbo.Program_Control_Panel_Options PC on
		PC.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
	WHERE 
			CM.Deleted = 0 AND
			CM.Approved = 1 AND
			PC.Pullbacks_On = 1 AND
			CM.Contract_End_Date > '2012-05-01 00:00:00.000' AND 
			(PC.generic_type = 'Operator Direct or HQ Programs' OR 
			PC.generic_type = 'Operator-Deviated Pricing')
			AND Contract_Main_Id not in (select distinct pullback_program_id from Pullbacks_Distributors_Defaults)
</CFQUERY>


<cfloop query="getOprContarcts">
	<cfif (getOprContarcts.generic_type EQ "Operator Direct or HQ Programs" OR 
		  getOprContarcts.generic_type EQ "Operator-Deviated Pricing") and 
		  getOprContarcts.Pullbacks_On EQ 1>
	
	
	 	<cfset p = getOprContarcts.Contract_Main_Id>
	
		<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") >
		<cfset tmp = PullbackManager.InsertDefaultsonRFA(p,u) >
	</cfif>
	UPDATED <cfoutput>#getOprContarcts.Contract_Number#</cfoutput> <br>
</cfloop>