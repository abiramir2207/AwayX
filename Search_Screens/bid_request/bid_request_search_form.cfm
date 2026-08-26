
<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->
<CFSET Form_Field_Width = "190">
<cfparam name="form.PL_Final" 		default="">
<cfparam name="form.PL_PreSubmit" 	default="">
<cfparam name="form.PL_PostSubmit" 	default="">

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
		else if (start_D == 2)
		{
			spName = "SP_End_date";			
		}
		else if (start_D == 3)
		{
			spName = "SP_Open_date";			
		}
		else 
		{
			spName = "SP_Needed_date";			
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}
	
	function disable_start_End_Date()
	{
		start_End_Date(1,document.all.Start_date_Operator);
		start_End_Date(2,document.all.End_date_Operator);
		start_End_Date(3,document.all.Open_date_Operator);
		start_End_Date(4,document.all.Needed_date_Operator);
		document.all.Start_date.style.fontSize=10;
		document.all.End_date.style.fontSize=10;
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
	 document.body.onload=new Function ("disable_start_End_Date();")
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
<cfoutput>
<FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="/search_screens/bid_request/bid_request_search_result.cfm" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result"></cfoutput>
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
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
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
	<CFQUERY NAME="Get_Users_And_Positions" DATASOURCE="#application.datasource#">
		SELECT	User_Positions_ID, _Users.Name_First + ' ' +  _Users.Name_Last AS User_Name
		FROM	_Users
				INNER JOIN User_Position_Holders
				ON
				User_Position_Holders.User_ID = _Users.User_ID
				AND
				User_Position_Holders.Deleted = 0
		WHERE
				_Users.Deleted = 0				
				AND
				Len(_Users.Name_First) > 0
				AND
				Len(_Users.Name_Last) > 0
		ORDER BY _Users.Name_First
	</CFQUERY>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Show Proposal Search Result"  
	TitleClosed="Show Proposal Search Form"  
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
	<!---////////////////////////////////////////////////BID///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Bid</TD>
		</TR>
		<TR VALIGN="TOP">
			<TD WIDTH="30" ROWSPAN="<cfif form.businessSegmentsOn EQ 1>3<cfelse>2</cfif>">&nbsp;</TD>
			<!---Program title--->
			<TD>
			<span ID="searchItemLabel"><B>Program Title</B></span><BR>
				<CFPARAM NAME="FORM.Program_Title" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Program_Title" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64"<CFIF len(trim(FORM.Program_Title)) GT 0>VALUE="#trim(FORM.Program_Title)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<!---Program number--->
			<TD>
			<span ID="searchItemLabel"><B>Program Number</B></span><BR>
				<CFPARAM NAME="FORM.Program_Number" DEFAULT="">
				<CFOUTPUT>
				<INPUT TYPE="Text" NAME="Program_Number" STYLE="WIDTH:#Form_Field_Width#px;" <CFIF len(trim(FORM.Program_Number)) GT 0>VALUE="#trim(FORM.Program_Number)#"</CFIF>>
				</CFOUTPUT>
			</TD>
			<!---Program status (RFA etc.)--->
			<TD>
			<span ID="searchItemLabel"><B>Program Status</B></span><BR>
				<CFQUERY NAME="Get_Status" DATASOURCE="#application.datasource#">
					Select	Contract_Status_Type_ID,Contract_Status_Type_Desc
					From 	Contract_Status_Types
					Where	Contract_Status_Type_ID <> 3
					AND 	Contract_Status_Type_ID != 1
					Order By Contract_Status_Type_ID
					</CFQUERY>
					<CFPARAM NAME="FORM.Status" DEFAULT="0">
					<SELECT NAME="Status">
						<OPTION VALUE="0">**ALL** Status</OPTION>
						<OPTION VALUE="1">Active, Expiring, Expired</OPTION>
						<CFOUTPUT QUERY="Get_Status"><OPTION VALUE="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</OPTION></CFOUTPUT>
					</SELECT>
					<br><b style="color:red;font-size:10px;">**All** Status will not include expired programs</b>
			</TD>
			<!---Bid status (Pending, Won, Lost or Split)--->
			<TD>
			<span ID="searchItemLabel"><B>Bid Status</B></span><BR>
					<CFPARAM NAME="FORM.BidStatus" DEFAULT="0">
					<cfquery name="GetBidStatus" datasource="#application.datasource#">
					SELECT Bid_Request_Status_ID, Status_Desc
					FROM Bid_Request_Status
					WHERE Deleted = 0
					ORDER BY Bid_Request_Status_ID
					</cfquery>
						<cfoutput query="GetBidStatus">
								<input type="checkbox" name="BidStatus" value="#Bid_Request_Status_ID#" checked>#Status_Desc#&nbsp; 
						</cfoutput>
			</TD>
			
		</TR>
		<!---Only if there's business segments--->
		<cfif form.businessSegmentsOn EQ 1>
		<TR VALIGN="TOP">
			<!---Business ID--->	
			
			<TD colspan="3">
				<span ID="searchItemLabel"><B><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput></B></span><BR>
				<!---get the list of business segments--->
				<cfset qGetBusSegments = businessSegManager.getActive(request.AccessStructure.User_ID) />
					<cfoutput query="qGetBusSegments">
					<input type="checkbox" name="Business_Segment_ID" value="#Business_Segment_ID#" checked>#Business_Unit_Desc#&nbsp; 
					</cfoutput>
			
			</TD>
			<TD>
				<cfoutput>
				<span ID="searchItemLabel"><B>Legacy Deal ID</B></span><BR>
				<INPUT TYPE="Text" NAME="Legacy_Deal_ID" STYLE="WIDTH:#Form_Field_Width#px;" SIZE="64">				
				</cfoutput>
			</TD>
					
		</TR>
		</cfif>	
		
		<TR>	
		
			<!---Program Start Date--->		
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
			
			<!---Program end date--->
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
			
			<!---Open Date--->
			<TD>
			<span ID="searchItemLabel"><B>Open Date</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.Open_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(3,this);" NAME="Open_date_Operator" ID="Open_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.Open_Date" DEFAULT="#Now()#">
				<SPAN ID="SP_Open_Date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Open_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Open_Date#">
				</SPAN>
				</TD>
			</TR></TABLE>
			</CFOUTPUT>			
			</TD>
			
			<!---Date needed by--->
			<TD>
			<span ID="searchItemLabel"><B>Needed By Date</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.Needed_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(4,this);" NAME="Needed_date_Operator" ID="Needed_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.Needed_Date" DEFAULT="#Now()#">
				<SPAN ID="SP_Needed_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Needed_Date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Needed_Date#">
				</SPAN>
				</TD>
			</TR></TABLE>
			</CFOUTPUT>			
			</TD>
			
		</TR>
		
		<!---////////////////////////////////////////////////PRODUCTS///////////////////////////////////////////////////--->
		<cfoutput>
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Product</TD>
		</TR>
		<TR VALIGN="TOP">	
			<TD>&nbsp;</TD>
			<TD>
				<span ID="searchItemLabel"><B>ITEM</B></span>
				<BR>
				<CFPARAM NAME="FORM.item_number" DEFAULT="">
				<INPUT NAME="item_number" VALUE="#FORM.item_number#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>
			<TD>
				<span ID="searchItemLabel"><B>UPC</B></span>
				<BR>
				<CFPARAM NAME="FORM.UPC" DEFAULT="">
				<INPUT NAME="UPC" VALUE="#FORM.UPC#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>
			<TD>
				<CFQUERY NAME="qGetBrands" datasource="#application.datasource#">
					SELECT 	Brand_ID,
							Brand_Name
					FROM 	Brand
					WHERE 	len(brand_name) !=0 
					AND 	Deleted = 0
					<cfif (isDefined("form.Business_Segment_Id") and form.Business_Segment_Id IS NOT 0)>
					AND 	Business_segment_id = #FILTER_BUSINESS_SEGMENT_ID#
					</cfif>
					ORDER BY Brand_Name
				</CFQUERY>
				<span ID="searchItemLabel"><B>Brand</B></span>
				<BR>
				<CFPARAM NAME="FORM.Brand_ID" DEFAULT="0">
				<SELECT NAME="Brand_ID">
					<OPTION VALUE="0">**ALL** Brands</OPTION>
					<CFLOOP QUERY="qGetBrands">
						<OPTION VALUE="#Brand_ID#" <cfif Brand_ID eq form.Brand_ID>selected</cfif>>#Brand_Name#</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
			<TD>
				<span ID="searchItemLabel"><B>Description</B></span><BR>
				<CFPARAM NAME="FORM.description" DEFAULT="">
				<INPUT NAME="description" VALUE="#FORM.description#" STYLE="WIDTH:#Form_Field_Width#px">
			</TD>										
		</TR>
		<!---if use product hierarchy is on then show the hierarchy drop down--->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getUseProductHierarchy()>
			<cfset lHierLevels = application.oApplicationAppSettingsManager.getApplicationAppSettings().getBidRequestHierarchyLevel() />
			<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") /> 
			<TR VALIGN="TOP">	
				<TD>&nbsp;</TD>
				<!---loop over the levels set in app settings and disply drop down for each one--->
				<cfset counter = 1 />
				<cfloop index="levlIndx" list="#lHierLevels#">
					<cfset qProdHierarchy = GroupDataManager.getByProductGroupData(levlIndx + 1) />
					<TD>
						<span ID="searchItemLabel"><B>Product Hierarchy #levlIndx#</B></span>
						<BR>
						<CFPARAM NAME="FORM.Product_Hierarchy_ID_#levlIndx#" DEFAULT="0">
						<SELECT NAME="Product_Hierarchy_ID_#levlIndx#">
							<OPTION VALUE="0">**ALL** Product Hierarchy #levlIndx#</OPTION>
							<CFLOOP QUERY="qProdHierarchy">
								<OPTION VALUE="#Product_Group_ID#" <cfif Product_Group_ID eq "form.Product_Hierarchy_ID_#levlIndx#">selected</cfif>>#Group_Level_Desc#</OPTION>
							</CFLOOP>
						</SELECT>
					</TD>
					<!---logic to create a new tr if the cells are greater than 4--->
					<cfif counter gt 3>
						<cfset counter = 1 />
						</tr>
						<TR VALIGN="TOP">	
							<TD>&nbsp;</TD>
					</cfif>
					<cfset counter = counter + 1 />
				</cfloop>
			</tr>
		</cfif>
		<!---if class codes are on then show the class code drop down--->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getClasscodesOn()>
			<TR VALIGN="TOP">	
				<TD>&nbsp;</TD>
					<cfset qClassCodes = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getActiveClasscodes("", 0) />
					<TD>
						<span ID="searchItemLabel"><B>Class Code</B></span>
						<BR>
						<CFPARAM NAME="FORM.Class_Code_ID" DEFAULT="0">
						<SELECT NAME="Class_Code_ID">
							<OPTION VALUE="0">**ALL** Class Codes</OPTION>
							<CFLOOP QUERY="qClassCodes">
								<OPTION VALUE="#Class_Code_ID#" <cfif Class_Code_ID eq form.Class_Code_ID>selected</cfif>>#Class_Code_Desc#</OPTION>
							</CFLOOP>
						</SELECT>
					</TD>
			</tr>
		</cfif>
		</cfoutput>
		
		<!---////////////////////////////////////////////////CUSTOMER///////////////////////////////////////////////////--->
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Customer</TD>
		</TR>
		<TR VALIGN="TOP">	
			<TD>&nbsp;</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.distributor_label_singular# Name/#application.returned_customer_setting.shard_ship_to_label#</B></span><BR></cfoutput>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Distributor_Info" DEFAULT="">
			<SPAN ID="SP_Distributor_Info">
			<INPUT NAME="Distributor_Info" ID="Distributor_Info" VALUE="#FORM.Distributor_Info#" STYLE="WIDTH:#Form_Field_Width#px">
			</SPAN>
			</CFOUTPUT>
			</TD>
			
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.buying_group_label_singular#</B></span><BR></cfoutput>
			<cfquery name="GetBuyingGroups" datasource="#application.datasource#">
				SELECT *
				FROM Distributor_Buying_Groups
				WHERE Deleted = 0
				AND	Active_Code = 'A'
				ORDER BY Buying_Group_Name
			</cfquery>
			<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
			<SPAN ID="SP_Buying_Group">
			<SELECT NAME="Buying_Group">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.buying_group_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</SPAN>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.family_name_label_singular#</B></span><BR></cfoutput>
			<cfquery name="GetFamilyNames" datasource="#application.datasource#">
				SELECT *
				FROM Distributor_Family
				WHERE Deleted = 0
				ORDER BY Family_Name
			</cfquery>
			<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
			<SPAN ID="SP_Family_Name">
			<SELECT NAME="Family_Name">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.family_name_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</SPAN>
			</TD>	
			
			<!---Operator--->									
			<TD>
			<span ID="searchItemLabel"><B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> <!--- Operator ---> Name</B></span><BR>
			<CFOUTPUT>
			<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
			<INPUT NAME="Operator_Name" ID="Operator_Name" VALUE="#FORM.Operator_Name#" STYLE="WIDTH:#Form_Field_Width#px;">
			</CFOUTPUT>
			</TD>	
		</TR>
		
		<TR VALIGN="TOP">
			<TD COLSPAN="100%" CLASS="sectionHead">Geography</TD>
		</TR>
		<TR>	
			<TD>&nbsp;</TD>		
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.zone_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetZones" DATASOURCE="#application.datasource#">
			SELECT Service_Zone_ID, Zone_Name
			FROM Service_Zones
			WHERE Deleted = 0
			AND len(Zone_Name) > 0
			ORDER BY Zone_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Zone_ID" DEFAULT="0">
			<SELECT NAME="Service_Zone_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.zone_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(Service_Zone_ID)#"#IIF(trim(FORM.Service_Zone_ID) EQ Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(Zone_Name)#</OPTION></CFOUTPUT>
			</SELECT>
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
			<SELECT NAME="Service_Region_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.region_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(Service_Region_ID)#"#IIF(trim(FORM.Service_Region_ID) EQ Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(Region_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.market_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetMarkets" DATASOURCE="#application.datasource#">
			SELECT Service_Market_ID, Market_Name
			FROM Service_Markets
			WHERE Deleted = 0
			AND len(Market_Name) > 0
			ORDER BY Market_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Service_Market_ID" DEFAULT="0">
			<SELECT NAME="Service_Market_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.market_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Service_Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
			</SELECT>
			</TD>
			<TD>
			<cfoutput><span ID="searchItemLabel"><B>#application.returned_customer_setting.broker_label_singular#</B></span><BR></cfoutput>
			<CFQUERY NAME="GetBrokers" DATASOURCE="#application.datasource#">
			SELECT BSA_Foodservice_Brokers_ID, Broker_Name
			FROM broker_active
			WHERE len(Broker_Name) > 0
			ORDER BY Broker_Name
			</CFQUERY>
			<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
			<SELECT NAME="Broker_ID">
				<cfoutput><OPTION VALUE="0">**ALL** #application.returned_customer_setting.broker_label_plural#</OPTION></cfoutput>
				<CFOUTPUT QUERY="GetBrokers"><OPTION VALUE="#trim(GetBrokers.BSA_Foodservice_Brokers_ID)#"#IIF(trim(FORM.Broker_ID) EQ GetBrokers.BSA_Foodservice_Brokers_ID, DE(" SELECTED"), DE(""))#>#trim(GetBrokers.Broker_Name)#</OPTION></CFOUTPUT>
			</SELECT>
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
			
			<INPUT TYPE="HIDDEN" NAME="PL_Final" 		VALUE="#form.PL_Final#">
			<INPUT TYPE="HIDDEN" NAME="PL_PreSubmit" 	VALUE="#form.PL_PreSubmit#">
			<INPUT TYPE="HIDDEN" NAME="PL_PostSubmit" 	VALUE="#form.PL_PostSubmit#">
			<INPUT TYPE="HIDDEN" NAME="PL_ImportProducts" 		VALUE="0">
			<INPUT TYPE="HIDDEN" NAME="PL_ImportAllProducts" 	VALUE="0">
			<INPUT TYPE="HIDDEN" NAME="PL_AllProductList" 		VALUE="">
			</CFOUTPUT>
			&nbsp;&nbsp;
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" ONCLICK="javascript:document.SearchForm.reset();disable_start_End_Date();">reset form</a><FONT COLOR="FF0000">]</FONT></B>
			&nbsp;&nbsp;
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript:showSearchResult(true, 1);">search bids</a><FONT COLOR="#FF0000">]</FONT></B>
			
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
findselectboxes();
</SCRIPT>
</cfif>
<!--------------------------------------------------------
End Search Form
--------------------------------------------------------->
