<!---
* ==================================================================================================== 
*    @File: \billbacks\settlements\controls_pane.cfm
*  @Author: Sharon Harris
*    @Date: June 2019 
* 
* @Remarks: Settlements page - Left pane which shows the controls (search)
*
* ==================================================================================================== 
--->
<style>
	.controls-card {
		margin: 5px 2px 5px 0;
	}
	.card-header {
		background-color: #222a97;
		border-radius: 5px 5px 0px 0px;
		color: #FFF;
		font-size: 12px;
		font-weight: 600;
		height: 22px;	
		padding: 5px 5px 5px 9px;
	}
	.card-main {
		background-color: #f5f6fa; 
		border-color: #d8d9dd;
		border-radius: 0;
		border-style: solid;
		border-width: 0px 1px 1px 1px;
		min-height: 25px;
		padding-top:5px; 
		padding-left:4px; 
		padding-right:4px; 
		width: 100%;
	}
</style>

<cfif 1>
<div id="options-section" class="controls-card">
	<div class="card-header">Options</div> 
	<div class="card-main">
		<label class="mr-1">Match Deductions?:</label> 
		<input type="radio" class="ml-1 mr-1" name="match-yn" id="match-y" value="1" checked title="Choose Yes to start with a Deduction and detail the settlement information to match to the Deduction"/><label for="match-y">Yes</label>
		<input type="radio" class="ml-2 mr-1" name="match-yn" id="match-n" value="0" title="Choose No to create the Billback independent of the Deduction"/><label for="match-n">No</label>
	</div>
</div>
</cfif>

<div id="search-section" class="controls-card">
	<div class="card-header">Search</div> 
	<div class="card-main">
		<cfinclude template = "/billbacks/settlements/settlements_search_filters.cfm">
	</div>
</div>

<div id="deduction-results-section" class="controls-card">
	<div class="card-header">Deduction Results</div> 
	<div class="card-main">
		<!--- <cfinclude template = "/billbacks/settlements/deduction_results.cfm"> --->
	</div>
</div>