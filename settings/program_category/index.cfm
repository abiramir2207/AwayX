<!---
***********************************************************************
Author: Milan Mushran
Filename: Index.cfm
Purpose: For Adding program categories
Custom Tag/s: None
Include Files: settings/settings_title.cfm
Date Created: 10/04/2005
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>program Category</title>
	<CF_MessageWindow>
	<script language="javascript">
		function CheckForm()
		{
			var ErrorCount = 0;
			if(document.MyForm.Category_Name.value == '')
				{
					ErrorCount++;
					queueMessage("You must enter a category.", document.all.error_Category);
				}
			else
				{
					clearQueue(document.all.error_Category);
				}

					if(ErrorCount == 0) 
					{				
						MyForm.submit();
					}
					else 
					{
						showMessageWindow();
					}
		}
	</script>

</head>

<body>

<CFSET URL.PageTitle="Program Category">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY NAME="Get_Category_Info" datasource="#application.datasource#">
	SELECT	Program_Category, Program_Category_ID, Deleted
	FROM		Program_Category
	ORDER BY Deleted
</CFQUERY>

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="765">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Category Name</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Category_Info">
					<TR>
						<TD NOWRAP><A HREF="Index.cfm?RID=#Program_Category_ID#">#Program_Category#</TD>
						<TD NOWRAP>
								<CFIF deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>
				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" TITLE="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" TITLE="" ALIGN="middle"> - inactive record
				
			</TD>
			<TD VALIGN="top" WIDTH="470">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">

<CFQUERY NAME="Get_Category" datasource="#application.datasource#">
	SELECT		Program_Category, Program_Category_ID, Deleted
	FROM		Program_Category
	WHERE		Program_Category_ID ='#URL.RID#'
</CFQUERY>

<CFPARAM NAME="Get_Category.Category_Name" DEFAULT="">
		
			<FORM ACTION="Save_Program_Category.cfm" METHOD="post" NAME="MyForm"> 
				<CFOUTPUT><INPUT TYPE="hidden" NAME="Program_Category_ID" VALUE="#Get_Category.Program_Category_ID#"></CFOUTPUT>
				<TABLE CELLSPACING="0" CELLPADDING="2">
					<TR><span id="error_Category"></span>
						<TD VALIGN="top" ALIGN="right"><B>Category Name</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="45" NAME="Category_Name" VALUE="#Get_Category.Program_Category#">							
							</CFOUTPUT>
						</TD>
					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Status</B></TD>
						<TD VALIGN="top">

					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<!--- Is this record deleted? --->
						<CFIF Get_Category.Deleted EQ 0>
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive (*)
						</CFOUTPUT>
						
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A href="javascript:CheckForm();"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Index.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>



</body>
</html>
