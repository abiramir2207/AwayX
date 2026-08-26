<CFSET PAGE_TITLE="Create New Contract - 2 of 6">
<CFSET GROUP="Contracts">

<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="URL.RO" DEFAULT="0">
<CFPARAM name="FORM.button_caption"					default="continue">

<CFIF len(trim(URL.CID)) GT 0>
		<CF_CRYP type="de" string="#URL.CID#" key="#request.key#">
		<cfquery name="CheckForExistingOperators" datasource="#application.datasource#">
			SELECT 	operator_ID
			FROM Contract_Main
			WHERE Contract_Main_ID = '#cryp.value#'
		</cfquery>		
	<CFSET FORM.button_caption = "save">

	<CFIF listfind(CheckForExistingOperators.operator_ID, 0, ",") EQ 0>
		<CFSET FORM.FinalItemList = valuelist(CheckForExistingOperators.operator_ID)>	
	</CFIF>


	<CFSET FORM.Contract_Main_ID = cryp.value>
</CFIF>



<CFPARAM NAME="FORM.searchstring" DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="0">
<CFPARAM NAME="FORM.Contract_Main_ID" DEFAULT="">

<CFSET listofitemstodelete = "">

	<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
		<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
			<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
		</CFIF>
	</CFLOOP>

	<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
		<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
			<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
		</CFIF>
	</CFLOOP>

	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFLOOP>
	


<CFIF FORM.finishedselectingitems EQ 1>

		<cfquery name="CheckForExistingOperators" datasource="#application.datasource#">
			SELECT 	operator_ID
			FROM Contract_Main
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</cfquery>		

		<CFIF isdefined("FORM.ALLINCATEGORY")><CFSET FORM.FinalItemList = "ALL"><CFELSE><CFIF listfind(FORM.FinalItemList, "ALL") NEQ 0><CFSET FORM.FinalItemList = listdeleteat(FORM.FinalItemList,listfind(FORM.FinalItemList, "ALL"),",")></CFIF></CFIF>
		<CFIF len(trim(FORM.FinalItemList)) EQ 0><CFSET FORM.FinalItemList = "0"></CFIF>

		<cfquery name="SaveOperator" datasource="#application.datasource#">
			UPDATE Contract_Main
			SET Operator_ID = '#FORM.FinalItemList#'
			WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		</cfquery>
	
	<CF_CRYP type="en" string="#FORM.Contract_Main_ID#" key="#request.key#">
	<CFIF CheckForExistingOperators.operator_ID EQ 0>
		<CFLOCATION url="redirect.cfm?destination=select_brokers.cfm&CID=#cryp.value#">	
	<CFELSE>
		<cflocation url="Contract_Edit_Menu.cfm?CID=#cryp.value#">
	</CFIF>
</CFIF>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">


</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFIF len(FORM.Contract_Main_ID) GT 0><CFSET temp = FORM.Contract_Main_ID></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "op"> 
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">


	<!--- <CFSET URL.Contract_Main_ID = FORM.Contract_Main_ID> --->
	<!--- <CFINCLUDE TEMPLATE="thin_contract_general_display.cfm"> --->

	
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is help file that goes with this content													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
<CFSET helpfilenumber=3>
<cfinclude template="minimal_contract_info.cfm">


	<FORM ACTION="select_operators.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<FIELDSET STYLE="padding:8px; width: 500px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">operator search</LEGEND>
					<TABLE align="center">
						<TR>
							<TD>
							
								<!--- Get All Operator Types --->
								<CFQUERY NAME="Get_Operator_Types" datasource="#application.datasource#">
								Select	distinct Operator_Type
								From	BSA_Operator
								Where	Deleted =0 
								</CFQUERY>
							
								<SELECT NAME="Operator_Type" STYLE="width:200px;">
									<OPTION VALUE="ALL" SELECTED>**ALL** Operator Types</OPTION>
									<CFOUTPUT QUERY="Get_Operator_Types"><OPTION VALUE="#Operator_Type#">#Operator_Type#</OPTION></CFOUTPUT>
								</SELECT>
							</TD>
							<TD>
								<!--- Get all states --->
								<CFQUERY NAME="Get_States" datasource="#application.datasource#">
									Select s.*, c.Country_Sort_Order
									from _states s
									join _country c on s.Country_ID = c.Country_ID
									ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
								</CFQUERY>
	
								<SELECT NAME="Operator_State" SIZE="1" ID="Company_Address_State" STYLE="width:200px;">
									<OPTION VALUE="ALL" SELECTED>**ALL** States</OPTION>
									<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
								</SELECT>
							
							</TD>
							<TD>
								<!--- Get Location Types --->
								<CFQUERY NAME="Get_Location_Types" datasource="#application.datasource#">
								Select	distinct	Operator_Location_Type
								From	BSA_Operator
								Where	deleted = 0
								</CFQUERY>
								<SELECT NAME="Operator_Location_Type" STYLE="width:200px;">
									<OPTION VALUE="All" SELECTED>**ALL** Location Types</OPTION>
									<CFOUTPUT QUERY="Get_Location_Types"><OPTION VALUE="#Operator_Location_Type#">#Operator_Location_Type#</OPTION></CFOUTPUT>
								</SELECT>							
							</TD>
						</TR>
					</TABLE>
					<br>
					Search String: <INPUT TYPE="Text" NAME="searchstring" SIZE="64"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF>><INPUT TYPE="Submit" VALUE="search">
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	
	</FIELDSET>

<BR>

	<CFQUERY NAME="GetOperatorInfo" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Operator
		WHERE BSA_Operator_ID IN(<CFIF len(FORM.FinalItemList) EQ 0 OR FORM.FinalItemList EQ "ALL">0<CFELSE>#FORM.FinalItemList#</CFIF>)
	</CFQUERY>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected operators</LEGEND>
			<CFIF GetOperatorInfo.recordcount GT 0>
				
				<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
					<TR><CFOUTPUT QUERY="GetOperatorInfo">
						<TD NOWRAP BGCOLOR="eeeeee">#GetOperatorInfo.operator_name#<BR>#Operator_City# - #Operator_State#</TD>
		 				<CFIF GetOperatorInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
					</CFOUTPUT>	
				</TABLE>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL"><B>ALL OPERATORS</B><CFELSE><B>NONE</B></CFIF>
			</CFIF>
			<BR>
	</FIELDSET>


<BR><BR>	
	
<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
<INPUT TYPE="checkbox" NAME="ALLINCATEGORY" VALUE="1"  <CFIF FORM.FinalItemList EQ "ALL">checked</CFIF>>SELECT ALL OPERATORS

<cfinclude template="select_forms_buttons.cfm">

<CFIF isdefined("FORM.DOSEARCH")>
	<CFSET form.searchstring = trim(form.searchstring)>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Operator
		WHERE
			0 = 0
			AND DELETED = 0 
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				operator_Name = 'form.searchstring'
				OR
				operator_Name LIKE '%#form.searchstring#'
				OR
				operator_Name LIKE '#form.searchstring#%'
				OR
				operator_Name LIKE '%#form.searchstring#%'
			)
			OR
			(
				operator_type = 'form.searchstring'
				OR
				operator_type LIKE '%#form.searchstring#'
				OR
				operator_type LIKE '#form.searchstring#%'
				OR
				operator_type LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
		
		<CFIF form.Operator_Type NEQ "ALL">
			AND	Operator_Type	=	'#form.Operator_Type#'
		</CFIF>
		
		<CFIF form.Operator_Location_Type NEQ "ALL">
			AND	Operator_Location_Type	=	'#form.Operator_Location_Type#'
		</CFIF>
		
		<CFIF form.Operator_State NEQ "ALL">
			AND	Operator_State	=	'#form.Operator_State#'
		</CFIF>
		
			
	</CFQUERY>
<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many operators in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</SCRIPT>
	

	<FIELDSET STYLE="padding:8px; width:800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Operator<CFELSE>Operators</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
		
			<CFIF TheQuery.recordcount GTE 500>
				<FONT SIZE="+1"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
			<CFELSE>
			
				<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="100%">
					<TR ID="header" BGCOLOR="#ffce84">
						<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Operators"></TD>
						<TD align="left">Operator Name</TD>
						<!--- <TD align="left">Type</TD> --->
						<TD align="left" WIDTH="150">Location<BR>Type</TD>
						<TD align="left">City<BR>State</TD>
						<TD align="left"># of<BR>Locations&nbsp;</TD>
						<TD align="left" VALIGN="bottom" WIDTH="30%">Doing Business As</TD>
	
					</TR>
				<CFOUTPUT QUERY="TheQuery">
					<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
						<TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>></TD>
						<TD NOWRAP>#TheQuery.operator_name#</TD>
						<!--- <TD>#TheQuery.operator_type#&nbsp;</TD> --->
						<TD NOWRAP>#TheQuery.Operator_Location_Type#&nbsp;</TD>
						<TD NOWRAP>#TheQuery.Operator_City#<BR>#TheQuery.Operator_State#&nbsp;</TD>
						<TD NOWRAP>#numberformat(TheQuery.Operator_Number_Of_Locations,'_,___,___')#&nbsp;</TD>
						<TD>#TheQuery.Operator_DBA#&nbsp;</TD>
	 				</TR>
				</CFOUTPUT>
				</TABLE>
			</CFIF>
			
			
		</CFIF>
	</FIELDSET>	
</CFIF>

	<CFPARAM name="TheQuery.Recordcount" default="0">
	<SCRIPT>
		function resetform() {
			document.all.FinalItemList.value = 0;
			document.all.AlreadySelectedItems.value = 0;
		
			<CFIF TheQuery.Recordcount GT 0>
				document.all.SelectedITEMS.value = 0;
				for(var x=0; x<document.all.MyForm.elements.length;x++) {
					document.all.MyForm.elements[x].checked = false
				}
				
			</CFIF>
			document.all.MyForm.submit();
		}
	</SCRIPT>

<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="<CFOUTPUT>#Form.AlreadySelectedItems#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="Contract_Main_ID" VALUE="<CFOUTPUT>#FORM.Contract_Main_ID#</CFOUTPUT>">
<BR>
<!--- <cfinclude template="select_forms_buttons.cfm"> --->

</FORM>

</BLOCKQUOTE></BLOCKQUOTE>
 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 