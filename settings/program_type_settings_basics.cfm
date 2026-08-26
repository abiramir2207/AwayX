

	<script>
	function setChecksBasics() {
		resetBasics()
	
	ptsBasics = new Object();
	
	/* Get row count */
		basGRows = generic.getRowCount();		// generic
		basCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < basGRows; ++grow) 
		{
		var basGen = generic.getField(grow, 'Generic_Type');
		ptsBasics[basGen] = new Object();
			for (var crow = 0; crow < basCRows; ++crow) 
			{
				var basCgen = created.getField(crow, 'Generic_Type');
				if (basGen == basCgen) 
				{
					var basCreator = created.getField(crow, 'Created_Type');
			
					var chk1 = created.getField(crow, 'Max_Duration');
					var chk2 = created.getField(crow, 'Min_Duration');
					var chk3 = created.getField(crow, 'Max_Global_Volume');
					var chk4 = created.getField(crow, 'Min_Global_Volume');
					var chk5 = created.getField(crow, 'Allow_Retro_Create');
					var chk6 = created.getField(crow, 'Adv_Spend');
					var chk7 = created.getField(crow, 'Growth_Inclusion');
					<!--- var chk8 = created.getField(crow, 'Auto_Renew_Option'); --->
					var chk9 = created.getField(crow, 'Rates_By_Category');
					var chk10 = created.getField(crow, 'Controllable_Volume');
					var chk11 = created.getField(crow, 'Global_GL_Assign');
					var chk12 = created.getField(crow, 'Specify_Distributors');
					var chk13 = created.getField(crow, 'Specify_Operators');
					var chk14 = created.getField(crow, 'Specify_Brokers');
					var chk15 = created.getField(crow, 'Specify_Products');
					var chk16 = created.getField(crow, 'Global_GL_Assign_Choice');
					var chk17 = created.getField(crow, 'Active');					
					var chk18 = created.getField(crow, 'Include_Trade');
					if(chk18 == false) chk18 = 0;
					if(chk18 == true) chk18 = 1;
					<!--- var chk19 = created.getField(crow, 'Volume_Resolution'); --->
					<!--- var chk20 = created.getField(crow, 'Margin_Calc_Display'); --->
					
					var txt1 = created.getField(crow, 'Max_Duration_Length');
					var txt2 = created.getField(crow, 'Min_Duration_Length');
					var txt3 = created.getField(crow, 'Max_Global_Volume_Size_CS');
					var txt4 = created.getField(crow, 'Max_Global_Volume_Size_LBS');
					var txt5 = created.getField(crow, 'Max_Global_Volume_Size_GAL');
					var txt6 = created.getField(crow, 'Max_Global_Volume_Size_LTR');
					var txt7 = created.getField(crow, 'Min_Global_Volume_Size_CS');
					var txt8 = created.getField(crow, 'Min_Global_Volume_Size_LBS');
					var txt9 = created.getField(crow, 'Min_Global_Volume_Size_GAL');
					var txt10 = created.getField(crow, 'Min_Global_Volume_Size_LTR');		
					var txt11 = created.getField(crow, 'Allow_Retro_Create_Max');
					var txt12 = created.getField(crow, 'Adv_Spend_Amt');
					var txt13 = created.getField(crow, 'Program_Description');					
					<!--- var txt14 = created.getField(crow, 'Auto_Renew_Lead_Time'); --->
					var txt15 = created.getField(crow, 'Program_Editable');
					var txt16 = created.getField(crow, 'ProgramControl_Panel_Options_ID');
					
					var sel1 = created.getField(crow, 'Global_GL_Assign_Choice');

					ptsBasics[basGen][basCreator] = new Object();
					ptsBasics[basGen][basCreator] = basCreator;

					
					ptsBasics[basGen][chk1] = new Object();
					ptsBasics[basGen][chk1] = chk1;
					ptsBasics[basGen][chk2] = new Object();
					ptsBasics[basGen][chk2] = chk2;
					ptsBasics[basGen][chk3] = new Object();
					ptsBasics[basGen][chk3] = chk3;
					ptsBasics[basGen][chk4] = new Object();
					ptsBasics[basGen][chk4] = chk4;
					ptsBasics[basGen][chk5] = new Object();
					ptsBasics[basGen][chk5] = chk5;
					ptsBasics[basGen][chk6] = new Object();
					ptsBasics[basGen][chk6] = chk6;
					ptsBasics[basGen][chk7] = new Object();
					ptsBasics[basGen][chk7] = chk7;
					//ptsBasics[basGen][chk8] = new Object();
 					//ptsBasics[basGen][chk8] = chk8;
					ptsBasics[basGen][chk9] = new Object();
				   	ptsBasics[basGen][chk9] = chk9;
					ptsBasics[basGen][chk10] = new Object();
					ptsBasics[basGen][chk10] = chk10;
					ptsBasics[basGen][chk11] = new Object();
					ptsBasics[basGen][chk11] = chk11;
					ptsBasics[basGen][chk12] = new Object();
					ptsBasics[basGen][chk12] = chk12;
					ptsBasics[basGen][chk13] = new Object();
					ptsBasics[basGen][chk13] = chk13;
					ptsBasics[basGen][chk14] = new Object();
					ptsBasics[basGen][chk14] = chk14;
					ptsBasics[basGen][chk15] = new Object();
					ptsBasics[basGen][chk15] = chk15;
					ptsBasics[basGen][chk16] = new Object();
					ptsBasics[basGen][chk16] = chk16;
					ptsBasics[basGen][chk17] = new Object();
					ptsBasics[basGen][chk17] = chk17;					
					ptsBasics[basGen][chk18] = new Object();
					ptsBasics[basGen][chk18] = chk18;	
<!--- 					ptsBasics[basGen][chk19] = new Object();
					ptsBasics[basGen][chk19] = chk19; --->
<!--- 					ptsBasics[basGen][chk20] = new Object();
					ptsBasics[basGen][chk20] = chk20; --->
															
					ptsBasics[basGen][txt1] = new Object();
					ptsBasics[basGen][txt1] = txt1;
					ptsBasics[basGen][txt2] = new Object();
					ptsBasics[basGen][txt2] = txt2;
					ptsBasics[basGen][txt3] = new Object();
					ptsBasics[basGen][txt3] = txt3;
					ptsBasics[basGen][txt4] = new Object();
					ptsBasics[basGen][txt4] = txt4;
					ptsBasics[basGen][txt5] = new Object();
					ptsBasics[basGen][txt5] = txt5;
					ptsBasics[basGen][txt6] = new Object();
					ptsBasics[basGen][txt6] = txt6;
					ptsBasics[basGen][txt7] = new Object();
					ptsBasics[basGen][txt7] = txt7;
					ptsBasics[basGen][txt8] = new Object();
					ptsBasics[basGen][txt8] = txt8;
					ptsBasics[basGen][txt9] = new Object();
					ptsBasics[basGen][txt9] = txt9;
					ptsBasics[basGen][txt10] = new Object();
					ptsBasics[basGen][txt10] = txt10;
					ptsBasics[basGen][txt11] = new Object();
					ptsBasics[basGen][txt11] = txt11;
					ptsBasics[basGen][txt12] = new Object();
					ptsBasics[basGen][txt12] = txt12;
					ptsBasics[basGen][txt13] = new Object();
					ptsBasics[basGen][txt13] = txt13;
<!--- 					ptsBasics[basGen][txt14] = new Object();
					ptsBasics[basGen][txt14] = txt14; --->
					ptsBasics[basGen][txt15] = new Object();
					ptsBasics[basGen][txt15] = txt15;
					ptsBasics[basGen][txt16] = new Object();
					ptsBasics[basGen][txt16] = txt16;					
					ptsBasics[basGen][sel1] = new Object();
					ptsBasics[basGen][sel1] = sel1;

				}
				
				if (ptsBasics[basGen][basCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 > 0) {document.MyForm.Max_Duration.checked = true;}
					if (chk2 > 0) {document.MyForm.Min_Duration.checked = true;}
					if (chk3 > 0) {document.MyForm.Max_Global_Volume.checked = true;}
					if (chk4 > 0) {document.MyForm.Min_Global_Volume.checked = true;}
					<!--- if (chk19 > 0) {document.MyForm.Volume_Resolution.selectedIndex = chk19;} --->
					<!--- if (chk20 > 0) {document.MyForm.Margin_Calc_Display.selectedIndex = chk20;} --->
					if (chk5 > 0) {
									document.MyForm.Allow_Retro_Create.checked = true;
									document.MyForm.Allow_Retro_Create_Max.value 			= txt11;
								  }
					if (chk6 > 0) {document.MyForm.Adv_Spend.checked = true;}
					<!--- if (chk7 > 0) {document.MyForm.Growth_Inclusion.checked = true;} --->
<!--- 					if (chk8 > 0) {
									document.MyForm.Auto_Renew_Option.checked = true;
									document.MyForm.Auto_Renew_Lead_Time.value 				= txt14;
									
								  } --->
					
					<!--- if (chk9 == 1) {document.MyForm.Rates_By_Category[0].checked = true;} --->
					<!--- if (chk9 == 0) {document.MyForm.Rates_By_Category[1].checked = true;} --->
					if (chk10 > 0) {document.MyForm.Controllable_Volume.checked = true;}
					<!--- if (chk11 > 0) {document.MyForm.Global_GL_Assign.checked = true;} --->
					if (chk12 > 0) {document.MyForm.Specify_Distributors.checked = true;}
					if (chk13 > 0) {document.MyForm.Specify_Operators.checked = true;}
					if (chk14 > 0) {document.MyForm.Specify_Brokers.checked = true;}
					<!--- if (chk15 > 0) {document.MyForm.Specify_Products.checked = true;} --->
					<!--- if (chk16 >= 0) {document.MyForm.Global_GL_Assign_Choice.selectedIndex = chk16} --->

					if (chk17==1) {
						document.MyForm.Active[0].checked=true;
					}
					else {
						document.MyForm.Active[1].checked=true;
					}
					document.MyForm.Current_Active_State.value = chk17
				
					document.MyForm.Program_Description.value = txt13;

					if(chk1==1){
						document.MyForm.Max_Duration_Length.value = txt1;	
					}

					if(chk2==1){
						document.MyForm.Min_Duration_Length.value = txt2; 
					}					

					if(chk3==1){
						document.MyForm.Max_Global_Volume_Size_CS.value = txt3; 
						document.MyForm.Max_Global_Volume_Size_LBS.value = txt4;
<!--- 						document.MyForm.Max_Global_Volume_Size_GAL.value = txt5;
						document.MyForm.Max_Global_Volume_Size_LTR.value = txt6; 
 --->					}

					if(chk4==1){
						document.MyForm.Min_Global_Volume_Size_CS.value = txt7; 
						document.MyForm.Min_Global_Volume_Size_LBS.value = txt8;
<!--- 						document.MyForm.Min_Global_Volume_Size_GAL.value = txt9; 
						document.MyForm.Min_Global_Volume_Size_LTR.value = txt10; 
 --->					}


					document.MyForm.Adv_Spend_Amt.value 					= txt12;
					document.MyForm.Program_Editable.value 					= (txt15==false?0:1);
					document.MyForm.ProgramControl_Panel_Options_ID.value	= txt16;
					document.MyForm.Include_Trade[chk18].checked 			= true
				}
			}
		}
		if(parseInt(document.MyForm.Program_Editable.value) == 0 && document.MyForm.Active[0].checked){
			alert("Changes to This Program Will Not Be Saved Because It Is Active.")
		}

		if(parseInt(document.MyForm.Program_Editable.value) == 0 && document.MyForm.Active[1].checked){
			alert("Changes to This Program Will Not Be Saved To Insure Data Integrity.")
		}
	}
	
	function resetBasics() {
		
		document.all.Max_Duration.checked 				= false;
		document.all.Min_Duration.checked 				= false;
		document.all.Max_Global_Volume.checked 			= false;
		document.all.Min_Global_Volume.checked 			= false;
		document.all.Allow_Retro_Create.checked 		= false;
		document.all.Adv_Spend.checked 					= false;
		<!--- document.all.Auto_Renew_Option.checked 			= false; --->
		document.all.Controllable_Volume.checked 		= false;
		document.all.Specify_Distributors.checked		= false;
		document.all.Specify_Operators.checked 			= false;
		document.all.Specify_Operators.checked 			= false;
		document.all.Specify_Brokers.checked 			= false;
		<!--- document.all.Volume_Resolution.selectedIndex 	= 0; --->
		<!--- document.all.Margin_Calc_Display.selectedIndex 	= 0; --->

		document.all.Program_Description.value 				= ""
		document.all.Max_Duration_Length.value 				= "";
		document.all.Min_Duration_Length.value				= "";
		document.all.Max_Global_Volume_Size_CS.value		= "";
		document.all.Max_Global_Volume_Size_LBS.value		= "";
<!--- 		document.all.Max_Global_Volume_Size_GAL.value		= "";
		document.all.Max_Global_Volume_Size_LTR.value		= ""; --->
		document.all.Min_Global_Volume_Size_CS.value		= "";
		document.all.Min_Global_Volume_Size_LBS.value		= "";
<!--- 		document.all.Min_Global_Volume_Size_GAL.value		= "";
		document.all.Min_Global_Volume_Size_LTR.value		= ""; --->
		document.all.Allow_Retro_Create_Max.value			= "";
		<!--- document.all.Auto_Renew_Lead_Time.value				= ""; --->
		document.all.Current_Active_State.value				= "0";
		document.all.Program_Editable.value					= "1";
		document.all.ProgramControl_Panel_Options_ID.value	= "0"
		document.MyForm.Include_Trade[0].checked 			= false;
		document.MyForm.Include_Trade[1].checked 			= false;		
	}
	
	function verifyBasics() {
		ErrorCount = 0;
		//description
		if(trim(document.all.Program_Description.value).length == 0) {
			ErrorCount++;
			queueMessage("Enter A Program Description", document.all.error_Description);
		}
		else {
			clearQueue(document.all.error_Description);
		}
		
		//include trade
		if((document.all.Include_Trade[0].checked == false && document.all.Include_Trade[1].checked == false) == true) {
			ErrorCount++;
			queueMessage("You Must Make A Selection Regarding Trade Volume", document.all.error_TradeInclusion);
		}
		else {
			clearQueue(document.all.error_TradeInclusion);
		}
		
		//duration max
		if(document.all.Max_Duration.checked == true) {
			if(trim(document.all.Max_Duration_Length.value).length == 0) {
				ErrorCount++;
				queueMessage("Enter A Duration Maximum", document.all.error_MaxDuration);
			}
			else {
				clearQueue(document.all.error_MaxDuration);
			}
		}
		else{
			clearQueue(document.all.error_MaxDuration);
		}
		
		//duration min
		if(document.all.Min_Duration.checked == true) {
			if(trim(document.all.Min_Duration_Length.value).length == 0) {
				ErrorCount++;
				queueMessage("Enter A Duration Minimum", document.all.error_MinDuration);
			}
			else {
				clearQueue(document.all.error_MinDuration);
			}
		}		
		else{
			clearQueue(document.all.error_MinDuration);
		}
				
		//Maximum
		if(document.all.Max_Global_Volume.checked == true) {

			if(document.all.Max_Global_Volume_Size_CS.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Maximum Case Volume", document.all.error_MAXCS);
			}
			else {
				clearQueue(document.all.error_MAXCS);
			}
			
			if(document.all.Max_Global_Volume_Size_LBS.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Maximum Pound Volume", document.all.error_MAXLBS);
			}
			else {
				clearQueue(document.all.error_MAXLBS);
			}
		}
		else{
			clearQueue(document.all.error_MAXCS);
			clearQueue(document.all.error_MAXLBS);
		}

		//minimum
		if(document.all.Min_Global_Volume.checked == true) {

			if(document.all.Min_Global_Volume_Size_CS.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Minimum Case Volume", document.all.error_MINCS);
			}
			else {
				clearQueue(document.all.error_MINCS);
			}
			
			if(document.all.Min_Global_Volume_Size_LBS.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Minimum Pound Volume", document.all.error_MINLBS);
			}
			else {
				clearQueue(document.all.error_MINLBS);
			}
		}
		else{
			clearQueue(document.all.error_MINCS);
			clearQueue(document.all.error_MINLBS);
		}
		
		
		//allow retro
		if(document.all.Allow_Retro_Create.checked){
			if(document.all.Allow_Retro_Create_Max.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Retroactivity Maximum Duration", document.all.error_RetroDuration);
			}
			else {
				clearQueue(document.all.error_RetroDuration);
			}
		}
		else{
			clearQueue(document.all.error_RetroDuration);
		}		
		
		
<!--- 		//auto renew
		if(document.all.Auto_Renew_Option.checked){
			if(document.all.Auto_Renew_Lead_Time.value.length == 0){
				ErrorCount++;
				queueMessage("Enter A Renewal Lead Time", document.all.error_AutoRenewLeadTime);
			}
			else {
				clearQueue(document.all.error_AutoRenewLeadTime);
			}
		} --->
		
		if(ErrorCount==0){
			//compare minimum settings with maximum settings
			if(document.all.Max_Duration.checked && document.all.Min_Duration.checked) {
				if(parseInt(document.all.Min_Duration_Length.value) >=  parseInt(document.all.Max_Duration_Length.value)){
					ErrorCount++;
					queueMessage("The Duration Maximum Is Required To Be Greater Than The Minimum", document.all.error_MaxDuration);
					queueMessage("The Duration Minimum Is Required To Be Less Than The Maximum", document.all.error_MinDuration);

				}
				else {
					clearQueue(document.all.error_MaxDuration);
					clearQueue(document.all.error_MinDuration);
				}
			}
		
			//global volume
			if(document.all.Max_Global_Volume.checked && document.all.Min_Global_Volume.checked) {			
			//case

				
				if(parseInt(document.all.Max_Global_Volume_Size_CS.value) <= parseInt(document.all.Min_Global_Volume_Size_CS.value)) {
					ErrorCount++;
					queueMessage("The Case Volume Maximum Is Required To Be Greater Than The Minimum", document.all.error_MAXCS);
					queueMessage("The Case Volume Minimum Is Required To Be Less Than The Maximum", document.all.error_MINCS);
				}
				else {
					clearQueue(document.all.error_MAXCS);
					clearQueue(document.all.error_MINCS);
				}
			
			//pound
				if(parseInt(document.all.Max_Global_Volume_Size_LBS.value) <= parseInt(document.all.Min_Global_Volume_Size_LBS.value)) {
					ErrorCount++;
					queueMessage("The Pound Volume Maximum Is Required To Be Greater Than The Minimum", document.all.error_MAXLBS);
					queueMessage("The Pound Volume Minimum Is Required To Be Less Than The Maximum", document.all.error_MINLBS);
				}
				else {
					clearQueue(document.all.error_MAXLBS);
					clearQueue(document.all.error_MINLBS);
				}

			<!--- 			//Gallons
				if(parseInt(document.all.Max_Global_Volume_Size_GAL.value) <= parseInt(document.all.Min_Global_Volume_Size_GAL.value)) {
					ErrorCount++;
					queueMessage("The Gallon Volume Maximum Is Required To Be Greater Than The Minimum", document.all.error_MAXGAL);
					queueMessage("The Gallon Volume Minimum Is Required To Be Less Than The Maximum", document.all.error_MINGAL);
				}
				else {
					clearQueue(document.all.error_MAXGAL);
					clearQueue(document.all.error_MINGAL);
				}
			
			
			//litres
				if(parseInt(document.all.Max_Global_Volume_Size_LTR.value) <= parseInt(document.all.Min_Global_Volume_Size_LTR.value)) {
					ErrorCount++;
					queueMessage("The Liter Volume Maximum Is Required To Be Greater Than The Minimum", document.all.error_MAXLTR);
					queueMessage("The Liter Volume Minimum Is Required To Be Less Than The Maximum", document.all.error_MINLTR);
				}
				else {
					clearQueue(document.all.error_MAXLTR);
					clearQueue(document.all.error_MINLTR);
				} --->
			}
		}
		
		<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
		if(ErrorCount == 0) {
			return true
		}
		else {
			return false
		}	
	}
	
	
	</script>

	
<CFOUTPUT>
	<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD colspan="100%">&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"></TD>
			<TD align="right" nowrap colspan="100%"><span ID="error_Description"></span>&nbsp;<textarea style="width: 318px" name="Program_Description"></textarea></TD>
		</TR>	
		<TR BGCOLOR="White">
			<TD nowrap width="100%"></TD>
			<TD align="center" nowrap colspan="100%"><span ID="error_TradeInclusion"></span>&nbsp;<input TYPE="radio" NAME="Include_Trade" VALUE="0">Exclude Trade&nbsp;&nbsp;&nbsp;&nbsp;<input TYPE="radio" NAME="Include_Trade" VALUE="1">Include Trade</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center" nowrap><B>Include</B></TD>
			<TD align="center" nowrap><B>Entry</B></TD>
			<TD align="center" nowrap><B>UOM</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Maximum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Max_Duration" id="Max_Duration" value="1"></TD>
			<TD align="center" nowrap><span ID="error_MaxDuration"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Duration_Length" id="Max_Duration_Length" size="9"></TD>
			<TD nowrap>Days</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Minimum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Min_Duration" id="Min_Duration" value="1"></TD>
			<TD align="center" nowrap><span ID="error_MinDuration"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Min_Duration_Length" id="Min_Duration_Length" size="9"></TD>
			<TD nowrap>Days</TD>
		</TR>
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Volume Resolution</TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD align="center" nowrap><span ID="error_VolumeResolution"></span>&nbsp;
				<select name="Volume_Resolution" id="Volume_Resolution" style="width: 78;">
					<OPTION value="0">--------------</OPTION>
					<OPTION value="1">Week</OPTION>
					<OPTION value="2">Month</OPTION>
					<OPTION value="3">Quarterly</OPTION>
					<OPTION value="4">Year</OPTION>
				</SELECT>
			</TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Maximum</TD>
			<TD align="center" nowrap><input type="checkbox" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Global_Volume" id="Max_Global_Volume" value="1"></TD>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td></td>
			<TD align="center" nowrap><span ID="error_MAXCS"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Global_Volume_Size_CS" id="Max_Global_Volume_Size_CS" size="9"></TD>
			<td>Cases</td>
	 	</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MAXLBS"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Global_Volume_Size_LBS" id="Max_Global_Volume_Size_LBS" size="9"></TD>
			<td>Pounds</td>
		</tr>
<!--- 		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MAXGAL"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Global_Volume_Size_GAL" id="Max_Global_Volume_Size_GAL" size="9"></TD>
			<td>Gallons</td>
 		</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MAXLTR"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Max_Global_Volume_Size_LTR" id="Max_Global_Volume_Size_LTR" size="9"></TD>
			<td>Liters</td>
		</tr> --->
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Minimum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Min_Global_Volume" id="Min_Global_Volume" value="1"></TD>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td></td>
			<TD align="center" nowrap><span ID="error_MINCS"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Min_Global_Volume_Size_CS" id="Min_Global_Volume_Size_CS" size="9"></TD>
			<td>Cases</td>
	 	</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MINLBS"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Min_Global_Volume_Size_LBS" id="Min_Global_Volume_Size_LBS" size="9"></TD>
			<td>Pounds</td>
		</tr>
<!--- 		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MINGAL"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Min_Global_Volume_Size_GAL" id="Min_Global_Volume_Size_GAL" size="9"></TD>
			<td>Gallons</td>
 		</tr>
		<TR BGCOLOR="White">
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<TD align="center" nowrap><span ID="error_MINLTR"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Min_Global_Volume_Size_LTR" id="Min_Global_Volume_Size_LTR" size="9"></TD>
			<td>Liters</td>
		</tr> --->
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Allow Retroactive</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Allow_Retro_Create" id="Allow_Retro_Create" value="1"></TD>
			<TD align="center" nowrap><span ID="error_RetroDuration"></span>&nbsp;<input type="text" ONKEYUP="nextBox(this, 'NONE')" pageid="basics" name="Allow_Retro_Create_Max" id="Allow_Retro_Create_Max" size="9"></TD>
			<TD nowrap>Max duration</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Advanced Spending</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Adv_Spend" id="Adv_Spend" value="1"></TD>
			<TD align="center" nowrap><input type="hidden" pageid="basics" name="Adv_Spend_Amt" id="Adv_Spend_Amt"><!--- <input type="text" pageid="basics" name="Adv_Spend_Amt" id="Adv_Spend_Amt" size="9"> ---></TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Growth Inclusion Flags</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Growth_Inclusion" id="Growth_Inclusion" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Renewal Option</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Auto_Renew_Option" id="Auto_Renew_Option" value="1"></TD>
			<TD align="center" nowrap><span ID="error_AutoRenewLeadTime"></span>&nbsp;<input NAME="Auto_Renew_Lead_Time" ID="Auto_Renew_Lead_Time" TYPE="Text" SIZE="8"  ONKEYUP="nextBox(this, 'NONE')"><BR>lead time</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>

		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By Category</TD>
			<TD align="center" nowrap><input type="radio" pageid="basics" name="Rates_By_Category" id="Rates_By_Category" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By SKU/UPC</TD>
			<TD align="center" nowrap><input type="radio" pageid="basics" name="Rates_By_Category" id="Rates_By_Category" value="0" CHECKED></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Allow Advance Spending</TD>
			<TD align="center" nowrap><INPUT type="checkbox" value="1" pageid="basics" name="Adv_Spend"></TD>
			<TD align="center" nowrap><INPUT type="text" pageid="basics" name="Adv_Spend_Amt" size="9"></TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Controllable Flag</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Controllable_Volume" id="Controllable_Volume" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
	<!--- 	<TR BGCOLOR="White">
			<TD nowrap width="100%">Global GL Assignment</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Global_GL_Assign" id="Global_GL_Assign" value="1"></TD>
			<!--- <TD align="center" nowrap>&nbsp;</TD> --->
			<TD align="center" nowrap colspan="2"><img src="/Images/CLEAR.GIF" alt="" width="55" height="1" border="0">
				<select pageid="basics" name="Global_GL_Assign_Choice">
					<option value="0">Select One</option>
					<cfoutput query="getGLNames">
						<option value="#getGLNames.Deduction_Programs_And_GL_Reason_Code_ID#">#getGLNames.Program_Name#</option>
					</cfoutput>
				</select>
			</TD>
			
			<!--- <TD nowrap>&nbsp;</TD> --->
		</TR> --->
		<!--- <TR BGCOLOR="White">
			<TD nowrap width="100%">Program-specific GL</TD>
			<TD align="center" nowrap><INPUT type="checkbox" value="1" pageid="basics" name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Volume by SKU/UPC</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Volume_By_UPC" id="Volume_By_UPC" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Volume - Min by SKU/UPC</TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD align="center" nowrap><img src="/Images/CLEAR.GIF" alt="" width="57" height="1" border="0"><input type="text" pageid="basics" name="Volume_By_UPC_Min" id="Volume_By_UPC_Min"></TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Profit Margin Calculation Units</TD>
			<TD>&nbsp;</TD>
			<TD align="center" nowrap><span ID="error_MarginCalcDisplay"></span>&nbsp;
				<SELECT name="Margin_Calc_Display" id="Margin_Calc_Display">
					<OPTION value="0">---------------------</OPTION>
					<OPTION value="1">per pound</OPTION>
					<OPTION value="2">per case</OPTION>
					<OPTION value="3">percentage of revenue</OPTION>
				</SELECT>
			</TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Distributors" id="Specify_Distributors" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Operators" id="Specify_Operators" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.broker_label_singular#</cfoutput>(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Brokers" id="Specify_Brokers" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
<!--- this has been removed bu for simplicity i pass the variable as high consistantly --->
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify Product(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Products" id="Specify_Products" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
 ---></TABLE>
<input NAME="Specify_Products" TYPE="hidden" VALUE="1">

