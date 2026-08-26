<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with all the settings ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="appsettings.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<link rel="stylesheet" type="text/css" href="styles.css">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />

<title>blacksmith applications :: dashboards</title>




  
<style>

/*
	table wrapper				#FFFFFF		div.dataTables_wrapper
	table wrapper border		#CCCCCC		div.dataTables_wrapper 
	table border				#CCCCCC 	table.pretty td, table.pretty th
	table row titles			#DDDDDD 	table.pretty tbody th
	column headers				#BBBBBB 	table.pretty thead th.sorting th.sorting_asc th.sorting_desc
	table data fields			#FFFFFF 	table.pretty tbody tr.odd td
	table data fields (alte)	#eeeeee 	table.pretty tbody td
*/


/* ---------------------------------------------------------------------------------------------- */
/* Page setup styles */
/* ---------------------------------------------------------------------------------------------- */
#container 
{
	margin: 					0 auto;
	width: 						960px
}


/* ---------------------------------------------------------------------------------------------- */
/* DataTables framework */
/* ---------------------------------------------------------------------------------------------- */
div.dataTables_wrapper 
{
	background-color: 			#222222;
	border:						0px #CCCCCC solid;
}

div.dataTables_length 
{
	float: 						left;
}

div.dataTables_filter 
{
	float: 						right;
}

div.dataTables_info 
{
	padding: 					9px 6px 6px 6px;
	float: 						left;
	font-size:					11px;
	color:						#666666;
}

div.dataTables_paginate 
{
	float: 						right;
}

div.dataTables_length, div.dataTables_filter, div.dataTables_paginate 
{
	padding: 					6px;
}

/* ---------------------------------------------------------------------------------------------- */
/* Self clearing - http://www.webtoolkit.info/css-clearfix.html */
/* ---------------------------------------------------------------------------------------------- */
.dataTables_wrapper:after 
{
	content: 					".";
	display: 					block;
	clear: 						both;
	visibility: 				hidden;
	line-height: 				0;
	height: 					0;	
}
 
html[xmlns] .dataTables_wrapper 
{
	display: 					block;
}
 
* html .dataTables_wrapper 
{
	height: 					1%;
}

/* ---------------------------------------------------------------------------------------------- */
/* Table styles */
/* ---------------------------------------------------------------------------------------------- */
table.pretty 
{
	width: 						100%;
	clear: 						both;
}

table.pretty td, table.pretty th 
{
	padding: 					4px;
	border-bottom: 				1px solid #CCCCCC;
	color:						#CCCCCC;
}


/* ---------------------------------------------------------------------------------------------- */
/* Header cells */
/* ---------------------------------------------------------------------------------------------- */
table.pretty thead th 
{
	text-align: 				left;
	color:						#000000;
	font-weight:				bold;
	cursor:						pointer;

	background: #fefefe; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' see below this block */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZlZmVmZSIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNkZGRkZGQiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #fefefe 0%, #dddddd 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#fefefe), color-stop(100%,#dddddd)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* IE10+ */
	background: linear-gradient(top,  #fefefe 0%,#dddddd 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fefefe', endColorstr='#dddddd',GradientType=0 ); /* IE6-8 */
}

/* ---------------------------------------------------------------------------------------------- */
/* Body cells */
/* ---------------------------------------------------------------------------------------------- */

table.pretty tbody td 
{
	text-align: 				left;
	background: 				#222222;
	color:						#CCCCCC;
	border:						0;
	border-bottom:				1px #333333 solid;
}
		
table.pretty tbody tr.odd td 
{ 
	background: 				#000000;
	color:						#CCCCCC;
	border-bottom:				1px #333333 solid;
}


/* ---------------------------------------------------------------------------------------------- */
/* Pagination */
/* ---------------------------------------------------------------------------------------------- */
a.paginate_button, a.paginate_active 
{
	display: 					inline-block;
	background-color: 			#222222;
	color:						#FFFFFF;
	border:						1px #333333 solid;
	padding: 					2px 6px;
	margin-left: 				2px;
	cursor: 					pointer;
	*cursor: 					pointer;
	font-size:					10px;
}

a.paginate_active 
{
	background-color: 			#FFFFFF;
	border: 					1px solid white;
	color:						#000000;
	font-size:					10px;
}

a.paginate_button_disabled 
{
	color: 						#aaaaaa;
	font-size:					10px;
}

.paging_full_numbers a:active 
{
	outline: 					none
	font-size:					10px;
}

.paging_full_numbers a:hover 
{
	text-decoration: 			none;
	font-size:					10px;
}

div.dataTables_paginate span>a 
{
	width: 						15px;
	text-align: 				center;
	font-size:					10px;
}

/* ---------------------------------------------------------------------------------------------- */
/* Sorting */
/* ---------------------------------------------------------------------------------------------- */
table.pretty thead th.sorting_asc 
{
	background: 				#BBBBBB url('images/sort_asc.png') no-repeat right center;
}

table.pretty thead th.sorting_desc 
{
	background: 				#BBBBBB url('images/sort_desc.png') no-repeat right center;
}

table.pretty thead th.sorting 
{
	background: 				#BBBBBB url('images/sort_both.png') no-repeat right center;
}


label
{
	color:						#FFFFFF;
	font-size:					12px;
}


</style>
		
		
<script type="text/javascript" language="javascript" src="http://datatables.net/release-datatables/media/js/jquery.js"></script>
<script type="text/javascript" language="javascript" src="jquery.dataTables.js"></script>

<script type="text/javascript" charset="utf-8">
	/* Formatted numbers sorting */
	$.fn.dataTableExt.oSort['formatted-num-asc'] = function(x,y){
		x = parseInt( x.replace(/[^\d\-\.\/]/g,'') );
		y = parseInt( y.replace(/[^\d\-\.\/]/g,'') );
		return x - y;
	}
	$.fn.dataTableExt.oSort['formatted-num-desc'] = function(x,y){
		x = parseInt( x.replace(/[^\d\-\.\/]/g,'') );
		y = parseInt( y.replace(/[^\d\-\.\/]/g,'') );
		return y - x;
	}
	
	/* Initialisation */
	$(document).ready(function() {
		$('#table_id_1').dataTable( {
			"oLanguage": {"sSearch": "Search this table:"},
			"sPaginationType": "full_numbers",
			"aoColumnDefs": [ {
				"sType": "formatted-num"
				,"aTargets": []
			} ]
		} );
	} );


	/* Initialisation */
	$(document).ready(function() {
		$('#table_id_2').dataTable( {
			"oLanguage": {"sSearch": "Search this table:"},
			"sPaginationType": "full_numbers",
			"aoColumnDefs": [ {
				"sType": "formatted-num"
				,"aTargets": []
			} ]
		} );
	} );


	/* Initialisation */
	$(document).ready(function() {
		$('#table_id_3').dataTable( {
			"oLanguage": {"sSearch": "Search this table:"},
			"sPaginationType": "full_numbers",
			"aoColumnDefs": [ {
				"sType": "formatted-num"
				,"aTargets": []
			} ]
		} );
	} );

</script>



</head>

<body id="dt_example" name="top">


<!--[if gte IE 9]>
  <style type="text/css">
    .gradient_fix {
       filter: none;
    }
  </style>
<![endif]-->


<!--- ----------------------------------------------------------------------------------------- --->
<div class="header dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_header.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container">


<style>
a.nav_links
{
	color:				#ffffff; 
	text-decoration:	none;
	font-size:			10px;

}
</style>



<br />


<!--- ----------------------------------------------------------------------------------------- --->



<div id="container" style="width:90%;">


<cfloop index="i" list="#form.item_type_code#">


<!--- decide the primary color to be used ----------------------------------------------------- --->
<cfset color="">
<cfif #i# EQ 1>
	<cfset color=oper_color>
<cfelseif #i# EQ 2>
	<cfset color=dist_color>
<cfelse>
	<cfset color=prod_color>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
	<cfinclude template="search_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<style>
div.sub_section_title
{
	color:				#FFFF00;
	padding:			5px 5px 5px 0px;
	margin:				0px 0px 10px 0px;
	font-size:			16px;
	font-weight:		bold;
	border-bottom:		1px #CC33FF solid;
}
</style>

<div  class="sub_section_title">
<cfoutput>#get_type_code.snapshot_metadata_item_type_description#</cfoutput>
</div>

<table id="table_id_<cfoutput>#i#</cfoutput>" class="pretty" width="100%" cellpadding="0" cellspacing="0" border="0" align="center" style="	border-bottom:5px black solid;">

	<thead>

		<tr>
			<th class="datagrid_header summary" width="20%" height="20"><img src="images/sort.png">&nbsp;Item #</th>
			<th class="datagrid_header summary" width="80%"><img src="images/sort.png">&nbsp;Name</th>
		</tr>
	</thead>

	<tbody>
	<cfoutput query="get_data">
	<tr>
		<td class="datagrid_data"><a style="color:##FFFF00;" href="search_details.cfm?item_id=#item_id#&item_type_code=#i#&date_period=#date_period#&uom=13579">#item_id#</a></td>
		<td class="datagrid_data">#item_name#</td>
	</tr>
	</cfoutput>
	</tbody>

</table>

<br /><br />

</cfloop>



</div>


<br />

</div>
<!--- ----------------------------------------------------------------------------------------- --->












<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->


<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

</body>
</html>



