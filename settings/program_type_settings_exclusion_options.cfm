	
	<script>

	function setChecksEO() {
		document.MyForm.chkProgAdj_1.checked = false;
		document.MyForm.chkProgAdj_2.checked = false;
		document.MyForm.chkProgAdj_3.checked = false;
		document.MyForm.chkProgAdj_4.checked = false;
		document.MyForm.chkProgAdj_5.checked = false;
		
		document.MyForm.reqProgAdj_1.checked = false;
		document.MyForm.reqProgAdj_2.checked = false;
		document.MyForm.reqProgAdj_3.checked = false;
		document.MyForm.reqProgAdj_4.checked = false;
		document.MyForm.reqProgAdj_5.checked = false;
		
		document.MyForm.reqProgAdj_1.disabled = true;
		document.MyForm.reqProgAdj_2.disabled = true;
		document.MyForm.reqProgAdj_3.disabled = true;
		document.MyForm.reqProgAdj_4.disabled = true;
		document.MyForm.reqProgAdj_5.checked = false;

	
	ptsEO = new Object();
	
	/* Get row count */
		eoGRows = generic.getRowCount();		// generic
		eoCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < eoGRows; ++grow) 
		{
		var eoGen = generic.getField(grow, 'Generic_Type');
		ptsEO[eoGen] = new Object();
			for (var crow = 0; crow < eoCRows; ++crow) 
			{
				var eoCgen = created.getField(crow, 'Generic_Type');
				if (eoGen == eoCgen) 
				{
					var eoCreator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'Global_Prog_Adj');
					var chk2 = created.getField(crow, 'Adj_Prod_Prog');
					var chk3 = created.getField(crow, 'Deduct_Trade');
					var chk4 = created.getField(crow, 'Pullback_Trade');
					var chk5 = created.getField(crow, 'Auto_Deduct');
					
					var req1 = created.getField(crow, 'GPA_Required');
					var req2 = created.getField(crow, 'APP_Required');
					var req3 = created.getField(crow, 'DT_Required');
					var req4 = created.getField(crow, 'PT_Required');
					var req5 = created.getField(crow, 'AD_Required');
					

					ptsEO[eoGen][eoCreator] = new Object();
					ptsEO[eoGen][eoCreator] = eoCreator;
					
					ptsEO[eoGen][chk1] = new Object();
					ptsEO[eoGen][chk1] = chk1;
					ptsEO[eoGen][chk2] = new Object();
					ptsEO[eoGen][chk2] = chk2;
					ptsEO[eoGen][chk3] = new Object();
					ptsEO[eoGen][chk3] = chk3;
					ptsEO[eoGen][chk4] = new Object();
					ptsEO[eoGen][chk4] = chk4;
					ptsEO[eoGen][chk5] = new Object();
					ptsEO[eoGen][chk5] = chk5;

					ptsEO[eoGen][req1] = new Object();
					ptsEO[eoGen][req1] = req1;
					ptsEO[eoGen][req2] = new Object();
					ptsEO[eoGen][req2] = req2;
					ptsEO[eoGen][req3] = new Object();
					ptsEO[eoGen][req3] = req3;
					ptsEO[eoGen][req4] = new Object();
					ptsEO[eoGen][req4] = req4;
					ptsEO[eoGen][req5] = new Object();
					ptsEO[eoGen][req5] = req5;
				}
				
				if (ptsEO[eoGen][eoCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 > 0) {document.MyForm.chkProgAdj_1.checked = true;}
					if (chk2 > 0) {document.MyForm.chkProgAdj_2.checked = true;}
					if (chk3 > 0) {document.MyForm.chkProgAdj_3.checked = true;}
					if (chk4 > 0) {document.MyForm.chkProgAdj_4.checked = true;}
					if (chk5 > 0) {document.MyForm.chkProgAdj_5.checked = true;}
					
					if (req1 == 1) {document.MyForm.reqProgAdj_1.disabled = false; 
									document.MyForm.reqProgAdj_1.checked = true;}
					if (req2 == 1) {document.MyForm.reqProgAdj_2.disabled = false; 
									document.MyForm.reqProgAdj_2.checked = true;}
					if (req3 == 1) {document.MyForm.reqProgAdj_3.disabled = false; 
									document.MyForm.reqProgAdj_3.checked = true;}
					if (req4 == 1) {document.MyForm.reqProgAdj_4.disabled = false; 
									document.MyForm.reqProgAdj_4.checked = true;}
					if (req5 == 1) {document.MyForm.reqProgAdj_5.disabled = false; 
									document.MyForm.reqProgAdj_5.checked = true;}			
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
			<TD align="center"><B>Include</B></TD>
			<TD align="center"><B>Required</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global program adjustments</TD>
			<TD align="center"><INPUT type="checkbox" name="chkProgAdj_1" id="chkProgAdj_1" value="1" onclick="if(this.checked == true){this.form.reqProgAdj_1.disabled=false; this.form.chkProgAdj_2.disabled = true;}else{this.form.reqProgAdj_1.disabled=true;  this.form.chkProgAdj_2.disabled = false;}"></TD>
			<TD align="center"><INPUT type="checkbox" name="reqProgAdj_1" id="reqProgAdj_1" value="1" disabled></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Adjust by product/program</TD>
			<TD align="center"><INPUT type="checkbox" name="chkProgAdj_2" id="chkProgAdj_2" value="2" onclick="if(this.checked == true){this.form.reqProgAdj_2.disabled=false;   this.form.chkProgAdj_1.disabled = true;}else{this.form.reqProgAdj_2.disabled=true;   this.form.chkProgAdj_1.disabled = false;}"></TD>
			<TD align="center"><INPUT type="checkbox" name="reqProgAdj_2" id="reqProgAdj_2" value="1" disabled></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Deduct Trade from Fixed</TD>
			<TD align="center"><INPUT type="checkbox" name="chkProgAdj_3" id="chkProgAdj_3" value="3" onclick="if(this.checked == true){this.form.reqProgAdj_3.disabled=false}else{this.form.reqProgAdj_3.disabled=true}"></TD>
			<TD align="center"><INPUT type="checkbox" name="reqProgAdj_3" id="reqProgAdj_3" value="1" disabled></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Pullback from Trade</TD>
			<TD align="center"><INPUT type="checkbox" name="chkProgAdj_4" id="chkProgAdj_4" value="4" onclick="if(this.checked == true){this.form.reqProgAdj_4.disabled=false}else{this.form.reqProgAdj_4.disabled=true}"></TD>
			<TD align="center"><INPUT type="checkbox" name="reqProgAdj_4" id="reqProgAdj_4" value="1" disabled></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Deduct Notice</TD>
			<TD align="center"><INPUT type="checkbox" name="chkProgAdj_5" id="chkProgAdj_5" value="5" onclick="if(this.checked == true){this.form.reqProgAdj_5.disabled=false}else{this.form.reqProgAdj_5.disabled=true}"></TD>
			<TD align="center"><INPUT type="checkbox" name="reqProgAdj_5" id="reqProgAdj_5" value="1" disabled></TD>
		</TR>
	</TABLE>