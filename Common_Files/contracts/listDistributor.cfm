<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<title>#application.returned_customer_setting.distributor_label_singular# Selection Window</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>
</cfoutput>
<body>

<CFQUERY NAME="Get_Distributors" datasource="#application.datasource#">
		SELECT	DISTINCT customer_active.BSA_Foodservice_Customers_ID, Name, Shr_Ship_To
		FROM	customer_active
				INNER JOIN Line_Of_Business lob 
				ON customer_active.Line_Of_Business_ID = lob.Line_Of_Business_ID
				AND
				lob.Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#)
				AND lob.Deleted = 0
				INNER JOIN Invoice_Header
				ON
				Invoice_Header.Deleted = 0
				AND
				Invoice_Header.BSA_Foodservice_Customers_ID = customer_active.BSA_Foodservice_Customers_ID
		WHERE 	customer_active.Deleted = 0  
		ORDER BY Name
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
<FORM ACTION="listDistributorForm.cfm" METHOD="post" NAME="listDistForm" ID="listDistForm" STYLE="DISPLAY:INLINE">
	<DIV align="center">
	<FIELDSET STYLE="padding:10px; border: 3px groove LightGrey; width:400px" >
		<LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;"></LEGEND>
		
		<table ALIGN="center" CELLPADDING="4" CELLSPACING="">
			<TR>
				<TD>
					<B><FONT SIZE="2" color="##333399">Select <cfoutput>#Lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput></FONT></B>
				</TD>
			</TR>
			<TR>
				<TD>
					<SELECT name="listDist" id="listDist" >
						<CFOUTPUT><OPTION VALUE="0" selected> ******** Select a #Lcase(application.returned_customer_setting.distributor_label_singular)# ******** </OPTION></CFOUTPUT>
						<CFOUTPUT QUERY="Get_Distributors"><OPTION VALUE="#trim(Get_Distributors.BSA_Foodservice_Customers_ID)#">#trim(Get_Distributors.Name)#  -  ( #Shr_Ship_To# )</OPTION></CFOUTPUT>
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
	  	var myindex=document.listDistForm.listDist.selectedIndex;
		var callerWindowObj = dialogArguments;
  		
		if (myindex == 0)
		{
			callerWindowObj.document.all.SearchForm.Visible_Distributor.value = "";
		}
		else
		{
			callerWindowObj.document.all.SearchForm.Visible_Distributor.value = document.listDistForm.listDist.options[myindex].text;
		}
		callerWindowObj.document.all.SearchForm.Distributor.value = document.listDistForm.listDist.options[myindex].value;
		window.close();
	}
	
</script>