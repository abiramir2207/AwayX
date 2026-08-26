<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!--- <CFIF Get_Profile_Settings.BB_Create EQ 1><A HREF="/billbacks/Auto_Billback/index.cfm">Create Auto billback</A><CFELSE><font class="no_access">Create Auto billback</font></CFIF><BR> --->


<CFPARAM NAME="URL.BBID" DEFAULT="">


<CFPARAM NAME="FORM.BBID" DEFAULT="#URL.BBID#">
<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFPARAM NAME="FORM.NotesOnDistributor" DEFAULT="">
<CFPARAM NAME="FORM.Program_List" DEFAULT="">
<CFPARAM NAME="FORM.FilterSearchPrograms" DEFAULT="">
<CFPARAM NAME="FORM.Old_Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Old_Program_List" DEFAULT="">

<!--- <CFSET InfoBar_BBID = FORM.BBID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm"> --->

<CFIF URL.BBID NEQ "">
	<CFQUERY NAME="GetAutoBB_BasicInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		Distributor_ID, 
					BB_Distributor_Notes
					
		FROM 		Billback_Distributor
		
		WHERE 		Billback_ID = <cfqueryparam value="#URL.BBID#" cfsqltype="CF_SQL_VARCHAR">
		AND 		Deleted = 0
	</CFQUERY>
	<CFQUERY NAME="ProgramList" DATASOURCE="#Application.Datasource#">
		SELECT 	Program_ID 
		FROM 	Billback_Program
		WHERE	Billback_ID = <cfqueryparam value="#URL.BBID#" cfsqltype="CF_SQL_VARCHAR">
		AND		Deleted = 0
	</CFQUERY>
	<CFSET ProgrmID_List = VALUELIST(ProgramList.Program_ID)>
	
	
	
	<CFSET FORM.Distributor_List = GetAutoBB_BasicInfo.Distributor_ID>
	<CFSET FORM.NotesOnDistributor = GetAutoBB_BasicInfo.BB_Distributor_Notes>
	<CFSET FORM.Program_List = ProgrmID_List>
</CFIF>

<!--- <cfinclude template="/billbacks/capture/billback_number_generator.cfm">
<CFSET FORM.BB_Code = generator_billback_number> --->



<STYLE TYPE="text/css">
.DataTitleCell {
	text-align : right;
	font-weight : bold;
	vertical-align : top;
}
TABLE.UnderLined TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>


<CFIF FORM.Old_Distributor_List NEQ "">
	<CFIF FORM.Old_Distributor_List NEQ FORM.Distributor_List>
		<CFLOOP LIST="#FORM.Old_Program_List#" INDEX="Item">			
			<CFSET ItemPosition = ListFind(FORM.Program_List,Item)>
			<CFIF ItemPosition NEQ 0>
				<CFSET FORM.Program_List = ListDeleteAt(FORM.Program_List,ItemPosition)>
			</CFIF>
		</CFLOOP>
	</CFIF>
</CFIF>

<CFOUTPUT>
<BR><BR>
<FORM NAME="Dist_Prog" ACTION="AutoBB_Distributor_Program_Form.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="BBID" VALUE="#FORM.BBID#">
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
<INPUT TYPE="Hidden" NAME="Old_Distributor_List" VALUE="#FORM.Old_Distributor_List#">
<INPUT TYPE="Hidden" NAME="Program_List" VALUE="#FORM.Program_List#">
<INPUT TYPE="Hidden" NAME="Old_Program_List" VALUE="#FORM.Old_Program_List#">
<INPUT TYPE="Hidden" NAME="FilterSearchPrograms" VALUE="#FORM.FilterSearchPrograms#">
<!--- <INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly" VALUE="#FORM.SelectSingleSearchResultOnly#"> --->
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="10" ALIGN="Center" >
	
	<CFIF FORM.Distributor_List NEQ "">
		<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
			SELECT BSA_Foodservice_Customers_ID,Name 
			FROM BSA_Foodservice_Customers 
			WHERE
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = <cfqueryparam value="#FORM.Distributor_List#" cfsqltype="CF_SQL_VARCHAR">
				AND
				BSA_Foodservice_Customers.Deleted = 0
				AND
				BSA_Foodservice_Customers.Active_Code = 'A'
			ORDER BY Name
		</CFQUERY>
	<CFSET Selected_Distributor=Dist_Search_Result.Name>
	</CFIF>	
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Payee"></span>&nbsp;#application.returned_customer_setting.distributor_label_singular# (Payee):</TD>
		<TD ROWSPAN="5" BGCOLOR="0000CC" WIDTH="2px"></TD>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
		<TD><SPAN STYLE="WIDTH:285px;border:1px solid gray;">#Selected_Distributor#</SPAN><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif" title="click to search distributor" width="20" height="20"></A></TD>
	</TR>
	
	<TR>
		<TD class="DataTitleCell">&nbsp;Notes on #lcase(application.returned_customer_setting.distributor_label_singular)#:</TD>
		<TD>
			<CF_SCALABLETEXTAREA 
				NAME="NotesOnDistributor"
				ID="NotesOnDistributor"
				COLS="57" 
				ROWS="5" 
				incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">" 
				decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">">#Form.NotesOnDistributor#</CF_SCALABLETEXTAREA>
		</TD>
	</TR>
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Program"></span>&nbsp;Program:</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A ONCLICK="SearchPrograms(1)" STYLE="cursor: pointer;">add</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>		
	</TR>
	<CFIF FORM.Program_List NEQ "">
		<CFSET TitleLen = 50>
		<CFQUERY NAME="SelectedPrograms" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number,
						Contract_main_id,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Units_of_Measure.Unit_Of_Measure_Desc
					
			FROM 		Contract_Main
			INNER JOIN 	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Contract_Main.Contract_Quantity_UOM_IDX 
			
			WHERE		Contract_Main_ID IN (#LISTQUALIFY(FORM.Program_List,"'",",")#)
		</CFQUERY>
		<TR>
			<TD>&nbsp;</TD>			
			<TD>
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="UnderLined" STYLE="Border-Left: 1px solid Navy; Border-Bottom: 1px solid Navy; Border-Right: 1px solid Navy;Border-Top: 1px solid Navy;">
					<CFLOOP QUERY="SelectedPrograms">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<TD VALIGN="Top" <CFIF CurrentRow EQ RecordCount>STYLE="font-size:12px;color:navy;font-weight:bold;Border: None;"<CFELSE>style="font-size:12px;color:navy;font-weight:bold;"</CFIF>>
							<cf_cryp	type = "en" string = "#contract_main_id#" key = "#request.key#">
							<CFSET CID=cryp.value>
				 			<cfset targetURL = "/scorecard/program_display.cfm?CID=#CID#">
							<cfset targetWindow = "_blank">
							<cfset windowWidth = 800>
							<cfset windowHeight = 600> 
							<A <cfif contract_main_id neq "">onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;" target="#targetWindow#" HREF="#targetURL#" TITLE="View the details for program #Contract_Number#"</cfif>>

							#Contract_number#&nbsp;&nbsp;&nbsp;&nbsp;
						</TD>
						<TD VALIGN="Top" <CFIF CurrentRow EQ RecordCount>STYLE="font-weight:bold;Border: None;"<CFELSE>style="font-weight:bold;"</CFIF>>#Left(Contract_Title,TitleLen)#<BR>#DateFormat(Contract_Start_Date,"m/d/yyyy")# to #DateFormat(Contract_End_Date,"m/d/yyyy")# for #NumberFormat(Contract_Quantity,"_,___")# #LCase(Unit_Of_Measure_Desc)#</TD>
					</TR>
					</CFLOOP>					
				</TABLE>
			</TD>
		</TR>				
		
		<TR>
			<TD class="DataTitleCell">&nbsp;Include all items on the invoice:</TD>
			<TD><INPUT TYPE="CheckBox" NAME="Get_All_Items" VALUE="1"></TD>
		</TR>
	</CFIF>
		
	<TR>
		<TD COLSPAN="2"></TD>
		<TD><BR><BR>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"CheckForErrors();"
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
</CFOUTPUT>



<SCRIPT LANGUAGE="JavaScript">
function showDistSearchWindow() 
{			
	document.all.Old_Distributor_List.value = document.all.Distributor_List.value;	
	document.all.Old_Program_List.value = document.all.Program_List.value;
	document.all.Form_Submitted.value=0;		
	document.Dist_Prog.target = "_self";
	document.Dist_Prog.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";		
	NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=Dist_Prog", "searchwindow", 800, 600, "yes", "yes")
}

function SearchPrograms() 
{
	ErrorCount = 0;
	error_text 		= "Please select a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> (Payee) and try again";	
	error_oSpan 	= document.all.error_BB_Payee;	
	clearQueue(document.all.error_BB_Program)
	clearQueue(error_oSpan);	
	
	if (document.all.Distributor_List.value == "")
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);		
	}	
	
	if(ErrorCount == 0) 
	{
		document.Dist_Prog.FilterSearchPrograms.value 	= 2;							
		NewWindow("../search_screens/search_programs.cfm?Formname=Dist_Prog&fieldname=Program_List&SelectSingleSearchResultOnly=1", "programswindow", 800, 600, "yes", "yes")
	}
	else 
	{
		showMessageWindow()
	}	
}

function CheckForErrors() 
{
	todaysDate = new Date();
	
	ErrorCount = 0;
	
	// Payee
	error_text 		= "Please select a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> (Payee)";
	error_oSpan 	= document.all.error_BB_Payee;
	if (document.all.Distributor_List.value == "")
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);
	}
		
	//Program
	error_text 		= "Please select at least a program";
	error_oSpan 	= document.all.error_BB_Program;
	if (document.all.Program_List.value == "")
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);
	}
	
	if(ErrorCount == 0) 
	{
		document.Dist_Prog.action = "Auto_Distributor_Program_Action.cfm";	
		document.Dist_Prog.submit()
	}
	else 
	{
		showMessageWindow()
	}		
}	
</SCRIPT>
<CF_MessageWindow>


<cfset local_bbid = FORM.BBID>
<cfinclude template="/billbacks/capture/bb_menu_stats.cfm">

<script>
	if(window.parent.payee_program_tab)
	{
		window.parent.current_menu_item = "payee_program";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>


</body>
</html>
