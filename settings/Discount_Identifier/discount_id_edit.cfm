<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("Discount identification code already exists.");
	</script>
</cfif>

<FIELDSET STYLE="padding:10px; width: 750px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">DISCOUNT IDENTIFICATION CODES</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Discount ID Number:</B></TD>
			<TD><INPUT NAME="compName" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.Discount_Identifier_Number#</cfoutput>" SIZE="30" MAXLENGTH="25"></TD>
		</TR>		
		<TR>
			<TD ALIGN="right"><B>Discount ID Description:</B></TD>
			<TD><INPUT NAME="compDesc" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.Discount_Identifier_Desc#</cfoutput>" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- Tim Ford: Label D24189 - Removed ERP Component Type and added ERP discount component types below --->
		<TR>
			<TD ALIGN="right"><B>ERP Component Type:</B></TD>
			<TD><INPUT NAME="External_Component_Type" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.External_Component_Type#</cfoutput>" SIZE="30" MAXLENGTH="10">
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
			<option value="1" <cfif qGetCompRebates.External_Customer_Type_ID EQ 1>selected</cfif>>#application.returned_customer_setting.distributor_label_singular#</option>
			<option value="2" <cfif qGetCompRebates.External_Customer_Type_ID EQ 2>selected</cfif>>#application.returned_customer_setting.operator_label_singular#</option>
			</select>
			<!--- <font color="red">(leave unselected for this field to be ignored)</font> --->
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
	<!--- Tim Ford: added ERP discount component types --->

		<tr>
			<td align="right" nowrap="nowrap"><B>Fixed Price Discount Identifier:</B></td>
			<td><input name="infFixedPrice" type="text" value="<cfoutput>#qGetCompRebates.Interface_For_FixedPrice#</cfoutput>" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Fixed Price Component Type:</B> </td>
			<td><input name="External_FixedPrice_Component_Type" type="text" value="<cfoutput>#qGetCompRebates.External_FixedPrice_Component_Type#</cfoutput>" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Rebate Discount Identifier:</B> </td>
			<td><input name="infRebate" type="text" value="<cfoutput>#qGetCompRebates.Interface_For_Rebate#</cfoutput>" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Rebate Component Type:</B> </td>
			<td><input name="External_Rebate_Component_Type" type="text" value="<cfoutput>#qGetCompRebates.External_Rebate_Component_Type#</cfoutput>" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Lump Sum Discount Identifier:</B></td>
			<td><input name="infLumpSum" type="text" value="<cfoutput>#qGetCompRebates.Interface_For_LumpSum#</cfoutput>" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Lump Sum Component Type:</B></td>
			<td><input name="External_LumpSum_Component_Type" type="text" value="<cfoutput>#qGetCompRebates.External_LumpSum_Component_Type#</cfoutput>" size="25" maxlength="50"> </td>
		</tr>
		<tr>
			<td align="right" nowrap="nowrap"><B>Growth Discount Identifier:</B> </td>
			<td><input name="infGrowth" type="text" value="<cfoutput>#qGetCompRebates.Interface_For_Growth#</cfoutput>" size="25" maxlength="50"> </td>
			<td align="right" nowrap="nowrap"><B>ERP Growth Component Type:</B> </td>
			<td><input name="External_Growth_Component_Type" type="text" value="<cfoutput>#qGetCompRebates.External_Growth_Component_Type#</cfoutput>" size="25" maxlength="50"> </td>
		</tr>	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return upadateComp(#qGetCompRebates.Discount_Identifier_ID#);"
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