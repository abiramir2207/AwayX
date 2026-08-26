<!--- 75718-73349-64488-74924 --->


<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
    input.gradient_fix {filter: none;}
  </style>
<![endif]-->


<style>
li.filters
{
	text-align: left;
}

td.options
{
	color:			#FFFFFF;
	font-size:		12px;
	font-weight:	bold;
}
</style>


<!--- 
<!--- get the list of programs that I'm the CRA: Currently Responsible for Approval and outputs the list to the var #CRAProgramList# --->
<cfset CRAProgramList = ArrayToList(CreateObject("component", "mvc.Models.Program.ProgramManager").getPendingApprovalPrograms(request.AccessStructure.user_ID, request.AccessStructure.profiles_ID)) />        
 --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the list of budgets that the RFA, active & expiring belong to (status 2, 5 & 6) ---- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_budgets" datasource="#Application.Datasource#">
SELECT		distinct
					dbo.Budget.Budget_ID,
					lower(dbo.Budget.Budget_Desc) as Budget_Desc
FROM  Contract_Main
INNER JOIN Contract_Main All_versions -- We will get budget and actual dollar from all versions of the program
ON          All_versions.Contract_Number = Contract_Main.Contract_Number
AND         All_versions.Approved = 1
INNER JOIN Budget_Program_Selection
ON          Budget_Program_Selection.Program_ID = All_versions.Contract_Main_ID
INNER JOIN Budget
ON          Budget.Budget_ID = Budget_Program_Selection.Budget_ID
LEFT JOIN Budget_Position_Program
ON          Budget_Position_Program.Contract_Main_ID = All_versions.Contract_Main_ID
AND         ISNULL(Budget.Allocation_Position_Level, 0) != 4
LEFT JOIN Budget_Distributor_Program
ON          Budget_Distributor_Program.Contract_Main_ID = Contract_Main.Contract_Main_ID
AND         ISNULL(Budget.Allocation_Position_Level, 0) = 4

WHERE 
	(
	dbo.Contract_Main.Contract_Status_Type_IDX = 2
	OR
	dbo.Contract_Main.Contract_Status_Type_IDX = 5
	OR
	dbo.Contract_Main.Contract_Status_Type_IDX = 6
	)

</cfquery>

<div class="frame rounded_corners gradient_fix" style="padding:10px 10px 10px 10px; width:90%;">


<!--- ----------------------------------------------------------------------------------------- --->
<div class="section_title gradient_fix">Pre-Defined Criterias</div>
<table style="margin:10px auto 10px auto; width:90%;" cellpadding="10" cellspacing="0">
<tr>
	<td valign="top" class="align_left">

        <img src="../images/circle.png" />&nbsp;&nbsp;<a style="color:#FFFFFF; font-size:12px;" href="index.cfm?content=14363-32470-12748-79810&id=45640-28601-32997-26470">All - Active & Ready for Approval Programs</a><br /><br />

        <img src="../images/circle.png" />&nbsp;&nbsp;<a style="color:#FFFFFF; font-size:12px;" href="index.cfm?content=14363-32470-12748-79810&id=66506-53122-68190-18792">New - Started within last 30 days</a><br /><br />
        <img src="../images/circle.png" />&nbsp;&nbsp;<a style="color:#FFFFFF; font-size:12px;" href="index.cfm?content=14363-32470-12748-79810&id=21866-48048-53685-98323">Expiring - Ending within 30 days</a>
    </td>
	<td valign="top" class="align_left">
        <img src="../images/circle.png" />&nbsp;&nbsp;<a style="color:#FFFFFF; font-size:12px;" href="index.cfm?content=14363-32470-12748-79810&id=48843-25185-52768-72116">CRA - Ready for Approval Programs</a><br /><br />
        <img src="../images/circle.png" />&nbsp;&nbsp;<a style="color:#FFFFFF; font-size:12px;" href="index.cfm?content=14363-32470-12748-79810&id=12665-92034-26217-45059">Big - Top 25 committed dollars</a>
    </td>
</tr>
</table>
<!--- ----------------------------------------------------------------------------------------- --->



<br /><br /><br />



<!--- ----------------------------------------------------------------------------------------- --->

<div class="section_title gradient_fix">Custom Criteria</div>
<form action="index.cfm?content=14363-32470-12748-79810&amp;id=41970-74841-13362-76384" method="post" enctype="application/x-www-form-urlencoded">


<!--- ----------------------------------------------------------------------------------------- --->
<!--- display the possible budgets ------------------------------------------------------------ --->
<!--- ----------------------------------------------------------------------------------------- --->

<!-- 
<cfset counter=1>
<table style="margin:10px auto 10px auto; width:90%;" cellpadding="2" cellspacing="0">
    <tr>
	    <td colspan="100%" class="options align_left" style="border-bottom:1px #FF9900 solid; color:#FF9900;">Select the budget(s) (*)</td>
    </tr>
    <tr>
    <cfloop query="get_budgets">
    <td class="options align_left" style="font-size:10px;" title="<cfoutput>#Budget_ID# - #Budget_Desc#</cfoutput>"><cfoutput><input name="budget" type="checkbox" value="#Budget_ID#" /> #CAPFIRST(Budget_Desc)#</cfoutput></td>
    <CFIF get_budgets.CurrentRow MOD 3 IS 0>
    </tr><tr>
    </CFIF>
    <cfset counter=counter+1>
    </cfloop>
    </tr>
</table>
 -->



<table style="margin:10px auto 10px auto; width:90%;" cellpadding="5" cellspacing="0">
<tr><td colspan="100%" class="options align_left" style="border-bottom:1px #FF9900 solid; color:#FF9900;">Enter the text to search (*)</td></tr>
<tr>
	<td class="options">
    	<br />
        <input  id="foo" name="searchfor" type="text" class="search_field rounded_corners" autocorrect="off" autocapitalize="off">
    </td>
	<td class="options">
    	<br />
    	<input name="" type="submit" value="display program list" class="search_button rounded_corners dark_gradient gradient_fix" style="width:175px;">
        &nbsp;&nbsp;
    	<input name="" type="reset" value="clear all selections" class="search_button rounded_corners dark_gradient gradient_fix" style="width:175px;" onclick="return confirm('Are you sure you want to clear all selections?')">
	</td>
</tr>
</table>
</form>

<!--- 
<div style="font-size:9px; color:#777777;">(*) Budgets are ignored if you don't made any selections. The text will be searched against the program numbers and program titles.</div>
 --->
 
</div>

