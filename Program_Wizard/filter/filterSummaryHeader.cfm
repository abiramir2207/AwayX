<cfoutput>
		<div class="txt">
			<table width="100%" border="0" cellspacing=0 cellpadding=2>
				<tr>
			        <td class="MainRowHead">
			        	Template
			        </td>
			        <td class="MainRowHead">
			        	Filter Pack [id]
			        </td>
			        <td class="MainRowHead">
			        	Description
			        </td>
			        <!---<td class="rowHead">
			        	Market Price Lists
			        </td>--->
			    </tr>
			    <tr class="txt">
			        <td>
			        	#template.createdType#
			        </td>
			        <td>
			        	#TemplateFilter.Name# [#TemplateFilter.TEMPLATE_FILTERS_ID#]
			        </td>
			        <td>
			        	#TemplateFilter.Desc#
			        </td>
			        <!---<td>
			        	Market Price Lists: #ArrayLen(TemplateFilter.arrMarketPrice)#
			        </td>--->
			    </tr>
			</table>
			</div>
</cfoutput>