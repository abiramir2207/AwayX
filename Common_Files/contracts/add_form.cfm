<cfquery datasource="#request.dsn#" name="GetData">
select id_file, nm_title, nm_group_side, nm_sub1_group_side, nm_sub2_group_side, nm_sub3_group_side, nm_sub4_group_side
from files, side_group
where id_file=#Session.id_file#
AND files.id_side_group = side_group.id_side_group
</cfquery>


<HTML>
<HEAD>
	<TITLE>Add</TITLE>
</HEAD>

<BODY BGCOLOR = "#ffffff">

<!-- query to get the first level group names -->


<TABLE BORDER = "0" align="center">
  <cfset page_type="Add a file">
  <cfoutput> 
<form name="frm" enctype="multipart/form-data" action="add_file.cfm" method="post">
  
  <cfinclude template="get_side_groups.cfm">

    <tr> 
      <td bgcolor="F0F8FF"> 
        <div align="left"><font color="003366" face="Arial, Helvetica, sans-serif" size="2"><b>Title: 
          </b></font></div>
      </td>
      <td> 
        <input type="text" name="nm_title" size="47" <cfif #GetData.RecordCount# is not 0>value="#GetData.nm_title#"</cfif>>
        
      </td>
    </tr>

    	
    <tr bgcolor="FFFFFF"> 
      <td colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr bgcolor="FFFFFF"> 
<input type="hidden" name="form_action" value="add_file">	
<input type="hidden" name="page_type" value="#page_type#">
      <td></td>
      <td> <font face="Arial, Helvetica, sans-serif" size="2" color="003366"><b> 
        <input type="Submit" name="newsubmit" value="  Add File  " onClick="checkForm()">
        </b></font> </td>
  </cfoutput> </tr></form>
</TABLE>

<P>
<SCRIPT LANGUAGE="JavaScript">
<cfinclude template="script_side_groups.cfm">
<cfoutput>
  <cfif #GetData.RecordCount# is not 0>
	objForm.nm_group_side.setValue("#GetData.nm_group_side#");
	selectGroup();
	<cfif #GetData.nm_sub1_group_side# NEQ "">
		objForm.nm_sub1_group_side.setValue("#GetData.nm_sub1_group_side#"); // Select Subgroup 1
		objForm.nm_sub1_group_side.obj.onchange(); // Populate Subgroup 2
	</cfif>
	<cfif #GetData.nm_sub2_group_side# NEQ "">
		objForm.nm_sub2_group_side.setValue("#GetData.nm_sub2_group_side#"); // Select Subgroup 2
		objForm.nm_sub2_group_side.obj.onchange(); // Populate Subgroup 3
	</cfif>
	<cfif #GetData.nm_sub3_group_side# NEQ "">
		objForm.nm_sub3_group_side.setValue("#GetData.nm_sub3_group_side#"); // Select Subgroup 3
		objForm.nm_sub3_group_side.obj.onchange(); // Populate Subgroup 4
	</cfif>
	<cfif #GetData.nm_sub4_group_side# NEQ "">
		objForm.nm_sub4_group_side.setValue("#GetData.nm_sub4_group_side#"); // Select Subgroup 4
	</cfif>
	
  </cfif>	
</cfoutput>
function checkForm() {
  // Required field

  objForm.nm_title.validateNotNull("A title needs to be entered");
 }
	
</SCRIPT>

</BODY>
</HTML>
