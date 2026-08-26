<!--- select_distributor_program.cfm- Copyright (c) 2004 Blacksmith Applications, Inc.--->
<!--- Created By: Tim Ford on 05/12/2005 --->
<!--- Distributor/Program selection screen --->

<CFPARAM NAME="URL.BBID" DEFAULT="">


<CFPARAM NAME="FORM.BBID" DEFAULT="#URL.BBID#">
<CFPARAM NAME="Selected_Distributor" DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">
<CFPARAM NAME="FORM.NotesOnDistributor" DEFAULT="">
<CFPARAM NAME="FORM.Program_List" DEFAULT="">
<CFPARAM NAME="FORM.FilterSearchPrograms" DEFAULT="0">
<CFPARAM NAME="FORM.Old_Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Old_Program_List" DEFAULT="">
<CFPARAM NAME="RunSearch" DEFAULT="0">

<!--- <CFSET InfoBar_BBID = FORM.BBID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm"> --->

<CFIF URL.BBID NEQ "">
	<cfset useLakebaseForGetAutoBB_BasicInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForGetAutoBB_BasicInfo>
	<cftry>
		<cfset GetAutoBB_BasicInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0",
				"select" = "distributor_id,bb_distributor_notes"
			}), "distributor_id,bb_distributor_notes"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAutoBB_BasicInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAutoBB_BasicInfo>
<CFQUERY NAME="GetAutoBB_BasicInfo" DATASOURCE="#Application.Datasource#">
		SELECT 		Distributor_ID, 
					BB_Distributor_Notes
					
		FROM 		Billback_Distributor
		
		WHERE 		Billback_ID = '#URL.BBID#' AND Deleted = 0
	</CFQUERY>
</cfif>
	<cfset useLakebaseForProgramList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForProgramList>
	<cftry>
		<cfset ProgramList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForProgramList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForProgramList>
<CFQUERY NAME="ProgramList" DATASOURCE="#Application.Datasource#">
		SELECT 	Program_ID 
		FROM 	Billback_Program
		WHERE	Billback_ID = '#URL.BBID#' AND 
				Deleted = 0
	</CFQUERY>
</cfif>
	<CFSET ProgrmID_List = VALUELIST(ProgramList.Program_ID)>
	
	
	
	<CFSET FORM.Distributor_List = GetAutoBB_BasicInfo.Distributor_ID>
	<CFSET FORM.NotesOnDistributor = GetAutoBB_BasicInfo.BB_Distributor_Notes>
	<CFSET FORM.Program_List = ProgrmID_List>
</CFIF>


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
<FORM NAME="Dist_Prog" ACTION="index.cfm" METHOD="POST">
<INPUT TYPE="Hidden" NAME="command" VALUE="#FORM.command#">
<INPUT TYPE="Hidden" NAME="BBID" VALUE="#FORM.BBID#">
<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">
<!--- <INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#"> --->
<INPUT TYPE="Hidden" NAME="Old_Distributor_List" VALUE="#FORM.Old_Distributor_List#">
<INPUT TYPE="Hidden" NAME="Program_List" VALUE="#FORM.Program_List#">
<INPUT TYPE="Hidden" NAME="Old_Program_List" VALUE="#FORM.Old_Program_List#">
<INPUT TYPE="Hidden" NAME="FilterSearchPrograms" VALUE="#FORM.FilterSearchPrograms#">
<!--- <INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly" VALUE="#FORM.SelectSingleSearchResultOnly#"> --->
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="10" ALIGN="Center">
	<CFIF FORM.Program_List NEQ "">
		<CFQUERY NAME="SelectedPrograms" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Units_of_Measure.Unit_Of_Measure_Desc,
						Name,
						Rebate_Recipient_Customer_ID
					
			FROM 		Contract_Main
			INNER JOIN 	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Contract_Main.Contract_Quantity_UOM_IDX 
			Left Outer Join  BSA_Foodservice_Customers C on C.BSA_Foodservice_Customers_ID = Contract_Main.Rebate_Recipient_Customer_ID
			
			WHERE		Contract_Main_ID IN (#LISTQUALIFY(FORM.Program_List,"'",",")#)
		</CFQUERY>
		<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#SelectedPrograms.Rebate_Recipient_Customer_ID#">
	<cfelse>
		<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
	</cfif>
	
	<CFIF FORM.Distributor_List NEQ "">
		<cfset useLakebaseForDist_Search_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDist_Search_Result>
	<cftry>
		<cfset Dist_Search_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#FORM.Distributor_List#'
				--AND
				--BSA_Foodservice_Customers.Deleted = 0
				--AND
				--BSA_Foodservice_Customers.Active_Code = 'A",
				"order" = "name.asc",
				"select" = "bsa_foodservice_customers_id,name"
			}), "bsa_foodservice_customers_id,name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDist_Search_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDist_Search_Result>
<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
			SELECT BSA_Foodservice_Customers_ID,Name 
			FROM BSA_Foodservice_Customers 
			WHERE
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_List#'
				--AND
				--BSA_Foodservice_Customers.Deleted = 0
				--AND
				--BSA_Foodservice_Customers.Active_Code = 'A'
			ORDER BY Name
		</CFQUERY>
</cfif>
	<CFSET Selected_Distributor=Dist_Search_Result.Name>
	</CFIF>
	
	
	
	<CFIF len(trim(Selected_Distributor)) gt 0> <!--- tell the program search (popup from JS below) to fire if a distributor is selected --->
		<cfset RunSearch = 1>
	</CFIF>	
	
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Payee"></span>&nbsp;#application.returned_customer_setting.distributor_label_singular# (Rebate Recipient):</TD>
		<TD ROWSPAN="5" BGCOLOR="0000CC" WIDTH="2px"></TD>
		<CFPARAM NAME="Selected_Name" 	DEFAULT="">
		<TD><SPAN STYLE="WIDTH:285px;border:1px solid gray;"><cfif FORM.Program_List NEQ "">#SelectedPrograms.Name#<cfelse>#Selected_Distributor#</cfif></SPAN><CFIF FORM.Program_List EQ ""><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif" title="click to search distributor" width="20" height="20"></A></cfif></TD>
	</TR>
	<TR>
		<TD class="DataTitleCell"><span id="error_BB_Program"></span>&nbsp;Program:</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A ONCLICK="SearchPrograms(1)" STYLE="cursor: pointer;">add</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>		
	</TR>
	<CFIF FORM.Program_List NEQ "">
		<CFSET TitleLen = 50>
		<!--- <CFQUERY NAME="SelectedPrograms" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Units_of_Measure.Unit_Of_Measure_Desc
					
			FROM 		Contract_Main
			INNER JOIN 	Units_of_Measure ON Units_of_Measure.Unit_Of_Measure_ID = Contract_Main.Contract_Quantity_UOM_IDX 
			
			WHERE		Contract_Main_ID IN (#LISTQUALIFY(FORM.Program_List,"'",",")#)
		</CFQUERY> --->
		<TR>
			<TD>&nbsp;</TD>			
			<TD>
				<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" CLASS="UnderLined" STYLE="Border-Left: 1px solid Navy; Border-Bottom: 1px solid Navy; Border-Right: 1px solid Navy;Border-Top: 1px solid Navy;">
					<CFLOOP QUERY="SelectedPrograms">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
						<TD VALIGN="Top" <CFIF CurrentRow EQ RecordCount>STYLE="font-size:12px;color:navy;font-weight:bold;Border: None;"<CFELSE>style="font-size:12px;color:navy;font-weight:bold;"</CFIF>>#Contract_number#&nbsp;&nbsp;&nbsp;&nbsp;</TD>
						<TD VALIGN="Top" <CFIF CurrentRow EQ RecordCount>STYLE="font-weight:bold;Border: None;"<CFELSE>style="font-weight:bold;"</CFIF>>#Left(Contract_Title,TitleLen)#<BR>#DateFormat(Contract_Start_Date,"m/d/yyyy")# to #DateFormat(Contract_End_Date,"m/d/yyyy")# for #NumberFormat(Contract_Quantity,"_,___")# #LCase(Unit_Of_Measure_Desc)#</TD>
					</TR>
					</CFLOOP>					
				</TABLE>
			</TD>
		</TR>				
		
	</CFIF>
		
	<TR>
		<TD COLSPAN="2"></TD>
		<TD><BR><BR>
			<CF_button
				button_name		=	""
				button_caption	=	"next"
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
	
	/*if (document.all.Distributor_List.value == "")
	{
		ErrorCount++;
		queueMessage(error_text, error_oSpan);
	}
	else
	{
		clearQueue(error_oSpan);		
	}	*/ 
	
	if(ErrorCount == 0) 
	{
		//document.Dist_Prog.FilterSearchPrograms.value 	= 2;							
		NewWindow("../search_screens/search_programs.cfm?Formname=Dist_Prog&fieldname=Program_List&SelectSingleSearchResultOnly=1&DiscIDFilter=1&DistName=<cfoutput>#Selected_Distributor#&runsearchonfirstload=#RunSearch#</cfoutput>", "programswindow", 800, 600, "yes", "yes")
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
	error_text 		= "Please select a <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> (Rebate Recipient)";
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
		document.all.command.value = "selComponent";	
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

