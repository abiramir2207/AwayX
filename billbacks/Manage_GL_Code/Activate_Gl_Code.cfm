<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.formSubmitted" DEFAULT="0">

<CFIF FORM.formSubmitted EQ 1>
<!--- 
	<CFQUERY NAME="CurrActive" DATASOURCE="#Application.Datasource#">
		SELECT Created_Date FROM GL_Code_Activation WHERE Current_Active_Data = 1
	</CFQUERY>
	<CFIF CurrActive.Created_Date NEQ FORM.Created_Date>
		<CFQUERY NAME="ChangePreAct" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Activation		
			SET 	Previous_Active_Data = 0
			WHERE 	Previous_Active_Data = 1
		</CFQUERY>
		
		<CFQUERY NAME="PreActive" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Activation
			SET 	Current_Active_Data = 0,
					Previous_Active_Data = 1
			WHERE 	Created_Date = '#CurrActive.Created_Date#'
		</CFQUERY>
		
		<CFQUERY NAME="CurActive" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Activation
			
			SET 	Current_Active_Data = 1,
					Act_Data_Updated_By = '#request.AccessStructure.User_ID#',
					Act_Data_Updated_On = getDate()
					
			WHERE 	Created_Date = '#FORM.Created_Date#' 
		</CFQUERY>
	</CFIF>
 --->
 	<CFQUERY NAME="GetGL_Code_Upload_ID" DATASOURCE="#Application.Datasource#">
		SELECT TOP 1 * FROM GL_Code_Activation WHERE Created_Date = '#FORM.Created_Date#' AND Deleted = 0
	</CFQUERY>
 	
 	<CFQUERY NAME="offTonightBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Upload
		
		SET 	Activate_Tonight = 0
		
		WHERE 	Activate_Tonight = 1 AND 
				Deleted = 0
	</CFQUERY>
 
 	<CFQUERY NAME="ONTonightBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Upload
		
		SET 	Activate_Tonight = 1
		
		WHERE 	GL_Code_Upload_ID = #GetGL_Code_Upload_ID.GL_Code_Upload_ID#' AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFQUERY NAME="GetAllDate" DATASOURCE="#Application.Datasource#">
	SELECT DISTINCT Created_Date FROM GL_Code_Activation WHERE Current_Active_Data = 0 AND Activate_Tonight = 0 AND Deleted = 0
</CFQUERY>

<CFQUERY NAME="GetPreviousActiveDate" DATASOURCE="#Application.Datasource#">
	SELECT DISTINCT Created_Date FROM GL_Code_Activation WHERE Previous_Active_Data = 1 AND Deleted = 0
</CFQUERY>

<CFQUERY NAME="GetActiveData" DATASOURCE="#Application.Datasource#">
	SELECT * FROM GL_Code_Activation WHERE Current_Active_Data = 1 AND Deleted = 0
</CFQUERY>

<CFQUERY NAME="AnyReadyActivateTonight" DATASOURCE="#Application.Datasource#">
	SELECT 		* 
	FROM  		Gl_Code_Activation_Valid_Temp

	INNER JOIN 	GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = Gl_Code_Activation_Valid_Temp.GL_Code_Upload_ID AND
				GL_Code_Upload.Deleted = 0
				
	WHERE 		GL_Code_Upload.Activate_Tonight = 1 AND 
				Gl_Code_Activation_Valid_Temp.Deleted = 0

</CFQUERY>

<CFSET AnyReadyToActivate = 0>
<CFIF AnyReadyActivateTonight.RecordCount GT 0>
	<CFSET AnyReadyToActivate = 1>
</CFIF>

<CFQUERY NAME="GetUpdatedBy" DATASOURCE="#Application.Datasource#">
	SELECT 		Act_Data_Updated_On,
				Name_First, 
				Name_last 
				
	FROM 		GL_Code_Activation 
	INNER JOIN 	_Users ON _Users.User_ID = GL_Code_Activation.Act_Data_Updated_By AND 
				_Users.Deleted = 0
				
	WHERE 		GL_Code_Activation.Current_Active_Data = 1	AND 
				GL_Code_Activation.Deleted = 0
</CFQUERY>

<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>

<BR><BR>
<CFIF GetUpdatedBy.RecordCount GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
		<TD>
			<FONT SIZE="2"><B>
			This setting was last updated on <CFOUTPUT>#dateformat(GetUpdatedBy.Act_Data_Updated_On,'m/d/yyy')# #timeformat(GetUpdatedBy.Act_Data_Updated_On, 'h:mm:ss TT')# by #GetUpdatedBy.Name_First#  #GetUpdatedBy.Name_Last#</CFOUTPUT>
			</B></FONT>
		</TD>
	</TR>
</TABLE>
</CFIF>

<BR><BR>
<FORM NAME="ActivateThis" ACTION="index.cfm?Show_Tab=2" METHOD="POST">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0">
	<INPUT TYPE ="Hidden" NAME="formSubmitted" VALUE="0">
	<TR>
		<TD><B>Date of Previous active data:</B></TD>
		<TD><CFOUTPUT>#DATEFORMAT(GetPreviousActiveDate.Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(GetPreviousActiveDate.Created_Date,"HH:mm:ss")#</CFOUTPUT></TD>
	</TR>
	<TR>
		<TD><FONT COLOR="Red"><B>Pick Uploaded date to activate data:</B></FONT>&nbsp;</TD>
		<TD>
			<SELECT NAME="Created_Date" <CFIF AnyReadyActivateTonight.recordcount GT 0>ONCHANGE="Javascript: confirmActivation()"</CFIF>>
				<OPTION VAULE="">
				<CFOUTPUT QUERY="GetAllDate">
				<OPTION VALUE="#Created_Date#">#DateFormat(Created_Date,"mm/dd/yyyy")# #TIMEFORMAT(Created_Date,"HH:mm:ss")#</OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"make active"
				button_action	=	"validate()"
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
</TABLE>
</FORM>

<SCRIPT language="JavaScript">
function confirmActivation()
{
	var alertUser = "<CFOUTPUT>#AnyReadyToActivate#</CFOUTPUT>";
	if (alertUser == 1)
	{
		if (confirm("There is a set of data to be activated tonight. Press OK if you want to make your selection active and not the existing one"))
		{
		}
		else
		{
			document.all.Created_Date.options[0].selected = true;	
		}
	}
}
function validate()
{
	if (document.all.Created_Date.value == "")
	{
		alert("Please select a date and try again.");
		document.all.Created_Date.focus();
	}
	else
	{
		document.all.formSubmitted.value = 1;
		document.ActivateThis.submit();
	}	
}
</SCRIPT>

<BR><BR>
<CF_openLayer
	Border="Yes"
	BorderSize="1"  
	BorderColor="orange"  
	Image="/images/plus2.gif"
	ImageOpen="/images/minus2.gif"
	Title="Hide Current Active GL Code Data:"  
	TitleClosed="Show Current Active GL Code Data:"  
	TitleTooltip="Click to Show/Hide Criteria Used"  
	TitleFont="font"  
	TitleColor="Blue"  
	TitleSize="9"  
	IsClosed="Yes"  
	Width="100%">

		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="98%" CLASS="UnderLine">
			<TR bgcolor="FFE083">
				<TD><B>A/R #</B></TD>
				<TD><B>Description</B></TD>
				<TD><B>First Ship</B></TD>
				<TD><B>Last Ship</B></TD>
				<TD><B>Product Group</B></TD>
				<TD><B>IDC</B></TD>
				<TD><B>Fund</B></TD>
				<TD><B>Merch</B></TD>
				<TD><B>Pro</B></TD>
				<TD><B>Uploaded On</B></TD>
			</TR>
			<CFOUTPUT QUERY="GetActiveData">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD STYLE="font-size:10px">#A_R#&nbsp;</TD>
				<TD STYLE="font-size:10px">#A_R_DESCRIPTION#&nbsp;</TD>
				<TD STYLE="font-size:10px">#DATEFORMAT(FIRST_SHIP,"mm/dd/yyyy")#&nbsp;</TD>
				<TD STYLE="font-size:10px">#DATEFORMAT(LAST_SHIP,"mm/dd/yyyy")#&nbsp;</TD>
				<TD STYLE="font-size:10px">#PRODUCT_GROUP#&nbsp;</TD>
				<TD STYLE="font-size:10px">#IDC#&nbsp;</TD>
				<TD STYLE="font-size:10px">#FUND_TYPE#&nbsp;</TD>
				<TD STYLE="font-size:10px">#MERCH_TYPE#&nbsp;</TD>
				<TD STYLE="font-size:10px">#PRO_TERM#&nbsp;</TD>
				<TD STYLE="font-size:10px">#DATEFORMAT(Created_Date,"mm/dd/yyyy")#</TD>
			</TR>
			</CFOUTPUT>
		</TABLE>
</CF_openLayer>

<BR><BR>
<CFIF AnyReadyActivateTonight.recordcount GT 0>
	<CF_openLayer
		Border="Yes"
		BorderSize="1"  
		BorderColor="orange"  
		Image="/images/plus2.gif"
		ImageOpen="/images/minus2.gif"
		Title="Hide data Ready to be Activated Tonight:"  
		TitleClosed="Show data Ready to be Activated Tonight:"  
		TitleTooltip="Click to Show/Hide Criteria Used"  
		TitleFont="font"  
		TitleColor="Blue"  
		TitleSize="9"  
		IsClosed="Yes"  
		Width="100%">
	
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="98%" CLASS="UnderLine">
				<TR bgcolor="FFE083">
					<TD><B>A/R #</B></TD>
					<TD><B>Description</B></TD>
					<TD><B>First Ship</B></TD>
					<TD><B>Last Ship</B></TD>
					<TD><B>Product Group</B></TD>
					<TD><B>IDC</B></TD>
					<TD><B>Fund</B></TD>
					<TD><B>Merch</B></TD>
					<TD><B>Pro</B></TD>
					<TD><B>Uploaded On</B></TD>
				</TR>
				<CFOUTPUT QUERY="AnyReadyActivateTonight">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD STYLE="font-size:10px">#A_R#&nbsp;</TD>
					<TD STYLE="font-size:10px">#A_R_DESCRIPTION#&nbsp;</TD>
					<TD STYLE="font-size:10px">#DATEFORMAT(FIRST_SHIP,"mm/dd/yyyy")#&nbsp;</TD>
					<TD STYLE="font-size:10px">#DATEFORMAT(LAST_SHIP,"mm/dd/yyyy")#&nbsp;</TD>
					<TD STYLE="font-size:10px">#PRODUCT_GROUP#&nbsp;</TD>
					<TD STYLE="font-size:10px">#IDC#&nbsp;</TD>
					<TD STYLE="font-size:10px">#FUND_TYPE#&nbsp;</TD>
					<TD STYLE="font-size:10px">#MERCH_TYPE#&nbsp;</TD>
					<TD STYLE="font-size:10px">#PRO_TERM#&nbsp;</TD>
					<TD STYLE="font-size:10px">#DATEFORMAT(Created_Date,"mm/dd/yyyy")#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
	</CF_openLayer>
</CFIF>
</body>
</html>
