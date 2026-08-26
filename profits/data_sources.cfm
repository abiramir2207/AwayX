<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="3" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0" STYLE="border: 1px solid #D3D3D3;">


<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>


<CFFLUSH>


<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Code that makes the color of the row change with the mouse over it							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT language="JavaScript">
	function CellOn(CellName)
		{
			eval("CellName.bgColor = 'EEEEEE'")
		}

	function CellOff(CellName)
		{
			eval("CellName.bgColor = 'FFFFFF'")
		}
	function showProfile(ID){
		NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=' + ID,'name','400','450','Yes', 'No');	
	}
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Check for a valid selection --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<script language="JavaScript">
	<!--BEGIN Script
		function checkData (){
		      if (document.MyForm.Data_Sources.value == "") {
		          alert("Please select a specific report or commodity...")
		          document.MyForm.Data_Sources.focus()
		          return false}
		}
	// -->
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<style>
	Option.highlight
		{
			height: 30px;
			background-color: 	Yellow;
		}
</style>





<CFIF Get_Profile_Settings.Commodity_Price_Rule_View EQ 0>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Open layer Options																			 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSCRIPT>
		Border="No";
		BorderSize=1;  
		BorderColor="orange";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Navy"; 
		TitleFont="Arial";
		TitleSize=8;
		IsClosed="Yes";  
		Width="100%";
	</CFSCRIPT>
<CFELSE>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Open layer Options																			 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSCRIPT>
		Border="No";
		BorderSize=1;  
		BorderColor="orange";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Navy"; 
		TitleFont="Arial";
		TitleSize=8;
		IsClosed="Yes";  
		Width="100%";
	</CFSCRIPT>
</CFIF>



<SCRIPT language="JavaScript">
function propogateClickToOpenLayer(thisObj)
{
	return;
	var framesetObj = thisObj.getElementsByTagName("fieldset");
	if(framesetObj)
	{
		if(framesetObj.length)
		{
			//framesetObj[0].click();
			propogateClickToTitleSpan(framesetObj[0]);
		}
		else
		{
			//framesetObj.click();
			propogateClickToTitleSpan(framesetObj);
		}
	}
}
function propogateClickToTitleSpan(framesetObj)
{
	var frameID = framesetObj.id;
	if(frameID)
	{
		var ArID = frameID.split("_");
		if(ArID.length > 1)
		{
			var spObj = document.getElementById("title_" + ArID[1]);
			if(spObj.length)
			{
				
			}
			else
			{
				spObj.click();
			}			
		}
	}
}

function Expand_Collapse(aObj)
{
	var aObjText = aObj.innerText;
	var testVal = "expand";
	if(aObjText.indexOf(testVal) >= 0)
	{
		AllOpenLayers(1);
		aObj.innerText = "collapse all";
	}
	else
	{
		AllOpenLayers(0);
		aObj.innerText = "expand all";
	}
	return false;
}
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/Billbacks/Deviation/common_js.js"></SCRIPT>


<CFSET Window_Width = 800>
<CFSET Window_Height = 550>
<BR>
&nbsp;&nbsp;<B><FONT COLOR="FF0000">[</FONT><a HREF="void(0);" onClick="javaScript: return Expand_Collapse(this);">expand all</a><FONT COLOR="FF0000">]</FONT></B>
<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="100%" BORDER="0">
<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="CME Commodity Data"  
	TitleClosed="CME Commodity Data"  
	TitleTooltip="Click here to collapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=db&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Butter (DB)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=c5&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Butter Grade AA (C5)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=c4&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Cheese  Block (C4)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=c3&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Cheese  Barrel (C3)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=c1&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Milk Grade Extra (C1)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=c2&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Milk Grade A (C2)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=dk&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Class IV Milk Futures (DK)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=da&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">CME Milk (DA)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=fc&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Feeder Cattle (FC)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=lh&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Lean Hogs (LH)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=lc&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Live Cattle (LC)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=pb&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Pork Bellies (PB)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="CBOT Commodity Data"  
	TitleClosed="CBOT Commodity Data"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=c&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Corn (C)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=zc&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Corn E (ZC)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=o&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Oats (O)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=zo&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Oats E (ZO)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=w&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Wheat (W)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=zw&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Wheat E (ZW)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=s&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Soybeans (S)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=bo&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Soybean Oil (BO)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=sm&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Soybean Meal (SM)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=rr&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Rough Rice (RR)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Coffee Sugar Cocoa Exchange"  
	TitleClosed="Coffee Sugar Cocoa Exchange"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=sb&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Sugar ##11 (SB)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=se&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Sugar ##14 (SE)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=kc&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Coffee C (KC)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=cm&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Columbian Milds (KCY0)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=bz&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">ICA Brazilian (MKY0)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Kansas City Board of Trade"  
	TitleClosed="Kansas City Board of Trade"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=kw&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Wheat (KW)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=mv&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Value Line Futures (MV)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=is&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">ISDEX Index (IS)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="MidAmerica Commodity Exchange "  
	TitleClosed="MidAmerica Commodity Exchange "  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=xc&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">MidAm Corn (XC)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=xw&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">MidAm Wheat (XW)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=xs&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">MidAm Soybeans (XS)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Minneapolis Grain Exchange"  
	TitleClosed="Minneapolis Grain Exchange"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<CFOUTPUT><DIV STYLE="margin-left: 12px;">
		   <A HREF="view_commodity_chart.cfm?Symbol=mw&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">Spring Wheat (MW)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=iz&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">NSI Futures (IZ)</A><BR>
		   <A HREF="view_commodity_chart.cfm?Symbol=ic&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">NCI Futures (IC)</A><BR>
		</DIV></CFOUTPUT>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- <TR><TD BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD></TR> --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!------
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Urner Barry - Beef"  
	TitleClosed="Urner Barry - Beef"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<DIV STYLE="margin-left: 12px;">

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Beef Varieties - USDA"  
				TitleClosed="Beef Varieties - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB322&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Cheek Meat, trmd, 70-75% lean</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB324&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Head Meat, 60-70% lean</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB325&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Hearts, regular, bone out</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB327&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Lips, unscalded</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB328&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Livers, selected, 2/box</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB329&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Livers, selected, 2/box, export</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB333&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Trepas</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB334&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Variety Meats, Tripe, scalded, edible</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB336&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Gullets-Trachea, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB337&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Kidneys, Inedible, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB338&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Livers, Inedible, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB339&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Lungs, Inedible, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB340&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Melts, Inedible, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB341&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Salivary Glands, Fresh (Pet Food)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB342&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Salivary Glands, Boxed Frozen (Pet Food)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boneless Proc/Trim - USDA"  
				TitleClosed="Boneless Proc/Trim - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
						   <A HREF="view_commodity_chart.cfm?Symbol=UB319&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Beef Trimmings, National, Steer & Heifer Source, Fresh 50%</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boneless Proc/Trim - YS"  
				TitleClosed="Boneless Proc/Trim - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1201&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Beef Trimmings, 81% Fresh Chemical Lean FOB River-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1202&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Beef Trimmings, 81% Fresh Chemical Lean FOB River-(LTL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Brisket - USDA"  
				TitleClosed="Boxed Beef Brisket - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB393&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 120 1 Brisket, deckle-off, bnls Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB425&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 120 1 Brisket, deckle-off, bnls Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB774&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 120A 3 Brisket, point/off, bnls Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB789&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 120A 3 Brisket, point/off, bnls Select</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Brisket - YS"  
				TitleClosed="Boxed Beef Brisket - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1826&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1861&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2365&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2366&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3352&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3353&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3354&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3400&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3401&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3402&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB468&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB469&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB470&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB471&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 3 Brisket, Deckle-Off, Boneless Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB472&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB473&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB474&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB475&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120A 3 Brisket, Flat-Cut, Boneless Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB638&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB639&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 120 1 Brisket, Deckle-Off, Boneless Select-(TL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Chuck - USDA"  
				TitleClosed="Boxed Beef Chuck - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2168&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 113C 1 Chuck, semi-bnls, neck/off Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2172&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116B 1 Chuck, chuck tender Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2667&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116B 1 Chuck, chuck tender Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB378&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 113A 1 Chuck, square-cut, 2 piece Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB380&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 115 1 Chuck, 2-piece, boneless Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB382&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 114 1 Chuck, shoulder clod Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB392&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116C 1 Chuck, chuck roll Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB420&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 113A 1 Chuck, square-cut, 2 piece Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB421&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 113C 1 Chuck, semi-bnls, neck/off Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB422&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 115 1 Chuck, 2-piece, boneless Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB423&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 114 1 Chuck, shoulder clod Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB424&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116C 1 Chuck, chuck roll Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB771&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116A 3  Chuck, roll, lxl, neck/off Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB773&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 114A 3  Chuck, shoulder clod, trmd Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB786&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 116A 3  Chuck, roll, lxl, neck/off Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB788&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 114A 3  Chuck, shoulder clod, trmd Select</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Chuck - YS"  
				TitleClosed="Boxed Beef Chuck - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1817&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1818&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, Chuck Tender Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1819&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1820&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1821&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1822&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1823&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1824&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, Chuck Tender Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1825&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1852&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1853&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1854&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1855&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1856&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1857&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1858&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, ChuckTender Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1859&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, Chuck Tender Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1860&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2359&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2360&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2361&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2362&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2363&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, Chuck Tender CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2364&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3342&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3343&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3344&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3345&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3346&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3347&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3348&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3349&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3350&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, ChuckTender No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3351&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3390&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3391&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3392&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3393&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3394&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3395&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3396&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 3 Chuck, Square-Cut, Neck-Off, Semi-Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3397&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3398&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116B 1 Chuck, ChuckTender No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3399&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB456&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB457&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB458&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB459&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114A 3 Chuck, Shoulder Clod, Roast Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB460&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB461&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB462&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB463&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114B 3 Chuck, Shoulder Clod, Roast, Special Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB464&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB465&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB466&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB467&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116A 3 Chuck, Chuck Roll, Neck-Off Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB628&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB629&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 113A 1 Chuck, Square-Cut, Divided B-I Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB630&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB631&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 114 1 Chuck, Shoulder Clod Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB632&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB633&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115 1 Chuck, Square-Cut, 2-Piece, Bnls Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB634&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB635&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 115C 1 Chuck, Square-Cut, Neck-Off, Semi-Bnls Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB636&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB637&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 116C 1 Chuck, Chuck Roll Select-(TL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Loin - USDA"  
				TitleClosed="Boxed Beef Loin - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2177&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 184E 3 Loin, Top Butt, 2 pc. Bnls Choice</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Loin - USDA"  
				TitleClosed="Boxed Beef Loin - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB389&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 174 1 Loin, short loin, 2x3 Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB399&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 180 1 Loin, strip, bnls, heavy Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB400&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA --- 1 Loin, Strip Loin Bnls. 1x1 Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB402&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 184 1 Loin, top butt, bnls, heavy Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB413&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 189A 4 Loin, tndrloin, trmd, heavy Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB436&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 174 1 Loin, short loin, 2x3 Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB748&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 180 1 Loin, strip, bnls, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB749&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA --- 1 Loin, Strip Loin Bnls. 1x1 Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB752&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 184 1 Loin, top butt, bnls, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB762&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 189A 4 Loin, tndrloin, trmd, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB780&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 184 3 Loin, top butt, boneless Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB782&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 191A 4 Loin, butt tender, trimmed Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB783&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 175 3 Loin, strip loin, 1x1 Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB784&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 180 3 Loin, strip, bnls, 0x1 Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB785&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 174 3 Loin, short loin, 0x1 Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB796&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 184 3 Loin, top butt, boneless Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB798&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 191A 4 Loin, butt tender, trimmed Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB799&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 175 3 Loin, strip loin, 1x1 Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB800&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 180 3 Loin, strip, bnls, 0x1 Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB801&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 174 3 Loin, short loin, 0x1 Select</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Loin - YS"  
				TitleClosed="Boxed Beef Loin - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1838&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1839&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1840&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1841&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1842&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1843&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1873&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1874&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1875&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1876&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1877&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1878&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1879&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1880&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2378&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2379&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2380&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2381&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2382&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2383&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2384&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2385&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2386&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2387&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2388&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Peeled CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2389&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2395&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2396&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3369&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3370&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3371&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3372&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3373&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3374&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3375&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3376&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3377&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3378&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3379&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3380&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3382&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3417&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3418&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3419&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3420&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3421&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3422&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3423&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3424&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3425&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3426&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3427&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3428&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3430&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3436&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3437&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB447&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB448&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB449&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Up Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB450&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 189A 4 Loin, Tenderloin, PSMO, Defat Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB453&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB496&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB497&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB498&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB499&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 1x1 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB500&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB670&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB671&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 1 Loin, Short Loin, Short-Cut, 2x3 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB672&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB673&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 1 Loin, Strip Loin, Bone-In, 4x6 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB674&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB675&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Dn Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB678&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB679&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 2x3 Up Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB681&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB682&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 1 Loin, Strip Loin, Bnls, 1x1 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB683&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB684&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Dn Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB685&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB686&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 1 Loin, Top Sirloin Butt, Bnls Up Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB692&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB693&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB694&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 174 3 Loin, Short Loin, Short-Cut, 0x1 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB695&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB696&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB697&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB698&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 175 3 Loin, Strip Loin, Bone-In, 1x1 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB699&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB700&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB701&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 180 3 Loin, Strip Loin, Bnls, 0x1 Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB702&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB703&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB704&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB705&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB708&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Peeled Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB709&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 184 3 Loin, Top Sirloin Butt, Peeled Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB710&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB711&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB712&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB713&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 191A 4 Loin, Tenderloin Butt, Defatted Choice-(LTL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Rib - USDA"  
				TitleClosed="Boxed Beef Rib - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB376&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 109E 1  Rib, ribeye, lip-on, bn-in Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB377&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 112A 3  Rib, ribeye, bnls, heavy Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB381&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 112A 3  Rib, ribeye, bnls, light Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB416&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 109A 1  Rib, roast-ready, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB417&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 109E 1  Rib, ribeye, lip-on, bn-in Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB418&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 112A 3  Rib, ribeye, bnls, light Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB419&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 112A 3  Rib, ribeye, bnls, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB747&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 109A 1  Rib, roast-ready, heavy Choice</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Rib - YS"  
				TitleClosed="Boxed Beef Rib - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1104&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1105&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1106&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1107&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1809&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1810&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1811&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1812&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1813&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1814&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1815&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1816&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1844&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1845&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1846&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1847&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1848&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1849&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1850&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1851&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2353&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2354&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2355&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone In Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2356&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone In Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2357&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2358&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3335&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3336&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3337&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3338&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3339&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3340&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3341&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3383&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 107 1 Rib, Oven Prepared No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3384&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3385&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3386&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3387&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3388&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3389&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB620&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB621&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109A 1 Rib, Roast Ready Up Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB622&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109E 1 Rib, Ribeye Roll, Lip-On, Bone-In Up Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB623&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB624&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Dn Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB625&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB626&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up Choice (LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB627&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 112A 3 Rib, Ribeye Roll, Lip-On Up Select-(TL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Round - USDA"  
				TitleClosed="Boxed Beef Round - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2174&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA --- 3 Round, bnls/peeled heel-out Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2175&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 171B 3  Round, outside round Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2176&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA171C 3  Round, eye of round Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2669&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA --- 3 Round, bnls/peeled heel-out Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2670&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 171B 3  Round, outside round Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2671&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA171C 3  Round, eye of round Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB384&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 160 1 Round, bone-in Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB385&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 161 1 Round, boneless Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB386&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 167 1 Round, knuckle, peeled Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB394&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 167 1 Round, knuckle Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB395&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 168 1 Round, top inside round Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB396&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 170 1 Round, bottom gooseneck Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB427&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 160 1 Round, bone-in Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB428&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 161 1 Round, boneless Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB429&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 167 1 Round, knuckle Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB430&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 167 1 Round, knuckle, peeled Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB431&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 168 1 Round, top inside round Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB432&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 170 1 Round, bottom gooseneck Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB776&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 168 3 Round, top inside round Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB778&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 169 5 Round, top inside, denuded Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB791&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 168 3 Round, top inside round Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB793&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 169 5 Round, top inside, denuded Select</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef Round - YS"  
				TitleClosed="Boxed Beef Round - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1827&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1828&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1829&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1830&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1831&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1832&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1833&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1834&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1835&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1836&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1837&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1862&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1863&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1864&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1865&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1866&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1867&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1868&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1869&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1870&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1871&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1872&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2367&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 1 Steamship Round CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2368&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2369&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2370&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2371&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2372&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2373&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2374&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2375&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2376&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2377&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS --- 3 Flat/Eye Combo CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2501&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round Choice-(21:30)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2551&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) Select-(11:20)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3355&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3356&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3357&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3358&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3359&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3360&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3361&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3362&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3363&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3364&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3365&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3366&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3367&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3368&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round No-Roll-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3403&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3404&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 3 Round, S-O, Part Bnls w/Pld Knuckle No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3405&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3406&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3407&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3408&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3409&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3410&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3411&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3412&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169A 5 Inside Round, Cap-Off No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3413&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3414&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3415&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3416&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB476&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB477&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB478&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB479&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161B 3 Round, S-O, Bnls, w/Pld Knuck, H-O Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB480&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB481&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB482&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB483&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 3 Round, Top (Inside) Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB484&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB485&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB486&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB487&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 169 5 Round, Top (Inside), Denuded Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB489&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB491&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB492&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB493&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB494&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB495&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171C 3 Round, Eye of Round Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB642&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB643&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 160 1 Round, Shank-Off, Partially Bnls Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB644&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB645&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 161 1 Round, Shank-Off, Boneless Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB646&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB647&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167 1 Round, Knuckle Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB648&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB649&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 167A 4 Round, Knuckle, Peeled Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB650&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB651&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 168 1 Round, Top (Inside), Untrimmed Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB652&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB653&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170 1 Round, Bottom (Gooseneck) Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB654&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB655&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 170A 3 Round, Bottom (Gooseneck), Heel-Out Select-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB666&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round Choice-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB667&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 171B 3 Round, Outside Round Select-(TL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef-Thin Meats/Grinds - USDA"  
				TitleClosed="Boxed Beef-Thin Meats/Grinds - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2173&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 130 4 Chuck, short rib Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2178&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 193 4 Flank, flank steak Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2668&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 130 4 Chuck, short rib Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2673&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pectoral Meat Choice & Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2674&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground 75% Steer & Heifer Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2677&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground 93% Steer & Heifer Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2678&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground Chuck Steer & Heifer Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2679&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground Round Steer & Heifer Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2681&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground blend 73% Steer, Heifer & Cow Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2683&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground blend 81% Steer, Heifer & Cow Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2684&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground blend 85% Steer, Heifer & Cow Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2687&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground blend Chuck Steer, Heifer & Cow Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2688&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground blend Round Steer, Heifer & Cow Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB404&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 123A 3 Short Plate, short rib Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB405&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185A 4 Loin, bottom sirloin, flap Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB406&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185B 1 Loin, ball-tip, bnls, light Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB407&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185B 1 Loin, ball-tip, bnls, heavy Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB408&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185C 1 Loin, sirloin, tri-tip Choice</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB754&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 123A 3 Short Plate, short rib Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB755&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185A 4 Loin, bottom sirloin, flap Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB757&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185B 1 Loin, ball-tip, bnls, heavy Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB758&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 185C 1 Loin, sirloin, tri-tip Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB763&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 193 4 Flank, flank steak Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB764&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 124 4 Rib, Back Ribs, Fresh Choice & Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB765&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 124 4 Rib, Back Ribs, Frozen Choice & Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB767&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Cap and Wedge Meat Choice & Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB768&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA 121D 4 Plate, Inside Skirt Choice & Select</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB769&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground 81% Steer & Heifer Source</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB770&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Coarse ground 73% Steer & Heifer Source</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Boxed Beef-Thin Meats/Grinds - YS"  
				TitleClosed="Boxed Beef-Thin Meats/Grinds - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1883&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 121C 4 Plate, Outside Skirt CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1884&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 121D 4 Plate, Inside Skirt CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1885&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 123A 3 Short Ribs, Trimmed CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1886&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 123A 3 Short Ribs, Trimmed CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1887&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 124 4 Rib, Back Rib (Frozen) CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1888&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Cap & Wedge Meat (Special Trim) CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1889&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Pectoral Meat CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1890&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Pectoral Meat CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1891&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 73% CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1894&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 81% CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1895&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 81% CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1900&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 93% CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1901&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 93% CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1902&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Chuck CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1903&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Chuck CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1904&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Round CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1905&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Round CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2390&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185A 4 Loin, Bot Si. Butt, Flap, Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2392&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Up CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2393&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 1 Loin, Bot Sir Butt, Tri-Tip, Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2394&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 5 Loin, Bot Sir Butt, Tri-Tip, Bnls CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2397&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 193 4 Flank, Flank Steak CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2398&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 109B Rib Lifter Meat (Blade Meat) CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2399&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 121C 4 Plate, Outside Skirt CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2400&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 121D 4 Plate, Inside Skirt CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2401&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 124 4 Rib, Back Rib (Frozen) CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2402&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Cap & Wedge Meat (Special Trim) CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2403&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Pectoral Meat CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2405&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 81% CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2407&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Chuck CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2408&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Round CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2409&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Sirloin CAB</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3329&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185D 3 Loin, Bot Sir Butt, Tri-Tip, Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3332&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185D 3 Loin, Bot Sir Butt, Tri-Tip, Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3431&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185A 4 Loin, Bot Sir Butt, Flap, Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3432&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Dn No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3433&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Up No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3434&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 1 Loin, Bot Sir Butt, Tri-Tip, Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3435&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 5 Loin, Bot Sir Butt, Tri-Tip, Bnls No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3438&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 193 4 Flank, Flank Steak No-Roll-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3439&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Sirloin CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3440&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 137 Coarse Ground Sirloin CH, SE or NR-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB440&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Up Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB441&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 1 Loin, Bot Sir Butt, Tri-Tip, Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB442&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185C 1 Loin, Bot Sir Butt, Tri-Tip, Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB451&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 193 4 Flank, Flank Steak Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB452&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 193 4 Flank, Flank Steak Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB454&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Cap & Wedge Meat (Special Trim) CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB455&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 136 Coarse Ground 73% CH, SE or NR-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB687&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185A 4 Loin, Bot Sir Butt, Flap, Bnls Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB688&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185A 4 Loin, Bot Sir Butt, Flap, Bnls Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB689&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Dn Choice-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB690&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Dn Select-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB691&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS 185B 1 Loin, Bot Sir Butt, Ball-Tip, Bnls Up Choice-(LTL)</A><BR>
					</DIV>
			</CF_openLayer>
	
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Imported Beef"  
				TitleClosed="Imported Beef"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3555&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Imported Aust/NZ Imported Blend Cow 90% EC Spot</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3556&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Imported Aust/NZ Imported Blend Cow 90% EC 7:45</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3557&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Imported Aust/NZ Imported Blend Cow 90% WC Spot</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3558&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Imported Aust/NZ Imported Blend Cow 90% WC 7:45</A><BR>
					</DIV>
			</CF_openLayer>
	

		</DIV>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->







<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Urner Barry - Chicken"  
	TitleClosed="Urner Barry - Chicken"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<DIV STYLE="margin-left: 12px;">

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Frozen Parts - East Coast"  
				TitleClosed="Frozen Parts - East Coast"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1240&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB EC Frozen Bnls/Sknls White Trim Meat, Under 15%</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Frozen Parts - Gulf Ports"  
				TitleClosed="Frozen Parts - Gulf Ports"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1242&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB GP Frozen Bnls/Sknls White Trim Meat, Under 15%</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Frozen Parts - West Coast"  
				TitleClosed="Frozen Parts - West Coast"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1243&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB WC Frozen Bnls/Sknls White Trim Meat, Under 15%</A><BR>
					</DIV>
			</CF_openLayer>

		</DIV>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Urner Barry - Eggs"  
	TitleClosed="Urner Barry - Eggs"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<DIV STYLE="margin-left: 12px;">

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Frozen Egg Products - Institutional"  
				TitleClosed="Frozen Egg Products - Institutional"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB52&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Institutional Packs, Frozen Whole Eggs-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB53&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Institutional Packs, Frozen Whites-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB54&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Institutional Packs, Frozen Yolk, Sugar-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB55&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Institutional Packs, Frozen Blend, 30-32% Solids-(LTL)</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Frozen Egg Products - Truckloads"  
				TitleClosed="Frozen Egg Products - Truckloads"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB35&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Whole Egg, No Color</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB36&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Whites</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB37&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Yolk Sugar, 43% Solids</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB38&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Yolk Salt, 43% Solids</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB39&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Blend 30-32%</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB40&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen Blend 27-29%</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Liquid Egg Products - Tanker"  
				TitleClosed="Liquid Egg Products - Tanker"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB45&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Unpasteurized, Whole</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB46&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Pasteurized, Whole</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB47&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Unpasteurized, Whites</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB48&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Pasteurized, Whites</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB49&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Unpasteurized, Yolk 43% Solids</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB50&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Pasteurized, Yolk 43% Solids</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB51&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Yolk, Salt 43% Solids, 10% Salt</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Liquid Egg Products - Truckloads"  
				TitleClosed="Liquid Egg Products - Truckloads"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1149&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid in Portable Containers, Whole-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1150&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid in Portable Containers, Whole-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1154&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid in Portable Containers, Sugar Yolk-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1155&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid in Portable Containers, Salt Yolk-(LTL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1156&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid in Portable Containers, Salt Yolk-(TL)</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Solid Egg Products - Truckloads"  
				TitleClosed="Solid Egg Products - Truckloads"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB41&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Egg Solids, Dried Whole Plain</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB42&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Egg Solids, Dried Yolk</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB43&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Egg Solids, Spray Albumen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB44&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Egg Solids, Dried Blend, 65-75% Whole</A><BR>
					</DIV>
			</CF_openLayer>
			
			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="West Coast Egg - Products"  
				TitleClosed="West Coast Egg - Products"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB15&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen, Whole Eggs, California-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB16&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen, Whites, California-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB17&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen, Salt Yolk, California-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB18&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Frozen, Sugar Yolk, California-(TL)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2133&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Unpasteurized Whites, West Coast</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2134&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Liquid Eggs, Pasteurized Whites, West Coast</A><BR>
					</DIV>
			</CF_openLayer>

		</DIV>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->







<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Urner Barry - Pork"  
	TitleClosed="Urner Barry - Pork"  
	TitleTooltip="Click here to colapse selections"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#">
		<DIV STYLE="margin-left: 12px;">

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Pork Cuts - USDA"  
				TitleClosed="Pork Cuts - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1145&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Picnics, Picnic Cushion Meat, Combo 92% Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2883&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, 1/8 in. Trm/less 21#/DN-LGT, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2886&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Center Cut,10-11 Rib,1/4 in.Trim, Tender-in FLO  8-13#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2888&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Center Cut,10-11 Rib,1/4 in.Trim, Bnls Strap-off 5-11#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2890&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Bone-In Sirloin 2.5-3.5#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2891&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Blade Ends 2-4#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2897&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Picnics, Smkr Trm, SS, Combo</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2898&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Picnics, Smkr Trm, SS, Boxed</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2904&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Boston Butts, 1/4 in. Trim Stk Rdy, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2905&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Boston Butts, 1/8 in. Trim Stk Rdy, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2906&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Boston Butts, Boneless Butt</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2908&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Spareribs, 3 BAG/3 PCVAC 4.25#/DN-LG, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2909&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Spareribs, 2 BAG/3 PCVAC 4.25#/UP-MED</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2910&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Spareribs, Combos, 4.25#/DN-LGT, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2912&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Bone-In 17-20# Trim Spec 1, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2913&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Bone-In 20-23# Trim Spec 1, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2914&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Bone-In 23-27# Trim Spec 1, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2918&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Boneless 5 Muscle Hams FL4 94-96%, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2921&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Knuckle</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2924&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Ham Trimmings, Combo 72% Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2925&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Hams, Ham Trimmings, Boxed 72% Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2930&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Bellies, Skin-On, Trimmed 12-14#, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2932&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Bellies, Skin-On, Trimmed 16-18#, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB310&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, 1/4 in. Trim 21#/DN-LGT, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB313&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, 1/4 in. Trim 21#/UP-MED</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB314&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Combos 26/Up# (SOW)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB4346&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Loin Back Rib (Boxed), FRESH 2.00UP#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB4348&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Loin Back Rib (Boxed), FRZN 1.75/DN#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB4349&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Loin Back Rib (Boxed), FRZN 1.75/2.00DN#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB4350&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Loin Back Rib (Boxed), FRZN 2.00/UP#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB865&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Loins, Tenderloin 1.25/Dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB867&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Boston Butts, 1/4 in. Trim 5-10#, Total on FOB Basis</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB886&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Bellies, Skin-On, Trimmed 10-12</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB889&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Bellies, Skin-On, Trimmed 18-20#</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB901&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Picnics, Smkr Trm, RS, Combo</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Pork Cuts - YS"  
				TitleClosed="Pork Cuts - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1238&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Select Hams 20/23 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1239&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Select Hams 23/27 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1519&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Reg. Pork Loins 19/dn (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1520&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Reg. Pork Loins 19/23 (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1522&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Trimmed Pork Loins 19/dn (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1523&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Trimmed Pork Loins 19/23 (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1524&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Bnls. Center Cut Pork Loins, Strap On</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1525&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Bnls. Center Cut Pork Loins, Strap On (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1526&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Bnls. Center Cut Pork Loins, Strap Off</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1527&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Bnls. Center Cut Pork Loins, Strap Off (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1528&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Pork Tenderloin 1.25/dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1530&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Pork, Reg. Boston Butts 9/dn (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1532&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">YS Pork, Tr. Boston Butts 9/dn (LTL) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1546&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Trimd. Picnics 4/8, ss (combo)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2183&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  1/8 in. Trmd. Loins 21/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2189&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Trmd. Picnics 4/8, ss (boxed) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2190&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Bnls Pic Cushion, Fresh (boxed) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2193&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  1/4 in. Tr. Neck-Off Butts 9/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2196&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  1/8 in. Tr. Steak Ready Butts 9/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2204&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">RETAIL PORK CUTS (LTL)  1/8 in. Trmd. Loins 21/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2213&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">RETAIL PORK CUTS (LTL)  1/4 in. Tr. Neck-Off Butts 9/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2216&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">RETAIL PORK CUTS (LTL)  1/8 in. Tr. Steak Ready Butts 9/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2218&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  St. Louis Ribs 2.00/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2219&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  St. Louis Ribs 2.25/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2220&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  St. Louis Ribs 2.50/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2221&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  St. Louis Ribs 2.50/up *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2222&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  72% Ground Pork *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2223&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  81% Ground Pork *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB2241&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">RETAIL PORK CUTS (8:14)  1/4 in. Tr. Boston Butts 9/dn *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB251&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Trimd. Picnics 4/8, rs (combo)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB252&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Sq. Cut Bellies 10/12 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB253&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Sq. Cut Bellies 12/14 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB254&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Sq. Cut Bellies 14/16 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB255&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Sq. Cut Bellies 16/18 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB256&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Sq. Cut Bellies 18/20 (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB258&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Reg. Loins 21/dn (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB259&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Reg. Loins 21/up (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB260&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Reg. Loins 23/up</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB262&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  1/4 in. Trmd. Loins 21/dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB263&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  1/4 in. Trmd. Loins 21/up</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB265&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Loin Back Ribs 1.50/dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB266&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Reg. Boston Butts 9/dn (BP)</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB267&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Loin Back Ribs 2/dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB269&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Loin Back Ribs 2/up</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB270&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL) 1/4 in. Tr Boston Butts 9/dn</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB277&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Loin Back Ribs 1.75/up</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3805&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Spareribs, Light, Fresh (Vacpak) </A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3806&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (TL)  Spareribs, Medium, Fresh (Vacpak) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3807&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Spareribs, Light, Fresh (Vacpak) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3808&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Retail Pork Cuts (LTL)  Spareribs, Medium, Fresh (Vacpak) *</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB862&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Processing Items (TL)  Select Hams 17/20 (BP)</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Pork Varieties - USDA"  
				TitleClosed="Pork Varieties - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB907&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Variety Meats - Frozen Neck Bones</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB908&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Variety Meats - Frozen Tails</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB915&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Variety Meats - Frozen Hearts, Slashed, Domestic</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB916&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Variety Meats - Frozen Hocks, Picnic</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB918&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Variety Meats - Frozen Salivary Glands</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Sausage Material - USDA"  
				TitleClosed="Sausage Material - USDA"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3689&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Combo 42%  Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3690&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Combo 72% Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3691&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Bnls Picnic 72% Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3692&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Sknd Jowls, Combo, Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB894&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Boxed 42%  Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB896&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Boxed 72%  Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB898&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">USDA Pork Trimmings, Bnls Picnic Boxed 72% Frozen</A><BR>
					</DIV>
			</CF_openLayer>

			<CF_openLayer
				Border="#Border#"
				BorderSize="#BorderSize#"  
				BorderColor="#BorderColor#"  
				Image="#Image#"
				ImageOpen="#ImageOpen#"
				Title="Sausage Material - YS"  
				TitleClosed="Sausage Material - YS"  
				TitleTooltip="Click here to colapse selections"  
				TitleColor="#TitleColor#"  
				TitleFont="#TitleFont#"
				TitleSize="#TitleSize#"
				IsClosed="#IsClosed#"
				Width="#width#">
					<DIV STYLE="margin-left: 12px;">
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1558&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Ham Trim (72%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB1572&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Fat w/Trace Lean Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB285&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Boneless Picnic Cushion (92%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB286&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Boneless Picnic Cushion (92%) Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB290&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Trim (42%) Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB291&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Trim (72%) Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB292&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Boneless Picnic (72%) Frozen</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3792&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Trim (42%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3793&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Trim (72%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3794&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Boneless Picnic (72%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3795&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (TL)  Skinned Jowls Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3796&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (LTL)  Trim (42%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3797&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">SAUSAGE MATERIALS (LTL)  Trim (72%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3798&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (LTL)  Bnls. Pics. (72%) Fresh</A><BR>
					   <A HREF="view_commodity_chart.cfm?Symbol=UB3799&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">Pork Sausage Materials (LTL)  Skinned Jowls Fresh</A><BR>
					</DIV>
			</CF_openLayer>
			
		</DIV>
</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->










<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---											 TURKEY												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="Urner Barry - Turkey"  
			TitleClosed="Urner Barry - Turkey"  
			TitleTooltip="Click here to colapse selections"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
				<DIV STYLE="margin-left: 12px;">
		
					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Canner Packed Turkeys - Midwestern Area"  
						TitleClosed="Canner Packed Turkeys - Midwestern Area"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB581&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Canner Packed, Midwest, Fresh Line Run 17-20</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB582&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Canner Packed, Midwest, Fresh Line Run 20-24</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB583&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Young Hen, Midwest, Fresh Undergrade</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Consumer Sized Turkey Breast"  
						TitleClosed="Consumer Sized Turkey Breast"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB577&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breasts, Back Out with 10oz. Gravy Packet, 4-8 Pound</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Fresh Raw Turkey Meat"  
						TitleClosed="Fresh Raw Turkey Meat"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1050&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breast, Tom, Fresh</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1052&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Thigh, Fresh</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1197&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Tenderloin, Fresh</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB604&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breeder Breast Meat, Fresh</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB606&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Tenderloin, Fresh, Destrapped</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Frozen Raw Turkey Parts"  
						TitleClosed="Frozen Raw Turkey Parts"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1049&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breast, Tom, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1051&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Thigh, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1053&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breast Trim, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1054&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Scapula, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB601&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breast, Hen, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB602&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Tenderloin, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB603&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Breeder Breast Meat, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB605&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Tenderloin, Frozen, Destrapped</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB607&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - White Trim, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB608&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Meat - Wing Meat W/Skin, Frozen</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Institutional Sized Turkey Breast - East"  
						TitleClosed="Institutional Sized Turkey Breast - East"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB2060&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Gizzards, West, Defatted, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB590&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Drums, East, Tom, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB591&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Drums, East, Hen, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB592&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Wings, Whole, Tom , East, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB593&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB V-Wings, East, Tom, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB594&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB V-Wings, East, Hen, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB595&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Necks, East, Tom, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB596&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Necks, East, Hen, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB597&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Tails, East, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB598&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Livers, East, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB599&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Hearts, East, Frozen</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB600&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Gizzards, East, Defatted, Frozen</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Institutional Sized Turkey Breast - West"  
						TitleClosed="Institutional Sized Turkey Breast - West"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB584&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 8-10 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB585&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 10-12 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB586&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 12-14 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB587&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 14-16 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB588&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 16-18 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB589&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, East, 18-20 Pound</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Mechanically Separated Chicken"  
						TitleClosed="Mechanically Separated Chicken"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB572&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 20 Pound & Up</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB573&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 8-10 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB574&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 10-12 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB575&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 12-14 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB578&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 14-16 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB579&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 16-18 Pound</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB580&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB Turkey Breast Inst. Pkgd, West, 18-20 Pound</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Mechanically Separated Turkey"  
						TitleClosed="Mechanically Separated Turkey"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB1048&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Fresh-Over 20% Fat, With Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB609&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Fresh-Under 15% Fat, With Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB610&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Frozen-Under 15% Fat, With Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB615&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Frozen-Under 15% Fat, No Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB616&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Fresh-Under 15% Fat, No Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB617&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Frozen-15-20% Fat, With Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB618&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Fresh-15-20% Fat, With Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB619&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Chicken-Frozen-Over 20% Fat, With Skin</A><BR>
							</DIV>
					</CF_openLayer>

					<CF_openLayer
						Border="#Border#"
						BorderSize="#BorderSize#"  
						BorderColor="#BorderColor#"  
						Image="#Image#"
						ImageOpen="#ImageOpen#"
						Title="Statistics"  
						TitleClosed="Statistics"  
						TitleTooltip="Click here to colapse selections"  
						TitleColor="#TitleColor#"  
						TitleFont="#TitleFont#"
						TitleSize="#TitleSize#"
						IsClosed="#IsClosed#"
						Width="#width#">
							<DIV STYLE="margin-left: 12px;">
								   <A HREF="view_commodity_chart.cfm?Symbol=UB611&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Turkey-Frozen-Under 20% Fat, Some Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB612&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Turkey-Fresh-Under 20% Fat, Some Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB613&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Turkey-Frozen-Over 20% Fat, Some Skin</A><BR>
								   <A HREF="view_commodity_chart.cfm?Symbol=UB614&datasize=30" onclick="NewWindow(this.href,'name','750','550','No', 'No');return false;">UB MSP, Mech. Sep. Turkey-Fresh-Over 20% Fat, Some Skin</A><BR>

							</DIV>
					</CF_openLayer>
		
				</DIV>
		</CF_openLayer>
	</TD>
</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
----->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- 											Get UB Stuff										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>

<CFQUERY NAME="Get_UB_Data" DATASOURCE="#application.datasource#">
	Select		Commodity_Exchange_Type.Commodity_Exchange_Type_Description, Commodity_Exchange_Type.Commodity_Exchange_Type_ID,
				Commodities_Exchange_Detail.Exchange_Detail_Name, Commodities_Exchange_Detail.Exchange_Detail_Abrev
				

	From		Commodity_Exchange_Type
				INNER JOIN Commodities_Exchange_Detail
				ON
				Commodity_Exchange_Type.Commodity_Exchange_Type_ID = Commodities_Exchange_Detail.Commodity_Exchange_Type_ID

	Where		Commodity_Exchange_Type.Commodity_Exchange_Type_ID	<> 1

	Order by	Commodity_Exchange_Type.Commodity_Exchange_Type_Description, Commodities_Exchange_Detail.Exchange_Detail_Name
</CFQUERY>

<CFQUERY NAME="Distinct_Exchange_Type" DBTYPe="query">
	SELECT	DISTINCT	Commodity_Exchange_Type_ID, Commodity_Exchange_Type_Description
	FROM	Get_UB_Data
</CFQUERY>

<CFQUERY NAME="Get_All_Commodity_Symbols" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Commodities_Symbol
</CFQUERY>

<CFLOOP QUERY="Distinct_Exchange_Type">		
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TR onClick="propogateClickToOpenLayer(this);" BGCOLOR="FFFFFF" STYLE="cursor:pointer;" onmouseover="CellOn(this)" onmouseout="CellOff(this)" TITLE="View details...">
	<TD>
		<CF_openLayer
			Border="#Border#"
			BorderSize="#BorderSize#"  
			BorderColor="#BorderColor#"  
			Image="#Image#"
			ImageOpen="#ImageOpen#"
			Title="#Commodity_Exchange_Type_Description#"  
			TitleClosed="#Commodity_Exchange_Type_Description#"
			TitleTooltip="Click here to colapse selections"  
			TitleColor="#TitleColor#"  
			TitleFont="#TitleFont#"
			TitleSize="#TitleSize#"
			IsClosed="#IsClosed#"
			Width="#width#">
				<DIV STYLE="margin-left: 12px;">
					<CFQUERY NAME="Distinct_Exchange_Detail" DBTYPe="query">
						SELECT	DISTINCT	Exchange_Detail_Name, Exchange_Detail_Abrev
						FROM	Get_UB_Data
						WHERE
								Commodity_Exchange_Type_ID = #Commodity_Exchange_Type_ID#
					</CFQUERY>
				
					<CFLOOP QUERY="Distinct_Exchange_Detail">
						<CF_openLayer
							Border="#Border#"
							BorderSize="#BorderSize#"  
							BorderColor="#BorderColor#"  
							Image="#Image#"
							ImageOpen="#ImageOpen#"
							Title="#Exchange_Detail_Name#"  
							TitleClosed="#Exchange_Detail_Name#"  
							TitleTooltip="Click here to colapse selections"  
							TitleColor="#TitleColor#"  
							TitleFont="#TitleFont#"
							TitleSize="#TitleSize#"
							IsClosed="#IsClosed#"
							Width="#width#">
								<DIV STYLE="margin-left: 12px;">
									<CFQUERY NAME="Get_Commodity_Symbols" DBTYPE="query">
										SELECT	*
										FROM	Get_All_Commodity_Symbols
										WHERE
												Exchange_Detail_Abrev = '#Exchange_Detail_Abrev#'
									</CFQUERY>
									<CFLOOP QUERY="Get_Commodity_Symbols">
									<CFOUTPUT>
									<A HREF="view_commodity_chart.cfm?Symbol=#Symbol#&datasize=30" onclick="NewWindow(this.href,'name','#Window_Width#','#Window_Height#','No', 'No');return false;">#Symbol_Description#</A><BR>
									</CFOUTPUT>
									</CFLOOP>
								</DIV>
						</CF_openLayer>	
					</CFLOOP>
				</DIV>
		</CF_openLayer>
	</TD>
</TR>
</CFLOOP>



</TABLE>
</BODY>
