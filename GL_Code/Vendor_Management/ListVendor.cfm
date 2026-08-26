<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<title>Vendor Selection Window</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>
</cfoutput>
<body>
<CFQUERY NAME="Get_Vendor" datasource="#application.datasource#">
	SELECT	DISTINCT Vendor_ID,Vendor_Name
	FROM	Vendor_Master
	WHERE 	Deleted = 0  
	ORDER BY Vendor_ID
</CFQUERY>
<!--- none
hidden
dotted
dashed
solid
double
groove
ridge
inset
outset--->
<FORM ACTION="listVendor.cfm" METHOD="post" NAME="listVendForm" ID="listVendForm" STYLE="DISPLAY:INLINE">
	<DIV align="center">
	<FIELDSET STYLE="padding:10px; border: 3px groove LightGrey; width:400px" >
		<LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;"></LEGEND>
		
		<table ALIGN="center" CELLPADDING="4" CELLSPACING="">
			<TR>
				<TD>
					<B><FONT SIZE="2" color="##333399">Select Vendor</FONT></B>
				</TD>
			</TR>
			<TR>
				<TD>
					<SELECT name="listVend" id="listVend" >
						<CFOUTPUT><OPTION VALUE="0" selected> ******** Select a Vendor ******** </OPTION></CFOUTPUT>
						<CFOUTPUT QUERY="Get_Vendor"><OPTION VALUE="#trim(Get_Vendor.Vendor_ID)#">#trim(Get_Vendor.Vendor_ID)# - #trim(Get_Vendor.Vendor_Name)#</OPTION></CFOUTPUT>
					</SELECT> 
				</TD>
			</TR>
			<TR>
				<td align="left">
					<CF_button
						button_name		=	""
						button_caption	=	"Submit"
						button_action	=	"eventHandler();"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					> 
				</TD>
			</TR>
		</table>
	</FIELDSET>
	</DIV>
</FORM>

</body>
</html>


<script>

	function eventHandler()
	{
	  	var myindex=document.listVendForm.listVend.selectedIndex;
		var callerWindowObj = dialogArguments;
  		
		if (myindex == 0)
		{
			callerWindowObj.document.all.SearchForm.Visible_Vendor.value = "";
		}
		else
		{
			callerWindowObj.document.all.SearchForm.Visible_Vendor.value = document.listVendForm.listVend.options[myindex].text;
		}
		callerWindowObj.document.all.SearchForm.Vendor_ID.value = document.listVendForm.listVend.options[myindex].value;
		window.close();
	}
	
</script>
