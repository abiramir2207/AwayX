<script>

function setChecksCPR() {
		resetCPR();
		
<!--- 		document.MyForm.reqClaimPerfReq_1.checked = false;
		document.MyForm.reqClaimPerfReq_2.checked = false;
		document.MyForm.reqClaimPerfReq_3.checked = false;
		document.MyForm.reqClaimPerfReq_4.checked = false;
		document.MyForm.reqClaimPerfReq_5.checked = false;
		document.MyForm.reqClaimPerfReq_6.checked = false;
		document.MyForm.reqClaimPerfReq_7.checked = false;
		document.MyForm.reqClaimPerfReq_8.checked = false;
		document.MyForm.reqClaimPerfReq_9.checked = false;
		
		document.MyForm.reqClaimPerfReq_1.disabled = true;
		document.MyForm.reqClaimPerfReq_2.disabled = true;
		document.MyForm.reqClaimPerfReq_3.disabled = true;
		document.MyForm.reqClaimPerfReq_4.disabled = true;
		document.MyForm.reqClaimPerfReq_5.disabled = true;
		document.MyForm.reqClaimPerfReq_6.disabled = true;
		document.MyForm.reqClaimPerfReq_7.disabled = true;
		document.MyForm.reqClaimPerfReq_8.disabled = true;
		document.MyForm.reqClaimPerfReq_9.disabled = true; --->

	jchBlank = new Object();
	jchBlank[""] = "Existing Created Types(s)";
		
	jchDB = new Object();
	
	/* Get row count */
		nGRows = generic.getRowCount();		// columns
		nCRows = created.getRowCount();	
		
		for(var grow = 0; grow < nGRows; ++grow) 
		{
		var gen = generic.getField(grow, 'Generic_Type');
		jchDB[gen] = new Object();
			for (var crow = 0; crow < nCRows; ++crow) 
			{
				var cgen = created.getField(crow, 'Generic_Type');
				if (gen == cgen) 
				{
					var creator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'Invoice_Billback');
					var chk2 = created.getField(crow, 'Claim_Period');
					var chk3 = created.getField(crow, 'Item_Number');
					var chk4 = created.getField(crow, 'Total_Dollar_Pound');
					var chk5 = created.getField(crow, 'Menu_Listing');
					var chk6 = created.getField(crow, 'Branded_Point_Of_Sale');
					var chk7 = created.getField(crow, 'Mandated_Specification');
					var chk8 = created.getField(crow, 'Optional_Specification');
					var chk9 = created.getField(crow, 'Feature_Sheet');
					
					var req1 = created.getField(crow, 'IB_Required');
					var req2 = created.getField(crow, 'CP_Required');
					var req3 = created.getField(crow, 'IN_Required');
					var req4 = created.getField(crow, 'TDP_Required');
					var req5 = created.getField(crow, 'ML_Required');
					var req6 = created.getField(crow, 'BPOS_Required');
					var req7 = created.getField(crow, 'MS_Required');
					var req8 = created.getField(crow, 'OS_Required');
					var req9 = created.getField(crow, 'FS_Required');	
			
					jchDB[gen][creator] = new Object();
					jchDB[gen][creator] = creator;
					
					jchDB[gen][chk1] = new Object();
					jchDB[gen][chk1] = chk1;
					jchDB[gen][chk2] = new Object();
					jchDB[gen][chk2] = chk2;
					jchDB[gen][chk3] = new Object();
					jchDB[gen][chk3] = chk3;
					jchDB[gen][chk4] = new Object();
					jchDB[gen][chk4] = chk4;
					jchDB[gen][chk5] = new Object();
					jchDB[gen][chk5] = chk5;
					jchDB[gen][chk6] = new Object();
					jchDB[gen][chk6] = chk6;
					jchDB[gen][chk7] = new Object();
					jchDB[gen][chk7] = chk7;
					jchDB[gen][chk8] = new Object();
					jchDB[gen][chk8] = chk8;
					jchDB[gen][chk9] = new Object();
					jchDB[gen][chk9] = chk9;
					
					jchDB[gen][req1] = new Object();
					jchDB[gen][req1] = req1;
					jchDB[gen][req2] = new Object();
					jchDB[gen][req2] = req2;
					jchDB[gen][req3] = new Object();
					jchDB[gen][req3] = req3;
					jchDB[gen][req4] = new Object();
					jchDB[gen][req4] = req4;
					jchDB[gen][req5] = new Object();
					jchDB[gen][req5] = req5;
					jchDB[gen][req6] = new Object();
					jchDB[gen][req6] = req6;
					jchDB[gen][req7] = new Object();
					jchDB[gen][req7] = req7;
					jchDB[gen][req8] = new Object();
					jchDB[gen][req8] = req8;
					jchDB[gen][req9] = new Object();
					jchDB[gen][req9] = req9;
					
				}
				if (jchDB[gen][creator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 > 0) {document.MyForm.chkClaimPerfReq_1.checked = true;}
					if (chk2 > 0) {document.MyForm.chkClaimPerfReq_2.checked = true;}
					if (chk3 > 0) {document.MyForm.chkClaimPerfReq_3.checked = true;}
					if (chk4 > 0) {document.MyForm.chkClaimPerfReq_4.checked = true;}
					if (chk5 > 0) {document.MyForm.chkClaimPerfReq_5.checked = true;}
					if (chk6 > 0) {document.MyForm.chkClaimPerfReq_6.checked = true;}
					if (chk7 > 0) {document.MyForm.chkClaimPerfReq_7.checked = true;}
					if (chk8 > 0) {document.MyForm.chkClaimPerfReq_8.checked = true;}
					if (chk9 > 0) {document.MyForm.chkClaimPerfReq_9.checked = true;}
					
					/*
 					if (req1 == 1) {document.MyForm.reqClaimPerfReq_1.disabled = false; 
									document.MyForm.reqClaimPerfReq_1.checked = true;}
					if (req2 == 1) {document.MyForm.reqClaimPerfReq_2.disabled = false; 
									document.MyForm.reqClaimPerfReq_2.checked = true;}
					if (req3 == 1) {document.MyForm.reqClaimPerfReq_3.disabled = false; 
									document.MyForm.reqClaimPerfReq_3.checked = true;}
					if (req4 == 1) {document.MyForm.reqClaimPerfReq_4.disabled = false; 
									document.MyForm.reqClaimPerfReq_4.checked = true;}
					if (req5 == 1) {document.MyForm.reqClaimPerfReq_5.disabled = false; 
									document.MyForm.reqClaimPerfReq_5.checked = true;}
					if (req6 == 1) {document.MyForm.reqClaimPerfReq_6.disabled = false; 
									document.MyForm.reqClaimPerfReq_6.checked = true;}
					if (req7 == 1) {document.MyForm.reqClaimPerfReq_7.disabled = false; 
									document.MyForm.reqClaimPerfReq_7.checked = true;}
					if (req8 == 1) {document.MyForm.reqClaimPerfReq_8.disabled = false; 
									document.MyForm.reqClaimPerfReq_8.checked = true;}
					if (req9 == 1) {document.MyForm.reqClaimPerfReq_9.disabled = false; 
									document.MyForm.reqClaimPerfReq_9.checked = true;} */
					
				}
			}
		}
	}

	function resetCPR() {
		document.MyForm.chkClaimPerfReq_1.checked = false;
		document.MyForm.chkClaimPerfReq_2.checked = false;
		document.MyForm.chkClaimPerfReq_3.checked = false;
		document.MyForm.chkClaimPerfReq_4.checked = false;
		document.MyForm.chkClaimPerfReq_5.checked = false;
		document.MyForm.chkClaimPerfReq_6.checked = false;
		document.MyForm.chkClaimPerfReq_7.checked = false;
		document.MyForm.chkClaimPerfReq_8.checked = false;
		document.MyForm.chkClaimPerfReq_9.checked = false;	
	}
</script>


	<CFOUTPUT>
		<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
	</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Include</B></TD>
			<!--- <TD align="center"><B>Required</B></TD> --->
			<!--- <TD align="center"><B>Default</B></TD> --->
		</TR>
			 
			 			  <tr bgcolor="white">
						  	<TD nowrap width="100%">Invoice/Billback</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_1" id="chkClaimPerfReq_1" value="1"></td>
						    <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_1" id="reqClaimPerfReq_1" value="1" disabled></td> --->
			              	<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_1" disabled name="defClaimPerfReq_1"></TD> --->
						  </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Claim Period</TD>
			                <td  ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_2" id="chkClaimPerfReq_2" value="2"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_2" id="reqClaimPerfReq_2" value="1" disabled></td>	 --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_2" disabled name="defClaimPerfReq_2"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Item #'s w/Qty &amp; Rates</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_3" id="chkClaimPerfReq_3" value="3"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_3" id="reqClaimPerfReq_3" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_3" disabled name="defClaimPerfReq_3"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Total $'s &amp; lbs</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_4" id="chkClaimPerfReq_4" value="4"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_4" id="reqClaimPerfReq_4" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_4" disabled name="defClaimPerfReq_4"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Menu Listing</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_5" id="chkClaimPerfReq_5" value="5"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_5" id="reqClaimPerfReq_5" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_5" disabled name="defClaimPerfReq_5"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Branded Point of Sale</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_6" id="chkClaimPerfReq_6" value="6"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_6" id="reqClaimPerfReq_6" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_6" disabled name="defClaimPerfReq_6"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Mandated Specification</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_7" id="chkClaimPerfReq_7" value="7"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_7" id="reqClaimPerfReq_7" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_7" disabled name="defClaimPerfReq_7"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Optional Specification</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_8" id="chkClaimPerfReq_8" value="8"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_8" id="reqClaimPerfReq_8" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_8" disabled name="defClaimPerfReq_8"></TD> --->
			              </tr>
			              <tr bgcolor="white">
						  	<TD nowrap width="100%">Feature Sheet/Flyer</TD>
			                <td ALIGN="center"><input type="checkbox" name="chkClaimPerfReq_9" id="chkClaimPerfReq_9" value="9"></td>
			                <!--- <td align="center"><input type="checkbox" name="reqClaimPerfReq_9" id="reqClaimPerfReq_9" value="1" disabled></td> --->
							<!--- <TD align="center"><INPUT type="radio" value="defClaimPerfReq_9" disabled name="defClaimPerfReq_9"></TD> --->
			              </tr>
		</TABLE>