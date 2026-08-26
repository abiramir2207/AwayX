<!------ header.cfm ----->
<cfparam name="Active" 	default="">
<cfinclude template="Lock_Template.cfm">

<cfif Active EQ 0 OR (Active EQ 1 AND pageName NEQ "basicinfo") OR (Active EQ 1 AND pageName EQ "basicinfo" and action EQ "Edit" AND displayheader EQ 1)>
	<cfset TR_BORDER_WIDTH = 2>
	<cfset TD_FORE_COLOR = "FFE083">
	<style type="text/css">
    #tabs7 { border-collapse:collapse; margin-top:10px; }

    #tabs7 tr { line-height:35px; }
    #tabs7 td { text-align:center; font-weight:bold; font-size:12px; background-color:#dddddd; border:1px solid #A5A5A5; }

    #tabs7 a:link, #tabs7 a:visited,
    #tabs7 a:hover, #tabs7 a:active { color:rgb(0, 136, 204); text-decoration:none; }

    #tabs7 a:link.headerselected , #tabs7 a:visited.headerselected ,
    #tabs7 a:hover.headerselected , #tabs7 a:active.headerselected  { color:black; font-size:1.0em; font-weight:bold; text-transform: capitalize; }

    #tabs7 a:hover { background-color:white; }
	#tabs7 .headerselected { background-color:white; border-bottom:0px; }
	td.headerselected { background-color:white; }

    #tabs7 .tdfirst { border-top:0; border-left:0; border-right:0; background-color:white; }
    #tabs7 .tdlast { border-top:0; border-right:0; border-left:0; background-color:white }
	</style>

	<cf_include files="/styles/css-loader.css">

	<cfparam name="pageName" 		 default="">
	<cfparam name="ID" 				   default="0">
	<cfparam name="Generic_Type" default="">
	<cfparam name="Action" 			 default="">
	<cfparam name="Created_Type" default="">

	<cfinclude template="Page_List.cfm" />

	<cfset F_Counter = 1>
    <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( listToArray( "3," & repeatString("10,", listLen(PAGE_TITLES)) & ",4" ) )>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" id="tabs7">
		<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
	<tr>
	    <td class="tdfirst">&nbsp;</td>
			<cfloop list="#PAGE_TITLES#" index="ThisMenuItem">
			  <cfscript>
				  ThisURL             = ListGetAt(PAGE_URLS, F_Counter, ",");
				  ThisPageName        = ListGetAt(PAGE_NAMES, F_Counter, ",");
				  variables.className = ( ThisPageName EQ pageName ? 'headerselected' : '' );
				  F_Counter = F_Counter + 1;
				</cfscript>
				<cfoutput><td class="#variables.className#" nowrap><a class="#variables.className# hmenu" href="#ThisURL#"> &nbsp; #ThisMenuItem# &nbsp; </a></td></cfoutput>
			</cfloop>
			<td class="tdlast">&nbsp;</td>
		</tr>
	</table>
	<script>
		$("a.hmenu").click(function(){
			show_loader( "LOADING " + $(this).text().trim().toUpperCase() + ", PLEASE WAIT..." );
		});
	</script>
</cfif>
