<!----
	name: membership_edit.cfm         
	copyright (c) 2013 blacksmith applications, inc.       
	description:
		<brief description of what the file is used for>
	usage:
		<templates that depend on this file>
---->

<cfparam name="previousMemberId" 	default="0">
<cfparam name="check" 							default="1">
<cfparam name="url.action" 					default="">
<cfparam name="errors" 							default="">

<cfset membershipinfo = createobject("component", "components.settings.membership.customergroupmembership") /> 
<cfset membership = membershipinfo.membershipdetails(grouptype=#trim(url.grouptype)#, groupid=#trim(url.groupid)#, shiptoid=#trim(url.shiptoid)#, startdate=#trim(url.startdate)#)>
<cfset minstartdate = membershipinfo.minstartdate(shiptoid=#trim(url.shiptoid)#, startdate=#dateformat(url.startdate,'mm/dd/yyyy')#)>

<cfif len(url.action)>
	
<cfif len(form.startdate) EQ 0>
	<cfset errors ="Start date cannot be empty.">
</cfif>
<cfif len(form.startdate)  AND #trim(form.startdate)# LT #dateformat(minstartdate.min_allowed_date,'mm/dd/yyyy')#>
	<cfset errors ="Start date cannot be before &nbsp;"&	#dateformat(minstartdate.min_allowed_date,'mm/dd/yyyy')#>
</cfif>
<cfif len(form.startdate)  AND #trim(form.startdate)# GT #dateformat(membership.end_date, 'mm/dd/yyyy')#>
	<cfset errors ="Start date cannot be after &nbsp;"&	#dateformat(membership.end_date, 'mm/dd/yyyy')#>
</cfif>

		<cfif len(errors) EQ 0>
		<!---<cfset update = membershipinfo.updateMemeber(#form#)>
		<script>
			window.parent.TINY.box.hide();
		</script>--->
		</cfif>	
</cfif>
		
<cfinclude template="../advanced_budget/actionformat.cfm">

<cfif url.grouptype eq 1>
			<cfset group = "">
			<cfset shipto = "">
<cfelseif url.grouptype eq 2>
			<cfset group = #application.returned_customer_setting.family_name_label_singular#>
			<cfset shipto = #application.returned_customer_setting.shard_ship_to_label#>
</cfif>

<cfset customer_group_member_id =  #membership.customer_group_members_id#>

<cfset currentgroupid = #membership.group_guid#>
<cfset currentstartdate = #membership.start_date#>

<style type="text/css"> 
	.bold{
		font-weight: bold;
		font-size:12px;
		}
	.highlight{
		font-weight: 75;
		font-size:18px;
		}
	.unbold{
		font-size:12px;
		}
		.errors{
			width:98%;
			text-align:center;
			color:red;
			margin-bottom:-15px;
			font-size:14px;
		}
</style>


<cfoutput>
	<table width="99%" border=0 align="center">
		<tr>
			<td>
					<span class="bold">#shipto#</span>
					<span class="unbold">#membership.name#</span>
			</td>
			<td align="right">
				<span class="bold">#group#</span>
				<span class="unbold">#membership.group_desc#</span>
			</td>
		</tr>
	</table>
	
<div class="errors">#errors#</div>


<cfset actionpage="membership_edit.cfm?action=submit&shiptoid=#url.shiptoid#&startdate=#url.startdate#&grouptype=#url.grouptype#&groupid=#url.groupid#">
<form name="updatemember" action="#actionpage#" method="post">
	<cfparam name="form.startdate" default="#dateformat(membership.start_date, 'mm/dd/yyyy')#" >
	<table border="0" width="99%">
	<tr>
		<td width="75" class="bold">Start date:</td>
		<td width="150">
			<input type="text" name="startdate" value="#form.startdate#">
			<input type="hidden" name="startdatenomask" value="#membership.start_date#">
		</td>
		<td align="left">
			<span class="bold">Min start date:</span> #dateformat(minstartdate.min_allowed_date,'mm/dd/yyyy')#<br>
			<span class="bold">Max start date:</span> #dateformat(membership.end_date, 'mm/dd/yyyy')#
		</td>
	</tr>	
	<tr>
		<td class="bold">End date:</td>
		<td colspan="2">
			#dateformat(membership.end_date, 'mm/dd/yyyy')#
		</td>
	</tr>	
	<tr><td colspan="3" height="5px;">&nbsp;</td></tr>
	<tr>
		<td colspan="3" align="center">
			<a href="javascript: deleterecord();">#lcase(actiontext("delete this record"))#</a> 
			<a href="javascript: updaterecord();">#lcase(actiontext("update"))#</a>
		</td>
	</tr>
</table>		

<br>
<cfset shiptolist = membershipinfo.membershipdetails(grouptype=2,  shiptoid=#trim(url.shiptoid)#)>

	<table width="99%" align="center">
		<tr style="background-color:##ffc46b;height:20px;">
			<td><b>#group#</b></td>
			<td><b>start date</b></td>
			<td><b>end date</b></td>
		</tr>

	<cfloop query="shiptolist">
		<cfif (currentgroupid eq shiptolist.group_guid) and (currentstartdate eq shiptolist.start_date)>
				<tr style="background-color:gray;">
						<input type="hidden" name="previousMemberId" value="#previousMemberId#">
						<input type="hidden" name="updateEndDate" value="#trim(shiptolist.end_date)#">
						<!---<input type="hidden" name="previousStartDate" value="#previousStartDate#">--->
						<cfset check = 0>
		<cfelse>
				<tr>
		</cfif>
		<cfif check>
				<cfset previousMemberId = "#trim(shiptolist.customer_group_members_id)#">
				<!---<cfset previousStartDate = "#trim(start_date)#">--->
		</cfif>
			<td>#group_desc#//#customer_group_members_id#</td>
			<td>#dateformat(start_date, 'mm/dd/yyyy')#</td>
			<td>#dateformat(end_date, 'mm/dd/yyyy')#</td>
		</tr>
	</cfloop>

	</table>

	<input type="hidden" name="groupType" value="#trim(url.grouptype)#">
	<input type="hidden" name="update" value="0">
	<input type="hidden" name="remove" value="0">
	<input type="hidden" name="currentMemberId" value="#customer_group_member_id#">
</form>
</cfoutput>
<script>
	function deleterecord(){
		var okremove = confirm("Are you sure?");
			if(okremove == true){
				document.updatemember.remove.value= 1;
				document.updatemember.submit();
			}
	}
	function updaterecord(){
				document.updatemember.update.value= 1;
				document.updatemember.submit();
				//window.parent.TINY.box.hide();
	}
</script>
