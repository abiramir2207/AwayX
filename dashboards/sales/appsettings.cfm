<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with the settings ----------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the permissions for this user ------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="_get_position_lists.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the correct terms from the db for this customer and convert them to local variables - --->
<!--- ----------------------------------------------------------------------------------------- --->
	<cfinclude template="../terminology.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- Used to redirect to the correct contents file ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<CFPARAM NAME="content" DEFAULT='nodata.cfm'>
<CFPARAM NAME="page_name" DEFAULT=''>

<cfswitch expression="#content#">

    <cfcase value="26792-99654-16070-96715">
		<cfset page_name="Sales Last 12 Months">
        <cfset uom="eqc">
		<cfset content="last_12_months.cfm">
		<cfset sql_content="">
	</cfcase>

    <cfcase value="21496-54091-46875-59977">
		<cfset page_name="Sales Fiscal Year Summary">
        <cfset uom="eqc">
		<cfset content="fiscal_year_summary.cfm">
		<cfset sql_content="">
	</cfcase>

    <cfcase value="15339-12021-74875-68397">
		<cfset page_name="Sales View Drill Down">
        <cfset uom="eqc">
		<cfset content="sales_view_drilldown.cfm">
		<cfset sql_content="">
	</cfcase>

<!--- Sales Tracker --->

    <cfcase value="81957-97068-45938-95590">
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Net Sales $">
		<cfset content="sales_tracker_view.cfm">
	</cfcase>

    <cfcase value="63141-57622-30802-14065">
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Cases">
		<cfset content="sales_tracker_view.cfm">
	</cfcase>

    <cfcase value="75084-89619-44658-45919">
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Trade Operators $">
		<cfset content="sales_tracker_view.cfm">
	</cfcase>

    <cfcase value="74621-35745-50011-23332">
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Trade Distributors $">
		<cfset content="sales_tracker_view.cfm">
	</cfcase>

    <cfcase value="26011-88319-25672-80891">
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Trade Total $">
		<cfset content="sales_tracker_view.cfm">
	</cfcase>


    <cfdefaultcase>
		<cfset page_name="Sales Tracker">
        <cfset uom="">
        <cfset title="Net Sales $">
		<cfset content="sales_tracker_view.cfm">
	</cfdefaultcase>

</cfswitch>




<!--- ----------------------------------------------------------------------------------------- --->
<!--- these are the values to be used by the charts so they are all consistent ---------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfset chartwidth = 				900>
<cfset chartheight = 				450>
<cfset chartformat = 				"png">
<cfset chartforegroundcolor = 		"##FFFFFF">
<cfset chartdatabackgroundcolor =	"##000000">
<cfset chartfontsize = 				12>
<cfset chartshowlegend = 			"yes">
<cfset chartbackgroundcolor = 		"##000000">

<cfset actual_sales_color = 		"##FFFFFF">
<cfset actual_sales_type = 			"bar">

<cfset forecasted_sales_color = 	"##086FA1">
<cfset forecasted_sales_type = 		"bar">

<cfset sply_sales_color = 			"##FF8800">
<cfset sply_sales_type = 			"line">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- custom function to format numbers in dollars with any number of decimals ---------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfscript>
	function MyDollarFormat(money_string)
		{
			money_string = numberformat(money_string, "$9,999,999,999");
			return(money_string);
		}
</cfscript>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- math funtions used everywhere ----------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="../udf_functions.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- the styles the styles the styles the styles the styles the styles the styles the styles - --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<style>

<!--- /* HTML5: used to fix the content shift due to the scroll bar appearing */ --->
html
{
	overflow-y:				scroll;
}

<!--- /* body section ****************************************************** */ --->
body 
{
	background-color:		#373737;
	background-image:		url(images/black_sand.png);
	margin:					0px 0px 0px 0px;
	padding:				0px 0px 0px 0px;
} 

<!--- /* header section **************************************************** */ --->
div.header
{
	font-family:			sans-serif;
	font-size:				14px;
	font-weight:			bold;
	color:					#FFFFFF;
	background-color:		#000000;
	margin:					10px 0px 0px 0px;
	width:					950px;
	height:					60px;
	padding:				0px 0px 0px 0px;
	border:					0px #000000 solid;
	border-radius:			8px;
	background: #777777; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzc3Nzc3NyIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMyMjIyMjIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #777777 0%, #222222 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#777777), color-stop(100%,#222222)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #777777 0%,#222222 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #777777 0%,#222222 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #777777 0%,#222222 100%); /* IE10+ */
	background: linear-gradient(top,  #777777 0%,#222222 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#777777', endColorstr='#222222',GradientType=0 ); /* IE6-8 */
	text-shadow: 			1px 1px 1px #000000;
	text-align:				left;
}

div.header_page_name
{
	font-family:			sans-serif;
	font-size:				16px;
	font-weight:			bold;
	color:					#FFFFFF;
}

select.header_select_box
{
	border:					0px #000000 solid;
	border-radius:			4px;
	font-size:				15px;
}

<!--- /* main content section ********************************************* */ --->
div.main_container
{
	font-family:			sans-serif;
	font-size:				14px;
	font-weight:			bold;
	color:					#FFFFFF;
	background-color:		#000000;
	margin:					10px 0px 10px 0px;
	width:					950px;
	padding:				0px 0px 5px 0px;
	border:					0px #000000 solid;
	border-radius:			8px;
	text-align:				left;
}

<!--- /* footer section **************************************************** */ --->
div.footer
{
	font-family:			sans-serif;
	font-size:				10px;
	font-weight:			bold;
	color:					#FFFFFF;
	background-color:		#000000;
	margin:					0px 0px 0px 0px;
	width:					950px;
	height:					50px;
	padding:				0px 0px 5px 0px;
	border:					0px #000000 solid;
	border-radius:			8px;
	background: #777777; /* Old browsers */
	/* IE9 SVG, needs conditional override of 'filter' to 'none' */
	background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzc3Nzc3NyIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMyMjIyMjIiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
	background: -moz-linear-gradient(top,  #777777 0%, #222222 100%); /* FF3.6+ */
	background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#777777), color-stop(100%,#222222)); /* Chrome,Safari4+ */
	background: -webkit-linear-gradient(top,  #777777 0%,#222222 100%); /* Chrome10+,Safari5.1+ */
	background: -o-linear-gradient(top,  #777777 0%,#222222 100%); /* Opera 11.10+ */
	background: -ms-linear-gradient(top,  #777777 0%,#222222 100%); /* IE10+ */
	background: linear-gradient(top,  #777777 0%,#222222 100%); /* W3C */
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#777777', endColorstr='#222222',GradientType=0 ); /* IE6-8 */
	text-align:				left;
}

<!--- /* data grid section ************************************************* */ --->
td.data_grid_header, th.data_grid_header
{
	font-family:			sans-serif;
	font-size:				12px;
	font-weight:			bold;
	color:					#FFFFFF;
	background-color:		#000000;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			1px #FFA500 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				4px 4px 4px 5px;
	white-space:nowrap;
}

td.data_grid_level1
{
	font-family:			sans-serif;
	font-size:				14px;
	font-weight:			bold;
	color:					#FFA500;
	background-color:		#000000;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			2px #FFA500 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				4px 4px 4px 4px;
	text-align:				left;
}

td.data_grid_level2
{
	font-family:			sans-serif;
	font-size:				12px;
	font-weight:			bold;
	color:					#0097fe;
	background-color:		#000000;
	border-top:				10px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			2px #0097fe solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				2px 4px 2px 4px;
	text-align:				left;
}

td.data_grid_level3
{
	font-family:			sans-serif;
	font-size:				11px;
	font-weight:			bold;
	color:					#cccccc;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #000000 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				2px 5px 2px 2px;
	text-align:				left;
	vertical-align:			top;
}

td.data_grid_subtotals
{
	font-family:			sans-serif;
	font-size:				11px;
	font-weight:			bold;
	background-color:		#000000;
	color:					#FFFFFF;
	border-top:				1px #FFA500 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #000000 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				4px 20px 8px 5px;
	text-align:				left;
	vertical-align:			top;
}

td.data_grid_totals
{
	font-family:			sans-serif;
	font-size:				14px;
	font-weight:			bold;
	background-color:		#777777;
	color:					#ffffff;
	border-top:				0px #FFA500 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #FFA500 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				5px 20px 5px 5px;
	text-align:				left;
	vertical-align:			top;
}

<!--- /* links ****************************************************************** */ --->
a, a:visited, a:hover
{
	color:					#FFFFFF;
	text-decoration:		none;
}

<!--- /* grid used by the user content page ************************************* */ --->
td.grid_column_title
{
	font-family:			sans-serif;
	font-size:				16px;
	font-weight:			bold;
	color:					#0097fe;
	margin:					5px 5px 5px 0px;
	padding:				5px 5px 5px 0px;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			2px #0097fe solid;
	border-left:			0px #000000 solid;
	text-align:				left;
}

td.grid_legend
{
	font-family:			sans-serif;
	font-size:				14px;
	font-weight:			bold;
	color:					#f09f00;
	margin:					0px 0px 0px 0px;
	padding:				2px 0px 2px 0px;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			1px #444444 solid;
	border-left:			0px #000000 solid;
	text-align:				left;
	white-space:			nowrap;
}

td.grid_data
{
	font-family:			sans-serif;
	font-size:				12px;
	font-weight:			bold;
	color:					#DDDDDD;
	margin:					5px 5px 5px 0px;
	padding:				5px 5px 5px 0px;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #444444 solid;
	border-left:			0px #000000 solid;
	text-align:				left;
	white-space:			nowrap;
}

<!--- /* user name in the user content page ********************************* */ --->
div.user_name
{
	font-family:			sans-serif;
	font-size:				18px;
	font-weight:			bold;
	text-align:				left;
	color:					#ffa200;
	margin:					5px 5px 5px 5px;
	padding:				5px 5px 5px 5px;
	border-bottom:			3px #ffa200 solid;
}

<!--- /* charts in the user content page *********************************************** */ --->

div.chart_title
{
	font-family:			sans-serif;
	font-size:				16px;
	font-weight:			bold;
	color:					#0097fe;
	margin:					5px 5px 5px 0px;
	padding:				5px 5px 5px 0px;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			2px #0097fe solid;
	border-left:			0px #000000 solid;
}

<!--- /* pies in the user content page ****************************************************** */ --->

div.pie_detail
{
	font-family:			sans-serif;
	font-size:				12px;
	font-weight:			bold;
	color:					#FFFFFF;
	margin:					0px 0px 0px 0px;
	padding:				0px 0px 0px 0px;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #0097fe solid;
	border-left:			0px #000000 solid;
	text-align:				center;
}

<!--- /* master style for links ************************************************ */ --->

a.links
{
	color:#ffffff;
	text-decoration:none;
}

div.page_title
{
	color:			#ffdd00;
	font-weight:	bold;
	font-size:		15px;
	text-align:		left;
	margin:			0px 0px 15px 0px;
	padding:		0px 0px 5px 0px;
	border-bottom:	3px #FFFFFF solid;
}

<!--- /* used as the title of each section in the dashboards ********************************** */ --->
div.section_title
{
	font-family:		Arial, Helvetica, sans-serif;
	font-size:			14px;
	font-weight:		bold;
	color:				#FFFFFF;
	background-color:	#009900;
	height:				20px;
	padding:			5px 0px 0px 10px;
}

<!--- /* header section that need to be frozen so the table bodies can scroll */ --->
th
{
	text-align:				left;
	border-bottom:			10px #000000 solid;
	padding:				4px 0px 4px 0px;
	vertical-align:			bottom;
	font-family:			Arial, Helvetica, sans-serif;
	font-size:				12px;
	font-weight:			bold;
	text-transform:			uppercase;
	color:					#FFFFFF;
	background-color:		#060;
}

<!--- /* this section is used for the data grid popups used with the charts */ --->
<!--- /* it should not be used for anything else ************************** */ --->

div.hover_box
{
	border:				0px #DDDDDD solid;
	top:				100px;
	left:				150px;
	right:				150px;
	height:				425px;
	min-height:			425px;
	padding:			10px 25px 10px 25px;
	margin:				5px auto 5px auto;
	position:			absolute;
	color:				#DDDDDD;
	background-color:	#555555;
	opacity:			0.99;
	z-index:			1;
	overflow:			hidden;
	-webkit-box-shadow:	0px 0px 10px 5px #000000;
	-moz-box-shadow:	0px 0px 10px 5px #000000;
	box-shadow:			0px 0px 10px 5px #000000;
	-webkit-border-radius:	5px;
	border-radius: 			5px; 

background: #777777; /* Old browsers */
/* IE9 SVG, needs conditional override of 'filter' to 'none' */
background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzc3Nzc3NyIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiMxMTExMTEiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
background: -moz-linear-gradient(top,  #777777 0%, #111111 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#777777), color-stop(100%,#111111)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #777777 0%,#111111 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #777777 0%,#111111 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #777777 0%,#111111 100%); /* IE10+ */
background: linear-gradient(top,  #777777 0%,#111111 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#777777', endColorstr='#111111',GradientType=0 ); /* IE6-8 */
}

td.column_title, td.row_title, td.data_cell
{
	font-size:			12px;
	font-weight:		bold;
	color:				#cccccc;
	border-bottom:		1px #888888 solid;
	padding-right:		5px;
	padding-left:		5px;
	white-space: 		nowrap;
	text-align:			right;
}

td.column_title
{
	font-size:			14px;
	border-bottom:		3px #FFFFFF solid;
	color:				#FFFFFF;
}

td.row_title
{
	padding-left:		25px;
	text-align:			left;
	color:				#FFFFFF;
}

td.data_cell
{
}


</style>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfscript>

// Examples
// percentage(60,120) = 50
// percentage(50,0) = 0

function percentage(part, whole) 
	{
		if (whole LTE 0)
			 return 0;
		else 
			return (part*100/whole);
	}
</cfscript>  
<!--- ----------------------------------------------------------------------------------------- --->




<!--- ----------------------------------------------------------------------------------------- --->
<!--- this is a fix for IE when there are round corners around a gradient --------------------- --->
<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->
<!--- ----------------------------------------------------------------------------------------- --->



<!---
<!--- ----------------------------------------------------------------------------------------- --->
<!--- using the scheme of 10,000^4, we get 10 quadrillion possibilities ----------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfloop index="i" from="1" to="1000" step="1">
<cfoutput>
#randrange(10000,99999,"SHA1PRNG")#-#randrange(10000,99999,"CFMX_COMPAT")#-#randrange(10000,99999,"IBMSecureRandom")#-#randrange(10000,99999,"SHA1PRNG")#<br />
</cfoutput>
</cfloop>
--->

<!---


46968-95606-86923-71187
80901-34939-67764-34195
44993-62202-55188-52235
47786-88495-16464-25353
43754-22656-26347-39659
65949-80198-49752-22012
63013-79012-24421-15557
70156-79836-64604-85184
63083-62863-89367-25455
36006-46664-26927-48494
10675-98200-45447-78841
13991-26652-73883-80363
76793-75041-97615-50566
77470-56364-99583-55771
97959-73374-35091-16088
47901-38858-25790-16837
82974-99945-83812-71426
93848-12583-44710-61443
16914-28703-78755-36895
60668-60789-89620-71308
34102-76919-69552-37705
76821-16242-56387-38306
33843-21931-19153-20115
29205-38382-68284-45510
62938-93170-92026-65790
75862-55325-33814-31472
33468-81243-18323-14702
98849-24964-51620-30643
73705-72635-20487-40225
 --->

