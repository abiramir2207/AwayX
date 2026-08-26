<!-----
		Name: 			bb_closing_methods.cfm
               			Copyright (c) 2011 Blacksmith Applications, Inc.
		Created:
						07/18/2011
						Dinesh Rachala
		Last Modified:
						07/18/2011
						Dinesh Rachala
		Description:
                       This page allows administrators to view and edit the list of BillBack Closing Methods each profile can approve
					   Will be called from inside the profile settings section.
		Parameters:
                       profileId - ID of the the current profile that is getting edited
		Usage:
                       bb_closing_methods.cfm?profileId=6
----->
<cfparam name="url.profileId" 	default="">
<cfif NOT isNumeric(url.profileId) OR url.profileId EQ 0>
	<cfabort>
</cfif>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)>


<cfquery name="qBbclosingMethods" datasource="#application.datasource#">
SELECT     BCM.iBillback_Closing_Method_ID, BCM.vchBillback_Closing_Method_Desc, BPCM.Billback_Closing_Method_ID
FROM       Billback_Closing_Methods  AS BCM
           LEFT JOIN
           BB_Profile_Closing_Methods AS BPCM
           ON BCM.iBillback_Closing_Method_ID = BPCM.Billback_Closing_Method_ID
           AND BPCM.Profile_ID = #trim(url.profileId)#
		   AND BPCM.Deleted = 0
WHERE      BCM.Deleted = 0
           AND BCM.bEnabled = 1
</cfquery>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput><title>Closing Methods List for #sProfileName#</title></cfoutput>
</head>

<body>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script>
 checked=false;
function checkAll (BCM) {
	var fields= document.getElementById('BCM');
	 if (checked == false)
          {
           checked = true
          }
        else
          {
          checked = false
          }
	for (var i =0; i < fields.elements.length; i++)
	{
	fields.elements[i].checked = checked;
	}
      }
</script>

<font COLOR="Navy" SIZE="+1">
<cfoutput>Closing Methods List for #sProfileName#</cfoutput>
</font>
<HR COLOR="orange">
                <div align="center" style="font-size12px;font-weight: bold; color: blue; border:none;background-color:white;">
				<span style="color:red;">[</span>&nbsp;Select / UN select All<input type='checkbox' name='checkall' onclick='checkAll(BCM);'>&nbsp;<span style="color:red;">]</span>
				</div>
				<form method="post" name="frmBillBackClosingMethod" action="bb_closing_methods_action.cfm" id="BCM">
				<table align="center" cellpadding="3" cellspacing="1" bgcolor="c0c0c0" border="0">
				<thead bgcolor="c0c0c0">
				<td align="left" width="200"><B>Template</B></td>
				<td align="left"><B>Approve</B></td>
				</thead>
				<cfset i = 1>
				<cfoutput query="qBbclosingMethods">
				<tr bgcolor="FFFFFF">
				<td><strong>#vchBillback_Closing_Method_Desc#</strong></td>
				<td><input type="checkbox" value="#iBillback_Closing_Method_ID#" name="BillBackClosingMethodList#i#"<cfif #len(Billback_Closing_Method_ID)# NEQ 0>CHECKED</cfif>>&nbsp;</td>
				</tr>
				<cfset i = i + 1>
				</cfoutput>

				<cfoutput>
				<input type="hidden" name="count" value="#qBbclosingMethods.RecordCount#">
				<input type="Hidden" name="profileId" value="#url.profileId#" />
				</cfoutput>
				</table>
				<br>
				<div align="center">
				<span style="color:red;">[</span>
				<input type="submit" name="Submit" value="Save" style="font-size12px;font-weight: bold; color: blue; border:none;background-color:white;">
				<span style="color:red;">]</span>
				</div>
				</form>



</body>
</html>
