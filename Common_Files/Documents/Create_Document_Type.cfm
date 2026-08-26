<CFSET URL.PageTitle="PROGRAMS: Document Type List Management">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"><BR/><!--- Dev Note: KAL; D7432 --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGetDocType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
<cfif useLakebaseForGetDocType>
	<cftry>
		<cfset Get_Doc_type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_type", { "order" = "doc_type.asc" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDocType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDocType>
	<CFQUERY NAME="Get_Doc_type" datasource="#application.datasource#">
		Select		*
		From		Document_type
		Order by	Doc_Type
	</CFQUERY>
</cfif>

<!--- <B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
			<FONT SIZE="2" COLOR="Blue">
				
					<!--- <A HREF="/help_files/manual/projects/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Project Status"> --->
						read me first
					<!--- </A> --->
				
			</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B> --->
<BR>
		
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">

				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Doc_type">
					<TR>
						<TD NOWRAP><A HREF="create_Document_Type.cfm?RID=#Doc_Type_ID#">#Doc_Type#</A></TD>
						<TD NOWRAP>

								<CFIF Deleted EQ 0>
								<IMG SRC="/images/yes_small.gif" TITLE="active record...">
								<CFELSE>
								<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
								</CFIF>
						</TD>
					</TR>
					</CFOUTPUT>
				</TABLE>

				<BR>

				<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record<BR>
				
			</TD>
			<TD VALIGN="top">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="Get_Item.Doc_Type" DEFAULT="">
<CFPARAM NAME="Get_Item.Doc_Type_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">

<cfset useLakebaseForGetItem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
<cfif useLakebaseForGetItem>
	<cftry>
		<cfset Get_Item = application.oLakebase.toQuery(
			application.oLakebase.selectRows("document_type", { "doc_type_id" = "eq.#URL.RID#" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetItem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetItem>
	<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
		Select		*
		From		Document_Type
		Where		Doc_type_ID	= '#URL.RID#'
	</CFQUERY>
</cfif>

<SCRIPT language="JavaScript">
function alert_and_delete()
{
	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}
			
}	
</SCRIPT>

			<FORM ACTION="save_Document_Type.cfm" METHOD="post" NAME="MyForm">
				<TABLE CELLSPACING="5" CELLPADDING="0">
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Document Type</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="45" NAME="Doc_Type" VALUE="#Get_Item.Doc_type#" MAXLENGTH="50">
								<INPUT TYPE="hidden" NAME="Doc_Type_ID" VALUE="#Get_Item.Doc_Type_ID#">
							</CFOUTPUT>
						</TD>
					</TR>					
					<TR>
						<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
						<TD VALIGN="top">

					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- Get the number of projects that have this status: If there is at least 1 project that is active and has this status, then I will not allow the user to delete this status --->
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

					<CFQUERY NAME="Get_Count" datasource="#application.datasource#">
					Select count(*) as doc_type_count from Document_Type where Deleted = 0
					</CFQUERY>
					
					<CFIF Get_Count.Doc_Type_count NEQ 1>
						<CFPARAM NAME="disabled" DEFAULT="">
					<CFELSE>
						<CFPARAM NAME="disabled" DEFAULT="disabled">
					</CFIF>	 

						<!--- Is this record deleted? --->
						<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>

						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive# #disabled#>Inactive (*)
						</CFOUTPUT>						

						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right"></TD>
						<TD VALIGN="top">
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: document.MyForm.submit()"><B>save data</B></A>
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							
							<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
							<CFIF Get_Item.Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>
							<p></p>
							(*) A disabled "inactive" choice indicates that there is at least one active project that has this status. Thus, the user will not be able to make this status inactive.

						</TD>
						
						
					</TR>
				</TABLE>
				
			</FORM>
				
			</TD>
		</TR>
	</TABLE>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_Document_Type.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="create_Document_Details.cfm"><B>back to manage documents</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
				