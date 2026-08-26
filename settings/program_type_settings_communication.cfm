<script>
	setChecksCOMM=function() {
		document.MyForm.CommRecip_1.checked = false;
		document.MyForm.CommRecip_2.checked = false;
		document.MyForm.CommRecip_3.checked = false;
		document.MyForm.CommRecip_4.checked = false;
		

	ptsCOMM = new Object();
	
	/* Get row count */
		commGRows = generic.getRowCount();		// generic
		commCRows = created.getRowCount();		// created
		
		for(var grow = 0; grow < commGRows; ++grow) 
		{
		var commGen = generic.getField(grow, 'Generic_Type');
		ptsCOMM[commGen] = new Object();
			for (var crow = 0; crow < commCRows; ++crow) 
			{
				var commCgen = created.getField(crow, 'Generic_Type');
				if (commGen == commCgen) 
				{
					var commCreator = created.getField(crow, 'Created_Type');
					
					var chk1 = created.getField(crow, 'CommRecip_1');
					var chk2 = created.getField(crow, 'CommRecip_2');
					var chk3 = created.getField(crow, 'CommRecip_3');
					var chk4 = created.getField(crow, 'CommRecip_4');
					var chk5 = created.getField(crow, 'CommRecipDefault');
						
					ptsCOMM[commGen][commCreator] = new Object();
					ptsCOMM[commGen][commCreator] = commCreator;
					
					ptsCOMM[commGen][chk1] = new Object();
					ptsCOMM[commGen][chk1] = chk1;
					ptsCOMM[commGen][chk2] = new Object();
					ptsCOMM[commGen][chk2] = chk2;
					ptsCOMM[commGen][chk3] = new Object();
					ptsCOMM[commGen][chk3] = chk3;
					ptsCOMM[commGen][chk4] = new Object();
					ptsCOMM[commGen][chk4] = chk4;
					ptsCOMM[commGen][chk5] = new Object();
					ptsCOMM[commGen][chk5] = chk5;
				}

				if (ptsCOMM[commGen][commCreator] == document.MyForm.sel.options[document.MyForm.sel.selectedIndex].innerText) {
					if (chk1 == 1) {document.MyForm.CommRecip_1.checked = true;}
					if (chk2 == 1) {document.MyForm.CommRecip_2.checked = true;}
					if (chk3 == 1) {document.MyForm.CommRecip_3.checked = true;}
					if (chk4 == 1) {document.MyForm.CommRecip_4.checked = true;}
					document.MyForm.CommRecipDefault[chk5-1].checked = true;
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
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Sales</TD>
			<TD align="center"><INPUT type="checkbox" 	name="CommRecip_1" 		value="1"></TD>
			<TD align="center"><INPUT type="radio" 		name="CommRecipDefault"	value="1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Brokers</TD>
			<TD align="center"><INPUT type="checkbox" 	name="CommRecip_2" 		value="2"></TD>
			<TD align="center"><INPUT type="radio" 		name="CommRecipDefault"	value="2"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - HQ</TD>
			<TD align="center"><INPUT type="checkbox" 	name="CommRecip_3" 		value="3"></TD>
			<TD align="center"><INPUT type="radio" 		name="CommRecipDefault"	value="3"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - Local</TD>
			<TD align="center"><INPUT type="checkbox" 	name="CommRecip_4" 		value="4"></TD>
			<TD align="center"><INPUT type="radio" 		name="CommRecipDefault"	value="4"></TD>
		</TR>
	</TABLE>