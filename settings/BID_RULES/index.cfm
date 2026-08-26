<cfif FileExists("#apppath#\settings\bid_rules\rulesarelocked")>
	<!--- <cffile action="READ" file="#apppath#\settings\bid_rules\rulesarelocked" variable="filecontents">
	--->
		<cffile action="READ" file="#Application.Doc_Path#\data_files\created\settings\bid_rules\rulesarelocked" variable="filecontents">
	<cfset tempArray = listtoarray(filecontents, ",")>
	<cfif tempArray[1] EQ request.AccessStructure.user_id>
		<cffile action="DELETE" file="#apppath#\settings\bid_rules\rulesarelocked">
	</cfif>
</cfif>

<cfparam name="URL.TID" default="0">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
	<script SRC="/common_files/scripts/wholeNumberValidation.js"></script>
	<script>
		var pwinretval = 0;
		function popupWindow(ID, Action) {
			
			<cfif FileExists("#apppath#\settings\bid_rules\rulesarelocked")>
				alert("While Bid Rules are locked by another user, they are inaccessible to anyone but that user.")
			<cfelse>
				dataArray = new Array(1);
				dataArray[0] = ID;
				dataArray[1] = Action;
				
				/*
				action:
					1=new
					2=edit
					3=summary
				*/
				pwinretval = window.showModalDialog("popupWindow.cfm",dataArray,"dialogHeight: 700px; dialogWidth: 800px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: Yes; status: No; scroll: Yes;");
				if(pwinretval == 1) window.location.href = window.location.href;
				pwinretval = 0;
			</cfif>
			
		}
		
		function deleteRule(ruleid) {
			if(confirm("Press OK to delete this rule")) {
				window.location.href="delete_rule.cfm?ID=" + ruleid
			}
		}
		
		function filterRules(oSel) {
			this.window.location.href = "index.cfm?TID=" + oSel.value
		}
	</script>

</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET pagetitle = url.PageTitle> --->
<CFSET pagetitle = "Manage Bid Rules">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery name="getRules" datasource="#application.datasource#">
	SELECT *
	FROM Bid_Rules
	WHERE Deleted = 0

	<CFIF URL.TID NEQ 0>
	AND Bid_Rule_ID = (SELECT DISTINCT Bid_Rule_ID
						FROM Bid_Rule_Items	
						WHERE Type_Item_ID = '#URL.TID#'
						AND Deleted = 0)</CFIF>	

	ORDER BY Bid_Rule_Name
</cfquery>
<!--- <cfdump var="#getRules#"> --->

<!--- RULES ARE LOCKED  --->
<cfif FileExists("#apppath#\settings\bid_rules\rulesarelocked")>
	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#tempArray[1]#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<cfquery name="getUserName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last
		FROM _USERS
		WHERE User_ID = '#tempArray[1]#'
	</cfquery>
</cfif>
	<div align="center" style="color: red; font-weight:bold; font-size: 14px;">Bid Rules are currently locked by: <cfoutput>#getUserName.Name_First# #getUserName.Name_Last#</cfoutput></div>
</cfif>

<cfif application.returned_customer_setting.APPROVAL_ON_TYPE_CODE EQ 1>
	<CFSET dropDownString = "Type Codes">
<cfelse>
	<CFSET dropDownString = "Type Groups">
</cfif>

<CFQUERY NAME="getTypes" DATASOURCE="#application.datasource#">
	SELECT #application.returned_customer_setting.APPROVAL_CRITERIA_TABLE_ID# AS ID, #application.returned_customer_setting.APPROVAL_CRITERIA_TABLE# AS Description
	FROM #application.returned_customer_setting.APPROVAL_CRITERIA_TABLE#
	ORDER BY Description
</CFQUERY>


<!--- <cfdump VAR="#application.returned_customer_setting#"> --->
<TABLE WIDTH="99%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
	<tr>
		<TD>Show rules with:
			<cfoutput>
			<SELECT onchange="filterRules(this)">
				<option value="0">All #dropDownString#</option>
				<cfloop query="getTypes">
					<option <cfif URL.TID EQ getTypes.ID> SELECTED </cfif> value="#getTypes.ID#">#getTypes.Description#</option>
				</cfloop>
			</SELECT>
			</cfoutput>
		</TD>
		<td align="right"><font color="red" style="font-size: 15px;">[</font><a style="font-size: 15px;" onclick="popupWindow(0,0)"><b style="cursor: pointer;">create new rule</b></a><font color="red" style="font-size: 15px;">]</b></td>
	</tr>
</table>
<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header"><b>Rule Name</b></TD>
		<TD ID="header"><b>Rule Description</b></TD>
		<TD ID="header"><b>Last Modified</b></TD>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</TR>
<cfoutput>
<cfloop query="getRules">
	<CFSET LastModName = "Not Available">
	
	<cfif len(trim(getRules.Last_Mod_Usr_ID)) GT 0>
		<cfquery name="getLastModData" datasource="#application.datasource#">
			SELECT Name_First, Name_Last
			FROM _Users
			WHERE User_ID = '#getRules.Last_Mod_Usr_ID#'
		</cfquery>
		<cfif getLastModData.recordcount GT 0>
			<cfset LastModName = getLastModData.Name_First & " " & getLastModData.Name_Last & " On " & DateFormat(getRules.Last_Mod_Date, 'm/d/yyyy') & " @ " & TimeFormat(getRules.Last_Mod_Date, 'h:m tt')>
		</cfif>
	</cfif>
	
	

	<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
		<TD width="">#BID_RULE_NAME#</TD>
		<TD width="">#BID_RULE_DESC#</TD>
		<TD width="">#LastModName#</TD>
		<TD>&nbsp;</TD>
		<td align="right"><font color="red">[</font><a style="cursor: pointer;" onclick="popupWindow('#getRules.Bid_Rule_ID#',2)">edit</a><font color="red">]&nbsp;<font color="red">[</font><a href="javascript: deleteRule('#getRules.Bid_Rule_ID#')">delete</a><font color="red">]</font>&nbsp;<font color="red">[</font><a onclick="popupWindow('#getRules.Bid_Rule_ID#',3)" style="cursor: hand;">view summary</a><font color="red">]</font></td>
	</TR>
</cfloop>
</cfoutput>
<cfif getRules.recordcount EQ 0>
	<tr>
		<td colspan="100%" align="center">
			<span class="colr: red; font-size: 15px; font-weight: bold;">No Rules Are Defined</span>
		</td>
	</tr>
</cfif>
</table>

</BODY>
</HTML>



