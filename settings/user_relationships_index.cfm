<CFQUERY NAME="getServiceZones" datasource="#application.datasource#">
	SELECT *
	FROM Service_Zones
	--ORDER BY 
</CFQUERY>

<CFQUERY NAME="getServiceRegions" datasource="#application.datasource#">
	SELECT *
	FROM Service_Regions
	--ORDER BY 
</CFQUERY>

<CFQUERY NAME="getServiceMarkets" datasource="#application.datasource#">
	SELECT *
	FROM Service_Markets
	--ORDER BY 
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</head>

<BODY BGCOLOR="WhiteSmoke">

<CFSET PageTitle="USER RELATIONSHIPS: MAINTAINENCE">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSCRIPT>
	Border="Yes";
	BorderSize=1;  
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=8;
	IsClosed="No";  
	Width=400;
</CFSCRIPT>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Positions"  
	TitleClosed="Positions"  
	TitleTooltip=""  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">

		<CFQUERY NAME="getPostions" datasource="#application.datasource#">
SELECT     dbo.Service_Zones.Zone_Name, dbo.Service_Zones.Zone_Number, dbo.Service_Regions.Region_Number, dbo.Service_Regions.Region_Name, 
                      dbo.Service_Markets.Market_Name, dbo.User_Positions.*
FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Zones ON dbo.User_Positions.Position_Zone = dbo.Service_Zones.Service_Zone_ID INNER JOIN
                      dbo.Service_Regions ON dbo.User_Positions.Position_Region = dbo.Service_Regions.Service_Region_ID INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Position_Market = dbo.Service_Markets.Service_Market_ID
			WHERE 
				User_Positions.User_Positions_ID > 3
				AND
				Deleted = 0
			ORDER BY Position_Label
		</CFQUERY>

		<script>
		function trim(strText) { 
		    // this will get rid of leading spaces 
		    while (strText.substring(0,1) == ' ') 
		        strText = strText.substring(1, strText.length);
		
		    // this will get rid of trailing spaces 
		    while (strText.substring(strText.length-1,strText.length) == ' ')
		        strText = strText.substring(0, strText.length-1);
		
		   return strText;
		} 



			var ExistingLabels = new Array();
			var newLabel = "";
			var dataMode = "add";
			
			//make sure there are no duplicate labels
			function checkForDuplicateLabel(){
				for(var x=0; x<ExistingLabels.length; x++) {
					if(trim(ExistingLabels[x]) == newLabel) {
						alert("The New Label Already Exists, Please Rename it.")
						return false;
					}
				}
				return true;
			}
			
			function savePosition() {
				trimedLabel = trim(document.PositionForm.new_position_label.value)
				document.PositionForm.new_position_label.value = trimedLabel
				newLabel = trim(trimedLabel.toLowerCase())
				
				if(newLabel.length !=0){
					if(dataMode == "add") {
						if(checkForDuplicateLabel()){
							if(confirm("Add New Label?")) {
								document.PositionForm.submit()
							}
						}
					}
					else {
						if(confirm("Save Changes?")) {
							document.PositionForm.submit()
						}
					}
				}
				else{
					alert("Please Enter The Label Text.")
				}
			}
			

			function editLabel(position_label_text, position_description_text, position_id, zone_id, region_id, market_id) {
				clearNewLabelFields()
				dataMode = "edit"
				document.PositionForm.new_position_label.value 			= position_label_text;
				document.PositionForm.new_position_description.value	= position_description_text;
				document.PositionForm.new_position_label_id.value		= position_id;

				selectBoxOptionSelectWithSuppliedValue(document.all.Service_Zone_ID, zone_id)
				selectBoxOptionSelectWithSuppliedValue(document.all.Service_Region_ID, region_id)
				selectBoxOptionSelectWithSuppliedValue(document.all.Service_Market_ID, market_id)
				document.all.new_position_label.focus();
				document.PositionForm.labelActionButton.value 			= "update"
			}
			
			function deleteLabel(position_label_text, position_id){
				clearNewLabelFields();
				if(confirm("Press OK to Delete Position: " + position_label_text)){
					document.forms.PositionDeleteForm.Position_ID.value = position_id
					document.forms.PositionDeleteForm.submit()
				}
			}
			
			function clearNewLabelFields(){
				dataMode = "add"
				document.PositionForm.new_position_label.value 			= "";
				document.PositionForm.new_position_description.value	= "";
				document.PositionForm.new_position_label_id.value		= 0;
				document.all.Service_Zone_ID.selectedIndex				= 0;
				document.all.Service_Region_ID.selectedIndex			= 0;
				document.all.Service_Market_ID.selectedIndex			= 0;
				document.all.new_position_label.focus();
				document.PositionForm.labelActionButton.value 			= "add"
			}
			
			function selectBoxOptionSelectWithSuppliedValue(selectBoxObject, value){
				for(var x=0; x<selectBoxObject.options.length; x++){
					if(selectBoxObject.options[x].value == value){
						selectBoxObject.options[x].selected = true;
					}
				} 
			}
			
		
		</script>		

		<FORM ACTION="user_position_save_Action.cfm" METHOD="post" NAME="PositionForm" ID="PositionForm">
		<TABLE BORDER="1">
			<TR>
				<TD>Position Label</TD>
				<TD>Description</TD>
				<TD>Zone</TD>
				<TD>Region</TD>
				<TD>Market</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
			</TR>
			<CFOUTPUT QUERY="getPostions">
			<script>ExistingLabels[#evaluate("getPostions.currentrow-1")#] = "#lcase(getPostions.Position_Label)#"</script>
			<TR>
				<TD NOWRAP>#getPostions.Position_Label#&nbsp;</TD>
				<TD NOWRAP>#getPostions.Position_Description#&nbsp;</TD>
				<TD NOWRAP>#getPostions.Zone_Name#&nbsp;</TD>
				<TD NOWRAP>#getPostions.Region_Name#&nbsp;</TD>
				<TD NOWRAP>#getPostions.Market_Name#&nbsp;</TD>
				<TD><A ONCLICK="editLabel('#getPostions.Position_Label#','#getPostions.Position_Description#', '#getPostions.User_Positions_ID#', #getPostions.Position_Zone#, #getPostions.Position_Region#, #getPostions.Position_Market#)" STYLE="cursor: pointer;">[edit]</A></TD>
				<TD><IMG SRC="/images/delete.gif" STYLE="cursor: pointer;" ALT="" BORDER="0" ONCLICK="deleteLabel('#getPostions.Position_Label#' ,#getPostions.User_Positions_ID#)"></TD>
			</TR>
			</CFOUTPUT>
		</TABLE>
		<HR>
		<TABLE BORDER="1">
			<TR>
				<TD>Label</TD>
				<TD><input NAME="new_position_label" type="text"></TD>
			</TR>
			<TR>
				<TD>Description</TD>
				<TD><textarea NAME="new_position_description" STYLE="width: 200px;"></textarea></TD>
			</TR>
			<TR>
				<TD>Zone</TD>
				<TD><select NAME="Service_Zone_ID"><OPTION VALUE="0">Select One...</OPTION><CFOUTPUT QUERY="getServiceZones"><option VALUE="#getServiceZones.Service_Zone_ID#">#getServiceZones.Zone_Name#</option></CFOUTPUT></select></TD>
			</TR>
			<TR>
				<TD>Region</TD>
				<TD><select NAME="Service_Region_ID"><OPTION VALUE="0">Select One...</OPTION><CFOUTPUT QUERY="getServiceRegions"><option VALUE="#getServiceRegions.Service_Region_ID#">#getServiceRegions.Region_Name#</option></CFOUTPUT></select></TD>
			</TR>
			<TR>
				<TD>Market</TD>
								<TD><select NAME="Service_Market_ID"><OPTION VALUE="0">Select One...</OPTION><CFOUTPUT QUERY="getServiceMarkets"><option VALUE="#getServiceMarkets.Service_Market_ID#">#getServiceMarkets.Market_Name#</option></CFOUTPUT></select></TD>
			</TR>
			<TR>
				<TD>&nbsp;</TD>
				<TD NOWRAP><input ID="labelActionButton" type="button" VALUE="add" ONCLICK="savePosition()">&nbsp;<A ONCLICK="clearNewLabelFields()" STYLE="cursor: pointer;">[add mode]</A></TD>
			</TR>
		</TABLE>
		<input NAME="new_position_label_id" type="hidden" VALUE="0">
		</FORM>
		
		<FORM ACTION="user_position_delete.cfm" METHOD="post" NAME="PositionDeleteForm" ID="PositionDeleteForm">
			<INPUT TYPE="hidden" NAME="Position_ID" VALUE="0">
		</form>
		
</CF_openLayer>

<BR>
<HR>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Position Relationships"  
	TitleClosed="Position Relationships"  
	TitleTooltip=""  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">

</CF_openLayer>

</body>
</html>
