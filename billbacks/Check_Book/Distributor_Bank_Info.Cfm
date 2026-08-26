<HTML>
<CFIF isdefined("URL.new_bb_check")>
	<CFSET URL.PageTitle="BILLBACK: #application.returned_customer_setting.distributor_label_singular# Bank Info">
<CFELSE>
	<CFSET URL.PageTitle="#application.CompanyName#: #application.returned_customer_setting.distributor_label_singular# Bank Info">
</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BODY BGCOLOR="White" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="8" TOPMARGIN="12" RIGHTMARGIN="8" onload="javaScript: reloadDefaults();">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF isdefined("url.new_bb_check")>
<!--- <CFOUTPUT>
#url.new_bb_check#<br>
#url.trans_type#<br>
#url.LRID#<br>
</CFOUTPUT>
 <CFPARAM NAME = "url.new_bb_check" DEFAULT = "">--->
<CFPARAM NAME = "url.trans_type" DEFAULT = "">
<CFPARAM NAME = "url.LRID" DEFAULT = "">
</CFIF>
<CFQUERY NAME="Get_Distributor" datasource="#application.datasource#">
	SELECT 
		BSA_Foodservice_Customers.Name 				Distributor_Name,
		Customer_Bank_Info.Bank_Info_ID 				Bank_Info_ID,
		Customer_Bank_Info.Customer_ID 					Customer_ID,
		Customer_Bank_Info.Customer_Transit_Routing_No  Customer_Transit_Routing_No,
		Customer_Bank_Info.Customer_Bank_Name 			Customer_Bank_Name,
		Customer_Bank_Info.Customer_Bank_Address 		Customer_Bank_Address,
		Customer_Bank_Info.Customer_Bank_City 			Customer_Bank_City,
		Customer_Bank_Info.Customer_Bank_Statecode 		Customer_Bank_Statecode,
		Customer_Bank_Info.Customer_Bank_Zipcode 		Customer_Bank_Zipcode,
		Customer_Bank_Info.Customer_Bank_Country_Code 	Customer_Bank_Country_code,
		Customer_Bank_Info.Customer_Account_No	 		Customer_Account_No,
		Customer_Bank_Info.Category 					Category,
		Customer_Bank_Info.Bank_Info_Deleted 			Bank_Info_Deleted
    FROM Customer_Bank_Info
	INNER JOIN BSA_Foodservice_Customers
 	ON 
 	(
       	(Customer_Bank_Info.Customer_ID = CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS NVARCHAR(50)))
	AND
  		(Customer_Bank_Info.Category = 'Distributor')
	)
	ORDER BY  BSA_Foodservice_Customers.Name
</CFQUERY>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


<CFIF not isdefined("url.new_bb_check")>
<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="broker_bank_info.cfm"><B>broker bank info</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="operator_bank_info.cfm"><B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> bank info</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
</CFIF>

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="765">
		<TR>
			<TD VALIGN="top">

				<SPAN CLASS="title2">Stored Records</SPAN>
				<HR COLOR="Blue" SIZE="1">
				<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
					<TR>
						<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</B></SPAN></TD>
						<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
					</TR>
					<CFOUTPUT QUERY="Get_Distributor">
					<TR>
						<CFIF isdefined("url.payee_id")>
						<TD NOWRAP>#Distributor_Name#</TD>												 
						<CFELSEIF isdefined("url.new_bb_check")>
						<TD NOWRAP><A HREF="Distributor_Bank_Info.cfm?RID=#Bank_Info_ID#&new_bb_check=#url.new_bb_check#&trans_type=#url.trans_type#&LRID=#url.LRID#">#Distributor_Name#</A></TD>						
						<CFELSE>
						<TD NOWRAP><A HREF="Distributor_Bank_Info.cfm?RID=#Bank_Info_ID#">#Distributor_Name#</A></TD>
						</CFIF>
						<TD NOWRAP>
								<CFIF Bank_Info_Deleted EQ 0>
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
				<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
				
			</TD>
			<TD VALIGN="top"  width="500">


				<SPAN CLASS="title2">Edit Record</SPAN>
				<HR COLOR="Blue" SIZE="1">

				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->				
<CFPARAM NAME="URL.RID" DEFAULT="0">
				
<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	SELECT 
		BSA_Foodservice_Customers.Name 				Distributor_Name,
		Customer_Bank_Info.Bank_Info_ID 				Bank_Info_ID,
		Customer_Bank_Info.Customer_ID 					Customer_ID,
		Customer_Bank_Info.Customer_Transit_Routing_No  Customer_Transit_Routing_No,
		Customer_Bank_Info.Customer_Bank_Name 			Customer_Bank_Name,
		Customer_Bank_Info.Customer_Bank_Address 		Customer_Bank_Address,
		Customer_Bank_Info.Customer_Bank_City 			Customer_Bank_City,
		Customer_Bank_Info.Customer_Bank_Statecode 		Customer_Bank_Statecode,
		Customer_Bank_Info.Customer_Bank_Zipcode 		Customer_Bank_Zipcode,
		Customer_Bank_Info.Customer_Bank_Country_Code 	Customer_Bank_Country_code,
		Customer_Bank_Info.Customer_Account_No	 		Customer_Account_No,
		Customer_Bank_Info.Category 					Category,
		Customer_Bank_Info.Bank_Info_Deleted 			Bank_Info_Deleted,
		Customer_Bank_Info.Customer_Bank_Location		Customer_Bank_Location
    FROM Customer_Bank_Info
	INNER JOIN BSA_Foodservice_Customers
 	ON 
 	(
       	(Customer_Bank_Info.Customer_ID = CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS NVARCHAR(50)))
	AND
  		(Customer_Bank_Info.Category = 'Distributor')
	)
	Where Customer_Bank_Info.Bank_Info_ID = '#URL.RID#'
</CFQUERY>

<CFPARAM NAME="Get_Item.Bank_Info_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Transit_Routing_No" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Name" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Address" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_City" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Statecode" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Zipcode" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Country_Code" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Bank_Location" DEFAULT="">
<CFPARAM NAME="Get_Item.Customer_Account_No" DEFAULT="">
<CFPARAM NAME="Get_Item.Category" DEFAULT="">
<CFPARAM NAME="Get_Item.Bank_Info_Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Distributor_Name" DEFAULT="">

<!--- for billback without customer bank info --->
<CFPARAM NAME="URL.Payee_ID" DEFAULT = "">
<!--- <CFOUTPUT>#URL.payee_ID#<BR>#URL.payee_Name#</CFOUTPUT> --->

<CFSET Get_Item_Distributor_Name = Get_Item.Distributor_Name>

<CFIF URL.payee_ID NEQ "">
	<CFQUERY NAME = "get_item" DATASOURCE = "#Application.Datasource#">
	SELECT 
		BSA_Foodservice_Customers.Name 				Distributor_Name,
		Customer_Bank_Info.Bank_Info_ID 				Bank_Info_ID,
		Customer_Bank_Info.Customer_ID 					Customer_ID,
		Customer_Bank_Info.Customer_Transit_Routing_No  Customer_Transit_Routing_No,
		Customer_Bank_Info.Customer_Bank_Name 			Customer_Bank_Name,
		Customer_Bank_Info.Customer_Bank_Address 		Customer_Bank_Address,
		Customer_Bank_Info.Customer_Bank_City 			Customer_Bank_City,
		Customer_Bank_Info.Customer_Bank_Statecode 		Customer_Bank_Statecode,
		Customer_Bank_Info.Customer_Bank_Zipcode 		Customer_Bank_Zipcode,
		Customer_Bank_Info.Customer_Account_No	 		Customer_Account_No,
		Customer_Bank_Info.Category 					Category,
		Customer_Bank_Info.Bank_Info_Deleted 			Bank_Info_Deleted,
		Customer_Bank_Info.Customer_Bank_Location		Customer_Bank_Location
    FROM Customer_Bank_Info
	INNER JOIN BSA_Foodservice_Customers
 	ON 
 	(
       	(Customer_Bank_Info.Customer_ID = CAST(BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AS NVARCHAR(50)))
	AND
  		(Customer_Bank_Info.Category = 'Distributor')
	)
	Where Customer_Bank_Info.customer_ID = '#URL.payee_ID#'



<!--- 		SELECT *
		from customer_bank_info where 
 --->	</CFQUERY>
 	<CFIF get_item.bank_info_id NEQ "">
		<CFSET url.RID = get_item.bank_info_id>		
	<CFELSE>
		<CFSET url.RID = -1>		
	</CFIF>
<CFSET Get_Item_Distributor_Name = URL.Payee_Name> 
</CFIF>
<!--- <CFOUTPUT>RID#URL.RID#</CFOUTPUT> --->

<!--- Create New --->
<CFIF URL.RID EQ "0"> 
		<CFPARAM NAME="FORM.Distributor_List" 	DEFAULT="">
		<CFIF FORM.Distributor_List NEQ "">
			<CFQUERY NAME="Search_Result" DATASOURCE = "#Application.Datasource#">
				SELECT BSA_Foodservice_Customers_ID,Name 
				FROM BSA_Foodservice_Customers 
				WHERE
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
					AND
					BSA_Foodservice_Customers.Deleted = 0
					AND
					BSA_Foodservice_Customers.Active_Code = 'A'
				ORDER BY Name
			</CFQUERY>
			<CFSET Selected_Name = Search_Result.Name>
		</CFIF>
		<CFOUTPUT>
		<CFIF isdefined("URL.new_bb_check")>
			<CFSET QSTR = "?new_bb_check=#URL.new_bb_check#">
			<CFSET QSTR = "#QSTR#&trans_type=#URL.trans_type#">
			<CFSET QSTR = "#QSTR#&LRID=#URL.LRID#">
		<CFELSE>
			<CFSET QSTR = "">
		</CFIF>
		<FORM ACTION="#CGI.SCRIPT_NAME##QSTR#" ID="Cust_Search_Form" METHOD="POST" STYLE="DISPLAY:INLINE">
			<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
		</FORM>
		</CFOUTPUT>
	<CFELSEIF URL.payee_ID NEQ "">
		<CFSET Selected_Name = Get_Item_Distributor_Name>
	<CFELSE>
		<CFSET Selected_Name = Get_Item.Distributor_Name>
	</CFIF>


<!--- State code --->
<CFQUERY NAME="getStates" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>
<!--- Country code --->
<CFQUERY NAME="getCountry" datasource="#application.datasource#">
	SELECT *
	FROM _Country
	where active = 1
	ORDER BY Country_id ASC
</CFQUERY>
<!--- Bank_Address --->
<SCRIPT type = "text/javascript">
function restrictLength(thisobj,valueLength)
		{
			if(event.type == "keypress")
			{
				if(thisobj.value.length >= valueLength)
				{
					return false;
				}
			}			
			if(event.type == "paste")
			{
				var fullData = thisobj.value + window.clipboardData.getData("Text");
				if(fullData.length >= valueLength)
				{	
					thisobj.value = fullData.substr(0,valueLength);
					return false;
				}
			}
			
			return true;
		}
</SCRIPT>



<!--- Location --->	
<SCRIPT language="javascript">
	function Change_Address(thisObj)
	{
		var trState = document.all.TR_CITY_STATE;
		if(trState)
		{
			var chObjs = document.all[thisObj.name];
			if(chObjs[0].checked)
			{				
				document.all.Customer_Bank_City.disabled = false;
				document.all.Customer_Bank_Statecode.disabled = false;
				document.all.Customer_Bank_Zipcode.disabled = false;
				trState.style.display = "";
			}
			else
			{
				document.all.Customer_Bank_City.disabled = true;
				document.all.Customer_Bank_Statecode.disabled = true;
				document.all.Customer_Bank_Zipcode.disabled = true;
				trState.style.display = "none";
			}
		}
	}
</SCRIPT>

<!--- number check --->
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>

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

			<FORM ACTION="save_Customer_Bank_Info.cfm" METHOD="post" NAME="MyForm" onsubmit="javaSCript: alert(this.action);"> 
			
			<CFIF isdefined("URL.new_bb_check")>
			 <CFOUTPUT>
			<!---s;ldkfalkdf
			new_bb_check: #url.new_bb_check#
			trans_type: #url.Trans_type#
			LRID: #url.LRID#  --->
			<INPUT TYPE = "hidden" NAME = "new_bb_check" VALUE = "#url.new_bb_check#">
			<INPUT TYPE = "hidden" NAME = "trans_type" VALUE = "#url.Trans_type#">
			<INPUT TYPE = "hidden" NAME = "LRID" VALUE = "#url.LRID#">
			
			</CFOUTPUT>	
			</CFIF>
				<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0">

				<CFOUTPUT><INPUT TYPE="hidden" NAME="Bank_Info_ID" VALUE="#Get_Item.Bank_Info_Id#"></CFOUTPUT>
				<INPUT TYPE="hidden" NAME="Category" VALUE="Distributor">
				
					<!------------------------------------------------------------------------------------
					Search Distributor
					------------------------------------------------------------------------------------->
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></B></TD>
						<TD VALIGN="top">
							<SCRIPT LANGUAGE="JavaScript">
								function showSearchWindow() 
								{
									NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=Cust_Search_Form", "searchwindow", 800, 600, "yes", "yes")
								}
							</SCRIPT>
							<CFPARAM NAME="Selected_Name" 	DEFAULT="">
							<CFOUTPUT>
							<!---#Get_Item.Distributor_Name#--->
							

						<INPUT SIZE="45" NAME="Customer_Name" VALUE="#Selected_Name#" READONLY></TD>	
						<CFIF URL.RID EQ "0"> 
						<TD VALIGN="top" NOWRAP>
								<B>
									<FONT SIZE="2" COLOR="Red">[</FONT>
										<!--- <FONT SIZE="2" COLOR="Blue"> --->
							 				<A HREF="javascript: void(0);" onClick="javaScript: showSearchWindow();">
											<b>search #application.returned_customer_setting.distributor_label_singular#</b>											
											</A>
										<!--- </FONT> --->
									<FONT SIZE="2" COLOR="Red">]</FONT>
								</B>
						</TD>
								</CFIF>
							<!--- <CFELSE>
							<TD>
								<INPUT SIZE="45" NAME="Customer_ID" VALUE="#Get_Item.Distributor_Name#">
							</TD> --->
							
						<CFIF URL.payee_ID NEQ "">
							<INPUT TYPE="HIDDEN" NAME="Customer_ID" VALUE="#url.payee_ID#">
							<INPUT TYPE="HIDDEN" NAME="Payee_Name" VALUE="#url.payee_Name#">
						<CFELSEIF URL.RID NEQ 0>
							<INPUT TYPE="HIDDEN" NAME="Customer_ID" VALUE="#Get_Item.Customer_ID#">					

						<CFELSE>
							<INPUT TYPE="HIDDEN" NAME="Customer_ID" VALUE="#FORM.Distributor_List#">
						</CFIF>
						</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Account No</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="45" NAME="Customer_Account_No" VALUE="#Get_Item.Customer_Account_No#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Transit Rounting No</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="45" NAME="Customer_Transit_Routing_No" VALUE="#Get_Item.Customer_Transit_Routing_No#"  ONKEYUP="clenseText(this,'0123456789')">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Bank Name</B></TD>
						<TD VALIGN="top">
							<CFOUTPUT>
								<INPUT SIZE="45" NAME="Customer_Bank_Name" VALUE="#Get_Item.Customer_Bank_Name#">
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><b>Location</b></TD>
						<CFOUTPUT>
						<TD VALIGN="top">
							<CFSET US = "CHECKED">
							<CFSET OUTSIDE_US="">
						<CFIF isdefined("URL.new_bb_check")>
						
								<CFSET STATE = "disabled">
							<CFQUERY name = "check_contury" datasource = "#Application.datasource#">
								SELECT Curr_symbol from Ledger_Table where Ledger_ID = #URL.LRID#	
							</CFQUERY>
							<CFPARAM NAME = "check_contury.curr_symbol" DEFAULT = "">
						
								<CFIF check_contury.curr_symbol EQ "US">
								
									<!--- <INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "1"> --->
									<CFSET US_ADDRESS = "CHECKED">						 
									<CFSET US = "CHECKED">
									<CFSET OUTSIDE_US = ""> 
								<CFELSE>
									<!--- <INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "0"> --->
									<CFSET US = "">
									<CFSET OUTSIDE_US = "CHECKED"> 				
								</CFIF>
						</CFIF>
							<CFPARAM NAME = "US_Address" default = "">
							<CFPARAM NAME = "state" default = "">
								

	 					<CFIF #Get_Item.Customer_Bank_Location# EQ 0>
							<CFSET US ="">
							<CFSET OUTSIDE_US="CHECKED">
						<CFELSEIF #Get_Item.Customer_Bank_Location# EQ 1 >
							<CFSET US="CHECKED">
							<CFSET OUTSIDE_US="">
						</CFIF>
<!--- 						 <CFIF isdefined("URL.new_bb_check") and check_contury.curr_symbol NEQ "" or Get_Item.Customer_Bank_Location NEQ "">
							<CFIF US EQ "CHECKED">
							<INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "1">
							<CFELSE>
							<INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "0">
							</CFIF>
						</CFIF>
 --->					
						
						<INPUT TYPE = "radio" NAME = "Customer_Bank_Location" VALUE = "1" #US#  onClick="javaScript: Change_Address(this);">United States
						<INPUT TYPE = "radio" NAME = "Customer_Bank_Location" VALUE = "0" #OUTSIDE_US#  onClick="javaScript: Change_Address(this);">Outside United States
						</TD>
						</CFOUTPUT>
					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Bank Address</B></TD>
						<TD VALIGN="top">

							<CFOUTPUT>
								<TEXTAREA COLS="47" ROWS="2" NAME="Customer_Bank_Address" onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" >#Get_Item.Customer_Bank_Address#</TEXTAREA>
								<!--- <INPUT SIZE="45" NAME="Customer_Bank_Address" VALUE="#Get_Item.Customer_Bank_Address#"> <br>--->
							</CFOUTPUT>
						</TD>
					</TR>

					<TR ID="TR_CITY_STATE"<CFIF Len(US) LTE 0> STYLE="DISPLAY:NONE"</CFIF>>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>City/State/Postal</B></TD>
						<TD VALIGN="top"> 
							<CFOUTPUT>
								<INPUT <CFIF Len(US) LTE 0> DISABLED </CFIF>SIZE="24" NAME="Customer_Bank_City" VALUE="#Get_Item.Customer_Bank_City#">&nbsp;
								<SELECT <CFIF Len(US) LTE 0> DISABLED  </CFIF>NAME="Customer_Bank_Statecode"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getStates"><OPTION VALUE="#getStates.State_Code#" <CFIF getStates.State_Code EQ Get_Item.Customer_Bank_Statecode> SELECTED</CFIF>>#getStates.State_Code#</OPTION></CFLOOP></SELECT>&nbsp;  
								<INPUT <CFIF Len(US) LTE 0> DISABLED </CFIF>NAME="Customer_Bank_Zipcode" VALUE="#Get_Item.Customer_Bank_Zipcode#" TYPE="text" SIZE="4" MAXLENGTH="10">&nbsp; <!--- ONKEYUP="clenseText(this,'0123456789')" --->
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Country</B></TD>
						<TD VALIGN="top"> 
							<CFOUTPUT>
								<SELECT NAME="Customer_Bank_Country_Code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getCountry"><OPTION VALUE="#getCountry.Country_Code#" <CFIF getCountry.Country_Code EQ Get_Item.Customer_Bank_Country_Code> SELECTED</CFIF>>#getCountry.Country_Name#</OPTION></CFLOOP></SELECT>&nbsp;  
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Availability</B></TD>
						<TD VALIGN="top">


						<!--- Is this record deleted? --->
						<CFIF Get_Item.Bank_Info_Deleted EQ 0 OR Get_Item.Bank_Info_Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>
						
						<CFPARAM NAME = "disabled" DEFAULT = "">						
						<CFIF isdefined("URL.new_bb_check")>			
							<CFSET disabled = "DISABLED">
						</CFIF>
						
						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Bank_Info_Deleted"#active#>Active
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Bank_Info_Deleted"#inactive# #disabled#>Inactive 
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
							<CFIF Get_Item.Bank_Info_Deleted EQ 1>
							<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
									<A HREF="javascript: alert_and_delete();"><B>delete data</B></A><!--- HREF="javascript: document.MyForm.submit() href="#" ONCLICK="document.all.DeleteRecord.value=1;document.MyForm.submit();"--->
							<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
							</CFIF>							

						</TD>
					</TR>
				</TABLE>
			</FORM>
				
			</TD>
		</TR>
	</TABLE>
<CFIF not isdefined("url.new_bb_check")>
<B>	
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Distributor_Bank_Info.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>
</CFIF>	
<SCRIPT language="JavaScript">
	function reloadDefaults()
	{
		if(document.all.Customer_Bank_Location[0])
		{
			Change_Address(document.all.Customer_Bank_Location[0]);
		}
	}
</SCRIPT>
</BODY>
</HTML>
				
