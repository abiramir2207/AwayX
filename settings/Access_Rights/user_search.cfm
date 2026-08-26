<html>
<head>
	<title>Untitled</title>
</head>
<body TOPMARGIN="0">
<script>
function disableFields(disabled)
{
	if (disabled == true)
	{
		document.SearchForm.User_First_Name.disabled = true;
		document.SearchForm.User_Last_Name.disabled = true;
		document.SearchForm.profile_id.disabled = true;
		document.SearchForm.user_position_id.disabled = true;
		document.SearchForm.userPosition[0].disabled = true;
		document.SearchForm.userPosition[1].disabled = true;
		document.SearchForm.auth_sequence.disabled = true;
		document.SearchForm.User_First_Name.style.background = '#cccccc';
		document.SearchForm.User_Last_Name.style.background = '#cccccc';
	}
	else
	{
		document.SearchForm.User_First_Name.disabled = false;
		document.SearchForm.User_Last_Name.disabled = false;
		document.SearchForm.profile_id.disabled = false;
		document.SearchForm.user_position_id.disabled = false;
		document.SearchForm.userPosition[0].disabled = false;
		document.SearchForm.userPosition[1].disabled = false;
		document.SearchForm.auth_sequence.disabled = false;
		document.SearchForm.User_First_Name.style.background = '#ffffff';
		document.SearchForm.User_Last_Name.style.background = '#ffffff';
	}
}
function showSearchResult()
{
	document.SearchForm.submit();
	return false;
}
 /**********************************************************************
	buildFilter is used to take in all the search fields and build
	an object of those fields to pass into the filterSearch() function
	that is located in list_users.cfm
  ********************************************************************/
function buildFilter()
{
	
	
	var filterObj = new Object();
	var positionSelected = '';
	filterObj.sortBy = 'name_last';
	filterObj.type = parent.frames.list_users.Search_Form.displayinactiveusers.value;
	filterObj.start = 1;
	filterObj.end = 15;
	filterObj.firstName = document.SearchForm.User_First_Name.value;
	filterObj.lastName = document.SearchForm.User_Last_Name.value;
	filterObj.profileId = document.SearchForm.profile_id.value;
	filterObj.positionId = document.SearchForm.user_position_id.value;
	filterObj.last_name = '';

		for (var i = 0; i < document.SearchForm.userPosition.length; i++)
		{
			if (document.SearchForm.userPosition[i].checked)
			{
				positionSelected = document.SearchForm.userPosition[i].value;
			}
		}

	filterObj.position = positionSelected;

	if (document.SearchForm.auth_sequence)
	{
		filterObj.authoritySequence = document.SearchForm.auth_sequence.value;
	}
	else
	{
		filterObj.authoritySequence = 0;
	}

      	     
	      
	  parent.frames.list_users.filterSearch(filterObj);
	  parent.frames.list_users.document.body.scrollTop = 0;
	  parent.frames.list_users.resetValues('true');
	 

	  
}
</script>
<CFSET PageTitle="USERS: LIST USERS">
<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/Images/gradient.jpg" WIDTH="100%" HEIGHT="20"><SPAN STYLE="color:white; font-size:14px; font-weight: bold;"><CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN></TD>
</TR>
</TABLE>
<cfset variables.authoritySequenceObj = createObject('component', 'components.user.AuthoritySequenceManager').init() />
<cfset variables.getAuthSequence = variables.authoritySequenceObj.getAll() />
<FORM TARGET="list_users" STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="list_users.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result">
<table cellspacing="4" border="0" >
<tr>
<td><B>First Name</B><BR><input type="text" name="User_First_Name" size="20" onkeyup="buildFilter()"/> </td>
	<td><B>Last Name</B><BR><input type="text" name="User_Last_Name" size="20" onkeyup="buildFilter()" />
&nbsp;&nbsp;	<strong><font color="FF0000">[</font><a href="#" onclick="javascript:document.SearchForm.reset();buildFilter();return false;">reset form</a><font color="FF0000">]</font></b>

	</td>

 <cfsilent>
  <cfquery NAME="getUserPositions" datasource="#application.datasource#">
	Select		User_Positions.Position_Label,
				User_Positions.User_Positions_ID,
				Service_Zones.Zone_Name,
				Service_Regions.Region_Name,
				Service_Markets.Market_Name,
				User_Positions.Service_Zone_ID,
				User_Positions.Service_Region_ID,
				User_Positions.Service_Market_ID
	From		User_Positions
				LEFT JOIN	Service_Zones
				ON
				Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
				LEFT JOIN	Service_Regions
				ON
				Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
				LEFT JOIN	Service_Markets
				ON
				Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
	Where		User_Positions.Deleted=0
				AND
				(len(User_Positions.Position_Label) <> 0)
				AND
				(
					User_Positions.Service_Zone_ID IS NULL
					OR
					(Service_Zones.Deleted = 0)
				)
				AND
				(
					User_Positions.Service_Region_ID IS NULL
					OR
					(Service_Regions.Deleted = 0)
				)
				AND
				(
					User_Positions.Service_Market_ID IS NULL
					OR
					(Service_Markets.Deleted = 0)
				)
				
				Order By User_Positions.Position_Label Asc

 </cfquery>
</cfsilent>

<td >
</td>


</tr>
<tr>
	<cfsilent>
<cfset useLakebaseForGet_Profiles = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles")>
<cfif useLakebaseForGet_Profiles>
	<cftry>
		<cfset Get_Profiles = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles", {
				"deleted" = "eq.0",
				"order" = "profiles_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Profiles = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Profiles>
<CFQUERY NAME="Get_Profiles" DATASOURCE="#application.datasource#">
select * from profiles
where deleted = 0
Order By Profiles_Desc Asc
</CFQUERY>
</cfif></cfsilent>
<td><strong>Profile</strong><br />
     <select name="profile_id" onchange="buildFilter()">
	  <option value="0">**ALL** Profiles</option>
		<cfoutput query="Get_Profiles">
		 <option value="#trim(profiles_id)#">#Profiles_Desc#</option>
		</cfoutput>
	  </select>
</td>
	<td><strong>Position</strong>
    <span style="margin-left:10px;">
	<input type="radio" name="userPosition" id="userPosition" value="P" checked onclick="buildFilter()" />Primary
    <input type="radio" name="userPosition" id="userPosition" value="S" onclick="buildFilter()" />Secondary<br />
	</span>
	<select name="user_position_id" onchange="buildFilter()">
	  <option value="0">**ALL** Positions</option>
	   <cfoutput query="getUserPositions">
		<option value="#trim(User_Positions_ID)#">#Position_Label#</option>
	   </cfoutput>
	 </select>
</td>
<td><cfif variables.getAuthSequence.RecordCount gte 1>
	<strong>Authority Sequence</strong><br />
     	<select name="auth_sequence" onchange="buildFilter()">
	    <option value="0">**ALL**</option>
		<cfoutput query="variables.getAuthSequence">
		 <option value="#trim(Authority_Sequence_ID)#">#Authority_Sequence_Name#</option>
		</cfoutput>
	  </select>
	
<cfelse>
<input type="hidden" name="auth_sequence" value="0">

</cfif></td>

</tr>



</table>
</form>
<script>
	disableFields(true);
</script>
</body>
</html>