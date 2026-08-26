<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">
<CFIF isdefined("URL.FormName")>
	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">
		<input type="hidden" name="FilterSearchPrograms" 	value="0">
		<input type="hidden" name="FilterType" 				value="0">
		<input type="hidden" name="FilterDataList"			value="0">
		<input type="hidden" name="runsearchonfirstload"	value="0">
		<INPUT NAME="Distributor_List" TYPE="Hidden" VALUE="<cfoutput>#URL.Distributor_List#</cfoutput>">
		
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value
			<!--- if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterSearchPrograms.value == 1) {
				this.document.all.FilterSearchPrograms.value 	= 1;
				this.document.all.FilterType.value 				= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterType.value;
				this.document.all.FilterDataList.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterDataList.value;
			}
			
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload != null){
				if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload.value == 1) {
					this.document.all.runsearchonfirstload.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload.value;	
				}			
			} --->
			document.all.MyForm.submit()
		}
		else{
			alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
			window.close()
		}
	</script>
	<cfabort>
</CFIF>


<CFSET PAGE_TITLE="Select Programs">
<CFSET GROUP="Contracts">

<CFPARAM name="FORM.button_caption"					default="continue">
<CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 					DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 		DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedResults"				Default="1">
<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<CFPARAM NAME="FORM.AllowImportAll"					Default="0">
<CFPARAM NAME="FORM.Distributor_List"				Default="0">
<cfset FinalItemList="">

<CFSET FORM.SelectSingleSearchResultOnly = 1>

<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=10>

	
<CFSET FORM.LoadSavedResults=0>

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
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>

<cfif len(trim(Form.FinalItemList)) GT 0>
	<script>
		//opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.Broker_List.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.<CFOUTPUT>#Form.FieldName#</CFOUTPUT>.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		//opener.document.KnownProgramForm.submit();
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit()
		window.close()		
	</script>
	<CFABORT>
<cfelse>
	<div align="Center"><font color="red"><strong>You must select a program</strong></font></div>
</cfif>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
SELECT
{
 width: 190px;
}
</style>

<SCRIPT LANGUAGE="JavaScript">
	
	function dist_lookup_Pick(index,thisObj)
	{
		switch(index)
		{
			case 1:			
				disableDiv("SP_Family_Name",false,false);
				disableDiv("SP_Buying_Group",true,false);
				disableDiv("SP_Distributor_Name",true,false);				
				break;		
			case 2:
				disableDiv("SP_Family_Name",true,false);
				disableDiv("SP_Buying_Group",false,false);
				disableDiv("SP_Distributor_Name",true,false);				
				break;
			case 3:
				disableDiv("SP_Family_Name",true,false);
				disableDiv("SP_Buying_Group",true,false);
				disableDiv("SP_Distributor_Name",false,false);
				break;			
			default:			
		}
		
	}
	
	function start_End_Date(start_D,thisObj)
	{
		var spName;
		if(start_D == 1)
		{
			spName = "SP_Start_date";
		}
		else
		{
			spName = "SP_End_date";			
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}
	
	function disable_start_End_Date()
	{
		start_End_Date(1,document.all.Start_date_Operator);
		start_End_Date(2,document.all.End_date_Operator);
	}
	
	
	function disableDiv(divName,bDis,bHide)
	{
		oDiv = document.all.item(divName);	
		if(oDiv)
		{
			oDiv.disabled = bDis;
			//oDiv.onmousedown=new Function ("return false");
			var i,itemLen = oDiv.all.length;
			for(i=0;i<itemLen;i++)
			{
				oDiv.all[i].disabled = bDis;
				if((oDiv.all[i].tagName == "INPUT") && bDis)
				{
					oDiv.all[i].style.backgroundColor='cccccc';
				}
				else if((oDiv.all[i].tagName == "INPUT") && !bDis)
				{
					oDiv.all[i].style.backgroundColor='ffffff';
				}
				
				
				if((oDiv.all[i].tagName == "SELECT") && bDis)
				{
					oDiv.all[i].selectedIndex = 0;
					oDiv.all[i].style.backgroundColor='cccccc';
				}
				else if((oDiv.all[i].tagName == "SELECT") && !bDis)
				{
					if(oDiv.all[i].options.length > 0) oDiv.all[i].selectedIndex = 0;
				}
				if((oDiv.all[i].tagName == "SELECT") && !bDis)
				{
					oDiv.all[i].style.backgroundColor='ffffff';
				}
			}
			var args = arguments;
			var argLen = args.length;
			if(argLen <3)
			{
				return;
			}
			if(args[2])
			{
				oDiv.style.display = "none";
			}
			else
			{
				oDiv.style.display = "";		
			}
			if(argLen <4)
			{
				return;
			}
			var parObj = document.all.item(args[3]);
			
			if(args[2])
			{
				parObj.style.display = "none";
			}
			else
			{
				parObj.style.display = "";
			}
		}
	}

	 document.body.onload=new Function ("dist_lookup_Pick(3,document.all.MyForm.elements[0]);disable_start_End_Date();")

	function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
	{
		var formObj;
		formObj = document.all.MyForm;
		formObj.sort_by.value = thisSortItem;
		formObj.sort_Order.value = thisSortOrder;
		formObj.submit();
		return false;
	}
</SCRIPT>

<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">

<!---Set all default parameters for main search page--->
<CFPARAM NAME="FORM.Status" DEFAULT="0">
<CFPARAM NAME="FORM.ProgramType" DEFAULT="0">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
<CFPARAM NAME="FORM.Customer_Filter" DEFAULT="">
<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
<CFPARAM NAME="FORM.Start_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">

<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
<CFPARAM NAME="FORM.Program_Number" DEFAULT="">		

<BR><B>
<FONT SIZE="2" COLOR="Red">[</FONT>
	<FONT SIZE="2" COLOR="Blue">
	<A HREF="" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;" TITLE="Help">
	read me first
	</A>
</FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">program search</LEGEND>
			
			<TABLE BORDER="0">
				<TR VALIGN="TOP">
					<TD>
						<span ID="searchItemLabel">Status</span><BR>
<!-----------------------------------------------------------------------
						Get Status from DB
--------------------------------------------------------------------------->
						<CFQUERY NAME="Get_Status" DATASOURCE="#Application.Datasource#">
						Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
						From 	Contract_Status_Types
						Where	
							Contract_Status_Type_ID > 4
						Order By Contract_Status_Type_ID
						</CFQUERY>
						
						<SELECT NAME="Status">
							<OPTION VALUE="0">**ALL** Status</OPTION>
							<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
						</SELECT>
						<span ID="searchItemLabel">Program Type</span><BR>
<!-----------------------------------------------------------------------
Get Program Types from DB
--------------------------------------------------------------------------->
						<CFQUERY NAME="Get_ProgramTypes" DATASOURCE="#Application.Datasource#">
						Select	ProgramControl_Panel_Options_ID,Created_Type
						From 	Program_Control_Panel_Options
						Where 	Deleted=0 AND Generic_Type = 'Distributor Trade/Shelter' AND Active = 1
						Order By Created_Type
						</CFQUERY>
						
						<SELECT NAME="ProgramType">
							<OPTION VALUE="0">**ALL** Program Type</OPTION>
							<CFOUTPUT QUERY="Get_ProgramTypes"><OPTION VALUE="#trim(Get_ProgramTypes.ProgramControl_Panel_Options_ID)#"#IIF(trim(FORM.ProgramType) EQ Get_ProgramTypes.ProgramControl_Panel_Options_ID, DE(" SELECTED"), DE(""))#>#trim(Get_ProgramTypes.Created_Type)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<TD>
								<span ID="searchItemLabel">Broker</span><BR>
								<CFQUERY NAME="GetBrokers" DATASOURCE="#Application.Datasource#">
								SELECT BSA_Foodservice_Brokers_ID, Broker_Name
								FROM Broker_Active
								WHERE len(Broker_Name) > 0 
								ORDER BY Broker_Name
								</CFQUERY>
								<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
								<SELECT NAME="Broker_ID" style="width: 200px;">
									<OPTION VALUE="0">**ALL** Brokers</OPTION>
									<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker_ID) EQ GetBrokers.BSA_Foodservice_Brokers_ID, DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
								</SELECT>
								<CFOUTPUT>
								<span ID="searchItemLabel">#application.returned_customer_setting.operator_label_singular#</span><BR>								
								<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
								<INPUT NAME="Operator_Name" ID="Operator_Name" VALUE="#FORM.Operator_Name#">
								</CFOUTPUT>
					</TD>
					<TD>
												
						<CFPARAM NAME="FORM.Customer_Filter" DEFAULT="">						
						<TABLE>
							<TR>
								<TD>
								<cfif Distributor_List IS 0><INPUT OnClick="JavaScript:dist_lookup_Pick(1,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="family_name"<CFIF FORM.Customer_Filter EQ "family_name"> CHECKED</CFIF>></TD>
								<TD NOWRAP><span ID="searchItemLabel">Family Name</span></TD>
								<TD>
								<cfquery name="GetFamilyNames" DATASOURCE="#Application.Datasource#">
									SELECT *
									FROM Distributor_Family
									WHERE Deleted = 0 
									ORDER BY Family_Name
								</cfquery>
								<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
								<SPAN ID="SP_Family_Name">
								<SELECT NAME="Family_Name" style="width: 200px;">
									<OPTION VALUE="0">**ALL** Family Names</OPTION>
									<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
								</SELECT>
								</span>
							</TR>
							<TR>
								<TD><INPUT OnClick="JavaScript:dist_lookup_Pick(2,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="buying_group"<CFIF FORM.Customer_Filter EQ "buying_group"> CHECKED</CFIF>></TD>
								
								<TD NOWRAP><span ID="searchItemLabel">Buying Groups</span></TD>
								<TD>
								<cfset useLakebaseForGetBuyingGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_buying_groups")>
<cfif useLakebaseForGetBuyingGroups>
	<cftry>
		<cfset GetBuyingGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_buying_groups", {
				"deleted" = "eq.0",
				"active_code" = "eq.A",
				"order" = "buying_group_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBuyingGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBuyingGroups>
<cfquery name="GetBuyingGroups" DATASOURCE="#Application.Datasource#">
									SELECT *
									FROM Distributor_Buying_Groups
									WHERE Deleted = 0
									AND	Active_Code = 'A'
									ORDER BY Buying_Group_Name
								</cfquery>
</cfif>
								<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
								<SPAN ID="SP_Buying_Group">
								<SELECT NAME="Buying_Group" style="width: 200px;">
									<OPTION VALUE="0">**ALL** Buying Groups</OPTION>
									<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
								</SELECT>
								</span>
							</TR>
							<TR>
							<TD><INPUT CHECKED OnClick="JavaScript:dist_lookup_Pick(3,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="buying_group"<CFIF FORM.Customer_Filter EQ "buying_group"> CHECKED</CFIF>></TD>
								
								<TD NOWRAP ALIGN="RIGHT"><span ID="searchItemLabel"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></span>
								</TD>
								<TD>
								<CFOUTPUT>
									<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
								<SPAN ID="SP_Distributor_Name">
								<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#FORM.Distributor_Name#">
								</SPAN>
								</CFOUTPUT>
								<!---If they have a distributor from the ledger page--->
								<cfelse>
								<TD NOWRAP COLSPAN="2" ALIGN="RIGHT"><span ID="searchItemLabel"><strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>:</strong></span>
								</TD>
								<TD>
								<CFOUTPUT>
								
								<INPUT Type="Hidden" NAME="Distributor_Name" ID="Distributor_Name" VALUE="#Distributor_List#"><strong>#Distributor_List#</strong>
								</cfoutput>
								</cfif>
								
								</TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
				<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
				<CFSET Date_Operator_Symbols=" ,>=,=,<=">
				<TR>
					<TD VALIGN="TOP">
						<CFOUTPUT>
						<span ID="searchItemLabel">Start date</span>
							<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
						<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:45px">
					
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
						
						<CFPARAM NAME="FORM.Start_date" DEFAULT="">
						<SPAN ID="SP_Start_date">
						<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
						</SPAN>
						</CFOUTPUT>
					</TD>
					<TD VALIGN="TOP">
						<CFOUTPUT>
						<span ID="searchItemLabel">End date</span>
							<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
						<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" STYLE="WIDTH:45px">
					
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
							<CFPARAM NAME="FORM.End_date" DEFAULT="">
						<SPAN ID="SP_End_date">
						<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
						</SPAN>
						</CFOUTPUT>
					</TD>
					<TD NOWRAP ALIGN="left">
						<TABLE>
							<TR>
								<TD>
									<span ID="searchItemLabel">Sort By</span>
								</TD>
								<TD>
									<CFSET sort_By_List="Number,Title,Status,Program Type,Start Date,End date">
									<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
									<CFOUTPUT>
									<CFSET sort_By_List=ListSort(sort_By_List,"Text")>
									<SELECT ID="sort_by" NAME="sort_by">
									<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
										<CFSET thisItem=Trim(thisItem)>
										<OPTION VALUE="#thisItem#"<CFIF thisItem EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
									</CFLOOP>
									</SELECT>
									</CFOUTPUT>
								</TD>
							</TR>
							<TR>
								<TD>
									<span ID="searchItemLabel">Order</span>
								</TD>
								<TD>
										<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
									<SELECT ID="sort_Order" NAME="sort_Order">
										<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
										<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
									</SELECT>
								</TD>
							</TR>
						</TABLE>
					</TD>					
				</TR>
				<TR>
					<TD NOWRAP ALIGN="left" COLSPAN="2">
							<CFPARAM NAME="FORM.Program_Title" DEFAULT="">							
						Program Title<BR>
						<INPUT TYPE="Text" NAME="Program_Title" STYLE="WIDTH:380px" SIZE="64"<CFIF len(trim(FORM.Program_Title)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Title)#</CFOUTPUT>"</CFIF>>
					</TD>
					<TD NOWRAP ALIGN="left" COLSPAN="2">
												
				<CFPARAM NAME="FORM.Program_Number" DEFAULT="">						

						Program Number<BR>
						<INPUT TYPE="Text" NAME="Program_Number" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Number)#</CFOUTPUT>"</CFIF>>
					</TD>
				</TR>
				<TR>
					<TD ALIGN="left" NOWRAP>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
					&nbsp;&nbsp;
					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.submit();">search programs</a><FONT COLOR="#FF0000">]</FONT></B>
					</TD>
				</TR>
			</TABLE>
			
		
		
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
	</FIELDSET>


	

<br>


<CFIF isdefined("FORM.DOSEARCH")>

<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->

<CFSET sql_Sort_By="contract_main.contract_number">

<!------Number,Title,Status,Program Type,Start Date,End date----->
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Number">
		<CFSET sql_Sort_By="contract_main.contract_number">
	</CFCASE>
	<CFCASE value="Title">
		<CFSET sql_Sort_By="contract_main.contract_Title">
	</CFCASE>
	<CFCASE value="Status">
		<CFSET sql_Sort_By="contract_main.Contract_Status_Type_IDX">
	</CFCASE>
	<CFCASE value="Program Type">
		<CFSET sql_Sort_By="Program_Control_Panel_Options.Created_Type">

	</CFCASE>
	<CFCASE value="Start Date">
		<CFSET sql_Sort_By="contract_main.Contract_Start_Date">

	</CFCASE>
	<CFCASE value="End date">
		<CFSET sql_Sort_By="contract_main.Contract_End_Date">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>

<CFSET sql_Sort_By="#sql_Sort_By# #sql_Sort_By_Order#">


<!--- <!--- Distributor --->
				<cfset useLakebaseForgetPayeeFilter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForgetPayeeFilter>
	<cftry>
		<cfset getPayeeFilter = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"bsa_foodservice_customers_id" = "eq.#FORM.FilterDataList#",
				"deleted" = "eq.0",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeFilter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeFilter>
<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Distributors
					WHERE BSA_Foodservice_Customers_ID = '#FORM.FilterDataList#' AND Deleted = 0
				</cfquery>
</cfif>
				<CFIF getPayeeFilter.recordcount EQ 0>
					<CFSET Filter_CID_List = 0>
				<CFELSE>
					<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
				</CFIF>
				<CFSET ApplyFilter = 1> --->
	
<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
		SELECT	DISTINCT Contract_Main.Contract_Main_ID, Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date, Contract_Status_Type_ID, Contract_Status_Type_Desc, Program_Control_Panel_Options.Created_Type
		FROM	
				Contract_Main
				INNER JOIN Contract_Status_Types ON
				(Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX)				
				INNER JOIN	Program_Control_Panel_Options
				ON (Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
		WHERE	Contract_Main.ProgramType_ID IN (	SELECT ProgramControl_Panel_Options_ID 
						FROM Program_Control_Panel_Options 
						WHERE Program_Control_Panel_Options.Generic_Type = 'Distributor Trade/Shelter')
		AND
			Contract_Main.Flagged_As_Purged = 0
				AND
				Contract_Main.Deleted = 0
				AND
				Contract_Status_Types.Contract_Status_Type_ID >= 5
				AND
				(
					((Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND (Contract_Main.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(Contract_Main.Revision_of_Contract_Main_ID IS NULL) AND Contract_Status_Types.Contract_Status_Type_ID > 4)
				)
				<CFIF Form.Status NEQ "0">
					AND Contract_Status_Types.Contract_Status_Type_ID = #Form.Status#
				</CFIF>
				<CFIF Form.ProgramType NEQ "0">
					AND Contract_Main.ProgramType_ID = #Form.ProgramType#
				</CFIF>
				<CFIF Len(Trim(Form.Start_Date)) GT 0 AND ISDate(Form.Start_Date) AND (Form.Start_date_Operator EQ "Greater_Or_Equal" OR Form.Start_date_Operator EQ "Equal" OR Form.Start_date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.Start_Date#', Contract_Start_Date)
					<CFSWITCH expression="#Form.Start_date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				<CFIF Len(Trim(Form.End_Date)) GT 0 AND ISDate(Form.End_Date) AND (Form.End_date_Operator EQ "Greater_Or_Equal" OR Form.End_date_Operator EQ "Equal" OR Form.End_date_Operator EQ "Less_Or_Equal")>
					AND DateDiff(d, '#Form.End_Date#', Contract_End_Date)
					<CFSWITCH expression="#Form.End_date_Operator#">
						<CFCASE value="Greater_Or_Equal">
						>=
						</CFCASE>
						<CFCASE value="Equal">
						=
						</CFCASE>
						<CFCASE value="Less_Or_Equal">
						<=
						</CFCASE>
					</CFSWITCH>					
					0
				</CFIF>
				<CFIF Trim(Form.Program_Title) GT 0>
								AND Contract_Main.Contract_Title LIKE '%#Form.Program_Title#%'
				</CFIF>
				<CFIF Trim(Form.Program_Number) GT 0>
					AND Contract_Main.Contract_Number LIKE '%#Form.Program_Number#%'
				</CFIF>
				<CFIF Len(Form.Operator_Name) GT 0>
					AND
					EXISTS
					(
						SELECT	Contract_Operators.Contract_Main_ID
						FROM	Contract_Operators
								INNER JOIN	BSA_Operator
								ON
								(
									(BSA_Operator.Deleted = 0)
									AND
									(Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID)									
									AND
									(BSA_Operator.Operator_Name Like '%#Form.Operator_Name#%')
								)
						WHERE
							Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
							AND							
							Contract_Operators.Deleted = 0
							
					)
				</CFIF>
				<CFIF Form.Broker_ID NEQ "0">
					AND
					EXISTS
					(
					SELECT	Contract_Distributors.Contract_Main_ID, Contract_Brokers.Contract_Main_ID
					FROM
							Contract_Distributors
							FULL JOIN 	Contract_Brokers ON 
							(
							(Contract_Brokers.Contract_Main_ID = Contract_Main.Contract_Main_ID)
							AND
							(Contract_Brokers.Deleted = 0)
							)
							---INNER JOIN START
							INNER JOIN					
								(BSA_Foodservice_Brokers FULL JOIN 
									BSA_FoodService_Customers
									ON 
								(BSA_FoodService_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)
								)						
							ON
							(
							((BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID)
							OR 
							(BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID))							
							AND
							BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = '#Form.Broker_ID#'
							)
							---INNER JOIN END
						WHERE
							(
								Contract_Distributors.Deleted = 0
								AND
								Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
							)
							OR
							Contract_Distributors.Contract_Main_ID IS NULL
					)					
				</CFIF>
				<CFIF ((Len(Form.Customer_Filter) GT 0) AND ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))) OR (Len(Form.Distributor_Name) GT 0)>
					AND
					EXISTS
					(
					SELECT	Contract_Distributors.Contract_Main_ID
					FROM
							Contract_Distributors							
							---INNER JOIN START
							INNER JOIN					
							BSA_FoodService_Customers
							ON							
							(BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID)							
							<CFIF (Len(Form.Customer_Filter) GT 0) AND ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))>
							AND
							NOT (BSA_FoodService_Customers.BSA_FoodService_Customers_ID IS NULL)
							</CFIF>
							<CFIF Len(Trim(Form.Distributor_Name)) GT 0>
							AND
							BSA_FoodService_Customers.Name LIKE '%#Form.Distributor_Name#%'
							</CFIF>
						WHERE
							(
								Contract_Distributors.Deleted = 0
								AND
								Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
							)
							OR
							Contract_Distributors.Contract_Main_ID IS NULL
					
							<CFIF Form.Customer_Filter EQ "family_name" AND Form.Family_Name NEQ "0">
							AND
							EXISTS
							(
								SELECT	Distributor_Family.Family_ID
								FROM	Distributor_Family
								WHERE
									Distributor_Family.family_ID = BSA_FoodService_Customers.family_ID
									AND
									Distributor_Family.Deleted=0
									AND
									Distributor_Family.Family_ID = '#Form.Family_Name#'
							)							
							<CFELSEIF Form.Customer_Filter EQ "buying_group" AND Form.Buying_Group NEQ "0">
							AND
							EXISTS
							(
								SELECT	Distributor_Buying_Groups.Buying_Group_ID
								FROM	Distributor_Buying_Groups
								WHERE
									 Distributor_Buying_Groups.Buying_Group_ID = BSA_FoodService_Customers.Buying_Group_ID
									 AND
									 Distributor_Buying_Groups.Deleted=0
									 AND
									 Distributor_Buying_Groups.Buying_Group_ID = '#Form.Buying_Group#'
							)
							</CFIF>
					)					
				</CFIF>			
		ORDER BY #sql_Sort_By#
	</CFQUERY>
	
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many brokers in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
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
	<BR>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Program<CFELSE>Programs</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					
						<TD>&nbsp;</TD>
					
					<CFSET HeaderNameList="Number,Title,Start Date, End Date">
					<cfoutput>
					<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
					<CFSET sortImage="">				
					<CFIF this_Header EQ Form.SORT_BY>
						<CFIF FORM.SORT_ORDER EQ "DESC">
							<CFSET New_Sort_Order="ASC">
							<CFSET sortImage="up_1.gif">
						<CFELSE>
							<CFSET New_Sort_Order="DESC">
							<CFSET sortImage="down_1.gif">
						</CFIF>
						<CFELSE>
							<CFSET New_Sort_Order="ASC">
						</CFIF>
						<TD ID="header" align="left"><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
						</CFLOOP>
						</cfoutput>
<!--- 					<TD align="left" NOWRAP ID="header"><B>Number</B></TD>
					<TD align="left" ID="header"><B>Title</B></TD>
					<TD align="left" ID="header"><B>Start Date</B></TD>
					<TD align="left" ID="header"><B>End Date</B></TD> --->
				</TR>

			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<cf_cryp string="#TheQuery.Contract_Main_ID#" type="en" key="#request.key#">

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="center">
						
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.Contract_Main_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.Contract_Main_ID)) NEQ 0>CHECKED<!--- <CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.Contract_Number), ",")> ---></CFIF>>
						
						
					</td>

					<TD NOWRAP>#TheQuery.Contract_Number#&nbsp;</TD>
					<TD>#TheQuery.Contract_Title#<BR>(#TheQuery.Contract_Status_Type_Desc#)</TD>
					<TD NOWRAP>#DateFormat(TheQuery.Contract_Start_Date,"mm/dd/yyyy")#</TD>
					<TD NOWRAP>#DateFormat(TheQuery.Contract_End_Date,"mm/dd/yyyy")#</TD>
 				</TR>
			</CFOUTPUT>
			</TABLE>

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
				<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams="">
			</DIV>

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
		
		//findselectboxes();
	</SCRIPT>

<cfoutput>
<INPUT TYPE="hidden" NAME="FieldName" 				VALUE="#FORM.FieldName#">	
<INPUT TYPE="hidden" NAME="ParentFormname" 			VALUE="#FORM.ParentFormname#">	
<INPUT TYPE="hidden" NAME="FinalItemList" 			VALUE="#Form.FinalItemList#">
<INPUT TYPE="hidden" NAME="finishedselectingitems" 	VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" 		VALUE="0">
<INPUT TYPE="Hidden" NAME="startrow" 				VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" 				VALUE="#frompage#">
<input type="hidden" name="button_caption" 			value="#FORM.Button_Caption#">
<input type="hidden" name="Distributor_List" 		value="#Distributor_List#">
<input type="hidden" name="FilterSearchPrograms" 	value="#Form.FilterSearchPrograms#">
<input type="hidden" name="FilterType" 				value="#Form.FilterType#"> <!---  1= op, 2 = br, 3 = dis --->
<input type="hidden" name="FilterDataList"			value="#Form.FilterDataList#">
<input type="hidden" name="runsearchonfirstload"	value="#Form.runsearchonfirstload#">
</cfoutput>
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected program<CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned programs </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected programs </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<BR>	
	</DIV>
	</cfif>
	</cfif> 


<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				document.all.allbox.checked = true;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#TheQuery.Contract_Main_ID#</CFOUTPUT>";

				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#TheQuery.Contract_Main_ID#</CFOUTPUT>";
				
				}
	
				document.MyForm.submit();
			}
			else
			{
			
			}
		}
		
		function removeAllProducts(){
			
			if(confirm("By pressing OK all selected records will be unselected")){
				document.all.allbox.checked = false;
				document.all.allbox.fireEvent("onclick");
				
				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
			else
			{
			
			}
		}	
		
		function finishedSearching() {
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}	
	</cfif>
	
	<CFIF FORM.runsearchonfirstload EQ 1>
		document.all.runsearchonfirstload.value = 0;
		document.all.MyForm.submit();
	</CFIF>
</SCRIPT>

