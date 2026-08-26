<script>

	function setChecksCMech() {
		resetClaimMechs();
		
	ptsCMech = new Object();
	
	/* Get row count */
		cmechGRows = generic.getRowCount();		// generic
		cmechCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < cmechGRows; ++grow) 
		{
		var cmechGen = generic.getField(grow, 'Generic_Type');
		ptsCMech[cmechGen] = new Object();
			for (var crow = 0; crow < cmechCRows; ++crow) 
			{
				var cmechCgen = created.getField(crow, 'Generic_Type');
				if (cmechGen == cmechCgen) 
				{
					var cmechCreator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'ClaimMechOption_1');
					var chk2 = created.getField(crow, 'ClaimMechOption_2');
					var chk3 = created.getField(crow, 'ClaimMechOption_3');
					var chk4 = created.getField(crow, 'ClaimMechOption_4');
					var chk5 = created.getField(crow, 'ClaimMechDefaultOption');
					
					ptsCMech[cmechGen][cmechCreator] = new Object();
					ptsCMech[cmechGen][cmechCreator] = cmechCreator;
					
					ptsCMech[cmechGen][chk1] = new Object();
					ptsCMech[cmechGen][chk1] = chk1;
					ptsCMech[cmechGen][chk2] = new Object();
					ptsCMech[cmechGen][chk2] = chk2;
					ptsCMech[cmechGen][chk3] = new Object();
					ptsCMech[cmechGen][chk3] = chk3;
					ptsCMech[cmechGen][chk4] = new Object();
					ptsCMech[cmechGen][chk4] = chk4;
					ptsCMech[cmechGen][chk5] = new Object();
					ptsCMech[cmechGen][chk5] = chk5;
				}

				if (ptsCMech[cmechGen][cmechCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 == 1) {document.MyForm.ClaimMechOption_1.checked = true;}
					if (chk2 == 1) {document.MyForm.ClaimMechOption_2.checked = true;}
					if (chk3 == 1) {document.MyForm.ClaimMechOption_3.checked = true;}
					if (chk4 == 1) {document.MyForm.ClaimMechOption_4.checked = true;}
					if (chk5 != 0)document.MyForm.ClaimMechDefaultOption[chk5-1].checked = true;
				}
			}
		}
	}
	
	function resetClaimMechs() {
		document.MyForm.ClaimMechDefaultOption[4].checked = true;
		document.MyForm.ClaimMechOption_1.checked = false;
		document.MyForm.ClaimMechOption_2.checked = false;
		document.MyForm.ClaimMechOption_3.checked = false;
		document.MyForm.ClaimMechOption_4.checked = false;
	}
	
	function verifyClaimMechs(){
		ErrorCount=4;
		if(document.all.ClaimMechOption_1.checked==true) ErrorCount--;
		if(document.all.ClaimMechOption_2.checked==true) ErrorCount--;
		if(document.all.ClaimMechOption_3.checked==true) ErrorCount--;
		if(document.all.ClaimMechOption_4.checked==true) ErrorCount--;	

		if(ErrorCount == 4){
			queueMessage("Select At Least One Claim Mechanic", document.all.error_ClaimMech);
		}
		else {
			
			clearQueue(document.all.error_ClaimMech);
			ErrorCount=0;
		}

		
		<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
		if(ErrorCount == 0) {
			return true
		}
		else {
			return false
		}	
											
	}

	function maintainClaimMechDefaults(oObject) {
		if(oObject.type == "checkbox"){
			if(!oObject.checked && oObject.parentElement.nextSibling.firstChild.checked) {
				document.all.ClaimMechDefaultOption[4].checked = true
			}
			
		}
		else{
			if(oObject.checked && !oObject.parentElement.previousSibling.firstChild.checked) {
				selectNoDefault = true;
				document.all.ClaimMechDefaultOption[4].checked = selectNoDefault
			}
		}
	}		
</script>

	<CFOUTPUT>
		<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
	</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;<span id="error_ClaimMech"></span></TD>
			<TD align="center"><B>Include</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Off-Invoice</TD>
			<TD align="center"><INPUT type="checkbox" name="ClaimMechOption_1" value="1" ONCLICK="maintainClaimMechDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="ClaimMechDefaultOption" value="1" ONCLICK="maintainClaimMechDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Billback Request</TD>
			<TD align="center"><INPUT type="checkbox" name="ClaimMechOption_2" value="2" ONCLICK="maintainClaimMechDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="ClaimMechDefaultOption" value="2" ONCLICK="maintainClaimMechDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Payment</TD>
			<TD align="center"><INPUT type="checkbox" name="ClaimMechOption_3" value="3" ONCLICK="maintainClaimMechDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="ClaimMechDefaultOption" value="3" ONCLICK="maintainClaimMechDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Credit</TD>
			<TD align="center"><INPUT type="checkbox" name="ClaimMechOption_4" value="4" ONCLICK="maintainClaimMechDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="ClaimMechDefaultOption" value="4" ONCLICK="maintainClaimMechDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">no default</TD>
			<TD align="center">&nbsp;</TD>
			<TD align="center"><INPUT type="radio" name="ClaimMechDefaultOption" value="0"></TD>
		</TR>		
	</TABLE>