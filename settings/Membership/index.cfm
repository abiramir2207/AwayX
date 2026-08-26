<!----
	Name: index.cfm
	Created By:   Dinesh Rachala :: 03/04/2013
	Copyright (c) 2013 Blacksmith Applications, Inc.
 	Description:
	Usage: Used to navigate between Family/Buying Group/
---->
<cfset PageTitle = "membership">
<cfparam name="form.group" default=" ">
<cfparam name="form.groupid" default=" ">
<cfparam name="form.shipto" default=" ">
<cfparam name="form.shiptoid" default=" ">
<cfparam name="url.display_type" default="1">

<cfmodule template="/customTags/layout.cfm"
              layoutID = "membership"
              selectedIndex = "#(url.display_type eq '1' ? 0 : 1)#" >

<cfinclude template="../advanced_budget/actionFormat.cfm">

<cfif  url.display_type EQ "1">
	<!--- BUYING GROUP --->
		<cfset Filter1 = #application.returned_customer_setting.buying_group_label_singular#&"		(ID/Name)">
<cfelseif url.display_type EQ "2">
	<!--- FAMILY --->
		<cfset Filter1 = #application.returned_customer_setting.family_name_label_singular#&"		(ID/Name)">
<cfelse>
		<cfset Filter1 = "">
</cfif>

		<cfset Filter2 = #application.returned_customer_setting.shard_ship_to_label#&"			(ID/Name)">

<cfoutput>
<form name="groupForm" action="index.cfm?display_type=#url.display_type#" method="post">
	<cfswitch expression="#url.display_type#" >
			<cfcase value="1">
					<cfset groupmethod = 'lookupBuyingGroup'>

						<table style="margin-bottom:-10px;margin-top:10px;">
							<tr>
								<td>
											<b>#Filter1#:</b> <input type="text" name="group" value="#form.group#" id="group" style="width:300px;">
											<input type="hidden" name="groupid" value="#form.groupid#" id="groupid">
								</td>
								<td>
											<b>#Filter2#:</b> <input type="text" name="shipto" value="#form.shipto#" id="shipto" style="width:300px;">
											<input type="hidden" name="shiptoid" value="#form.shiptoid#" id="shiptoid">
								</td>
								<td>
											<a href="javascript: document.groupForm.submit();">#LCase(ActionText("Search"))#</a>
								</td>
						</tr>
						</table>

					<cfif len(trim(form.group)) OR len(trim(form.shipTo))>
						<cfinclude template="membership_display.cfm" >
					<cfelse>
						<div style="margin-top:30px;"></div>
					</cfif>

			</cfcase>
			<cfcase value="2">
					<cfset groupmethod = 'lookupFamily'>
						<table style="margin-bottom:-10px;margin-top:10px;">
							<tr>
								<td>
											<b>#Filter1#:</b> <input type="text" name="group" value="#form.group#" id="group" style="width:300px;">
											<input type="hidden" name="groupid" value="#form.groupid#" id="groupid">
								</td>
								<td>
											<b>#Filter2#:</b> <input type="text" name="shipto" value="#form.shipto#" id="shipto" style="width:300px;">
											<input type="hidden" name="shiptoid" value="#form.shiptoid#" id="shiptoid">
								</td>
								<td>
											<a href="javascript: document.groupForm.submit();">#LCase(ActionText("Search"))#</a>
								</td>
						</tr>
						</table>

					<cfif len(trim(form.group)) OR len(trim(form.shipTo))>
						<cfinclude template="membership_display.cfm" >
					<cfelse>
						<div style="margin-top:30px;"></div>
					</cfif>

			</cfcase>
			<cfdefaultcase>

			</cfdefaultcase>
	</cfswitch>
</form>
</cfoutput>

<cfinclude template="/Common_Files/jQuery.cfm">
<cf_include files="/script/popup/tinybox.js, /script/javascript/jQueryUI_1_11/jquery-ui.full.css">
<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){
//LOOK UP FAMILY
        $('#group').autocomplete({
				minLength: 1,
				source: function(request, response) {
                $.ajax({
                    url: "/components/settings/membership/customerGroupMembership.cfc?method=<cfoutput>#groupmethod#</cfoutput>&returnformat=json",
                    dataType: "json",
                    data: {
			                      search: request.term,
			                      maxRows: 10
			                    },
                    success: function(data) {
                      response(data.slice(0, 10));
                    }
                })
            } ,
			 select: function(event, ui) {
                $('#groupid').val(ui.item.id);
            }
        });

//LOOK UP SHIP TO
        $('#shipto').autocomplete({
				minLength: 1,
				source: function(request, response) {
                $.ajax({
                    url: "/components/settings/membership/customerGroupMembership.cfc?method=lookupShipTo&returnformat=json",
                    dataType: "json",
                    data: {
			                      search: request.term,
			                      maxRows: 10
                    			},
                    success: function(data) {
                      response(data.slice(0, 10));
                    }
                })
            },
				 select: function(event, ui){
		              $('#shiptoid').val(ui.item.id);
	            }
        });
    });

//POP_UP
function navigate(groupid, shiptoid,grouptype,startdate){
	TINY.box.show({
						iframe:'membership_edit.cfm?groupid='+groupid+'&shiptoid='+shiptoid+'&grouptype='+grouptype+'&startdate='+startdate
						,boxid:'frameless'
						,width:550
						,height:400
						,fixed:false
						,maskid:'mask'
						,maskopacity:10
						,closejs:function(){
							document.groupForm.submit();
							}
		})
}
</script>
</cfmodule>