<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfoutput>
<html>
<head>
	<title>#application.returned_customer_setting.operator_label_singular# Selection Window</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>
</cfoutput>
<body>
<cfset useLakebaseForGet_Operators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operators>
	<cftry>
		<cfset Get_Operators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"deleted" = "eq.0",
				"order" = "operator_name.asc",
				"select" = "bsa_operator_id,operator_name"
			}), "bsa_operator_id,operator_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operators>
<CFQUERY NAME="Get_Operators" datasource="#application.datasource#">
	SELECT	DISTINCT BSA_Operator_ID, Operator_Name
	FROM	BSA_Operator
	WHERE 	Deleted = 0  
	ORDER BY Operator_Name
</CFQUERY>
</cfif>
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
<FORM ACTION="listOperatorForm.cfm" METHOD="post" NAME="listOperForm" ID="listOperForm" STYLE="DISPLAY:INLINE">
	<DIV align="center">
	<FIELDSET STYLE="padding:10px; border: 3px groove LightGrey; width:400px" >
		<LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;"></LEGEND>
		
		<table ALIGN="center" CELLPADDING="4" CELLSPACING="">
			<TR>
				<TD>
					<B><FONT SIZE="2" color="##333399">Select <cfoutput>#Lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></FONT></B>
				</TD>
			</TR>
			<TR>
				<TD>
					<SELECT name="listOper" id="listOper" >
						<CFOUTPUT><OPTION VALUE="0" selected> ******** Select a #Lcase(application.returned_customer_setting.operator_label_singular)# ******** </OPTION></CFOUTPUT>
						<CFOUTPUT QUERY="Get_Operators"><OPTION VALUE="#trim(Get_Operators.BSA_Operator_ID)#">#trim(Get_Operators.Operator_Name)#</OPTION></CFOUTPUT>
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
	  	var myindex=document.listOperForm.listOper.selectedIndex;
		var callerWindowObj = dialogArguments;
  		
		if (myindex == 0)
		{
			callerWindowObj.document.all.SearchForm.Visible_Operator.value = "";
		}
		else
		{
			callerWindowObj.document.all.SearchForm.Visible_Operator.value = document.listOperForm.listOper.options[myindex].text;
		}
		callerWindowObj.document.all.SearchForm.Operator.value = document.listOperForm.listOper.options[myindex].value;
		window.close();
	}
	
</script>