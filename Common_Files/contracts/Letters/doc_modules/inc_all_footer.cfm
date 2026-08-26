<cfsilent>
<!--- 
FILE: 		
FILENAME: 		doc_modules/inc_all_footer.cfm
CREATED: 		12/19/2007 - RBL
EDITED:			08/05/2008 - RBL [commented out sectionName]
EDITED:			11/1/2011 - Milan

FUNCTIONALITY:
- This include template generates the footer for HTML Letters...
ACTION: Q - why cfoutput in this include, if not needed, delete, leave.
--->
</cfsilent>

<!--- This duplicate css file must be here. --->
<cfinclude template="css/inc_all_style.cfm">

<cfoutput>
  <table name="outer_table" width="100%" cellpadding="0" cellspacing="0" border="0" height="50" class="height_50">
      <tr>
        <td align="right" valign="top" width="100%" class="footer_text thinTopBorder height_50">
          <br /> #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
        </td>
      </tr>
  </table>
</cfoutput>