<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<CFPARAM NAME="FORM.Family_Name" 		DEFAULT="">
	<CFPARAM NAME="FORM.Buying_Group" 		DEFAULT="">
	<title>#Ucase(URL.name)# Selection Window</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>
</cfoutput>
<body>
<cfswitch expression = #trim(URL.name)#>
  <cfcase value = "family_name">
 	<!--- Query --->
	<cfquery name="GetFamilyNames" datasource="#application.datasource#">
		SELECT distinct *
		FROM Distributor_Family
		WHERE Deleted = 0
		ORDER BY Family_Name
	</cfquery>
  </cfcase>
  <cfcase value = "buying_group">
  	<!--- Query --->
	<!--- Buying Groups --->
	<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
		SELECT distinct *
		FROM Distributor_Buying_Groups
		WHERE Deleted = 0
		ORDER BY Buying_Group_Name
	</cfquery>
  </cfcase>
  <cfdefaultcase>
   
  </cfdefaultcase>
</cfswitch> 

<cfoutput>
	<FORM ACTION="listSelection.cfm" METHOD="post" NAME="listSelectionForm" ID="listSelectionForm" STYLE="DISPLAY:INLINE">
		<cfswitch expression = #trim(URL.name)#>
		  <cfcase value = "family_name">
		 	<BR>&nbsp;&nbsp;<span ID="searchItemLabel" STYLE="color:navy"><B>#application.returned_customer_setting.family_name_label_singular#</B></span><BR>&nbsp;&nbsp;			
			<SELECT NAME="Family_Name" style="width: 200px;">
				<OPTION VALUE="0">**ALL** #application.returned_customer_setting.family_name_label_plural#</OPTION>
				<cfloop query="GetFamilyNames"><OPTION VALUE="#trim(Family_ID)#"#IIF(trim(FORM.Family_Name) EQ "#trim(Family_ID)#", DE(" SELECTED"), DE(""))#>#trim(Family_Name)#</OPTION></cfloop>
			</SELECT>		
			<BR><BR>
			&nbsp;&nbsp;<INPUT TYPE="Button" NAME="Submit"  VALUE="Submit" ONCLICK="eventHandler(document.all.listSelectionForm.Family_Name)" STYLE="font-size: 12px;font-weight: bold;">
		  </cfcase>
		  <cfcase value = "buying_group">
			<BR>&nbsp;&nbsp;<span ID="searchItemLabel" STYLE="color:navy"><B>#application.returned_customer_setting.buying_group_label_plural#</B></span><BR>&nbsp;&nbsp;	
			<SELECT NAME="Buying_Group" style="width: 200px;">
			<OPTION VALUE="0">**ALL** #application.returned_customer_setting.buying_group_label_plural#</OPTION>
			<cfloop query="GetBuyingGroups"><OPTION VALUE="#trim(Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ "#trim(Buying_Group_ID)#", DE(" SELECTED"), DE(""))#>#trim(Buying_Group_Name)#</OPTION></cfloop>
			</SELECT>	
			<BR><BR>
			&nbsp;&nbsp;<INPUT TYPE="Button" NAME="Submit"  VALUE="Submit" ONCLICK="eventHandler(document.all.listSelectionForm.Buying_Group)" STYLE="font-size: 12px;font-weight: bold;">	
		  </cfcase>
		  <cfdefaultcase>
		   
		  </cfdefaultcase>
		</cfswitch> 
		
	</FORM>
</cfoutput>
</body>
</html>


<script>

	function eventHandler(theObj)
	{
	  	var myindex=theObj.selectedIndex;
		var callerWindowObj = dialogArguments;
  		alert(theObj.name);
		
		if (myindex == 0)
		{
			eval("callerWindowObj.document.all.MyInvoiceForm." + "Visible_" + theObj.name + ".value = '"  + "'");
			eval("callerWindowObj.document.all.MyInvoiceForm." + theObj.name + ".value = '" + 0 + "'");
		}
		else
		{
			alert(theObj.options[myindex].text);
			eval("callerWindowObj.document.all.MyInvoiceForm." +  "Visible_" + theObj.name + ".value = '" + theObj.options[myindex].text + "'");
			eval("callerWindowObj.document.all.MyInvoiceForm." +  theObj.name + ".value = '" + theObj.options[myindex].value + "'");
		}
		window.close();
	}
	
</script>