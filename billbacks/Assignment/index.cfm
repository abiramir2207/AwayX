<cfsilent>
<!------ index.cfm ----->

<!------ set defaults ----->
<cfparam name="url.command" 	default="">
<cfparam name="form.command" 	default="#url.command#">
<cfparam name="form.subcommand" 	default="">

<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfif form.command eq "">
	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
</cfif>

<cfswitch expression="#form.command#">
	<cfcase value="view">        <cfset selectedIndex = 0>  </cfcase>
	<cfcase value="analyst">     <cfset selectedIndex = 1>	</cfcase>
	<cfcase value="market">      <cfset selectedIndex = 2>	</cfcase>
	<cfcase value="distributor"> <cfset selectedIndex = 3>	</cfcase>
	<cfcase value="operator">    <cfset selectedIndex = 4>	</cfcase>
	<cfcase value="supervisor">  <cfset selectedIndex = 5>	</cfcase>
	<cfcase value="assign-supervisor">  <cfset selectedIndex = 6>  </cfcase>
	<cfcase value="director">    <cfset selectedIndex = 7>  </cfcase>
	<cfcase value="assign-director">  	<cfset selectedIndex = 8>  </cfcase>
	<cfcase value="template">  	<cfset selectedIndex = 9>  </cfcase>	<!---77024 :: BB Assignment - by template --->
</cfswitch>
</cfsilent>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "billBackAssignment"
							helpLink = "true"
							selectedIndex = "#selectedIndex#" >

<cfmodule template="/customTags/include.cfm" file_to_include="/Deductions/Assignment/main_container.js, Billback_Assignment.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js, /Script/javascript/dhtml.js">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<cfset jQuery.version = "1.12.4">
<cfinclude template="/common_files/jQuery.cfm">
<!---<cfset datatables.version ="1.10.16">--->
<cfinclude template="/common_files/dataTables2.cfm">

<FORM NAME="frmBillbackAssignment" ACTION="index.cfm" METHOD="Post">

<cfswitch expression="#form.command#">

<cfcase value="view">
	<cfinclude template="view.cfm" />
</cfcase>

<cfcase value="analyst">
	<cfinclude template="analyst.cfm" />
</cfcase>

<cfcase value="market">
	<cfinclude template="market.cfm" />
</cfcase>

<cfcase value="distributor">
	<cfinclude template="distributor.cfm" />
</cfcase>

<cfcase value="operator">
	<cfinclude template="operator.cfm" />
</cfcase>
<cfcase value="supervisor">
	<cfinclude template="supervisor.cfm" />
</cfcase>

<cfcase value="assign-supervisor">
	<cfinclude template="assignSupervisor.cfm" />
</cfcase>

<cfcase value="director">
	<cfinclude template="director.cfm" />
</cfcase>

<cfcase value="assign-director">
	<cfinclude template="assignDirector.cfm" />
</cfcase>
<!---77024 :: BB Assignment - by template --->
<cfcase value="template">
	<cfinclude template="BB_ApproveBy_Template.cfm" />
</cfcase>
</cfswitch>

<cfoutput>
<input type="Hidden" name="command" value="#form.command#" />
<input type="Hidden" name="subcommand" value="#form.subcommand#" />
<input type="Hidden" name="BBAssignmentByTemplate" id="BBAssignmentByTemplate" value="#val(appSettings.get_Setting('BB_Assignment_By_Template'))#" />
</cfoutput>
</FORM>
<script type="text/javascript">
	exportAll = function() {
window.open( "/Common_Files/exportAll.cfm?" + "type=getAvailableDistributors"
						+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('BB_UnAssigned_Distributos')#</cfoutput>"
	,"_blank"
	,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
</script>
</cfmodule>