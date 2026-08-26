<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>


<cfinclude template="/includes/call_please_wait.cfm">
<cfinclude template="Price_list_Detail_Content_Sort.cfm">
<cfoutput>#savethis_todispaly#</cfoutput>
<!--- <cfoutput query="get_all_details">
#Start_Date#,#End_Date#,#LB_FOB_Price#,#CS_FOB_Price#,#Type_Code_Desc#,#Type_Group_Desc#,#Item#,#UPC#,#Description#,#Brand_Name#,#Net_Weight#,#Gross_Weight#<br>
</cfoutput> --->

<SCRIPT LANGUAGE="JavaScript">
function email_this()
{
	var email_var;
	email_var = NewWindow("PL_Email_Create.cfm?<cfoutput>PL_ID=#URL.PL_ID#&Type=#URL.Type#&Sort_By=#FORM.Sort_By#&Sort_Order=#FORM.Sort_Order#</cfoutput>&Nottodispaly=1", 'pl_email', '600', '400', 'Yes', 'No', true);
}
function fax_this()
{
	var fax_var;
	fax_var = NewWindow("PL_Fax_Create.cfm?<cfoutput>PL_ID=#URL.PL_ID#&Type=#URL.Type#&Sort_By=#FORM.Sort_By#&Sort_Order=#FORM.Sort_Order#</cfoutput>&Nottodispaly=1&Fax=1", 'pl_email', '600', '400', 'Yes', 'No', true);
}
function print_this()
{
	var print_var;
	alert("Please select 'Landscape Layout' to avoid losing some columns.")
	print_var = NewWindow("PL_Print_Create.cfm?<cfoutput>PL_ID=#URL.PL_ID#&Type=#URL.Type#&Sort_By=#FORM.Sort_By#&Sort_Order=#FORM.Sort_Order#</cfoutput>&Nottodispaly=1&Print=1", 'pl_email', '850', '600', 'Yes', 'No', true);
}
</script>

<br><br>
<table align="center">
	<tr>
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"E-Mail"
				button_action	=	"javaScript: email_this()"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		</td>
	<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"Fax"
				button_action	=	"javaScript: fax_this()"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		</td>
	 --->
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"Print"
				button_action	=	"javaScript: print_this()"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">	
		</td>
	</tr>
</table>
</body>
</html>
