<cfsilent>
<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->
<CFSET Form_Field_Width = "210">
<cfif NOT isDefined("genSettingsManager") OR NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
<cfset Agreement_Details = CreateObject("component","components.Export.Sales_Agreement_AJAX") />
<cfset qry_Export_Destination_Country = Agreement_Details.getDestination()>
</cfsilent>
<STYLE>
	SELECT,INPUT
	{
		font-size : 10px;
	}
	SELECT
	{
		font-size : 10px;
		WIDTH:<CFOUTPUT>#Form_Field_Width#</CFOUTPUT>px;
	}
</STYLE>
<cfparam name="FILTER_BUSINESS_SEGMENT_ID" default="0">
<cfif isDefined("BUSINESS_SEGMENT_ID")>
	<CFSET FILTER_BUSINESS_SEGMENT_ID = FORM.BUSINESS_SEGMENT_ID>
</cfif>
<CFSET Layer_ID = 9999>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript">
	var bNoPrevSearch = true;
	function showSearchResult(bchangeMode, pageNum)
	{
		document.SearchForm.startrow.value = pageNum;
		if(arguments.length > 2)
		{
			document.SearchForm.frompage.value = arguments[2];
		}
		var searhFormHideImg = document.all.image_<CFOUTPUT>#Layer_ID#</CFOUTPUT>;
		if(bchangeMode)
		{
			searhFormHideImg.click();
		}

		document.SearchForm.submit();
		bNoPrevSearch = false;
	}
	
	function disableSelect(sel1, sel2, findProperVal)
	{
		var selInd = 0;
		if(findProperVal)
		{
			selInd = Get_Select_Index(sel2, sel1.value);
			sel2.selectedIndex = selInd;
		}
		else
		{
			if(sel1.selectedIndex > 0)
			{
				sel2.selectedIndex = selInd;
			}
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
	}
	
/* Dev Note: Milan; 9864. This function is being used to "reset" a form */
	function ClearFields()
	{
		for(i=0; i<document.SearchForm.elements.length; i++)
		{			
		/* For single select boxes */
				if(SearchForm.elements[i].type =='select-one')
				{
					SearchForm.elements[i].value = SearchForm.elements[i].options[0].value;
				}
		/* For text boxes */	
						if(SearchForm.elements[i].type =='text')
						{
						/* Not for date fields - Date fields are disabled instead by "disable_start_End_Date" function above */
							if(SearchForm.elements[i].name != 'Start_date'  && SearchForm.elements[i].name != 'End_date')
							{
								SearchForm.elements[i].value = '';
							}
						}					
		  }
	  }

	function disableDiv(divName,bDis,bHide)
	{
		oDiv = document.all.item(divName);	
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
		
	 //document.body.onload=new Function ("dist_lookup_Pick(3,document.all.SearchForm.elements[0]);disable_start_End_Date();")
	 document.body.onload=new Function ("disable_start_End_Date()")
</SCRIPT>

<STYLE>
	.sectionHead
	{
		font-weight:bold;
		font-size:15px;
		color:red;
		border-bottom:2px solid #0000CD;
	}
</STYLE>
<cfoutput><FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="/scorecard/Sales_Agreement_Search_Result.cfm#form.IFRAME_Extra_URL#" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result"></cfoutput>
<CFSCRIPT>
	Border="Yes";
	BorderSize=0;  
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="No";  
	WIDTH="100%";
</CFSCRIPT>
	<CFQUERY NAME="Get_User_Positions" DATASOURCE="#application.datasource#">
		SELECT	User_Positions_ID, Position_Label
		FROM	User_Positions
		WHERE
				len(Position_Label) <> 0
				AND
				Deleted = 0
				AND
				(
					User_Positions.Service_Market_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Markets
						WHERE 	
								Deleted = 0
								AND
								Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
					)
				)
				AND
				(
					User_Positions.Service_Region_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Regions
						WHERE 	
								Deleted = 0
								AND
								Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
					)
				)
				AND
				(
					User_Positions.Service_Zone_ID IS NULL
					OR EXISTS
					(
						SELECT  *
						FROM 	Service_Zones
						WHERE 	
								Deleted = 0
								AND
								Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
					)
				)
		ORDER BY Position_Label
	</CFQUERY>
	<CFQUERY NAME="Get_Users_And_Positions" DATASOURCE="#application.datasource#" cachedwithin="#APPLICATION.userDataCacheSpan#">
		SELECT	User_Positions_ID, _Users.Name_First + ' ' +  _Users.Name_Last AS User_Name
		FROM	_Users
				INNER JOIN User_Position_Holders
				ON
				User_Position_Holders.User_ID = _Users.User_ID
				AND
				User_Position_Holders.Deleted = 0
				AND User_Position_Holders.User_Position_Type = 'P'
		WHERE
				_Users.Deleted = 0				
				AND
				Len(_Users.Name_First) > 0
				AND
				Len(_Users.Name_Last) > 0
		<!---Don't show BSA users --->
	<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
	AND (_Users.User_Rights_ID IS NULL 
	OR _Users.User_Rights_ID != 9999)
	</cfif>
		ORDER BY _Users.Name_First
	</CFQUERY>
	
<cfscript>

function isNextRow(maxCols, currCols)
{
	if(currCols LTE 1)
	{
		return 0;
	}
	else
	{
		return (not(currCols) mod maxCols);
	}
}

</cfscript>
<cfset maxColsPerRow = 4/>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Show Agreement Search Result"  
	TitleClosed="Show Agreement Search Form"  
	TitleTooltip="Click here to toggle the view"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#"
	layerid="#Layer_ID#">

	<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
	<CFSET Date_Operator_Symbols=" ,>=,=,<=">
	<TABLE BORDER="0" CELLSPACING="2" WIDTH="<CFOUTPUT>#table_Width#</CFOUTPUT>" CELLPADDING="0">
	
	<!---////////////////////////////////////////////////AGREEMENT///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Agreement</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD WIDTH="30" ROWSPAN="2">&nbsp;</TD>
			<TD>
			<span ID="searchItemLabel"><B>Agreement Title</B></span><BR>
				<CFPARAM NAME="FORM.Agreement_Title" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Agreement_Title" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64"<CFIF len(trim(FORM.Agreement_Title)) GT 0>VALUE="#trim(FORM.Agreement_Title)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Agreement Number</B></span><BR>
				<CFPARAM NAME="FORM.Agreement_Number" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Agreement_Number" STYLE="WIDTH:#Form_Field_Width#px;" <CFIF len(trim(FORM.Agreement_Number)) GT 0>VALUE="#trim(FORM.Agreement_Number)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Agreement Status</B></span><BR>
				<CFQUERY NAME="Get_Status" DATASOURCE="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 12, 0, 0)#">
					SELECT	Contract_Status_Type_ID,Contract_Status_Type_Desc
					FROM 	Contract_Status_Types
					WHERE	Contract_Status_Type_ID < = 7
					AND  Contract_Status_Type_ID NOT IN (3,6)
					ORDER BY Contract_Status_Type_ID
					</CFQUERY>
					<CFPARAM NAME="FORM.Status" DEFAULT="-1">
					<SELECT NAME="Status">
						<OPTION VALUE="-1">**ALL** Status</OPTION>
						<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
					<!------ <br><b style="color:red;font-size:10px;">**All** Status will not include expired programs</b> ----->
			</TD>
		</TR>
		<TR>			
			<TD>
			<span ID="searchItemLabel"><B>Start Date</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
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
				<TR><TD>
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
		</TR>
		<!---////////////////////////////////////////////////CUSTOMER///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Customer</TD>
		</TR>
		<TR VALIGN="TOP">	
			<TD>&nbsp;</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.distributor_label_singular# Name</B></span><BR></cfoutput>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
			<SPAN ID="SP_Distributor_Name">
			<INPUT NAME="Distributor_Name" ID="Distributor_Name" VALUE="#FORM.Distributor_Name#" STYLE="WIDTH:#Form_Field_Width#px">
			</SPAN>
			</CFOUTPUT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.shard_ship_to_label#</B></span><BR></cfoutput>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Distributor_shipto" DEFAULT="">
			<SPAN ID="SP_Distributor_shipto">
			<INPUT NAME="Distributor_shipto" ID="Distributor_shipto" VALUE="#FORM.Distributor_shipto#" STYLE="WIDTH:#Form_Field_Width#px">
			</SPAN>
			</CFOUTPUT>
			</TD>
		</TR>
				<!---////////////////////////////////////////////////GEOGRAPHY///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Geography</TD>
		</TR>
		<TR VALIGN="TOP">	
			<TD>&nbsp;</TD>
			<TD><span ID="searchItemLabel"><B>Destination Country:</B></span><BR>
			<CFPARAM NAME="FORM.Export_Destination_Country_ID" DEFAULT="0">
			<SPAN ID="SP_Country_ID">
			<SELECT NAME="Export_Destination_Country_ID">
			<CFOUTPUT>
				<OPTION VALUE="0">**ALL** Countries</OPTION>
			<cfloop query="qry_Export_Destination_Country">
				<OPTION VALUE="#Export_Lookup_Destination_Country_ID#" <cfif Form.Export_Destination_Country_ID eq Export_Lookup_Destination_Country_ID>selected</cfif>>#Export_Lookup_Destination_Country_Desc#</OPTION>
			</cfloop>
			</SELECT>
			</SPAN>
			</CFOUTPUT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.region_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetRegions" DATASOURCE="#application.datasource#">
			SELECT Service_Region_ID, Region_Name
			FROM Service_Regions
			WHERE Deleted = 0
			AND len(Region_Name) > 0
			ORDER BY Region_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Region_ID" DEFAULT="0">
			<SPAN ID="SP_Service_Region_ID">
			<SELECT NAME="Service_Region_ID">
				<CFOUTPUT><OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION></CFOUTPUT>
				<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Service_Region_ID) EQ Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</SPAN>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" align="right">
			<CFOUTPUT>
			<span ID="searchItemLabel"><B></B></span><BR>
			<INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="#Default_Sort#">
			<INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="#Default_Sort_Order#">
			<INPUT TYPE="HIDDEN" NAME="startrow" VALUE="1">
			<INPUT TYPE="HIDDEN" NAME="frompage" VALUE="1">
			<INPUT TYPE="HIDDEN" NAME="pageLength" VALUE="13">
			<INPUT TYPE="HIDDEN" NAME="DOSEARCH" VALUE="1">
			</CFOUTPUT>
			&nbsp;&nbsp;
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" ONCLICK="javascript:ClearFields();disable_start_End_Date();">reset form</a><FONT COLOR="FF0000">]</FONT></B>
			&nbsp;&nbsp;
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:showSearchResult(true, 1);">search agreements</a><FONT COLOR="#FF0000">]</FONT></B>
			
			</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%">&nbsp;</TD>
		</TR>
	</TABLE>
</CF_openLayer>
</FORM>

<CFPARAM name="form.SearchIsConductedFromOtherWindow" default="0">
<cfif form.SearchIsConductedFromOtherWindow EQ 0>
<SCRIPT LANGUAGE="JavaScript">
	document.all.Agreement_Title.focus();
	findselectboxes();
</SCRIPT>
</cfif>
<!--------------------------------------------------------
End Search Form
--------------------------------------------------------->
