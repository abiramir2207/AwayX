<FIELDSET STYLE="padding:10px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">DISCOUNT IDENTIFICATION CODES</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Discount ID Number:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" SIZE="30" MAXLENGTH="25"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Discount ID Description:</B></TD>
			<TD><INPUT NAME="compDesc" TYPE="text" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>ERP Component Type:</B></TD>
			<TD><INPUT NAME="External_Component_Type" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="10">
			</TD>
			<TD nowrap="true"><font color="red">(leave empty for this field to be ignored)</font>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>ERP Customer Type:</B></TD>
			<TD>
			<cfoutput>
			<select name="External_Customer_Type_ID" style="width:180px;">
			<option value="0">** Select ERP Customer Type **</option>
			<option value="1">#application.returned_customer_setting.distributor_label_singular#</option>
			<option value="2">#application.returned_customer_setting.operator_label_singular#</option>
			</select>
			</cfoutput>
			</TD>
			<TD nowrap="true"><font color="red">(leave unselected for this field to be ignored)</font></TD>
		</TR>


    <tr>
      <td colspan="4">
		<br>
		<h5><u>Interface Logic:</u>&nbsp;
		<img src="/images/help_small.gif" title="When a program has this discount identifier, to determine which discount identifier to send in the program interface file see below settings.  Each discount type on a program will be interfaced with the discount identifier entered below."></h5>
		<font color="red">(If your program interface does not handle discount identifier values, do not enter any values in below fields.  Check with your system administrator.)</font>
      </td>
    </tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Fixed Price Discount Identifier:</B></td>
			<td><input name="infFixedPrice" type="text" size="25" maxlength="50"></td>
			<td align="right" nowrap="nowrap"><B>ERP Fixed Price Component Type:</B> </td>
			<td><input name="External_FixedPrice_Component_Type" type="text" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Rebate Discount Identifier:</B>  </td>
			<td><input name="infRebate" type="text" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Rebate Component Type:</B> </td>
			<td><input name="External_Rebate_Component_Type" type="text" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Lump Sum Discount Identifier:</B> </td>
			<td><input name="infLumpSum" type="text" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Lump Sum Component Type:</B></td>
			<td><input name="External_LumpSum_Component_Type" type="text" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Growth Discount Identifier:</B> </td>
			<td><input name="infGrowth" type="text" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Growth Component Type:</B> </td>
			<td><input name="External_Growth_Component_Type" type="text" size="25" maxlength="50"> </td>
		</tr>

		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addComp();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
</FIELDSET>