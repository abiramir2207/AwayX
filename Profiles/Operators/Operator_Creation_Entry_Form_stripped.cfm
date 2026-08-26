<cfsilent>
<cfparam name="URL.CID" default="">
<cfif URL.CID neq "">
<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
</cfif>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfif Get_Profile_Settings.Create_Operator_Access NEQ 1>
	<script>
	window.close();
	</script>
	<cfabort>
</cfif>
<!---Gets application settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
<cfset businessSegManager= CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegManagerList =businessSegManager.getAll() />
<cfset OperatorSegEnable = businessSegManager.isEnabledForOperator()/>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->
<cfset Operator_Creation_Fields_Required =  appSettings.getOperator_Creation_Fields_Required()>
<!---72360 :: Add customer label for BSA ID START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!---72360 :: Add customer label for BSA ID END --->
<cfparam name="URL.businessSegementId" 	default="0">
<cfif (URL.businessSegementId EQ 3 OR URL.businessSegementId EQ 5) AND application.returned_customer_setting.customer_keyword EQ "conagra">
	<cfset URL.businessSegementId = 1>
</cfif>

<cfparam name="Action" default="Add">
<cfif isDefined("OID")>
	<cfset BSA_Operator_ID = OID>
</cfif>
<cfif NOT isDefined("BSA_Operator_ID")>
	<cfset Action="Add">
</cfif>

<cfparam name="OPERATOR_NAME"					default="">
<cfparam name="OPERATOR_ADDRESS"				default="">
<cfparam name="OPERATOR_CITY"					default="">
<cfparam name="OPERATOR_STATE"					default="">
<cfparam name="OPERATOR_ZIP"					default="">
<cfparam name="OPERATOR_Country_Code"			default="USA">
<cfparam name="OPERATOR_NUMBER_OF_LOCATIONS"	default="">
<cfparam name="OPERATORTYPE"					default="">
<cfparam name="OPERATORLOCATIONTYPE"			default="">
<cfparam name="OPERATOR_DBA"					default="">
<cfparam name="OPERATOR_FIRST_NAME"				default="">
<cfparam name="OPERATOR_LAST_NAME"				default="">
<cfparam name="OPERATOR_TITLE"					default="">
<cfparam name="zzz_Operator_Phone"				default="">
<cfparam name="Operator_Phone"					default="">
<cfparam name="FinalItemList"					default="">
<cfparam name="Legacy_ID"						default="">
<cfparam name="Display_Code"					default="">
<cfparam name="Source"							default="">
<cfparam name="Deleted"							default="">
<cfparam name="User_Date_Added"					default="">
<cfparam name="Added_By"						default="">
<cfparam name="User_Date_Edited"				default="">
<cfparam name="Edited_By"						default="">
<cfparam name="Notes"							default="">
<cfparam name="variables.Q_Brand_Legacy"		default="">
<cfparam name="variables.Contact_Address"		default="">
<cfparam name="variables.Contact_City"			default="">
<cfparam name="variables.Contact_State"			default="">
<cfparam name="variables.Contact_Zip"			default="">
<cfparam name="variables.Contact_Email"			default="">

<cfparam name="url.ProgramBusinessSegmentID" default="0" >
<cfparam name="Segment"					default="#url.ProgramBusinessSegmentID#">

<cfif Action IS "Edit">
	<cfset useLakebaseForSelectOperatorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForSelectOperatorInfo>
	<cftry>
		<cfset SelectOperatorInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"bsa_operator_id" = "eq.#BSA_Operator_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSelectOperatorInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSelectOperatorInfo>
<cfquery name="SelectOperatorInfo" datasource="#application.datasource#">
		SELECT * FROM BSA_Operator WHERE BSA_Operator_ID = '#BSA_Operator_ID#'
	</cfquery>
</cfif>

	<cfif SelectOperatorInfo.Recordcount IS 1>
		<cfscript>
			BSA_Operator_ID 			= 	SelectOperatorInfo.BSA_Operator_ID;
			OPERATOR_NAME 				= 	SelectOperatorInfo.OPERATOR_NAME;
			Legacy_ID 					= 	SelectOperatorInfo.Legacy_ID;
			OPERATOR_ADDRESS 			= 	SelectOperatorInfo.OPERATOR_ADDRESS;
			OPERATOR_CITY 				= 	SelectOperatorInfo.OPERATOR_CITY;
			OPERATOR_STATE 				= 	SelectOperatorInfo.OPERATOR_STATE;
			OPERATOR_ZIP 				= 	SelectOperatorInfo.OPERATOR_ZIP;
			OPERATOR_Country_Code 		= 	SelectOperatorInfo.OPERATOR_Country_Code;
			OPERATOR_NUMBER_OF_LOCATIONS=	SelectOperatorInfo.OPERATOR_NUMBER_OF_LOCATIONS;
			OPERATORTYPE 				= 	SelectOperatorInfo.OPERATOR_TYPE;
			OPERATORLOCATIONTYPE 		= 	SelectOperatorInfo.OPERATOR_LOCATION_TYPE;
			OPERATOR_DBA 				= 	SelectOperatorInfo.OPERATOR_DBA;
			OPERATOR_FIRST_NAME 		= 	SelectOperatorInfo.OPERATOR_FIRST_NAME;
			OPERATOR_LAST_NAME 			= 	SelectOperatorInfo.OPERATOR_LAST_NAME;
			OPERATOR_TITLE 				= 	SelectOperatorInfo.OPERATOR_TITLE;
			zzz_Operator_Phone			=	SelectOperatorInfo.zzz_Operator_Phone;
			Operator_Phone 				= 	SelectOperatorInfo.Operator_Phone;
			Legacy_ID					=	SelectOperatorInfo.Legacy_ID;
			Display_Code				=	SelectOperatorInfo.Display_Code;
			Deleted						=	SelectOperatorInfo.Deleted;
			User_Added_Date				= 	SelectOperatorInfo.User_Date_Added;
			Added_By					= 	SelectOperatorInfo.Added_By;
			User_Date_Edited			= 	SelectOperatorInfo.User_Date_Edited;
			Edited_By					= 	SelectOperatorInfo.Edited_By;
			Notes						=	SelectOperatorInfo.Notes;
			Segment				=   SelectOperatorInfo.Business_Segment_ID;
			variables.Q_Brand_Legacy	=	SelectOperatorInfo.Q_Brand_Legacy;
			variables.Contact_Address   =   SelectOperatorInfo.Contact_Address;
			variables.Contact_City   	=   SelectOperatorInfo.Contact_City;
			variables.Contact_State   	=   SelectOperatorInfo.Contact_State;
			variables.Contact_Zip   	=   SelectOperatorInfo.Contact_Zip;
			variables.Contact_Email   	=   SelectOperatorInfo.Contact_Email;
		</cfscript>
	</cfif>
</cfif>
</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<cfif Action IS "Edit">
		<TITLE>Edit Operator</TITLE>
	<cfelse>
		<TITLE>Create Operator</TITLE>
	</cfif>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">
	<script type="text/javascript">
		function invalidQuotes(o,w){
			o.value = o.value.replace(invalidQuotes.r[w],'');
		}
		invalidQuotes.r={
		'quotes':/['\''&'\"']/g
		}
	</script>
	<script>
		function resetOpenerOperatorWindowObject(){
			if(window.opener != null) {
				opener.operatorWindow=null
			}
			//window.close();
		}

		function verifyData(){
			ErrorCount = 0;

			<!--- name --->
			if(trim(document.all.Operator_Name.value).length == 0){
				ErrorCount++;
				queueMessage("You must enter an <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> name.", document.all.error_Name)
			}
			else {
				clearQueue(document.all.error_Name)
			}
		<!--- D58174 :: Operator Location Type END --->
			<!--- Legacy ID (Milan - 8961)--->
			if(document.all.Legacy_ID){
				if(trim(document.all.Legacy_ID.value) == ''){
						if (MyForm.Display_Code[0].checked){
							ErrorCount++;
							queueMessage("An operator cannot be made active without a legacy ID.", document.all.error_Legacy_ID);
						}
					}
			}
			else {
				clearQueue(document.all.error_Legacy_ID)
			}

			<cfif Operator_Creation_Fields_Required eq 1>
			<cfif OperatorSegEnable>
			//D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START
			<!--- Segment --->
			if(trim(document.all.Business_Segment.value) == 0)
			{
				ErrorCount++;
				queueMessage("You must select a <cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>.", document.all.error_Business_Segment)
			}
			else {
				clearQueue(document.all.error_Business_Segment)
			}
			//D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END
			</cfif>
			<!--- address --->
			if(trim(document.all.Operator_Address.value).length == 0){
				ErrorCount++;
				queueMessage("You must enter a street address.", document.all.error_Address)
			}
			else {
				clearQueue(document.all.error_Address)
			}

			<!--- city --->
			if(trim(document.all.Operator_City.value).length == 0){
				ErrorCount++;
				queueMessage("You must enter the city.", document.all.error_City)
			}
			else {
				clearQueue(document.all.error_City)
			}

			<!--- zip --->
			if(trim(document.all.Operator_Zip.value).length == 0){
				ErrorCount++;
				queueMessage("You must enter a valid postal code.", document.all.error_Zip)
			}
			else {
				clearQueue(document.all.error_Zip)

			}

			<!--- Country Code --->
			if(trim(document.all.Operator_Country_Code.value) == 0){
				ErrorCount++;
				queueMessage("You must select a country.", document.all.error_Country_Code)
			}
			else {
				clearQueue(document.all.error_Country_Code)

			}

		<!--- State Code --->
			if((trim(document.all.Operator_Country_Code.value) == 'USA' || trim(document.all.Operator_Country_Code.value) == 'CAN')
				&& document.all.Operator_State.value == 0)
			{
				ErrorCount++;
				queueMessage("You must select a state/province.", document.all.error_State_Code)
			}
			else {
				clearQueue(document.all.error_State_Code)
			}
			<!--- locations --->
			if(trim(document.all.Operator_Number_Of_Locations.value).length == 0){
				ErrorCount++;
				queueMessage("You must enter a number of locations for this operator.", document.all.error_Locations)
			}
			else {
				clearQueue(document.all.error_Locations)
			}

			</cfif>

		<!--- D58174 :: Operator Location Type START --->
		<!--- Operator Type --->
			if(document.all.Operator_Type.value == 0)
			{
				ErrorCount++;
				queueMessage("You must select a Operator Type.", document.all.error_Operator_Type)
			}
			else {
				clearQueue(document.all.error_Operator_Type)
			}
		<!--- Operator Location Type --->
			if(document.all.Operator_Location_Type.value == 0)
			{
				ErrorCount++;
				queueMessage("You must select a Operator Location Type.", document.all.error_Operator_Location_Type)
			}
			else {
				clearQueue(document.all.error_Operator_Location_Type)
			}

			<cfif appSettings.getOperatorQBrandLegacy() neq "0">
				if ( document.all.q_brand_legacy.value == "") {
					ErrorCount++;
					queueMessage("Please select a " + <cfoutput>"#application.returned_customer_setting.Q_Brand_Label_Singular#."</cfoutput>, document.all.error_q_brand_legacy)
				}
				else {
					clearQueue(document.all.error_q_brand_legacy)
				}
			</cfif>

			var email = $("input[name=Contact_Email]").val();
			if (email.length && email !== "optional" && !goog.format.EmailAddress.isValidAddress(email)) {
				ErrorCount++;
				queueMessage("Please enter a valid email address.", document.all.error_contact_email);
			}
			else {
				clearQueue(document.all.error_contact_email)
			}

			if(ErrorCount != 0){
				showMessageWindow();
			}
			else {
				saving = 1;
				$("input[placeholder]").each(function() {
					if ( $(this).val() == "" )
						$(this).attr("placeholder", "").val("");  // reset placeholder to avoid sending placeholder to post
				});
				document.all.MyForm.submit();
			}

		}

		function deleteOperator()
		{
			confirm("Are you sure you want to delete this <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>? This <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> will removed from existing programs if you click 'OK'.");
			{
				document.all.DeleteOperator.submit();
			}
		}

		function expandTable(objectID)
		{
			var object = document.getElementById("TB_"+objectID);
			tempVar = eval("document.all.TB_"+objectID);
			var myPIcon = document.getElementById("picon_" + objectID);
			if (object.style.display =='block')
			{
				document.getElementById("picon_" + objectID).innerHTML = "view history";
				object.style.display='none';
				for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = 'none';
				}
			}
			else {
				document.getElementById("picon_" + objectID).innerHTML = "hide history";
				object.style.display='block';
				for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = 'block';
				}
			}
			return;
		}

	</script>
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<SCRIPT SRC="/script/javascript/string_functions.js">
		<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->
	</SCRIPT>
	<!--- var saving = 0
		function resetOpenerOperatorWindowObject(){
			if(saving == 0){
				if(window.opener != null) {
					opener.operatorWindow=null
				}
				window.close();
			}
		} --->
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0"  onblur="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	awayX_Operator_Location_Type
where 0=0
<cfif URL.businessSegementId NEQ "" AND URL.businessSegementId NEQ 0 AND IsNumeric(URL.businessSegementId)>
 and Business_segment_id = #URL.businessSegementId#
</cfif>
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
 <!----------------------------------------------------------------------------
    Dev Notes: D19761 -Anand Rao 07/28/09
    Changed to query to have a where clause to look for active = 1 and
    Deleted = 0
 ------------------------------------------------------------------------------>
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#">
  SELECT	Distinct Operator_Type
  FROM	awayX_Operator_Type
  WHERE Active=1 AND Deleted = 0
<cfif URL.businessSegementId NEQ "" AND URL.businessSegementId NEQ 0 AND IsNumeric(URL.businessSegementId)>
 and Business_segment_id = #URL.businessSegementId#
</cfif>
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id)
</CFQUERY>
<!--- Country code --->
<cfset useLakebaseForgetCountry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_country")>
<cfif useLakebaseForgetCountry>
	<cftry>
		<cfset getCountry = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_country", {
				"order" = "country_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCountry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCountry>
<CFQUERY NAME="getCountry" datasource="#application.datasource#">
	SELECT *
	FROM _Country
	ORDER BY Country_id ASC
</CFQUERY>
</cfif>

<!--- Max Length for legacy ID --->
<cfset useLakebaseForqryMaxLengthOprLegacy = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqryMaxLengthOprLegacy>
	<cftry>
		<cfset qryMaxLengthOprLegacy = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "max_operator_id_length"
			}), "max_operator_id_length"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryMaxLengthOprLegacy = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryMaxLengthOprLegacy>
<CFQUERY NAME="qryMaxLengthOprLegacy" datasource="#application.datasource#">
SELECT Max_Operator_ID_Length
FROM	_Users_Settings
Where	User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>
</cfif>

<style>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
select, TEXTAREA
	{
		width:	200px;
		font-size: 10px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
div#header {
	margin-top: 6px;
}
form {
	margin: 0;
	padding: 0;
}
blockquote { margin:0; padding:0px 5px 5px 5px; }
.contact { font-weight: bold; font-size: 1.1em; color:blue; }
#track48 { margin: 4px 0; font-size: 0.9em; padding: 0;}
#symbol27 { margin: 0; font-size: 0.8em; padding: 0;}
#actions37 { margin: 5px; }
#actions37 a { margin-right: 15px; }
</STYLE>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/wholeNumberValidation.js"></SCRIPT>
<cfoutput>
<blockquote>
  <!--- <p>&nbsp;</p> --->
<div id="header">
<cfif Action IS "Edit"><SPAN CLASS="title2">Change This #application.util.string.fCase(application.returned_customer_setting.operator_label_singular)#'s Information</Span>
<cfset useLakebaseForCreatorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForCreatorName>
	<cftry>
		<cfset CreatorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Added_By#",
				"limit" = "1",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCreatorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreatorName>
<cfquery name="CreatorName" datasource="#application.datasource#">
SELECT TOP 1 Name_First, Name_Last FROM _Users WHERE User_ID = '#Added_By#'
</cfquery>
</cfif>
<div id="track48">
	Added <cfif creatorName.recordCount>by #CreatorName.Name_First# #CreatorName.Name_Last#</cfif> on #application.util.datetime.DateTimeFormat(User_Added_Date)#
	<cfset useLakebaseForEditorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForEditorName>
	<cftry>
		<cfset EditorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Edited_By#",
				"limit" = "1",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForEditorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEditorName>
<cfquery name="EditorName" datasource="#application.datasource#">
		SELECT TOP 1 Name_First, Name_Last FROM _Users WHERE User_ID = '#Edited_By#'
	</cfquery>
</cfif>
	<cfif EditorName.Recordcount GT 0>
		<Br>Last edited by #EditorName.Name_First# #EditorName.Name_Last# on #application.util.datetime.DateTimeFormat(User_Date_Edited)#
	</cfif>
</div>
<cfelse><SPAN CLASS="title2">Create A New #application.util.string.fCase(application.returned_customer_setting.operator_label_singular)#</Span></cfif>
</div>
<HR COLOR="Orange">

<FORM ACTION="Operator_Creation_Entry_Action_Stripped.cfm" METHOD="POST" TARGET="_self" NAME="MyForm" ID="MyForm">
<div id="symbol27">( * = read-only )</div>
<INPUT TYPE="hidden" NAME="deleted" VALUE="0">
<input type="hidden" name="FinalItemList" value="#FinalItemList#">

<!--- do not allow full editing when:
				  a. operator has legacy id
				  b. operator is not manually added
 --->
<cfset variables.limitedEditing = "">
	<!---  62724 :: Edit option for Operators
Commented this code so that user can edit operator name which are created through upload process.
<cfif Action eq "Edit">
	<cfif SelectOperatorInfo.USER_ADDED neq '1' and len(SelectOperatorInfo.Legacy_ID)>
		<cfset variables.limitedEditing = "readonly class='readonly'">
	</cfif>
</cfif>
--->
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="2">

    <TR>
    <TD valign="top" ALIGN="right" nowrap><span ID="error_Name"></span>&nbsp;<B>#application.returned_customer_setting.operator_label_singular# Name</B><cfif len(variables.limitedEditing)>*</cfif></TD>
    <TD>
		<input type="text" NAME="Operator_Name" #variables.limitedEditing# MAXLENGTH="255" STYLE="width:400px;" value="#Operator_Name#">
		<!--- <CFINPUT TYPE="Text" NAME="Operator_Name" MESSAGE="You must enter the name of the Operator..." REQUIRED="Yes" MAXLENGTH="510" STYLE="width:400px;"> --->
	</TD>
	</TR>

	<cfif appSettings.getOperatorQBrandLegacy() neq "0">
		<cfset useLakebaseForvariables_qBrand = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("q_brand_desc")>
<cfif useLakebaseForvariables_qBrand>
	<cftry>
		<cfset variables.qBrand = application.oLakebase.toQuery(
			application.oLakebase.selectRows("q_brand_desc", {
				"deleted" = "eq.0",
				"order" = "q_brand.asc",
				"select" = "q_brand,q_brand_legacy"
			}), "q_brand,q_brand_legacy"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qBrand = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qBrand>
<cfquery name="variables.qBrand" datasource="#application.datasource#">
			 SELECT Q_Brand, Q_Brand_Legacy
		  	  FROM Q_BRAND_DESC
		     WHERE Deleted = 0
		     ORDER BY q_Brand
		</cfquery>
</cfif>
		<tr>
		   	<TD valign="top" ALIGN="right" nowrap><span ID="error_q_brand_legacy"></span>&nbsp;<B>#application.returned_customer_setting.Q_Brand_Label_Singular#</B></TD>
    	   	<TD>
    	   		<select name="q_brand_legacy">
							<option <cfif variables.Q_Brand_Legacy eq "">selected</cfif> value="">Select #application.returned_customer_setting.Q_Brand_Label_Singular#</option>
							<!--- IP wants to display NONE first --->
							<cfquery name="variables.qBrandNone" dbtype="query">
								 SELECT *
							  	  FROM variables.qBrand
							     WHERE Q_Brand = 'NONE'
							</cfquery>
							<cfif variables.qBrandNone.recordCount>
								<option <cfif (compare(variables.Q_Brand_Legacy, variables.qBrandNone.Q_Brand_Legacy) eq 0)>selected=selected</cfif> value="#variables.qBrandNone.Q_Brand_Legacy#">#variables.qBrandNone.Q_Brand#</option>
							</cfif>

    	   			<cfloop query="variables.qBrand">
    	   				<!--- NONE was displayed earlier skip it --->
    	   				<cfif variables.qBrand.Q_Brand neq 'NONE'>
									<option <cfif (compare(variables.Q_Brand_Legacy, variables.qBrand.Q_Brand_Legacy) eq 0)>selected=selected</cfif> value="#variables.qBrand.Q_Brand_Legacy#">#variables.qBrand.Q_Brand#</option>
								</cfif>
							</cfloop>
    	   		</select>
			</TD>
		</tr>
	</cfif>

	<!--- If the client uses BSA Operator ID, then display that ID --->
		<cfif application.returned_customer_setting.operator_legacy_id_on eq 0>
			<cfif Action IS "Edit">
		<TR>
	    <TD valign="top" ALIGN="right"><b>#CustomerSettingsLabels.BSA_ID_label#</b>&nbsp;</TD>
	    <TD valign="top">#BSA_Operator_Id#</TD>
		</TR>
			</cfif>
		<!--- If the client uses Legacy ID instead of BSA_Operator_ID, let the user add/edit that ID (Milan - 8961)--->
		<cfelse>
		<TR>
			<TD valign="top" align="right"><span ID="error_Legacy_ID"></span>&nbsp;<strong>#application.returned_customer_setting.Operator_Legacy_Id_label#</strong><cfif len(variables.limitedEditing)>*</cfif></TD>
			<TD valign="top"><input type="text" name="Legacy_ID" #variables.limitedEditing# maxlength="#qryMaxLengthOprLegacy.Max_Operator_ID_Length#" SIZE="#qryMaxLengthOprLegacy.Max_Operator_ID_Length#" value="#Legacy_ID#"></TD>
		</TR>
		</cfif>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
	<cfif OperatorSegEnable>
		<TR>
			<TD valign="top" ALIGN="right" nowrap><span ID="error_Business_Segment"></span>&nbsp;<B> #appSettings.getbusiness_segment_label()#</B></TD>
			<TD valign="top">
				<SELECT NAME="Business_Segment" STYLE="width:123px;">
					<OPTION VALUE="0">please select</OPTION>
					<CFLOOP QUERY="businessSegManagerList"><OPTION VALUE="#Business_Segment_ID#" <cfif Segment EQ Business_Segment_ID>SELECTED</cfif>>#Business_Unit_Desc#</OPTION></CFLOOP>
				</SELECT>
			</TD>
		</TR>
	</cfif>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->
    <TR>
    <TD valign="top" ALIGN="right" nowrap><span ID="error_Address"></span>&nbsp;<B>Address</B></TD>
    <TD>
		<input type="text"  NAME="Operator_Address" MAXLENGTH="255" STYLE="width:400px;" value="#Operator_Address#">
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right" nowrap><span ID="error_City"></span>&nbsp;<span ID="error_Zip"></span>&nbsp;<span ID="error_State_Code"></span>&nbsp;<B> City</B></TD>
    <TD>

		<input type="text"  NAME="Operator_City" MAXLENGTH="255" value="#Operator_City#">
		<!--- <CFINPUT TYPE="Text" NAME="Operator_City" MESSAGE="You must enter the city..." REQUIRED="Yes" MAXLENGTH="510"> --->
		<b>State</b>
		<SELECT NAME="Operator_State" STYLE="width:123px;">
		<OPTION VALUE="0">please select</OPTION>
		<CFLOOP QUERY="Get_States"><OPTION VALUE="#State_Code#"<cfif Operator_State IS State_Code OR Operator_State IS State_Name>selected</cfif>>#State_Name#</OPTION></CFLOOP>
		</SELECT>
		<b>Postal Code</b>
		<input type="text"  NAME="Operator_Zip"  STYLE="width:70px;" MAXLENGTH="10" value="#Operator_Zip#"> <!--- ONKEYUP="clenseText(this, '0123456789')" --->
		<!--- <CFINPUT TYPE="Text" NAME="Operator_Zip" MESSAGE="You must enter the Zip code..." REQUIRED="Yes" MAXLENGTH="510" STYLE="width:70px;"> --->

	</TD>
	</TR>

	<TR>
		<TD VALIGN="top" ALIGN="right" nowrap><span ID="error_Country_Code"></span><B>Country</B></TD>
		<TD VALIGN="top">
			<CFOUTPUT>
				<SELECT NAME="Operator_Country_Code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getCountry"><OPTION VALUE="#getCountry.Country_Code#" <CFIF Operator_Country_Code EQ getCountry.Country_Code> SELECTED</CFIF>>#getCountry.Country_Name#</OPTION></CFLOOP></SELECT>&nbsp;
			</CFOUTPUT>
		</TD>
	</TR>

	<TR><TD valign="top" align="right"><b>Phone</b></TD>
	<td>	<input type="text" name="Operator_Phone" maxlength="14" size="14" ONKEYUP="clenseText(this, '0123456789()-')" value="#Operator_Phone#">	</TD></TR>

    <TR>
    <TD valign="top" ALIGN="right" nowrap><span ID="error_Locations"></span>&nbsp;<B> Number of Locations </B></TD>
    <TD>
		<INPUT NAME="Operator_Number_Of_Locations" TYPE="text" ONKEYUP="clenseText(this, '0123456789')" value="#Replace(Operator_Number_Of_Locations,'-','','ALL')#" MAXLENGTH="8">
		<!--- <CFINPUT TYPE="Text" NAME="Operator_Number_Of_Locations" MESSAGE="You must enter the number of locations..." VALIDATE="integer" REQUIRED="Yes" MAXLENGTH="8"> --->
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><span ID="error_Operator_Type"></span><span ID="error_Operator_Location_Type"></span><B> Type & Location </B></TD>
    <TD>
		<SELECT NAME="Operator_Type">
			<option value="0"> Select Operator Type </option>
		<CFLOOP QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#" <cfif Operator_Type IS trim(OperatorType)>Selected</cfif>>#Operator_Type#</OPTION></CFLOOP>
		</SELECT>
		<SELECT NAME="Operator_Location_Type">
			<option value="0"> Select Operator Location Type </option>
		<CFLOOP QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#" <cfif Operator_Location_Type IS OperatorLocationType>Selected</cfif> >#Operator_Location_Type#</OPTION></CFLOOP>
		</SELECT>
	</TD>
	</TR>

    <TR>
    <TD valign="top" ALIGN="right"><B>Doing business as...</B></TD>
    <TD>
		<TEXTAREA COLS="48" ROWS="3" maxlenth="500" NAME="Operator_DBA" onPaste="javaScript: return textareaChecklength('510', this);"  onkeyPress="javaScript: return textareaChecklength('510', this);">#Operator_DBA#</TEXTAREA>
	</TD>
	</TR>



<TR>
				<TD align="right"><B>Activation Status</B></TD>
        <TD>Active <input type="radio" name="Display_Code" value="A" <cfif Deleted eq 0 AND Display_Code eq 'A' OR (Display_Code eq '' AND appSettings.getCreated_Operators_Default_Active() EQ 1 )>checked</cfif>>
				InActive <input type="radio" name="Display_Code" value="N" <cfif  (Deleted eq 1	AND Display_Code eq 'A') OR (Display_Code eq '' AND appSettings.getCreated_Operators_Default_Active() EQ 0 )>checked</cfif>>
				</TD>
</TR>
<TR>
	 <TD valign="top" ALIGN="right"><B>Notes</B><br>
		<cfif action IS "Edit">
		<cfquery name="GetNotes" datasource="#application.datasource#">
				SELECT TOP 3 BSA_Operator_History_ID,Notes,Name_First,Name_Last,user_Date_edited
				FROM BSA_Operator_History
				inner join _Users on BSA_Operator_History.edited_by = _Users.User_ID
				and BSA_Operator_ID = '#BSA_Operator_ID#'
				and EditNotes =1
				ORDER BY user_Date_edited DESC
		</cfquery>
			<cfif GetNotes.recordcount GT 0>
				<font color="red">[</font>
				<font size=1><a id="NotesDetail" href="javascript:expandTable('NotesDetail');"><span id="picon_NotesDetail">view history </span></a>
				</font><font color="red">]</font>
			</cfif>
		</cfif>
	</TD>
    	<TD>
		<TEXTAREA COLS="48" ROWS="3" maxlenth="250" NAME="Notes" onPaste="javaScript: return textareaChecklength('250', this);"  onkeyPress="javaScript: return textareaChecklength('250', this);">#Notes#</TEXTAREA>
		<cfif action IS "Edit"><br>

			<cfif GetNotes.recordcount GT 0>

				<FIELDSET width="200" STYLE="padding:4px; width:240px; border: 1px solid Blue;display:none" id="TB_NotesDetail">
				<table  width="400" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE" >
					<tr><td align="center" NOWRAP>Created Date</td><td align="center" NOWRAP>Created By</td><td align="center">Note</td>
					<cfloop query="GetNotes">
						<tr>
						<td>#dateformat(GetNotes.user_Date_edited, 'mm/dd/yy')# #timeFormat(GetNotes.user_Date_edited, "hh:mm")#</td><td>#GetNotes.Name_First# #GetNotes.Name_Last#</td><td>#GetNotes.Notes#&nbsp;</td>
						</tr>
					</cfloop>
				</table>
				</FIELDSET>

			</cfif>
		</cfif>
	</TD>
</TR>

<!-------------------------------------------------------------------------------------------------------------------------------------->
<!--- C O N T A C T    P E R S O N ----------------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------------------------------------------->
<tr style="height:22px;">
	<td colspan="2"><hr></td>
</tr>
<tr>
	<td valign="top" align="center" class="contact">Contact Person</td>
	<td>
		<table border="0" cellspacing="0" cellpadding="2" width="100%">
			<tr>
				<td width="33%">
					<b>First Name</b><BR>
					<input type="text" placeholder="optional" name="Operator_First_Name" ID="Operator_First_Name" value="#Operator_First_Name#">
				</td>
				<td width="33%">
					<b>Last Name</b><BR>
					<input type="text" placeholder="optional" name="Operator_Last_Name" ID="Operator_Last_Name" value="#Operator_Last_Name#">
				</td>
				<td width="33%">
					<b>Title</b><BR>
					<input type="text" placeholder="optional" name="Operator_Title" ID="Operator_Title" value="#Operator_Title#" style="width:125;">
				</td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td valign="top" align="right" nowrap><B>Address</B></TD>
	<td>
		<input type="text" placeholder="optional" name="Contact_Address" maxlength="255" style="width:98%;" value="#variables.Contact_Address#">
	</td>
</tr>
<tr>
	<td valign="top" align="right" nowrap><B>City</B></TD>
	<td>
		<input type="text" placeholder="optional" name="Contact_City" MAXLENGTH="255" value="#variables.Contact_City#">
		<b>State</b>
		<select name="Contact_State" style="width:123px;">
			<option value="0">please select</option>
			<cfloop query="Get_States"><option value="#Get_States.State_Code#"<cfif variables.Contact_State IS Get_States.State_Code>selected</cfif>>#Get_States.State_Name#</option></cfloop>
		</select>
		<b>Postal Code</b>
		<input type="text" placeholder="optional" name="Contact_Zip"  STYLE="width:70px;" MAXLENGTH="10" value="#variables.contact_zip#">
	</td>
</tr>
<tr>
	<td align="right"><b>Phone</b></TD>
	<td>
		<input type="text" placeholder="optional" name="zzz_Operator_Phone" maxlength="14" size="14" ONKEYUP="clenseText(this, '0123456789()-')" value="#zzz_Operator_Phone#">
	</td>
</tr>
<tr>
	<td align="right"><span ID="error_contact_email"></span>&nbsp;<b>Email</b></TD>
	<td>
		<input type="text" placeholder="optional" name="Contact_Email" maxlength="255" style="width:98%" value="#variables.Contact_Email#">
	</td>
</tr>
</table>

<input type="hidden" name="Source" value="#Source#">
<cfset Revision_Settings_Allowed = 0>
<cfif URL.CID neq "">
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
	<cfset programInfo = programManager.getProgramInfo(cryp.value)>

	<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />

	<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = programInfo.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = cryp.value)>
	<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(cryp.value)>

	<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number eq 1)>
		<cfset Revision_Settings_Allowed = 1>
	</cfif>

<cfelse>
<!--- This is to avoid the errors as these values are used later (RevisionStatus and RevisionSettings are query objects) --->
	<cfset RevisionStatus.Is_A_Revision ="">
	<cfset RevisionSettings.Operators_Removed = "">
</cfif>

<INPUT TYPE="hidden" name="Action" value="#Action#">
<cfif action IS "Edit">
<input type="hidden" name="BSA_Operator_ID" value="#BSA_Operator_ID#">

</cfif>

<div id="actions37">
	<a href="##" onclick="javascript:return verifyData();">#application.util.string.actionLinkFormat2("save")#</a>
	<cfif Action IS "Edit">
		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Removed eq 2>
		<cfelse>
			<a href="##" onclick="javascript:return deleteOperator();">#application.util.string.actionLinkFormat2("permanently delete this operator")#</a>
		</cfif>
	</cfif>
</div>
</FORM>
<cf_messagewindow></blockquote>

<cfif Action IS "Edit">
	<form name="DeleteOperator" action="/profiles/operators/delete_operator.cfm" method="Post">
		<input type="hidden" name="BSA_Operator_ID" value="#BSA_Operator_ID#">
	</form>
</cfif>

<cfinclude template="/common_files/jQuery.cfm">
<script src="/script/javascript/jquery.placeholder.min.js"></script>
<script src="/script/javascript/google/base.min.js"></script>
<script src="/script/javascript/google/string.min.js"></script>
<script src="/script/javascript/google/emailaddress.min.js"></script>

<script>
	$("input[placeholder]").placeholder();
</script>
</BODY>
</HTML>
</cfoutput>
