<CFSET PAGE_TITLE="Deductions Scorecard">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="" onResize="moveDiv();">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<CFSET AppLevelAllowCredits = appSettings.getDDAllowNegativeAmountCredits() />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Unlock all locked deductions under this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFSET useLakebaseForUnlockDDUnderThisUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<CFIF useLakebaseForUnlockDDUnderThisUser>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "locked_by" = "eq.#request.AccessStructure.user_ID#", "dd_locked_by_match_central" = "eq.0" },
			{ "is_locked" = 0, "locked_by" = "" }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUnlockDDUnderThisUser = false>
		</cfcatch>
	</cftry>
</CFIF>
<CFIF NOT useLakebaseForUnlockDDUnderThisUser>
<CFQUERY NAME="UnlockDDUnderThisUser" DATASOURCE="#Application.Datasource#">
	UPDATE	Deductions
	SET 	Is_Locked=0,
			Locked_By=''
	WHERE	Locked_By = '#request.AccessStructure.user_ID#'
		AND DD_Locked_By_Match_Central = 0
</CFQUERY>
</CFIF>

<!--- Dev Note: KAL; 7821 --->
<cfset DD_Status_toHide	= CreateObject("component", "components.Deduction.settings.DeductionSettingsManager").DD_Status_Control(request.AccessStructure.profiles_id) />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<CFSET fore_Color="FFE083">
<CFOUTPUT>
<STYLE>
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Black;
		cursor:				pointer;
		BACKGROUND-COLOR: 	FFCE84;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				pointer;		
		BACKGROUND-COLOR: 	WhiteSmoke;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
	
	
	
	TD.headernotselected
  {
   background-color 	: dddddd;
   border-bottom		: solid 3px black;
   cursor				: pointer;	
  }
  TD.headerselected
  {
   border-left			: solid 3px black;
   border-top			: solid 3px black;
   border-right			: solid 3px black;
   background-color 	: #fore_Color#;
   cursor				: pointer;	
   TEXT-TRANSFORM		: uppercase;
  }
  TD.headerblank
  {
   border-bottom		: solid 3px black;
  }
  TD.headerspacer
  {
   border-bottom		: solid 3px black;
  }
  TD.headerlastone
  {
   border-left			: solid 3px black;
  }

</STYLE>
</CFOUTPUT>
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="DD_DedID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">


<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
<CFOUTPUT>
var default_Sort_By = "#FORM.SORT_BY#";
var default_Sort_Order = "#FORM.SORT_ORDER#";

var Asc_Img = "#ASC_IMG#";
var Desc_Img = "#DESC_IMG#";
</CFOUTPUT>

var sort_By;
var sort_Order;
var Sort_Img;
setDefaults();

function setDefaults()
{
	sort_By = default_Sort_By;
	sort_Order = default_Sort_Order;
	if(default_Sort_Order == "ASC")
	{
		Sort_Img = Asc_Img;
	}
	else
	{
		Sort_Img = Desc_Img;
	}
}

function Change_Tab()
{	/* I have removed the anchors inside "CFLOOP QUERY="GetStatus".
	If it is added back, then the below line needs to be uncommented.
	*/
	//var aObj 	= getParentObject(event.srcElement,"A");
	var oTable_Deductions = document.all.Table_Deductions;
	var oCells = oTable_Deductions.rows[0].cells;
	var i;
	var thisCell = getParentObject(event.srcElement,"TD");
	if(thisCell)
	{
		for(i=0;i<oCells.length;i++)
		{
			if(oCells[i] == thisCell)
			{					
				oCells[i].className = "headerselected";
			}
			else
			{
				if(oCells[i].id)
				{
					oCells[i].className = "headernotselected";
				}
			}
		}
	}
	setDefaults();
	/* I have removed the anchors inside "CFLOOP QUERY="GetStatus".
	If it is added back, then the below line needs to be uncommented.
	*/
	//sc_URL = aObj.href;		
	Sort_It(document.all.DD_Table_Headers.rows[0].cells[0], 1);	
	event.cancelBubble = true;
}


function Set_Sort_By(sortVal)
{
	var This_Sort_Order = "ASC";
	Sort_Img = Asc_Img;
	if(sort_By == sortVal)
	{
		if(sort_Order == "ASC")
		{
			This_Sort_Order = "DESC";
			Sort_Img = Desc_Img;
		}
	}
	sort_Order = This_Sort_Order;
	sort_By = sortVal;
	var tdObj 	= getParentObject(event.srcElement,"TD");
	Sort_It(tdObj);
}

function Sort_It(tdObj, switch_tab)
{
    switch_tab = switch_tab || 0;
    var Summary_Page_Form = window.Show_List.document.DD_Scorecard;
	if(Summary_Page_Form)
	{
		Summary_Page_Form.SORT_BY.value = sort_By;
		Summary_Page_Form.SORT_ORDER.value = sort_Order;
		Summary_Page_Form.HIDE_PARENT.value = Number(window.document.frmHideParent.chkHideParent.checked);
	
		if(tdObj)
		{
			var spObjs = $(tdObj).find('[id="SP_SORT"]').get(0);
			var AllSps = $(document).find('[id="SP_SORT"]');
			var i;
			for(i=0;i<AllSps.length;i++)
			{
				if(AllSps[i] == spObjs)
				{						
					$(AllSps[i]).find('[id="IMG_SORT"]').attr("src", "/Images/" + Sort_Img);
					$(AllSps[i]).attr("style", "visibility: visible");
				}
				else
				{
					$(AllSps[i]).attr("style", "visibility: hidden");
				}
			}
        }
        // skip form submission in tab switching
        if (switch_tab !== 1)
		    Summary_Page_Form.submit();
	}
}
</SCRIPT>

<CFPARAM NAME="URL.Status" DEFAULT="">
<CFPARAM NAME="URL.Tier_Number" DEFAULT="">
<CFPARAM NAME="URL.Action" DEFAULT="">
<CFPARAM NAME="URL.Class" DEFAULT="">
<CFPARAM NAME="URL.chkHideParent" DEFAULT="">
<CFPARAM NAME="HIDE_PARENT" DEFAULT="">
<CFPARAM NAME="URL.Program_Agree_Status_ID" DEFAULT="">
<CFPARAM NAME="URL.Show_Status" DEFAULT="">
<CFPARAM NAME="URL.SC_Shr_Ship_To" DEFAULT="">
<CFPARAM NAME="URL.SC_Broker_Shard" DEFAULT="">


<TABLE BORDER="0" WIDTH="1250">
	<TR>
		<TD WIDTH="100"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
		<TD><form name="frmHideParent" style="margin-bottom:0px;"><b>Hide Parent</b>:<input type="checkbox" name="chkHideParent" value="1" 
				onClick="window.Show_List.document.DD_Scorecard.HIDE_PARENT.value = Number(window.document.frmHideParent.chkHideParent.checked);window.Show_List.document.DD_Scorecard.submit();" <cfif URL.chkHideParent eq 1>checked</cfif>></form></td>
		<TD ALIGN="Right"><B><FONT SIZE="2" COLOR="Red">[ </FONT><A HREF="/deductions/search_screens/Ded_Advanced_Search.cfm"><FONT SIZE="2">search deductions</FONT></A><FONT SIZE="2" COLOR="Red"> ]</FONT></B></TD>
	</TR>
</TABLE>
<BR>


<CFSET URL_Str = "">
<CFIF URL.Tier_Number NEQ "">
	<CFSET URL_Str = "#URL_Str#&Tier_Number=#URL.Tier_Number#">
</CFIF>
<CFIF URL.chkHideParent NEQ "">
	<CFSET URL_Str = "#URL_Str#&HIDE_PARENT=#URL.chkHideParent#">
</CFIF>
<CFIF URL.Action NEQ "">
	<CFSET URL_Str = "#URL_Str#&DD_Stage_ID=#URL.Action#">
</CFIF>
<CFIF URL.Class NEQ "">
	<CFSET URL_Str = "#URL_Str#&DD_Classification_ID=#URL.Class#">
</CFIF>

<CFIF IsDefined("URL.Program_Agree_Status_ID")>
	<CFSET URL_Str = "#URL_Str#&Program_Agree_Status_ID=#URL.Program_Agree_Status_ID#">
</CFIF>

<CFIF URL.SC_Shr_Ship_To NEQ "">
	<CFSET URL_Str = "#URL_Str#&SC_Shr_Ship_To=#URL.SC_Shr_Ship_To#">
</CFIF>
<CFIF URL.SC_Broker_Shard NEQ "">
	<CFSET URL_Str = "#URL_Str#&SC_Broker_Shard=#SC_Broker_Shard#">
</CFIF>

<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT 	DD_Status_ID,
			<CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>
			CASE 
			WHEN DD_Status_ID = 3 THEN
			Program_Agree_Status.Program_Agree_Status_Desc
			ELSE
			DD_Status_Description
			END As DD_Status_Description
			<CFELSE>
			DD_Status_Description
			</CFIF>,
			Program_Agree_Status_ID,
			DD_Status_Order
	FROM 	DD_Status 
	
	LEFT JOIN Program_Agree_Status ON 1 = 2 <CFIF Get_Profile_Settings.DD_RFA_Agreed EQ 1>OR DD_Status_ID = 3</CFIF>
	WHERE 	<CFIF (application.returned_customer_setting.DD_Show_Rebill NEQ 1 AND appSettings.getIntegrated_Rebill() NEQ 1)>
			DD_Status_ID <> 7 AND
			</CFIF>
			<CFIF AppLevelAllowCredits NEQ 1>
			DD_Status_ID NOT IN (8,9) AND
			</CFIF>
			<cfif appSettings.getDD_Show_Delete() NEQ 1>
			DD_Status_ID <> 6 AND
			</cfif>
			DD_Status.Deleted = 0 
	ORDER BY DD_Status_Order, Program_Agree_Status_ID
</CFQUERY>

<cfif ListFind(DD_Status_toHide, URL.Show_Status) NEQ 0><!------ If the default tab to be selected it set to hide, make the default another one, which is done below ----->
	<cfset URL.Show_Status = "" />
</cfif>

<CFOUTPUT>

<TABLE BORDER="0" WIDTH="1250" CELLPADDING="1" CELLSPACING="0" ID="Table_Deductions" ALIGN="Center">
	<TR>	
	 <TD CLASS="headerblank">&nbsp;</TD>
		<CFLOOP QUERY="GetStatus">
		<cfif ListFind(DD_Status_toHide, DD_STATUS_ID) EQ 0>
			<cfif URL.Show_Status EQ ""><!------ set the default selected tab, if it is empty ----->
				<cfset URL.Show_Status = DD_STATUS_ID />
			</cfif>
			<TD ID="#RecordCount#" ONCLICK="javaScript:Change_Tab(); load_iframe('DD_Scorecard_display.cfm?Program_Agree_Status_ID=#Program_Agree_Status_ID#&Show_Status=#DD_Status_ID#&Hide_Parent='+Number(window.document.frmHideParent.chkHideParent.checked));"
			<CFIF URL.Show_Status EQ DD_Status_ID AND URL.Program_Agree_Status_ID EQ Program_Agree_Status_ID>
				CLASS="headerselected" 		
			<CFELSE>
				CLASS="headernotselected" 
			</CFIF>
			 ALIGN="center" NOWRAP ID="PL_Type">
			<b>		
				
			<!---<A ID="#RecordCount#" ONCLICK="javaScript: CLASS='tablink_back'; Show_List.location.href='DD_Scorecard_display.cfm?Program_Agree_Status_ID=#Program_Agree_Status_ID#&Show_Status=#DD_Status_ID#&Hide_Parent='+Number(window.document.frmHideParent.chkHideParent.checked)">---><!--- #URL_Str# --->
			<NOBR>&nbsp;&nbsp;&nbsp;#LCase(DD_Status_Description)#&nbsp;&nbsp;&nbsp;</NOBR><!---</A>---></B></TD><!---</A>--->
			<CFIF CurrentRow LT RecordCount>
			<TD CLASS="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
			</CFIF>
		</cfif>
		</CFLOOP>
	 
<TD CLASS="headerspacer" WIDTH="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
<!------
<TD WIDTH="90%" CLASS="remaining">&nbsp;</TD>
----->
	</TR>
</TABLE>

<TABLE WIDTH="1250" BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" ID="DD_Table_Headers">
	<TR BGCOLOR=#fore_Color#>
		<TD WIDTH="30">&nbsp;</TD>
		<!--- <TD WIDTH="30">&nbsp;</TD> --->
		
		<CFSET Header_Name_List = "DEDUCTION ##,$ AMOUNT,#ucase(application.returned_customer_setting.distributor_label_singular)#,DATE,AGE,#UCase(stDeductionLabels["Action"])#,BROKER,REGION,&nbsp;ANALYST">
		<CFSET Header_Value_List = "DD_DedID_SP_Number,DD_Amount,Name,DD_Date,DD_Date,DD_Stage_Description,Broker_Name,Region_Name,Name_Last">
		<CFSET Header_Width_List = "180,260,0,62,175,0,260,0,175">
		<CFSET Counter = 1>
		<CFLOOP LIST="#Header_Name_List#" INDEX="This_Header" DELIMITERS=",">
			<CFSET This_Width = ListGetAt(Header_Width_List, Counter, ",")>
			<CFSET This_Sort_By = ListGetAt(Header_Value_List, Counter, ",")>
			<CFSET Show_Sort_Img = false>
			<CFIF FORM.SORT_BY EQ This_Sort_By>
				<CFSET Show_Sort_Img = true>
			</CFIF>
			
			<CFIF This_Sort_By NEQ "Name" AND This_Sort_By NEQ "DD_Stage_Description" AND This_Sort_By NEQ "Region_Name">			
			<TD WIDTH="#This_Width#" STYLE="cursor:pointer;" nowrap valign="center">
			<CFELSE>
			<BR>
			</CFIF>
			<A HREF="##" ONCLICK="javaScript: Set_Sort_By('#This_Sort_By#');"><b>#TRIM(This_Header)#</b></A>
			<SPAN ID="SP_SORT"<CFIF NOT Show_Sort_Img> STYLE="VISIBILITY:hidden;"</CFIF>><IMG ID="IMG_SORT" SRC="/Images/down_1.gif"></SPAN>
			<CFIF This_Sort_By NEQ "DD_Amount" AND This_Sort_By NEQ "DD_Date" AND This_Sort_By NEQ "Broker_Name">
			</TD>
			</CFIF>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
	</TR>
</TABLE>

<cfset Src_URL="DD_Scorecard_display.cfm?Show_Status=#URL.Show_Status##URL_Str#">
<!--- For IE 10, "display: table;margin: 0 auto;" is the code for horizontal align center". For IE 9 and below, we need to continue using "align=center" --->
<IFRAME NAME="Show_List" ID="Show_List" SRC="#Src_URL#" scrolling="auto" WIDTH="1250" FRAMEBORDER="0" STYLE="border: 0px none ##000000;display: table;margin: 0 auto;" align="center"></IFRAME>
<!--- <IFRAME NAME="Show_List" ID="Show_List" SRC="#Src_URL#" scrolling="auto" STYLE="border:0px;height:77vh;width:100%;margin:0"></IFRAME> --->
<!--- style="height: expression(document.body.clientHeight-60);"HEIGHT="440"--->
</CFOUTPUT>

<script>
    function moveDiv(){
        document.getElementById('Show_List').style.height = document.body.clientHeight-105;
    }
    moveDiv();

    function load_iframe( url ) {
        let iframe_element = document.getElementById("Show_List");
        if (iframe_element) {
            // empty iframe content
            iframe_element.contentWindow.document.body.innerHTML = '';
            // load new iframe content
            iframe_element.src = url;
        }
    }
</script>
<cfset request.focusHiLightOff = true>
</BODY>
</HTML>