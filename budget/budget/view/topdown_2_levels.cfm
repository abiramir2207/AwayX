<cfset inhibitDisplay = 1 />
<!------ <cfinclude template="data.cfm" /> ----->

<table class="allocation" width="950" style="border-collapse:collapse">
  <tr>
    <td colspan="10" class="allocator_main_header">[Place Holder for the Budget Code: Budget Name]</td>
    <td colspan="4" class="allocator_main_header">Budget Start and End Dates </td>
  </tr>
  <tr>
    <td colspan="10" >[Sort] [Add Master Data] </td>
    <td colspan="4" >&nbsp;</td>
  </tr>
  <tr>
    <td colspan="10">&nbsp;</td>
    <td colspan="4" class="allocator_manual_adj_sub_header">Manual Adjustments </td>
  </tr>
  <tr>
    <td width="20" class="allocator_sub_header">&nbsp;</td>
    <td width="51" class="allocator_sub_header"><div align="center">Level 1 </div></td>
    <td width="51" class="allocator_sub_header"><div align="center">Level 2 </div></td>
    <td width="66" class="allocator_sub_header"><div align="center">Historical Data </div></td>
    <td width="35" class="allocator_sub_header"><div align="center">% of Total </div></td>
    <td width="33" class="allocator_sub_header"><div align="center">% of Level 1 </div></td>
    <td width="50" class="allocator_sub_header"><div align="center">New Budget </div></td>
    <td width="43" class="allocator_sub_header"><div align="center">% of New Budget </div></td>
    <td width="43" class="allocator_sub_header"><div align="center">% of Level 1 Budget </div></td>
    <td width="68" class="allocator_sub_header"><div align="center">Budget Adjustment Chg % </div></td>
    <td width="144" class="allocator_manual_adj_sub_header"><div align="center">Dollar Chg </div></td>
    <td width="146" class="allocator_manual_adj_sub_header"><div align="center">% Chg </div></td>
    <td colspan="2" class="allocator_manual_adj_sub_header"><div align="center">Comments</div></td>
  </tr>
  <tr>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">Total</td>
    <td class="allocator_control_level_header">Total Products </td>
    <td class="allocator_control_level_header">$ [historic allocated value] </td>
    <td class="allocator_control_level_header">100 %</td>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">$[budget value]</td>
    <td class="allocator_control_level_header">100 % </td>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">100 %</td>
    <td class="allocator_control_level_header">$ - </td>
    <td class="allocator_control_level_header">0%</td>
    <td colspan="2" class="allocator_control_level_header">&nbsp;</td>
  </tr>
  <form id="form1" name="form1" method="post" action="">
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td class="allocator_control_level_header">
      <label></label>    </td>
    <td class="allocator_control_level_header">Customer A </td>
    <td class="allocator_control_level_header">Total Products </td>
    <td class="allocator_control_level_header">$ [some value] </td>
    <td class="allocator_control_level_header">[some %]</td>
    <td class="allocator_control_level_header">&nbsp;</td>
    <td class="allocator_control_level_header">$[some value]</td>
    <td class="allocator_control_level_header">$[some %]</td>
    <td class="allocator_control_level_header">100%</td>
    <td class="allocator_control_level_header">100%</td>
    <td class="allocator_control_level_header" >$ - </td>
    <td class="allocator_control_level_header" >0%</td>
    <td colspan="2" class="allocator_control_level_header" >&nbsp;</td>
    </tr>
	<cfoutput query="qAllocationdata">
  <tr>
    <td><input type="checkbox" name="checkbox" value="checkbox" /></td>
    <td>#Control_Level_1_Name#</td>
    <td>#Control_Level_2_Name#</td>
    <td>#Level_Value#</td>
    <td>#Level_Value_Percentage#</td>
    <td>&nbsp;</td>
    <td>#New_Level_Value#</td>
    <td>#New_Level_Value_Percentage#</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td ><input type="text" name="md_am_#CurrentRow#" /></td>
    <td ><input type="text" name="md_per_#CurrentRow#" /></td>
    <td colspan="2" ><input type="text" name="md_cm_#CurrentRow#" /></td>
    </tr>
   </cfoutput>
<!------ 
  <cfoutput query="getCrossProduct">
  <tr>
    <td><input type="checkbox" name="checkbox" value="checkbox" /></td>
    <td>#Family_Name#</td>
    <td>#Type_Code_Desc#</td>
    <td>&nsbp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td ><input type="text" name="md_am_#CurrentRow#" /></td>
    <td ><input type="text" name="md_per_#CurrentRow#" /></td>
    <td colspan="2" ><input type="text" name="md_cm_#CurrentRow#" /></td>
    </tr>
   </cfoutput>
 ----->
  </form>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td ><div align="center">[save WIP]</div></td>
    <td ><div align="center">[Apply]</div></td>
    <td width="60" ><div align="center">[Undo]</div></td>
    <td width="84" ><div align="center">[Reset]</div></td>
  </tr>
</table>