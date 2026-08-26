
<CFSET thisTemplate="#GetFileFromPath(GetCurrentTemplatePath())#">
<CFIF isdefined("URL.FormName")>
	<CFPARAM NAME="URL.ReturnFieldName"				Default="Contract_Main_ID">
	<CFPARAM NAME="URL.AllowImportAll"				Default="0">
	<cfparam name="URL.Display_Deleted_Programs" 	default="0">
	<CFPARAM NAME="Contract_Status"					Default="0">
	<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
		<INPUT NAME="ParentFormname" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FormName#</CFOUTPUT>">
		<INPUT NAME="FieldName" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.FieldName#</CFOUTPUT>">		
		<INPUT NAME="FinalItemList" TYPE="HIDDEN" VALUE="">
		<INPUT NAME="ReturnFieldName" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.ReturnFieldName#</CFOUTPUT>">
		<INPUT NAME="AllowImportAll" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.AllowImportAll#</CFOUTPUT>">
		<INPUT NAME="Display_Deleted_Programs" TYPE="HIDDEN" VALUE="<CFOUTPUT>#URL.Display_Deleted_Programs#</CFOUTPUT>">
		<input type="hidden" name="FilterSearchPrograms" 	value="0">
		<input type="hidden" name="FilterType" 				value="0">
		<input type="hidden" name="FilterDataList"			value="0">
		<input type="hidden" name="runsearchonfirstload"	value="0">
		<input type="hidden" name="Contract_Status"	value="<CFOUTPUT>#Contract_Status#</CFOUTPUT>">
		<INPUT TYPE="hidden" NAME="Disable_Locked" VALUE= <CFIF isdefined("URL.disable_Locked")><CFIF disable_locked EQ 1>"<CFOUTPUT>#URL.Disable_Locked#</CFOUTPUT>"</CFIF><CFELSE>"0"</CFIF>>
		<INPUT TYPE="hidden" NAME="Creating_User_Position" VALUE=<CFIF isdefined("URL.Creating_User_Position")><CFIF URL.Creating_User_Position NEQ ""><CFOUTPUT>"#URL.Creating_User_Position#"</CFOUTPUT></CFIF><CFELSE>""</CFIF>>		
	</FORM>
	<script>
		if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT> != null){
			this.document.all.FinalItemList.value = opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.<CFOUTPUT>#URL.FieldName#</CFOUTPUT>.value
			if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterSearchPrograms)
			{			
				if(window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterSearchPrograms.value == 1) {
					this.document.all.FilterSearchPrograms.value 	= 1;
					this.document.all.FilterType.value 				= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterType.value;
					this.document.all.FilterDataList.value 			= window.opener.document.all.<CFOUTPUT>#URL.FormName#</CFOUTPUT>.FilterDataList.value;
				}
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
	<cfabort>
</CFIF>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

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
<CFPARAM NAME="FORM.Display_Deleted_Programs"					Default="0">
<CFPARAM NAME="FORM.ReturnFieldName"				Default="Contract_Main_ID">
<CFPARAM NAME="FORM.ProgramList" default="" />

<cfif isDefined("FORM.selPageSize") AND FORM.SelPageSize NEQ "">
  <cfset pgSize = FORM.SelPageSize />
<cfelse>
  <cfset pgSize = 25 />
</cfif>

            
<CFPARAM NAME="startrow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<!--- <cf_Number_of_Rows maxrows= Val(pgSize)> --->
  <cfset maxrows = val(pgSize) />  
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
	<script>
		opener.document.all.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.<CFOUTPUT>#Form.FieldName#</CFOUTPUT>.value = '<CFOUTPUT>#Form.FinalItemList#</CFOUTPUT>'
		opener.document.<CFOUTPUT>#Form.ParentFormname#</CFOUTPUT>.submit();
		window.close()
	</script>
	<CFABORT>
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

<CFSET Input_Select_Width = 150>
<CFSET Large_Select_Width = 220>
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
		document.all.Start_date.style.fontSize=10;
		document.all.End_date.style.fontSize=10;
		document.all.Start_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
		document.all.End_date.style.width = "<CFOUTPUT>#Evaluate("#Input_Select_Width#-50")#</CFOUTPUT>px";
	}
	
	 document.body.onload=new Function ("disable_start_End_Date();")

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
<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
<FORM ACTION="<CFOUTPUT>#thisTemplate#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="Hidden" NAME="Disable_Locked" VALUE="<CFOUTPUT>#FORM.disable_Locked#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Creating_User_Position" VALUE="<CFOUTPUT>#FORM.Creating_User_Position#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="ProgramList" VALUE="" />
<BR>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">program search</LEGEND>
			<TABLE BORDER="0" CELLSPACING="2" CELLPADDING="0" BGCOLOR="WhiteSmoke">
				<TR VALIGN="TOP">
					<TD>
					<span ID="searchItemLabel"><B>Program Title</B></span><BR>
						<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
						<INPUT TYPE="Text" NAME="Program_Title" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px;" SIZE="64"<CFIF len(trim(FORM.Program_Title)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Title)#</CFOUTPUT>"</CFIF>>
					</TD>
					<TD>
					<span ID="searchItemLabel"><B>Program Number</B></span>&nbsp;<FONT COLOR="Red">[</FONT><!---onclick="window.open(this.href,'ProgramList','toolbar=no,width=330,height=400,location=no,menubar=no,resizable=yes,scrollbars=yes');return false" onclick="window.showModalDialog(this.href,window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;"  --->
					<FONT COLOR="Blue"><A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=PROGRAM&passForm=SearchForm',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A></FONT> 
					<FONT COLOR="Red">]</FONT><BR>
						<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
						<INPUT TYPE="Text" NAME="Program_Number" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px;" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.Program_Number)#</CFOUTPUT>"</CFIF>>
					</TD>
					<TD>
					<cfif discountIdentifierManager.discountIdentifierOn()>
						<span ID="searchItemLabel"><B>Discount Identifier</B></span><BR>
						<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
						<cfset qDiscountIdentifiers = discountIdentifierManager.getActive()>
						<SELECT NAME="Discount_Identifier" STYLE="WIDTH:<CFOUTPUT>#Large_Select_Width#</CFOUTPUT>px;">
							<OPTION VALUE="0">**ALL** Discount Identifier</OPTION>
							<CFOUTPUT QUERY="qDiscountIdentifiers"><OPTION VALUE="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>#trim(Discount_Identifier_Desc)#</OPTION></CFOUTPUT>
						</SELECT>
					<cfelse>
						<span ID="searchItemLabel"><B>Program Generic type</B></span><BR>						
						<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
						<cfset useLakebaseForGet_Generic_Types = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_type")>
<cfif useLakebaseForGet_Generic_Types>
	<cftry>
		<cfset Get_Generic_Types = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_type", {
				"order" = "generic_type.asc",
				"select" = "generic_type"
			}), "generic_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Generic_Types = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Generic_Types>
<CFQUERY NAME="Get_Generic_Types" DATASOURCE="#application.datasource#">
						Select	Generic_Type
						From 	Generic_Type
						Order By Generic_Type
						</CFQUERY>
</cfif>
						<SELECT NAME="Generic_Type" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px">
							<OPTION VALUE="0">**ALL** Generic Type</OPTION>
							<CFOUTPUT QUERY="Get_Generic_Types"><OPTION VALUE="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</OPTION></CFOUTPUT>
						</SELECT>
					</cfif>
					</TD>
					<TD>
					<span ID="searchItemLabel"><B>Program Status</B></span><BR>
						<CFQUERY NAME="Get_Status" DATASOURCE="#application.datasource#">
							Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
							From 	Contract_Status_Types
							Where	
								Contract_Status_Type_ID <> 3
							<!--- If cancelling multiple programs (start)--->
							<cfif Contract_Status eq 1>
							and Contract_Status_Type_ID NOT IN(1,2)
							</cfif>
							<!--- If cancelling multiple programs (end)--->
							Order By Contract_Status_Type_ID
							</CFQUERY>
							<CFPARAM NAME="FORM.Status" DEFAULT="0">
							<SELECT NAME="Status" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px">
								<OPTION VALUE="0">**ALL** Status</OPTION>
								<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
							</SELECT>
					</TD>
					<TD WIDTH="30%" ROWSPAN="4">			
					</TD>
				</TR>
				<TR VALIGN="TOP">			
					<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
					<CFSET Date_Operator_Symbols=" ,>=,=,<=">
					<TD>
					<span ID="searchItemLabel"><B>Start Date</B></span><BR>
						<CFOUTPUT>
						<TABLE CELLPADDING="0" CELLSPACING="0">
						<TR><TD valign="top">
						<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
						<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:45px">
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
						</TD>
						<TD>
						<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
						<SPAN ID="SP_Start_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
						</SPAN>
						</TD>
					</TR></TABLE>
						</CFOUTPUT>
					</TD>
					<TD>
					<span ID="searchItemLabel"><B>End Date</B></span><BR>
					<CFOUTPUT>
					<TABLE CELLPADDING="0" CELLSPACING="0">
						<TR><TD valign="top">
						<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
						<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" STYLE="WIDTH:45px">
							<CFSET cnt=0>
							<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
								<CFSET cnt=cnt+1>
								<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
							</CFLOOP>
						</SELECT>
						</TD>
						<TD>
						<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
						<SPAN ID="SP_End_date">
						<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
						</SPAN>
						</TD>
					</TR></TABLE>
					</CFOUTPUT>
					</TD>
					
					<TD>
					<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.broker_label_singular#</B></span><BR></cfoutput>
					<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
					SELECT BSA_Foodservice_Brokers_ID, Broker_Name
					FROM broker_active
					WHERE len(Broker_Name) > 0
					ORDER BY Broker_Name
					</CFQUERY>
					<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
					<SELECT NAME="Broker_ID" STYLE="WIDTH:<CFOUTPUT>#Large_Select_Width#</CFOUTPUT>px;">
						<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.broker_label_plural#</OPTION></cfoutput>
						<!--- GROUP BROKERS BY NAME TO DISPLAY THEM ONLY ONCE IN THE SEARCH TOOL --->
						<CFOUTPUT QUERY="GetBrokers" group="Broker_Name">
							<!--- CREATE LIST OF ID'S THAT SHARE A COMMON BROKER NAME FOR USING IN THE SEARCH QUERY --->
							<OPTION VALUE="#GetBrokers.BSA_Foodservice_Brokers_ID#" <cfif GetBrokers.BSA_Foodservice_Brokers_ID EQ FORM.Broker_ID>SELECTED</cfif>>
								#trim(GetBrokers.Broker_Name)#
							</OPTION>
							<!--- CLEAR IDLIST VARIABLE TO ALLOW CREATION OF A NEW LIST FOR THE NEXT BROKER NAME IN THE LOOP --->
						</CFOUTPUT>
					</SELECT>
					</TD>
					<TD>
					<span ID="searchItemLabel"><B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> <!--- Operator ---> Name</B></span><BR>
					<CFOUTPUT>
					<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
					<INPUT NAME="Operator_Name" ID="Operator_Name" VALUE="#FORM.Operator_Name#" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px;">
					</CFOUTPUT>
					</TD>
				</TR>
				<TR VALIGN="TOP">
					<TD>
					<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.distributor_label_singular# Name</B></span><BR></cfoutput>
					<CFOUTPUT>
					<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
					<SPAN ID="SP_Distributor_Name">
					<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#FORM.Distributor_Name#" STYLE="WIDTH:<CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px">
					</SPAN>
					</CFOUTPUT>
					</TD>
					<TD>
					<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.buying_group_label_singular#</B></span><BR></cfoutput>
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
					<SELECT NAME="Buying_Group" style="width: <CFOUTPUT>#Input_Select_Width#</CFOUTPUT>px;">
						<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.buying_group_label_plural#</OPTION></cfoutput>
						<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
					</SELECT>
					</SPAN>
					</TD>
					<TD>
					<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.family_name_label_singular#</B></span><BR></cfoutput>
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
					<SELECT NAME="Family_Name" style="width: <CFOUTPUT>#Large_Select_Width#</CFOUTPUT>px;">
						<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.family_name_label_plural#</OPTION></cfoutput>
						<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
					</SELECT>
					</SPAN>
					</TD>
					<TD VALIGN="bottom" ALIGN="RIGHT">
 					<cfif NOT isDefined("FORM.sort_by")>
						<INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="ID">
						<INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="ASC">
					</cfif>
					<CFIF isdefined("FORM.DOSEARCH")>
						<cfparam name="FORM.Include_Deleted_Programs" 	default="">
					<CFELSE>
						<cfparam name="FORM.Include_Deleted_Programs" 	default="1"><!------ first time alone default to checked ----->
					</CFIF>
					<cfif FORM.Display_Deleted_Programs EQ 1>
					<b>Include deleted records</b><input type="Checkbox" name="Include_Deleted_Programs" value="1" <cfif FORM.Include_Deleted_Programs EQ 1>checked</cfif>><br>
					</cfif>
          </td>
          </tr>
         	<!--- 
        				Dev Notes: D24498/Anand Rao/31-Aug-10
        				Program Reassign - Changes
        	--->
          <tr>
            <td valign="middle" align="right" colspan="4">
  					<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javascript:document.MyForm.reset();disable_start_End_Date();">reset</a><FONT COLOR="FF0000">]</FONT></B>
  					<br><nobr>         <strong> No. of Records per page:</strong>
            <select id="selPageSize" name="SelPageSize" style="width:45">
              <option value="10" <cfif pgSize EQ "10">selected</cfif>>10</option>
              <option value="25" <cfif pgSize EQ "25">selected</cfif>>25</option>
              <option value="50" <cfif pgSize EQ "50">selected</cfif>>50</option>
              <option value="100" <cfif pgSize EQ "100">selected</cfif>>100</option>                                    
            </select>  
  					<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.MyForm.submit();">search programs</a><FONT COLOR="#FF0000">]</FONT></B></nobr>
  					</TD>
				</TR>		
			</TABLE>

            
    
		<INPUT TYPE="Hidden" NAME="DOSEARCH" VALUE="1">
		<input type="hidden" name="Contract_Status"	value="<CFOUTPUT>#Contract_Status#</CFOUTPUT>">
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


<!--- data filter based on payee--->
<CFSET Filter_CID_List = "">
<CFSET ApplyFilter = 0>
<CFIF isdefined("FORM.FilterSearchPrograms")>
	<!--- <CFIF FORM.FilterSearchPrograms NEQ 0 AND len(trim(FORM.FilterDataList)) GT 0> --->
	<CFIF FORM.FilterSearchPrograms NEQ 0>
		<CFSWITCH expression="#FORM.FilterType#">
			<cfcase value="1"><!--- Distributor --->
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
				<CFSET ApplyFilter = 1>
			</cfcase>
			<cfcase value="2"><!--- Operator --->
				<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Operators
					WHERE BSA_Operator_ID = '#FORM.FilterDataList#' AND Deleted = 0
				</cfquery>
				<CFIF getPayeeFilter.recordcount EQ 0>
					<CFSET Filter_CID_List = 0>
				<CFELSE>
					<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
				</CFIF>
				<CFSET ApplyFilter = 1>					
			</cfcase>
			<cfcase value="3"><!--- Broker --->
				<cfquery name="getPayeeFilter" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Brokers
					WHERE BSA_Foodservice_Brokers_ID = '#FORM.FilterDataList#' AND Deleted = 0
				</cfquery>
				<CFIF getPayeeFilter.recordcount EQ 0>
					<CFSET Filter_CID_List = 0>
				<CFELSE>
					<CFSET Filter_CID_List = ValueList(getPayeeFilter.Contract_Main_ID)>
				</CFIF>								
				<CFSET ApplyFilter = 1>
			</cfcase>
			<cfdefaultcase>
				<CFSET Filter_CID_List = 0>
				<CFSET ApplyFilter = 1>
			</cfdefaultcase>
		</CFSWITCH>
	</CFIF>
</CFIF>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfparam name="Form.Include_Deleted_Programs" 	default="">
<!--------------------------------------------------------------------
Add Sort By
--------------------------------------------------------------------->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT	DISTINCT Contract_Main.Contract_Main_ID, Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date, Contract_Status_Type_ID, Contract_Status_Type_Desc, Program_Control_Panel_Options.Created_Type,
				--Contract_Is_Locked,
				(SELECT Count(Contract_Is_Locked)
				FROM	Contract_Main r
				WHERE
						r.Contract_Is_Locked = 1
						AND
						r.Deleted = 0
						AND
						r.Contract_Locked_By_User_ID <> '#request.AccessStructure.User_ID#'
						AND
						r.Contract_Number = Contract_Main.Contract_Number) AS Any_Revision_Locked_By_Others
		FROM	
				Contract_Main
				INNER JOIN Contract_Status_Types ON
				(Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX)				
				INNER JOIN	Program_Control_Panel_Options
				ON (Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
		WHERE	
				Contract_Main.Deleted IN (0<cfif Form.Include_Deleted_Programs EQ 1>,1</cfif>)
				AND
				Contract_Main.Flagged_As_Purged = 0
				AND
				(
					((Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND (Contract_Main.Revision_of_Contract_Main_ID IS NULL))
					OR
					(NOT(Contract_Main.Parent_Revised_Contract_Main_ID IS NULL) AND NOT(Contract_Main.Revision_of_Contract_Main_ID IS NULL) AND Contract_Status_Types.Contract_Status_Type_ID > 3)
				)
				<CFIF FORM.Creating_User_Position NEQ "">
					AND Creating_User_Position_ID = #FORM.Creating_User_Position#
				</CFIF>
				<!--- To cancel multiple programs (start) --->
				<CFIF Form.Contract_Status eq 1>
				AND Contract_Status_Types.Contract_Status_Type_ID NOT IN (1,2)
				AND Contract_Main.Force_Expiration_Flag = 0
				</CFIF>
				<!--- To cancel multiple programs (end) --->
				<CFIF Form.Status NEQ "0">
					AND Contract_Status_Types.Contract_Status_Type_ID = #Form.Status#
				</CFIF>
				<!------<CFIF Form.ProgramType NEQ "0">
					AND Contract_Main.ProgramType_ID = #Form.ProgramType#
				</CFIF>----->
				<CFPARAM NAME="FORM.Generic_Type" DEFAULT="0">
				<CFIF FORM.Generic_Type NEQ "0">
					AND	Program_Control_Panel_Options.Generic_Type = '#FORM.Generic_Type#'
				</CFIF>
				<CFPARAM NAME="FORM.Discount_Identifier" DEFAULT="0">
				<CFIF FORM.Discount_Identifier NEQ "0" AND IsNumeric(FORM.Discount_Identifier)>
					AND	Program_Control_Panel_Options.Discount_Identifier_ID = '#FORM.Discount_Identifier#'
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
				<CFIF (Trim(FORM.ProgramList) NEQ "")>
					AND Contract_Main.Contract_Number in (#preservesinglequotes(FORM.ProgramList)#)
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
				<CFIF Form.Broker_ID NEQ "0">
					AND
					EXISTS
					(
					SELECT	TOP 1 Contract_Brokers.Contract_Main_ID
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
							)							
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
					)					
				</CFIF>
				<CFIF (((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))) OR (Len(Form.Distributor_Name) GT 0)>
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
							(BSA_FoodService_Customers.BSA_FoodService_Customers_ID = Contract_Distributors.BSA_FoodService_Customers_ID)							
							<CFIF ((Form.Family_Name NEQ "0") OR (Form.Buying_Group NEQ "0"))>
							AND
							NOT (BSA_FoodService_Customers.BSA_FoodService_Customers_ID IS NULL)
							</CFIF>
							<CFIF Len(Trim(Form.Distributor_Name)) GT 0>
							AND
							BSA_FoodService_Customers.Name LIKE '%#Form.Distributor_Name#%'
							</CFIF>
						WHERE
							Contract_Distributors.Deleted = 0
							AND
							Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
							<CFIF Form.Family_Name NEQ "0">
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
							</CFIF>
							<CFIF Form.Buying_Group NEQ "0">
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
				</CFIF>
				<CFIF ApplyFilter EQ 1>
					AND
					Contract_Main.Contract_Main_ID IN(#Filter_CID_List#)
				</CFIF>
				
							
		ORDER BY #sql_Sort_By#
	</CFQUERY>
	
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many programs in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
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
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Programs"></TD>
					<CFELSE>
						<TD>&nbsp;</TD>
					</CFIF>
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
						<TD ID="header" align="left" nowrap><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#this_Header#','#New_Sort_Order#');"><b>#this_Header#</b><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></TD>
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
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(Evaluate("TheQuery.#FORM.ReturnFieldName#"))#" <CFIF listfind(FORM.FinalItemList, trim(Evaluate("TheQuery.#FORM.ReturnFieldName#"))) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(Evaluate("TheQuery.#FORM.ReturnFieldName#")), ",")></CFIF> <CFIF FORM.Disable_Locked EQ 1 AND Any_Revision_Locked_By_Others EQ 1>DISABLED</CFIF>>
						<CFELSE>
							<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(Evaluate("TheQuery.#FORM.ReturnFieldName#"))#" <CFIF listfind(FORM.FinalItemList, trim(Evaluate("TheQuery.#FORM.ReturnFieldName#"))) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(Evaluate("TheQuery.#FORM.ReturnFieldName#")), ",")></CFIF>>
						</CFIF>
					</TD>
					<TD NOWRAP>#TheQuery.Contract_Number#&nbsp;</TD>
					<TD TITLE="#TheQuery.Contract_Title#" WIDTH="70%">
					<CFSET Display_Title=Left(TheQuery.Contract_Title,55)>
					<CFIF len(trim(TheQuery.Contract_Title)) GT 55>
						#Display_Title#...
					<CFELSEIF len(trim(TheQuery.Contract_Title)) EQ 0>
						&nbsp;
					<CFELSEIF len(trim(TheQuery.Contract_Title)) LTE 55>
						#Display_Title#	
					</CFIF>
						
					(#TheQuery.Contract_Status_Type_Desc#)</TD>
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
	<input type="hidden" name="FilterType" 				value="#Form.FilterType#"> <!---  1= op, 2 = br, 3 = dis --->
	<input type="hidden" name="FilterDataList"			value="#Form.FilterDataList#">
	<input type="hidden" name="runsearchonfirstload"	value="#Form.runsearchonfirstload#">	
	<INPUT TYPE="HIDDEN" NAME="AllowImportAll" 			VALUE="#FORM.AllowImportAll#">
	<INPUT TYPE="HIDDEN" NAME="Display_Deleted_Programs" VALUE="#FORM.Display_Deleted_Programs#">
	<INPUT TYPE="HIDDEN" NAME="ReturnFieldName" 		VALUE="#FORM.ReturnFieldName#">
	<cfif isDefined("FORM.sort_by")>
		<INPUT TYPE="HIDDEN" NAME="sort_by" 				VALUE="#FORM.sort_by#">
		<INPUT TYPE="HIDDEN" NAME="sort_Order" 				VALUE="#FORM.sort_Order#">
	</cfif>
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
			<!------//recordcount = <CFOUTPUT>#ListLen(whole_Product_List)#</CFOUTPUT>;----->
			if(parseInt(recordcount) == 1) pString = "Program";
			else pString = "Programs";
			
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){
				/* true or false based on browser - IE 10 and above or IE 9 and below. 
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.allbox,'Click');
				
				document.MyForm.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0){
					<CFIF LCase(FORM.ReturnFieldName) EQ LCase("Contract_Main_ID")>
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.Contract_Main_ID)#</CFOUTPUT>";
					<CFELSE>
					document.MyForm.FinalItemList.value 	= document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.Contract_Number)#</CFOUTPUT>";
					</CFIF>
				}
				else
				{
					<CFIF LCase(FORM.ReturnFieldName) EQ LCase("Contract_Main_ID")>
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.Contract_Main_ID)#</CFOUTPUT>";
					<CFELSE>
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.Contract_Number)#</CFOUTPUT>";
					</CFIF>
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
			document.all.finishedselectingitems.value = 1
			document.all.MyForm.submit();
		}	
	</cfif>
	<CFIF FORM.runsearchonfirstload EQ 1>
		document.all.runsearchonfirstload.value = 0;
		document.all.MyForm.submit();
	</CFIF>

</SCRIPT>
