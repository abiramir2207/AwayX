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

    <cfcase value			=	"78888-94737-84955-80478">
		<cfset content		=	"market_total.cfm">
        <cfset info_name	=	"market_total_info.cfm">
        <cfset page_name	=	label.territory.singular & " Total">
        <cfset logo_name	=	"red.png">
	</cfcase>

    <cfcase value			=	"78887-94737-85955-80428">
		<cfset content		=	"market_budget_level_detail.cfm">
        <cfset info_name	=	"market_budget_level_detail_info.cfm">
        <cfset page_name	=	label.territory.singular & " budget level detail">
        <cfset logo_name	=	"red.png">
	</cfcase>

    <cfcase value			=	"78889-94739-95955-90429">
		<cfset content		=	"sub_region_budget_level_detail.cfm">
        <cfset info_name	=	"sub_region_budget_level_detail_info.cfm">
        <cfset page_name	=	label.sub_region.singular & " budget level details">
        <cfset logo_name	=	"red.png">
	</cfcase>

    <cfcase value			=	"35852-17070-37427-48000">
		<cfset content		=	"customer_specific_budgets.cfm">
		<cfset info_name	=	"customer_specific_budgets_info.cfm">
		<cfset page_name	=	"Customer Specific Budgets - by Distributor">
        <cfset logo_name	=	"red.png">
	</cfcase>

    <cfcase value			=	"78887-94887-85955-88428">
		<cfset content		=	"sub_region_budgets.cfm">
		<cfset info_name	=	"sub_region_budgets_info.cfm">
        <cfset page_name	=	label.program.singular & " details">
        <cfset logo_name	=	"red.png">
	</cfcase>






    <cfcase value			=	"78887-94749-95959-90409">
		<cfset content		=	"select_budget_classes.cfm">
		<cfset info_name	=	"select_budget_classes_info.cfm">
        <cfset page_name	=	"budget class selection">
        <cfset logo_name	=	"red.png">
	</cfcase>





<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

    <cfcase value="64967-42449-38955-35403">
		<cfset content="customer_specific_budgets_type.cfm">
		<cfset page_name="Customer Specific Budgets - by Budget Type">
        <cfset logo_name="red.png">
	</cfcase>


    <cfcase value="25361-51743-37247-67820">
		<cfset content="customer_specific_budgets_territory.cfm">
		<cfset page_name="Customer Specific Budgets - by Territory">
        <cfset logo_name="red.png">
	</cfcase>


    <cfcase value="88047-21078-75459-74654">
		<cfset content="customer_specific_budgets_parent.cfm">
		<cfset page_name="Customer Specific Budgets - by Corporate Parent">
        <cfset logo_name="red.png">
	</cfcase>

    <cfcase value="51124-68216-86238-83797">
		<cfset content="roi.cfm">
		<cfset page_name="budget dollars efficiency">
        <cfset logo_name="red.png">
	</cfcase>

    <cfcase value="61432-92781-14853-63278">
		<cfset content="user_total.cfm">
		<cfset page_name="User Total">
        <cfset logo_name="red.png">
	</cfcase>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->





    <cfdefaultcase>
		<cfset content="nodata.cfm">
		<cfset page_name="select dashboard">
        <cfset logo_name="ios_logo2.png">
	</cfdefaultcase>

</cfswitch>


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
<!--- styles ---------------------------------------------------------------------------------- --->
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
	padding:				0px 0px 0px 0px;
	text-align:				right;
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
	padding:				3px 0px 3px 0px;
	text-align:				left;
}

td.data_grid_level2
{
	font-family:			sans-serif;
	font-size:				12px;
	font-weight:			bold;
	color:					#0092ff;
	background-color:		#000000;
	border-top:				10px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			2px #0092ff solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				3px 0px 3px 0px;
	text-align:				left;
}

td.data_grid_level3
{
	font-family:			sans-serif;
	font-size:				11px;
	font-weight:			normal;
	color:					#AAAAAA;
	border-top:				0px #000000 solid;
	border-right:			0px #000000 solid;
	border-bottom:			0px #000000 solid;
	border-left:			0px #000000 solid;
	margin:					0px 0px 0px 0px;
	padding:				0px 5px 8px 0px;
	text-align:				right;
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
	font-size:				12px;
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
	border-bottom:			1px #444444 solid;
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

<!--- /* charts in the user content page ****************************************************** */ --->
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

<!--- /* used by the small "dollars in thousands" note used everywhere ************************ */ --->

span.dollars_note
{
	color:			#ffdd00;
	font-weight:	bold;
	font-size:		12px;
	font-style:		italic;
	text-align:		left;
	margin:			0px 0px 0px 25px;
	padding:		0px 0px 0px 0px;
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

</style>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- this is a fix for IE when there are round corners and gradients ------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->
<!--- ----------------------------------------------------------------------------------------- --->
