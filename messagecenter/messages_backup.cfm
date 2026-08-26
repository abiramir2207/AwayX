<!--- ----------------------------------------------------------------------------------------- --->
<!--- the main link to JQuery --->
<!--- ----------------------------------------------------------------------------------------- --->
<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- the main link to datatables.js --->
<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" language="javascript" src="./datatables_code/jquery.dataTables.js"></script>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- the js required for most of the gui tricks --->
<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" language="javascript" src="./datatables_code/dataTables.jqueryui.js"></script>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- the link to the css file --->
<!--- ----------------------------------------------------------------------------------------- --->
<link rel="stylesheet" type="text/css" href="./datatables_code/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="./datatables_code/dataTables.jqueryui.css">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- the initialization code --->
<!--- ----------------------------------------------------------------------------------------- --->
<script>
	
	$(document).ready(function() {
	    $('#example').dataTable( {
	        "sPaginationType": "full_numbers"
	    } );
	} );
	
</script>



<div class="page_title"><cfoutput>#title#</cfoutput></div>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- begining of content --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="content">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the control panel settings --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_settings" datasource="#db_connection#">
	 SELECT		*
	 FROM		msg_ctr_settings
	 WHERE		deleted = 0
</cfquery>

<!---<cfdump var="#cgi#">--->

<!---<cfoutput>#HTTP_REFERER#</cfoutput>--->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- decides what the default values should be depending where this page came from --->
<!--- ----------------------------------------------------------------------------------------- --->



<cfif (findnocase("Manufacturers",HTTP_REFERER) GT 0) or (findnocase("83607-86672-50948-17728",HTTP_REFERER) GT 0)>

	<cfparam name="form.products" default="1" >
	<cfparam name="form.programs" default="1">
	<cfparam name="form.customers" default="1" >
	<cfparam name="form.messages" default="1" >

<cfelse>

	<cfparam name="form.products" default="0" >
	<cfparam name="form.programs" default="0">
	<cfparam name="form.customers" default="0" >
	<cfparam name="form.messages" default="0" >

</cfif>

 


<!--- ----------------------------------------------------------------------------------------- --->
<!--- product messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_products" datasource="#db_connection#">

SELECT DISTINCT
		top 250
		dbo.msg_ctr_event_types.msg_ctr_event_types_desc,
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_desc,
		dbo.msg_ctr_log.msg_ctr_log_item_number,
		dbo.msg_ctr_log.msg_ctr_log_item_desc,
		-- dbo.msg_ctr_log.msg_ctr_log_item_pack_size,
		
		CASE  WHEN dbo.msg_ctr_log.msg_ctr_log_item_pack_size IS NOT NULL THEN dbo.msg_ctr_log.msg_ctr_log_item_pack_size ELSE 'n/a' END as msg_ctr_log_item_pack_size,

		dbo.msg_ctr_log.created_date,
		dbo.msg_ctr_log.msg_ctr_log_id
		
FROM
		dbo.msg_ctr_log
		INNER JOIN dbo.msg_ctr_event_sub_types ON dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_id = dbo.msg_ctr_log.msg_ctr_event_sub_types_id AND dbo.msg_ctr_event_sub_types.deleted = dbo.msg_ctr_log.deleted
		INNER JOIN dbo.msg_ctr_event_types ON dbo.msg_ctr_event_types.msg_ctr_event_types_id = dbo.msg_ctr_event_sub_types.msg_ctr_event_types_id AND dbo.msg_ctr_event_types.deleted = dbo.msg_ctr_log.deleted
WHERE
		dbo.msg_ctr_event_types.msg_ctr_event_types_id = 1 
		AND
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_view = 1
		AND
		dbo.msg_ctr_log.deleted = 0

		<cfif form.products EQ 1>
			AND 1 = 1
		<cfelse>
			AND 1=2
		</cfif>

ORDER BY
		msg_ctr_event_sub_types_desc DESC

</cfquery>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- program messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_programs" datasource="#db_connection#">

SELECT DISTINCT
		top 250
		dbo.msg_ctr_event_types.msg_ctr_event_types_desc,
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_desc,
		dbo.msg_ctr_log.created_date,
		dbo.msg_ctr_log.msg_ctr_log_id,
		dbo.msg_ctr_log.msg_ctr_log_prog_assigned_to,
		dbo.msg_ctr_log.msg_ctr_log_prog_assigned_from,
		dbo.msg_ctr_log.msg_ctr_log_prog_number,
		dbo.msg_ctr_log.msg_ctr_log_prog_title,
		dbo.msg_ctr_log.msg_ctr_log_prog_start_date,
		dbo.msg_ctr_log.msg_ctr_log_prog_end_date

FROM
		dbo.msg_ctr_log
		INNER JOIN dbo.msg_ctr_event_sub_types ON dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_id = dbo.msg_ctr_log.msg_ctr_event_sub_types_id AND dbo.msg_ctr_event_sub_types.deleted = dbo.msg_ctr_log.deleted
		INNER JOIN dbo.msg_ctr_event_types ON dbo.msg_ctr_event_types.msg_ctr_event_types_id = dbo.msg_ctr_event_sub_types.msg_ctr_event_types_id AND dbo.msg_ctr_event_types.deleted = dbo.msg_ctr_log.deleted
WHERE
		dbo.msg_ctr_event_types.msg_ctr_event_types_id = 2 
		AND
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_view = 1
		AND
		dbo.msg_ctr_log.deleted = 0

		<cfif form.programs EQ 1>
			AND 1 = 1
		<cfelse>
			AND 1=2
		</cfif>

ORDER BY
		msg_ctr_event_sub_types_desc DESC

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- customer messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_customers" datasource="#db_connection#">


SELECT DISTINCT
		top 250
		dbo.msg_ctr_event_types.msg_ctr_event_types_desc,
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_desc,
		dbo.msg_ctr_log.created_date,
		dbo.msg_ctr_log.msg_ctr_log_id,
		dbo.msg_ctr_log.msg_ctr_log_customer_number,
		dbo.msg_ctr_log.msg_ctr_log_customer_name

FROM
		dbo.msg_ctr_log
		INNER JOIN dbo.msg_ctr_event_sub_types ON dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_id = dbo.msg_ctr_log.msg_ctr_event_sub_types_id AND dbo.msg_ctr_event_sub_types.deleted = dbo.msg_ctr_log.deleted
		INNER JOIN dbo.msg_ctr_event_types ON dbo.msg_ctr_event_types.msg_ctr_event_types_id = dbo.msg_ctr_event_sub_types.msg_ctr_event_types_id AND dbo.msg_ctr_event_types.deleted = dbo.msg_ctr_log.deleted
WHERE
		dbo.msg_ctr_event_types.msg_ctr_event_types_id = 5 
		AND
		dbo.msg_ctr_event_sub_types.msg_ctr_event_sub_types_view = 1
		AND
		dbo.msg_ctr_log.deleted = 0

		<cfif form.customers EQ 1>
			AND 1 = 1
		<cfelse>
			AND 1=2
		</cfif>

ORDER BY
		msg_ctr_event_sub_types_desc DESC
		
</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- admin messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="get_admin_messages" datasource="#db_connection#">

SELECT 
	*

FROM
	msg_ctr_admin_msgs

WHERE
	deleted = 0
	and
	<cfoutput>#createodbcdatetime(now())#</cfoutput> >= msg_ctr_admin_msgs.msg_ctr_start_date
	and 
	<cfoutput>#createodbcdatetime(now())#</cfoutput> <= msg_ctr_admin_msgs.msg_ctr_end_date
	AND
	msg_ctr_admin_msgs.deleted = 0

	<cfif form.messages EQ 1>
		AND 1 = 1
	<cfelse>
		AND 1=2
	</cfif>

ORDER BY
	msg_ctr_admin_msgs.msg_ctr_start_date

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- heading links to select, unselect and clear messages --->
<!--- ----------------------------------------------------------------------------------------- --->

<style>
	
div.eye_candy
{

	padding: 7px 5px 7px 5px;

	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNkZGRkZGQiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #ffffff 0%, #dddddd 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ffffff), color-stop(100%,#dddddd)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* IE10+ */
	background: linear-gradient(to bottom,  #ffffff 0%,#dddddd 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#dddddd',GradientType=0 ); /* IE6-8 */

	border-radius: 4px 4px 4px 4px;	

	box-shadow: 0 0 5px 0px #B0B0B0;	
	
	border: 1px #c5c5c5 solid;
	
}	

	
td.eye_candy
{
	padding:0px 5px 0px 5px;
	vertical-align:middle;
	white-space:nowrap; 
}	
	
</style>


<form action="index.cfm?id=94451-84537-17189-37328" method="post" name="form_name" id="form_name">

<div class="eye_candy">

<table>
	<tr>
		<td class="eye_candy"><input type="checkbox" name="products" value="1" <cfif form.products EQ 1> checked="checked"</cfif>></td>
		<td class="eye_candy">products</td>

		<td class="eye_candy"><input type="checkbox" name="programs" value="1" <cfif form.programs EQ 1> checked="checked"</cfif>></td>
		<td class="eye_candy">programs</td>

		<td class="eye_candy"><input type="checkbox" name="customers" value="1" <cfif form.customers EQ 1> checked="checked"</cfif>></td>
		<td class="eye_candy">customers</td>

		<td class="eye_candy"><input type="checkbox" name="messages" value="1" <cfif form.messages EQ 1> checked="checked"</cfif>></td>
		<td class="eye_candy">administrator messages</td>

		<td class="eye_candy"><input type="submit" value="View Selected Message Types"></td>
		<td class="eye_candy" width="100%" align="right"><input type="button" value="Message Center Administration"  onclick="location.href='index.cfm?id=83607-86672-50948-17728';"></td>
	</tr>
</table>
                                          
</div>

</form>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- if there are no records at all, say so and stop the process --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfif get_products.recordcount+get_programs.recordcount+get_customers.recordcount+get_admin_messages.recordcount EQ 0>
	<div  class="eye_candy" style="text-align:center; padding:200px 0px 200px 0px; margin:15px auto 0px auto; font-weight:bold; font-size:14px;">
		No Messages Available
	</div>
	<cfabort>
</cfif>

<br/>


<div class="eye_candy">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- product messages --->
<!--- ----------------------------------------------------------------------------------------- --->

<table id="example" class="display" cellspacing="0" width="100%">
	<col class="col_one">
	<col class="col_two">
	<col class="col_three">

<thead>
<tr>
	<th>Event Type</th>
	<th>Event Date</th>
	<th>Event Details</th>
</tr>
</thead>


<tbody>

<cfoutput  query="get_products">
	<tr>
		<td>Products</td>
		<td>#dateformat(created_date, 'm/d/yyyy')# - #timeformat(created_date, 'h:mm:ss tt')#</td>
		<td>#msg_ctr_event_sub_types_desc#&nbspItem number #msg_ctr_log_item_number#, #msg_ctr_log_item_desc#, Pack Size: #msg_ctr_log_item_pack_size#</td>
	</tr>
</cfoutput>

<cfoutput  query="get_programs">
	<tr>
		<td>Programs</td>
		<td>#dateformat(created_date, 'm/d/yyyy')# - #timeformat(created_date, 'h:mm:ss tt')#</td>
		<td>#msg_ctr_event_sub_types_desc#&nbspNumber #msg_ctr_log_prog_number#, #msg_ctr_log_prog_title#, assigned by #msg_ctr_log_prog_assigned_from# to #msg_ctr_log_prog_assigned_to#, running from #dateformat(msg_ctr_log_prog_start_date, 'm/d/yyyy')# to #dateformat(msg_ctr_log_prog_end_date, 'm/d/yyyy')#</td>
	</tr>
</cfoutput>
 
<cfoutput  query="get_customers">
	<tr>
		<td>Customers</td>
		<td>#dateformat(created_date, 'm/d/yyyy')# - #timeformat(created_date, 'h:mm:ss tt')#</td>
		<td>#msg_ctr_event_sub_types_desc#&nbsp #msg_ctr_log_customer_number#, #msg_ctr_log_customer_name#</td>
	</tr>
</cfoutput>




<cfoutput  query="get_admin_messages">
	<tr>
		<td>Administration Messages</td>
		<td>#dateformat(created_date, 'mm/dd/yy')#</td>
		<td>#msg_ctr_admin_txt#</td>
	</tr>
</cfoutput>

	
</tbody>



</table>


</div>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- end of content --->
<!--- ----------------------------------------------------------------------------------------- --->

