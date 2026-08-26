<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFPARAM NAME="URL.DataType" DEFAULT="1">

<CFPARAM NAME="FORM.DataType" DEFAULT="#URL.DataType#">
<CFPARAM NAME="FORM.FormSubmitted" DEFAULT="0">
<CFPARAM NAME="FORM.A_R_DESCRIPTION" DEFAULT="">
<CFPARAM NAME="FORM.DESCRIPTION" DEFAULT="">
<CFPARAM NAME="FORM.A_R" DEFAULT="">
<CFPARAM NAME="FORM.APPROP" DEFAULT="">
<CFPARAM NAME="FORM.Allocation" DEFAULT="">
<CFPARAM NAME="FORM.FIRST_SHIP" DEFAULT="">
<CFPARAM NAME="FORM.LAST_SHIP" DEFAULT="">
<CFPARAM NAME="FORM.COMPANY" DEFAULT="">
<CFPARAM NAME="FORM.LOCATION" DEFAULT="">
<CFPARAM NAME="FORM.COST_CENTER" DEFAULT="">
<CFPARAM NAME="FORM.NATURAL_ACCT" DEFAULT="">
<CFPARAM NAME="FORM.CHANNEL" DEFAULT="">
<CFPARAM NAME="FORM.PRODUCT_GROUP" DEFAULT="">
<CFPARAM NAME="FORM.IDC" DEFAULT="">
<CFPARAM NAME="FORM.FUND_TYPE" DEFAULT="">
<CFPARAM NAME="FORM.MERCH_TYPE" DEFAULT="">
<CFPARAM NAME="FORM.PRO_TERM" DEFAULT="">
<CFPARAM NAME="FORM.FUND_NUMBER" DEFAULT="">
<CFPARAM NAME="FORM.Current_Active_Data" DEFAULT="1">
<CFPARAM NAME="FORM.Fiscal_Year" DEFAULT="">

<CFQUERY NAME="A_R" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT A_R 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				A_R IS NOT NULL 
	ORDER BY	A_R
</CFQUERY>

<CFQUERY NAME="A_R_DESCRIPTION" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT A_R_DESCRIPTION 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				A_R_DESCRIPTION IS NOT NULL
	ORDER BY 	A_R_DESCRIPTION
</CFQUERY>

<CFQUERY NAME="APPROP" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT APPROP 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				APPROP IS NOT NULL
	ORDER BY 	APPROP
</CFQUERY>

<CFQUERY NAME="Allocation" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Allocation 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF> 
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				Allocation IS NOT NULL
	ORDER BY 	Allocation
</CFQUERY> 

<CFQUERY NAME="FIRST_SHIP" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT FIRST_SHIP 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				FIRST_SHIP IS NOT NULL
	ORDER BY 	FIRST_SHIP
</CFQUERY>

<CFQUERY NAME="LAST_SHIP" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT LAST_SHIP 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF> 
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				LAST_SHIP IS NOT NULL
	ORDER BY	LAST_SHIP
</CFQUERY>

<CFQUERY NAME="COMPANY" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT COMPANY 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				COMPANY IS NOT NULL
	ORDER BY	COMPANY
</CFQUERY>

<CFQUERY NAME="LOCATION" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT LOCATION 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				LOCATION IS NOT NULL
	ORDER BY	LOCATION
</CFQUERY>

<CFQUERY NAME="COST_CENTER" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT COST_CENTER 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				COST_CENTER IS NOT NULL
	ORDER BY	COST_CENTER
</CFQUERY>

<CFQUERY NAME="NATURAL_ACCT" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT NATURAL_ACCT 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				NATURAL_ACCT IS NOT NULL
	ORDER BY	NATURAL_ACCT
</CFQUERY>

<CFQUERY NAME="CHANNEL" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT CHANNEL 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				CHANNEL IS NOT NULL
	ORDER BY	CHANNEL
</CFQUERY>

<CFQUERY NAME="PRODUCT_GROUP" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT PRODUCT_GROUP 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				PRODUCT_GROUP IS NOT NULL
	ORDER BY	PRODUCT_GROUP
</CFQUERY>

<CFQUERY NAME="IDC" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT IDC 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				IDC IS NOT NULL
	ORDER BY	IDC
</CFQUERY>

<CFQUERY NAME="FUND_TYPE" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT FUND_TYPE 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				FUND_TYPE IS NOT NULL
	ORDER BY	FUND_TYPE
</CFQUERY>

<CFQUERY NAME="MERCH_TYPE" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT MERCH_TYPE 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				MERCH_TYPE IS NOT NULL
	ORDER BY	MERCH_TYPE
</CFQUERY>

<CFQUERY NAME="PRO_TERM" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT PRO_TERM 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				PRO_TERM IS NOT NULL
	ORDER By	PRO_TERM
</CFQUERY>

<CFQUERY NAME="FUND_NUMBER" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT FUND_NUMBER 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				FUND_NUMBER IS NOT NULL
	ORDER By	FUND_NUMBER
</CFQUERY>

<CFQUERY NAME="DESCRIPTION" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT DESCRIPTION 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
				
	WHERE 		Deleted = 0 AND 
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				DESCRIPTION IS NOT NULL
	ORDER BY	DESCRIPTION
</CFQUERY>

<cfset useLakebaseForCurrent_Active_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation")>
<cfif useLakebaseForCurrent_Active_Data>
	<cftry>
		<cfset Current_Active_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_activation", {
				"deleted" = "eq.0",
				"current_active_data" = "not.is.null",
				"select" = "current_active_data"
			}), "current_active_data"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCurrent_Active_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCurrent_Active_Data>
<CFQUERY NAME="Current_Active_Data" DATASOURCE="#Application.Datasource#">
	SELECT DISTINCT Current_Active_Data FROM GL_Code_Activation WHERE Deleted = 0 AND Current_Active_Data IS NOT NULL
</CFQUERY>
</cfif>

<CFQUERY NAME="GetFicalYear" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT(Fiscal_Year) 
	
	FROM 		<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp 
				<CFELSE>
					GL_Code_Activation
				</CFIF>
	INNER JOIN	GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = <CFIF URL.DataType EQ 4>Gl_Code_Activation_Valid_Temp.GL_Code_Upload_ID<CFELSE>GL_Code_Activation.GL_Code_Upload_ID</CFIF>	
	WHERE 		GL_Code_Upload.Deleted = 0 AND
				<CFIF URL.DataType EQ 1>
					Current_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 2>
					Previous_Active_Data = 1 AND
				<CFELSEIF URL.DataType EQ 3>
					Current_Active_Data = 0 AND 
				</CFIF>
				<CFIF URL.DataType EQ 4>
					Gl_Code_Activation_Valid_Temp.Deleted = 0 
				<CFELSE>
					GL_Code_Activation.Deleted = 0
				</CFIF>				
	ORDER BY	Fiscal_Year
</CFQUERY>


<SCRIPT language="JavaScript">
function ChangeData(Type)
{
	
	window.location.href = "index.cfm?Show_Tab=1&DataType=" + Type;
	
}
</SCRIPT>

<FORM NAME="GlSearch" ACTION ="index.cfm?Show_Tab=1" METHOD="POST">
<INPUT TYPE="Hidden" NAME="FormSubmitted" VALUE="0">
<INPUT TYPE="Hidden" NAME="FORM.DataType" VALUE="#FORM.DataType#">

	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>
				<INPUT TYPE="radio" NAME="Data_Type" VALUE="1" <CFIF URL.DataType EQ 1>CHECKED</CFIF> ONCLICK="Javascript: ChangeData('1')"><B><FONT COLOR="red" SIZE="2">Active</FONT></B>&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Data_Type" VALUE="2" <CFIF URL.DataType EQ 2>CHECKED</CFIF> ONCLICK="Javascript: ChangeData('2')"><B><FONT COLOR="red" SIZE="2">Previous Active</FONT></B>&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Data_Type" VALUE="3" <CFIF URL.DataType EQ 3>CHECKED</CFIF> ONCLICK="Javascript: ChangeData('3')"><B><FONT COLOR="red" SIZE="2">Inactive</FONT></B>&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Data_Type" VALUE="4" <CFIF URL.DataType EQ 4>CHECKED</CFIF> ONCLICK="Javascript: ChangeData('4')"><B><FONT COLOR="red" SIZE="2">Tonight's upload</FONT></B>&nbsp;&nbsp;
			</TD>
		</TR>
	</TABLE>
<BR>
<!--- <FIELDSET STYLE="padding:8px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">GL Code search</LEGEND> --->
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" STYLE="border-left: 1px solid Blue;border-right: 1px solid Blue;border-top: 1px solid Blue;border-bottom: 1px solid Blue;">		
		<TR>					
			<TD COLSPAN="3">&nbsp;&nbsp;&nbsp;
				<B>A/R Description</B>
				<BR>&nbsp;&nbsp;&nbsp;
				<SELECT NAME="A_R_DESCRIPTION" STYLE="WIDTH: 270px;">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="A_R_DESCRIPTION">
						<OPTION VALUE="#A_R_DESCRIPTION#" <CFIF FORM.A_R_DESCRIPTION EQ A_R_DESCRIPTION>SELECTED</CFIF>>#A_R_DESCRIPTION#</OPTION>
					</CFOUTPUT>
				</SELECT>	
			</TD>
			<TD COLSPAN="3">
				<B>Description</B>
				<BR>
				<SELECT NAME="DESCRIPTION" STYLE="WIDTH: 270px;">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="DESCRIPTION">
						<OPTION VALUE="#DESCRIPTION#" <CFIF FORM.DESCRIPTION EQ DESCRIPTION>SELECTED</CFIF>>#DESCRIPTION#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>	
			<TD>
				<B>A/R</B>
				<BR>
				<SELECT NAME="A_R" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="A_R">
						<OPTION VALUE="#A_R#" <CFIF FORM.A_R EQ A_R>SELECTED</CFIF>>#A_R#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Approp</B>
				<BR>
				<SELECT NAME="APPROP" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="APPROP">
						<OPTION VALUE="#APPROP#" <CFIF FORM.APPROP EQ APPROP>SELECTED</CFIF>>#APPROP#</OPTION>
					</CFOUTPUT>
				</SELECT>&nbsp;&nbsp;&nbsp;
			</TD>			
		</TR>
		<TR>
			<TD>&nbsp;&nbsp;&nbsp;
				<B>Allocation</B>
				<BR>&nbsp;&nbsp;&nbsp;
				<SELECT NAME="Allocation" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="Allocation">
						<OPTION VALUE="#Allocation#" <CFIF FORM.Allocation EQ Allocation>SELECTED</CFIF>>#Allocation#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>First Ship</B>
				<BR>
				<SELECT NAME="FIRST_SHIP" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="FIRST_SHIP">
						<OPTION VALUE="#FIRST_SHIP#" <CFIF FORM.FIRST_SHIP EQ FIRST_SHIP>SELECTED</CFIF>>#DATEFORMAT(FIRST_SHIP,"mm/dd/yyyy")#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Last Ship</B>
				<BR>
				<SELECT NAME="LAST_SHIP" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="LAST_SHIP">
						<OPTION VALUE="#LAST_SHIP#" <CFIF FORM.LAST_SHIP EQ LAST_SHIP>SELECTED</CFIF>>#DATEFORMAT(LAST_SHIP,"mm/dd/yyyy")#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Company</B>
				<BR>
				<SELECT NAME="COMPANY" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="COMPANY">
						<OPTION VALUE="#COMPANY#" <CFIF FORM.COMPANY EQ COMPANY>SELECTED</CFIF>>#COMPANY#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Location</B>
				<BR>
				<SELECT NAME="LOCATION" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="LOCATION">
						<OPTION VALUE="#LOCATION#" <CFIF FORM.LOCATION EQ LOCATION>SELECTED</CFIF>>#LOCATION#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Cost Center</B>
				<BR>
				<SELECT NAME="COST_CENTER" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="COST_CENTER">
						<OPTION VALUE="#COST_CENTER#" <CFIF FORM.COST_CENTER EQ COST_CENTER>SELECTED</CFIF>>#COST_CENTER#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Natural Acct</B>
				<BR>
				<SELECT NAME="NATURAL_ACCT" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="NATURAL_ACCT">
						<OPTION VALUE="#NATURAL_ACCT#" <CFIF FORM.NATURAL_ACCT EQ NATURAL_ACCT>SELECTED</CFIF>>#NATURAL_ACCT#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Channel</B>
				<BR>
				<SELECT NAME="CHANNEL" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="CHANNEL">
						<OPTION VALUE="#CHANNEL#" <CFIF FORM.CHANNEL EQ CHANNEL>SELECTED</CFIF>>#CHANNEL#</OPTION>
					</CFOUTPUT>
				</SELECT>&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<TR>			
			<TD>&nbsp;&nbsp;&nbsp;
				<B>Product Group</B>
				<BR>&nbsp;&nbsp;&nbsp;
				<SELECT NAME="PRODUCT_GROUP" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="PRODUCT_GROUP">
						<OPTION VALUE="#PRODUCT_GROUP#" <CFIF FORM.PRODUCT_GROUP EQ PRODUCT_GROUP>SELECTED</CFIF>>#PRODUCT_GROUP#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>IDC</B>
				<BR>
				<SELECT NAME="IDC" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="IDC">
						<OPTION VALUE="#IDC#" <CFIF FORM.IDC EQ IDC>SELECTED</CFIF>>#IDC#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Fund Type</B>
				<BR>
				<SELECT NAME="FUND_TYPE" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="FUND_TYPE">
						<OPTION VALUE="#FUND_TYPE#" <CFIF FORM.FUND_TYPE EQ FUND_TYPE>SELECTED</CFIF>>#FUND_TYPE#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Merch Type</B>
				<BR>
				<SELECT NAME="MERCH_TYPE" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="MERCH_TYPE">
						<OPTION VALUE="#MERCH_TYPE#" <CFIF FORM.MERCH_TYPE EQ MERCH_TYPE>SELECTED</CFIF>>#MERCH_TYPE#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Pro Term</B>
				<BR>
				<SELECT NAME="PRO_TERM" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="PRO_TERM">
						<OPTION VALUE="#PRO_TERM#" <CFIF FORM.PRO_TERM EQ PRO_TERM>SELECTED</CFIF>>#PRO_TERM#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			<TD>
				<B>Fund #</B>
				<BR>
				<SELECT NAME="FUND_NUMBER" STYLE="Width:80px">
					<OPTION VALUE="">
					<CFOUTPUT QUERY="FUND_NUMBER">
						<OPTION VALUE="#FUND_NUMBER#" <CFIF FORM.FUND_NUMBER EQ FUND_NUMBER>SELECTED</CFIF>>#FUND_NUMBER#</OPTION>
					</CFOUTPUT>
				</SELECT>
			</TD>
			
			<TD COLSPAN="2">
				<B>Fiscal Year</B>
				<BR>
				<SELECT NAME="Fical_Year">
					<OPTION VALUE=""></OPTION>
					<CFOUTPUT QUERY="GetFicalYear">
						<OPTION VALUE="#Fiscal_Year#" <CFIF FORM.Fiscal_Year EQ Fiscal_Year>SELECTED</CFIF>>#Fiscal_Year#</OPTION> 
					</CFOUTPUT>
				</SELECT>&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="Right">
				<B>
				<FONT SIZE="2" COLOR="red">[ </FONT><A Href="##" ONCLICK="Javascript: validate()">search GL Code</A><FONT SIZE="2" COLOR="red"> ]</FONT>&nbsp;&nbsp;&nbsp;	
				<FONT SIZE="2" COLOR="red">[ </FONT><A Href="##" ONCLICK="Javascript: resetform()">reset</A><FONT SIZE="2" COLOR="red"> ]</FONT>
				</B>&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>		
	</TABLE>
<!--- </FIELDSET> --->
</FORM>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
<SCRIPT language="JavaScript">
function validate()
{
	document.all.FormSubmitted.value=1;
	document.all.GlSearch.submit()
}
	
function resetform()
{
	resetSelect("A_R_DESCRIPTION");
	resetSelect("DESCRIPTION");
	resetSelect("A_R");
	resetSelect("APPROP");
	resetSelect("Allocation");
	resetSelect("FIRST_SHIP");
	resetSelect("LAST_SHIP");
	resetSelect("COMPANY");
	resetSelect("LOCATION");
	resetSelect("COST_CENTER");
	resetSelect("NATURAL_ACCT");
	resetSelect("CHANNEL");
	resetSelect("PRODUCT_GROUP");
	resetSelect("IDC");
	resetSelect("FUND_TYPE");
	resetSelect("MERCH_TYPE");
	resetSelect("PRO_TERM");
	resetSelect("FUND_NUMBER");
	resetSelect("Current_Active_Data");
}

function resetSelect(selName)
{
	var sObj = document.getElementById(selName);
	if(sObj)
	{
		sObj.selectedIndex = 0;
		callfireEvent(document,sObj,'Change');
	}
}
</SCRIPT> 


<CFQUERY NAME="GetGLData" DATASOURCE="#Application.Datasource#">
	SELECT 	<CFIF FORM.DataType EQ 4>
			Gl_Code_Activation_Valid_Temp.*, 
			<CFELSE>
			GL_Code_Activation.*,			
			</CFIF>
			Fiscal_Year			
			
	FROM 	<CFIF FORM.DataType EQ 4>
			Gl_Code_Activation_Valid_Temp 
			<CFELSE>
			GL_Code_Activation
			</CFIF>
	INNER JOIN GL_Code_Upload ON GL_Code_Upload.GL_Code_Upload_ID = <CFIF URL.DataType EQ 4>Gl_Code_Activation_Valid_Temp.GL_Code_Upload_ID<CFELSE>GL_Code_Activation.GL_Code_Upload_ID</CFIF>	
	WHERE	1 = 1 AND
			<CFIF URL.DataType EQ 1>
				Current_Active_Data = 1 AND
			<CFELSEIF URL.DataType EQ 2>
				Previous_Active_Data = 1 AND
			<CFELSEIF URL.DataType EQ 3>
				Current_Active_Data = 0 AND 
			</CFIF>
			<CFIF FORM.A_R_DESCRIPTION NEQ "">
				A_R_DESCRIPTION = '#FORM.A_R_DESCRIPTION#' AND
			</CFIF>
			<CFIF FORM.DESCRIPTION NEQ "">
				DESCRIPTION = '#FORM.DESCRIPTION#' AND
			</CFIF>
			<CFIF FORM.A_R NEQ "">
				A_R = '#FORM.A_R#' AND
			</CFIF>
			<CFIF FORM.APPROP NEQ "">
				APPROP = '#FORM.APPROP#' AND
			</CFIF>
			<CFIF FORM.Allocation NEQ "">
				Allocation = '#FORM.Allocation#' AND
			</CFIF>
			<CFIF FORM.FIRST_SHIP NEQ "">
				FIRST_SHIP = '#FORM.FIRST_SHIP#' AND
			</CFIF>
			<CFIF FORM.LAST_SHIP NEQ "">
				LAST_SHIP = '#FORM.LAST_SHIP#' AND
			</CFIF>
			<CFIF FORM.COMPANY NEQ "">
				COMPANY = '#FORM.COMPANY#' AND
			</CFIF>
			<CFIF FORM.LOCATION NEQ "">
				LOCATION = '#FORM.LOCATION#' AND
			</CFIF>
			<CFIF FORM.COST_CENTER NEQ "">
				COST_CENTER = '#FORM.COST_CENTER#' AND
			</CFIF>
			<CFIF FORM.NATURAL_ACCT NEQ "">
				NATURAL_ACCT = '#FORM.NATURAL_ACCT#' AND
			</CFIF>
			<CFIF FORM.CHANNEL NEQ "">
				CHANNEL = '#FORM.CHANNEL#' AND
			</CFIF>
			<CFIF FORM.PRODUCT_GROUP NEQ "">
				PRODUCT_GROUP = '#FORM.PRODUCT_GROUP#' AND
			</CFIF>
			<CFIF FORM.IDC NEQ "">
				IDC = '#FORM.IDC#' AND
			</CFIF>
			<CFIF FORM.FUND_TYPE NEQ "">
				FUND_TYPE = '#FORM.FUND_TYPE#' AND
			</CFIF>
			<CFIF FORM.MERCH_TYPE NEQ "">
				MERCH_TYPE = '#FORM.MERCH_TYPE#' AND
			</CFIF>
			<CFIF FORM.PRO_TERM NEQ "">
				PRO_TERM = '#FORM.PRO_TERM#' AND
			</CFIF>
			<CFIF FORM.FUND_NUMBER NEQ "">
				FUND_NUMBER = '#FORM.FUND_NUMBER#' AND
			</CFIF>
			<CFIF FORM.Fiscal_Year NEQ "">
				Fiscal_Year = '#FORM.Fiscal_Year#' AND
			</CFIF>
			1 = 1 
</CFQUERY>

<BR>
<STYLE>
TABLE.UnderLine TD
{
	border-bottom: 1px #93BEE2 solid; 
}
</STYLE>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD><B><FONT SIZE="2" COLOR="Navy">There<CFIF GetGLData.recordcount EQ 0> Are No Documents <CFELSEIF GetGLData.recordcount EQ 1> Is A <CFELSE> Are <CFOUTPUT>#GetGLData.recordcount#</CFOUTPUT> GL Code Data</CFIF> That Match This Criteria</FONT></B></TD>
	</TR>
</TABLE>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" width="100%" CLASS="UnderLine">
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
	<CFOUTPUT QUERY="GetGLData">
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

</body>
</html>
