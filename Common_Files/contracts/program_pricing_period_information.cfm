





<CFSET TodaysDate = DateFormat(Now(),'m-d-yyyy')>


<!--- initialize --->
<CFSET periods 													= StructNew()>
<CFSET periods.Debug 											= 0>
<CFSET periods.Program_ID										= 0>
<CFSET allPeriods 												= QueryNew("Deleted")>
<CFIF isdefined("getInfoForProgramID")>
	<CFIF IsNumeric(getInfoForProgramID)>
	<CFSET periods.Program_ID = getInfoForProgramID>
		<CFQUERY NAME="allPeriods" datasource="#application.datasource#">
			SELECT *
			FROM Program_Formula_Pricing_Periods
			WHERE 
				Active = 1
				AND
				Deleted = 0
				AND
				Program_ID = #periods.Program_ID#
		</CFQUERY>
		
		<CFQUERY NAME="Get_Program_Start_Date" DATASOURCE="#application.datasource#">
			SELECT	Contract_Start_Date
			FROM	Contract_Main
			WHERE
					Contract_Main.Contract_Main_ID = #periods.Program_ID#
		</CFQUERY>
		<CFIF Get_Program_Start_Date.recordCOunt GT 0>
			<CFSET TodaysDate = Get_Program_Start_Date.Contract_Start_Date>
		</CFIF>
		
	</CFIF>
</CFIF>


<CFSET periods.Period_Current 									= StructNew()>
<CFSET periods.Period_Current.Release_Date 						= "">
<CFSET periods.Period_Current.Start_Date 						= "">
<CFSET periods.Period_Current.End_Date 							= "">
<CFSET periods.Period_Current.ValidData 						= 0>
<CFSET periods.Period_Current.Program_Formula_Pricing_Period_ID	= "">


<CFSET periods.Period_Next 										= StructNew()>
<CFSET periods.Period_Next.Release_Date 						= "">
<CFSET periods.Period_Next.Start_Date 							= "">
<CFSET periods.Period_Next.End_Date 							= "">
<CFSET periods.Period_Next.ValidData 							= 0>
<CFSET periods.Period_Next.Program_Formula_Pricing_Period_ID	= "">


<CFSET periods.Period_Last 										= StructNew()>
<CFSET periods.Period_Last.Release_Date 						= "">
<CFSET periods.Period_Last.Start_Date 							= "">
<CFSET periods.Period_Last.End_Date 							= "">
<CFSET periods.Period_Last.ValidData 							= 0>
<CFSET periods.Period_Last.Program_Formula_Pricing_Period_ID	= "">


<CFSET periods.Requested_Period_Info									= StructNew()>
<CFSET periods.Requested_Period_Info.Release_Date 						= "">
<CFSET periods.Requested_Period_Info.Start_Date 						= "">
<CFSET periods.Requested_Period_Info.End_Date 							= "">
<CFSET periods.Requested_Period_Info.ValidData 							= 0>
<CFIF NOT isdefined("getInfoForPeriod")>
	<CFSET periods.Requested_Period_Info.Requested_Period = "curr">	
<CFELSE>
	<CFSET periods.Requested_Period_Info.Requested_Period = lcase(getInfoForPeriod)> 
</CFIF>
<!--- curr --->
<!--- last --->
<!--- next --->
<!--- any --->
<CFSET periods.Requested_Period_Info.Program_Formula_Pricing_Period_ID	= "">


<!--- Period_Current --->
<CFQUERY NAME="currentPeriod" DBTYPE="query" MAXROWS="1">
	SELECT *
	FROM allPeriods
	WHERE 
		Start_Date 		<= '#TodaysDate#'
		AND End_Date 	>= '#TodaysDate#'
</CFQUERY>

<CFIF currentPeriod.recordcount GT 0>
	<CFSET periods.Period_Current.ValidData 							= 1>
	<CFSET periods.Period_Current.Release_Date 							= DateFormat(currentPeriod.Release_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Current.Start_Date 							= DateFormat(currentPeriod.Start_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Current.End_Date 								= DateFormat(currentPeriod.End_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Current.Program_Formula_Pricing_Period_ID 	= currentPeriod.Program_Formula_Pricing_Period_ID>	
</CFIF>
<!--- Period_Current --->


<!--- Period_Next --->
<CFQUERY NAME="nextPeriod" DBTYPE="query" MAXROWS="1">
	SELECT *
	FROM allPeriods
	WHERE 
		Start_Date 	>= '#TodaysDate#'
		ORDER BY Start_Date 	ASC
</CFQUERY>

<CFIF nextPeriod.recordcount GT 0>
	<CFSET periods.Period_Next.ValidData 							= 1>
	<CFSET periods.Period_Next.Release_Date 						= DateFormat(nextPeriod.Release_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Next.Start_Date 							= DateFormat(nextPeriod.Start_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Next.End_Date 							= DateFormat(nextPeriod.End_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Next.Program_Formula_Pricing_Period_ID 	= nextPeriod.Program_Formula_Pricing_Period_ID>
</CFIF>
<!--- Period_Next --->


<!--- Period_Last --->
<CFQUERY NAME="lastPeriod" DBTYPE="query" MAXROWS="1">
	SELECT *
	FROM allPeriods
	WHERE 
		End_Date < '#TodaysDate#'
		ORDER BY Start_Date 	DESC
</CFQUERY>

<CFIF lastPeriod.recordcount GT 0>
	<CFSET periods.Period_Last.ValidData = 1>
	<CFSET periods.Period_Last.Release_Date 						= DateFormat(lastPeriod.Release_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Last.Start_Date 							= DateFormat(lastPeriod.Start_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Last.End_Date 							= DateFormat(lastPeriod.End_Date,'mm-dd-yyyy')>
	<CFSET periods.Period_Last.Program_Formula_Pricing_Period_ID 	= lastPeriod.Program_Formula_Pricing_Period_ID>
</CFIF>
<!--- Period_Last --->




<!--- save requested data --->
<CFSET PERIOD_INFO_SOURCE = "">

<CFSWITCH EXPRESSION="#periods.Requested_Period_Info.Requested_Period#">
	<!--- current period --->
	<CFCASE VALUE="curr">
		<CFIF periods.Period_Current.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Current">
		</CFIF>
	</CFCASE>
	<!--- next period --->
	<CFCASE VALUE="next">
		<CFIF periods.Period_Next.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Next">
		</CFIF>
	</CFCASE>
	<!--- last period --->
	<CFCASE VALUE="last">
		<CFIF periods.Period_Last.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Last">
		</CFIF>
	</CFCASE>	
	<!--- any case avaiable --->
	<CFCASE VALUE="any">
		<CFSET FoundOne = 0>		
		<CFIF FoundOne EQ 0 AND periods.Period_Current.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Current">
			<CFSET FoundOne = 1>
		</CFIF>
		<CFIF FoundOne EQ 0 AND periods.Period_Next.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Next">
			<CFSET FoundOne = 1>
		</CFIF>
		<CFIF FoundOne EQ 0 AND periods.Period_Last.ValidData EQ 1>
			<CFSET PERIOD_INFO_SOURCE = "Period_Last">
			<CFSET FoundOne = 1>
		</CFIF>
	</CFCASE>
</CFSWITCH>

<CFIF len(trim(PERIOD_INFO_SOURCE))>
	<CFSET periods.Requested_Period_Info.Release_Date						= evaluate("periods.#PERIOD_INFO_SOURCE#.Release_Date")>
	<CFSET periods.Requested_Period_Info.Start_Date							= evaluate("periods.#PERIOD_INFO_SOURCE#.Start_Date")>
	<CFSET periods.Requested_Period_Info.End_Date							= evaluate("periods.#PERIOD_INFO_SOURCE#.End_Date")>
	<CFSET periods.Requested_Period_Info.Program_Formula_Pricing_Period_ID 	= evaluate("periods.#PERIOD_INFO_SOURCE#.Program_Formula_Pricing_Period_ID")>
	<CFSET periods.Requested_Period_Info.ValidData							= 1>
</CFIF>

<CFIF periods.Debug EQ 1>
	<CFDUMP VAR="#periods#">
	<CFDUMP VAR="#allPeriods#">
</CFIF>

