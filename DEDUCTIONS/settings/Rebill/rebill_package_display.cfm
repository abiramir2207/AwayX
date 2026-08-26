<!-----------------------------------------------------------------------------

FILE NAME:		rebill_package_display.cfm
DESCRIPTION:	Display page for all the rebill packages
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	09-Apr-10 Created 
------------------------------------------------------------------------------> 
<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags"> 

<table width="60%" border="0" cellpadding="1" cellspacing="0">
	<tr>
		<cfif qgetrebillpackage.recordcount gt 0>
			<td align="left" width="130" nowrap>
			<cfif form.display eq "inActive">
			<b><font color="FF0000">[</font><a href="#" onClick="javaScript: return activateSelPackages();">
			activate selected</a>
			<cfelse>
			<b><font color="FF0000">[</font><a href="" onClick="javaScript: return deactivateSelPackages();">
			deactivate selected</a>
			</b></b></cfif><b><b>
			<font color="FF0000">]</font></b>
			</b></td>
		</cfif>
		<td width="">&nbsp;</td>
	</tr>
</table>
<br>
<table width="90%" border="0" cellpadding="1" cellspacing="0" class="MAINTABLE">
	<!---- HEAD ----->
	<tr id="HEADER" bgcolor="#FFCE84">
		<td width="10">
			<input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this);">
		</td>
		<td style="font-size:11px;" width="100">
			<b>Title</b>
		</td>
    <td style="font-size:11px;" width="150">
			<b>Rebill Message</b>
		</td>
    <td style="font-size:11px;">
			<b>Default Message</b>
		</td>    
    <td style="font-size:11px;" width="100">
			<b>Defaults</b>
		</td>    
		<td width="65" style="font-size:11px;"><b>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</b></td>
		<td width="50" style="font-size:11px;"><b>Delete</b></td>
	</tr>
	
	<cfoutput query="qGetRebillPackage">
		<!---check to see if we can delete this Package --->
		<cfscript>
			bCanDelete = rebillPackage.canDelete(qGetRebillPackage.DD_Rebill_Package_Hdr_ID);
		</cfscript>
	
	<tr <cfif currentrow mod 2>BGCOLOR="CCFFCC"</cfif> HEIGHT="21">
		<td width="10"><input type="checkbox" name="CID" value="#DD_Rebill_Package_Hdr_ID#"></td>
		<td>
			<a href="" onClick="JavaScript: return submitDataForm2('edit','#DD_Rebill_Package_Hdr_ID#');" title="#Rebill_Package_Title#">#Left(Rebill_Package_Title,30)#</a>
		</td>		
    <td>
			<span title="#Rebill_Package_Msg#">#Left(Rebill_Package_Msg,30)#...</span>
		</td>	
    <td> 
      <cfif (Default_Message EQ 1)>
        ON
      <cfelseif (Default_Message EQ 0)> 
        OFF
      </cfif>
    </td>
    <td>
        <cfset useLakebaseForqryGetRebillPackageDtl = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_rebill_package_dtl") AND application.oLakebase.isTableMigrated("dd_reason_code") AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForqryGetRebillPackageDtl>
	<cftry>
		<cfset qryGetRebillPackageDtl = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin2("dd_rebill_package_dtl", {
				"deleted" = "eq.0",
				"dd_rebill_package_hdr_id" = "eq.#qGetRebillPackage.DD_Rebill_Package_Hdr_ID#",
				"select" = "created_date,dd_classification_id,dd_reason_code_id,dd_rebill_package_dtl_id,deleted,is_default"
			}, "dd_reason_code_id", "dd_reason_code", "dd_reason_code_id", "dd_reason_code", "dd_classification_id", "dd_classification", "dd_classification_id", "dd_classification_desc"), "created_date,dd_classification_id,dd_reason_code_id,dd_rebill_package_dtl_id,deleted,is_default,dd_reason_code,dd_classification_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetRebillPackageDtl = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetRebillPackageDtl>
<cfquery name="qryGetRebillPackageDtl" datasource="#Application.Datasource#">
          SELECT 
              DDRPD.DD_Rebill_Package_Dtl_ID,
              DDRPD.DD_Reason_Code_ID,
              DDRPD.DD_Classification_ID,
              DDRPD.Is_Default,
              DDRPD.Created_Date,
              DDRPD.Deleted,
              DRC.DD_Reason_Code,
              DDC.DD_Classification_Desc
          FROM
              DD_Rebill_Package_Dtl DDRPD
              LEFT JOIN DD_Reason_Code DRC ON DRC.DD_Reason_Code_ID = DDRPD.DD_Reason_Code_ID
              LEFT JOIN DD_Classification DDC ON DDC.DD_Classification_ID = DDRPD.DD_Classification_ID
          WHERE DDRPD.Deleted = 0 AND DDRPD.DD_Rebill_Package_Hdr_ID = #qGetRebillPackage.DD_Rebill_Package_Hdr_ID#
        </cfquery>
</cfif>
        <cfloop query ="qryGetRebillPackageDtl">
          <cfif qryGetRebillPackageDtl.Is_Default EQ 1 AND qryGetRebillPackageDtl.DD_Reason_Code_ID NEQ "">
          <strong>RC :</strong>#qryGetRebillPackageDtl.DD_Reason_Code#<br>
          </cfif>
          <cfif (appSettings.getDD_Show_Classification() EQ 1)>
            <cfif qryGetRebillPackageDtl.Is_Default EQ 1 AND qryGetRebillPackageDtl.DD_Classification_Desc NEQ "">
            <strong>CL :</strong> #qryGetRebillPackageDtl.DD_Classification_Desc#
            </cfif>
          </cfif>
        </cfloop>  
    </td>
    
		<cfif form.display eq "active">
			<td title="Deactivate #Rebill_Package_Title#" align="center"><a href="" onClick="JavaScript: return deactivatePackage('#DD_Rebill_Package_Hdr_ID#');"><img src="/images/not_allowed.gif" title="Deactivate #Rebill_Package_Title#" border="0"></a></td>
		<cfelse>
			<td title="Activate #Rebill_Package_Title#" align="center"><a href="" onClick="JavaScript: return activatePackage('#DD_Rebill_Package_Hdr_ID#');"><img src="/images/on_the_program_item.gif" title="Activate #Rebill_Package_Title#" border="0"></a></td>
		</cfif>
		
		
		<cfif bCanDelete>
			<td title="Delete #Rebill_Package_Title#" align="center"><a href="" onClick="JavaScript: return deletePackage('#DD_Rebill_Package_Hdr_ID#');"><img src="/images/no_small.gif" title="Delete #Rebill_Package_Title#" border="0"></a></td>
		<cfelse>
			<td align="center">&nbsp;<font color="Red">N/A</font></td>
		</cfif>	
	</tr>	
	</cfoutput>
</table>

