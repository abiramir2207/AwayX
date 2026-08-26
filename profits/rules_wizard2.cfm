	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- The master table settings for all objects														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET table_settings="BORDER='0' CELLSPACING='5' CELLPADDING='0' WIDTH='500'">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



	<script>
		

		function returnTwoDecimals(number){
			number = Math.round(number * 10000);
			number = number/10000
			number = number + "";
			
			locationOfDecimal = number.indexOf(".");
			
			if(locationOfDecimal == -1){
				number = number + ".0000"
				return number
			}
			else {
				decimalLocation = number.substring(locationOfDecimal+1, locationOfDecimal+5) 

				if(decimalLocation.length == 1){
					number = number + "000"
					return number
				}

				if(decimalLocation.length == 2){
					number = number + "00"
					return number
				}
				if(decimalLocation.length == 3){
					number = number + "0"
					return number
				}
				
				
				
				return number;
			}
			
		}
		
		seed = parseFloat(2.00);
		runningCalculatedPercentageTotal = parseFloat(0);
		
		function calcConcurrentTotal() {
			concurrentSeed = runningCumulativeTotal
			runningCalculatedPercentageTotal = 0;
			for(var x=1; x<=4; x++){
				currentPercentageField = eval('document.all.percentage_of_seed_' + x);
				currentCalculatedPercentageField = eval('document.all.calculated_percentage_of_seed_' + x);
				finalValueField = eval('document.all.finalvalue_' + x);
				
				if(currentPercentageField.value.length != 0 && currentPercentageField.value.indexOf("%") != -1) {

					percentage = parseFloat(currentPercentageField.value);
					calculatedPercentage = (concurrentSeed*(percentage*.01))
					runningCalculatedPercentageTotal = runningCalculatedPercentageTotal + calculatedPercentage;
					tempFinalValue = concurrentSeed + runningCalculatedPercentageTotal
					finalValueField.value = returnTwoDecimals(tempFinalValue);
					
					currentCalculatedPercentageField.value = returnTwoDecimals(calculatedPercentage)
				}


				if(currentPercentageField.value.length != 0 && currentPercentageField.value.indexOf("%") == -1) {
					runningCalculatedPercentageTotal = runningCalculatedPercentageTotal + parseFloat(currentPercentageField.value);
					currentCalculatedPercentageField.value = returnTwoDecimals(parseFloat(currentPercentageField.value))
					tempFinalValue = concurrentSeed + runningCalculatedPercentageTotal
					finalValueField.value = returnTwoDecimals(tempFinalValue);
				}

				
			runningTotal = concurrentSeed+runningCalculatedPercentageTotal
			displayFinalTotal()
			
			}
		}
	
		var runningCumulativeTotal = 0;
		function calcCumulativeTotal() {
			runningCumulativeTotal = seed;
			for(var x=1; x<=4; x++){
				currentCumulativePercentageField = eval('document.all.cumulative_percentage_of_seed_' + x);
				currentCumulativeCalculatedPercentageField = eval('document.all.cumulative_calculated_percentage_of_seed_' + x);
				cumulativefinalValueField = eval('document.all.cumulative_finalvalue_' + x);
				
				if(currentCumulativePercentageField.value.length != 0 && currentCumulativePercentageField.value.indexOf("%") != -1) {
					
					percentage = parseFloat(currentCumulativePercentageField.value);
					
					calculatedPercentage = (runningCumulativeTotal*(percentage*.01));
					
					runningCumulativeTotal = runningCumulativeTotal + (runningCumulativeTotal*(percentage*.01))
					currentCumulativeCalculatedPercentageField.value = returnTwoDecimals(parseFloat(calculatedPercentage))
					cumulativefinalValueField.value = returnTwoDecimals(parseFloat(runningCumulativeTotal))
				}

				if(currentCumulativePercentageField.value.length != 0 && currentCumulativePercentageField.value.indexOf("%") == -1) {
					runningCumulativeTotal = runningCumulativeTotal + parseFloat(currentCumulativePercentageField.value)
					currentCumulativeCalculatedPercentageField.value = returnTwoDecimals(parseFloat(currentCumulativePercentageField.value))
					cumulativefinalValueField.value = returnTwoDecimals(parseFloat(runningCumulativeTotal))
					
				}			
			}		
		}
	
	function calcAll(){
		calcCumulativeTotal();
		calcConcurrentTotal();
		
	}
	function displayFinalTotal(){
		total = Math.round((runningCumulativeTotal+runningCalculatedPercentageTotal)*1000)
		total = parseFloat(total/1000)
		document.all.finalTotal.innerText = returnTwoDecimals(total)
	}
	</script>

</head>


<style>
	INPUT.hidden
	{
		border : 1 solid White;
		text-align : right;
	}
</style>


<body onload="document.all.seedText.innerText = seed; calcAll();">


<CFINCLUDE TEMPLATE="rules_wizard_pg1_selections.cfm">


<!--- 
<FIELDSET STYLE="padding:0px; width: 1%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity Pricing  - Step 2 of 2</LEGEND>
 --->

<CFFORM ACTION="rules_wizard_save_data.cfm" METHOD="post" NAME="MyForm">

<TABLE <CFOUTPUT>#table_settings#</CFOUTPUT>>
	<TR>
		<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Compounded Calculations</DIV></TD>
		<TD ALIGN="right"><A HREF="commodity_help.cfm#Compounded_Calculations" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="4"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD VALIGN="bottom"><B>Component Description</B></TD>
		<TD VALIGN="bottom"><B>Amount</B></TD>
		<TD VALIGN="bottom"><B>Calculated<BR>Amount</B></TD>
		<TD VALIGN="bottom"><B>Running<BR>Total</B></TD>
	</TR>
	<TR>
		<TD COLSPAN="4" BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="CP_desc_calc1" TABINDEX="1"   SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="2" name="CP_amount_calc1" id="cumulative_percentage_of_seed_1" size="4"></TD>
		<TD><INPUT TYPE="text" NAME="cumulative_calculated_percentage_of_seed_1" ID="cumulative_calculated_percentage_of_seed_1" SIZE="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="cumulative_finalvalue_1" id="cumulative_finalvalue_1" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="CP_desc_calc2" TABINDEX="3"  SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="4" name="CP_amount_calc2" id="cumulative_percentage_of_seed_2" size="4"></TD>
		<TD><input type="text" name="cumulative_calculated_percentage_of_seed_2" id="cumulative_calculated_percentage_of_seed_2" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="cumulative_finalvalue_2" id="cumulative_finalvalue_2" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="CP_desc_calc3"  TABINDEX="5" SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="6" name="CP_amount_calc3" id="cumulative_percentage_of_seed_3" size="4"></TD>
		<TD><input type="text" name="cumulative_calculated_percentage_of_seed_3" id="cumulative_calculated_percentage_of_seed_3" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="cumulative_finalvalue_3" id="cumulative_finalvalue_3" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="CP_desc_calc4"  TABINDEX="7" SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="8" name="CP_amount_calc4" id="cumulative_percentage_of_seed_4" size="4"></TD>
		<TD><input type="text" name="cumulative_calculated_percentage_of_seed_4" id="cumulative_calculated_percentage_of_seed_4" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="cumulative_finalvalue_4" id="cumulative_finalvalue_4" size="4" READONLY CLASS="hidden"></TD>
	</TR>
</table>

<TABLE <CFOUTPUT>#table_settings#</CFOUTPUT>>
	<TR>
		<TD VALIGN="bottom" WIDTH="100%" COLSPAN="3"><DIV CLASS="title2">Independent Calculations</DIV></TD>
		<TD ALIGN="right"><A HREF="commodity_help.cfm#Independent_Calculations" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="4"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD VALIGN="bottom"><B>Component Description</B></TD>
		<TD VALIGN="bottom"><B>Amount</B></TD>
		<TD VALIGN="bottom"><B>Calculated<BR>Amount</B></TD>
		<TD VALIGN="bottom"><B>Running<BR>Total</B></TD>
	</TR>
	<TR>
		<TD COLSPAN="4" BGCOLOR="Orange"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="IN_desc_calc1" TABINDEX="9"  SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="10" name="IN_amount_calc1" id="percentage_of_seed_1" size="4"></TD>
		<TD><input type="text" name="calculated_percentage_of_seed_1" id="calculated_percentage_of_seed_1" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="finalvalue_1" id="finalvalue_1" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="IN_desc_calc2"  TABINDEX="11" SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="12" name="IN_amount_calc2" id="percentage_of_seed_2" size="4"></TD>
		<TD><input type="text" name="calculated_percentage_of_seed_2" id="calculated_percentage_of_seed_2" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="finalvalue_2" id="finalvalue_2" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="IN_desc_calc3"  TABINDEX="13" SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="14" name="IN_amount_calc3" id="percentage_of_seed_3" size="4"></TD>
		<TD><input type="text" name="calculated_percentage_of_seed_3" id="calculated_percentage_of_seed_3" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="finalvalue_3" id="finalvalue_3" size="4" READONLY CLASS="hidden"></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="text" NAME="IN_desc_calc4"  TABINDEX="15" SIZE="50" MAXLENGTH="50"></TD>
		<TD><input type="text" ONBLUR="calcAll();" TABINDEX="16" name="IN_amount_calc4" id="percentage_of_seed_4" size="4"></TD>
		<TD><input type="text" name="calculated_percentage_of_seed_4" id="calculated_percentage_of_seed_4" size="4" READONLY CLASS="hidden"></TD>
		<TD><input type="text" name="finalvalue_4" id="finalvalue_4" size="4" READONLY CLASS="hidden"></TD>
	</TR>
</table>

<TABLE <CFOUTPUT>#table_settings#</CFOUTPUT>>
<TR>
	<TD ALIGN="right" WIDTH="100%"><B>Net Result:</B></TD>
	<TD NOWRAP>$<span id="finalTotal"> Not Yet Calculated</span></TD>
</TR>
</TABLE>

<!--- 		
<FIELDSET STYLE="padding:5px; width: 414; border: 1px solid White;">
<input type="Button" onclick="calcAll()" value="calculate all"><FONT SIZE="+1">Net Result: $<span id="finalTotal"> Not Yet Calculated</span></FONT>
</FIELDSET>

 --->

<TABLE <CFOUTPUT>#table_settings#</CFOUTPUT>>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom" WIDTH="100%"><DIV CLASS="title2">Freight</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Freight" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Please enter any additional freight charges for Delivered Net Pricing Contracts:<BR>
			<CFINPUT TYPE="Text" NAME="freight" MESSAGE="The freight value must be a number" VALIDATE="float" REQUIRED="No" SIZE="11">
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Pricing Floor</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Pricing_Floor" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			For items covered by this formula, do not allow requests to be equal to or less than a price that is:<BR>
			<INPUT TYPE="radio" NAME="Floor_type" VALUE="dollars" CHECKED>$/pound above calculated cost
			&nbsp;&nbsp;&nbsp;
			<INPUT TYPE="radio" NAME="Floor_type" VALUE="percent">% above calculated cost
			&nbsp;&nbsp;&nbsp;
			<CFINPUT TYPE="Text" NAME="Floor_Amount" MESSAGE="The floor value must be a number." VALIDATE="float" REQUIRED="No" SIZE="11">
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD VALIGN="bottom"><DIV CLASS="title2">Notes</DIV></TD>
		<TD><A HREF="commodity_help.cfm#Notes" onclick="NewWindow(this.href,'name','625','450','Yes', 'No');return false;"><IMG SRC="/images/question.gif" BORDER="0"></A></TD>
	</TR>
	<TR>
		<TD BGCOLOR="Orange" COLSPAN="2"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
	</TR>
	<TR>
		<TD COLSPAN="2">
			Enter any comments or remarks:<BR>
			<TEXTAREA COLS="85" ROWS="5" NAME="Notes"></TEXTAREA>
		</TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	

</TABLE>	

<TABLE <CFOUTPUT>#table_settings#</CFOUTPUT>>
<TR>
	<TD ALIGN="right" WIDTH="350"></TD>
	<TD NOWRAP><INPUT TYPE="submit" VALUE="save pricing rule"></TD>
</TR>
</TABLE>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- These are the contents of the form from the previous page (page 1)							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="Rulename" 				VALUE="#form.rulename#">
	<INPUT TYPE="hidden" NAME="Products" 				VALUE="#form.Products#">
	<INPUT TYPE="hidden" NAME="Exchange"				VALUE="#Form.Exchange#">
	<INPUT TYPE="hidden" NAME="Commodity"				VALUE="#Form.Commodity#">
	<INPUT TYPE="hidden" NAME="Sample_size"				VALUE="#form.sample_size#">
	<INPUT TYPE="hidden" NAME="Time_UOM_sample_size"	VALUE="#form.Time_UOM_sample_size#">
	<INPUT TYPE="hidden" NAME="Point_in_time"			VALUE="#point_in_time#">
	<INPUT TYPE="hidden" NAME="Time_UOM_point_in_time"	VALUE="#form.Time_UOM_point_in_time#">
	<INPUT TYPE="hidden" NAME="Calc_Process"			VALUE="#form.Calc_Process#">
</CFOUTPUT>

</CFFORM>
<!--- 
</FIELDSET>

 --->



		
