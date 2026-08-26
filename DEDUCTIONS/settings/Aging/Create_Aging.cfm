<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>


<CFSET URL.PageTitle="Deductions: AGING MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_aging", {
				"deleted" = "eq.0",
				"order" = "tier_number.asc"
			}),
			"aging_count,dd_aging_label,colorid,fontid,end_range"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" DATASOURCE="#Application.Datasource#">
	SELECT * FROM DD_Aging WHERE Deleted=0 ORDER BY Tier_Number Asc
</CFQUERY>
</cfif>


<CFPARAM NAME="URL.Mode" DEFAULT="2">
<CFPARAM NAME="URL.TotTRNumber" DEFAULT="#Get_Data.Aging_Count#">
<CFIF URL.TotTRNumber NEQ "" AND IsDefined("URL.FromColorPalette")>
	<CFLOOP INDEX="Loopcount" FROM ="1" TO = "#URL.TotTRNumber#">
		<CFIF Loopcount EQ URL.TotTRNumber>
			<CFPARAM NAME="URL.Label_#Loopcount#" DEFAULT="">	
			<CFPARAM NAME="URL.colorID_#LoopCount#" DEFAULT="">
			<CFPARAM NAME="URL.fontID_#LoopCount#" DEFAULT="">
		<CFELSE>
			<CFPARAM NAME="URL.Ed_Rg_#Loopcount#" DEFAULT="">
			<CFPARAM NAME="URL.Label_#Loopcount#" DEFAULT="">	
			<CFPARAM NAME="URL.colorID_#LoopCount#" DEFAULT="">
			<CFPARAM NAME="URL.fontID_#LoopCount#" DEFAULT="">
		</CFIF>		
	</CFLOOP>
<CFELSEIF URL.TotTRNumber NEQ "" AND Not IsDefined("URL.FromColorPalette")>
	<CFLOOP QUERY="Get_Data">
		<CFIF Currentrow EQ URL.TotTRNumber>
			<CFPARAM NAME="URL.Label_#Currentrow#" DEFAULT="#DD_Aging_Label#">	
			<CFPARAM NAME="URL.colorID_#Currentrow#" DEFAULT="#ColorID#">
			<CFPARAM NAME="URL.fontID_#Currentrow#" DEFAULT="#FontID#">
		<CFELSE>
			<CFPARAM NAME="URL.Ed_Rg_#Currentrow#" DEFAULT="#End_Range#">
			<CFPARAM NAME="URL.Label_#Currentrow#" DEFAULT="#DD_Aging_Label#">	
			<CFPARAM NAME="URL.colorID_#Currentrow#" DEFAULT="#ColorID#">
			<CFPARAM NAME="URL.fontID_#Currentrow#" DEFAULT="#FontID#">
		</CFIF>		
	</CFLOOP>
</CFIF>




<CFPARAM NAME="FORM.TotTRNumber" DEFAULT="#URL.TotTRNumber#">
<CFIF FORM.TotTRNumber NEQ "">
	<CFLOOP INDEX="Loopcount" FROM ="1" TO = "#FORM.TotTRNumber#">
		<CFIF Loopcount EQ FORM.TotTRNumber>
			<CFPARAM NAME="FORM.Label_#Loopcount#" DEFAULT="#EVALUATE("URL.Label_#Loopcount#")#">	
			<CFPARAM NAME="FORM.colorID_#LoopCount#" DEFAULT="#EVALUATE("URL.colorID_#Loopcount#")#">
			<CFPARAM NAME="FORM.fontID_#LoopCount#" DEFAULT="#EVALUATE("URL.fontID_#Loopcount#")#">			
		<CFELSE>
			<CFPARAM NAME="FORM.Ed_Rg_#Loopcount#" DEFAULT="#EVALUATE("URL.Ed_Rg_#Loopcount#")#">
			<CFPARAM NAME="FORM.Label_#Loopcount#" DEFAULT="#EVALUATE("URL.Label_#Loopcount#")#">	
			<CFPARAM NAME="FORM.colorID_#LoopCount#" DEFAULT="#EVALUATE("URL.colorID_#Loopcount#")#">
			<CFPARAM NAME="FORM.fontID_#LoopCount#" DEFAULT="#EVALUATE("URL.fontID_#Loopcount#")#">
		</CFIF>		
	</CFLOOP>
</CFIF>



<BR><BR>

<CFIF URL.Mode EQ 1>
	<CFSET NextMode = 2>
<CFELSE>
	<CFSET NextMode = 1>
</CFIF>
<FORM NAME="Aging_Entry" ACTION="Save_Aging.cfm" METHOD="POST">

<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="TotTRNumber" VALUE="#FORM.TotTRNumber#">
<INPUT TYPE="Hidden" NAME="PreTotTRNumber" VALUE="#FORM.TotTRNumber#">
</CFOUTPUT>
<DIV ID="Dynamic_Color_Font">
</DIV>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="3" ALIGN="Center" ID="Aging_Table" <CFIF FORM.TotTRNumber EQ "">WIDTH="590"</CFIF>>
	<TR>
		<TD COLSPAN="5" ALIGN="Center"><HR COLOR="Navy"><BR><B><FONT SIZE="2">AGING - RANGE & LABEL</FONT></B><HR COLOR="Navy"></TD>
	</TR>
	<CFIF URL.MODE EQ 2 OR FORM.TotTRNumber EQ "">
	<TR>
		<TD COLSPAN="100%" ALIGN="Right"><FONT COLOR="red"><B>Aging Count:</B></FONT> <CFOUTPUT><INPUT TYPE ="Text" NAME="Aging_Count" VALUE="#FORM.TotTRNumber#" SIZE="3"></CFOUTPUT> <INPUT TYPE="Button" NAME="Submit_Count" VALUE="go" ONCLICK="Javascript: incrementInput()"><BR><BR></TD>
	</TR>
	</CFIF>
	<CFIF FORM.TotTRNumber EQ "">		
	<TR>
		<TD WIDTH="40" height="25"></TD>
		<TD WIDTH="90" ALIGN="Center"><B>RANGE START</B></TD>
		<TD WIDTH="90" ALIGN="Center"><B>RANGE END</B></TD>	
		<TD <CFIF URL.MODE EQ 2>WIDTH="200"</CFIF>><B>LABEL</B></TD>			
		<TD WIDTH="82" NOWRAP><B>HEADER COLOR</B></TD>
	</TR>
	
	<CFELSE>
	<TR>
		<TD WIDTH="40" height="25">			
			&nbsp;<!--- <CFOUTPUT><B><FONT SIZE="2" COLOR="Red">[ </FONT><A href="Create_Aging.cfm?Mode=#NextMode#"><FONT SIZE="2"><CFIF NextMode EQ 1>view<CFELSE>edit</CFIF></FONT></A><FONT SIZE="2" COLOR="Red"> ]</FONT></B></CFOUTPUT> ---> 			
		</TD>
		<TD WIDTH="90" ALIGN="Center"><B>RANGE START</B></TD>
		<TD WIDTH="90" ALIGN="Center"><B>RANGE END</B></TD>	
		<TD <CFIF URL.MODE EQ 2>WIDTH="200"</CFIF>><B>LABEL</B></TD>			
		<TD WIDTH="82" NOWRAP><B>HEADER COLOR</B></TD>
	</TR>
	

		<INPUT TYPE="Hidden" NAME="FirstEntry" VALUE="0">
		<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.TotTRNumber#">
		<CFOUTPUT>	
		<INPUT TYPE="Hidden" NAME="colorID_#LoopCount#" VALUE="#EVALUATE("FORM.colorID_#LoopCount#")#">
		<INPUT TYPE="Hidden" NAME="fontID_#LoopCount#" VALUE="#EVALUATE("FORM.fontID_#LoopCount#")#">
		<CFIF LoopCount EQ 1>
			<CFSET Start_Range = #EVALUATE("FORM.Ed_Rg_#Loopcount#")#>
			<CFIF Start_Range EQ "">
				<CFSET Start_Range = "...">
			<CFELSE>
				<CFSET Start_Range = Start_Range - 1>
			</CFIF>			
		<CFELSE>
			<CFSET PreIndex = Loopcount -1>
			<CFSET Start_Range =#EVALUATE("FORM.Ed_Rg_#PreIndex#")#>
			<CFIF Start_Range EQ "">
				<CFSET Start_Range = "...">
			<CFELSE>
				<CFSET Start_Range = Start_Range + 1>
			</CFIF>
		</CFIF>
				<TR>
					<TD HEIGHT="30" NOWRAP><B>Aging #LoopCount#</B></TD>					
					<TD ALIGN="Center">
						<CFIF URL.MODE EQ 1>
							<CFIF LoopCount EQ 1>
								Up to #EVALUATE("FORM.Ed_Rg_#Loopcount#")# days
							<CFELSE>
								#Start_Range#
							</CFIF>
						<CFELSE>
							<CFIF LoopCount EQ 1>
								Up to #EVALUATE("FORM.Ed_Rg_#Loopcount#")# days
							<CFELSE>
								#Start_Range#
							</CFIF>
						</CFIF>
					</TD>
					<TD ALIGN="Center">
						<CFIF URL.MODE EQ 1>
							<CFIF LoopCount EQ FORM.TotTRNumber>
								at least #Start_Range# days
							<CFELSE>
								#EVALUATE("FORM.Ed_Rg_#Loopcount#")#
							</CFIF>
						<CFELSE>
							<CFIF LoopCount EQ FORM.TotTRNumber>
								<CFIF Start_Range EQ "...">
									#Start_Range#
								<CFELSE>
									at least #Start_Range# days
								</CFIF>
							<CFELSE>
								<INPUT TYPE="Text" NAME="Ed_Rg_#LoopCount#" VALUE=<CFIF #EVALUATE("FORM.Ed_Rg_#Loopcount#")# EQ "">""<CFELSE>"#EVALUATE("FORM.Ed_Rg_#Loopcount#")#"</CFIF> ONBLUR="Javascript: incrementByOne(#LoopCount#,document.all.TotTRNumber.value)" SIZE="4" STYLE="text-align:center;">
							</CFIF>
						</CFIF>
					</TD>
					<TD>
						<CFIF URL.MODE EQ 1>
							#EVALUATE("FORM.Label_#Loopcount#")#
						<CFELSE>
							<INPUT TYPE="Text" NAME="Label_#LoopCount#" VALUE="#EVALUATE("FORM.Label_#Loopcount#")#" SIZE="30" MAXLENGTH="45">
						</CFIF>
					</TD>
					<CFIF URL.MODE EQ 1>
						<TD <CFIF #EVALUATE("FORM.colorID_#LoopCount#")# NEQ "">BGCOLOR="#EVALUATE("FORM.colorID_#LoopCount#")#"</CFIF>>
							<CFIF #EVALUATE("FORM.colorID_#LoopCount#")# EQ "">
								None.
							<CFELSE>
								&nbsp;
							</CFIF>
						</TD>
					<CFELSE>	
						<!--- <A HREF="Javascript: colorPalette('#LoopCount#')"><TD ALIGN="Center" STYLE="cursor: pointer; border: 1px solid silver;"  TITLE="Click to choose header color for deductions in this age" <CFIF EVALUATE("FORM.colorID_#LoopCount#") NEQ "">BGCOLOR="#EVALUATE("FORM.colorID_#LoopCount#")#" </CFIF>><CFIF EVALUATE("FORM.colorID_#LoopCount#") EQ "">set color<CFELSE>&nbsp;</CFIF></TD></A> --->
						
						<CFIF EVALUATE("FORM.colorID_#LoopCount#") EQ "">
							<TD ALIGN="Center"   TITLE="Click to choose header color for deductions in this age" ><A HREF="Javascript: colorPalette('#LoopCount#')"><B>set color</B></A></TD>
						<CFELSE>
							<A HREF="Javascript: colorPalette('#LoopCount#')"><TD ALIGN="Center" STYLE="cursor: pointer; border: 1px solid silver;"  TITLE="Click to choose header color for deductions in this age" <CFIF EVALUATE("FORM.colorID_#LoopCount#") NEQ "">BGCOLOR="#EVALUATE("FORM.colorID_#LoopCount#")#" </CFIF>>&nbsp;</TD></A>	
						</CFIF>	
					</CFIF>								
				</TR>						
		</CFOUTPUT>
		</CFLOOP>
	</CFIF>
	<TR>
		<TD COLSPAN="5" ALIGN="Center"><HR COLOR="Navy">
		<CFIF URL.Mode EQ 2 OR Get_Data.RecordCount EQ 0>
			 <BR><BR>
			<CF_button
			button_name		=	""
			button_caption	=	"save data"
			button_action	=	"Validate()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
						>	
		</CFIF>	
		</TD>
	</TR>
</TABLE>
</FORM>


<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT language="JavaScript">
function colorPalette(index)
{
	var loopcount = document.all.TotTRNumber.value;
	var URLStr = "TotTRNumber="+loopcount+",";	
	for (i=1; i<=loopcount; i++)
	{
		if(i<loopcount)
		{
			Ed_Rg = "Ed_Rg_"+i;					
			URLStr=URLStr+Ed_Rg+"=";
			Ed_Rg = eval("document.all.Ed_Rg_"+i+".value");
			URLStr=URLStr+Ed_Rg+",";
		}
		Color = "colorID_"+i;
		URLStr=URLStr+Color+"=";
		Color = eval("document.all.colorID_"+i+".value");
		URLStr=URLStr+Color+","; 
		
		font = "fontID_"+i;
		URLStr=URLStr+font+"=";
		font=eval("document.all.fontID_"+i+".value");
		URLStr=URLStr+font+",";
		
		Label = "Label_"+i;
		URLStr=URLStr+Label+"=";
		Label = eval("document.all.Label_"+i+".value");		
		if (i==loopcount)
		{
			URLStr=URLStr+Label;
		}
		else
		{
			URLStr=URLStr+Label+",";
		}
			
	}	
	ColorPalette = NewWindow("Color_palette.cfm?SelItem="+index+"&URLStr="+URLStr , 'name', '130', '113', 'Yes', 'No', true);	
}


function incrementInput()
{
	var ploopStart = parseInt(document.Aging_Entry.TotTRNumber.value);	
	if (isNaN(ploopStart))
	{
		ploopStart = 0;
	}	
	var ploopEnd = document.Aging_Entry.Aging_Count.value;
	var ptabObj = document.all.Aging_Table;
	if (ploopEnd > 0)
	{
		if (ploopStart < ploopEnd)
		{
			ploopStart = ploopStart + 1;		 			
			insertNewRows(ptabObj,ploopStart,ploopEnd);
		}
		else if (ploopStart > ploopEnd)
		{
			deleteRows(ptabObj,ploopStart,ploopEnd)
		}
	}
	else
	{
		alert("Age count must be more than zero.");
		document.Aging_Entry.Aging_Count.focus();
		return;
	}
}

function deleteRows(tabObj,loopStart,loopEnd)
{	
	var suffix = loopEnd - 1;
	var strEnd = "Ed_Rg_"+suffix;
	for(i=loopStart; i>loopEnd; i--)
	{	
		var rowNumber = i + 2;
		tabObj.deleteRow(rowNumber);
	}	
	document.Aging_Entry.TotTRNumber.value = loopEnd;		
	loopEnd = parseInt(loopEnd) + 2;
	
	if (suffix != 0)	
	{
		strEnd=eval("document.all."+strEnd+".value");
		
		if (strEnd == "")
		{
			document.all.Aging_Table.rows[loopEnd].cells[2].innerHTML = "...";
		}
		else
		{
			strEnd = parseInt(strEnd) + 1;	
			document.all.Aging_Table.rows[loopEnd].cells[2].innerHTML = "at least "+strEnd+" days";
		}
	}	
}


function insertNewRows(tabObj,loopStart,loopEnd)
{	
	var preLastRow,cellTwoID;
	
	document.Aging_Entry.PreTotTRNumber.value = document.Aging_Entry.TotTRNumber.value;
	preLastRow = document.Aging_Entry.PreTotTRNumber.value;	
	preLastRowObsolute = parseInt(preLastRow) + 2;
	cellTwoID = "Ed_Rg_"+preLastRow;
	
	if (document.all.Ed_Rg_1)
	{
		document.all.Aging_Table.rows[preLastRowObsolute].cells[2].innerHTML = "<INPUT TYPE=\"text\" SIZE=\"4\" STYLE=\"text-align:center\" NAME=\""+cellTwoID+"\" ONBLUR=\"Javascript: incrementByOne("+preLastRow+","+loopEnd+")\">"
	}
		
	document.Aging_Entry.TotTRNumber.value = loopEnd;	
	
	for(i=loopStart; i<=loopEnd; i++)
	{
		var rowNumber = i + 2;
		var trObj = tabObj.insertRow(rowNumber);		
		var cellOneID = "St_Rg_"+i;
		var cellTwoID = "Ed_Rg_"+i;
		var labelID = "Label_"+i;
		var cellObj;
		var Color_Font = document.all.Dynamic_Color_Font;
		Color_Font.innerHTML = Color_Font.innerHTML + "<INPUT TYPE=\"Hidden\" NAME=\"colorID_" + i + "\">";
		Color_Font.innerHTML = Color_Font.innerHTML + "<INPUT TYPE=\"Hidden\" NAME=\"fontID_" + i + "\">";				
		
		for(j=0; j<=4; j++)
		{
			cellObj = trObj.insertCell(j);
			if (j==0)
			{
				cellObj.innerHTML = "<B>Aging " + i + "</B>";
				
			}
			if (j==1)
			{
				cellObj.innerHTML = "..."
				cellObj.align = "center";
			}
			if (j==2)
			{
				if (i == loopEnd)
				{
					cellObj.innerText = "..."					
				}				
				else
				{
					cellObj.innerHTML = "<INPUT TYPE=\"text\" SIZE=\"4\" STYLE=\"text-align:center\" NAME=\""+cellTwoID+"\" ONblur=\"Javascript: incrementByOne("+i+","+loopEnd+")\">"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
				}
				cellObj.align = "center";
			}
			if (j==3)
			{				
				cellObj.innerHTML = "<INPUT TYPE=\"text\" NAME=\""+labelID+"\" SIZE=\"30\" MAXLENGTH=\"45\">"
			}
			if(j==4)
			{
				cellObj.innerHTML = "<A HREF=\"Javascript: colorPalette(" + i + ")\"><B>set color</B></A>";
				cellObj.align = "center";				
			}
		} 
	}	
}
function incrementByOne(index,rowIndexLast)
{
	var lastRow = document.all.TotTRNumber.value;	
	//alert(lastRow)
	if (index < lastRow)
	{
		var currentEnd = eval("document.all.Ed_Rg_"+index);	
		var currentValue = parseInt(currentEnd.value);
		var incrementedValue = currentValue;
		var nextRow = parseInt(index) + 3;
		if (isNaN(currentValue))
		{
			alert("Please Enter some number.");
			currentEnd.focus();
			return;
		}
		else
		{
			if (index > 1)
			{
				var previousEnd = eval("document.all.Ed_Rg_"+(index-1));	
				if (currentEnd.value > (parseInt(previousEnd.value) + 1))
				{
					core(index,lastRow);//core(index,rowIndexLast);
				}
				else
				{
					alert("The end range must be more than start range.");				
					currentEnd.focus();		
					return;		
				}
			}
			else
			{
				if (eval("document.all.Ed_Rg_"+index+".value") < 1)
				{
					alert("The end range cannot be zero or less.");	
					document.all.Ed_Rg_1.focus();
				}
				else
				{
					core(index,lastRow);//core(index,rowIndexLast);
				}
			}
		}
	}
}

function core(indexC,rowIndexLastC)
{
	var currentEnd = eval("document.all.Ed_Rg_"+indexC);	
	var currentValue = parseInt(currentEnd.value);
	var incrementedValue = currentValue;
	var nextRow = parseInt(indexC) + 3;
	if (indexC == 1)
	{
		document.all.Aging_Table.rows[3].cells[1].innerText = "Up to "+currentValue+" days";
	}	
	
	incrementedValue = incrementedValue + 1;
	document.all.Aging_Table.rows[nextRow].cells[1].innerText = incrementedValue;
	//alert(indexC);alert(rowIndexLastC)	
	if (indexC == (rowIndexLastC - 1))
	{
		var rowIndexLastC = parseInt(rowIndexLastC)+2;
		var cellindexLast = 3;
		document.all.Aging_Table.rows[rowIndexLastC].cells[2].innerText = "at least "+incrementedValue+" days";				
	}		
}


function Validate()
{
	var totCount = document.all.TotTRNumber.value;
	var edObj,labelObj; 
	var submit_ok = 1;
	if (totCount == 0)
	{
		alert("Enter some number in age count and press 'go'.");
		return;
	}	
	for (i=1; i<=totCount; i++)
	{		
		labelObj = eval("document.all.Label_"+i);							
		if (i != totCount)
		{
			edObj = eval("document.all.Ed_Rg_"+i);			
			if (edObj.value == "")
			{
				alert("Enter some number for all end ranges.");
				submit_ok = 0;			
				edObj.focus();	
				return;				
			}
			if (labelObj.value == "")
			{
				alert("Enter a label for all Ages.");
				submit_ok = 0;	
				labelObj.focus();
				return;
			}
		}
		else
		{
			if (labelObj.value == "")
			{
				alert("Enter a label for all Ages.");
				submit_ok = 0;	
				labelObj.focus();
				return;
			}
		}
	}
	
	for(i=1; i<totCount; i++)
	{		
		var passVal=eval("document.all.Ed_Rg_"+i);
		var checkDecimal=isInt(passVal.value)
		if (checkDecimal == false)
		{
			alert("No decimals are allowed in end range");
			submit_ok = 0;	
			passVal.focus();
			return;
		}
		
	}
	
	
	
	var preValue;
	for (i=1; i<totCount; i++)
	{		
		if(i == 1)
		{
			preValue = eval("document.all.Ed_Rg_"+i+".value");
		}
		else
		{
			curValue = eval("document.all.Ed_Rg_"+i);			
			if (parseInt(curValue.value) <= parseInt(preValue))
			{
				alert("The end range must be higher than the start range.")
				curValue.focus();
				return;
			}
			else
			{
				preValue = eval("document.all.Ed_Rg_"+i+".value");
			}
		}
	}
	if (submit_ok == 1)
	{
		document.Aging_Entry.submit();
	}
}
</SCRIPT>


</body>
</html>