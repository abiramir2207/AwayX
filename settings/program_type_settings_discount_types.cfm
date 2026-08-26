	
<script>

	function setChecksDT() {
		
		resetDiscountTypes();
			
	ptsDT = new Object();
	
	/* Get row count */
		dtGRows = generic.getRowCount();		// generic
		dtCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < dtGRows; ++grow) 
		{
		var dtGen = generic.getField(grow, 'Generic_Type');
		ptsDT[dtGen] = new Object();
			for (var crow = 0; crow < dtCRows; ++crow) 
			{
				var dtCgen = created.getField(crow, 'Generic_Type');
				if (dtGen == dtCgen) 
				{
					var dtCreator = created.getField(crow, 'Created_Type');
										
					var chk1 = created.getField(crow, 'Discount_Fixed_Prices');
					var chk2 = created.getField(crow, 'Discount_Rebates');
					var chk3 = created.getField(crow, 'Discount_Lump_Sums');
					var chk4 = created.getField(crow, 'Discount_Growth');
					var chk5 = created.getField(crow, 'Discount_Formula_Pricing');

					ptsDT[dtGen][dtCreator] = new Object();
					ptsDT[dtGen][dtCreator] = dtCreator;
					
					ptsDT[dtGen][chk1] = new Object();
					ptsDT[dtGen][chk1] = chk1;
					ptsDT[dtGen][chk2] = new Object();
					ptsDT[dtGen][chk2] = chk2;
					ptsDT[dtGen][chk3] = new Object();
					ptsDT[dtGen][chk3] = chk3;
					ptsDT[dtGen][chk4] = new Object();
					ptsDT[dtGen][chk4] = chk4;
					ptsDT[dtGen][chk5] = new Object();
					ptsDT[dtGen][chk5] = chk5;
				}

				if (ptsDT[dtGen][dtCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 == 1) {document.MyForm.Discount_Fixed_Prices.checked = true;}
					if (chk2 == 1) {document.MyForm.Discount_Rebates.checked = true;}
					if (chk3 == 1) {document.MyForm.Discount_Lump_Sums.checked = true;}
					if (chk4 == 1) {document.MyForm.Discount_Growth.checked = true;}
					if (chk5 == 1) {document.MyForm.Discount_Formula_Pricing.checked = true;}
				}
			}
		}
	}

	function resetDiscountTypes() {
		document.MyForm.Discount_Fixed_Prices.checked = false;
		document.MyForm.Discount_Rebates.checked = false;
		document.MyForm.Discount_Lump_Sums.checked = false;
		document.MyForm.Discount_Growth.checked = false;
		document.MyForm.Discount_Formula_Pricing.checked = false;
	}
	
	function verifyDiscountTypes(){
		ErrorCount=5;
		if(document.all.Discount_Fixed_Prices.checked==true) ErrorCount--;
		if(document.all.Discount_Rebates.checked==true) ErrorCount--;
		if(document.all.Discount_Lump_Sums.checked==true) ErrorCount--;
		if(document.all.Discount_Growth.checked==true) ErrorCount--;
		if(document.all.Discount_Formula_Pricing.checked==true) ErrorCount--;	

		if(ErrorCount == 5){
			queueMessage("Select At Least One Discount Type", document.all.error_DiscountType);
		}
		else {
			
			clearQueue(document.all.error_DiscountType);
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
</script>


<CFOUTPUT>
	<table width="#tablewidth#"
       border="#tableborder#"
       cellspacing="#CELLSPACING#"
       cellpadding="#CELLPADDING#"
       class="Maintable">
</CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;<span ID="error_DiscountType"></span></TD>
			<TD align="center"><B>Include</B></TD>
			<!--- <TD align="center"><B>Required</B></TD> --->
		</TR>

<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Fixed Prices</TD>
			<TD align="center"><input type="checkbox" name="Discount_Fixed_Prices" id="Discount_Fixed_Prices" value="1"></TD>
		</TR> --->

		<TR BGCOLOR="White">
			<TD nowrap width="100%">Fixed Price</TD>
			<TD align="center"><input type="checkbox" name="Discount_Fixed_Prices" id="Discount_Fixed_Prices" value="1"></TD>
		</TR>

		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT>s</TD>
			<TD align="center"><input type="checkbox" name="Discount_Rebates" id="Discount_Rebates" value="1"></TD>
		</TR>

		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT>s</TD>
			<TD align="center"><input type="checkbox" name="Discount_Lump_Sums" id="Discount_Lump_Sums" value="1"></TD>
		</TR>

		<TR BGCOLOR="White">
			<TD nowrap width="100%">Growth</TD>
			<TD align="center"><input type="checkbox" name="Discount_Growth" id="Discount_Growth" value="1"></TD>
		</TR>					

		<TR BGCOLOR="White">
			<TD nowrap width="100%">Formula Pricing</TD>
			<TD align="center"><input type="checkbox" name="Discount_Formula_Pricing" id="Discount_Formula_Pricing" value="1"></TD>
		</TR>					

<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rebate - Straight</TD>
			<TD align="center"><input type="checkbox" name="Rebate_Basic" id="Rebate_Basic" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="RB_Required" id="RB_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rebate - Step-wise</TD>
			<TD align="center"><input type="checkbox" name="Rebate_Step_Wise" id="Rebate_Step_Wise" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="RSW_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rebate - Retro</TD>
			<TD align="center"><input type="checkbox" name="Rebate_Retro" id="Rebate_Retro" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="RR_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Lump Sum - Open</TD>
			<TD align="center"><input type="checkbox" name="Lump_Sum_Open" id="Lump_Sum_Open" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="LSO_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Lump Sum - Timed</TD>
			<TD align="center"><input type="checkbox" name="Lump_Sum_Timed" id="Lump_Sum_Timed" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="LST_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Lump Sum - Growth</TD>
			<TD align="center"><input type="checkbox" name="Lump_Sum_Growth" id="Lump_Sum_Growth" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="LSG_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Fixed Price</TD>
			<TD align="center"><input type="checkbox" name="Fixed_Price" id="Fixed_Price" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="FP_Required"></TD> --->
		</TR>
		--->
		
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Delivered Price</TD>
			<TD align="center"><input type="checkbox" name="Delivered_Price" id="Delivered_Price" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="DP_Required"></TD> --->
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">FOB Price</TD>
			<TD align="center"><input type="checkbox" name="FOB_Price" id="FOB_Price" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="FOB_Required"></TD> --->
		</TR> --->
<!--- 		<TR BGCOLOR="White">
			<TD nowrap width="100%">Show both Del and FOB</TD>
			<TD align="center"><input type="checkbox" name="Del_And_FOB_Price" id="Del_And_FOB_Price" value="1"></TD>
			<!--- <TD align="center"><INPUT type="checkbox" value="1" name="DFP_Required"></TD> --->
		</TR> ---> 
	</TABLE>