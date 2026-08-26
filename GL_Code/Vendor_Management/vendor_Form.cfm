<!--- Dev Note: drachala; D28955: vendor table in settings  START
Added/Changed: Modified this page to prevnet issues like nesting forms--->
<STYLE>
TABLE.Underlinedtable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>


<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Vendor_Dist_Oper.Vendor_ID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFPARAM NAME="FORM.SearchNow" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_ID" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_City" DEFAULT="">
<CFPARAM NAME="FORM.State" DEFAULT="">
<CFPARAM NAME="FORM.Country_Code" DEFAULT="">  
<CFPARAM NAME="FORM.Distributor_List" DEFAULT=""> 
<CFPARAM NAME="FORM.Operator_List" DEFAULT="">
<CFPARAM NAME="FORM.Visible_Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Shr_Ship_To" DEFAULT="">
<CFPARAM NAME="FORM.Importallflag" DEFAULT="">
<CFPARAM NAME="FORM.Visible_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Operator" DEFAULT="">
<CFPARAM NAME="FORM.Importallflag_Oper" DEFAULT="">
<CFPARAM NAME="FORM.Operator_ID_Number" DEFAULT="">

<CFIF FORM.SORT_BY EQ "Vendor_ID">
	<CFSET FORM.SORT_BY = "Vendor_Dist_Oper.Vendor_ID">
</CFIF>
<CFQUERY NAME="GetVendorIDInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		Vendor_Dist_Oper.*, 
				BSA_Foodservice_Customers.Shr_Ship_To,
				Name,
				BSA_Operator.Operator_Name,
				BSA_Operator.Legacy_ID Operator_ID_Number,BSA_Operator.BSA_Operator_ID,
				--------vendor mater information
				Vendor_Name as vendorName,
				Vendor_Master.Address_1 as vendorAddress1,
				Vendor_Master.Address_2 as vendorAddress2,	
				Vendor_Master.City as vendorCity,
				Vendor_Master.State as vendorState,
				Vendor_Master.Zipcode as vendorZipCode
	FROM 		Vendor_Dist_Oper
	LEFT JOIN 	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Dist_Oper.Distributor_ID AND				
				BSA_Foodservice_Customers.Deleted = 0 				
	LEFT JOIN	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Vendor_Dist_Oper.Operator_ID	
	INNER JOIN	Vendor_Master ON Vendor_Master.Vendor_ID = Vendor_Dist_Oper.Vendor_ID AND Vendor_Master.Active_Code = 'A'
				
	WHERE 		1 = 1 AND
				<CFIF FORM.Vendor_ID NEQ "">
					Vendor_Dist_Oper.Vendor_ID = '#FORM.Vendor_ID#' AND
				</CFIF>		
				<CFIF FORM.Vendor_Name NEQ "">
					Vendor_Name LIKE '%#FORM.Vendor_Name#%' AND
				</CFIF>
				<CFIF FORM.Vendor_City NEQ "">
					Vendor_Master.City = '#FORM.Vendor_City#' AND
				</CFIF>
				<CFIF FORM.State NEQ "">
					Vendor_Master.State = '#FORM.State#' AND
				</CFIF>
				<CFIF FORM.Distributor NEQ "">
					Distributor_ID = '#FORM.Distributor#' AND	
				</CFIF>
				<CFIF FORM.Operator_list NEQ "">
					Vendor_Dist_Oper.Operator_ID = '#FORM.Operator_list#' AND
				</CFIF>		
				<CFIF FORM.Shr_Ship_To NEQ "">	
					BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#FORM.Shr_Ship_To#%' AND
				</CFIF>
				<CFIF FORM.Operator_ID_Number NEQ "">
					(BSA_Operator.Legacy_ID LIKE '%#FORM.Operator_ID_Number#%'
					<cfif IsNumeric(FORM.Operator_ID_Number)>
				OR BSA_Operator_id = #FORM.Operator_ID_Number#</cfif>
					) AND
				</CFIF>				
				Vendor_Dist_Oper.Deleted = 0
	ORDER BY 	#FORM.SORT_BY# #FORM.SORT_ORDER#
</CFQUERY>

	
<CFOUTPUT>
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
<cfparam name="FORM.startrow"  default="1">
<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
<cfparam name="FORM.pageLength"  default=10>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">   	
	
<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
</CFOUTPUT>
 	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" STYLE="Border-Bottom: 1px Solid Navy;Border-Right: 1px Solid Navy;Border-Left: 1px Solid Navy;Border-Top: 1px Solid Navy;">
		<TR>
			<TD COLSPAN="100%">
				<B>Vendor Name</B><BR>
				<CFOUTPUT><INPUT TYPE="Text" NAME="Vendor_Name" VALUE="#FORM.Vendor_Name#" SIZE="115"></CFOUTPUT>
			</TD>
		</TR>
		<TR>
			<TD>
				<B>Vendor Number</B><BR>
				<CFOUTPUT><INPUT TYPE="Text" NAME="Vendor_ID" VALUE="#FORM.Vendor_ID#"></CFOUTPUT>
			</TD>	
			<TD>
				<CFQUERY NAME="getVendorCity" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT City FROM Vendor_Master WHERE LEN(City) > 0	ORDER BY City
				</CFQUERY>
				<B>Vendor City</B><BR>
				<SELECT NAME="Vendor_City" STYLE="WIDTH:115px">
					<OPTION VALUE="">**ALL** City</OPTION>
					<CFOUTPUT QUERY="getVendorCity"><OPTION VALUE="#trim(getVendorCity.City)#" <CFIF FORM.Vendor_City EQ getVendorCity.City>SELECTED </CFIF>><CFIF len(trim(getVendorCity.City)) EQ 0>City Not Specified<CFELSE>#trim(getVendorCity.City)#</CFIF></OPTION></CFOUTPUT>
				</SELECT>		
			</TD>
			<TD>
				<cfquery name="GetStates" datasource="#application.datasource#">
					SELECT DISTINCT State, State_Name, Country_Sort_Order
					FROM Vendor_Master V
					join _States s on s.State_Code =  V.state
					join _Country c on s.Country_ID = c.Country_ID
					WHERE	LEN(State) > 0
					ORDER BY Country_Sort_Order, State_Name
				</cfquery>
				<B>Vendor State</B><BR>
				<SELECT NAME="State" STYLE="WIDTH:115px">
					<OPTION VALUE="">**ALL** States</OPTION>
					<CFOUTPUT QUERY="GetStates"><OPTION VALUE="#trim(GetStates.state)#"#IIF(trim(FORM.state) EQ trim(GetStates.state), DE(" SELECTED"), DE(""))#><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state_name)#</CFIF></OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
			<TD>
				<!--- Country code --->
				<!--- 
				<CFQUERY NAME="getCountry" datasource="#application.datasource#">
					SELECT distinct c.country_code, country_name, Country_id
					FROM Vendor_Master bc
					Join  _Country c on bc.country_code = c.country_code
					where active = 1
					ORDER BY Country_id ASC
				</CFQUERY>
				 --->
				<CFQUERY NAME="getCountry" DATASOURCE="#Application.Datasource#">
					SELECT * FROM _Country
				</CFQUERY>
				
				<B>Vendor Country</B><BR>
				<CFOUTPUT>
					<SELECT NAME="Country_Code" STYLE="WIDTH:115px" disabled>
					  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
					    <CFLOOP QUERY="getCountry">
							<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.country_code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
						</CFLOOP>
				     </SELECT>
				</CFOUTPUT>			
			</TD>
			
		</TR>	
		<TR>
			<TD COLSPAN="2">
				<B><CFOUTPUT>#application.returned_customer_setting.distributor_label_singular# Name</CFOUTPUT></B>
				<CFIF FORM.Distributor NEQ "">
					<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
						SELECT BSA_Foodservice_Customers_ID,Name 
						FROM BSA_Foodservice_Customers 
						WHERE
							BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#Distributor#'
							AND
							BSA_Foodservice_Customers.Deleted = 0
							AND
							BSA_Foodservice_Customers.Active_Code = 'A'
						ORDER BY Name
					</CFQUERY>
					
					<CFSET FORM.Visible_Distributor=VAlueList(Dist_Search_Result.Name)>
				</CFIF>
				<SCRIPT LANGUAGE="JavaScript">
					function showDistSearchWindow() 
					{				
						//document.all.Form_Submitted.value=0;		
						document.SearchForm.target = "_self";
						document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
						NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm&FieldName=Distributor&SelectSingleSearchResultOnly=1", "searchwindow", 800, 600, "yes", "yes")
					}
				</SCRIPT>
				<B>
					<FONT COLOR="Red">[</FONT>
					<FONT COLOR="Blue"><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();">select</A></FONT><!--- onclick="window.showModalDialog(this.href,window,'dialogHeight:210px;dialogWidth:450px;center:yes;edge:raised'); return false;" --->
					<FONT COLOR="Red">]</FONT>
				</B><BR>
				
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Visible_Distributor" VALUE="#FORM.Visible_Distributor#" style="font:italic;width:300px;background-color:CCCCCC" READONLY>
				<INPUT TYPE="Hidden" NAME="Distributor" VALUE="#FORM.Distributor#" style="width: 350px;">
				<INPUT TYPE="Hidden" NAME="Importallflag"  VALUE="#FORM.Importallflag#">
				</CFOUTPUT>
				
			</TD>
			<TD COLSPAN="2">
				<B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular# Name</CFOUTPUT></B>
				<CFIF FORM.Operator_List NEQ "">
					<CFQUERY NAME="Oper_Search_Result" DATASOURCE = "#Application.Datasource#">
						SELECT Operator_Name
						FROM	BSA_Operator
						WHERE 	BSA_Operator_ID = '#FORM.Operator_List#'
					</CFQUERY>
					
					<CFSET FORM.Visible_Operator=Oper_Search_Result.Operator_Name>
				</CFIF>
				<SCRIPT LANGUAGE="JavaScript">
					function showOperSearchWindow() 
					{				
						//document.all.Form_Submitted.value=0;		
						document.SearchForm.target = "_self";
						document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
						NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=SearchForm&SelectSingleSearchResultOnly=1", "operatorwindow", 800, 600, "yes", "yes")
					}
				</SCRIPT>
				
				<B>
					<FONT COLOR="Red">[</FONT>
					<FONT COLOR="Blue"><A HREF="javascript: void(0);" onclick="javaScript: showOperSearchWindow();">select</A></FONT>
					<FONT COLOR="Red">]</FONT>
				</B><BR>
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Visible_Operator" VALUE="#FORM.Visible_Operator#" style="font:italic;width:300px;background-color:CCCCCC" READONLY>
				<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#FORM.Operator_List#" style="width: 350px;">
				<INPUT TYPE="Hidden" NAME="Importallflag_Oper"  VALUE="#FORM.Importallflag_Oper#">
				</CFOUTPUT>
			</TD>			
		</TR>
		<TR>
			<TD>
				<B><CFOUTPUT>#application.returned_customer_setting.Shard_Ship_To_Label#</CFOUTPUT></B><BR>
				<CFOUTPUT><INPUT TYPE="Text" NAME="Shr_Ship_To" VALUE="#FORM.Shr_Ship_To#"></CFOUTPUT>
			</TD> 
			<TD>
				<B>Legacy <CFOUTPUT>#application.returned_customer_setting.operator_label_singular# ID</CFOUTPUT></B><BR>
				<CFOUTPUT><INPUT TYPE="Text" NAME="Operator_ID_Number" VALUE="#FORM.Operator_ID_Number#"></CFOUTPUT>
			</TD>
			<TD COLSPAN="2" ALIGN="Right"><BR>				
				<B>
				<FONT COLOR="Red" SIZE="2">[ </FONT>
				<A HREF="" ONCLICK="javascript: resetForm(); return false;">reset</A>
				<FONT COLOR="Red" SIZE="2"> ]</FONT>
				</B>
				&nbsp;&nbsp;
				<B>
				<FONT COLOR="Red" SIZE="2">[ </FONT>
				<A HREF="" ONCLICK="javascript: validate(); return false;">search vendor</A>
				<FONT COLOR="Red" SIZE="2"> ]</FONT>
				</B>
			</TD>
		</TR>
		
	</TABLE>
	<BR><BR>
	
	<CFSET A_Header_Value_List = "Vendor_ID,vendorName,vendorAddress1,Shr_Ship_To,Name,Operator_ID,Operator_Name">
	<CFSET A_Header_Name_List = "Vendor ID,Vendor Name,Vendor Address,#application.returned_customer_setting.Shard_Ship_To_Label#,#application.returned_customer_setting.distributor_label_singular# Name,#application.returned_customer_setting.operator_label_singular# ID,#application.returned_customer_setting.operator_label_singular# Name">
	
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="Underlinedtable">
		<TR>
			<TD COLSPAN="100%" STYLE="Border-Bottom: none;"><BR><BR><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="Vendor_Action.cfm" TITLE="Click to create new record.">create new entry</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD><!--- ONCLICK="NewWindow(this.href,'name','500','350','Yes', 'No');return false;" --->
		</TR>
		<TR>
			<TD COLSPAN="100%"><FONT COLOR="Red" SIZE="2"><b>There Are <cfoutput>#GetVendorIDInfo.recordcount#</cfoutput> Vendor(s) That Match The Supplied Criteria</b></FONT></TD>
		</TR>		
		<CFOUTPUT>
		<TR BGCOLOR="FFE083">
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
				
				<TD ID="header" align="left">
				
				<A HREF="##" onClick="javascript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>
				
				</TD>
				
				<CFSET Counter = Counter + 1>
			</CFLOOP>
		</TR>
		</CFOUTPUT>
		<CFOUTPUT QUERY="GetVendorIDInfo" startrow="#StartRow#" maxrows="#MaxRows#">
			<cfset vendorAddr = "" >
			<!--- <CFIF vendorName NEQ ""><cfset vendorAddr =  vendorAddr & vendorName></CFIF> --->
			<CFIF vendorAddress1 NEQ ""><cfset vendorAddr =  vendorAddress1 & "<BR>"></CFIF>
			<CFIF vendorAddress2 NEQ ""><cfset vendorAddr =  vendorAddr & vendorAddress2 & "<BR>" ></CFIF>
			<CFIF vendorCity NEQ ""><cfset vendorAddr =  vendorAddr & vendorCity ></CFIF>
			<CFIF vendorState NEQ ""><cfset vendorAddr =  vendorAddr & "," & vendorState ></CFIF>
			<CFIF vendorZipCode NEQ ""><cfset vendorAddr =  vendorAddr & " " & vendorZipCode></CFIF>		
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD  align="left"><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="Vendor_Action.cfm?RID=#Vendor_Dist_Oper_ID#" TITLE="Click to edit this record."><CFIF Vendor_ID NEQ "">#Vendor_ID#<CFELSE> <FONT COLOR="red">none</FONT> </CFIF></A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;</TD><!--- ONCLICK="NewWindow(this.href,'name','500','350','Yes', 'No');return false;" --->
				<TD nowrap align="left"><CFIF vendorName NEQ "">#vendorName#<cfelse> <FONT COLOR="red">--none--</FONT> </cfif>&nbsp;</TD>
				<TD nowrap align="left"><CFIF vendorAddr NEQ "">#vendorAddr#<cfelse> <FONT COLOR="red">--none--</FONT> </cfif>&nbsp;</TD>
				<TD nowrap align="left"><CFIF Shr_Ship_To NEQ "">#Shr_Ship_To#<CFELSE> <FONT COLOR="red">--none--</FONT> </CFIF>&nbsp;</TD>
				<TD nowrap align="left"><CFIF Name NEQ "">#Name#<CFELSE> <FONT COLOR="red">--none--</FONT> </CFIF>&nbsp;</TD>
				<TD nowrap align="left" <CFIF Operator_ID_Number NEQ "">Title="Operator Legacy ID"<CFELSE>Title="BSA Operator ID"</CFIF>><CFIF Operator_ID_Number NEQ "">#Operator_ID_Number#<CFELSE> #BSA_Operator_ID#</CFIF>&nbsp;</TD>
				<TD nowrap align="left"><CFIF Operator_Name NEQ "">#Operator_Name#<CFELSE> <FONT COLOR="red">--none--</FONT> </CFIF>&nbsp;</TD>
			</TR>
		</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%" STYLE="Border-Bottom: none;">
				<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <CF_Next_Previous_For_Forms
			    formname="SearchForm"
			    query="GetVendorIDInfo"
			    maxpages="40"
			    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    addparams="">
			   </DIV>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" STYLE="Border-Bottom: none;"><BR><BR><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HREF="Vendor_Action.cfm" TITLE="Click to create new record.">create new entry</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD><!--- ONCLICK="NewWindow(this.href,'name','500','350','Yes', 'No');return false;" --->
		</TR>
	</TABLE>	
	





<SCRIPT language="JavaScript">
function resetForm()
{	
	event.returnValue = false;
	document.all.Vendor_Name.value = "";
	document.all.Vendor_ID.value = "";
	document.all.Shr_Ship_To.value = "";
	document.all.Visible_Distributor.value = "";	
	document.all.Distributor.value = "";
	document.all.Importallflag.value = "";
	document.all.Visible_Operator.value = "";
	//document.all.Operator.value = "";
	document.all.Importallflag_Oper.value = "";
	document.all.Operator_ID_Number.value = "";
	document.all.Vendor_City.value="";//: drachala; D28955
	document.all.State.value="";//: drachala; D28955
	document.all.Country_Code.value="";//: drachala; D28955

	document.location.href="/GL_Code/Vendor_Management/index.cfm";
	
	/*resetSelect("Vendor_City");
	resetSelect("State");
	resetSelect("Country_Code");*/ //drachala; D28955
}

function validate()
{
	document.SearchForm.action = "/GL_Code/Vendor_Management/index.cfm";//dr
	document.SearchForm.submit()
}


function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.SearchForm;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}	
</SCRIPT>

