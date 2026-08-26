<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" >
<CFSET PAGETITLE = "#application.returned_customer_setting.zone_label_singular#/#application.returned_customer_setting.region_label_singular#/#application.returned_customer_setting.market_label_singular# Setup">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "USERS: USER POSITIONS">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<cfset useLakebaseForlasteditedby = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("zone_region_market_last_edited_by")>
<cfif useLakebaseForlasteditedby>
	<cftry>
		<cfset lasteditedby = application.oLakebase.toQuery(
			application.oLakebase.selectRows("zone_region_market_last_edited_by", {
				"order" = "last_updated.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlasteditedby = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlasteditedby>
<CFQUERY NAME="lasteditedby" datasource="#application.datasource#" MAXROWS="1">
SELECT *
FROM Zone_Region_Market_Last_Edited_By
ORDER BY Last_Updated desc
</CFQUERY>
</cfif>
<!---Help Files--->
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Administration/Positions/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>
<p></p>
<!---Help Files--->

<CFIF lasteditedby.recordcount EQ 0>
<CFELSE>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#lasteditedby.Users_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT *
		FROM _Users
		WHERE User_ID = '#lasteditedby.Users_ID#'
	</CFQUERY>
</cfif>

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated By &nbsp;<CFOUTPUT>#getUserName.Name_First# #getUserName.Name_Last#</CFOUTPUT> on <CFOUTPUT>#dateformat(lasteditedby.Last_Updated, 'm/d/yyy')# 
	#timeformat(lasteditedby.Last_Updated, 'h:mm:ss TT')#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
</CFIF>


<BR><BR>

<table STYLE="display: none;" border=0><tr><td><font size=-2><a style="font-size:7pt;text-decoration:none;color:silver" href=http://www.treeview.net/treemenu/userhelp.asp target=_top>Tree Menu Help</a></font></td></table>

<script src="\common_files\scripts\treemenu\ua.js"></script>
<script src="\common_files\scripts\treemenu\ftiens4.js"></script>
<script>
	<CFINCLUDE TEMPLATE="\common_files\scripts\treemenu\defineMyTree2.cfm">
</script>




<script>
		function relocate(URLstring){
			if(URLstring != 0){
				this.location.href=URLstring
			}
			
		}
</script>


<script>initializeDocument()</script>
	

</body>
</html>
