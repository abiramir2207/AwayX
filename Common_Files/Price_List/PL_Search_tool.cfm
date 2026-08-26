<CFSET PAGE_TITLE="Price List Search">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<SCRIPT language="JavaScript">
function resetform()
{
	var x=document.Search_form;
	x.Price_List_ID.value="";
	x.Description.value="";
	x.PL_Type.value="1";
}
function submitthis()
{
	var x=document.Search_form
	var checknull=1;
	/*if (x.Price_List_ID.value != "")
	{
		checknull=0;
	}
	if (x.Description.value != "")
	{
		checknull=0;
	}
	if (checknull==1)
	{
		alert("Please select atleast one listed below as search criteria to search price list.\n\n \t1. Description \n \t2. Price List ID");
	}
	else
	{valuelist
		document.Search_form.submit();
	}*/document.Search_form.submit();
}
function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.Search_form;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}
</SCRIPT>
<STYLE>
	TABLE.LINED TD
	{	
		border-bottom:solid #93BEE2 1px;
	}
</STYLE>

<CFPARAM NAME="FORM.Price_List_ID" DEFAULT="">
<CFPARAM NAME="FORM.Description" DEFAULT="">
<CFPARAM NAME="FORM.PL_Type" DEFAULT="">

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">

<TABLE ALIGN="Center" WIDTH="598">
	<TR>
		<TD Align="Right">
			<B>
			<FONT SIZE="2" COLOR="Red">[</FONT>
			<A Href="/Common_Files/Price_List/Price_List_Scorecard_Main.cfm" TITLE="View Price List"><FONT SIZE="2">Price List Scorecard</FONT></A>
			<FONT SIZE="2" COLOR="Red">]</FONT>
			</B>
		</TD>
	</TR>
</TABLE>

<CFOUTPUT>
<FORM NAME="Search_form" ACTION="PL_Search_Tool.cfm" METHOD="POST">
	<cfparam name="FORM.startrow"  default="1">
   	<cfparam name="FORM.frompage"   default="1">
   	<cfparam name="FORM.pageLength"  default=12>
   	<cfset startrow=FORM.startrow>
   	<cfset frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">

	<cfoutput>
   	<input type="hidden" value = "#FORM.frompage#" name="frompage">
	<input type="hidden" value = "#FORM.StartRow#" name="startrow">	
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
	<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
	</cfoutput>
	
<INPUT TYPE="Hidden" NAME="Form_Sumitted" VALUE="1">

<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="598" ALIGN="center" STYLE="border-bottom:solid Navy 1px; border-Left:solid Navy 1px;border-Top:solid Navy 1px; border-right:solid Navy 1px;">
	<TR>
		<TD WIDTH="15%" ALIGN="Right"><BR><B>Description:</B></TD>
		<TD COLSPAN="3"><BR><INPUT TYPE="Text" NAME="Description" VALUE="#FORM.Description#" SIZE="90"></TD>
	</TR>
	<TR>
		<TD ALIGN="Right"><B>Price List ID:</B></TD>
		<TD WIDTH="15%"><INPUT TYPE="Text" NAME="Price_List_ID" VALUE="#FORM.Price_List_ID#" SIZE="9"></TD>
		<TD ALIGN="Right" WIDTH="31%">
			<CFIF Get_Profile_Settings.Special_Price_List_Access EQ 1>
			<B>Price List Type:</B>&nbsp;			
			<SELECT NAME="PL_Type">
			<OPTION VALUE="1" <CFIF FORM.PL_Type EQ "" OR FORM.PL_Type EQ 1>SELECTED</CFIF>>Regular</OPTION>			
			<OPTION VALUE="2" <CFIF FORM.PL_Type EQ 2>SELECTED</CFIF>>Special</OPTION>			
			</SELECT>			
			</CFIF>&nbsp;
			</TD>
		<TD ALIGN="Right"><B><FONT SIZE="2" COLOR="red">[</FONT><FONT SIZE="2"><A HREF="Javascript: resetform();">reset form</A></FONT><FONT SIZE="2" COLOR="red">]</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<FONT SIZE="2" COLOR="red">[</FONT><FONT SIZE="2"><A HREF="Javascript: submitthis();">search price list</A></FONT><FONT SIZE="2" COLOR="red">]</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>			
	</TR>
	<TR>
		<TD COLSPAN="4"><BR></TD>
	</TR>
</TABLE>
<BR>
<CFSET A_Header_Value_List = "Price_List_ID,Price_List_Description"><!--- ,Created_Date ---><!---Doc_Description,Uploaded_By,Doc_Family  --->
<CFSET A_Header_Name_List = "Price List,Description"><!--- ,Active Date --->
<CFSET Header_Width_List = "100,400,100">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="598" ALIGN="center" CLASS="LINED">
	<TR BGCOLOR="FFE083">
		<!--- <TD WIDTH="100"><B>Price List</B></TD>
		<TD WIDTH="400"><B>Description</B></TD>
		<TD WIDTH="100"><B>Active Date</B></TD> --->
		<CFOUTPUT>
		<CFSET Counter = 1>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET This_Width = ListGetAt(Header_Width_List, Counter, ",")>
			<CFSET thisSortOrder = "ASC">
			<CFSET Image_Name = "/Images/down_1.gif">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>
			<CFIF ThisHeaderItem EQ FORM.SORT_BY>
				<CFIF FORM.SORT_ORDER EQ "ASC">
					<CFSET thisSortOrder = "DESC">
					<CFSET Image_Name = "/Images/up_1.gif">
				</CFIF>
			</CFIF>
			<TD ID="header" width="#This_Width#">	
			<CFIF ThisHeaderItemName NEQ "Active Date">
			<A HREF="##" onClick="javaSCript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>			
			<CFELSE>
			<B>#ThisHeaderItemName#</B>
			</CFIF> 		
			</TD>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>
</TABLE>

</CFOUTPUT>

<CFIF isdefined("FORM.Form_Sumitted")>
<CFOUTPUT>

<CFSWITCH EXPRESSION="#FORM.SORT_BY#">
	<CFCASE VALUE="Price_List_ID,Price_List_Description,Created_Date" DELIMITERS=",">
		<CFIF FORM.PL_Type EQ 1>
			<CFSET FORM.SORT_BY = FORM.SORT_BY>
		<CFELSE>
			<CFIF FORM.SORT_BY EQ "Price_List_ID">
				<CFSET FORM.SORT_BY = "Ship_To">
			<CFELSEIF FORM.SORT_BY EQ "Price_List_Description">
				<CFSET FORM.SORT_BY = "Description">
			<CFELSE>
				<CFSET FORM.SORT_BY = FORM.SORT_BY>
			</CFIF>
		</CFIF>
	</CFCASE>
	<CFDEFAULTCASE>
		<CFSET FORM.SORT_BY = "Price_List_ID">
	</CFDEFAULTCASE>
</CFSWITCH>

<CFIF FORM.SORT_ORDER NEQ "DESC">
	<CFSET FORM.SORT_ORDER = "ASC">
</CFIF>
	
<CFIF FORM.PL_Type EQ 1>
	<CFQUERY NAME="Search_Record" DATASOURCE="#Application.Datasource#">
		SELECT 		Price_List_Description 	Description,
					Price_List_ID			Price_List_ID,
					Created_Date			Active_Date
						
		FROM 		Price_List_Header
		
		WHERE 		1=1 AND
					<CFIF FORM.Description NEQ "">
						Price_List_Description LIKE '%#FORM.Description#%' AND
					</CFIF>
					<CFIF FORM.Price_List_ID NEQ "">
						Price_List_ID LIKE '%#FORM.Price_List_ID#%' AND
					</CFIF>
					2=2
		ORDER BY	#FORM.SORT_BY# #FORM.SORT_ORDER#			
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Search_Record" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT	<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
								Ship_To Price_List_ID,
								<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
								Price_List_ID,
								<cfelse>		
								Price_List_ID,	
								</cfif>
								<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
								Description
								<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
								Price_List_Description 	
								<cfelse>Price_List_Description</cfif> AS Description																
						
		FROM 		Price_List_Header_Special
		
		WHERE 		1=1 AND
					<CFIF FORM.Description NEQ "">
						<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">
						Description LIKE '%#FORM.Description#%' AND
						<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
						Price_List_Description LIKE '%#FORM.Description#%' AND
						<cfelse>
						Price_List_Description LIKE '%#FORM.Description#%' AND
						</cfif>						
					</CFIF>
					<CFIF FORM.Price_List_ID NEQ "">						
						<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">						
						Ship_To LIKE '%#FORM.Price_List_ID#%' AND
						<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
						Price_List_ID LIKE '%#FORM.Price_List_ID#%' AND
						<cfelse>
						Price_List_ID LIKE '%#FORM.Price_List_ID#%' AND
						</cfif>											
						
					</CFIF>
					2=2
		ORDER BY	#FORM.SORT_BY#	#FORM.SORT_ORDER#					
	</CFQUERY>
	 
</CFIF>
</CFOUTPUT>


<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="598" ALIGN="center" CLASS="LINED">
	<!--- <TR BGCOLOR="FFE083">
		<TD WIDTH="100"><B>Price List</B></TD>
		<TD WIDTH="400"><B>Description</B></TD>
		<TD WIDTH="100"><B>Active Date</B></TD>
	</TR> --->
	<CFOUTPUT QUERY="Search_Record" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfif FORM.PL_Type eq 1>
			<cfquery name="check_data" datasource="#Application.Datasource#">
				SELECT 		top 1 *  
			
				FROM 		Price_List_Detail 
		
				WHERE 		Price_List_ID = '#Price_List_ID#' AND Active_Code = 'A' AND 
							CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
							End_Date >= CONVERT(Char(10),getdate(),101)
				ORDER BY	Price_List_ID
			</cfquery>
		<cfelse>
			<CFQUERY NAME="Guid_List" DATASOURCE="#Application.Datasource#">
				SELECT 	Price_List_Header_Special_ID 
				FROM 	Price_List_Header_Special 
				
				WHERE 	<cfif application.returned_customer_setting.Customer_Keyword EQ "Resers">						
						Ship_To = '#Price_List_ID#'
						<cfelseif application.returned_customer_setting.Customer_Keyword EQ "conagra">
						Price_List_ID = '#Price_List_ID#'
						<cfelse>
						Price_List_ID = '#Price_List_ID#'
						</cfif>	
				
				
			</CFQUERY>
			<CFSET ListOfGuid = VALUELIST(Guid_List.Price_List_Header_Special_ID)>
			<CFSET ListOfGuid = LISTQUALIFY(ListOfGuid,"'",",","All")>
			
			<!--- <CFQUERY NAME="Get_Created_Date" DATASOURCE="#Application.Datasource#">
				SELECT Top 1 Created_Date 
				FROM <CFIF FORM.PL_Type EQ 1>
						Price_List_Header
					<CFELSE>
						Price_List_Header_Special
					</CFIF>
				WHERE Price_List_ID = #Price_List_ID#
			</CFQUERY> --->
			<cfquery name="Check_data" datasource="#Application.Datasource#">
			SELECT 		top 1 * 
			FROM 		Price_List_Detail_Special
	
			WHERE 		Price_List_Header_Special_ID IN (#PRESERVESINGLEQUOTES(ListOfGuid)#) AND Active_Code = 'A' AND 
						CONVERT(Char(10),Start_Date,101) <= CONVERT(Char(10),getdate(),101) AND 
						End_Date >= Convert(Char(10),getdate(),101)
			</cfquery>
		</cfif>
	<TR  BGCOLOR="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#" >
		<TD WIDTH="100" <CFIF Check_Data.Recordcount EQ 0>TITLE="No details available for this price list."</CFIF>>
			<CFIF Check_Data.Recordcount GT 0>
				<B>
				<FONT SIZE="2" COLOR="Red">[</FONT>
				<A HREF="Price_List_Detail.cfm?type=#FORM.PL_Type#&PL_ID=#Price_List_ID#&Descp=#HTMLEDITFORMAT(Description)#" onclick="NewWindow(this.href,'P_List','850','600','Yes', 'No');return false;">#Price_List_ID#</A>
				<FONT SIZE="2" COLOR="Red">]</FONT>				
				</B>	
			<CFELSE>
				<B>
				<FONT SIZE="2">[</FONT>
				#Price_List_ID#
				<FONT SIZE="2">]</FONT>	
				</B>
			</CFIF>
		
		</TD>
		<TD WIDTH="400">#HTMLEDITFORMAT(Description)#</TD>
		<!--- <TD WIDTH="100"><CFIF FORM.PL_Type eq 1>#DateFormat(Active_Date,"mm/dd/yyyy")#<CFELSE>#DateFormat(Get_Created_Date.Created_Date,"mm/dd/yyyy")#</CFIF></TD> --->
	</TR>
	</CFOUTPUT>		
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="598" ALIGN="center">
<TR>
		<TD COLSPAN="100%">
			<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
		    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		    <CF_Next_Previous_For_Forms
		    formname="Search_form"
		    query="Search_Record"
		    maxpages="25"
		    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		    addparams="">
		   </DIV>
		</TD>
	</TR>	
</TABLE>
</CFIF>
</FORM>

<blockquote><blockquote>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</blockquote></blockquote>

</body>
</html>
