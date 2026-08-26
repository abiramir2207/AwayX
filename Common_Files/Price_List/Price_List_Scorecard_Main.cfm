<CFSET PAGE_TITLE="Price List Scorecard">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Scorecard Detail</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfset fore_Color="FFE083">
<cfoutput>
<style>
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Black;
		cursor:				hand;
		BACKGROUND-COLOR: 	FFCE84;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				hand;		
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
   cursor				: hand;	
  }
  TD.headerselected
  {
   border-left			: solid 3px black;
   border-top			: solid 3px black;
   border-right			: solid 3px black;
   background-color 	: #fore_Color#;
   cursor				: hand;	
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

</style>
</cfoutput>
<CFPARAM NAME="FORM.SORT_BY" 	DEFAULT="ID">
<CFPARAM NAME="FORM.SORT_ORDER" 	DEFAULT="ASC">
<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
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
	{
		var aObj 	= getParentObject(event.srcElement,"A");
		var oTable_PriceList = document.all.Table_PriceList;
		var oCells = oTable_PriceList.rows[0].cells;
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
		sc_URL = aObj.href;		
		Sort_It(document.all.Price_List_Table_Headers.rows[0].cells[0]);	
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
	
	function Sort_It(tdObj)
	{
		var Summary_Page_Form = window.Show_List.document.PL_Scorecard;
		if(Summary_Page_Form)
		{
			Summary_Page_Form.SORT_BY.value = sort_By;
			Summary_Page_Form.SORT_ORDER.value = sort_Order;
		
			if(tdObj)
			{
				var spObjs = tdObj.all.SP_SORT;
				var AllSps = document.all.SP_SORT;
				var i;
				for(i=0;i<AllSps.length;i++)
				{
					if(AllSps[i] == spObjs)
					{						
						AllSps[i].all.IMG_SORT.src = "/Images/" + Sort_Img;
						AllSps[i].style.visibility = "visible";
					}
					else
					{
						AllSps[i].style.visibility = "hidden";
					}
				}
			}
			Summary_Page_Form.submit();
		}
	}
</SCRIPT>

<table align="center" width="600" border="0">
	<tr>
	<td align="Left"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></td>
		<td align="Right"><b><font size="2" color="red">[</font> <a href="PL_Search_Tool.cfm"><font size="2">search price list</font></a> <font size="2" color="red">]</font></b></td>
	</tr>
</table>


<br>
<cfparam name="URL.Show_Scorecard" 	default=1>
<cfset Src_URL="Reg_Spc_PL_Scorecard.cfm?Show_Scorecard=1">
<CFIF Get_Profile_Settings.Special_Price_List_Access EQ 1>
<cfset Price_List_Type="Price List,Special Pricing,Incomplete">
<CFELSE>
<cfset Price_List_Type="Price List">
</CFIF>


<cfset i=1>
<cfoutput>
<table border="0" width="500" cellspacing="0" cellpadding="1" ID="Table_PriceList" align="center">
	<tr>
	 <td class="headerblank">&nbsp;</td>
	 <cfloop list="#Price_List_Type#" index="thisIndex">
		<cfif Len(Trim(thisIndex)) GT 0>
		<a ID="#i#" OnClick="javaScript: Change_Tab();" class="tablink_back" href="Reg_Spc_PL_Scorecard.cfm?Show_Scorecard=#i#" target="Show_List">
		<td width="120" 
		<cfif URL.Show_Scorecard EQ i>
			class="headerselected" 		
		<cfelse>
			class="headernotselected" 
		</cfif>
		 align="center" nowrap ID="PL_Type">
		<b>			
		<a ID="#i#" class="tablink_back" href="Reg_Spc_PL_Scorecard.cfm?Show_Scorecard=#i#" target="Show_List">
		<nobr>#LCase(thisIndex)#</nobr></a></b></td></a>
		<cfif (i-1) lt Len(Price_List_Type)>
		<td class="headerspacer"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>
		</cfif>
	</cfif>
<cfset i=i+1>
</cfloop>
<td class="headerspacer" width="100%"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></td>
<!------
<TD WIDTH="90%" CLASS="remaining">&nbsp;</TD>
----->
	</tr>
</table>	 
<table border="0" width="500" cellspacing="0" callpadding="3" align="center" ID="Price_List_Table_Headers">
	<tr bgcolor=#fore_Color#>
		<CFSET Header_Name_List = "&nbsp;&nbsp;PRICE LIST,DESCRIPTION"><!--- ,ACTIVE DATE --->
		<CFSET Header_Value_List = "ID,DESCRIPTION"><!--- ,DATE --->
		<CFSET Header_Width_List = "100,370,100">
		<CFSET Counter = 1>
		<CFLOOP LIST="#Header_Name_List#" INDEX="This_Header" DELIMITERS=",">
			<CFSET This_Width = ListGetAt(Header_Width_List, Counter, ",")>
			<CFSET This_Sort_By = ListGetAt(Header_Value_List, Counter, ",")>
			<CFSET Show_Sort_Img = false>
			<CFIF FORM.SORT_BY EQ This_Sort_By>
				<CFSET Show_Sort_Img = true>
			</CFIF>
			<td width="#This_Width#" onClick="javaScript: Set_Sort_By('#This_Sort_By#');" STYLE="cursor:hand;">
			<CFIF This_Header NEQ "ACTIVE DATE">
			<A HREF="void(0);" ONCLICK="return false;"><b>#This_Header#</b></A>
			<CFELSE>
			<b>#This_Header#</b>
			</CFIF>
			<SPAN ID="SP_SORT"<CFIF NOT Show_Sort_Img> STYLE="VISIBILITY:hidden;"</CFIF>><IMG ID="IMG_SORT" SRC="/Images/down_1.gif"></SPAN>
			</td>
			<CFSET Counter = Counter + 1>
		</CFLOOP>
	</tr>
</table>
</cfoutput>	 


<cfoutput>
<IFRAME NAME="Show_List" SRC="#Src_URL#" WIDTH="500" HEIGHT="395" FRAMEBORDER="0" align="center" style="border: 0px none ##000000;"></IFRAME>
</cfoutput>

<blockquote><blockquote>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</blockquote></blockquote>

</BODY>
</HTML>
