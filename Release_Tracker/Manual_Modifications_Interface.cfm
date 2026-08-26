<!---
***********************************************************************
Author: Milan Mushran
Filename: manual_modifications_interface.cfm
Purpose: For entering details about the files manually changed.
Date Created: 10/04/2006
Modification: Added Java Applet for browsing files, removing certain fields and addition of error validation.
Modified By: Milan Mushran
Modified Date: 10/20/2006
Modification: Now, Instead of the Java Applet, we have the browse button and web services functionality.
Modified By: Milan Mushran
Modified Date: 9/14/2007
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
<cfset useLakebaseForqrygetClientList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("client_list")>
<cfif useLakebaseForqrygetClientList>
	<cftry>
		<cfset qrygetClientList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("client_list", {
				"deleted" = "eq.0",
				"order" = "client_url.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqrygetClientList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqrygetClientList>
<CFQUERY NAME="qrygetClientList" datasource="PunchList">
	SELECT *
	FROM Client_List
	WHERE Deleted = 0
	ORDER BY Client_URL
</CFQUERY>
</cfif> 

<cfparam name="PageTitle" default="">
<cfparam name="Success" default="0">

<!--- Displays the page title set in the URL --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!---
Uncomment this line to debug js on this page. Just call the dump function - dump(object_name, true)
<SCRIPT SRC="/script/javascript/dump.js"></SCRIPT>
--->

<cfset LocalDev =  0>

<!--- Look whether it is a developer's local environment --->
<cfif server_name eq "localhost" OR server_name eq "127.0.0.1">
	<cfset LocalDev =  1>
</cfif>

<script language="javascript">
	function CheckForm()
	{
	var ErrorList = 0;
	var ErrorListValues = ''

	if(document.frmFilePath.Name.value == '')
	{
		ErrorList = ErrorList + 1;
		ErrorListValues ='- User';
	}

	if(document.frmFilePath.Release_Version.options[document.frmFilePath.Release_Version.selectedIndex].value == '')
	{
		ErrorList = ErrorList + 1;
		ErrorListValues = ErrorListValues + '\n'  + '- Release Version';
	}
	
	 var regex=/^[0-9A-Za-z]+$/; //^[a-zA-z]+$/
	 	if(document.frmFilePath.Label_Number.value != ''){
		 if(regex.test(document.frmFilePath.Label_Number.value)==0){
			ErrorList = ErrorList + 1;
			ErrorListValues = ErrorListValues + '\n'  + '- Only alpha-numeric values allowed for Label Number';
		 }
	 	}	
	
	<cfif LocalDev eq 0>
	if(document.frmFilePath.selClientList){
		if(document.frmFilePath.selClientList.options[document.frmFilePath.selClientList.selectedIndex].value == '')
		{
		ErrorList = ErrorList + 1;
		ErrorListValues = ErrorListValues + '\n'  + '- Client Web Site';
		}
	}
	</cfif>

	if(document.frmFilePath.comments.value == '')
	{
		ErrorList = ErrorList + 1;
		if(ErrorList == 1){
			AddNewLine = '';
			}
		else{
			AddNewLine = '\n';
			}
		ErrorListValues = ErrorListValues + AddNewLine + '- Comments';
	}

		if(ErrorList != 0){
		alert("Please complete the following information:" + '\n' + ErrorListValues);
		return false;
		}
		
	}
		
		// Reverse the string
		function strrev(str) {
  			return str.split("").reverse().join("");
		}
		
		function RemoveAllSpaces(sStr) { 
    		var str = ''; 
    		for (var i = 0; i < sStr.length; i++) { 
        	if (sStr.charAt(i) != ' ') str += sStr.charAt(i); 
    		} 
    	return str; 
		} 
		
		function GetSelectedPath() 
		{
			// If no file is selected
			if(document.frmFilePath.FiletoUpload.value == ''){
				alert("Please select a file.");
				return false;
			}
			
			// If it is the first entry
			if(document.frmFilePath.file_path.value == '')
			{
				document.frmFilePath.file_path.value = document.frmFilePath.FiletoUpload.value;
				// If it is a source file (The Path should have 'Awayx' in it)
				if(document.frmFilePath.file_path.value.toLowerCase().indexOf('awayx') == -1)
				{
					document.frmFilePath.file_path.value = '';
					alert("You should only select files which are a part of the source code");
				}				
			}				
			// If the user intends to enter multiple entries	
			else
			{
			// Separate the entries with a new line
			document.frmFilePath.file_path.value = document.frmFilePath.file_path.value+'\n'+document.frmFilePath.FiletoUpload.value;
			
			// Initialize an array for the file paths
			var File_Path_Array = [];
			
			// Initialize a variable to hold individual entry
			var ArrayContentValue;
			ArrayContentValue = ''

			// Loop through the content of the textareabox and populate the array bases on the newline character
			for (i=0;i<=document.frmFilePath.file_path.value.length-1;i++)
			{	
				// Get character by character
				ArrayContentValue = ArrayContentValue+document.frmFilePath.file_path.value.charAt(i);
				
				// Dont include spaces in the array being populated
				if(ArrayContentValue != ''){			
					if(document.frmFilePath.file_path.value.charCodeAt(i) == 13 && document.frmFilePath.file_path.value.charCodeAt(i+1) == 10)
					{
						File_Path_Array[File_Path_Array.length] = ArrayContentValue;
						ArrayContentValue = ''
					}
				}
			}
			
			for (i=0;i<=File_Path_Array.length-1;i++){
				// Remove white space
				File_Path_Array[i] = File_Path_Array[i].replace(/\s+/g,'');
				/* Remove all spaces (This is useful when we have a space in between a file path. 
				   For eg: 'C:\SQL Files\AwayX_SQL_4_3\AwayX_SQL\1686_2.sql) 
				*/
				document.frmFilePath.FiletoUpload.value = RemoveAllSpaces(document.frmFilePath.FiletoUpload.value);
				// If there is a duplicate entry
				if(File_Path_Array[i] == RemoveAllSpaces(document.frmFilePath.FiletoUpload.value) || document.frmFilePath.FiletoUpload.value.toLowerCase().indexOf('awayx') == -1){
					// Reverse the string
					ReverseString = strrev(document.frmFilePath.file_path.value)
					/* Loop through the contents of the textarea, find the position of the first newline 
					   character in the reversed string and remove the last entry (a duplicate) from the textarea					   
					*/					 				  
					for (i=0;i<=document.frmFilePath.file_path.value.length-1;i++){	
						if(ReverseString.charCodeAt(i)== 10 && ReverseString.charCodeAt(i+1)== 13){
							document.frmFilePath.file_path.value = strrev(ReverseString.substring(i+2));
											
							if(document.frmFilePath.FiletoUpload.value.toLowerCase().indexOf('awayx') == -1){
								alert("You should only select files which are a part of the source code.");
							}
							else
							{
								alert("You should only select a file once.");
							}
							break;
						}
					}
				}		
			}					  					
		  }
		}
</script>
	
<cfif Success eq 1>
<table border="0" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td><span style="color:red;font-style:bold;font-size:14;">THE DETAILS OF THE FILE/S MODIFICATION HAVE BEEN ENTERED.</span></td>
	</tr>
</table>
</cfif>

<cfquery name="qgetUsers" datasource="#application.datasource#">
	SELECT DISTINCT(Name_First + ' ' + Name_Last) As Name
	FROM _Users
	Where Deleted = 0
	ORDER BY Name
</cfquery>

<cfset useLakebaseForqgetReleaseVersion = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("application_installation")>
<cfif useLakebaseForqgetReleaseVersion>
	<cftry>
		<cfset qgetReleaseVersion = application.oLakebase.toQuery(
			application.oLakebase.selectRows("application_installation", {
				"order" = "release_version.desc",
				"limit" = "1",
				"select" = "release_version"
			}), "release_version"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetReleaseVersion = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetReleaseVersion>
<cfquery name="qgetReleaseVersion" datasource="#application.datasource#">
	SELECT TOP 1 Release_Version
	FROM Application_Installation
	ORDER BY Release_Version DESC
</cfquery>
</cfif>

<form name="frmFilePath" action="manual_modifications_interface_action.cfm" method="post" onSubmit="return CheckForm();">
<table border="0" cellspacing="2" cellpadding="2" align="left" width="100%">
	<tr>
		<td colspan="100%"><b>User:</b>&nbsp;<br />
		<select name="Name">
				<option value="">select user</option>
			<cfoutput query ="qgetUsers">
				<option value="#Name#">#Name#</option>
			</cfoutput>
		</select>
		</td>
  </tr>
	<cfoutput>
	<tr>
		<td colspan="100%"><b>Release Version</b>&nbsp;<br /><select name="Release_Version">
			<option value="">select version</option>
				<cfloop index="MainVersion" from="4" to="9">
					<cfloop index="PointVersion" from="0" to="3">
						<option value="#MainVersion#.#PointVersion#">#MainVersion#.#PointVersion#</option>
					</cfloop>
				</cfloop>
			</select></td>
  </tr>
  <tr>
		<td colspan="100%"><b>Label Number:</b>&nbsp;<br /><input type="text" name="Label_Number"></td>
  </tr>
<cfif LocalDev eq 1>
  <tr>
		<td colspan="100%"><b>Client Web Site</b>&nbsp;<br />
		 <select name="selClientList">
			<option value="">select web site</option>
		 <cfloop query="qrygetClientList">
			<option value="http://#Client_URL#">http://#Client_URL#</option>
		 </cfloop>
		 </select>
		</td>
  </tr>
</cfif> 
  <tr>
  <tr>
		<td width="30%"><input type="file" name="FiletoUpload" size="45">&nbsp;&nbsp;&nbsp;<input type="button" name="Add_File" value="Add File" onclick="GetSelectedPath();"></td>
  </tr> 

  <tr>
		<td colspan="100%"><b>File Path:&nbsp;</b>&nbsp;<br /><textarea name="file_path" rows="6" cols="120"></textarea>
  </tr>
	<tr>
		<td colspan="100%"><b>Comments:</b>&nbsp;<br /><textarea name="comments" rows="10" cols="120"></textarea></td>
  </tr>
	<tr>
		<td colspan="100%">
		(<span style="color:red">Please make sure that the date and time matches the date and time that you made the actual change
		 on the client's instance</span>)
		 <br />
		<b>Date:</b>&nbsp;<br /><select name="Start_Day">
				<cfloop index="startDayIndx" from="1" to="31">
					<option value="#startDayIndx#" <cfif startDayIndx eq Day(now())>selected</cfif>>#startDayIndx#</option>
				</cfloop>
			</select>
			<select name="Start_Month">
				<cfloop index="startMonthIndx" list="#request.app_general_functions.getMonths()#">
					<cfset thisStartMonth = ListFindNoCase(request.app_general_functions.getMonths(), startMonthIndx) />
					<option value="#thisStartMonth#" <cfif thisStartMonth eq Month(now())>selected</cfif>>#startMonthIndx#</option>
				</cfloop>
			</select>
			<select name="Start_Year">
				<cfloop index="startYearIndx" list="#request.app_general_functions.getYears(20, 3)#">
					<option value="#startYearIndx#" <cfif startYearIndx eq Year(Now())>selected</cfif>>#startYearIndx#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td colspan="100%">
		<b>Time:</b>&nbsp;<br /><select name="Start_Hour">
				<cfloop index="startHourIndx" from="1" to="12">
					<cfif Hour(Now()) gt 12><cfset startHourIndxTime = startHourIndx + 12><cfelse><cfset startHourIndxTime = startHourIndx></cfif>
					<option value="#startHourIndx#" <cfif startHourIndxTime eq Hour(Now())>selected</cfif>>#startHourIndx#</option>
				</cfloop>
			</select>
			<select name="Start_Minute">
				<cfloop index="startMinuteIndx" from="1" to="59">
					<cfif startMinuteIndx LT 10><cfset startMinuteIndx = "0"&startMinuteIndx></cfif>
					<option value="#startMinuteIndx#" <cfif startMinuteIndx eq Minute(Now())>selected</cfif>>#startMinuteIndx#</option>
				</cfloop>
			</select>
			<select name="AM_PM">
				<option value="AM" <cfif TimeFormat(Now(), 'tt') eq "AM"> selected</cfif>>AM</option>
				<option value="PM" <cfif TimeFormat(Now(), 'tt') eq "PM"> selected</cfif>>PM</option>
			</select>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="100%">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="100%"><input type="submit" value="Submit"></td>
  </tr>
	</cfoutput>
</table>	
</form>