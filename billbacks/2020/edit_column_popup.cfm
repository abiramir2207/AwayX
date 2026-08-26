<cfsilent>
	<!---
	* ==================================================================================================== 
	*    @File: billbacks\2020\edit_column_popup.cfm
	*  @Author: Sharon Harris
	*    @Date: Feb-2020
	* 
	* @Remarks: Display Contents of the popup window to edit Column field
	*           
	*
	* ==================================================================================================== 
	--->
	</cfsilent>
	<!doctype html>
	<html lang="en">
	<head>
		<title>Mass Apply Edit</title>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="ie=edge">
	
		<style>
			label {
				display: inline-block;
				float: left;
				font-size: 12px;
				font-weight: 500;
				clear: left;
				width: 35%;
				text-align: right;
				margin: 9px 5px 5px 0;
			}
			input[type=text] {
				border-radius: 3px;
				display: inline-block;
				height: 20px;
				float: left;
				margin: 5px 0;
				padding: 0 2px;
			}
			.clearfix::after {
				content: "";
				clear: both;
				display: block;
			}
			.popup-title {
				color: #343540;
				font-size: 14px;
				text-align: center;
			}
		</style>
	</head>
	
	
	<body>
		<cfparam name="URL.name" 			default="value">
		<cfparam name="URL.nSel" 			default=0>
		<!--- Determine headin gprompt, based on # of selected rows.  Zero rows are rejected before getting here, but handle just in case. --->
		<cfscript>
			prompt = "";
			if (URL.nSel eq 0) {
				prompt = "Please select at least one row.";
			}
			else {
				if (URL.nSel eq 1) {
				prompt = "Please enter a new value.<br> This will replace the "&URL.name&" value in the selected row.";
				}
				else {
					prompt = "Please enter a new value.<br> This will replace the "&URL.name&" values in the <b>"&URL.nSel&"</b> selected rows.";
				}
			}
		</cfscript>

		<!--- UI to display inside the popup --->
	
		<!--- Heading --->
		<div class="popup-title" style="margin:15px 0;"><cfoutput>#prompt#</cfoutput></div>

	
		<!--- Input --->
		<div class="clearfix"> 
			<label><cfoutput>#URL.name#</cfoutput></label> 
			<input id="mass_apply_value" name="mass_apply_value" type="text" value=""><br>
		</div>
				

		<!--- Buttons --->
		<div style="display:flex; align-items:center; justify-content:center; margin-top:10px;">
			<button type="button" id="saveIds" title="" class="button recommended">Save</button>
			<button type="button" id="cancelIds" title="" class="button">Cancel</button>
		</div>
	
	

	</body>
	</html>