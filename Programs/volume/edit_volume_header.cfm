<cfsilent>
<!---
* ==================================================================================================== 
*    @File: \programs\volume\edit_volume_header.cfm
*  @Author: Chris Nguyen
*    @Date: 2019-02-01
* 
* @Remarks: Shared code for displaying program title, navigation bar on program edit volume page  
*
*
* 
*  
* ==================================================================================================== 
--->
	<!--- TODO: Remove the default value before checking the code in --->
	<cfparam name="URL.Program_ID" default="">

	<!--- <cfset url.program_id = "39224"> --->
    <cfscript>
        volume_cfc = createObject("component", "mvc.models.program.volume.volumeApplicator");
        qProgram   = volume_cfc.getProgramDetails(url.program_id, request.AccessStructure.user_id);
    </cfscript>
</cfsilent><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><cfoutput>#(cgi.script_name contains "details.cfm" ? "Details" : "Volume " & qProgram.Contract_Number)#</cfoutput></title>
	<cfsavecontent variable="head_content">
        <cfinclude template="/common_files/tabnav-css.cfm">
		<style>
			input[type="checkbox"] {
				vertical-align: middle;
			}
		</style>
    </cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
	<cfset request.noty_version = "3">
	<cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm">
   
	<!---------------------->
	<!--- Whole document --->
	<!---------------------->
    <div id="app" class="h-screen p-2">
		<!------------------------------>
		<!--- Header - Program Info  --->
		<!------------------------------>
		<div id="header" class="flex rounded p-3 text-white font-semibold text-sm bg-blue-darkest mb-1 text justify-between">
			<cfoutput>			
				<section class="flex-1">Edit Volume</section>
				<section class="flex-1 text-center">#qProgram.Contract_Number# &nbsp; &bull; &nbsp; #qProgram.Contract_Title#</section>
				<section class="flex-1 text-right">#application.util.dateTime.DateSpanFormat(qProgram.Contract_Start_Date, qProgram.Contract_End_Date, 'mmm')# (#qProgram.Contract_Span# days)</section>
			</cfoutput>
		</div>

		<!-------------------->
		<!--- Navigation  --->
		<!-------------------->
		<div class="flex justify-between border-b mb-2">
			<cfscript>
				// current selected tab is details
				if (cgi.script_name contains "details.cfm") {
					details_css = "active";
					edit_css    = "cursor-pointer";
				}
				// current selected tab is edit volume
				else {
					edit_css    = "active";
					details_css = "cursor-pointer";
				}
			</cfscript>
			<ul class="flex list-reset nav mx-2 -mb-px">
				<cfoutput>					
                    <li class="border rounded-t w-32 #edit_css#"    onclick="reload('/programs/volume/edit_volume.cfm?#cgi.query_string#')">Edit</li>
                    <cfif qProgram.Volume_Details_Tab_Display>
                        <li class="border rounded-t w-32 #details_css#" onclick="reload('/programs/volume/edit_volume_details.cfm?#cgi.query_string#')">Details</li>
                    </cfif>
				</cfoutput>
            </ul>
            <cfif !cgi.script_name contains "detail">
                <div class="pt-2 pr-1">
                    <label class="cursor-pointer"
                            <cfoutput>title="Updated by #qProgram.Auto_Volume_Exclude_Updated_Data#"</cfoutput> >
                        <input type="checkbox" name="exclude_auto_volume" <cfif qProgram.Exclude_From_Auto_Volume_Updates is "1">checked=checked</cfif>> Exclude from auto volume updates
                    </label>
                </div>
            </cfif>
		</div>

        <script>
        function reload( url ) {
            location.href = url;
        }
        </script>

		<!--- 
			ALERT: The matching ending div tag for whole document (#app) is defined in edit_volume_footer.cfm
	</div>

</body>
</html> --->