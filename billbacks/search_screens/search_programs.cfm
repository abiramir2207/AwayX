<!--- Dev Note: Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>
<CFPARAM NAME="URL.Distributor_ID" DEFAULT="">
<CFPARAM NAME="URL.Distributor_Bill_To_ID" DEFAULT="">
<cfparam name="URL.ProgramType" default="">
<cfparam name="URL.ModifyProgram" default="0">

<CFSET sort_By_List="Number,Title,Status,Program Type,Start Date,End Date">
<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List))#">
<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
<cfparam name="ShowAllPrograms" default="0">
<cfparam name="Program_ID" default="">
<cfparam name="Billback_ID" default="">
<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	used for scheduled auto billback searches				XXXXX
		* Don't show price list (loaded deals) programs 	XXXXX
		* Search on rebate recipient Name (distName)    	XXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
<CFPARAM NAME="URL.DiscIDFilter" DEFAULT="0">
<CFPARAM NAME="Form.DiscIDFilter" DEFAULT="0">
<CFPARAM NAME="URL.DistName" DEFAULT="">
<CFPARAM NAME="Form.DistName" DEFAULT="">
<CFPARAM NAME="URL.runsearchonfirstload" DEFAULT="0">
<CFPARAM NAME="Form.selectMultiResultOverRide" DEFAULT="0">
<CFPARAM NAME="URL.selectMultiResultOverRide" DEFAULT="#Form.selectMultiResultOverRide#">
<CFPARAM NAME="URL.AutoPayFilter"  default="0">
<CFPARAM Name="variables.Filter_Auto_Pay_Claim_Mech_List" default="">
<!--- BJF Changes requested when auto pay was implemented --->
<CFPARAM NAME="FORM.Payment_Type_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Program_Template_Name" default ="">
<CFPARAM NAME="FORM.Payment_Cycle_ID" default="0">

<!---TSF - Param these values so that they can be passed from flex VIA URL not the openers form scope --->
<cfparam name="URL.FilterSearchPrograms" 	DEFAULT="0">
<cfparam name="URL.FilterType" 				DEFAULT="0">
<cfparam name="URL.FilterDataList"			DEFAULT="0">
<!--- This will change the date feature to use an OR instead of an AND between start and end date --->
<CFPARAM NAME="ActiveWithinSpan" DEFAULT = 0>
<CFPARAM NAME="URL.ProgramRestrictions" DEFAULT = "1">
<!--- Dev Note: 46301--->
<cfif isDefined("URL.AllowImportAll") AND URL.AllowImportAll EQ 1>
	<cfparam name="form.AllowImportAll" default="1">
<cfelse>
	<cfparam name="form.AllowImportAll" default="0">
</cfif>
<cfparam name="PageSource" default="">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset segment_is_enabled = businessSegManager.isEnabled()>       <!---31706--->
<cfset segment_enabled_for_distributor = businessSegManager.isEnabledForDistributor()>
<!--- D31683:Processing HCIS Payment Requests START--->
<cfset SearchExpiredProgramWithin = CreateObject("component", "components.billback.BillbackSettingsManager").getSearchExpiredProgramWithin() />
<!--- D31683:Processing HCIS Payment Requests END--->
<!---31706 gather user segments--->
<cfif segment_is_enabled>
	<cfset vars.qUserSegments = businessSegManager.getActive(request.AccessStructure.User_ID)>
	<cfset vars.lUserSegments = ValueList( vars.qUserSegments.Business_Segment_ID )>
<cfelse>
	<cfset vars.lUserSegments = "">
</cfif>

<!--- get the User Profile information --->
<cfinclude template="/get_access_profile.cfm">

<cfset variables.VendorOnlyBillback = 0>
<cfif len(trim(Billback_ID)) GT 0>
<cfset useLakebaseForqVendorOnlyBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqVendorOnlyBillback>
	<cftry>
		<cfset qVendorOnlyBillback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "vendor_only_billback"
			}), "vendor_only_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqVendorOnlyBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqVendorOnlyBillback>
<cfquery name="qVendorOnlyBillback" datasource="#Application.Datasource#">
	SELECT Vendor_Only_Billback
	FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>
	<!--- Dev Note(78635): Check whether it is a lump sum program paid to vendor --->
	<cfset variables.VendorOnlyBillback = qVendorOnlyBillback.Vendor_Only_Billback>
</cfif>

<!---if restrict one program per billback is on then turn single search--->
<cfif (appSettings.getOneProgramPerBillback() OR appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1') AND URL.selectMultiResultOverRide EQ 0>
	<cfset URL.SelectSingleSearchResultOnly = 1 />
	<cfset form.SelectSingleSearchResultOnly = 1 />
</cfif>

<cfif URL.ProgramType IS "Trade">
	<cfset URL.ProgramType="Distributor Trade/Shelter">
</cfif>

<!--- This logic passes in dates and date parameters from auto pay --->
<cfparam name="form.Start_Date" default="">
<cfparam name="form.End_Date" default="">
<cfparam name="form.Start_Date_Operator" default="">
<cfparam name="form.End_Date_Operator" default="">

<Cfif isDefined("url.Start_Date") AND isdefined("url.End_Date")>
	<!--- it is possible to search before you have dates -- this only sets dates if they're not null --->
	<cfif len(trim(url.Start_Date)) GT 0>
		<cfset form.Start_Date = url.Start_Date>
		<cfset form.Start_Date_Operator = "Greater_Or_Equal">
	</cfif>

	<cfif len(trim(url.End_Date)) GT 0>
		<cfset form.End_Date = url.End_Date>
		<cfset form.End_Date_Operator = "Less_Or_Equal">
	</cfif>

</CFIF>
<!--- D41325 :: Prod Event 883 --->
<cfparam name="FilterSearchPrograms" default="0" >

<cfparam name="URL.SelectSingleSearchResultOnly" 	default="0">
<cfparam name="form.program_list" default="">

<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">
<CFIF isdefined("URL.FormName")>

	<!--- TSF - This is a fix when calling this page from Flex. TODO: Pass the UUID to this files from Flex --->
	<cfif URL.FormName EQ 'flex' and trim(URL.FilterDataList) neq 0 and trim(URL.FilterType) neq 0>
		<CFSWITCH expression="#trim(url.FilterType)#">
			<cfcase value="1"><!--- Distributor --->
				<cfquery name="getDistributorId" datasource="#Application.Datasource#">
					SELECT 	BSA_Foodservice_Customers_ID
					FROM	BSA_Foodservice_Customers
					WHERE 	Ship_To = '#url.FilterDataList#' OR CAST(BSA_Foodservice_Customers_ID AS NVARCHAR(50)) = '#url.FilterDataList#'
				</cfquery>
				<CFIF getDistributorId.recordcount GT 0>
					<cfset url.FilterDataList = getDistributorId.BSA_Foodservice_Customers_ID />
				</CFIF>
			</cfcase>
			<cfcase value="2"><!--- Operator --->
				<cfset arrOperatorData = CreateObject("component","mvc.Models.Billback.BillbackEditSearchManager").getOperatorData(operatorId = url.FilterDataList) />
				<CFIF ArrayLen(arrOperatorData)>
					<cfset url.FilterDataList = arrOperatorData[1].bsaOperatorId />
				</CFIF>
			</cfcase>
		</CFSWITCH>
	</cfif>

	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="SelectSingleSearchResultOnly" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.SelectSingleSearchResultOnly#</CFOUTPUT>">
		<CFOUTPUT>
		<input type="hidden" name="FilterSearchPrograms" 	value="#URL.FilterSearchPrograms#">
		<input type="hidden" name="FilterType" 				value="#URL.FilterType#">
		<input type="hidden" name="FilterDataList"			value="#URL.FilterDataList#">
		<!--- <input type="hidden" name="runsearchonfirstload"	value="0"> --->
		<INPUT TYPE="Hidden" NAME="Distributor" VALUE = "">
		<input type="hidden" name="runsearchonfirstload"	value="#URL.runsearchonfirstload#">
		<INPUT TYPE="Hidden" NAME="DistName" VALUE = "#URL.DistName#">
		<INPUT TYPE="Hidden" NAME="DiscIDFilter" VALUE = "#URL.DiscIDFilter#">
		<input type="hidden" name="ProgramType" value="#ProgramType#">
		<input type="hidden" name="ModifyProgram" value="#URL.ModifyProgram#">
		<INPUT TYPE="Hidden" NAME="Distributor_Bill_To_ID" VALUE="#URL.Distributor_Bill_To_ID#">
		<INPUT TYPE="Hidden" NAME="Distributor_ID" VALUE="#URL.Distributor_ID#">
		<!--- BJF: added for program switching --->
		<input type="hidden" name="Program_ID" value="#Program_ID#">
		<input type="hidden" name="Billback_ID" value="#Billback_ID#">
		<input type="hidden" name="selectMultiResultOverRide" value="#URL.selectMultiResultOverRide#">
		<!--- BJF: from auto pay --->
		<input type="hidden" name="Start_Date" value="#form.Start_Date#">
		<input type="hidden" name="Start_Date_Operator" value="#form.Start_Date_Operator#">
		<input type="hidden" name="End_Date" value="#form.End_Date#">
		<input type="hidden" name="End_Date_Operator" value="#form.End_Date_Operator#">
		<input type="hidden" name="ActiveWithinSpan" value="#ActiveWithinSpan#">
		<input type="hidden" name="isAutoPaySearch" value="#URL.AutoPayFilter#">
		<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#FORM.FlexAppName#">
		<INPUT TYPE="Hidden" NAME="ProgramRestrictions" VALUE="#URL.ProgramRestrictions#">
		<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="#form.AllowImportAll#">
		<input name="program_list" type="hidden" value="#form.program_list#">
		<INPUT TYPE="hidden" NAME="PageSource" VALUE="#PageSource#">
		</CFOUTPUT>
	</FORM>

	<!----

			If you want to run this from a calling page without passing any search parameters, you need to have your forms set up like this in the form you pass as the URL parameter:
	<input type="hidden" name="runsearchonfirstload" value=0> (1 if you want the search to immediately execute)
	<input type="hidden" name="FilterSearchPrograms" value=0>

		URL.FormName: The name of the form on the parent page this should submit to
		FilterSearchPrograms: A form field on your parent page; value binary on whether you will or will not search
		FilterType: If you are filtering, what you are filtering on. Value is an int from Billback_Payee_Type_ID
		FilterDataList: Looks for programs for a particular client (distributor, operator, broker); looks up id based on Payee Type.
	---->
	<cfif URL.FormName EQ 'flex' OR PageSource eq "AliasProgramSearch">
		<script>
			document.all.MyForm.submit();
		</script>
	<cfelse>
		<script>
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
				this.document.all.FinalItemList.value = window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value
				if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterSearchPrograms.value == 1) {

					this.document.all.FilterSearchPrograms.value 	= 1;
					this.document.all.FilterType.value 				= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterType.value;
					this.document.all.FilterDataList.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterDataList.value;
				}
				if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterSearchPrograms.value == 2)
				{
					this.document.all.FilterSearchPrograms.value 	= 2;
					this.document.all.FilterType.value 				= 1;
					this.document.all.FilterDataList.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.Distributor_List.value;
				}

				if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload != null){

					if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload.value == 1) {
						this.document.all.runsearchonfirstload.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.runsearchonfirstload.value;
					}
				}
				document.all.MyForm.submit()
			}
			else{
				alert("The Data Needed From The Parent Form Isnt Available.This Window Will Close!")
				window.close()
			}
		</script>
	</cfif>
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
<CFPARAM NAME="FORM.Distributor_ID" 				DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Name" 				DEFAULT="#form.DistName#">
<CFPARAM NAME="FORM.Distributor_Bill_To_ID" 		DEFAULT="">
<CFPARAM NAME="FORM.ProgramType" 					DEFAULT="">
<CFPARAM name="FORM.ModifyProgram" 					DEFAULT="0">
<!--- <CFIF FORM.FilterSearchPrograms EQ 2>
	<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="1">
<CFELSE> --->
	<CFPARAM NAME="FORM.SelectSingleSearchResultOnly"	Default="0">
<!--- </CFIF> --->
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<!--- D41349 :: Prod Event 14542--->
<CFPARAM NAME="FORM.FilterDataList"					Default="0">
<cf_Number_of_Rows maxrows=100>


<CFSET FORM.LoadSavedResults=0>

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>


<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF FORM.SelectSingleSearchResultOnly NEQ 1>
		<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
			<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
		</CFIF>
	<CFELSE>
		<CFSET FORM.FinalItemList = ListItem>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
		<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>

<CFIF FORM.finishedselectingitems EQ 1>
<!--- If there's a program ID we're switching programs instead of  --->
	<cfif len(trim(Program_ID)) GT 0 and FORM.PARENTFORMNAME NEQ 'flex' AND PageSource NEQ "AliasProgramSearch">

		<cflocation url="/billbacks/capture/switch_program.cfm?Billback_ID=#Billback_ID#&Program_ID=#Program_ID#&NewProgram=#Form.FinalItemList#&ParentFormName=#Form.ParentFormname#">

	<cfelse>

	<CFOUTPUT>
		<cfif FORM.PARENTFORMNAME EQ 'flex'>
			<!--- implement call to externalinterface --->
			<script>
				// This function returns the appropriate reference,
				// depending on the browser.
				function getFlexApp(appName)
				{
				  if (navigator.appName.indexOf ("Microsoft") !=-1)
				  {
				    return opener.window[appName];
				  }
				  else
				  {
				    return opener.document[appName];
				  }
				}

				<cfif len(trim(Program_ID))>
					function showSwitchPrograms()
					{
						getFlexApp('#FORM.FlexAppName#').showSwitchPrograms('#Program_ID#', '#Form.FinalItemList#');
					}
					showSwitchPrograms();
				<cfelse>
					function saveProgram()
					{
						getFlexApp('#FORM.FlexAppName#').saveProgram('#Form.FinalItemList#');
					}
					saveProgram();
				</cfif>

				window.close();
			</script>
		<cfelse>
		<cfif PageSource IS "AliasProgramSearch">
		<script>
			window.opener.getProgramInfo('#Form.FinalItemList#',0,1);
			window.close();
		</script>
		<cfelse>
			<script>
				opener.document.all.#Form.ParentFormname#.#Form.FieldName#.value = '#Form.FinalItemList#'

				<cfif Form.selectMultiResultOverRide EQ 1>
					window.opener.saveProgramAction('#Form.FinalItemList#');
				<cfelse>
					opener.document.#Form.ParentFormname#.submit();
				</cfif>
				window.close()
			</script>
		</cfif>
		</cfif>
	</CFOUTPUT>
	</cfif>
	<CFABORT>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<SCRIPT language="JavaScript" src="/script/javascript/validateFormUtils.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/wholeNumberValidation.js"></SCRIPT>
	<script type="text/javascript" src="/script/tTip.js"></script><!--- D31683:Processing HCIS Payment Requests --->
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" /> <!--- D31683:Processing HCIS Payment Requests --->
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
	.searchItemLabel { font-weight: bold; }
	input, select { display:inline-block; margin:3px 0; }
	.full { width:90%; }
	.action { margin:0 10px;}
	.operator { WIDTH:45px; position:relative; top:8px; }
	</style>
</HEAD>

<!--- <BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="20" TOPMARGIN="0" onLoad="document.all.Program_Title.focus();"> --->
<body>
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

		document.all.Program_Title.focus();

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



<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">program search</LEGEND>

	<cfoutput>
	<INPUT TYPE="Hidden" NAME="Distributor_Bill_To_ID" VALUE="#FORM.Distributor_Bill_To_ID#">
	<INPUT TYPE="Hidden" NAME="Distributor_ID" VALUE="#FORM.Distributor_ID#">
	<input type="hidden" name="ProgramType" VALUE="#form.ProgramType#">
	<input type="hidden" name="ModifyProgram" VALUE="#form.ModifyProgram#">
	<input name="program_list" type="hidden" value="#form.program_list#">
	</cfoutput>

	<cfset filterslist = listqualify(FORM.FilterDataList,"'")><!--- D31454:Single Billback Per Invoice:   program search logic  --->


			<TABLE BORDER="0" style='table-layout:relative;width:100%;'>
				<col width="27%">
				<col width="36%">
				<col width="37%">
				<TR VALIGN="TOP">
					<TD>
						<span class="searchItemLabel" onmouseout="popUpTip(event,'expiredprogramsinfo');" onmouseover="popUpTip(event,'expiredprogramsinfo');">
							Status <img src="/images/help_small.gif" /><!--- D31683:Processing HCIS Payment Requests --->
						</span><!--- D31683:Processing HCIS Payment Requests START--->
						<div id="expiredprogramsinfo" class="tip" style="margin-left:85px;margin-top:-75px;width:525px">
								<cfoutput>
                                 	**All Statuses** includes expired programs that are within #SearchExpiredProgramWithin# days of the program's end date. <br>
									Where #SearchExpiredProgramWithin# is the number of days from the setting in Settings>Payable> payables settings.<br>
									To find expired programs beyond N days, select 'expired' from the status field and then search for the program.
                                 </cfoutput>
						</div><!--- D31683:Processing HCIS Payment Requests END--->

<!-----------------------------------------------------------------------
						Get Status from DB
--------------------------------------------------------------------------->
						<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
						Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
						From 	Contract_Status_Types
						Where
							Contract_Status_Type_ID >= 4
						Order By Contract_Status_Type_ID
						</CFQUERY>
						<CFPARAM NAME="FORM.Status" DEFAULT="0">
						<SELECT NAME="Status" class="full"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
							<OPTION VALUE="0">**All Status**</OPTION>
							<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
						</SELECT>
						<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
						<br>
						<div style="margin-top:5px;">
							<cfif discountIdentifierManager.discountIdentifierOn()>
								<span class="searchItemLabel">Discount Identifier</span><BR>
								<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
								<cfset qDiscountIdentifiers = discountIdentifierManager.getActive()>
								<SELECT NAME="Discount_Identifier" class="full" onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
									<OPTION VALUE="0">**ALL** Discount Identifier</OPTION>
									<CFOUTPUT QUERY="qDiscountIdentifiers"><OPTION VALUE="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>#trim(Discount_Identifier_Desc)#</OPTION></CFOUTPUT>
								</SELECT>
							<cfelse>
								<span class="searchItemLabel">Program Generic Type</span><BR>
								<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
								<CFQUERY NAME="Get_Generic_Types" DATASOURCE="#application.datasource#">
								Select	Generic_Type
								From 	Generic_Type
								WHERE Generic_Type NOT LIKE 'Distributor Off-Invoice'
								Order By Generic_Type
								</CFQUERY>
								<CFIF FORM.FilterSearchPrograms EQ 2>
									<CFSET FORM.Generic_Type = 'Distributor Trade/Shelter'>
								</CFIF>
								<SELECT NAME="Generic_Type" class="full" <CFIF FORM.FilterSearchPrograms EQ 2>DISABLED</CFIF>  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
									<OPTION VALUE="0">**ALL** Generic Type</OPTION>
									<CFOUTPUT QUERY="Get_Generic_Types"><OPTION VALUE="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</OPTION></CFOUTPUT>
								</SELECT>
							</cfif>
						</div>
					</TD>
					<TD>

				<div style="position:relative;top:4px;">
						<span class="searchItemLabel" ><cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput></span><BR>

					<CFQUERY NAME="GetBrokers" datasource="#application.datasource#">
						SELECT BSA_Foodservice_Brokers_ID, Broker_Name
						FROM broker_active
						WHERE len(Broker_Name) > 0
						ORDER BY Broker_Name

					</CFQUERY>

					<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">

					<cfset BrokerIDList = "">

					<SELECT NAME="Broker_ID" class="full" onkeydown="if (event.keyCode == 13) document.MyForm.submit();">

						<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.broker_label_plural#</cfoutput></OPTION>

						<!--- GROUP BROKERS BY NAME TO DISPLAY THEM ONLY ONCE IN THE SEARCH TOOL --->

						<cfsavecontent variable="variables.brokers">
							<CFOUTPUT QUERY="GetBrokers" group="Broker_Name">

							<!--- CREATE LIST OF ID'S THAT SHARE A COMMON BROKER NAME FOR USING IN THE SEARCH QUERY --->
								<cfoutput>

								<cfset BrokerIDList = listAppend(BrokerIDList,trim(GetBrokers.BSA_Foodservice_Brokers_ID))>
								</cfoutput>

							<OPTION VALUE="#BrokerIDList#" <cfif BrokerIDList EQ FORM.Broker_ID>SELECTED</cfif>>
									#trim(GetBrokers.Broker_Name)#
								</OPTION>

							<!--- CLEAR IDLIST VARIABLE TO ALLOW CREATION OF A NEW LIST FOR THE NEXT BROKER NAME IN THE LOOP --->

							<cfset BrokerIDList = "">
							</cfoutput>
							</cfsavecontent>
							<cfoutput>#application.util.string.compress( variables.brokers )#</cfoutput>

					</SELECT>
						</div>
					</TD>
					<TD>
						<CFPARAM NAME="FORM.Customer_Filter" DEFAULT="">
						<TABLE>
							<TR>
								<TD><INPUT onclick="JavaScript:dist_lookup_Pick(1,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="family_name"<CFIF FORM.Customer_Filter EQ "family_name"> CHECKED</CFIF>></TD>
								<TD NOWRAP><span class="searchItemLabel"><cfoutput>#application.returned_customer_setting.family_name_label_singular#</cfoutput></span></TD>
								<TD>
								<cfset useLakebaseForGetFamilyNames = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_family")>
<cfif useLakebaseForGetFamilyNames>
	<cftry>
		<cfset GetFamilyNames = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_family", {
				"deleted" = "eq.0",
				"order" = "family_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFamilyNames = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFamilyNames>
<cfquery name="GetFamilyNames" datasource="#application.datasource#">
									SELECT *
									FROM Distributor_Family
									WHERE Deleted = 0
									ORDER BY Family_Name
								</cfquery>
</cfif>
								<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
								<SPAN ID="SP_Family_Name">
								<SELECT NAME="Family_Name" style="width: 180px;"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
									<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.family_name_label_plural#</cfoutput></OPTION>
									<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
								</SELECT>
								</SPAN>
							</TR>
							<TR>
								<TD><INPUT onclick="JavaScript:dist_lookup_Pick(2,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="buying_group"<CFIF FORM.Customer_Filter EQ "buying_group"> CHECKED</CFIF>></TD>
								<TD NOWRAP><span class="searchItemLabel"><cfoutput>#application.returned_customer_setting.buying_group_label_plural#</cfoutput></span></TD>
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
<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
									SELECT *
									FROM Distributor_Buying_Groups
									WHERE Deleted = 0
									AND	Active_Code = 'A'
									ORDER BY Buying_Group_Name
								</cfquery>
</cfif>
								<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
								<SPAN ID="SP_Buying_Group">
								<SELECT NAME="Buying_Group" style="width: 180px;"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
									<OPTION VALUE="0">**ALL** <cfoutput>#application.returned_customer_setting.buying_group_label_plural#</cfoutput></OPTION>
									<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
								</SELECT>
								</SPAN>
							</TR>
							<TR>

								<TD>
									<INPUT CHECKED onclick="JavaScript:dist_lookup_Pick(3,this);" TYPE="RADIO" ID="Customer_Filter" NAME="Customer_Filter" VALUE="buying_group"<CFIF FORM.Customer_Filter EQ "buying_group"> CHECKED</CFIF>>
								</TD>
								<TD NOWRAP>
									<span class="searchItemLabel"><cfif form.DiscIDFilter>Rebate Recipient<cfelse><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</cfif></span>
								</TD>
								<CFIF FORM.FilterSearchPrograms EQ 2 OR FORM.Distributor_ID NEQ "">
									<CFQUERY NAME="GetDistName" DATASOURCE="#Application.Datasource#">
										SELECT Name FROM BSA_Foodservice_Customers
										WHERE BSA_Foodservice_Customers_ID IN (<CFIF FORM.FilterSearchPrograms EQ 2>
																					#PreserveSingleQuotes(filterslist)#
																			  <CFELSEIF FORM.Distributor_ID NEQ "">
																					'#FORM.Distributor_ID#'
																			  <cfelse>
																				NULL
																			  </CFIF>)
																					 AND Deleted=0 <!--- D31454:Single Billback Per Invoice:   program search logic  --->
									</CFQUERY>
								</CFIF>
								<TD>
								<CFOUTPUT>
								<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
								<SPAN ID="SP_Distributor_Name">
								<INPUT NAME="Distributor_Name" type="text" size="35" ID="Distributor_Name" <CFIF FORM.FilterSearchPrograms EQ 2 OR FORM.Distributor_ID NEQ "">VALUE="#GetDistName.Name#" READONLY <CFELSE>VALUE="#FORM.Distributor_Name#"</CFIF>>
								</SPAN>
								</CFOUTPUT>
								</TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
				<cfoutput>
				<tr>
					<td valign="top" nowrap>
						<span class="searchItemLabel">#application.returned_customer_setting.operator_label_singular# ##</span><BR>
						<CFPARAM NAME="FORM.BSA_Operator_ID" DEFAULT="">
						<!--- D25340 - Billbacks:  Change operator fields in program search page --->
						<INPUT NAME="BSA_Operator_ID" type="text" ID="BSA_Operator_ID" class="full" VALUE="#FORM.BSA_Operator_ID#" <!--- onBlur="checkNumberDataNotReq(this,'BSA Operator ID');nextBox(BSA_Operator_ID,'NONE',9);" ---> size="25"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
					<br>
						<cfoutput>
						<span class="searchItemLabel">#application.returned_customer_setting.operator_label_singular# Name</span><BR>
						<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
						<INPUT type="text" NAME="Operator_Name" ID="Operator_Name" VALUE="#FORM.Operator_Name#" class="full" onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
						</cfoutput>
					</td>

					<td valign="top">
						<!--- Get list of payment types --->
						<cfquery name="qGetPaymentTypes" datasource="#application.datasource#">
						SELECT
							Payment_Type_Name,
							Payment_Type_ID
						FROM Payment_Type
						WHERE	Active = 1
							AND	Deleted = 0
							AND	Restrict_From_Billback = 0
							AND Off_Invoice = 0
						ORDER BY Payment_Type_Name
						</cfquery>

						&nbsp;<br>
						<SPAN ID="Payment_Type">
								<SELECT NAME="Payment_Type_ID" style="width: 180px;"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
									<OPTION VALUE="0">**ALL** Claim Mechanics</OPTION>
									<CFloop QUERY="qGetPaymentTypes"><OPTION VALUE="#trim(Payment_Type_ID)#"#IIF(trim(FORM.Payment_Type_ID) EQ trim(Payment_Type_ID), DE(" SELECTED"), DE(""))#>#trim(Payment_Type_Name)#</OPTION></CFloop>
								</SELECT>
								</SPAN>

						<!--- Payment cycle --->
						<cfquery name="qGetPaymentCycle" datasource="#application.datasource#">
						SELECT DISTINCT PC.Payment_Cycle_ID,
										PC.Payment_Cycle
						FROM Payment_Cycle PC
						ORDER BY Payment_Cycle_ID
						</cfquery>

						<SPAN ID="Payment_Cycle">
						<SELECT NAME="Payment_Cycle_ID" style="width: 180px;"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
							<OPTION VALUE="0">**ALL** Payment Frequencies</OPTION>
							<CFloop QUERY="qGetPaymentCycle"><OPTION VALUE="#trim(Payment_Cycle_ID)#"#IIF(trim(FORM.Payment_Cycle_ID) EQ trim(Payment_Cycle_ID), DE(" SELECTED"), DE(""))#>#trim(Payment_Cycle)#</OPTION></CFloop>
						</SELECT>
						</SPAN>

						<!--- Program templates --->
						<cfquery name="qGetTemplates" datasource="#application.datasource#">
						SELECT DISTINCT Created_Type AS Program_Template_Name
						FROM Program_Control_Panel_Options
						WHERE Deleted = 0
						AND Active = 1
						AND IsDominant = 1
						ORDER BY Created_Type
						</cfquery>

						<div>
						<SPAN ID="Program_Template_Name">
						<SELECT NAME="Program_Template_Name" style="width: 180px;"  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
							<OPTION VALUE="0">**ALL** Program Templates</OPTION>
							<CFloop QUERY="qGetTemplates"><OPTION VALUE="#trim(Program_Template_Name)#"#IIF(trim(FORM.Program_Template_Name) EQ trim(Program_Template_Name), DE(" SELECTED"), DE(""))#>#trim(Program_Template_Name)#</OPTION></CFloop>
						</SELECT>
						</SPAN>
						</div>

					</td>
					<td valign="top" nowrap>
						<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
						<CFSET Date_Operator_Symbols=" ,>=,=,<=">
						<table border=0>
							<tr>
								<td>
									<CFOUTPUT>
									<span class="searchItemLabel">Start date</span>
									<CFPARAM NAME="Start_date_Operator" DEFAULT="">
									<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" class="operator">
										<CFSET cnt=0>
										<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
											<CFSET cnt=cnt+1>
											<OPTION VALUE="#Trim(thisOperator)#"<CFIF Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
										</CFLOOP>
									</SELECT>
									<CFPARAM NAME="Start_date" DEFAULT="">
									<div ID="SP_Start_date" style="position:relative;top:10px;">
									<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#Start_date#">
									</div>
									</CFOUTPUT>
								</td>
								<td>
									<CFOUTPUT>
									<span class="searchItemLabel">End Date</span>
									<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
									<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" class="operator">
										<CFSET cnt=0>
										<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
											<CFSET cnt=cnt+1>
											<OPTION VALUE="#Trim(thisOperator)#"<CFIF End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
										</CFLOOP>
									</SELECT>
									<CFPARAM NAME="End_date" DEFAULT="">
									<div ID="SP_End_date" style="position:relative;top:10px;">
										<CF_EASYDATE FORMNAME="MyForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#End_date#">
									</div>
									</CFOUTPUT>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				</cfoutput>
<!--- 				<TR>
					<TD NOWRAP ALIGN="left">
						<TABLE>
							<TR>
								<TD>
									<span class="searchItemLabel">Sort By</span>
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
									<span class="searchItemLabel">Order</span>
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
				</TR> --->
				<TR>
					<TD NOWRAP ALIGN="left">
						<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
						<span class="searchItemLabel">Program Title</span><BR>
						<INPUT TYPE="Text" NAME="Program_Title" class="full" <CFIF len(trim(FORM.Program_Title)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Title)#</CFOUTPUT>"</CFIF>  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
					</TD>
					<TD NOWRAP ALIGN="left">
						<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
						<span class="searchItemLabel">Program Number</span><BR>
						<INPUT TYPE="Text" NAME="Program_Number" class="full" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Number)#</CFOUTPUT>"</CFIF>  onkeydown="if (event.keyCode == 13) document.MyForm.submit();">
					</TD>
					<!--- Show link to show all programs --->
					<cfif FORM.FilterSearchPrograms IS 1 AND Get_Profile_Settings.BB_Add_Program IS 1 AND AppSettings.getdisableBBAddProgram() IS 1>
						<td valign2="top">
							<input type="checkbox" name="ShowAllPrograms" value="1" style="position:relative;top:4px;" <cfif ShowAllPrograms IS 1>checked</cfif>> Do not restrict to programs with payee
						</td>
						</tr>
						<tr>
							<td align="right" colspan="3"><BR>
								&nbsp;&nbsp;
								<a href="#" class="action" onclick="createList();"><cfoutput>#application.util.string.actionLinkFormat2("create list")#</cfoutput></a>
								<a href="#" class="action" onclick="javascript:document.MyForm.submit();"><cfoutput>#application.util.string.actionLinkFormat2("search programs")#</cfoutput></a>
							</td>

					<cfelse>
						<TD ALIGN="center" NOWRAP>
							<a href="#" class="action" onclick="createList();"><cfoutput>#application.util.string.actionLinkFormat2("create list")#</cfoutput></a>
							<a href="#" class="action" onclick="javascript:document.MyForm.submit();"><cfoutput>#application.util.string.actionLinkFormat2("search programs")#</cfoutput></a>
						</TD>
					</cfif>
				</TR>


				<!--- If there are associated operators (not payee) --->
				<cfoutput>
				<cfif len(trim(Billback_ID)) GT 0>
						<cfsilent>
						<cfset thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(Billback_ID) >
						<cfset AssoOperator = thisPayeeObj.getAssoOperator(Billback_ID)>
						</cfsilent>
						<tr>
				<td colspan="3">
						<CFIF AssoOperator.RecordCount EQ 1>
						<strong>Associated <span class="searchItemLabel">#application.returned_customer_setting.operator_label_singular#</span></strong><br>
						#AssoOperator.Operator_name# (#AssoOperator.Legacy_ID#)
						<CFELSEIF AssoOperator.RecordCount GT 1>
						<strong>Associated <span class="searchItemLabel">#application.returned_customer_setting.operator_label_plural#</span></strong><br>
							<CF_openLayer
							Border="Yes"
							BorderSize="1"
							BorderColor="orange"
							Image="/images/plus2.gif"
							ImageOpen="/images/minus2.gif"
							Title="Hide #application.returned_customer_setting.operator_label_plural#:"
							TitleClosed="Show #application.returned_customer_setting.operator_label_plural#:"
							TitleTooltip="Click to Show/Hide #application.returned_customer_setting.operator_label_plural#"
							TitleFont="font"
							TitleColor="Blue"
							TitleSize="9"
							IsClosed="Yes"
							Width="100%">
							<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
								<CFLOOP Query="AssoOperator">
								<TR>
									<TD VALIGN="Top">#Operator_name# (#Legacy_ID#) </TD>
								</TR>
								</CFLOOP>
							</TABLE>
							</CF_openLayer>

				</td>
				</tr>
				</CFIF>
					</cfif>
				</cfoutput>


			</TABLE>



		<cfoutput>
			<INPUT TYPE="Hidden" NAME="sort_by" VALUE="#form.sort_by#">
			<INPUT TYPE="Hidden" NAME="sort_Order" VALUE="#FORM.sort_Order#">
			<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
		</cfoutput>
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
	<CFCASE value="End Date">
		<CFSET sql_Sort_By="contract_main.Contract_End_Date">
	</CFCASE>
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
</CFIF>
<CFSET sql_Sort_By="#sql_Sort_By# #sql_Sort_By_Order#">


<!--- If business segment is enabled, we want the programs to be filtered based on the payee's filter --->
<cfset businessSegmentId = 0 />
<cfif segment_enabled_for_distributor>
	<cfif trim(FORM.FilterDataList) neq ''>
		<CFSWITCH expression="#FORM.FilterType#">
			<cfcase value="1"><!--- Distributor --->
				<cfquery name="getDistributorBusinessSegmentId" datasource="#Application.Datasource#">
					SELECT 	Business_Segment_ID
					FROM	BSA_Foodservice_Customers
					WHERE 	Ship_To IN('#FORM.FilterDataList#') OR BSA_Foodservice_Customers_ID IN (#PreserveSingleQuotes(filterslist)#) <!--- D31454:Single Billback Per Invoice:   program search logic --->
				</cfquery>
				<CFIF getDistributorBusinessSegmentId.recordcount GT 0>
					<cfset businessSegmentId = getDistributorBusinessSegmentId.Business_Segment_ID />
				</CFIF>
			</cfcase>
			<cfcase value="2"><!--- Operator --->
				<!---
				<cfquery name="getOperatorBusinessSegmentId" datasource="#Application.Datasource#">
					SELECT 	Business_Segment_ID
					FROM	BSA_Operator
					WHERE 	BSA_Operator_ID = '#FORM.FilterDataList#'
				</cfquery>
				<CFIF getOperatorBusinessSegmentId.recordcount GT 0>
					<cfset businessSegmentId = getOperatorBusinessSegmentId.Business_Segment_ID />
				</CFIF>
				--->
				<!--- when payee is operator do not filter on business segment --->
				<cfset businessSegmentId = 0 />
				<cfset segment_enabled_for_distributor = 0 />
			</cfcase>
			<cfcase value="3"><!--- Broker --->
				<cfset useLakebaseForgetBrokerBusinessSegmentId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForgetBrokerBusinessSegmentId>
	<cftry>
		<cfset getBrokerBusinessSegmentId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_brokers", {
				"bsa_foodservice_brokers_id" = "eq.#FORM.FilterDataList#",
				"select" = "business_segment_id"
			}), "business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBrokerBusinessSegmentId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBrokerBusinessSegmentId>
<cfquery name="getBrokerBusinessSegmentId" datasource="#Application.Datasource#">
					SELECT 	Business_Segment_ID
					FROM	BSA_Foodservice_Brokers
					WHERE 	BSA_Foodservice_Brokers_ID = '#FORM.FilterDataList#'
				</cfquery>
</cfif>
				<CFIF getBrokerBusinessSegmentId.recordcount GT 0>
					<cfset businessSegmentId = getBrokerBusinessSegmentId.Business_Segment_ID />
				</CFIF>
			</cfcase>
		</CFSWITCH>
	</cfif>
</cfif>

<!--- data filter based on payee--->

<CFSET ApplyFilter = 0>


<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<!--- 	########	get list of pricing templstes to exclude from search results	########
		########	used for auto bb stuff...could be applied for other purposes 	########
		########	Discount Identifier Filter										########--->
<cfif form.DiscIDFilter>
	<cfset useLakebaseForgetPricingTemplateList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetPricingTemplateList>
	<cftry>
		<cfset getPricingTemplateList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "pricing_template_list"
			}), "pricing_template_list"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPricingTemplateList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPricingTemplateList>
<cfquery name="getPricingTemplateList" datasource="#Application.Datasource#">
		SELECT Pricing_Template_List
			FROM _Application_Settings
	</cfquery>
</cfif>
</cfif>
<!--- Filter on Programs with components that have "is_Auto_pay = 1" claim_mechanics --->
<cfif form.isAutoPaySearch eq 1>
	<cfset useLakebaseForqGetAutoPayClaimMechanics = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForqGetAutoPayClaimMechanics>
	<cftry>
		<cfset qGetAutoPayClaimMechanics = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"is_auto_pay" = "eq.1",
				"select" = "payment_type_id"
			}), "payment_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAutoPayClaimMechanics = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAutoPayClaimMechanics>
<cfquery name="qGetAutoPayClaimMechanics" datasource="#Application.Datasource#">
		SELECT Payment_Type_Id
		FROM Payment_Type
		WHERE is_Auto_Pay = 1
	</cfquery>
</cfif>
	<CFSET Filter_Auto_Pay_Claim_Mech_List = ValueList(qGetAutoPayClaimMechanics.Payment_Type_Id)>
</cfif>
<!---TSF: Label 10612 - Adding program filters based on users position.--->
<cfinclude template="../../Scorecard/access_permissions.cfm" />

<cfif not isdefined("HQUser")>
	<cfset HQUser = 0 />
</cfif>

<cfset variables.program_numbers = []>  <!--- 55530 --->
<cfif len(trim(form.program_list))>
    <!--- program list exists :: remove carriage returns & line feeds, then split entries into an array --->
    <cfset variables.program_numbers = listToArray( replace(form.program_list, chr(13) & chr(10), " ", "all"), " " )>
</cfif>


<!--- D31683:Processing HCIS Payment Requests START--->
<!---<cfset SearchExpiredProgramWithin = CreateObject("component", "components.billback.BillbackSettingsManager").getSearchExpiredProgramWithin() />--->
<!--- D31683:Processing HCIS Payment Requests END--->
<cftransaction isolation="read_uncommitted">
<CFQUERY NAME="TheQuery" datasource="#application.datasource#" result="TheQuery_result"> <!--- Dev Note: Kal ; 8665 : Dont allow billbacks on programs flagged not to allow  --->
		<cfif not HQUser>
		DECLARE @Positions_Below_Me table
		(
		  Below_User_Positions_ID   int          NOT NULL
		)

	INSERT INTO @Positions_Below_Me(Below_User_Positions_ID)
	SELECT	DISTINCT Below_User_Positions_ID
	FROM	Positions_Below_Me
	WHERE	User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
	</cfif>

	DECLARE @program_id_list table (contract_main_id int)
	<!---
		D29052/Anand Rao/03-Nov-2011
		This code from above was moved here so that the variable Filter_CID_List variable
		can be eliminated and the data could be selected from the temp table to avoid the
		error that was happening because of very large data
	--->
	<CFSET ApplyFilter = 0>
	<CFIF isdefined("FORM.FilterSearchPrograms") AND ShowAllPrograms IS NOT 1>
	<!--- <CFIF FORM.FilterSearchPrograms NEQ 0 AND len(trim(FORM.FilterDataList)) GT 0> --->

	<CFIF FORM.FilterSearchPrograms NEQ 0>
		<CFSWITCH expression="#FORM.FilterType#">
			<cfcase value="1"><!--- Distributor --->

				<!--- XX They should not get here without a dist_id in the var FilterDataList, 									XXXXXX
					  XX but if they do (again), we need to check.  filtertype 1 means it is a distributor payee and the user	XXXXXX
					  XX can not get by the payye screen without making a selection...but some are able to? 					XXXXXX--->
				<cfif trim(FORM.FilterDataList) neq ''>
						INSERT INTO @program_id_list (contract_main_id)
						SELECT Contract_Distributors.Contract_Main_ID
						FROM Contract_Distributors
						<!--- Dev Note: Milan; 19434 - The business segment in the program should match the payee's --->
						<cfif segment_enabled_for_distributor>
						 INNER JOIN Contract_Main
						 ON Contract_Main.Contract_Main_ID = Contract_Distributors.Contract_Main_ID
						 INNER JOIN BSA_Foodservice_Customers
						 ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
						 AND BSA_Foodservice_Customers.business_segment_id = Contract_Main.business_segment_id
						</cfif>
						WHERE Contract_Distributors.BSA_Foodservice_Customers_ID IN (#PreserveSingleQuotes(filterslist)#) <!--- D31454:Single Billback Per Invoice:   program search logic --->
						AND Contract_Distributors.Deleted = 0
				</cfif>
				<CFSET ApplyFilter = 1>
			</cfcase>
			<cfcase value="2"><!--- Operator --->
					INSERT INTO @program_id_list (contract_main_id)
					SELECT Contract_Operators.Contract_Main_ID
					FROM Contract_Operators
					<!--- Dev Note: Milan; 19434 - The business segment in the program should match the payee's --->
					<!--- KE: You can get rid of business segment for operator.  GM will not have business segment for operator.  And none of our other clients have business segment for operator, yet. --->
					<!---
					<cfif segment_enabled_for_distributor>
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID = Contract_Operators.Contract_Main_ID
						INNER JOIN BSA_Operator
						ON BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
						AND BSA_Operator.business_segment_id = Contract_Main.business_segment_id
					</cfif>
					--->
					WHERE Contract_Operators.BSA_Operator_ID = '#FORM.FilterDataList#'
					AND Contract_Operators.Deleted = 0
				<CFSET ApplyFilter = 1>
			</cfcase>
			<cfcase value="3"><!--- Broker --->
					DECLARE @Broker_Legcy_Shard nvarchar(100)
					SELECT	@Broker_Legcy_Shard = BSA_Foodservice_Brokers.Broker_Legcy_Shard
					FROM	BSA_Foodservice_Brokers
					WHERE	BSA_Foodservice_Brokers_ID = '#FORM.FilterDataList#'

					DECLARE @BrokersWithLegacyMatch table
					(
					Broker_ID uniqueidentifier
					)
					INSERT INTO @BrokersWithLegacyMatch (Broker_ID)
					SELECT	BSA_Foodservice_Brokers_ID
					FROM	BSA_Foodservice_Brokers
					WHERE	Broker_Legcy_Shard = @Broker_Legcy_Shard

					INSERT INTO @program_id_list (contract_main_id)
					SELECT Contract_Brokers.Contract_Main_ID
					FROM 	Contract_Brokers
					<!--- Dev Note: Milan; 19434 - The business segment in the program should match the payee's --->
					<cfif segment_enabled_for_distributor>
						INNER JOIN Contract_Main
						ON Contract_Main.Contract_Main_ID = Contract_Brokers.Contract_Main_ID
						INNER JOIN BSA_Foodservice_Brokers
						ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Contract_Brokers.BSA_Foodservice_Brokers_ID
						AND BSA_Foodservice_Brokers.business_segment_id = Contract_Main.business_segment_id
					</cfif>
					WHERE 	Contract_Brokers.Deleted = 0
					AND		Contract_Brokers.BSA_Foodservice_Brokers_ID IN (SELECT Broker_ID FROM @BrokersWithLegacyMatch)

				<CFSET ApplyFilter = 1>
			</cfcase>
			<cfdefaultcase>
				<CFSET ApplyFilter = 1>
			</cfdefaultcase>
		</CFSWITCH>
	</CFIF>
</CFIF>


	<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		DECLARE @Profile_Forbidden_Template table
		(
		  Template_ID   int          NOT NULL,
		  Forbid_Access_Type int          NOT NULL
		)
		INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
		select 	distinct template_id, Forbid_Access_Type
		from 	Profile_Forbidden_Template
		where 	Deleted = 0
				AND Forbid_Type = #forbidType#
				AND profile_id = #Get_Profile_Settings.Profiles_ID#


	SELECT	DISTINCT
			DateDiff(d, Contract_Main.Contract_End_Date, GetDate()) AS Dateinquestion,
			Contract_Main.Contract_Main_ID,
			Contract_Number,
			Contract_Title,
			Contract_Start_Date,
			Contract_End_Date,
			Contract_Status_Type_ID,
			Contract_Status_Type_Desc,
			Program_Control_Panel_Options.Created_Type,
			Contract_Status_Type_IDX,
			Cancelled_Date,
			Cancelled.Name_First + ' ' + Cancelled.Name_Last AS Cancelled_Name
	FROM	Contract_Main
			INNER JOIN Contract_Status_Types ON (Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX)
			INNER JOIN Contract_Main_Aux_Data ON (Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID)
			LEFT JOIN Accounting_Program_Type ON (Accounting_Program_Type.Accounting_Program_Type_ID = Contract_Main_Aux_Data.Accounting_Program_Type_ID)
			INNER JOIN	Program_Control_Panel_Options ON (Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
			<cfif FORM.Program_Template_Name NEQ 0>
			AND Program_Control_Panel_Options.Created_Type = '#FORM.Program_Template_Name#'
			</cfif>

			<cfif form.DiscIDFilter>
				INNER JOIN Discount_Identifier d ON d.Discount_Identifier_id = Program_Control_Panel_Options.Discount_Identifier_id
				AND Discount_Identifier_number NOT IN (#ListQualify(getPricingTemplateList.Pricing_Template_List,"'",",","all")#)
			</cfif>
			LEFT OUTER JOIN _Users Cancelled
			ON (Cancelled.User_ID = Contract_Main.Cancelled_By)

			LEFT JOIN _Users responsibleSalesPerson
			ON 	responsibleSalesPerson.User_ID = Responsible_User_ID
			AND	responsibleSalesPerson.Deleted = 0

			<!--- Add distributor criteria --->
			<CFIF ((Len(Form.Customer_Filter) GT 0) AND ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))) OR (Len(Form.Distributor_Name) GT 0) OR FORM.Distributor_ID NEQ "" OR FORM.Distributor_Bill_To_ID NEQ "">
			INNER JOIN Contract_Distributors
			ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND Contract_Distributors.Deleted = 0
			INNER JOIN BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			<cfif Form.Distributor_ID NEQ "">
			AND BSA_FoodService_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_ID#'
			</cfif>
			<CFIF FORM.Distributor_Bill_To_ID NEQ "">
			AND BSA_FoodService_Customers.Distributor_Bill_To_ID = '#FORM.Distributor_Bill_To_ID#'
			</CFIF>
			<cfif Len(Form.Distributor_Name) GT 0>
			AND BSA_FoodService_Customers.Name LIKE '%#Form.Distributor_Name#%'
			</cfif>

			<cfif Form.Buying_Group NEQ "0">
			INNER JOIN Distributor_Buying_Groups
			ON Distributor_Buying_Groups.Buying_Group_ID = BSA_Foodservice_Customers.Buying_Group_ID
			AND Distributor_Buying_Groups.Buying_Group_ID = '#Form.Buying_Group#'
			</cfif>

			<cfif Form.Family_Name NEQ "0">
			INNER JOIN Distributor_Family
			ON Distributor_Family.Family_ID = BSA_Foodservice_Customers.Family_ID
			AND Distributor_Family.Family_ID = '#Form.Family_Name#'
			</cfif>

			<!--- Any distributor criteria --->
			</cfif>

			<!--- Payment frequency on program data --->
			<cfif FORM.Payment_Cycle_ID NEQ 0 AND appSettings.getPaymentCycleAtDiscountType()>
				INNER JOIN Program_Payment_Cycle
				ON Program_Payment_Cycle.Payment_Cycle_ID = <cfqueryparam value="#FORM.Payment_Cycle_ID#" cfsqltype="numeric">
				AND Program_Payment_Cycle.Deleted = 0
				AND Program_Payment_Cycle.Program_ID = Contract_Main.Contract_Main_ID
			<!--- They selected a payment cycle --->
			</cfif>

			<!--- Join to comps for payment type on component level --->
			<cfif (FORM.Payment_Type_ID NEQ 0 AND appsettings.getClaims_at_Comp_Level() EQ 1) OR Form.isAutoPaySearch eq 1>
			<!--- Fixed --->
			LEFT JOIN Program_Fixed_Component
			ON Program_Fixed_Component.Program_ID = Contract_Main.Contract_Main_ID
			AND Program_Fixed_Component.Deleted = 0
			<!--- Rebate --->
			LEFT JOIN Program_Rebates_Component
			ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID
			AND Program_Rebates_Component.Deleted = 0
			<!--- Lump Sum --->
			LEFT JOIN Program_Lump_Sums
			ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID
			AND Program_Lump_Sums.Deleted = 0
			<!--- Growth --->
			LEFT JOIN Program_Growth_Components
			ON Program_Growth_Components.Program_ID = Contract_Main.Contract_Main_ID
			AND Program_Growth_Components.Deleted = 0
			</cfif>


	WHERE	Contract_Main.Deleted = 0
			<cfif variables.VendorOnlyBillback eq 1>
			AND Program_Control_Panel_Options.Allow_Vendor_Only = 1
			</cfif>
			AND Contract_Status_Types.Contract_Status_Type_ID >= 4

			<!--- Payment type checks --->
			<cfif FORM.Payment_Type_ID NEQ 0>
				<!--- on program level --->
				<cfif appsettings.getClaims_at_Comp_Level() NEQ 1>
				AND Contract_Main.ClaimMechanics = '#FORM.Payment_Type_ID#'
					<cfif Form.isAutoPaySearch eq 1>
						AND Contract_Main.ClaimMechanics IN <cfqueryparam list="true" value="#Filter_Auto_Pay_Claim_Mech_List#">
					</cfif>
				<cfelse>
				<!---- on component level --->
				AND
				(
					Program_Fixed_Component.Claim_Mechanics = '#FORM.Payment_Type_ID#'
					OR
					Program_Rebates_Component.Claim_Mechanics = '#FORM.Payment_Type_ID#'
					OR
					Program_Lump_Sums.Claim_Mechanics = '#FORM.Payment_Type_ID#'
					OR
					Program_Growth_Components.Claim_Mechanics = '#FORM.Payment_Type_ID#'
				)
				</cfif>
			</cfif>
			<cfif form.isAutoPaySearch eq 1>
				<!--- on program level --->
				<cfif appsettings.getClaims_at_Comp_Level() NEQ 1>
					AND Contract_Main.ClaimMechanics IN (<cfqueryparam value="#Filter_Auto_Pay_Claim_Mech_List#">)
				<cfelse>
				<!---- on component level --->
				AND
				(
					Program_Fixed_Component.Claim_Mechanics IN (<cfqueryparam list="true" value="#Filter_Auto_Pay_Claim_Mech_List#">)
					OR
					Program_Rebates_Component.Claim_Mechanics IN (<cfqueryparam list="true" value="#Filter_Auto_Pay_Claim_Mech_List#">)
					OR
					Program_Lump_Sums.Claim_Mechanics IN (<cfqueryparam list="true" value="#Filter_Auto_Pay_Claim_Mech_List#">)
					OR
					Program_Growth_Components.Claim_Mechanics IN (<cfqueryparam list="true" value="#Filter_Auto_Pay_Claim_Mech_List#">)
				)
				</cfif>
			</cfif>

			<!--- BJF Do not show "cancelled like they never existed" programs --->
			AND
			(
				Manual_Cancel = 0
				OR
				(	Manual_Cancel = 1
				And   Cancel_And_End_Dated = 1
				)
			)

			<!--- Payment cycle check for program level --->
			<cfif FORM.Payment_Cycle_ID NEQ 0 AND NOT appSettings.getPaymentCycleAtDiscountType()>
			AND Contract_Main.ClaimMechanics = #FORM.Payment_Cycle_ID#
			</cfif>

			<!---TSF: Label 10752 - Don't show expired by default--->
			<CFIF not Form.Status>
			AND (
				Contract_Status_Types.Contract_Status_Type_ID <> 7
				<cfif IsNumeric(SearchExpiredProgramWithin)>
				OR (DateDiff(d, Contract_Main.Contract_End_Date, GetDate()) <= #SearchExpiredProgramWithin# <!--- BJF: I don't know why this code was here, but it's preventing any expired programs from showing, regardless of whether they were cancelled ... AND Cancel_And_End_Dated = 1 --->)
				</cfif>
				)
			</CFIF>
			AND ISNULL(Accounting_Program_Type.APT_Allow_Billbacks, 1) = 1
			AND Contract_Main.Flagged_As_Purged = 0
			AND
				(
					(
						(
							Contract_Main.Parent_Revised_Contract_Main_ID IS NULL
						)
						AND
						(
							Contract_Main.Revision_of_Contract_Main_ID IS NULL
						)
					)
					OR
					(
						NOT
						(
							Contract_Main.Parent_Revised_Contract_Main_ID IS NULL
						)
						AND NOT
								(
									Contract_Main.Revision_of_Contract_Main_ID IS NULL
								)
						AND Contract_Status_Types.Contract_Status_Type_ID >= 4
					)
				)

			<CFIF Form.Status NEQ "0">
				AND Contract_Status_Types.Contract_Status_Type_ID = #Form.Status#
			</CFIF>

			<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
			<cfif len(Trim(FORM.ProgramType)) GT 0>
				<cfset FORM.Generic_Type = FORM.ProgramType>
			</cfif>
			<CFIF FORM.FilterSearchPrograms NEQ 2>
				<CFIF Form.Generic_Type NEQ "0">
					AND Program_Control_Panel_Options.Generic_Type = '#FORM.Generic_Type#'
				<CFELSE>
					AND Program_Control_Panel_Options.Generic_Type NOT LIKE 'Distributor Off-Invoice'
				</CFIF>
			<CFELSE>
				AND Program_Control_Panel_Options.Generic_Type = 'Distributor Trade/Shelter'
			</CFIF>

			<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
			<CFIF FORM.Discount_Identifier NEQ "0" AND IsNumeric(FORM.Discount_Identifier)>
				AND	Program_Control_Panel_Options.Discount_Identifier_ID = '#FORM.Discount_Identifier#'
			</CFIF>

			<!--- Use ActiveWithinSpan to find a program that was active between the dates listed --->
			<cfif ActiveWithinSpan NEQ 1>
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

			<!--- the active within span flag is turned on --->
			<cfelse>
				<cfif len(trim(Form.Start_Date)) GT 0 AND len(trim(Form.End_Date)) GT 0 AND ISDate(Form.Start_Date) AND ISDate(Form.End_Date)>
				<!--- if both dates are defiend --->
				AND
				(
					(
						Contract_Start_Date <= '#Form.End_Date#'
						AND
						Contract_End_Date >= '#Form.Start_Date#'
					)
				<cfif form.isAutoPaySearch eq 1>
					OR
					(
						(SELECT MIN(Effective_Start_Date) from Contract_Main CM_STart where (CM_STart.Contract_Number = Contract_Main.Contract_Number ) and CM_STart.Approved = 1) <= '#Form.End_Date#'
						AND
						(SELECT MAX(Effective_END_Date) from Contract_Main CM_END where (CM_END.Contract_Number = Contract_Main.Contract_Number ) and CM_END.Approved = 1) >= '#Form.Start_Date#'
					)
				</cfif>
				)

				</cfif>
			</cfif>
			<!--- ActiveWithinSpan --->

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
					SELECT	TOP 1 Contract_Operators.Contract_Main_ID
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
			<CFIF Len(trim(FORM.BSA_Operator_ID)) GT 0>
						<!--- <cfif isnumeric(FORM.BSA_Operator_ID)> --->
							<cfset tmpBSAOperatorString = FORM.BSA_Operator_ID />
						<!--- <cfelse>
							<cfset tmpBSAOperatorString = 0 />
						</cfif> --->

				AND
				EXISTS
				(
					SELECT	TOP 1 Contract_Operators.Contract_Main_ID
					FROM	Contract_Operators
							INNER JOIN	BSA_Operator
							ON
							(
								(BSA_Operator.Deleted = 0)
								AND
								(Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID)
								AND
								(<!--- D25340 - Billbacks:  Change operator fields in program search page --->
									<CFIF isnumeric(FORM.BSA_Operator_ID)>
									BSA_Operator.BSA_Operator_ID = '#tmpBSAOperatorString#' OR
									</CFIF>
									BSA_Operator.Legacy_ID LIKE '%#tmpBSAOperatorString#%'
								)
							)
					WHERE
						Contract_Operators.Contract_Main_ID = Contract_Main.Contract_Main_ID
						AND
						Contract_Operators.Deleted = 0

				)
			</CFIF>

			<CFIF Form.Broker_ID NEQ "0">
				AND EXISTS
				(
					SELECT TOP 1 CB.Contract_Main_ID
					FROM Contract_Distributors CD
						INNER JOIN Contract_Brokers CB ON CB.Contract_Main_ID = Contract_Main.Contract_Main_ID AND CB.Deleted = 0 AND CD.Deleted = 0
						LEFT JOIN BSA_FoodService_Customers BSAFC ON BSAFC.BSA_FoodService_Customers_ID = CD.BSA_FoodService_Customers_ID
						<cfif appSettings.getDistributorMultiPosition()>
							LEFT JOIN Market_Distributor MD ON MD.Distributor_ID = BSAFC.BSA_FoodService_Customers_ID AND MD.Deleted = 0
						</cfif>
						INNER JOIN BSA_Foodservice_Brokers BSAFB ON BSAFB.BSA_Foodservice_Brokers_ID = CB.BSA_Foodservice_Brokers_ID
						<cfif NOT appSettings.getDistributorMultiPosition()>
							OR BSAFC.BSA_Foodservice_Brokers_ID = BSAFB.BSA_Foodservice_Brokers_ID
						<cfelse>
							OR MD.Service_Market_ID = BSAFB.Service_Market_ID
						</cfif>
					WHERE BSAFB.BSA_Foodservice_Brokers_ID IN ('#Form.Broker_ID#')
						AND
						(
							(CD.Deleted = 0 AND CD.Contract_Main_ID = Contract_Main.Contract_Main_ID)
						OR
							(CB.Deleted = 0 AND CB.Contract_Main_ID = Contract_Main.Contract_Main_ID)
						)
				)
			</CFIF>


			<!--- Moved distributor lookups from where to Joins --->

			<!--- <CFIF ((Len(Form.Customer_Filter) GT 0) AND ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))) OR (Len(Form.Distributor_Name) GT 0) OR FORM.Distributor_ID NEQ "" OR FORM.Distributor_Bill_To_ID NEQ "">
				AND
				EXISTS
				(
				SELECT	TOP 1 Contract_Distributors.Contract_Main_ID
				FROM
						Contract_Distributors
						---INNER JOIN START
						INNER JOIN
						BSA_FoodService_Customers
						ON
						(BSA_FoodService_Customers.BSA_FoodService_Customers_ID =
																	<cfif form.DiscIDFilter> <!--- join on rebate_recipient instead of contract_distributor id --->
																		Contract_Main.Rebate_Recipient_Customer_ID)
																	<cfelse>
																		Contract_Distributors.BSA_FoodService_Customers_ID)
																	</cfif>
						<CFIF (Len(Form.Customer_Filter) GT 0) AND ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))>
						AND
						NOT (BSA_FoodService_Customers.BSA_FoodService_Customers_ID IS NULL)
						</CFIF>
						<CFIF Len(Trim(Form.Distributor_Name)) GT 0>
						AND
						(
						BSA_FoodService_Customers.Name LIKE '%#Form.Distributor_Name#%'
						OR
						BSA_FoodService_Customers.Shr_Ship_To LIKE '%#Form.Distributor_Name#%'
						)
						</CFIF>
						<CFIF FORM.Distributor_ID NEQ "">
						AND BSA_FoodService_Customers.BSA_Foodservice_Customers_ID = '#FORM.Distributor_ID#'
						</CFIF>
						<CFIF FORM.Distributor_ID EQ "" AND FORM.Distributor_Bill_To_ID NEQ "">
						AND Distributor_Bill_To_ID = '#FORM.Distributor_Bill_To_ID#'
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
							SELECT	TOP 1 Distributor_Family.Family_ID
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
							SELECT	TOP 1 Distributor_Buying_Groups.Buying_Group_ID
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
			</CFIF> --->

			<cfif len(vars.lUserSegments)>   <!---31706--->
				AND Contract_Main.Business_Segment_ID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#vars.lUserSegments#" list="yes"> )
			</cfif>

			<!--- Do not restrict by conditions, if accessing from a place where there should be no restrictions, like program search from Aliases (Flex or non-Flex) --->
			<cfif ProgramRestrictions eq 1>
			 <cfif segment_enabled_for_distributor and trim(FORM.FilterDataList) neq '' AND FORM.FilterType NEQ 0>
				<cfif isNumeric(businessSegmentId)>
				  AND Contract_Main.Business_Segment_ID = #businessSegmentId#
				<cfelse>
				AND	1 = 2
				</cfif>
			  </cfif>
			</cfif>

			<CFIF (ApplyFilter EQ 1 AND (FORM.FilterDataList neq 0 AND FORM.FilterDataList neq ''))>
				AND Contract_Main.Contract_Main_ID IN(select contract_main_id from @program_id_list)
			</CFIF>

            <cfif arrayLen(variables.program_numbers)>  <!--- 55530 --->
                AND ( 1 = 0 <cfloop from="1" to="#arrayLen(variables.program_numbers)#" index="variables.program_index"> OR Contract_Main.Contract_Number LIKE '%#trim(variables.program_numbers[ variables.program_index ])#%' </cfloop> )
            </cfif>

			<!--- "Paid to" filter should be used even when "Do not restrict to programs with payee" option is checked when in modify program. --->
			<cfif IsDefined("Form.FilterSearchPrograms") and IsDefined("Form.FilterType") and IsDefined("Form.ModifyProgram")>
				<!---
					Dev Note: Kal; D42646: Do not filter for Payee - Manual Billbacks
					On Switch Program, we want to restrict the programs in the results to align with the payee type in the billback, as if the check box was OFF.
					On Search Program, we want to restrict the programs in the results to align with the payee type in the billback, only when the check box is OFF. When ON no filters
				 --->

				<cfif (Form.FilterSearchPrograms neq 0 AND Form.FilterType neq 0) AND (Form.ModifyProgram eq 1 OR ShowAllPrograms eq 0)>
					AND Contract_Main.Contract_Main_ID IN
					(
						<!---Fixed --->
						SELECT Program_ID
						FROM Program_Fixed_Component	<!--- Must have at least one component that is not restricted from billbacks --->
						INNER JOIN Payment_Type
						ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
						WHERE Program_Fixed_Component.Deleted = 0
						  AND (Program_Fixed_Component.Fixed_Component_Paid_To = #FORM.FilterType#
									OR (Program_Fixed_Component.Fixed_Component_Paid_To = 4 AND #FORM.FilterType# != 3))

						UNION <!---Rebates --->
						SELECT Program_ID
						FROM Program_Rebates_Component	<!--- Must have at least one component that is not restricted from billbacks --->
						INNER JOIN Payment_Type
						ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
						WHERE Program_Rebates_Component.Deleted = 0
							AND (Program_Rebates_Component.Component_Paid_To = #FORM.FilterType#
									OR (Program_Rebates_Component.Component_Paid_To = 4 AND #FORM.FilterType# != 3))

						<cfif Form.ModifyProgram eq 0>
						<!--- Matching programs while "modifying programs" will not look at lumpsum, since currently we do not even have a feature (dropdown) for lumpsum
		.				on the switch program page (switch_program.cfm).So, programs cannot be modified to lumpsum, even if the program on the billback has a lumpsum.
						This can avoid one issue: - If a bb has rebate (or any discount type), where the payee is an operator (or distributor), the code will not look for matching
						bb's which have a lumpsum with component paid to operator. The "paid to" matches can be on any other discount type.
						--->
						UNION <!--- Lump sums --->
						SELECT Program_ID
						FROM Program_Lump_Sums	<!--- Must have at least one component that is not restricted from billbacks --->
						INNER JOIN Payment_Type
						ON Program_Lump_Sums.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
						WHERE Program_Lump_Sums.Deleted = 0
							AND (Program_Lump_Sums.Component_Paid_To = #FORM.FilterType#
									OR (Program_Lump_Sums.Component_Paid_To = 4 AND #FORM.FilterType# != 3))
						</cfif>


						UNION <!--- Growth --->
						SELECT Program_ID
						FROM Program_Growth_Components	<!--- Must have at least one component that is not restricted from billbacks --->
						INNER JOIN Payment_Type
						ON Program_Growth_Components.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0
						WHERE Program_Growth_Components.Deleted = 0
							AND (Program_Growth_Components.Component_Paid_To = #FORM.FilterType#
									OR (Program_Growth_Components.Component_Paid_To = 4 AND #FORM.FilterType# != 3))


						UNION <!--- Formula (no payable to or comps... a program that has formula should be eligible --->
						<!--- OLD LOGIC -> Formula rules are now Mapped instead of created in the program
								SELECT Program_ID
								FROM Program_Formula_Pricing_Rules
								WHERE Program_Formula_Pricing_Rules.Deleted = 0 --->

						SELECT Program_ID
						FROM Program_Formula_Pricing_Rule_Mapped PFPRM
						WHERE PFPRM.Deleted = 0

						UNION <!--- Bid Request --->
						SELECT Program_ID
						FROM Program_BidRequest_Component	<!--- Ana 19914: Commentting the below. We do not have claim mechanics at Bid request component level --->
						<!--- INNER JOIN Payment_Type
						ON Program_BidRequest_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
						AND Payment_Type.Restrict_From_Billback = 0 --->
						WHERE Program_BidRequest_Component.Deleted = 0
							AND (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = #FORM.FilterType#
									OR (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = 4 AND #FORM.FilterType# != 3))
					)
				</cfif>
			</cfif>

		<!--- Do not restrict by conditions, if accessing from a place where there should be no restrictions, like program search from Aliases (Flex) --->
		<cfif ProgramRestrictions eq 1>

		<cfif not HQUser AND Get_Profile_Settings.BB_Add_Payee_Any_Position NEQ 1>
			AND
			(
				(
					Creating_User_Position_ID IN(#PreserveSingleQuotes(UserPositionList)#)
				)
				OR
				(
					Creating_User_Position_ID IN (#preserveSingleQuotes(GP_Position_List_From_My_Position_Down)#)
				)
				<!--- When this setting is on, we only show programs created by the users with the same position.
							Execute the code below only when the setting is off. "ProgramsWithDistUnderMe" and "ProgramsWithBrokerUnderMe"
							are set in scorecard/access_permissions.cfm
				--->
				<cfif NOT Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
				OR
				(
					Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithDistUnderMe)#)
				)
				OR
				(
					Contract_Main.Contract_Main_ID IN(#PreserveSingleQuotes(ProgramsWithBrokerUnderMe)#)
				)
				</cfif>
			)
		</cfif>

<!--- If the below profile settings is on, then the user should only be allowed to see programs
			that have him/her as an RSP OR where the program creator's RSP has the user number same as
			this user's User number
--->
		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
			<cfset programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>

			<cfset qUserNumber = "" />
			<cfif appSettings.getUserNumberRestrict()>
				<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(programScorecardRestrictCreatedByUserId) />
				<cfset qUserNumber = qUser.User_Number />
			</cfif>
			AND (responsibleSalesPerson.User_ID = '#programScorecardRestrictCreatedByUserId#'
				<cfif Len(qUserNumber) GT 0>
			OR responsibleSalesPerson.User_Number = '#qUserNumber#'
				</cfif>
			)
		</cfif>

		<!--- If forbidType is allow, then the user should only be able to see these programs in these templates, else
					the user should be able to see all programs except the programs in these templates
		--->
			AND Contract_Main.ProgramType_ID
			<cfif forbidType EQ 1>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
			in
			<!--- (Forbid_Access_Type = 1 means 'Access') --->
			(select Template_ID from @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)
		</cfif>
			ORDER BY #sql_Sort_By#
</CFQUERY>
</cftransaction>
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many programs in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY' ) && (e.name != 'ShowAllPrograms' )) {
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
	<CFIF TheQuery.recordcount GT 0>

		<DIV ALIGN="center">
		&nbsp;&nbsp;&nbsp;
		<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT><a href="#" onclick="javascript: finishedSearching()"> import selected program<CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<CFIF FORM.AllowImportAll EQ 1>
		<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT><a href="#" STYLE="cursor: pointer;" onclick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned programs </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT><a href="#" STYLE="cursor: pointer;" onclick="removeAllProducts()"> remove all selected programs </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<BR>
		</DIV>
		</cfif>
	</cfif>

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>&nbsp;#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>program<CFELSE>programs</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" align="center" WIDTH="685" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="left"><INPUT Name="allbox" TYPE="Checkbox" onclick="CA()" TITLE="Click here to select all Programs"></TD>
					<CFELSE>
						<TD>&nbsp;</TD>
					</CFIF>
					<CFSET HeaderNameList="Number,Title,Start Date,End Date">
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
						<TD ID="header" align="left" nowrap><cfif len(trim(this_Header)) GT 0><A href="##" onclick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></CFIF></A></TD>
						</CFLOOP>
						</cfoutput>
<!--- 					<TD align="left" NOWRAP ID="header"><B>Number</B></TD>
					<TD align="left" ID="header"><B>Title</B></TD>
					<TD align="left" ID="header"><B>Start Date</B></TD>
					<TD align="left" ID="header"><B>End Date</B></TD> --->
				</TR>

			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<cf_cryp string="#TheQuery.Contract_Main_ID#" type="en" key="#request.key#">
				<CFSET CID = cryp.value>

				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<TD align="left">
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.Contract_Main_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.Contract_Main_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.Contract_Main_ID), ",")></CFIF>>
						<CFELSE>

							<!--- If we're switching programs only show program we're switching from --->
							<cfif len(trim(Program_ID)) EQ 0>
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.Contract_Main_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.Contract_Main_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.Contract_Main_ID), ",")></CFIF>>
						<cfelse>
						<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.Contract_Main_ID)#" <CFIF Program_ID EQ TheQuery.Contract_Main_ID>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.Contract_Main_ID), ",")></CFIF>>
						<!--- If we're switching programs only show program we're switching from --->
						</cfif>
						</CFIF>
						<cfif TheQuery.Contract_Status_Type_IDX IS 7 AND len(trim(TheQuery.Cancelled_Date)) GT 0>
							<img src="/images/delete.gif" title="Cancelled by #Cancelled_Name#">
						</cfif>

					</TD>
					<TD NOWRAP>#TheQuery.Contract_Number#&nbsp;
					<br><A onclick="javaScript: NewWindow(this.href , 'Catalog_Program' , 750 , 550 , 'yes' , 'yes'); return false;" target="_blank" href="/scorecard/program_display.cfm?display_program=1&CID=#CID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #TheQuery.Contract_Number#"><font color="660033"><b>Preview</b></font></A></TD>
					<TD>#TheQuery.Contract_Title# <BR>(#TheQuery.Contract_Status_Type_Desc#)</TD>

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
	<INPUT TYPE="hidden" NAME="AlreadySelectedItems" 	VALUE="#Form.AlreadySelectedItems#">
	<INPUT TYPE="hidden" NAME="finishedselectingitems" 	VALUE="0">
	<INPUT TYPE="hidden" NAME="LoadSavedOperators" 		VALUE="0">
	<INPUT TYPE="Hidden" NAME="startrow" 				VALUE="#startrow#">
	<INPUT TYPE="Hidden" NAME="frompage" 				VALUE="#frompage#">
	<input type="hidden" name="button_caption" 			value="#FORM.Button_Caption#">
	<input type="hidden" name="FilterSearchPrograms" 	value="#Form.FilterSearchPrograms#">
	<input type="hidden" name="FilterType" 				value="#Form.FilterType#"> <!---  1= dis, 2 = op, 3 = br --->
	<input type="hidden" name="FilterDataList"			value="#Form.FilterDataList#">
	<input type="hidden" name="runsearchonfirstload"	value="#Form.runsearchonfirstload#">
	<input type="hidden" name="SelectSingleSearchResultOnly"	value="#Form.SelectSingleSearchResultOnly#">
	<input type="hidden" name="selectMultiResultOverRide" value="#Form.selectMultiResultOverRide#">
	<INPUT TYPE="Hidden" NAME="DiscIDFilter" VALUE = "#form.DiscIDFilter#">
	<INPUT TYPE="Hidden" NAME="DistName" VALUE = "#Form.DistName#">
	<input type="hidden" name="Program_ID" value="#Program_ID#">
	<input type="hidden" name="Billback_ID" value="#Billback_ID#">
	<input type="hidden" name="ActiveWithinSpan" value="#ActiveWithinSpan#">
	<input type="hidden" name="ISAUTOPAYSEARCH" value="#form.ISAUTOPAYSEARCH#">
	<INPUT TYPE="Hidden" NAME="FlexAppName" VALUE="#FORM.FlexAppName#">
	<INPUT TYPE="Hidden" NAME="ProgramRestrictions" VALUE="#Form.ProgramRestrictions#">
	<INPUT TYPE="HIDDEN" NAME="AllowImportAll"  VALUE="#form.AllowImportAll#">
	<INPUT TYPE="hidden" NAME="PageSource"  VALUE="#PageSource#">

</cfoutput>
</FORM>
	<cfif TheQuery.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a href="#" onclick="javascript: finishedSearching()"> import selected program<CFIF FORM.AllowImportAll EQ 1>s</CFIF> </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<CFIF FORM.AllowImportAll EQ 1>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a href="#" STYLE="cursor: pointer;" onclick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned programs </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a href="#" STYLE="cursor: pointer;" onclick="removeAllProducts()"> remove all selected programs </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<BR>
	</DIV>
	</cfif>
	</cfif>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Product";
			else pString = "Products";

			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);

				callfireEvent(document,document.all.allbox,'Click');

				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.Contract_Main_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= document.SearchForm.FinalUPCList.value + "," + "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";
					//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}
				else{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.Contract_Main_ID)#</CFOUTPUT>";
					<!------//document.SearchForm.FinalUPCList.value 	= "<CFOUTPUT>#whole_Product_List#</CFOUTPUT>";----->
				}

				document.MyForm.submit();
			}
			else
			{

			}
		}

		function removeAllProducts(){

			if(confirm("By pressing OK all selected records will be unselected")){
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'0' as an argument below means "false". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0);

				callfireEvent(document,document.all.allbox,'Click');

				document.MyForm.finishedselectingitems.value = 0;
				document.MyForm.FinalItemList.value 	= "";
				document.MyForm.AlreadySelectedItems.value 	= "";
			}
			else
			{

			}
		}

		function finishedSearching() {

			var bProgramChecked = false;

			for (var i=0;i<document.all.MyForm.elements.length;i++)
			{
				var e = document.all.MyForm.elements[i];
				if (e.name == 'SelectedITEMS' && e.checked == true)
				{
					bProgramChecked = true;
					break;
				}
			}

			if(bProgramChecked != true)
			{
				alert('At least one program must be selected.');
				return;
			}

			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}

	</cfif>

	function createList() {
		NewWindow('/common_files/createList2.cfm?parent=search_program', 'search_program_create_list', 350, 425, 'yes', 'yes');
	}

	<CFIF FORM.runsearchonfirstload EQ 1>
		//document.all.runsearchonfirstload.value = 0;
		//document.all.MyForm.submit();
	</CFIF>
</SCRIPT>
