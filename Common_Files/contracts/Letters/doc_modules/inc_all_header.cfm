<cfsilent>
<!--- 
FILE: 		
FILENAME: 	doc_modules/inc_all_header.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			10/29/2008 - RBL [D17386]

FUNCTIONALITY:
- This include template is utilized to display the top most "Header" module for all versionS of the Deal Letters v2...
The cfoutput tags ARE needed for this include.
--->

<!--- These parameters are required for this template to process correctly --->
<!--- na --->

<!--- <cfif findNoCase("HTTPS",cgi.server_protocol,1)> --->
<cfset variables.protocol = application.HTTPVar />

</cfsilent>
<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">
<cfoutput>
<!--- height="100" class="height_100" --->
  <table name="outer_table" width="100%" cellpadding="0" cellspacing="0" border="0">
      <!--- <tr>
        <td align="left" valign="bottom" colspan="2" height="50" width="100%" class="header_text">
          Price & Promotion Incentive Offer <!--- #thisTag.stPDFHeaderInfo.program_id# 
		  variables.protocol##cgi.http_host##thisTag.stPDFHeaderInfo.company_logo_path--->
        </td>
      </tr>
			rowspan="2" --->
      <tr>
        <td align="left" valign="middle" width="50%" class="header_text"><br /><h2><span class="redText">#thisTag.stPDFHeaderInfo.contract_number#</span> #thisTag.stPDFHeaderInfo.program_bid_request_status#</h2></td>
        <!--- "File:///" will not work here. "File:///" is for pdf only --->
        <td align="right" valign="top" width="50%" class="header_text"><img src="#thisTag.stPDFHeaderInfo.company_logo_path#" border="0"  height="50" /></td>
      </tr>
      <tr>
        <td align="left" valign="middle" width="50%">&nbsp;</td>
        <td align="right" valign="middle" width="50%">&nbsp;</td>
      </tr>
      <tr>
        <td align="left" valign="bottom" width="50%" class="header_text thinBottomBorder">
          <!--- ACTION: MAY DELETE <b>#uCase(thisTag.stPDFHeaderInfo.program_title)#<cfif isDefined("thisTag.consignee") AND len(trim(thisTag.consignee))> - #uCase(thisTag.consignee)#</cfif><cfif isDefined("thisTag.revised_doc_title") AND len(trim(thisTag.revised_doc_title))> - #thisTag.revised_doc_title#</cfif></b> --->
          <h3><!--- <cfif isDefined("thisTag.revised_doc_title") AND len(trim(thisTag.revised_doc_title))>#thisTag.revised_doc_title#<cfelse> --->#thisTag.stPDFHeaderInfo.program_title#<!--- </cfif> ---> #dateFormat(thisTag.stPDFIntroInfo.contract_start_date, "m/d/yy")# - #dateFormat(thisTag.stPDFIntroInfo.contract_end_date, "m/d/yy")#</h3></td>
        <td align="right" valign="bottom" width="50%" class="header_text thinBottomBorder"><cfif len(trim(thisTag.stPDFHeaderInfo.company_address))><h3>#trim(thisTag.stPDFHeaderInfo.company_address)#</h3><cfelse>&nbsp;</cfif></td>
      </tr>
  </table>
  <br clear="all" />
  <br />
</cfoutput>