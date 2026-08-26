<!DOCTYPE HTML>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\performance_req.cfm
      Date:     2015 June
      Author:   Chris Nguyen
      Purpose:  Display performance requirements
----------------------------------------------------------------------------------------------------------------------->
<!---get all data--->
<cfinvoke component = "components.programs.program" method = "getProgramInfo" returnVariable = "variables.programInfo">
	<cfinvokeargument name="programId" value="#url.program_ID#">
</cfinvoke>
<cfinvoke component = "components.customer.operator.Category" method = "getCategory" returnVariable = "variables.categories"></cfinvoke>
<cfinvoke component = "components.customer.operator.Priority" method = "getPriority" returnVariable = "variables.priorities"></cfinvoke>

<!--- <cfquery name="variables.templateRequirements" datasource="#application.datasource#">
	SELECT 	DISTINCT Program_Perf_Req.Requirement_Name,
			Program_Perf_Req.Program_Perf_Req_ID,
			Program_Perf_Req.PR_Operator_Category,
			Program_Perf_Req.PR_Operator_Priority,
			Program_Perf_Req.PR_Date_Range,
			Program_Perf_Mapping.Program_Perf_Req_Checked,
			Program_Perf_Req.Allow_Change_On_Revision
	FROM 	Program_Perf_Mapping
			INNER JOIN Program_Perf_Req ON
			Program_Perf_Req.Program_Perf_Req_ID = Program_Perf_Mapping.Program_Perf_Req_ID
	WHERE 	Program_Perf_Mapping.Template_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.programInfo.ProgramType_ID#">
</cfquery> --->
<cfquery name="variables.programRequirements" datasource="#application.datasource#">
	SELECT a.Program_Perf_req_Id
	       ,IsNull( Operator_Category_Id, 0 ) AS Operator_Category_Id
	       ,IsNull( Operator_Priority_Id, 0 ) AS Operator_Priority_Id
	       ,a.pr_Start_Date
	       ,a.pr_End_Date
	       ,a.checked
	       ,b.Requirement_Name
		   ,b.PR_Operator_Category
		   ,b.PR_Operator_Priority
		   ,b.PR_Date_Range
		   ,b.Allow_Change_On_Revision
		   ,c.Program_Perf_Req_Checked
	  FROM One_Program_Perf_Mapping a
	       INNER JOIN Program_Perf_Req b ON b.Program_Perf_Req_ID = a.Program_Perf_Req_ID
	       INNER JOIN Program_Perf_Mapping c ON c.Program_Perf_Req_ID = a.Program_Perf_Req_ID
	       									AND c.Template_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.programInfo.ProgramType_ID#">
	 WHERE a.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.programInfo.Contract_Main_ID#">
	       ---AND Checked = 1
</cfquery>
</cfsilent>

<html>
<head>
<title>Program - Performance Requirements</title>
<style type="text/css">
#actp727 { margin-top:15px; text-align:left }
#budget_form { margin-top:10px; }
#cancel729 { margin-left:30px; }
#fs727 { margin:0; padding:0 0px 0 0; border:0 none; border-top:1px solid; width:100%; clear:both; }
#fs727 legend { margin:3px 0 0 0; padding:0 5px; font:bold 16px; }
#hdr727 { font:bold 20px "Times New Roman"; color:red; margin:0; float:left;}
#tp727 { font:normal 12px; float:right; position:relative; top:10px; }
td { border:none; }
</style>
</head>

<body>
<!--- <cfdump var="#variables.templateRequirements#"> --->
<cfoutput>
<!---heading--->
<div id="hdr727">#application.returned_customer_setting.company_name#</div>
<div id="tp727"><b>Template:</b> #variables.programInfo.Created_Type#</div>
<fieldset id="fs727">
<legend>#variables.programInfo.Contract_Number#</legend>
<h3>Performance Requirements</h3>
<table cellspacing="3" cellpadding="3" border=0 style='table-layout:fixed;width:100%;'>
	<col width="65%">
	<col width="35%">
	<cfloop query="variables.programRequirements">
		<cfquery dbtype="query" name="variables.category">
			SELECT *
			  FROM categories
			 WHERE categories.Operator_Category_Id = #variables.programRequirements.Operator_Category_Id#
		</cfquery>
		<cfquery dbtype="query" name="variables.priority">
			SELECT *
			  FROM priorities
			 WHERE priorities.Operator_Priority_Id = #variables.programRequirements.Operator_Priority_Id#
		</cfquery>
		<tr>
			<td valign2="bottom">#variables.programRequirements.requirement_name#</td>
			<!--- checkbox yes/no --->
			<td>yes <input type="radio" #(variables.programRequirements.checked ? 'checked' : '')# disabled> &nbsp; no <input type="radio" #(variables.programRequirements.checked ? '' : 'checked')# disabled>
				<!--- category --->
				#(variables.programRequirements.pr_operator_category eq 1 ? variables.category.category_label : '')#
				<!--- priority --->
				#(variables.programRequirements.pr_operator_priority eq 1 ? variables.category.priority_label : '')#
				<!--- date range --->
				<cfif variables.programRequirements.pr_date_range eq 1>
						#(isDate(variables.programRequirements.pr_Start_Date) ? dateFormat(variables.programRequirements.pr_Start_Date, 'mmm d, yyyy') : '')#
						#(isDate(variables.programRequirements.pr_End_Date)   ? dateFormat(variables.programRequirements.pr_End_Date, 'mmm d, yyyy')   : '')#
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
<div id="actp727">
 <a href="##" onclick="window.close();">#application.util.string.actionLinkFormat2("close")#</a>
</div>
</cfoutput>
</form>
</fieldset>
</body>
</html>
