<script>
	setChecksRT=function() {
		resetRateTypes();

	ptsRT = new Object();
	
	/* Get row count */
		rtGRows= generic.getRowCount();		// generic
		rtCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < rtGRows; ++grow) 
		{
		var rtGen = generic.getField(grow, 'Generic_Type');
		ptsRT[rtGen] = new Object();
			for (var crow = 0; crow < rtCRows; ++crow) 
			{
				var rtCgen = created.getField(crow, 'Generic_Type');
				if (rtGen == rtCgen) 
				{
					var rtCreator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'RateTypeOption_1');
					var chk2 = created.getField(crow, 'RateTypeOption_2');
					var chk3 = created.getField(crow, 'RateTypeOption_3');
 					//var chk4 = created.getField(crow, 'RateTypeOption_4');
					//var chk5 = created.getField(crow, 'RateTypeOption_5');
					//var chk6 = created.getField(crow, 'RateTypeOption_6');
					//var chk7 = created.getField(crow, 'RateTypeOption_7');
					//var chk8 = created.getField(crow, 'RateTypeOption_8');							
					var chk9 = created.getField(crow, 'RateTypeDefault');
						
					ptsRT[rtGen][rtCreator] = new Object();
					ptsRT[rtGen][rtCreator] = rtCreator;
					
					ptsRT[rtGen][chk1] = new Object();
					ptsRT[rtGen][chk1] = chk1;
					ptsRT[rtGen][chk2] = new Object();
					ptsRT[rtGen][chk2] = chk2;
					ptsRT[rtGen][chk3] = new Object();
					ptsRT[rtGen][chk3] = chk3;
					//ptsRT[rtGen][chk4] = new Object();
					//ptsRT[rtGen][chk4] = chk4;
					//ptsRT[rtGen][chk5] = new Object();
					//ptsRT[rtGen][chk5] = chk5;
					//ptsRT[rtGen][chk6] = new Object();
					//ptsRT[rtGen][chk6] = chk6;
					//ptsRT[rtGen][chk7] = new Object();
					//ptsRT[rtGen][chk7] = chk7;
					//ptsRT[rtGen][chk8] = new Object();
					//ptsRT[rtGen][chk8] = chk8;
					ptsRT[rtGen][chk9] = new Object();
					ptsRT[rtGen][chk9] = chk9;					
				}

				if (ptsRT[rtGen][rtCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 == 1) {document.MyForm.RateTypeOption_1.checked = true;}
					if (chk2 == 1) {document.MyForm.RateTypeOption_2.checked = true;}
					if (chk3 == 1) {document.MyForm.RateTypeOption_3.checked = true;}
					//if (chk4 == 1) {document.MyForm.RateTypeOption_4.checked = true;}
					<!--- if (chk4 == 1) {document.MyForm.RateTypeOption_4.checked = true;} --->
					<!--- if (chk5 == 1) {document.MyForm.RateTypeOption_5.checked = true;} --->
					<!--- if (chk6 == 1) {document.MyForm.RateTypeOption_6.checked = true;} --->
					<!--- if (chk7 == 1) {document.MyForm.RateTypeOption_7.checked = true;} --->					
					<!--- if (chk8 == 1) {document.MyForm.RateTypeOption_8.checked = true;} --->					
					if(chk9 == 2) document.MyForm.RateTypeDefault[0].checked = true;
					if(chk9 == 1) document.MyForm.RateTypeDefault[1].checked = true;
					if(chk9 == 3) document.MyForm.RateTypeDefault[2].checked = true;
					if(chk9 == 4) document.MyForm.RateTypeDefault[3].checked = true;
					

				}
			}
		}
	}

	function resetRateTypes() {
		document.all.RateTypeDefault[3].checked  = true
		document.MyForm.RateTypeOption_1.checked = false;
		document.MyForm.RateTypeOption_2.checked = false;
		document.MyForm.RateTypeOption_3.checked = false;
<!--- 		document.MyForm.RateTypeOption_4.checked = false; 
		document.MyForm.RateTypeOption_6.checked = false;--->
	}
	
	function verifyRates(){
		ErrorCount=2;
		if(document.all.RateTypeOption_1.checked==true) ErrorCount--;
		if(document.all.RateTypeOption_2.checked==true) ErrorCount--;
		if(document.all.RateTypeOption_3.checked==true) ErrorCount--;
<!--- 	if(document.all.RateTypeOption_4.checked==true) ErrorCount--; 
		if(document.all.RateTypeOption_6.checked==true) ErrorCount--;	---> 

		if(ErrorCount == 2){
			queueMessage("Select At Least One Rate Type", document.all.error_RateType);
		}
		else {
			
			clearQueue(document.all.error_RateType);
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

	function maintainRateTypeDefaults(oObject) {
		if(oObject.type == "checkbox"){
			if(!oObject.checked && oObject.parentElement.nextSibling.firstChild.checked) {
				document.all.RateTypeDefault[4].checked = true
			}
			
		}
		else{
			if(oObject.checked && !oObject.parentElement.previousSibling.firstChild.checked) {
				selectNoDefault = true;
				document.all.RateTypeDefault[4].checked = selectNoDefault
			}
		}
	}
	
</script>

<CFOUTPUT>
	<TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#">
</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;<span ID="error_RateType"></span></TD>
			<TD align="center"><B>Include</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per pound</TD>
			<TD align="center"><INPUT type="checkbox" 	name="RateTypeOption_1" value="1" ONCLICK="maintainRateTypeDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" 		name="RateTypeDefault" 	value="2" ONCLICK="maintainRateTypeDefaults(this)"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per case</TD>
			<TD align="center"><INPUT type="checkbox" 	name="RateTypeOption_2" value="1" ONCLICK="maintainRateTypeDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" 		name="RateTypeDefault" 	value="1" ONCLICK="maintainRateTypeDefaults(this)"></TD>
		</TR>
 		<TR BGCOLOR="White">
			<TD nowrap width="100%">% Of Revenue</TD>
			<TD align="center"><INPUT type="checkbox" 	name="RateTypeOption_3" value="1" ONCLICK="maintainRateTypeDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" 		name="RateTypeDefault" 	value="3" ONCLICK="maintainRateTypeDefaults(this)"></TD>
		</TR>
<!---  		<TR BGCOLOR="White">
			<TD nowrap width="100%">% Of Net</TD>
			<TD align="center"><INPUT type="checkbox" 	name="RateTypeOption_4" value="1" ONCLICK="maintainRateTypeDefaults(this)"></TD>
			<TD align="center"><INPUT type="radio" 		name="RateTypeDefault" 	value="4" ONCLICK="maintainRateTypeDefaults(this)"></TD>
		</TR> --->		
		<TR BGCOLOR="White">
			<TD nowrap width="100%" ALIGN="right">no default</TD>
			<TD align="center">&nbsp;</TD>
			<TD align="center"><INPUT type="radio" 		name="RateTypeDefault" 	value="0" ></TD>
		</TR>
	</TABLE>