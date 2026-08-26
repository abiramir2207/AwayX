<style>

table.datagrid
{
	border-collapse:			colapse;
	border-spacing:				0px;
	width:						900px;
}

td.col_header, th.col_header
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					center;
	font-size:					11px;
	font-weight:				bold;
	padding:					5px 5px 5px 5px;
	text-transform:				capitalize;
}

td.row_header
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					center;
	font-size:					11px;
	font-weight:				bold;
	padding:					5px 5px 5px 5px;
	text-transform:				capitalize;
	
}

td.data
{
	color:						#CCCCCC;
	background-color:			;
	text-align:					left;
	font-size:					11px;
	font-weight:				bold;
	padding:					5px 5px 5px 5px;
	text-transform:				;
	
}

td.section_title
{
	color:						#FFFF00;
	background-color:			#000000;
	text-align:					left;
	font-size:					11px;
	font-weight:				bold;
	padding:					15px 5px 5px 5px;
	text-transform:				capitalize;
	border-bottom:				2px solid #FFFF00;
}

td.sub_totals
{
	color:						#FFFF00;
	background-color:			#000000;
	text-align:					left;
	font-size:					11px;
	font-weight:				bold;
	padding:					5px 5px 5px 5px;
	text-transform:				capitalize;
	border-top:					1px solid #FFFF00;
}

td.grand_totals
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					center;
	font-size:					11px;
	font-weight:				bold;
	padding:					5px 5px 5px 5px;
	text-transform:				capitalize;
	
}

td.left, th.left
{
	text-align:					left;
}

td.right, th.right
{
	text-align:					right;
}

tr.row:nth-child(even) 
{
	background: 				#373737
}

tr.row:nth-child(odd) 
{
	background: 				#444444
}

</style> 

<br/>





<!---

<!--- ----------------------------------------------------------------------------------------- --->
<!--- get all the budget classes that could be retrieved -------------------------------------  --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
		Budget_Class.start_date

FROM	Budget 
inner join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID

WHERE	Budget.Deleted = 0
Order by Budget_Class.start_date
</cfquery>










<cfparam name="form.budget_class_value" default="" type="any">

<!--- If somethign is comign from the form scope use it --->
<cfif form.budget_class_value eq "">
      <!--- if form scope is empty, use cookie --->
      <cfif isdefined("cookie.budget_classes")>
            <cfset form.budget_class_value = cookie.budget_classes />
      <cfelse> <!--- if form scope is empty, and cookie is nto set, use all classes --->
            <cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />
      </cfif>

</cfif>
<cfset budget_classes_list = form.budget_class_value />

<div style="text-align:left; font-size:10px; margin:10px 10px -10px 10px;">


    <form action="display.cfm?content=78887-94887-85955-88428" method="post">
    <table>
    <tr>
        <cfoutput query="Get_budget_classes">
        <td style="color:##DDDDDD;">#Budget_Class_Desc#</td>
        <td><input name="budget_class_value" type="checkbox" value="#Budget_Class_Desc#" style="width:20px; margin: 2px 0px 0px 0px;" <cfif ListFind(budget_classes_list, Budget_Class_Desc)>checked</cfif> /></td>
        </cfoutput>
        <td><input name="" type="submit" style="margin:3px 0px 0px 0px;" /></td>
    </tr>
    </table>
    </form>

      <!--- create the cookie with the budget classes values  --->
    <cfcookie name="budget_classes" value="#form.budget_class_value#">

</div>

<hr style="color: #f00;  background-color: #f00;  height: 2px; border:0px;" />



Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput>
<br/>



--->

















<style>
	
	div.note
	{
		color:			#FFFF00;
		font-size:		11px;
		font-style: 	italic;
	}
		
</style>











<cfparam name="form.budget_class_value" default="" type="any">

<!--- If somethign is comign from the form scope use it --->
<cfif form.budget_class_value eq "">
      <!--- if form scope is empty, use cookie --->
      <cfif isdefined("cookie.budget_classes")>
            <cfset form.budget_class_value = cookie.budget_classes />
      </cfif>


		<cfif form.budget_class_value eq ""> <!--- if form scope is empty, and cookie is nto set, use all classes --->

		<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
		SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
				Budget_Class.start_date
		
		FROM	dbo.dashboards_budget_weekly_summary
				
		
		        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
		        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
		
		WHERE	1=1
		
		        AND     dash_budget_type = 3
		        <cfif 	user_market_list neq "">
		        AND		market_id in (#user_market_list#)
		        <cfelse>
		        AND		1=2 <!--- Do not return any record if user is below this level --->
				Order by Budget_Class.start_date
				</cfif>

		</cfquery>

		<cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />

      </cfif>

</cfif>












<cfset budget_classes_list = form.budget_class_value />
<BR />
Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput>
<div class="note">The only budget classes used by this dashboard, are the ones set by the "Select Budget Classes"</div>




<BR />


<script> 
function toggle(thisname) { 
tr=document.getElementsByTagName('tr') 
for (i=0;i<tr.length;i++){ 
if (tr[i].getAttribute(thisname)){ 
if ( tr[i].style.display=='none' ){ 
tr[i].style.display = ''; 
} 
else { 
tr[i].style.display = 'none'; 
}}}} 
</script> 


<cfquery name="get_data_1" datasource="#application.datasource#">

IF Object_id( 'tempdb..##tmp_budget_program_committed' ) IS NOT NULL
  DROP TABLE ##tmp_Budget_Program_Committed

</cfquery>

<cfquery name="get_data" datasource="#application.datasource#">
DECLARE @distributorMultiPosition bit,
		@business_segment_enabled bit

SELECT  @distributorMultiPosition = distributorMultiPosition
FROM    _application_settings

SELECT 	@business_segment_enabled = Enabled  FROM 	Business_Segment_Enabled WHERE 	Deleted = 0

IF Object_id( 'tempdb..##tmp_budget_program_committed' ) IS NOT NULL
  DROP TABLE ##tmp_Budget_Program_Committed

-- distributor budgets
SELECT Budget.Budget_Code
       ,Budget.Budget_Id
       ,Budget.Budget_class_id
       ,Budget.Budget_desc
       ,Budget.Business_Segment_ID
       ,Name + ' ' + '(' + shr_Ship_To + ')'               AS Position_Customer
       ,bsa_FoodService_Customers.bsa_FoodService_Customers_Id
       ,0 as User_Position_Id
       ,CAST(NULL as uniqueidentifier) as Service_Zone_ID
       ,CAST(NULL as uniqueidentifier) as Service_Region_ID
       ,CAST(0 as int) as Service_Market_ID
       ,Sum( Budget_Distributor_Program.Committed_Dollar ) AS Committed_Dollar
       ,Sum( Budget_Distributor_Program.Actual_Dollar )    AS Actual_Dollar
       ,Max( Contract_Main_Id )                            AS Max_Contract_Main_Id
  INTO ##tmp_Budget_Program_Committed
  FROM Budget
       INNER JOIN Budget_Distributor_Program
         ON Budget_Distributor_Program.Budget_Id = Budget.Budget_Id
       LEFT JOIN bsa_FoodService_Customers
         ON bsa_FoodService_Customers.bsa_FoodService_Customers_Id = Budget_Distributor_Program.bsa_FoodService_Customers_Id
 WHERE Budget.Deleted = 0
 GROUP BY Budget.Budget_Code
          ,Budget.Budget_Id
          ,Budget.Budget_class_id
          ,Budget.Budget_desc
          ,bsa_FoodService_Customers.bsa_FoodService_Customers_Id
          ,bsa_FoodService_Customers.shr_Ship_To
          ,bsa_FoodService_Customers.Name
          ,Budget_Distributor_Program.Contract_Number
          ,Budget.Business_Segment_ID
UNION ALL
-- position budgets
SELECT Budget.Budget_Code
       ,Budget.Budget_Id
       ,Budget.Budget_class_id
       ,Budget.Budget_desc
       ,Budget.Business_Segment_ID
       ,User_Positions.Position_Label                   AS Position_Customer
       ,NULL as bsa_FoodService_Customers_Id
       ,Budget_Position_Program.User_Position_Id
       ,CAST(NULL as uniqueidentifier) as Service_Zone_ID
       ,CAST(NULL as uniqueidentifier) as Service_Region_ID
       ,CAST(0 as int) as Service_Market_ID
       ,Sum( Budget_Position_Program.Committed_Dollar ) AS Committed_Dollar
       ,Sum( Budget_Position_Program.Actual_Dollar )    AS Actual_Dollar
       ,Max( Contract_Main_Id )                         AS Max_Contract_Main_Id
  FROM Budget
       INNER JOIN Budget_Position_Program
         ON Budget_Position_Program.Budget_Id = Budget.Budget_Id
       LEFT JOIN User_Positions
         ON User_Positions.User_Positions_Id = Budget_Position_Program.User_Position_Id
 WHERE Budget.Deleted = 0
 GROUP BY Budget.Budget_Code
          ,Budget.Budget_Id
          ,Budget.Budget_class_id
          ,Budget.Budget_desc
          ,Budget_Position_Program.User_Position_Id
          ,User_Positions.Position_Label
          ,Budget_Position_Program.Contract_Number
          ,Budget.Business_Segment_ID

<cfif HQUser EQ 0>
IF @distributorMultiPosition = 1
BEGIN
	UPDATE	t
	SET		Service_Market_ID = md.Service_Market_ID
	FROM	##tmp_Budget_Program_Committed t
	INNER JOIN Market_Distributor md
	ON		md.Distributor_ID = t.bsa_FoodService_Customers_Id
	AND		md.Deleted = 0
	INNER JOIN Service_Markets sm
	ON		sm.Service_Market_ID = md.Service_Market_ID
	AND		(@business_segment_enabled = 0 OR sm.Business_Segment_ID = t.Business_Segment_ID)
	WHERE	User_Position_Id = 0
END
ELSE
BEGIN
	UPDATE	t
	SET		Service_Market_ID = b.Service_Market_ID
	FROM	##tmp_Budget_Program_Committed t
	INNER JOIN BSA_Foodservice_Customers c
	ON		c.BSA_Foodservice_Customers_ID = t.bsa_FoodService_Customers_Id
	INNER JOIN BSA_Foodservice_Brokers b
	ON		b.BSA_Foodservice_Brokers_ID = c.BSA_Foodservice_Brokers_ID	
	WHERE	User_Position_Id = 0
END

UPDATE	t
SET		Service_Zone_ID = up.Service_Zone_ID,
		Service_Region_ID = up.Service_Region_ID,
		Service_Market_ID = up.Service_Market_ID
FROM	##tmp_Budget_Program_Committed t
INNER JOIN User_Positions up
ON		up.User_Positions_ID = t.User_Position_Id
WHERE	t.User_Position_Id != 0

</cfif>

SELECT Budget_Code
       ,Budget_Id
       ,Budget_desc
       ,Position_Customer
       ,Contract_Main.Contract_Number
       ,Contract_Main.Contract_Title
       ,Contract_Main.Contract_Start_Date
       ,Contract_Main.Contract_End_Date
       ,_Users.Name_First + ' ' + _Users.Name_Last AS rsp
       ,Program_Control_Panel_Options.Created_Type AS Template
       ,Committed_Dollar
       ,Actual_Dollar
       ,Contract_Main.Manual_Cancel
  FROM ##tmp_Budget_Program_Committed
       LEFT JOIN Contract_Main
         ON Contract_Main.Contract_Main_Id = ##tmp_Budget_Program_Committed.Max_Contract_Main_Id
       LEFT JOIN _Users
         ON _Users.User_Id = Contract_Main.Responsible_User_Id
       LEFT JOIN Program_Control_Panel_Options
         ON Program_Control_Panel_Options.ProgramControl_Panel_Options_Id = Contract_Main.ProgramType_Id




-- -------------------------------------------------------------- --
 left join Budget_Class on Budget_Class.Budget_Class_ID = ##tmp_Budget_Program_Committed.Budget_Class_ID
-- -------------------------------------------------------------- --

         
         

		 
		 
 WHERE ( Contract_Main.Manual_Cancel = 0
          OR ##tmp_Budget_Program_Committed.Actual_Dollar != 0 )
          

          
          
          
<cfif HQUser EQ 0>
	AND (1=2
	<cfif 	user_zone_list neq "">
	OR Service_Zone_ID in (#PreserveSingleQuotes(user_zone_list)#)
	</cfif>
	<cfif 	user_region_list neq "">
	OR Service_Region_ID in (#PreserveSingleQuotes(user_region_list)#)
	</cfif>
	<cfif 	user_market_list neq "">
	OR Service_Market_ID in (#user_market_list#)
	</cfif>
	)
</cfif>




-- ------------------------------------------------------------------
        <cfif 	budget_classes_list neq "">
        AND Budget_Class.Budget_Class_Desc IN (#ListQualify(budget_classes_list,"'")#)
        <cfelse>
        AND 1=2 <!--- Do not return any record if budget_classes_list is empty --->
        </cfif>        
-- ------------------------------------------------------------------





 ORDER BY
 		Budget_Code
        ,Budget_Id
        ,Budget_desc
 		,Committed_Dollar desc
        ,Position_Customer
        ,Contract_Number 



</cfquery>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- used to colapse all details or expand all details --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>

<style>
	a.new, a.cons
	{
		color:					#FFFFFF;
		background-color:		#999999; 
		text-transform:			uppercase; 
		font-size:				11px;
		padding:				7px 15px 7px 15px;
	    -webkit-border-radius:	3px;
	    border-radius:			3px;
		text-decoration:		none;

		text-shadow: 			1px 1px 1px #000000;

		background: #999999; /* Old browsers */
		/* IE9 SVG, needs conditional override of 'filter' to 'none' */
		background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzc3Nzc3NyIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMyMjIyMjIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
		background: -moz-linear-gradient(top,  #999999 0%, #444444 100%); /* FF3.6+ */
		background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#999999), color-stop(100%,#444444)); /* Chrome,Safari4+ */
		background: -webkit-linear-gradient(top,  #999999 0%,#444444 100%); /* Chrome10+,Safari5.1+ */
		background: -o-linear-gradient(top,  #999999 0%,#444444 100%); /* Opera 11.10+ */
		background: -ms-linear-gradient(top,  #999999 0%,#444444 100%); /* IE10+ */
		background: linear-gradient(top,  #999999 0%,#444444 100%); /* W3C */
		filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#999999', endColorstr='#444444',GradientType=0 ); /* IE6-8 */

	}
</style>


<span class="side-nav">
	
<a class="new" href="#">View all details</a>
&nbsp;&nbsp;
<a class="cons" href="#">Hide all details</a>
</span>

<BR /><BR />

<script>
$(function()
{
    $('span.side-nav a').click(function()
    {
       $('tr.cond').hide();
       $('tr.' + $(this).attr('class')).show();       
    });
});
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<cfset number_of_columns	=	7>
<cfset table_width			=	925>
<cfset column_width			=	130>
<cfset column_width_first	=	table_width - ((number_of_columns-1) * column_width)>
<cfset table_height			=	450>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- data grid table columns 															 	 	--->
<!--- ----------------------------------------------------------------------------------------- --->

<div style=" overflow-y: scroll; width:<cfoutput>#table_width#</cfoutput>px;">
<table class="datagrid" style="width:100%">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>
	<tr>
		<th class="col_header left"><CFOUTPUT>#label.program.singular#</CFOUTPUT></th>
		<th class="col_header left">Title</th>
		<th class="col_header left">Template</th>
		<th class="col_header left">RSP</th>
		<th class="col_header left"><CFOUTPUT>#label.customer.singular#</CFOUTPUT>/Position</th>
		<th class="col_header right"><CFOUTPUT>#label.commit.singular#</CFOUTPUT></th>
		<th class="col_header right">Actual</th>
	</tr>
</table>
</div>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- data grid table data																	  	--->
<!--- ----------------------------------------------------------------------------------------- --->

<div style=" overflow: auto; width:<cfoutput>#table_width#</cfoutput>px; height:<cfoutput>#table_height#</cfoutput>px;">
<table class="datagrid" style="width:100%;">
	<cfoutput>
    <col width="#column_width_first#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    <col width="#column_width#" />
    </cfoutput>


<cfoutput query="get_data" group="budget_desc">
	
	<tr>
		<td class="section_title" colspan="7"><span onClick="toggle('#budget_id#');" style="cursor:pointer;"><img src="../images/link_small.png">&nbsp;&nbsp;#Budget_Code# - #budget_desc#</span></td>
	</tr>
	
	<!--- instanciate the totals variables --->
	<cfset commit_total="0">
	<cfset actual_total="0">
	
	<cfoutput>

	<tr class="cond new" #budget_id#="#budget_id#" style="display:none;">

		<td class="data left">#Contract_Number#</td>
		<td class="data left">#Contract_Title#</td>
		<td class="data left">#Template#</td>
		<td class="data left">#RSP#</td>
		<td class="data left">#Position_Customer#</td>
		<td class="data right">#dollarformat(Committed_Dollar)#</td>
		<td class="data right">#dollarformat(Actual_Dollar)#</td>
	</tr>
		
		<cfset commit_total=commit_total+Committed_Dollar>
		<cfset actual_total=actual_total+actual_Dollar>
		
	</cfoutput>

		
	<tr class="row cond new" #budget_id#="#budget_id#" style="display:none;">
		<td class="sub_totals right" colspan="4">&nbsp;</td>
		<td class="sub_totals left">Grand Totals:</td>
		<td class="sub_totals right">#dollarformat(commit_total)#</td>
		<td class="sub_totals right">#dollarformat(actual_total)#</td>
	</tr>

</cfoutput>


</table>
</div>
