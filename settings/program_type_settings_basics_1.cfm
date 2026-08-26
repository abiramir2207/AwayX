	<script>
		//getAttributesWindow();
	function setChecksBasics() {
	
	var c = 0;
	var d = 0;
	var e = 0;

		document.MyForm.Max_Duration.checked = false;
		document.MyForm.Min_Duration.checked = false;
		document.MyForm.Max_Global_Volume.checked = false;
		document.MyForm.Min_Global_Volume.checked = false;
		document.MyForm.Allow_Retro_Create.checked = false;
		document.MyForm.Adv_Spend.checked = false;
		document.MyForm.Growth_Inclusion.checked = false;
		document.MyForm.Auto_Renew_Option.checked = false;
		document.MyForm.Rates_By_Category.checked = false;
		document.MyForm.Rates_By_UPC.checked = false;
		document.MyForm.Controllable_Volume.checked = false;
		document.MyForm.Global_GL_Assign.checked = false;
		document.MyForm.Volume_By_UPC.checked = false;
		document.MyForm.Specify_Distributors.checked = false;
		document.MyForm.Specify_Operators.checked = false;
		document.MyForm.Specify_Brokers.checked = false;
		document.MyForm.Specify_Products.checked = false;
		
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
					var chk8 = created.getField(crow, 'Auto_Renew_Option');
					var chk9 = created.getField(crow, 'Rates_By_Category');
					var chk10 = created.getField(crow, 'Rates_By_UPC');
					var chk11 = created.getField(crow, 'Controllable_Volume');
					var chk12 = created.getField(crow, 'Global_GL_Assign');
					var chk13 = created.getField(crow, 'Volume_By_UPC');
					var chk14 = created.getField(crow, 'Specify_Distributors');
					var chk15 = created.getField(crow, 'Specify_Operators');
					var chk16 = created.getField(crow, 'Specify_Brokers');
					var chk17 = created.getField(crow, 'Specify_Products');
					
					var txt1 = created.getField(crow, 'Max_Duration_Length');
					var txt2 = created.getField(crow, 'Min_Duration_Length');
					var txt3 = created.getField(crow, 'Max_Global_Volume_Size');
					var txt4 = created.getField(crow, 'Min_Global_Volume_Size');
					var txt5 = created.getField(crow, 'Allow_Retro_Create_Max');
					var txt6 = created.getField(crow, 'Adv_Spend_Amt');
					var txt7 = created.getField(crow, 'Volume_By_UPC_Min');
					
					var sel1 = created.getField(crow, 'Global_GL_Assign_Choice');
					
					var rdo1 = created.getField(crow, 'Max_Global_Volume_UOM');
					var rdo2 = created.getField(crow, 'Min_Global_Volume_UOM');

					ptsBasics[basGen][basCreator] = new Object();
					ptsBasics[basGen][basCreator] = basCreator;
					
						/*for (var i = 0; i < document.MyForm.elements.length; i++) {
							var myElement = document.MyForm.elements[i];
								if (myElement.pageid == "basics") {
								
									if (myElement.type == "text") {
									c += 1;
										ptsBasics[basGen][eval('txt' + c)] = new Object();
										ptsBasics[basGen][eval('txt' + c)] = eval('txt' + c);
									}
									d += 1;
									if (myElement.type == "select-one") {
										ptsBasics[basGen][eval('sel' + d)] = new Object();
										ptsBasics[basGen][eval('sel' + d)] = eval('sel' + d);									
									}
									e += 1;
									if (myElement.type == "checkbox") {
										ptsBasics[basGen][eval('chk' + e)] = new Object();
										ptsBasics[basGen][eval('chk' + e)] = eval('txt' + e);
									}
									f += 1;
									if (myElement.type == "radio") {
										ptsBasics[basGen][eval('rdo' + f)] = new Object();
										ptsBasics[basGen][eval('rdo' + f)] = eval('rdo' + f);
									}
									alert('rdo' + f);
								}
							}*/
							
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
					ptsBasics[basGen][chk7] = new Object();
					ptsBasics[basGen][chk8] = chk8;
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
					
					ptsBasics[basGen][sel1] = new Object();
					ptsBasics[basGen][sel1] = sel1;
					
					ptsBasics[basGen][rdo1] = new Object();
					ptsBasics[basGen][rdo1] = rdo1;
					ptsBasics[basGen][rdo2] = new Object();
					ptsBasics[basGen][rdo2] = rdo2;
				}
				
				if (ptsBasics[basGen][basCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 > 0) {document.MyForm.Max_Duration.checked = true;}
					if (chk2 > 0) {document.MyForm.Min_Duration.checked = true;}
					if (chk3 > 0) {document.MyForm.Max_Global_Volume.checked = true;}
					if (chk4 > 0) {document.MyForm.Min_Global_Volume.checked = true;}
					if (chk5 > 0) {document.MyForm.Allow_Retro_Create.checked = true;}
					if (chk6 > 0) {document.MyForm.Adv_Spend.checked = true;}
					if (chk7 > 0) {document.MyForm.Growth_Inclusion.checked = true;}
					if (chk8 > 0) {document.MyForm.Auto_Renew_Option.checked = true;}
					if (chk9 > 0) {document.MyForm.Rates_By_Category.checked = true;}
					if (chk10 > 0) {document.MyForm.Rates_By_UPC.checked = true;}
					if (chk11 > 0) {document.MyForm.Controllable_Volume.checked = true;}
					if (chk12 > 0) {document.MyForm.Global_GL_Assign.checked = true;}
					if (chk13 > 0) {document.MyForm.Volume_By_UPC.checked = true;}
					if (chk14 > 0) {document.MyForm.Specify_Distributors.checked = true;}
					if (chk15 > 0) {document.MyForm.Specify_Operators.checked = true;}
					if (chk16 > 0) {document.MyForm.Specify_Brokers.checked = true;}
					if (chk17 > 0) {document.MyForm.Specify_Products.checked = true;}
					
					document.MyForm.Max_Duration_Length.value = txt1;
					document.MyForm.Min_Duration_Length.value = txt2; 
					document.MyForm.Max_Global_Volume_Size.value = txt3; 
					document.MyForm.Min_Global_Volume_Size.value = txt4;
					document.MyForm.Allow_Retro_Create_Max.value = txt5;
					document.MyForm.Adv_Spend_Amt.value = txt6; 
					document.MyForm.Volume_By_UPC_Min.value = txt7; 
								
					document.MyForm.Global_GL_Assign_Choice.value = sel1;
					
					if (rdo1 == 1) {document.MyForm.Max_Global_Volume_UOM[0].checked = true;} else {document.MyForm.Max_Global_Volume_UOM[1].checked = true;}
					if (rdo2 == 1) {document.MyForm.Min_Global_Volume_UOM[0].checked = true;} else {document.MyForm.Min_Global_Volume_UOM[1].checked = true;}

				}
			}
		}
	}
		
	</script>

<CFOUTPUT>
	<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center" nowrap><B>Yes</B></TD>
			<TD align="center" nowrap><B>Entry</B></TD>
			<TD align="center" nowrap><B>UOM</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Maximum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Max_Duration" id="Max_Duration" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Max_Duration_Length" id="Max_Duration_Length" size="9"></TD>
			<TD nowrap>Months</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Minimum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Min_Duration" id="Min_Duration" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Min_Duration_Length" id="Min_Duration_Length" size="9"></TD>
			<TD nowrap>Months</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Maximum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Max_Global_Volume" id="Max_Global_Volume" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Max_Global_Volume_Size" id="Max_Global_Volume_Size" size="9"></TD>
			<TD nowrap>
				<input type="radio" pageid="basics" name="Max_Global_Volume_UOM" id="Max_Global_Volume_UOM" value="1">LBS &nbsp;&nbsp;&nbsp;
				<input type="radio" pageid="basics" name="Max_Global_Volume_UOM" id="Max_Global_Volume_UOM" value="2">CS
			</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Minimum</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Min_Global_Volume" id="Min_Global_Volume" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Min_Global_Volume_Size" id="Min_Global_Volume_Size" size="9"></TD>
			<TD nowrap>
				<input type="radio" pageid="basics" name="Min_Global_Volume_UOM" value="1">LBS &nbsp;&nbsp;&nbsp;
				<INPUT type="radio" value="2" pageid="basics" name="Min_Global_Volume_UOM">CS
			</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Allow Retroactive</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Allow_Retro_Create" id="Allow_Retro_Create" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Allow_Retro_Create_Max" id="Allow_Retro_Create_Max" size="9"></TD>
			<TD nowrap>Max duration</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Advanced Spending</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Adv_Spend" id="Adv_Spend" value="1"></TD>
			<TD align="center" nowrap><input type="text" pageid="basics" name="Adv_Spend_Amt" id="Adv_Spend_Amt" size="9"></TD>
			<TD nowrap>Total $</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Growth Inclusion Flags</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Growth_Inclusion" id="Growth_Inclusion" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Renewal Option</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Auto_Renew_Option" id="Auto_Renew_Option" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By Category</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Rates_By_Category" id="Rates_By_Category" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By SKU/UPC</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Rates_By_UPC" id="Rates_By_UPC" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
<!--- 		<TR BGCOLOR="White">
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
		<TR BGCOLOR="White">
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
		</TR>
		<!--- <TR BGCOLOR="White">
			<TD nowrap width="100%">Program-specific GL</TD>
			<TD align="center" nowrap><INPUT type="checkbox" value="1" pageid="basics" name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR> --->
		<TR BGCOLOR="White">
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
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.Distributor_label_singular#</cfoutput>(s)</TD>
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
			<TD nowrap width="100%">Specify Broker(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Brokers" id="Specify_Brokers" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify Product(s)</TD>
			<TD align="center" nowrap><input type="checkbox" pageid="basics" name="Specify_Products" id="Specify_Products" value="1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
	</TABLE>
	
	<script>
	c = 0;
	d = 0;
	e = 0;
	f = 0;
	</script>