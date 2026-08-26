<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Untitled Document</title>
 
<link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/3.3.0/build/cssreset/reset-min.css">
<link rel="stylesheet" type="text/css" href="styles_global.css">
<link rel="stylesheet" type="text/css" href="styles_search.css">


  
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
	background-color: 			#DDDDDD;
	border:						1px #CCCCCC solid;
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
	border: 					1px solid #CCCCCC;
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
	background: 				#eeeeee;
}
		
table.pretty tbody tr.odd td 
{ 
	background: 				#ffffff;
}


/* ---------------------------------------------------------------------------------------------- */
/* Pagination */
/* ---------------------------------------------------------------------------------------------- */
a.paginate_button, a.paginate_active 
{
	display: 					inline-block;
	background-color: 			#FFFFFF;
	padding: 					2px 6px;
	margin-left: 				2px;
	cursor: 					pointer;
	*cursor: 					hand;
	color:						black;
}

a.paginate_active 
{
	background-color: 			transparent;
	border: 					1px solid white;
	color:						black;
}

a.paginate_button_disabled 
{
	color: 						#aaaaaa;
}

.paging_full_numbers a:active 
{
	outline: 					none
}

.paging_full_numbers a:hover 
{
	text-decoration: 			none;
}

div.dataTables_paginate span>a 
{
	width: 						15px;
	text-align: 				center;
}

/* ---------------------------------------------------------------------------------------------- */
/* Sorting */
/* ---------------------------------------------------------------------------------------------- */
table.pretty thead th.sorting_asc 
{
	background: 				#BBBBBB url('/snapshots/images/sort_asc.png') no-repeat right center;
}

table.pretty thead th.sorting_desc 
{
	background: 				#BBBBBB url('/snapshots/images/sort_desc.png') no-repeat right center;
}

table.pretty thead th.sorting 
{
	background: 				#BBBBBB url('/snapshots/images/sort_both.png') no-repeat right center;
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

<!--- 
<div id="top" name="top">&nbsp;</div>
 --->

<style>
a.nav_links
{
	color:				#ffffff; 
	text-decoration:	none;
}
</style>


<!--- show shortcuts to the dtaa tables if more than one type of item is retrieved --->
<div class="page_title">
<cfswitch expression="#form.item_type_code#">
	<cfcase value="1">
		<a href="#Operators" class="nav_links">[ operators ]</a>&nbsp;&nbsp;&nbsp;
	</cfcase>
	<cfcase value="2">
		<a href="#Distributors" class="nav_links">[ distributors ]</a>&nbsp;&nbsp;&nbsp;
	</cfcase>
	<cfcase value="3">
		<a href="#Products" class="nav_links">[ products ]</a>
	</cfcase>
	<cfdefaultcase>
		<a href="#Operators" class="nav_links">[ operators ]</a>&nbsp;&nbsp;&nbsp;
		<a href="#Distributors" class="nav_links">[ distributors ]</a>&nbsp;&nbsp;&nbsp;
		<a href="#Products" class="nav_links">[ products ]</a>
	</cfdefaultcase>
</cfswitch>
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="/snapshots/nav_links.cfm">
<!--- ----------------------------------------------------------------------------------------- --->




<div id="container" style="width:99%;">


<cfloop index="i" list="#form.item_type_code#">

<!--- ----------------------------------------------------------------------------------------- --->
	<cfinclude template="search_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<a name="<cfoutput>#get_type_code.snapshot_metadata_item_type_description#</cfoutput>"><br /></a>

<div class="sub_section_title">
	<cfoutput>#get_type_code.snapshot_metadata_item_type_description#</cfoutput>

	<cfif #form.item_type_code# EQ "1,2,3">
		<a href="#top"><img src="/snapshots/images/top.png" border="0" align="right"></a>
	</cfif>

</div>



<div class="rounded_corners">

<table id="table_id_<cfoutput>#i#</cfoutput>" class="pretty" width="100%" cellpadding="2" cellspacing="0" border="0" align="center">

	<thead>
		<tr>
			<th class="datagrid_header summary" width="20%" height="20"><img src="images/sort.png">&nbsp;Item #</th>
			<th class="datagrid_header summary" width="80%"><img src="images/sort.png">&nbsp;Name</th>
		</tr>
	</thead>

	<tbody>
	<cfoutput query="get_data">
	<tr>
		<td class="datagrid_data"><a href="search_details.cfm?item_id=#item_id#&item_type_code=#i#&date_period=#date_period#">#item_id#</a></td>
		<td class="datagrid_data">#item_name#</td>
	</tr>
	</cfoutput>
	</tbody>

</table>

</div>

</cfloop>



</div>
</body>
</html>