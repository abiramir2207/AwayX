<cfset getDistributor_Trade=caller.srQuery>
<cfset colStarted=false>
<cfoutput query="getDistributor_Trade" startrow="#caller.Item_Dist_Start_Row#" group="Contract_Number">
	<cfif (getDistributor_Trade.Item NEQ caller.thisItem) OR (getDistributor_Trade.Contract_Number NEQ caller.thisContract_Number)>
		<cfif colStarted></table></td></tr></cfif>
		<cfset colStarted=false>
		<cfexit>
	</cfif>
<cfset pTypeCount=0>
<cfoutput group="Product_Type_ID">
<cfset pTypeCount=pTypeCount+1>
<cfif pTypeCount GT 1><cfif colStarted></table></td></tr></cfif>
		<cfset colStarted=false>
		<cfexit></cfif>
<cfoutput group="ship_to">
	<cfif (getDistributor_Trade.Item NEQ caller.thisItem)>
		<cfif colStarted></table></td></tr></cfif>
		<cfset colStarted=false>
		<cfexit>
	</cfif>
<cfif getDistributor_Trade.ship_to NEQ "">
<cfif NOT colStarted>	
		<cfset colStarted = true>
		<cfif caller.rReportOutputType EQ "h"><cfset c1="2"><cfelse><cfset c1="5"></cfif>
		<tr bgcolor="FFFFFF"><td colspan="#c1#"></td><td colspan="#Evaluate("#caller.totalColumns#-#c1#")#"><table align="right" border="1" CELLPADDING="0" CELLSPACING="0"><colgroup><col width="100"></col><col width="250"></col><col width="100" span="2"></col><col width="120"></col></colgroup><thead><tr bgcolor="B0C4DE" ALIGN=CENTER><td>#application.returned_customer_setting.shard_ship_to_label#</td><td>Name</td><td>Rate</td><td>Program Weight</td><td>WTPR</td></tr></thead></cfif>
		<tr valign="top"><td>&nbsp;#getDistributor_Trade.Ship_To#</td><td>#getDistributor_Trade.Name#</td><td>&nbsp;#numberformat(getDistributor_Trade.Rate,'$(___,___,___,___,___.___')#</td><td>&nbsp;#getDistributor_Trade.Program_Weight#%</td><td>&nbsp;#numberformat(getDistributor_Trade.WTPR,'$(___,___,___,___,___.___')#</td></tr>
</cfif>
</cfoutput>
</cfoutput>
</cfoutput>
<cfif colStarted></table></td></tr></cfif>
<cfset colStarted=false>