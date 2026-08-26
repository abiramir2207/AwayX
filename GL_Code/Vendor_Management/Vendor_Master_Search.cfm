<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Vendor Master Search</title>
</head>

<body>
<CFSET thisPage = CGI.SCRIPT_NAME>

<CFPARAM NAME="URL.FieldName" DEFAULT="Vendor_ID" />
<CFPARAM NAME="URL.Business_Segment_Id" DEFAULT = "0">
<CFPARAM NAME="URL.QuickPay" default="0">
<CFPARAM NAME ="URL.Settlements" default="0">
<CFPARAM NAME ="URL.srcCaller" default="0">
<CFPARAM NAME ="URL.busSegID" default="0">

<!--- Dev Note: - Call from the Flex App --->
<cfparam name="FORM.FlexAppName" default="ContractMain">
<cfif isDefined("URL.FlexAppName")>
	<cfset temp = structInsert(FORM,"FlexAppName",#URL.FlexAppName#,true) />
</cfif>

<cfparam name="FORM.vendorSearchType" default="1">
<cfif isDefined("URL.vendorSearchType")>
	<cfset temp = structInsert(FORM,"vendorSearchType",#URL.vendorSearchType#,true) />
</cfif>

<!--26298 2011/02/28-->
<cfscript>
if (not StructKeyExists(URL, "DescFieldName")) {
  if (StructKeyExists(Form, "DescFieldNameVariable")) {
    URL.DescFieldName = Form.DescFieldNameVariable;
  }
  else {
    URL.DescFieldName = "paidToName";
  }
}
</cfscript>


<CFPARAM NAME="FORM.AlreadySelectedItems" 	DEFAULT="" />
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="" />
<CFPARAM NAME="URL.SelectedVendor_ID" 	DEFAULT="#FORM.FinalItemList#" />
<CFPARAM NAME="FORM.SelectedVendor_ID" 	DEFAULT="#URL.SelectedVendor_ID#" />
<CFPARAM NAME="FORM.Business_Segment_Id" 	DEFAULT="#URL.Business_Segment_Id#" />
<CFPARAM NAME="Form.Vendor_Name_Desc" 	DEFAULT="" />
<CFPARAM NAME="FORM.Go" DEFAULT= 0 />
<CFPARAM NAME="ReloadForm" default="1">
<CFPARAM NAME="PageSource" default="">
<CFPARAM NAME="FORM.QuickPay" default="#url.QuickPay#">
<CFPARAM NAME ="FORM.Settlements" default="#url.Settlements#">


<CFPARAM NAME="FORM.FinisedSearching" DEFAULT="0">
<CFPARAM NAME="FORM.FinalItemList" DEFAULT="" />
<!--- 96461	HF Bundle - Payment Recipient Screen/Anand Rao/18-Nov-2020 --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFPARAM NAME="URL.programId" 	DEFAULT="" />
<CFPARAM NAME="FORM.programId" 	DEFAULT="" />
<cfif URL.programID NEQ "">
	<cfset FORM.programId = "#URL.programID#" />
</cfif>

<CFPARAM NAME="URL.lsBusinessSegmentID" 	DEFAULT="" />
<CFPARAM NAME="FORM.lsBusinessSegmentID" 	DEFAULT="" />
<cfif URL.Business_segment_ID NEQ 0 AND URL.lsBusinessSegmentID EQ "">
	<cfset URL.lsBusinessSegmentID = URL.Business_segment_ID />
</cfif>
<cfif URL.lsBusinessSegmentID NEQ "">
	<cfset FORM.lsBusinessSegmentID = "#URL.lsBusinessSegmentID#" />
</cfif>
<cfif FORM.lsBusinessSegmentID EQ "UNDEFINED">
	<cfset FORM.lsBusinessSegmentID = "" />
</cfif>

<!--26298-->
<cfif StructKeyExists(Form, "DescField")>
  <cfset variables.DescField = Form.DescField>
<cfelse>
  <cfset tmpString = 'Form.Vendor_Name_Desc_' & '#Replace(FORM.SelectedVendor_ID,"-","_","ALL")#' />
  <CFPARAM NAME="#tmpString#" DEFAULT="" />
  <cfset variables.DescField = ( structKeyExists(form, tmpString) ? form[ tmpString ] : "" )/>
</cfif>

<CFMODULE TEMPLATE="/search_screens/Popup_Search.cfm"
			FirstFormNameVariable="URL.FormName"
			FirstFieldNameVariable="URL.FieldName"
			ActionPage="#thisPage#"
			AlreadySelectedItems="#FORM.AlreadySelectedItems#"
			id="#FORM.SelectedVendor_ID#"
			FinalItemList="#FORM.FinalItemList#"
			ReturnFinalItemListVariable="FORM.FinalItemList"
			FinisedSearching="#FORM.FinisedSearching#"
			LastFormNameVariable="FORM.Formname"
			LastFieldNameVariable="FORM.FieldName"
			DescFieldNameVariable="#URL.DescFieldName#"
			DescField="#variables.DescField#"
			importType="single"
			ReloadForm="#ReloadForm#"
			PageSource="#PageSource#"
			FlexAppName="#FORM.FlexAppName#"
			vendorSearchType = "#FORM.vendorSearchType#"
			Business_Segment_Id = "#FORM.Business_Segment_Id#"
			QuickPay = "#FORM.QuickPay#"
			Settlements = "#FORM.Settlements#"
			ProgramID = "#FORM.ProgramID#"
			lsBusinessSegmentID = "#URL.lsBusinessSegmentID#"
>

<STYLE>
TABLE.Underlinedtable TD
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>

<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="Vendor_ID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">

<CFPARAM NAME="FORM.Vendor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_Name_Desc" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_ID" DEFAULT="">
<CFPARAM NAME="FORM.Vendor_City" DEFAULT="">
<CFPARAM NAME="FORM.State" DEFAULT="">
<CFPARAM NAME="FORM.Country_Code" DEFAULT="">
<CFPARAM NAME="FORM.SelectedVendor_ID" DEFAULT="#Form.FinalItemList#">
<CFPARAM NAME="FORM.FinalVendor" DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" DEFAULT="">

<CFIF FORM.SelectedVendor_ID NEQ "" OR FORM.FinalItemList NEQ "">
	<CFSET FORM.FinalVendor = FORM.SelectedVendor_ID>
	<CFSET FORM.FinalItemList = FORM.SelectedVendor_ID>
</CFIF>

<cfset segmentEnabledForVendorType = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").isEnabledForVendorType() />

 <cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
 <cfquery datasource="#application.datasource#" name="getUsrBusSeg">
	SELECT UBS.Business_Segment_ID FROM User_Business_Segment UBS WHERE UBS.User_ID =  '#request.accessStructure.User_Id#' AND UBS.deleted = 0
 </cfquery>

 <cfset lsUsrBusSeg =  ValueList(getUsrBusSeg.Business_Segment_ID) />

 <cfset busSegOn = 0 />
 <cfif (businessSegManager.isEnabled())>
	  <cfset busSegOn = 1 />
</cfif>


 <cfif (businessSegManager.isEnabledForOperator())>
	<cfset Operator_Segment_On = 1>
	 <cfset BusSegBBsOpr = ValueList(getUsrBusSeg.Business_Segment_ID) />
	 <cfset lsUsrBusSeg = BusSegBBsOpr />
  <cfelse>
    <cfset Operator_Segment_On = 0 />
	<cfset BusSegBBsOpr = 0 />
  </cfif>

 <cfif (businessSegManager.isEnabledForDistributor())>
	<cfset Distributor_Segment_On = 1>
	 <cfset BusSegBBsDist = ValueList(getUsrBusSeg.Business_Segment_ID) />
 	 <cfset lsUsrBusSeg = BusSegBBsDist />
  <cfelse>
    <cfset Distributor_Segment_On = 0 />
	<cfset BusSegBBsDist = 0 />
  </cfif>

<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor />

<cfif (busSegOn AND ((FORM.Business_Segment_Id NEQ "" AND FORM.Business_Segment_Id NEQ 0) OR (segmentEnabledForVendorType NEQ 0 AND FORM.lsBusinessSegmentID NEQ "")))>
	<!--- The below query will apply only for the above condition --->
	<cfquery name="GetVMVendorIDInfo" datasource="#Application.Datasource#">
		SELECT
					<cfif FORM.vendorSearchType EQ 2>
					DISTINCT
					</cfif>
					RTRIM(Vendor_Master.Vendor_ID) as Vendor_ID,
					Vendor_Name as vendorName,
					Vendor_Master.Address_1 as vendorAddress1,
					Vendor_Master.Address_2 as vendorAddress2,
					Vendor_Master.City as vendorCity,
					Vendor_Master.State as vendorState,
					Vendor_Master.Zipcode as vendorZipCode,
					Vendor_Master.Business_Segment_ID,
					BS.Business_Unit_Desc
		FROM 		Vendor_Master
					<cfif FORM.vendorSearchType EQ 2>
						INNER JOIN Vendor_Dist_Oper VD ON VD.Vendor_ID = Vendor_Master.Vendor_ID
					</cfif>
					<cfif (segmentEnabledForVendorType NEQ 0)>
					INNER JOIN Vendor_Segment_Xref VMXREF
						ON Vendor_Master.Vendor_id = VMXREF.vendor_id
						AND Vendor_Master.Deleted = 0
						AND Vendor_Master.Active_Code = 'A'
						AND VMXREF.Deleted = 0
						INNER JOIN Business_Segment BS
						ON BS.Business_Segment_ID = VMXREF.Business_Segment_ID
					<cfelse>
						LEFT JOIN Business_Segment BS ON BS.Business_Segment_ID = Vendor_Master.Business_Segment_ID
					</cfif>
		WHERE 		
					Vendor_Master.Deleted = 0 AND
					<CFIF FORM.Vendor_ID NEQ "">
						Vendor_Master.Vendor_ID LIKE '%#FORM.Vendor_ID#%' AND
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
					<cfif (appSettings.get_setting('Margin_Display_Style') EQ "custom_t")>
						Vendor_Master.Vendor_Type != 'VEND' AND
					</cfif>
					<cfif FORM.lsBusinessSegmentID NEQ "" AND segmentEnabledForVendorType NEQ 0>
						VMXREF.Business_Segment_ID IN (#FORM.lsBusinessSegmentID#) AND
					</cfif>	 
					1=1
		ORDER BY 	#FORM.SORT_BY# #FORM.SORT_ORDER#
	</cfquery>
<cfelse>		
	<!--- Original vendor master search --->		
	<CFQUERY NAME="GetVMVendorIDInfo" DATASOURCE="#Application.Datasource#">
		SELECT
					<cfif FORM.vendorSearchType EQ 2>
					DISTINCT
					</cfif>
					RTRIM(Vendor_Master.Vendor_ID) as Vendor_ID,
					Vendor_Name as vendorName,
					Vendor_Master.Address_1 as vendorAddress1,
					Vendor_Master.Address_2 as vendorAddress2,
					Vendor_Master.City as vendorCity,
					Vendor_Master.State as vendorState,
					Vendor_Master.Zipcode as vendorZipCode,
					Vendor_Master.Business_Segment_ID,
					BS.Business_Unit_Desc
		FROM 		Vendor_Master
					<cfif FORM.vendorSearchType EQ 2>
						INNER JOIN Vendor_Dist_Oper VD ON VD.Vendor_ID = Vendor_Master.Vendor_ID
					</cfif>
					LEFT JOIN Business_Segment BS ON BS.Business_Segment_ID = Vendor_Master.Business_Segment_ID
		WHERE 		<!--- Dev Notes: 11084 Ana Commenting this line---- Vendor_ID NOT IN (SELECT Vendor_ID FROM Vendor_Dist_Oper WHERE Deleted = 0 AND Vendor_ID IS NOT NULL) AND --->
					<CFIF FORM.Vendor_ID EQ "" AND FORM.Vendor_Name EQ "" AND  FORM.Vendor_City EQ "" AND  FORM.State EQ "" AND Form.Go EQ 0>
						1 = 2 AND
					</CFIF>
					<CFIF FORM.Vendor_ID NEQ "">
						Vendor_Master.Vendor_ID LIKE '%#FORM.Vendor_ID#%' AND
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
					
					<!--- START: 96461: HF Bundle - Payment Recipient Screen/Anand Rao/18-Nov-2020 --->
					<!--- The below setting is supposed to be on for tyson --->
					<cfif (appSettings.get_setting('Margin_Display_Style') EQ "custom_t")>
						Vendor_Master.Vendor_Type != 'VEND' AND
					</cfif>
					<!--- 108970 - Vendor changes for Segment / Anand Rao / 30-Nov-2021 --->
				<cfif busSegOn>
					<CFIF FORM.Business_Segment_Id NEQ "" AND FORM.Business_Segment_Id NEQ 0>
						<CFIF segmentEnabledForVendorType EQ 1><!--- Enable - One vendor has single segment --->
						Vendor_Master.Business_Segment_ID = '#FORM.Business_Segment_Id#' AND
						<CFELSEIF segmentEnabledForVendorType EQ 2><!--- Enable - One vendor has multiple segment --->
						EXISTS
						(
							SELECT	1
							FROM	Vendor_Segment_Xref
							WHERE	Vendor_Segment_Xref.Vendor_ID = Vendor_Master.Vendor_ID
							AND		Vendor_Segment_Xref.Business_Segment_ID = '#FORM.Business_Segment_Id#'
							AND		Vendor_Segment_Xref.Deleted = 0
						) AND
						</CFIF>
					</CFIF>
					<!--- <cfif  ((Operator_Segment_On EQ "0") AND (Distributor_Segment_On EQ "0"))>
						Vendor_Master.Business_Segment_ID IN (#lsUsrBusSeg#) AND
					</cfif> --->
					<cfif  ((Distributor_Segment_On EQ "1" AND FORM.lsBusinessSegmentID NEQ "") OR (Operator_Segment_On EQ "1" AND FORM.lsBusinessSegmentID NEQ ""))>
						Vendor_Master.Business_Segment_ID IN (#FORM.lsBusinessSegmentID#) AND
					<cfelse>	
						<cfif (Distributor_Segment_On EQ "1" AND FORM.lsBusinessSegmentID EQ "")>
							Vendor_Master.Business_Segment_ID IN (#lsUsrBusSeg#) AND
						</cfif>
						<cfif (Operator_Segment_On EQ "1" AND FORM.lsBusinessSegmentID EQ "")>
							Vendor_Master.Business_Segment_ID IN (#lsUsrBusSeg#) AND
						</cfif>
					</cfif>
				</cfif>
					Vendor_Master.Deleted = 0 AND
					Vendor_Master.Active_Code = 'A'
	
		ORDER BY 	#FORM.SORT_BY# #FORM.SORT_ORDER#
	</CFQUERY>
</cfif>
	
<!--- END: 96461: HF Bundle - Payment Recipient Screen/Anand Rao/18-Nov-2020 --->

<FORM NAME="VMSearchForm" ACTION="Vendor_Master_Search.cfm" METHOD="POST">
<CFOUTPUT>
<INPUT TYPE="hidden" VALUE = "#EncodeForHTMLAttribute(FORM.SORT_BY)#" NAME="SORT_BY">
<INPUT TYPE="hidden" VALUE = "#EncodeForHTMLAttribute(FORM.SORT_ORDER)#" NAME="SORT_ORDER">
<cfparam name="FORM.startrow"  default="1">
<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
<cfparam name="FORM.pageLength"  default=100>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">

<INPUT TYPE="hidden" VALUE = "#EncodeForHTMLAttribute(FORM.frompage)#" NAME="frompage">
<INPUT TYPE="hidden" VALUE = "#EncodeForHTMLAttribute(FORM.StartRow)#" NAME="startrow">
<INPUT TYPE="Hidden" NAME="FinalVendor" VALUE="#EncodeForHTMLAttribute(FORM.FinalVendor)#">
<INPUT TYPE="Hidden" NAME="finishedselectingitems" VALUE="#EncodeForHTMLAttribute(FORM.finishedselectingitems)#">
<INPUT TYPE="Hidden" NAME="lsBusinessSegmentID" value="#EncodeForHTMLAttribute(FORM.lsBusinessSegmentID)#">
</CFOUTPUT>
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">vendor master search</LEGEND>
 	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" >
		<TR>
			<TD COLSPAN="100%">
				<CFOUTPUT><B>#variables.VendorLabel# Name</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_Name" VALUE="#FORM.Vendor_Name#" SIZE="115">
				</CFOUTPUT>
			</TD>
		</TR>
		<TR>
			<TD>
				<CFOUTPUT><B>#variables.VendorLabel# Number</B><BR>
				<INPUT TYPE="Text" NAME="Vendor_ID" VALUE="#FORM.Vendor_ID#">
				</CFOUTPUT>
			</TD>
			<TD>
				<CFQUERY NAME="getVendorCity" DATASOURCE="#Application.Datasource#">
					SELECT DISTINCT City FROM Vendor_Master WHERE LEN(City) > 0	ORDER BY City
				</CFQUERY>
				<B><CFOUTPUT>#variables.VendorLabel#</CFOUTPUT> City</B><BR>
				<SELECT NAME="Vendor_City" ID="Vendor_City" STYLE="WIDTH:115px">
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
				<B><CFOUTPUT>#variables.VendorLabel#</CFOUTPUT> State</B><BR>
				<SELECT NAME="State" ID="State" STYLE="WIDTH:115px">
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

				<CFOUTPUT>
				<B>#variables.VendorLabel# Country</B><BR>
					<SELECT NAME="Country_Code" ID="Country_Code" STYLE="WIDTH:115px" disabled>
					  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
					    <CFLOOP QUERY="getCountry">
							<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.country_code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
						</CFLOOP>
				     </SELECT>
				</CFOUTPUT>
			</TD>

		</TR>

		<TR>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD COLSPAN="2" ALIGN="Right"><BR>
				<B>
				<FONT COLOR="Red" SIZE="2">[ </FONT>
				<A HREF="" ONCLICK="javascript: resetForm(); return false;">reset</A>
				<FONT COLOR="Red" SIZE="2"> ]</FONT>
				</B>
				&nbsp;&nbsp;
				<B>
				<FONT COLOR="Red" SIZE="2">[ </FONT>
				<A HREF="" ONCLICK="javascript: validate(); return false;">search <CFOUTPUT>#variables.VendorLabel#</CFOUTPUT></A>
				<FONT COLOR="Red" SIZE="2"> ]</FONT>
				</B>
			</TD>
		</TR>

	</TABLE>
	</FIELDSET>

	<BR><BR>
	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There Are <CFOUTPUT>#GetVMVendorIDInfo.RecordCount#</CFOUTPUT> Vendors That Match The Above Criteria</LEGEND>

<cfif  (busSegOn EQ "1")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings        = genSettingsManager.get()>
	<CFSET A_Header_Value_List = "Vendor_ID,vendorName,vendorAddress1,Business_Unit_Desc">
	<CFSET A_Header_Name_List = "#variables.VendorLabel# ID,#variables.VendorLabel# Name,#variables.VendorLabel# Address,#appSettings.getbusiness_segment_label()#">
<cfelse>
	<CFSET A_Header_Value_List = "Vendor_ID,vendorName,vendorAddress1">
	<CFSET A_Header_Name_List = "#variables.VendorLabel# ID,#variables.VendorLabel# Name,#variables.VendorLabel# Address">
</cfif>

	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="Underlinedtable">
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

				<TD ID="header">

				<A HREF="##" onClick="javascript: return sort_by_this_order('#ThisHeaderItem#', '#thisSortOrder#');"><B>#ThisHeaderItemName#</B></A><CFIF ThisHeaderItem EQ FORM.SORT_BY>&nbsp;<IMG SRC="#Image_Name#" BORDER="0"></CFIF>

				</TD>

				<CFSET Counter = Counter + 1>
			</CFLOOP>
		</TR>
		</CFOUTPUT>

		<CFOUTPUT QUERY="GetVMVendorIDInfo" startrow="#StartRow#" maxrows="#MaxRows#">
			<cfset vendorAddr = "" >
			<!--- <CFIF vendorName NEQ ""><cfset vendorAddr =  vendorAddr & vendorName></CFIF> --->
			<CFIF vendorAddress1 NEQ ""><cfset vendorAddr =  vendorAddress1 & "<BR>"></CFIF>
			<CFIF vendorAddress2 NEQ ""><cfset vendorAddr =  vendorAddr & vendorAddress2 & "<BR>" ></CFIF>
			<CFIF vendorCity NEQ ""><cfset vendorAddr =  vendorAddr & vendorCity ></CFIF>
			<CFIF vendorState NEQ ""><cfset vendorAddr =  vendorAddr & "," & vendorState ></CFIF>
			<CFIF vendorZipCode NEQ ""><cfset vendorAddr =  vendorAddr & " " & vendorZipCode></CFIF>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD><INPUT type="Radio" NAME="SelectedVendor_ID" VALUE="#Vendor_ID#" <CFIF FORM.FinalVendor EQ Vendor_ID>CHECKED</CFIF>>
				<B><CFIF Vendor_ID NEQ "">#Vendor_ID#<CFELSE> <FONT COLOR="red">none</FONT> </CFIF></B>&nbsp;</TD><!--- ONCLICK="NewWindow(this.href,'name','500','350','Yes', 'No');return false;" --->
				<TD nowrap><CFIF vendorName NEQ "">#vendorName#<cfelse> <FONT COLOR="red">--none--</FONT> </cfif>&nbsp;</TD>
				<TD nowrap><CFIF vendorAddr NEQ "">#vendorAddr#<cfelse> <FONT COLOR="red">--none--</FONT> </cfif>&nbsp;</TD>
				<cfif  (busSegOn EQ "1")> <TD nowrap><CFIF Business_Unit_Desc NEQ "">#Business_Unit_Desc#<cfelse><FONT COLOR="red">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--&nbsp;&nbsp;</FONT> </cfif></TD></cfif>
			</TR>
			<INPUT NAME="Vendor_Name_Desc_#Replace(Vendor_ID,'-','_','ALL')#" TYPE="Hidden" VALUE="#GetVMVendorIDInfo.vendorName#">
		</CFOUTPUT>
<!---		<cfif (GetVMVendorIDInfo.RecordCount EQ 0 AND zapyRan EQ 1)>
			<tr>
				<td COLSPAN="100%"><br><font STYLE="font: bold 14px sans-serif; color: Red;">For the customers selected in the program, there are no qualifying payment recipients established in master data.</font><br><br></td>
			</tr>
		</cfif>
	--->
		<TR>
			<TD COLSPAN="100%" STYLE="Border-Bottom: none;">
				<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
			    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			    <CF_Next_Previous_For_Forms
			    formname="VMSearchForm"
			    query="GetVMVendorIDInfo"
			    maxpages="40"
			    previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			    next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			    previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			    addparams="">
			   </DIV>
			</TD>
		</TR>
	</TABLE>
	<cfif GetVMVendorIDInfo.recordcount GT 0>
	<DIV ALIGN="center">
	&nbsp;&nbsp;&nbsp;
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: finishedSearching()"> import selected <CFOUTPUT>#variables.VendorLabel#</CFOUTPUT></a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	<FONT SIZE="2">
	<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="CloseWindow()"> back to main window </a><FONT COLOR="#FF0000">]</FONT></B>
	</FONT>
	</DIV>

	<BR>
	</cfif>
	<!------ popup search code ----->
	<CFOUTPUT>
	<INPUT NAME="Formname" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.FormName)#">
	<INPUT NAME="FieldName" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.FieldName)#">
	<INPUT NAME="FinalItemList" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.FinalItemList)#">
	<INPUT NAME="Business_Segment_Id" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.Business_Segment_Id)#">
	<INPUT NAME="AlreadySelectedItems" TYPE="Hidden" VALUE="#AlreadySelectedItems#">
	<INPUT NAME="FinisedSearching" TYPE="HIDDEN" VALUE="0">
	<INPUT NAME="ReloadForm" type="hidden" value ="#EncodeForHTMLAttribute(form.ReloadForm)#">
	<INPUT NAME="PageSource" type="hidden" value="#EncodeForHTMLAttribute(form.PageSource)#">
	<INPUT NAME="Go" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(form.Go)#">
	<INPUT NAME="FlexAppName" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.FlexAppName)#">
	<INPUT NAME="vendorSearchType" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.vendorSearchType)#">
	<INPUT NAME="QuickPay" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.QuickPay)#">
	<INPUT NAME="programID" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.programID)#">
	<!--- <INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(FORM.startrow)#">
	<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(FORM.frompage)#"> --->
<!--- 	<INPUT NAME="ExcludeList" TYPE="HIDDEN" VALUE="#EncodeForHTMLAttribute(FORM.ExcludeList)#">	 --->
	<INPUT NAME="Settlements" TYPE="Hidden" VALUE="#EncodeForHTMLAttribute(FORM.Settlements)#">
  <!---26298 added descfieldnamevariable, so popup search can refresh descfieldnamevariable automatically--->
  <cfparam name="form.DescFieldNameVariable" default="">
	<input name="DescFieldNameVariable" type="hidden" value="#EncodeForHTMLAttribute(Form.DescFieldNameVariable)#">  <!--26298-->
	<cfif Len(form.DescFieldNameVariable)>
    <input name="#form.DescFieldNameVariable#" type="hidden" value="#EncodeForHTMLAttribute(form.DescFieldNameVariable)#">
  </cfif>
  <!--end of 26298-->
	</CFOUTPUT>
</FORM>
</FIELDSET>
</body>
</html>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function validate()
{
	document.VMSearchForm.Go.value = 1;
	document.VMSearchForm.submit()
}
function resetForm()
{
	event.returnValue = false;
	document.all.Vendor_Name.value = "";
	document.all.Vendor_ID.value = "";

	resetSelect("Vendor_City");
	resetSelect("State");
	resetSelect("Country_Code");
}

function resetSelect(selName)
{
	var sObj = document.getElementById(selName);
	if(sObj)
	{
		sObj.selectedIndex = 0;
		callfireEvent(document,sObj,'Change');
	}
}

function CloseWindow()
{
	window.close()
}

function finishedSearching()
{
	var searchForm = document.all.VMSearchForm;
	var vendorValID = "";
	searchForm.FinisedSearching.value = 1;
	if  (searchForm.Formname.value =="labelSettings")
	{
		var selVendor = document.getElementsByName("SelectedVendor_ID");
	 	var vendorLength = selVendor.length;
        for (var i = 0; i < vendorLength; i++) {
            if (selVendor[i].checked) {
                vendorValID = selVendor[i].value;
            }
        }
		window.opener.document.location.href =  "/DEDUCTIONS/settings/deduction_external_settings.cfm?PageTitle=Payables: Settings&uVendorID=" + vendorValID;
	}
	searchForm.submit();
	return false;
}
function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.VMSearchForm;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}
</SCRIPT>