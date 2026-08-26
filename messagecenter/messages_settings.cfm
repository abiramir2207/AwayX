
<div class="page_title"><cfoutput>#title#</cfoutput></div>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- used by the date pickers --->
<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" src="datepickers_code/datepickr.js"></script>
<link rel="stylesheet" type="text/css" href="datepickers_code/datepickr.css">


<!--- ----------------------------------------------------------------------------------------- --->
<!--- script used in the message creation process popup											--->
<!--- ----------------------------------------------------------------------------------------- --->
<script>
function PopupCenter(pageURL, title,w,h) {
var left = (screen.width/2)-(w/2);
var top = (screen.height/2)-(h/2);
var targetWin = window.open (pageURL, title.replace(/\s/g, ''), 'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left);
}
</script>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- begining of content --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="content">


<!---
<cfparam name="all" default="0" >

<cfparam name="programs" default="0" >

<cfparam name="programs_too_long" default="0" >
<cfparam name="programs_too_long_value" default="0" >

<cfparam name="programs_backdated" default="0" >
<cfparam name="programs_backdated_value" default="0" >

<cfparam name="programs_reassigned" default="0" >

<cfparam name="products" default="0" >
<cfparam name="products_new_item" default="0" >
<cfparam name="products_discontinued_item" default="0" >

<cfparam name="sales" default="0" >
<cfparam name="sales_changes" default="0" >
<cfparam name="sales_new_rep" default="0" >

<cfparam name="customers" default="0" >
<cfparam name="customers_inactive" default="0" >

<cfparam name="system" default="0" >
<cfparam name="system_jobs" default="0" >

<cfparam name="system_custom_text" default="" >
<cfparam name="system_custom_from" default="#now()#" >
<cfparam name="system_custom_to" default="#now()#" >


<cfparam name="modified_by_user_id" default="#user_id#" >
<cfparam name="modified_on_date" default="#now()#" >

 --->

<!--- ----------------------------------------------------------------------------------------- --->
<!--- retrieve the settings from db --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset useLakebaseForget_settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("msg_ctr_settings")>
<cfif useLakebaseForget_settings>
	<cftry>
		<cfset get_settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("msg_ctr_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_settings>
<cfquery name="get_settings" datasource="#db_connection#">
	 SELECT		*
	 FROM		msg_ctr_settings
</cfquery>
</cfif>




<style>

table.messages
	{
		padding:		0px 0px 0px 0px;
		margin:			0px 0px 0px 0px;
		border:			0px #cccccc solid;
		width:			100%;
	}
td.messages
	{
		padding:		3px 3px 3px 3px;
		margin:			0px 0px 0px 0px;
		border:			0px #cccccc solid;
		color:			#333333;
	}
td.messages_titles
	{
		padding:		5px 5px 5px 5px;
		margin:			0px 0px 0px 0px;
		border:			0px #cccccc solid;
		color:			#333333;
		font-weight:	bold;
		border-bottom:	1px #cccccc solid;
	}

td.indent
	{
		padding:		0px 0px 0px 25px;
	}

col.messages_label
	{
		width:			90%;
	}

col.messages_data
	{
		width:			10%;
	}

div.group_name
	{
		font-size: 		14px;
		font-weight:	bold;
		text-transform:	capitalize;
		padding:	10px 0px 10px 10px;
		margin:			0px auto 5px auto;
		border-radius: 4px 4px 4px 4px;
		border: 1px #c5c5c5 solid;
		width:			75%;
		box-shadow:		0 0 3px 3px #cccccc;

		/* IE9 SVG, needs conditional override of 'filter' to 'none' */
		background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNkZGRkZGQiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
		background: -moz-linear-gradient(top,  #ffffff 0%, #dddddd 100%); /* FF3.6+ */
		background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ffffff), color-stop(100%,#dddddd)); /* Chrome,Safari4+ */
		background: -webkit-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* Chrome10+,Safari5.1+ */
		background: -o-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* Opera 11.10+ */
		background: -ms-linear-gradient(top,  #ffffff 0%,#dddddd 100%); /* IE10+ */
		background: linear-gradient(to bottom,  #ffffff 0%,#dddddd 100%); /* W3C */
		filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#dddddd',GradientType=0 ); /* IE6-8 */

	}

div.group_content
	{
		padding:		5px 5px 5px 5px;
		border:			1px #c5c5c5 solid;
		border-radius:	6px;
		width:			75%;
		margin:			0px auto 25px auto;
		background-color: #EEEEEE;
	}

</style>





<!--- used to hide/dispaly notification types ------------------------------------------------- --->
<script language="JavaScript">
function setVisibility(id, visibility) {
document.getElementById(id).style.display = visibility;
}
</script>
<!--- ----------------------------------------------------------------------------------------- --->

<form action="index.cfm?id=32992-20832-29750-49236" method="post" name="form_name">




<!--- ----------------------------------------------------------------------------------------- --->
<!--- master: show (or not)  messages to the users.  if "no", no messages of any kind will show --->
<!--- ----------------------------------------------------------------------------------------- --->

<div class="group_name">
	Show Messages
</div>

<div class="group_content">

<table class="messages">
	<col class="messages_label">
	<col class="messages_data">
	<col class="messages_data">
	<thead>
		<tr>
			<td class="messages_titles"></td>
			<td class="messages_titles">Yes</td>
			<td class="messages_titles">No</td>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="messages">would you like the users to get messages/notifications?</td>

			<cfif get_settings.show_all EQ 1>
				<cfset all_yes = "checked=checked">
				<cfset all_no = "">
			<cfelse>
				<cfset all_yes = "">
				<cfset all_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="show_all" <cfoutput>#all_yes#</cfoutput> type="radio" value="1" /></td>
			<td class="messages"><input name="show_all" <cfoutput>#all_no#</cfoutput> type="radio" value="0"  /></td>
		</tr>
	</tbody>
</table>

</div>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- ----------------------------------------------------------------------------------------- --->
<!--- product related messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="group_name">
	Products
</div>

<div class="group_content">

<table class="messages">
	<col class="messages_label">
	<col class="messages_data">
	<thead>
		<tr>
			<td class="messages_titles">&nbsp;</td>
			<td class="messages_titles">Yes</td>
			<td class="messages_titles">No</td>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="messages">Display product related messages?</td>

			<cfif get_settings.products EQ 1>
				<cfset products_yes = "checked=checked">
				<cfset products_no = "">
			<cfelse>
				<cfset products_yes = "">
				<cfset products_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="products" <cfoutput>#products_yes#</cfoutput> type="radio" value="1" checked="checked" /></td>
			<td class="messages"><input name="products" <cfoutput>#products_no#</cfoutput> type="radio" value="0" /></td>
		</tr>
		<tr id="products1">
			<td class="messages indent">
				Inform when a new item/product has been added?
				<br/>
				Inform the users for how long?&nbsp;
				<input size="2" type="text" name="products_new_item_display" value="<cfoutput>#get_settings.products_new_item_display#</cfoutput>" maxlength="3"> days.

			</td>

			<cfif get_settings.products_new_item EQ 1>
				<cfset products_new_item_yes = "checked=checked">
				<cfset products_new_item_no = "">
			<cfelse>
				<cfset products_new_item_yes = "">
				<cfset products_new_item_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="products_new_item" <cfoutput>#products_new_item_yes#</cfoutput> type="radio" value="1" checked="checked" /></td>
			<td class="messages"><input name="products_new_item" <cfoutput>#products_new_item_no#</cfoutput> type="radio" value="0" /></td>
		</tr>


	</tbody>
</table>

</div>

<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- program related messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="group_name">
	Programs
</div>

<div class="group_content">

<table class="messages">
	<col class="messages_label">
	<col class="messages_data">
	<thead>
		<tr>
			<td class="messages_titles">&nbsp;</td>
			<td class="messages_titles">Yes</td>
			<td class="messages_titles">No</td>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="messages">Display program messages?</td>

			<cfif get_settings.programs EQ 1>
				<cfset programs_yes = "checked=checked">
				<cfset programs_no = "">
			<cfelse>
				<cfset programs_yes = "">
				<cfset programs_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="programs" <cfoutput>#programs_yes#</cfoutput> type="radio" value="1" onClick="programs_on();" /></td>
			<td class="messages"><input name="programs" <cfoutput>#programs_no#</cfoutput> type="radio" value="0" onClick="programs_off();" /></td>
		</tr>
		<tr id="programs1">
			<td class="messages indent">
				Inform that a program has been in RFA status to long?
				<br/>
				For more than
				<input name="programs_too_long_rfa_value" type="text" value="<cfoutput>#get_settings.programs_too_long_rfa_value#</cfoutput>" size="1" maxlength="3" /> days
				<br/>
				Inform the users for how long?&nbsp;
				<input size="2" type="text" name="programs_too_long_rfa_display" value="<cfoutput>#get_settings.programs_too_long_rfa_display#</cfoutput>" maxlength="3" /> days.
			</td>

			<cfif get_settings.programs_too_long_rfa EQ 1>
				<cfset programs_too_long_rfa_yes = "checked=checked">
				<cfset programs_too_long_rfa_no = "">
			<cfelse>
				<cfset programs_too_long_rfa_yes = "">
				<cfset programs_too_long_rfa_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="programs_too_long" <cfoutput>#programs_too_long_rfa_yes#</cfoutput> type="radio" value="1" /></td>
			<td class="messages"><input name="programs_too_long" <cfoutput>#programs_too_long_rfa_no#</cfoutput> type="radio" value="0" /></td>
		</tr>

		<tr id="programs3">
			<td class="messages indent">
				Inform that a program is backdated?
				<br/>
				For more than
				<input name="programs_backdated_value" type="text" value="<cfoutput>#get_settings.programs_backdated_value#</cfoutput>" size="1" maxlength="3" /> days
				<br/>
				Inform the users for how long?&nbsp;
				<input size="2" type="text" name="programs_backdated_value_display" value="<cfoutput>#get_settings.programs_backdated_value_display#</cfoutput>" maxlength="3"> days.
			</td>

			<cfif get_settings.programs_backdated EQ 1>
				<cfset programs_backdated_yes = "checked=checked">
				<cfset programs_backdated_no = "">
			<cfelse>
				<cfset programs_backdated_yes = "">
				<cfset programs_backdated_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="programs_backdated" <cfoutput>#programs_backdated_yes#</cfoutput> type="radio" value="1" /></td>
			<td class="messages"><input name="programs_backdated" <cfoutput>#programs_backdated_no#</cfoutput> type="radio" value="0" /></td>
		</tr>
		<tr id="programs4">
			<td class="messages indent">
				Inform that a program  has been reassigned to someone else?
				<br/>
				Inform the users for how long?&nbsp;
				<input size="2" type="text" name="programs_reassigned_display" value="<cfoutput>#get_settings.programs_reassigned_display#</cfoutput>" maxlength="3"> days.
			</td>

			<cfif get_settings.programs_reassigned EQ 1>
				<cfset programs_reassigned_yes = "checked=checked">
				<cfset programs_reassigned_no = "">
			<cfelse>
				<cfset programs_reassigned_yes = "">
				<cfset programs_reassigned_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="programs_reassigned" <cfoutput>#programs_reassigned_yes#</cfoutput> type="radio" value="1" checkegrogroup_name/td>
			<td class="messages"><input name="programs_reassigned" <cfoutput>#programs_reassigned_no#</cfoutput> type="radio" value="0" /></td>
		</tr>
	</tbody>
</table>


</div>


<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- customer related messages --->
<!--- ----------------------------------------------------------------------------------------- --->
<div class="group_name">
	Customers
</div>

<div class="group_content">

<table class="messages">
	<col class="messages_label">
	<col class="messages_data">
	<thead>
		<tr>
			<td class="messages_titles">&nbsp;</td>
			<td class="messages_titles">Yes</td>
			<td class="messages_titles">No</td>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="messages">Display Customer related messages?</td>

			<cfif get_settings.customers EQ 1>
				<cfset customers_yes = "checked=checked">
				<cfset customers_no = "">
			<cfelse>
				<cfset customers_yes = "">
				<cfset customers_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="customers" <cfoutput>#customers_yes#</cfoutput> type="radio" value="1" checked="checked" onClick="customers_on();" /></td>
			<td class="messages"><input name="customers" <cfoutput>#customers_no#</cfoutput> type="radio" value="0" onClick="customers_off();" /></td>
		</tr>
		<tr id="customers1">
			<td class="messages indent">
				Inform when a customer becomes inactive?
				<br/>
				Inform the users for how long?&nbsp;<input size="2" type="text" name="customers_inactive_display" value="<cfoutput>#get_settings.customers_inactive_display#</cfoutput>" maxlength="3"> days.
			</td>

			<cfif get_settings.customers_inactive EQ 1>
				<cfset customers_inactive_yes = "checked=checked">
				<cfset customers_inactive_no = "">
			<cfelse>
				<cfset customers_inactive_yes = "">
				<cfset customers_inactive_no = "checked=checked">
			</cfif>

			<td class="messages"><input name="customers_inactive" <cfoutput>#customers_inactive_yes#</cfoutput> type="radio" value="1"grougroup_named" /></td>
			<td class="messages"><input name="customers_inactive" <cfoutput>#customers_inactive_no#</cfoutput> type="radio" value="0" /></td>
		</tr>
	</tbody>
</table>

</div>


<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- admin related messages --->
<!--- ----------------------------------------------------------------------------------------- --->





<!--- get the messages saved in the db --->

<cfset useLakebaseForget_admin_msgs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("msg_ctr_admin_msgs")>
<cfif useLakebaseForget_admin_msgs>
	<cftry>
		<cfset get_admin_msgs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("msg_ctr_admin_msgs", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_admin_msgs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_admin_msgs>
<cfquery name="get_admin_msgs" datasource="#db_connection#">
	 Select * from msg_ctr_admin_msgs
</cfquery>
</cfif>





<div class="group_name">
	Administrator Messages

	<a style="font-size:11px; font-weight:bold; padding:0px 0px 5px 20px;" href="javascript:void(0);" onclick="PopupCenter('index.cfm?id=80905-48412-88691-85983&msgid=0', 'myPop1',640,480);">[ create a new message ]</a>

</div>




<div class="group_content">

<!--- styles used by the message display block --->
<style>

	td.heading
	{
		padding:			10px;
		font-size:			13px;
		font-weight:		bold;
		border-bottom:		2px #555555 solid;
	}

	td.data
	{
		padding:			10px;
		font-size:			12px;
		font-weight:		normal;
		border-bottom:		1px #cccccc solid;
	}

	tr.messages:nth-child(even)
	{
		background: #dddddd;
		padding:10px;
	}

	tr.messages:nth-child(odd)
	{
		background: #eeeeee;
		padding:10px;
	}

</style>

<!--- if there are no messages saved, say so and stop ... otherwise keep going --->
<cfif get_admin_msgs.recordCount EQ 0>
	<br/><br/>
	&nbsp;&nbsp;
	No administration messages.
	<br/><br/><br/>
</cfif>

<cfparam  name = "count" default = #get_admin_msgs.recordCount#>



<cfif get_admin_msgs.recordCount GT 0>

<table style="border-collapse:collapse; width:100%;" class="messages">

	<col span="1" style="width:75%; padding:10px;">
	<col span="1" style="width:15%; padding:10px;">
	<col span="1" style="width:10%; padding:10px;">

	<tr>
		<td class="heading">Message text</td>
		<td class="heading">Msg. Display Period</td>
		<td class="heading">Action</td>
	</tr>

<cfloop query="get_admin_msgs">

	<tr class="messages">
		<td class="data" style="vertical-align:middle;"><cfoutput>#msg_ctr_admin_txt#</cfoutput></td>
		<td class="data" style="vertical-align:middle;"><cfoutput>#dateformat(msg_ctr_start_date, "mm/dd/yy")#</cfoutput>&nbsp;&nbsp;-&nbsp;&nbsp;<cfoutput>#dateformat(msg_ctr_end_date, "mm/dd/yy")#</cfoutput></td>
		<td class="data" style="vertical-align:middle;">

			<a style="font-size:11px; font-weight:bold;" href="javascript:void(0);" onclick="PopupCenter('index.cfm?id=80905-48412-88691-85983&msgid=<cfoutput>#msg_ctr_admin_id#</cfoutput>', 'myPop1',640,480);"><img src="images/file_edit.png" alt="edit this message" title="edit this message"></a>
			&nbsp;&nbsp;
			<a style="font-size:11px; font-weight:bold;" href="javascript:PopupCenter('index.cfm?id=18573-15912-55267-38595&msgid=<cfoutput>#msg_ctr_admin_id#</cfoutput>&actid=666', 'myPop1',640,480);" onclick="return confirm('Are you sure you want to delete this message?');"><img src="images/file_delete.png" alt="delete this message" title="delete this message"></a></td>
	</tr>
</cfloop>

</table>

</cfif>

</div>


<tr bgcolor="###iif(SCOPE.currentrow MOD 2,DE('efefef'), DE('999999'))#">


<!--- ----------------------------------------------------------------------------------------- --->

<div class="group_content">
<table class="messages">
	<tr>
		<td style="text-align:left; padding:10px 0px 10px 20px;"><input name="submit_name" type="submit" value="Save These Settings" /></td>
		<td style="text-align:right; padding:10px 20px 10px 0px;"><input name="button_name" type="button" value="Review message log" onClick="location.href='/messagecenter/index.cfm?id=94451-84537-17189-37328'" /></td>
	</tr>
</table>
</div>

</form>






