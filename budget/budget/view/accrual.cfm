<table class="allocation" width="900" style="border-collapse:collapse">
  <tr>
    <td colspan="7" class="allocator_main_header">[Place Holder for the Budget
    Code: Budget Name]</td>
  </tr>
  <tr>
    <td colspan="3" >[Sort] [Add Master Data] </td>
    <td >% Change  Applicator </td>
    <td colspan="3" ><input type="text" name="textfield5" />
      [apply] </td>
  </tr>
  <tr>
    <td colspan="3" >&nbsp;</td>
    <td >Rate Applicator </td>
    <td colspan="3" ><input type="text" name="textfield5" />[apply]</td>
  </tr>
  <tr><td width="37" class="allocator_sub_header">&nbsp;</td><td width="200" class="allocator_sub_header"><div align="center">Level 1 </div></td><td width="200" class="allocator_sub_header"><div align="center">Level 2 </div></td><td width="107" class="allocator_sub_header"><div align="center">Volume</div></td><td width="42" class="allocator_sub_header">UOM</td><td width="144" class="allocator_sub_header">Rate</td><td width="83" class="allocator_sub_header">Budget </td></tr>
  <form id="form1" name="form1" method="post" action="">
  <tr>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">Total</td>
    <td class="allocator_control_level_header">Total Products </td>
    <td class="allocator_control_level_header" align="right"><cfoutput>#qAllocationDataTotal.Level_Value#</cfoutput></td>
    <td class="allocator_control_level_header" >CS</td>
    <td class="allocator_control_level_header" >100%</td>
    <td class="allocator_control_level_header" >$</td>
    </tr>
  <cfoutput query="qAllocationDataSummary"><tr bgcolor="<cfif CurrentRow Mod 2>##DEFFDE</cfif>"><td>&nbsp;</td><td>Total</td><td>#Control_Level_2_Name# </td><td align="right">#LEVEL_VALUE#</td><td >CS</td><td >&nbsp;</td><td >$</td></tr></cfoutput>
  <tr>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">Customer A </td>
    <td class="allocator_control_level_header">Total Products </td>
    <td class="allocator_control_level_header"></td>
    <td class="allocator_control_level_header" >CS</td>
    <td class="allocator_control_level_header" >%</td>
    <td class="allocator_control_level_header" >$</td>
  </tr>
  <cfoutput query="qAllocationData"><tr bgcolor="<cfif CurrentRow Mod 2>##DEFFDE</cfif>"><td><input type="checkbox" name="checkbox24" value="checkbox" /></td><td> #Control_Level_1_Name# </td><td>#Control_Level_2_Name# </td><td align="right">#Level_Value#</td><td >CS</td><td ><input type="text" name="textfield2423" /></td><td >$</td></tr></cfoutput>
  </form>
  <tr>
    <td colspan="3"><div align="center">[Save]</div></td>
    <td>&nbsp;</td>
    <td colspan="3" ><div align="center">[Save &amp; Close]</div></td>
  </tr>
</table>
