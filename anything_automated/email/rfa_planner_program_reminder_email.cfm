<cfscript>
	LocationFrom    = "Auto";
	userManager     = CreateObject("component", "components.user.UserManager");
	uEmail          = userManager.getCurrentSystemAdmin().User_Email;

	is_debugging    = false;  // D83038 - TODO - change it to false before checking the code in CVS
	developer_email = ( cgi.http_host contains ".stage." and is_debugging
							? "johnDoe@blacksmithapplications.com"
							: '' );
</cfscript>

<!---Programs in need of approval START--->
<cfquery name="qGetProgramsInNeedApproval" datasource="#application.datasource#">
	SELECT DISTINCT Contract_Main.Contract_Main_ID,
					u.User_Email,
					Planners.Planner_Number,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_End_Date
	FROM   Planner_Template
		INNER JOIN Planners
				ON Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
					AND Planners.Deleted = 0
		INNER JOIN Contract_Main
				ON Contract_Main.Planner_ID = Planners.Planner_ID
					AND Contract_Main.Contract_Status_Type_IDX = 2
					AND Contract_Main.Deleted = 0
					AND ( Isnull(Contract_Main.Planner_ID, 0) <> 0 )
					AND Datediff(day, Getdate(), Contract_Start_Date) <= Isnull(Alert_Pending_Accept_Programs_Days, 0)  -- 83038
					AND Datediff(day, Getdate(), Contract_End_Date) > 0   -- 83038
		INNER JOIN Contract_Main_Aux_Data
				ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND Contract_Main_Aux_Data.RFA_Email_Sent = 0
		INNER JOIN _Users u
				ON u.User_ID = Contract_Main.Responsible_User_ID
	ORDER  BY Planners.Planner_Number
</cfquery>

<!---For each record returned--->
<cfoutput query="qGetProgramsInNeedApproval" group="User_Email">
	<!--- keep track of programs in the process -- 83038--->
	<cfset programs = []>

	<cfsavecontent variable="email_content">
	<table cellspacing="5">
		<tr>
			<td>
				<b>#Application.PlannerLabel# ##</b>
			</td>
			<td>
				<b>#Application.PlannerPrgLabel# ##</b>
			</td>
			<td>
				<b>#Application.PlannerPrgLabel# Title</b>
			</td>
			<td>
				<b>Delivery Start Date</b>
			</td>
		</tr>
		<cfoutput>
		<!--- keep track of programs in the process -- 83038 --->
		<cfset arrayAppend(programs, qGetProgramsInNeedApproval.Contract_Main_ID)>
		<tr>
			<td>
				#Planner_Number#
			</td>
			<td>
				#Contract_Number#
			</td>
			<td>
				#Contract_Title#
			</td>
			<td>
				#dateformat(Contract_Start_Date, "mm/dd/yyyy")#
			</td>
		</tr>

		</cfoutput>
	</table>
	</cfsavecontent>

	<CF_EMAILWRAPPER
		TO		=	"#User_Email#"
		CC      =   "#developer_email#"
		FROM 	=	"#uEmail#"
		subject="Programs in need of approval"
		TYPE		=	"html"
		messagetype="1"
		generatedby="2"
		appArea="1"
	>
	#email_content#

	</CF_EMAILWRAPPER>

	<!--- flag programs as sent -- 83038 --->
	<cfquery datasource="#application.datasource#">
		UPDATE Contract_Main_Aux_Data
		   SET RFA_Email_Sent = 1
		 WHERE Contract_Main_ID IN (<cfqueryparam value="#arrayToList(programs)#" cfsqltype="cf_sql_integer" list="true">)
	</cfquery>
</cfoutput>
<!---Programs in need of approval START--->


<!---Programs in need of customer commitment START--->
<cfquery name="qGetProgramsInNeedCommitment" datasource="#application.datasource#">

	SELECT DISTINCT Contract_Main.Contract_Main_ID,
					u.User_Email,
					Planners.Planner_Number,
					Contract_Main.Contract_Number,
					Contract_Main.Contract_Title,
					Contract_Main.Contract_Start_Date,
					Contract_Main.Contract_End_Date
	FROM   Planner_Template
		INNER JOIN Planners
				ON Planners.Planner_Template_ID = Planner_Template.Planner_Template_ID
					AND Planners.Deleted = 0
		INNER JOIN Contract_Main
				ON Contract_Main.Planner_ID = Planners.Planner_ID
					AND Contract_Main.Contract_Status_Type_IDX = 10
					AND Contract_Main.Deleted = 0
					AND ( Isnull(Contract_Main.Planner_ID, 0) <> 0 )
					AND Datediff(day, Getdate(), Contract_Start_Date) <= Isnull(Alert_Pending_Accept_Programs_Days, 0)
					AND Datediff(day, Getdate(), Contract_End_Date) > 0 -- 83038
		INNER JOIN Contract_Main_Aux_Data
				ON Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
					AND Contract_Main_Aux_Data.Pending_Status_Email_Sent = 0
		INNER JOIN _Users u
				ON u.User_ID = Contract_Main.Responsible_User_ID
	ORDER  BY Planners.Planner_Number

</cfquery>

<!---For each record returned--->
<cfoutput query="qGetProgramsInNeedCommitment" group="User_Email">

	<!--- keep track of programs in the process -- 83038 --->
	<cfset programs = []>

	<cfsavecontent variable="email_content">
	<table cellspacing="5">
		<tr>
			<td>
				<b>#Application.PlannerLabel# ##</b>
			</td>
			<td>
				<b>#Application.PlannerPrgLabel# ##</b>
			</td>
			<td>
				<b>#Application.PlannerPrgLabel# Title</b>
			</td>
			<td>
				<b>Delivery Start Date</b>
			</td>
		</tr>
		<cfoutput>
		<!--- keep track of programs in the process -- 83038 --->
		<cfset arrayAppend(programs, qGetProgramsInNeedCommitment.Contract_Main_ID)>
		<tr>
			<td>
				#Planner_Number#
			</td>
			<td>
				#Contract_Number#
			</td>
			<td>
				#Contract_Title#
			</td>
			<td>
				#dateformat(Contract_Start_Date, "mm/dd/yyyy")#
			</td>
		</tr>

		</cfoutput>
	</table>
	</cfsavecontent>


	<CF_EMAILWRAPPER
		TO		=	"#User_Email#"
		CC      =   "#developer_email#"
		FROM 	=	"#uEmail#"
		subject="#Application.PlannerPrgLabel# in need of customer commitment"
		TYPE		=	"html"
		messagetype="1"
		generatedby="2"
		appArea="1"
	>
	#email_content#

	</CF_EMAILWRAPPER>

	<!--- flag programs as sent -- 83038 --->
	<cfquery datasource="#application.datasource#">
		UPDATE Contract_Main_Aux_Data
		   SET Pending_Status_Email_Sent = 1
		 WHERE Contract_Main_ID IN (<cfqueryparam value="#arrayToList(programs)#" cfsqltype="cf_sql_integer" list="true">)
	</cfquery>

</cfoutput>
<!---Programs in need of customer commitment START--->
