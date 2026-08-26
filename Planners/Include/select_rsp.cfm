<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/include/select_planner_rsp.cfm
	Created Date:  2016 Apr
	  Created By:  kal
	 Description:  displays products from source planner not in target planner during copy
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<style>
	th.left { text-align: left;}
	td.center { text-align: center; }
	td.hand { cursor: pointer; }
	td.numeric { text-align: right; }
	div.actions a { margin: 0 50px; position: relative; top: -2px; }
	div.rsp { margin: 15px 20px 20px 20px; }
	div.rsp > label {font-weight: bold; margin-right: 10px;}
	div.rsp > select { margin-right: 15px; width: auto; }
</style>

<cfscript>
	userManager = createObject("component", "components.user.UserManager");
	profile = createObject("component", "components.user.Profile");
	qGetProfileSettings = profile.getProfileSettings(request.AccessStructure.Profiles_ID);
	planner_create_profiles = profile.profilesList("planner_create = 2", "planner");
</cfscript>

<form id="select_planner_rsp" method="post">
	<cfset saveHiddenValues()>

	<cf_include files="/common_files/dhx_message.cfm">

	<!--- get user positions id & rsp list --->
	<cfset this_user_id  = request.AccessStructure.User_ID />
	<cfset this_user_positions_id = userManager.getPositionId(request.AccessStructure.User_ID, 1) />
	<cfset rspList = userManager.getRSPList(request.AccessStructure.User_ID, qGetProfileSettings.Program_Scorecard_Restrict_Created_By) />
	
	<cfsavecontent variable="uncompressed">
		<div class="rsp">
		<label class="rsp" for="rspList"> Responsible Sales Person:  </label>
		<select name="responsible_user_id_position_id" id="responsible_user_id_position_id">
			<!--- Default to RSP with one position and not on behalf of others --->
			<option value=""> select an option </option>
			<cfoutput query="rspList">
				<!--- select only RSP that have planner create permission --->
				<cfif listFindNoCase(planner_create_profiles, rspList.Profiles_ID)>
					<cfif rspList.Position_Level eq 3>
						<cfset positionlevel = application.returned_customer_setting.market_label_singular>
					<cfelseif rspList.Position_Level eq 2>
						<cfset positionlevel = application.returned_customer_setting.region_label_singular>
					<cfelseif rspList.Position_Level eq 1>
						<cfset positionlevel = application.returned_customer_setting.zone_label_singular>
					<cfelse>
						<cfset positionlevel = "Headquarters"/>
					</cfif>
					<option value="#user_positions_id#_#user_id#"
						<cfif rspList.user_id eq this_user_id AND rspList.user_positions_id EQ this_user_positions_id>selected</cfif>>
						#positionlevel# &nbsp;[#rspList.position_label#] &nbsp;#rspList.user_full_name# <cfif appSettings.getPgmViewDisplaySPRAddress2() AND len(trim(company_name)) GT 0>- #Company_Name#</cfif>
					</option>
				</cfif>
			</cfoutput>
		</select>
		<a href="##" id="choose"><cfoutput>#application.util.string.linkFormat("select")#</cfoutput></a>
		</div>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( uncompressed )#</cfoutput>

	<script>

		function rsp_selected (){
			var rsp = $('#responsible_user_id_position_id').val().split("_");
			$("input[name=rsp_position_id]").val(rsp[0]);
			$("input[name=rsp_user_id]").val(rsp[1]);
			$("input[name=chosen_rsp]").val($('#responsible_user_id_position_id').find("option:selected").text());
			$("#select_planner_rsp").submit();
		}

		// rsp selected
		$("#choose").click(function(){
			if($('#responsible_user_id_position_id').val() == ''){
				dhtmlx.message({
					text: 	"please select a responsible sales person.",
					expire: 2000
				});
			}else{
				rsp_selected();
			}
		});

		// if RSP is single position (not multi position) then submit form
		<cfif rspList.recordCount eq 1>
			rsp_selected();
		</cfif>

	</script>
</form>
