<!--
  * ==================================================================================================== 
  *  program_search_options.cfm
  *  @Author: Sharon Harris
  *    @Date: 2018-07-11 
  * 
  * @Remarks:   
  *  This file contains the Program Search left pane tab handling.
  *
  *  
  * ==================================================================================================== 
-->

<cfset request.altActiveColor = "true">
<cf_include files="/common_files/tabnavFlex.cfm"/>

<div class="nav">
    <ul class="nav">
        <li  class="topnav" onclick="showTab(event, 'searchTab')" id="defaultTab">Search</li>
		<cfif local.External_Customer_Profile_Access EQ 0>
        <li  class="topnav" onclick="showTab(event, 'listTab')" id="liTab">List</li>
        <li  class="topnav" onclick="showTab(event, 'toolsTab')" id="liTools">Tools</li>
		</cfif>
	</ul>
</div>

<div id="searchTab" class="tabContent">
    <cfinclude template = "/programs/program_search_filters.cfm">
</div>

<div id="listTab" class="tabContent">
    <cfinclude template = "/programs/program_search_list.cfm">
</div>

<div id="toolsTab" class="tabContent">
    <cfinclude template = "/programs/program_search_tools.cfm">
</div>

<script>
    // Default to the first tab open
    document.getElementById("defaultTab").click();
</script>