<cfparam name="form.RankOrder" default="">

<cfset variables.Ranklist="1,2,3">

<FIELDSET STYLE="padding:10px; width: 73%; border: 1px solid Blue;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Ranking Alias Management</LEGEND>
<span><b>Please select the ranking in which the aliases will be displayed. 1 is the highest ranking and will be used first</b></span>
<table border="0" align="center" cellpadding="3">
<cfoutput>

<!--- Distributor --->
<cfset variables.qgetDistributorLevelRanking = AliasManager.getDistributorLevelRanking(0)>

<tr>
 <td><span id="error_Distributor"></span><b>#DistributorSingularLabel#<b></td>
 <td>
  <select name="RankOrder_1" id="RankOrder_1">
    <option value="">NONE</option>
    <cfloop list="#variables.Ranklist#" index="i">
	<option value="#i#" <cfif variables.qgetDistributorLevelRanking.Alias_Management_Ranking eq i>selected</cfif>>#i#</option>
    </cfloop>
  </select>
 </td>
</tr>

<!--- Family --->
<cfset variables.qgetDistributorLevelRanking = AliasManager.getDistributorLevelRanking(2)>

<tr>
 <td><span id="error_Family"></span><b>#FamilySingularlabel#<b></td>
 <td>
  <select name="RankOrder_2" id="RankOrder_2">
    <option value="">NONE</option>
    <cfloop list="#variables.Ranklist#" index="i">
	<option value="#i#" <cfif variables.qgetDistributorLevelRanking.Alias_Management_Ranking eq i>selected</cfif>>#i#</option>
    </cfloop>
  </select>
 </td>
</tr>

<!--- Buying Group --->
<cfset variables.qgetDistributorLevelRanking = AliasManager.getDistributorLevelRanking(3)>

<tr>
 <td><span id="error_BuyingGroup"></span><b>#BuyingGroupSingularlabel#<b></td>
 <td>
  <select name="RankOrder_3" id="RankOrder_3">
    <option value="">NONE</option>
    <cfloop list="#variables.Ranklist#" index="i">
	<option value="#i#" <cfif variables.qgetDistributorLevelRanking.Alias_Management_Ranking eq i>selected</cfif>>#i#</option>
    </cfloop>
  </select>
 </td>
</tr>
</cfoutput>

<tr>
<td colspan="100%" align="center">
<CF_button
	button_name	=""
	button_caption	="save"
	button_action	="javascript:submitDataFormCommandRanking('Ranking');"
	button_type	= "javascript_link"
	button_width	="100"
	button_color	="Navy"
	button_tip	=""
	font_color	="White"
	font_size	="12"
	font_weight	="bold"
>
</td>
</tr>
</table>
</FIELDSET>

<input type="hidden" name="Shr_Ship_To">
<input type="hidden" name="Family_Name">
<input type="hidden" name="Buying_Group">


	
