<script>
	setChecksPC=function() {
 		resetPaymentCycle();
 
	ptsPC = new Object();
	
	/* Get row count */
		pcGRows = generic.getRowCount();		// generic
		pcCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < pcGRows; ++grow) 
		{
		var pcGen = generic.getField(grow, 'Generic_Type');
		ptsPC[pcGen] = new Object();
			for (var crow = 0; crow < pcCRows; ++crow) 
			{
				var pcCgen = created.getField(crow, 'Generic_Type');
				if (pcGen == pcCgen) 
				{
					var pcCreator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'PayCycleOption_1');
					var chk2 = created.getField(crow, 'PayCycleOption_2');
					var chk3 = created.getField(crow, 'PayCycleOption_3');
					var chk4 = created.getField(crow, 'PayCycleOption_4');
					var chk5 = created.getField(crow, 'PayCycleOption_5');
					var chk6 = created.getField(crow, 'PayCycleOption_6');
					var chk7 = created.getField(crow, 'PayCycleOption_7');					
					var chk8 = created.getField(crow, 'PayCycleDefaultOption');
						
					ptsPC[pcGen][pcCreator] = new Object();
					ptsPC[pcGen][pcCreator] = pcCreator;
					
					ptsPC[pcGen][chk1] = new Object();
					ptsPC[pcGen][chk1] = chk1;
					ptsPC[pcGen][chk2] = new Object();
					ptsPC[pcGen][chk2] = chk2;
					ptsPC[pcGen][chk3] = new Object();
					ptsPC[pcGen][chk3] = chk3;
					ptsPC[pcGen][chk4] = new Object();
					ptsPC[pcGen][chk4] = chk4;
					ptsPC[pcGen][chk5] = new Object();
					ptsPC[pcGen][chk5] = chk5;
					ptsPC[pcGen][chk6] = new Object();
					ptsPC[pcGen][chk6] = chk6;
					ptsPC[pcGen][chk7] = new Object();
					ptsPC[pcGen][chk7] = chk7;
					ptsPC[pcGen][chk8] = new Object();
					ptsPC[pcGen][chk8] = chk8;
				}

				if (ptsPC[pcGen][pcCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 == 1) {document.MyForm.PayCycleOption_1.checked = true;}
					if (chk2 == 1) {document.MyForm.PayCycleOption_2.checked = true;}
					if (chk3 == 1) {document.MyForm.PayCycleOption_3.checked = true;}
					if (chk4 == 1) {document.MyForm.PayCycleOption_4.checked = true;}
					if (chk5 == 1) {document.MyForm.PayCycleOption_5.checked = true;}
					if (chk6 == 1) {document.MyForm.PayCycleOption_6.checked = true;}
					<!--- if (chk7 == 1) {document.MyForm.PayCycleOption_7.checked = true;} --->					
					if(chk8 != 0) document.MyForm.PayCycleDefaultOption[chk8-1].checked = true;
				}
			}
		}
	}
	
	function resetPaymentCycle() {
		document.MyForm.PayCycleDefaultOption[6].checked = true;
		document.MyForm.PayCycleOption_1.checked = false;
		document.MyForm.PayCycleOption_2.checked = false;
		document.MyForm.PayCycleOption_3.checked = false;
		document.MyForm.PayCycleOption_4.checked = false;
		document.MyForm.PayCycleOption_5.checked = false;
		document.MyForm.PayCycleOption_6.checked = false;	
	}
	
	function verifyPaymentCycle(){
		ErrorCount=6;
		if(document.all.PayCycleOption_1.checked==true) ErrorCount--;
		if(document.all.PayCycleOption_2.checked==true) ErrorCount--;
		if(document.all.PayCycleOption_3.checked==true) ErrorCount--;
		if(document.all.PayCycleOption_4.checked==true) ErrorCount--;
		if(document.all.PayCycleOption_5.checked==true) ErrorCount--;	
		if(document.all.PayCycleOption_6.checked==true) ErrorCount--;
		
		if(ErrorCount == 6){
			queueMessage("Select At Least One Payment Cycle Option", document.all.error_PaymentCycle);
		}
		else {
			
			clearQueue(document.all.error_PaymentCycle);
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
	
	function maintainPaymentDefaults(oObject) {
		if(oObject.type == "checkbox"){
			if(!oObject.checked && oObject.parentElement.nextSibling.firstChild.checked) {
				document.all.PayCycleDefaultOption[6].checked = true
			}
			
		}
		else{
			if(oObject.checked && !oObject.parentElement.previousSibling.firstChild.checked) {
				selectNoDefault = true;
				document.all.PayCycleDefaultOption[6].checked = selectNoDefault
			}
		}
	}	
</script>

	<CFOUTPUT>
		<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
	</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;<span ID="error_PaymentCycle"></span></TD>
			<TD align="center"><B>Include</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Daily</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_1" value="1" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="1" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Weekly</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_2" value="2" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="2" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Monthly</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_3" value="3" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="3" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Quarterly</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_4" value="4" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="4" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Semi-Annual</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_5" value="5" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="5" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Annual</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_6" value="6" ONCLICK="maintainPaymentDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="6" ONCLICK="maintainPaymentDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">no default</TD>
			<TD align="center">&nbsp;</TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="0"></TD>
		</TR>		
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Use Fiscal Calendar</TD>
			<TD align="center"><INPUT type="checkbox" name="PayCycleOption_7" value="7"></TD>
			<TD align="center"><INPUT type="radio" name="PayCycleDefaultOption" value="7"></TD>
		</TR> --->
	</TABLE>