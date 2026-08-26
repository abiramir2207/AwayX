<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<cfparam name="Form.nm_sub1_group_side"		default="">
<cfparam name="Form.nm_sub2_group_side"	default="">
<cfparam name="Form.nm_sub3_group_side"	default="">
<cfparam name="Form.nm_sub4_group_side"    default="">
<cfparam name="page_type"  default="Add a file">

<!--- Create a query to feed to the API... --->
<cfif #page_type# is not "All">
  <cfquery datasource="#request.dsn#" name="GetGroups">
  select nm_group_side, nvl(nm_sub1_group_side, ' ') "nm_sub1_group_side", nvl(nm_sub2_group_side, ' ') "nm_sub2_group_side", nvl(nm_sub3_group_side, ' ') "nm_sub3_group_side",  nvl(nm_sub4_group_side, ' ') "nm_sub4_group_side"
  from side_group, user_groups
  where side_group.id_side_group = user_groups.id_side_group
  AND user_groups.id_user = #Session.id_user#
  order by nm_group_side, "nm_sub1_group_side", "nm_sub2_group_side", "nm_sub3_group_side", "nm_sub4_group_side"
  </cfquery>
<cfelse>
  <cfquery datasource="#request.dsn#" name="GetGroups">
 select nm_group_side, nvl(nm_sub1_group_side, ' ') "nm_sub1_group_side", nvl(nm_sub2_group_side, ' ') "nm_sub2_group_side", nvl(nm_sub3_group_side, ' ') "nm_sub3_group_side",  nvl(nm_sub4_group_side, ' ') "nm_sub4_group_side"
  from side_group
  order by nm_group_side, "nm_sub1_group_side", "nm_sub2_group_side", "nm_sub3_group_side", "nm_sub4_group_side"
 </cfquery>
</cfif>

<html>
<head>
	<title>Five Selects Example</title>
<cfinclude template="js_head.cfm">
</head>

<!--- Script for prepopulating page --->
<cfoutput>
<script language="JavaScript">
function init() {
	<cfif IsDefined("Form.submit")>
		objForm.nm_group_side.setValue("#Form.nm_group_side#"); // Select group
		objForm.nm_group_side.obj.onchange(); // Populate subgroup 1
		<cfif Form.nm_sub1_group_side NEQ "">
			objForm.nm_sub1_group_side.setValue("#Form.nm_sub1_group_side#"); // Select Subgroup 1
			objForm.nm_sub1_group_side.obj.onchange(); // Populate Subgroup 2
		</cfif>
		<cfif Form.nm_sub2_group_side NEQ "">
			objForm.nm_sub2_group_side.setValue("#Form.nm_sub2_group_side#"); // Select Subgroup 2
			objForm.nm_sub2_group_side.obj.onchange(); // Populate Subgroup 3
		</cfif>
		<cfif Form.nm_sub3_group_side NEQ "">
			objForm.nm_sub3_group_side.setValue("#Form.nm_sub3_group_side#"); // Select Subgroup 3
			objForm.nm_sub3_group_side.obj.onchange(); // Populate Subgroup 4
		</cfif>
		<cfif Form.nm_sub4_group_side NEQ "">
			objForm.nm_sub4_group_side.setValue("#Form.nm_sub4_group_side#"); // Select Subgroup 4
		</cfif>
	</cfif>
} 
</script>
</cfoutput>

<BODY onLoad="init();">



  <tr>
	<td bgcolor="#F0F8FF" align="left"> 
      <font color="#003366" face="Arial, Helvetica, sans-serif" size="2"><b>Group: </b></font>
    </td>
	<td>
	  <select name="nm_group_side" style="width : 250px;">
	    <OPTION>Select a Group </OPTION>
		<cfoutput query="GetGroups" group="nm_group_side">
		  <option value="#nm_group_side#">#nm_group_side#</option>
		</cfoutput>
	  </select>
	</td>
  </tr>

  <tr>
    <td bgcolor="#F0F8FF" align="left"> 
      <font color="#003366" face="Arial, Helvetica, sans-serif" size="2"><b>Sub Group 1: </b></font>
    </td>
	<td>
	  <select name="nm_sub1_group_side" style="width : 250px;">
	  </select>
	</td>
  </tr>
  <tr>
    <td bgcolor="#F0F8FF" align="left"> 
      <font color="#003366" face="Arial, Helvetica, sans-serif" size="2"><b>Sub Group 2: </b></font>
    </td>
	<td>
	  <select name="nm_sub2_group_side" style="width : 250px;">
	  </select>
	</td>
  </tr>
  <tr>
    <td bgcolor="#F0F8FF" align="left"> 
      <font color="#003366" face="Arial, Helvetica, sans-serif" size="2"><b>Sub Group 3: </b></font>
    </td>			
	<td>
	  <select name="nm_sub3_group_side" style="width : 250px;">
	  </select>
	</td>
  </tr>
  <tr>
    <td bgcolor="#F0F8FF" align="left"> 
      <font color="#003366" face="Arial, Helvetica, sans-serif" size="2"><b>Sub Group 4: </b></font>
    </td>
	<td>
	  <select name="nm_sub4_group_side" style="width : 250px;">
	  </select>
	</td>
  </tr>


</body>
</html>

