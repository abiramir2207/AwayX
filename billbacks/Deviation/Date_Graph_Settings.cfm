<!------
Date_Graph_Settings.cfm
----->

<!------
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber1">
  <tr>
    <td width="100" bgcolor="red"></td>
    <td width="100" style="border-top-style:solid; border-top-width:8; border-bottom-style:solid; border-bottom-width:8"></td>
    <td width="200" bgcolor="yellow"></td>
  </tr>
</table>
 
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" id="AutoNumber2" width="508">
  <tr>
    <td width="169" bgcolor="red"></td>
    <td width="111" style="border-top-style:solid; border-top-width:8; border-bottom-style:solid; border-bottom-width:8"></td>
    <td width="228" bgcolor="yellow"></td>
  </tr>
</table>
----->

<CFSET INC_Date_Graph_Settings = true>
<CFSET DATE_GRAPH_HEIGHT="7">
<CFSET DATE_GRAPH_BORDER_WIDTH="4">
<CFSET RED_BGCOLOR = "##FF0000">
<CFSET BLUE_BGCOLOR = "##0000FF">
<CFSET BLACK_BGCOLOR = "##000000">
<CFOUTPUT>
<STYLE>
.GRAPHSPAN_FILL
{
	font-size: 1px;
	border: none;
}
.GRAPHSPAN_RED
{
	font-size: 1px;
	background-color:red;
	border-top-color:#RED_BGCOLOR#; 
	border-top-style:solid;
	border-top-width:#DATE_GRAPH_BORDER_WIDTH#; 
	border-bottom-color:#RED_BGCOLOR#;
	border-bottom-style:solid;
	border-bottom-width:#DATE_GRAPH_BORDER_WIDTH#;
}
.GRAPHSPAN_BLUE
{
	font-size: 1px;
	background-color:blue;
	border-top-color:#BLUE_BGCOLOR#; 
	border-top-style:solid;
	border-top-width:#DATE_GRAPH_BORDER_WIDTH#; 
	border-bottom-color:#BLUE_BGCOLOR#;
	border-bottom-style:solid;
	border-bottom-width:#DATE_GRAPH_BORDER_WIDTH#;
}


.GRAPHSPAN_BLACK
{
	font-size: 1px;
	background-color:black;
	border-top-color:#BLACK_BGCOLOR#; 
	border-top-style:solid;
	border-top-width:#DATE_GRAPH_BORDER_WIDTH#; 
	border-bottom-color:#BLACK_BGCOLOR#;
	border-bottom-style:solid;
	border-bottom-width:#DATE_GRAPH_BORDER_WIDTH#;
}
</STYLE>
</CFOUTPUT>
<CFSCRIPT>	
	function addThisDateToDisplay(bar_Image1, bar_Image2, dStart, dEnd, sDesc)
	{
		WriteOutput("<script language=""JavaScript"">");
		//WriteOutput("addDate('#bar_Image1#','#dStart#','#dEnd#','#sDesc#')");
		WriteOutput("addDate('#bar_Image1#','#bar_Image2#','#dStart#','#dEnd#','#sDesc#')");
		WriteOutput("</script>");
	}
</CFSCRIPT>

<CFSET Max_Length=500>

<CFIF ADDSCRIPT EQ "Yes">
<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript">
	
	var Arr_Bar_Image1 = new Array();
	var Arr_Bar_Image2 = new Array();
	var Arr_D_Start = new Array();
	var Arr_D_End = new Array();
	var Arr_Desc = new Array();
	var padHeight = 10;
	
	function addDate(bar_Image1, bar_Image2, dStart, dEnd, sDesc)
	{
		var arrayLen = Arr_Bar_Image1.length;
		Arr_Bar_Image1[arrayLen] = bar_Image1;
		Arr_Bar_Image2[arrayLen] = bar_Image2;
		Arr_D_Start[arrayLen] = dStart;
		Arr_D_End[arrayLen] = dEnd;
		Arr_Desc[arrayLen] = sDesc;
	}
	
	
	
	function showDates()
	{
		var arrayLen = Arr_Bar_Image1.length;
		var i, imgObj, imgObj2, divObj1, divObj2, divObj3;
		var imgRealLeft, imgRealTop;
		var oTable;
		oTable = document.all.Date_Overlap_Table;
		for(i=0;i<arrayLen;i++)
		{
			eval("imgObj = document.all." + Arr_Bar_Image1[i]);
			eval("imgObj2 = document.all." + Arr_Bar_Image2[i]);			
			eval("divObj1 = document.all." + Arr_D_Start[i]);
			eval("divObj2 = document.all." + Arr_D_End[i]);
			eval("divObj3 = document.all." + Arr_Desc[i]);
			
		
			imgRealLeft = imgObj.offsetLeft + imgObj.offsetParent.offsetLeft + oTable.offsetLeft;
			imgRealLeft = parseFloat(getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0));
			imgRealTop = parseFloat(getTotalOffsetProperty(imgObj, "body", "offsetTop", 0));
			
			divObj1.style.left 		= (imgRealLeft - 40) - 10;
			divObj1.style.setExpression("top", "divTop1(\"" + Arr_Bar_Image1[i] + "\", \"" + Arr_Bar_Image2[i] + "\")");
			divObj1.style.display 	= "";
			
			
			divObj3.style.left 		= imgRealLeft;
			divObj3.style.setExpression("top", "divTop3(\"" + Arr_Bar_Image1[i] + "\", \"" + Arr_Bar_Image2[i] + "\")");
			divObj3.style.display 	= "";
			
			
			imgRealLeft = parseFloat(getTotalOffsetProperty(imgObj2, "body", "offsetLeft", 0));
			divObj2.style.left 		= imgRealLeft + parseFloat(imgObj2.width) + 10;
			divObj2.style.setExpression("top", "divTop2(\"" + Arr_Bar_Image1[i] + "\", \"" + Arr_Bar_Image2[i] + "\")");
			divObj2.style.display 	= "";
			
		}
	}
	
	function divLeft1(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		eval("imgObj = document.all." + img1);
		//eval("imgObj2 = document.all." + img2);	
		imgRealLeft = getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0);
		//imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return ((imgRealLeft - 40) - 10);
	}
	
	function divLeft3(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		eval("imgObj = document.all." + img1);
		//eval("imgObj2 = document.all." + img2);	
		imgRealLeft = getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0);
		//imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return imgRealLeft;
	}
	
	function divLeft2(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		//eval("imgObj = document.all." + img1);
		eval("imgObj2 = document.all." + img2);	
		imgRealLeft = getTotalOffsetProperty(imgObj2, "body", "offsetLeft", 0);
		//imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return (imgRealLeft + imgObj2.width + 10);
	}
	
	function divTop1(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		eval("imgObj = document.all." + img1);
		//eval("imgObj2 = document.all." + img2);	
		//imgRealLeft = getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0);
		imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return (imgRealTop - 5);
	}
	
	
	function divTop3(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		eval("imgObj = document.all." + img1);
		//eval("imgObj2 = document.all." + img2);	
		//imgRealLeft = getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0);
		imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return (imgRealTop + #DATE_GRAPH_HEIGHT#);
	}
	
	
	function divTop2(img1, img2)
	{
		var imgObj, imgObj2, imgRealLeft, imgRealTop;
		eval("imgObj = document.all." + img1);
		//eval("imgObj2 = document.all." + img2);	
		//imgRealLeft = getTotalOffsetProperty(imgObj, "body", "offsetLeft", 0);
		imgRealTop = getTotalOffsetProperty(imgObj, "body", "offsetTop", 0);
		return (imgRealTop - 5);
	}
	
	function getTotalOffsetProperty(thisObj, tagName, sProperty, addValues)
	{
		addValues = addValues + eval("thisObj." + sProperty);
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return addValues;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return addValues;
		}
		else
		{
			return getTotalOffsetProperty(thisObj.offsetParent, tagName, sProperty, addValues);
		}
	}
</SCRIPT>
</CFOUTPUT>
</CFIF>

<SCRIPT LANGUAGE="JavaScript">
	function printPage()
	{
		window.print();
	}
</SCRIPT>