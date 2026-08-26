<!--
  * ==================================================================================================== 
  *  program_search_list.cfm
  *  @Author: Sharon Harris
  *    @Date: 2018-07-12 
  * 
  * @Remarks:   
  *  This file contains the Program Search List tab feature.
  *
  *  
  * ==================================================================================================== 
-->
<style>
    input[type='radio'], label {   
        vertical-align: bottom;
     }
</style>

<cfoutput>
<cfsavecontent variable="filter_content">
	<form name="frmProgramList" class="active-panel" method="post">

    <div style="margin-top:5px; margin-left:4px;">
        <label for="program_create_list">Enter Program numbers:</label><br>
		<textarea name="program_create_list" id="program_create_list" rows="21" cols="15" style="margin-top:3px" title="To search for a list of programs:&##13;Type or paste in a list of programs. #stProgramSettings.exactlistmatchingonmessage#. The program number should only include the middle 7 digits, ex: 1000233. Separate each program by the enter key. Click search."></textarea><br>
		Find using:
        <label>
            <input type="radio" name="match_type" value="1"  <cfif application.appSettingsget.getExact_List_Matching_On() eq "0">checked</cfif>>Partial match
        </label>
        <label>
            <input type="radio" name="match_type" value="2" <cfif application.appSettingsget.getExact_List_Matching_On()>checked</cfif>>Exact match
        </label>
	</div>

	<div style="margin-top:10px; margin-bottom:10px;">
        <button type="button" onClick="filterData('ListSearch');" class="button recommended" style="margin:0 4px;">search</button>
        <button type="button" onClick="clearList();" class="button alt" style="margin:0 4px;">clear list</button>
    </div>
</form>

</cfsavecontent>
#application.util.string.compress(filter_content)#
</cfoutput>

<script>
    function clearList() {
        $('#program_create_list').val('');
    }
</script>