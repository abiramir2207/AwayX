<cfcomponent extends="components.AjaxCFC.ajax">

<!--- This function is called in AJAX, which in turn calls "getMarginLogInfo" to check 
	  the status of the margin call. I made a seperate function so that "getMarginLogInfo" 
	  can be used by non-AJAX calls too.
--->
<cffunction name="getAJAXMarginLogInfo" output="false" returntype="array">
 <cfargument name="Program_ID" type="numeric" required="true" />

	<cfset ArrayMarginLog = getMarginLogInfo(arguments.Program_ID)>

	<cfreturn ArrayMarginLog>
</cffunction>

<!--- This function returns the status of the margin call. --->
<cffunction name="getMarginLogInfo" output="false" returntype="array">
 <cfargument name="Program_ID" type="numeric" required="true" />
	<cfset ArrayMarginLog = ArrayNew(1)>
	<cfquery name="qgetMarginLogInfo" datasource="#application.datasource#">
		SELECT Program_Margin_Log.Processed_Product_Count
		,Program_Margin_Log.Total_Product_Count
		,Program_Margin_Log_Status.Status
		,_Users.Name_First + ' ' + _Users.Name_Last As MarginCreatorName
		,Program_Margin_Log_Status.Created_Date
		,Contract_Main.Contract_Status_Type_IDX
		,Datediff("d",Program_Margin_Log_Status.Created_Date,getdate()) As MarginPeriodInDays
		,Program_Margin_Log_Status.Unit_Of_Time
		FROM Program_Margin_Log WITH (NOLOCK)
		RIGHT JOIN Program_Margin_Log_Status WITH (NOLOCK)
		ON Program_Margin_Log.Program_ID = Program_Margin_Log_Status.Program_ID
		RIGHT JOIN Contract_Main WITH (NOLOCK)
		ON Program_Margin_Log_Status.Program_ID = Contract_Main.Contract_Main_ID
		INNER JOIN _Users WITH (NOLOCK)
		ON _Users.User_ID = Program_Margin_Log_Status.User_ID
		WHERE Program_Margin_Log_Status.Program_ID = '#arguments.Program_ID#'
	</cfquery>

			<cfset ArrayMarginLog[1] = qgetMarginLogInfo.Processed_Product_Count>
			<cfset ArrayMarginLog[2] = qgetMarginLogInfo.Total_Product_Count>
			<cfset ArrayMarginLog[3] = qgetMarginLogInfo.Status>
			<cfset ArrayMarginLog[4] = qgetMarginLogInfo.Recordcount>
			<cfset ArrayMarginLog[5] = qgetMarginLogInfo.MarginCreatorName>
			<cfset ArrayMarginLog[6] = qgetMarginLogInfo.Created_Date>
		<cfif qgetMarginLogInfo.recordcount neq 0>
			<cfset ArrayMarginLog[7] = qgetMarginLogInfo.MarginPeriodInDays>
			<cfset ArrayMarginLog[8] = Datediff("n",qgetMarginLogInfo.Created_Date,now())>
		<cfelse>
			<cfset ArrayMarginLog[7] = "">
			<cfset ArrayMarginLog[8] = "">
		</cfif>
			<cfset ArrayMarginLog[9] = qgetMarginLogInfo.Contract_Status_Type_IDX>
			<cfset ArrayMarginLog[10] = qgetMarginLogInfo.Unit_Of_Time>
	<cfreturn ArrayMarginLog>
</cffunction>

<!--- This table stores the progress of the product count after margin call --->
<cffunction name="setMarginLogInfo" output="false">
 <cfargument name="Program_ID" type="numeric" required="true" />
	<cfset useLakebaseForqsetMarginLogInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_margin_log")>
<cfif useLakebaseForqsetMarginLogInfo>
	<cftry>
		<cfset application.oLakebase.insertRow("program_margin_log", {
			"program_id" = "#arguments.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqsetMarginLogInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqsetMarginLogInfo>
<cfquery name="qsetMarginLogInfo" datasource="#application.datasource#">
		INSERT INTO Program_Margin_Log(Program_ID)
		VALUES('#arguments.Program_ID#')
	</cfquery>
</cfif>
	<cfreturn 1 />
</cffunction>

<!--- This table stores the status (Processing,Processed) and the user of the margin call --->
<cffunction name="setMarginLogStatusInfo" output="false">
 <cfargument name="Program_ID" type="numeric" required="true" />
 <cfargument name="User_ID" type="string" required="true" />
 <cfargument name="Status" type="numeric" required="true" />
 <cfargument name="Unit_Of_Time" type="numeric" required="false" default="0" />

	<cfif ! arguments.Unit_Of_Time>
		<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
			Select		ISNULL(Margin_UOT_ID, 0) AS Margin_UOT_ID
			From		_Users_Settings
			Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
		</CFQUERY>
		<cfset arguments.Unit_Of_Time = Get_Settings.Margin_UOT_ID>
	</cfif>

	<cfquery name="qsetMarginLogStatusInfo" datasource="#application.datasource#">
		INSERT INTO Program_Margin_Log_Status(Program_ID,User_ID,Status,Unit_Of_Time)
		VALUES('#arguments.Program_ID#','#arguments.User_ID#','#arguments.Status#',#arguments.Unit_Of_Time#)
	</cfquery>
	<cfreturn 1 />
</cffunction>

<!--- This table stores the progress of the product count after margin the call --->
<cffunction name="DeleteMarginLogInfo" output="false">
 <cfargument name="Program_ID" type="numeric" required="true" />
	<cfset useLakebaseForqDeleteMarginLogInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_margin_log")>
<cfif useLakebaseForqDeleteMarginLogInfo>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_margin_log", {
			"program_id" = "eq.#arguments.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteMarginLogInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteMarginLogInfo>
<cfquery name="qDeleteMarginLogInfo" datasource="#application.datasource#">
		DELETE
		FROM Program_Margin_Log
		WHERE Program_ID = '#arguments.Program_ID#'
	</cfquery>
</cfif>
	<cfreturn 1 />
</cffunction>

<!--- This table stores the status (Processing,Processed) and the user of the margin call --->
<cffunction name="DeleteMarginLogStatusInfo" output="false">
 <cfargument name="Program_ID" type="numeric" required="true" />
	<cfset useLakebaseForqDeleteMarginLogStatusInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_margin_log_status")>
<cfif useLakebaseForqDeleteMarginLogStatusInfo>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_margin_log_status", {
			"program_id" = "eq.#arguments.Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteMarginLogStatusInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteMarginLogStatusInfo>
<cfquery name="qDeleteMarginLogStatusInfo" datasource="#application.datasource#">
		DELETE
		FROM Program_Margin_Log_Status
		WHERE Program_ID = '#arguments.Program_ID#'
	</cfquery>
</cfif>
	<cfreturn 1 />
</cffunction>

<!--- This table updates the status to "Processed" and the margin calculation is completed successfully --->
<cffunction name="UpdateMarginLogStatusInfo" output="false">
 <cfargument name="Program_ID" type="numeric" required="true" />
  <cfargument name="Status" type="numeric" required="true" />
	<cfset useLakebaseForqUpdateMarginLogStatusInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_margin_log_status")>
<cfif useLakebaseForqUpdateMarginLogStatusInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("program_margin_log_status",
			{
				"program_id" = "eq.#arguments.Program_ID#"
			},
			{
				"status" = "#arguments.Status#",
				"completed_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateMarginLogStatusInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateMarginLogStatusInfo>
<cfquery name="qUpdateMarginLogStatusInfo" datasource="#application.datasource#">
		UPDATE Program_Margin_Log_Status
		SET Status = '#arguments.Status#',
		Completed_Date = getDate()
		WHERE Program_ID = '#arguments.Program_ID#'
	</cfquery>
</cfif>
	<cfreturn 1 />
</cffunction>

</cfcomponent>