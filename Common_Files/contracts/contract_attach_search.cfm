<!---
	Name: contract_attach_search.cfm        
	Copyright (c) 2006 Blacksmith Applications, Inc.              
	Description:
		Used to search and attach documents to contracts
	Modified By: Clarence Morse 3/24/2006
	Purpose: filtering welcome letters from returned documents.  
--->	
<CFSET A_Header_Value_List = "Uploaded_Date,Uploaded_By,Doc_File_Name,Doc_Title,Doc_Description,Doc_Type,Public_View"><!---Doc_Description,Uploaded_By,Doc_Family  --->
<CFSET A_Header_Name_List = "Date,Name,File,Title,Description,Type,Privacy">

<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
	<TR ID="header" BGCOLOR="ffce84" VALIGN="top">
		<TD ID="header">
			<input TYPE="checkbox" NAME="allbox" onclick="javaScript: selectAll(this);">
		</TD>
		<CFOUTPUT>
		<CFSET Counter = 1>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>
			<CFIF LCase(ThisHeaderItemName) NEQ "name" AND LCase(ThisHeaderItemName) NEQ "description" AND LCase(ThisHeaderItemName) NEQ "privacy">
			<TD ID="header">
			<CFELSE>
			<BR>
			</CFIF>
			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>
			<CFIF LCase(ThisHeaderItemName) NEQ "date" AND LCase(ThisHeaderItemName) NEQ "title" AND LCase(ThisHeaderItemName) NEQ "type">
			</TD>
			</CFIF>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>	

	<CFSET This_Page_List = "">
	<CFSET disabled = "">
	<CFOUTPUT QUERY="ret_data" startrow="#StartRow#" maxrows="#MaxRows#">
 		<CFSET This_Page_List = ListAppend(This_Page_List, Doc_ID, ",")>

	<!--- <CFLOOP QUERY="ret_data"> --->

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<CFSET comp_doc_ID = #doc_ID#>			
			<TD WIDTH="3%">
			<!------<span ID="chkBoxCol"><input TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" <CFLOOP query = "Current_sel"><CFIF comp_Doc_ID EQ doc_iD>checked</CFIF></CFLOOP>></span>----->
			<input TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" <CFIF ListFindNoCase(Current_Selection_List, comp_Doc_ID, ",")>CHECKED</CFIF>>
			</TD>
			<CFSET SIZEinMB = #Doc_size#/1024>
			<CFQUERY NAME="sel_Name" DATASOURCE="#Application.Datasource#">
				SELECT Name_First, Name_Last FROM _Users 
				RIGHT JOIN Document_Details ON Document_Details.Uploaded_By = _users.User_ID 
				WHERE DOC_ID = '#Doc_ID#'
				AND Is_Welcome_Letter = 0
			</CFQUERY>
			<TD WIDTH="13%">#dateformat(Uploaded_Date,"mm/dd/yyyy")#<br>#Sel_Name.Name_First# #Sel_Name.Name_Last#&nbsp;</TD>
			<TD NOWRAP TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
				<CFSET Display_Name=Left(Doc_File_Name,20)>
				<CFIF len(trim(Doc_File_Name)) GT 20>
					#LCASE(Display_Name)#...
				<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
					&nbsp;
				<CFELSE>
					#LCASE(Display_Name)#	
				</CFIF>		
				</A><BR>#numberformat(SIZEinMB,"_.___")# KB&nbsp;</TD>			
			<TD WIDTH="58%">#Doc_Title#<br>Description: #Doc_Description#&nbsp;</TD>
			<TD WIDTH="12%">#Doc_Type#<br><cfif #Public_View# EQ 1> Yes <cfelse> No</cfif>&nbsp;</TD>
		</TR>
	</CFOUTPUT>

	
</TABLE>
<INPUT TYPE="Hidden" NAME="This_Page_List" VALUE="<CFOUTPUT>#This_Page_List#</CFOUTPUT>">

