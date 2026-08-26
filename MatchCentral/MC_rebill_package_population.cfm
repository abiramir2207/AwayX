
<cfsetting showdebugoutput="No">

 <!-----------------------------------------------------------------------------

FILE NAME:		MC_rebill_package_population.cfm
DESCRIPTION:	Rebill package DIV population page
CREATED BY:		Ana Shankar (D19384)
CREATED DATE: 04/12/2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
------------------------------------------------------------------------------> 
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<cfquery name="getAllRebillPackages" datasource="#application.datasource#">
	SELECT 		Rebill_Package_Msg, Default_Message	
	FROM 		DD_Rebill_Package_Hdr
	WHERE		DD_Rebill_Package_Hdr_ID = #rebillPakID# AND Active = 1 AND Deleted = 0
	ORDER BY 	Rebill_Package_Title
</cfquery>

<cfquery name="getAllRebillClass" datasource="#application.datasource#">	
SELECT		DD_Rebill_Package_Dtl.DD_Classification_ID,
			DD_Classification.DD_Classification_Desc,
			DD_Rebill_Package_Dtl.Is_Default 
FROM		DD_Rebill_Package_Dtl
INNER JOIN	DD_Classification ON DD_Rebill_Package_Dtl.DD_Rebill_Package_Hdr_ID = #rebillPakID# AND 
			DD_Classification.DD_Classification_ID = DD_Rebill_Package_Dtl.DD_Classification_ID AND
			DD_Classification.Deleted = 0 AND DD_Rebill_Package_Dtl.Deleted = 0
ORDER BY	DD_Classification.DD_Classification_Desc
</cfquery>

<cfquery name="getAllRebillReason" datasource="#application.datasource#">	
SELECT		DD_Rebill_Package_Dtl.DD_Reason_Code_ID,
			DD_Reason_Code.DD_Reason_Code,
			DD_Rebill_Package_Dtl.Is_Default 
FROM		DD_Rebill_Package_Dtl
INNER JOIN	DD_Reason_Code ON DD_Rebill_Package_Dtl.DD_Rebill_Package_Hdr_ID = #rebillPakID# AND 
			DD_Reason_Code.DD_Reason_Code_ID = DD_Rebill_Package_Dtl.DD_Reason_Code_ID AND
			DD_Reason_Code.Deleted = 0 AND DD_Rebill_Package_Dtl.Deleted = 0
ORDER BY	DD_Reason_Code.DD_Reason_Code
</cfquery>

<CFSET JustDDID = RIGHT(ddID,LEN(ddID)-3)>

<CFIF getAllRebillPackages.Default_Message EQ 1>
	<cfquery name="RebillPak_MsgBuilder" datasource="#application.datasource#">	
		SELECT dbo.UDF_DD_Rebill_Msg_Builder('#JustDDID#', #rebillPakID#, #balanceAmount#) default_Msg
	</cfquery>
</CFIF>

<cfscript>
	rebillPackage = CreateObject("component","components.Deduction.rebill.Rebill");
</cfscript>
<cfset rebillSettingsManager = rebillPackage.getRebillSettings() />
<cfset MaxLen = rebillSettingsManager.Rebill_Message_Size />

<CFSET MsgLen = 0>
<CFIF getAllRebillPackages.Default_Message EQ 1>
	<CFSET MsgLen = LEN(RebillPak_MsgBuilder.default_Msg) + 2>
</CFIF>
<CFSET AvailableChar = MaxLen - MsgLen>

<CFOUTPUT>
<table border="0" cellspacing="0" cellpadding="5" width="100%">
<CFIF getAllRebillPackages.Default_Message EQ 1>
	<input type="hidden" name="Default_Message_#suffixID#" id="Default_Message_#suffixID#" value="#RebillPak_MsgBuilder.default_Msg#">
	<TR>
		<TD COLSPAN="100%">Default Message:<BR>#RebillPak_MsgBuilder.default_Msg#</TD>
	</TR>
<CFELSE>
	<input type="hidden" name="Default_Message_#suffixID#" id="Default_Message_#suffixID#" value="">	
</CFIF>
<TR>
<TD width="60%">
<CFIF getAllRebillPackages.Default_Message EQ 1>Add-On<CFELSE>Rebill</CFIF> Message:
<CF_SCALABLETEXTAREA 
NAME="rebillMessage_#suffixID#" 
ID="rebillMessage_#suffixID#"
COLS="57" 
ROWS="5" 
onKeyUp="javaScript: lenCheck(this, '#suffixID#','#AvailableChar#');"
onkeyPress="javaScript: return textareaChecklength('#AvailableChar#', this);"
onPaste="javaScript: return textareaChecklength('#AvailableChar#', this);"
incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">"
></CF_SCALABLETEXTAREA>
<input type="text" name="Len_#suffixID#" id="Len_#suffixID#" value="#AvailableChar#" size = "5">
</TD>
<TD>
#stDeductionLabels["Rebill Classification"]#:<br />
<select name="RebillClassIDForSplit_#suffixID#"	id="RebillClassIDForSplit_#suffixID#">
		<option value=""></option>
		<cfloop query="getAllRebillClass">
		<option value="#DD_Classification_ID#" <cfif (Is_Default EQ 1)>selected</cfif>>#DD_Classification_Desc#</option>						
		</cfloop>
</select>
<div class="formError" id="ClassificationIDForSplit_#suffixID#_error" style="display:none;">
	Please select a #LCase(stDeductionLabels["Rebill Classification"])# for the split.
</div>
<BR><BR>
#stDeductionLabels["Rebill Reason Code"]#:<br />
	<select name="RebillRCForSplit_#suffixID#" id="RebillRCForSplit_#suffixID#">
		<option value=""></option>
		<cfloop query="getAllRebillReason">
		<option value="#DD_Reason_Code_ID#" <cfif (Is_Default EQ 1)>selected</cfif>>#DD_Reason_Code#</option>						
		</cfloop>
	</select>
	<div class="formError" id="ReasonCodeForSplit_#suffixID#_error" style="display:none;">
		Please select a #LCase(stDeductionLabels["Rebill Reason Code"])# for the split.
	</div>
</TD>
</TR>
</table>
</CFOUTPUT>
