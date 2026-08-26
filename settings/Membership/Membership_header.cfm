<!----
	Name: index.cfm 
	Created By:   Dinesh Rachala :: 03/04/2013     
	Copyright (c) 2013 Blacksmith Applications, Inc.       
 	Description:
	Usage: Used to navigate between Family/Buying Group/
---->

<cfset TR_BORDER_WIDTH = 2>
<cfset TD_FORE_COLOR = "FFE083">
<cfset TD_FORE_COLORTOP = "FFC46B">

<!---  TO DISPLAY THE TABS FOR PRODUCT, CUSTOMER,  OPERATOR THESE BELOW SWITCHES SHOULD BE ON --->
<cfset PageLevelSetting_Customer = 1/>
<cfset PageLevelSetting_Product = 1/>
<cfset PageLevelSetting_Operator = 1/>

<style type="text/css">
	a,a:visited{
			color:black;
	}
	.headernotselectedtop
	{
			background-color 	: #cfcfcf;
			border-bottom		: solid 2px #636363;
			cursor				: pointer;
	}
	.headerselectedtop
	{
			border-left			: solid 2px #636363;
			border-top			: solid 2px #636363;
			border-right			: solid 2px #636363;
			background-color 	: #ffc46b;
			cursor				: pointer;
			text-transform		: uppercase;
	}
	.headerspacertop
	{
 		border-bottom		: solid 2px #636363;
	}
</style>


<cfparam name="membership_page_name" default=1>
<cfset membership_page_titles = "">
<cfset membership_page_actions = "">

<cfset membership_page_titles = listappend(membership_page_titles, "buying group", ",")>
<cfset membership_page_actions = listappend(membership_page_actions, "1", ",")>

<cfset membership_page_titles = listappend(membership_page_titles, "#application.returned_customer_setting.family_name_label_singular#", ",")>
<cfset membership_page_actions = listappend(membership_page_actions, "2", ",")>

<cfif url.display_type eq "1">
  <cfset membership_page_name = 1 />
<cfelseif url.display_type eq "2">
	<cfset membership_page_name = 2 />
</cfif>

<CFOUTPUT>
		<table border="0" cellspacing="0" cellpadding="1" width="100%">
				<tr>
						<cfset p_counter = 1>
						<cfloop list="#membership_page_titles#" index="thistoptabitem">
						
									<cfif p_counter eq membership_page_name>
											<cfset class_name= "headerselectedtop">
									<cfelse>
											<cfset class_name= "headernotselectedtop">
									</cfif>
									
								<td width="140" class="#class_name#" align="center" nowrap>
										<a  class="tablink_backtop"  href="#ajaxlink('#cgi.script_name#?display_type=#listgetat(membership_page_actions, p_counter)#')#"><b>#thistoptabitem#</b></a>
								</td>
								<td class="headerspacertop">
										<img src="/images/fill.gif" width="1" height="1">
								</td>
								<cfset p_counter = p_counter + 1>
						
						</cfloop>
						<td class="headerspacertop" width="100%"><img src="/images/fill.gif" width="1" height="1"></td>						
				</tr>
		</table>
</CFOUTPUT>