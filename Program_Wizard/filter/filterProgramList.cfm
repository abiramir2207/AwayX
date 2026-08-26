

<!--- Summary view of current Template Filter Pack config --->
<cfparam name="url.TemlateFiltersId" type="numeric" default="0"/>
<cfparam name="url.TemlateId" type="numeric" default="0"/> 
<cfscript>
	TemplateFilter = createObject("component", "mvc.models.Template.TemplateFilter").init();//url.TemlateFiltersId
	templateManager = CreateObject("component","components.programs.template.TemplateManager");
	templateManager.get(url.TemlateId);
	template = templateManager.template;
	arrTemplateFilters = template.TemplateFilters;
	
	for (i=1;i LTE ArrayLen(arrTemplateFilters);i=i+1) {
		if(arrTemplateFilters[i].Template_Filters_Id == url.TemlateFiltersId){
			TemplateFilter = arrTemplateFilters[i];
			break;
		}
	}
</cfscript>
<!--- cfdocument pdf attribute collection ---> 
<cfset pdfdef = structNew()> 
<cfset pdfdef.format = "PDF"> 
<cfset pdfdef.orientation = "portrait"> 
<cfset pdfdef.pageType = "letter"> 
<cfset pdfdef.mimeType = "text/html"> 
<cfset pdfdef.pageType = "letter"> 
<cfset pdfdef.marginLeft = .5> 
<cfset pdfdef.marginRight = .5> 
<cfset pdfdef.marginTop = .5> 
<cfset pdfdef.marginBottom = .5> 
<cfset pdfdef.bookmark = 1>


<cfdocument attributeCollection="#pdfdef#">

	<!---<cfdocumentsection name="Overview">--->
	<cfinclude template="/program_Wizard/filter/filterCSS.cfm" />
	
	<cfoutput>
		<cfdocumentitem type="header">
        	<font size="-3" ><i>Template: #template.createdType#  ::  Filter Pack: #TemplateFilter.Name# [#TemplateFilter.TEMPLATE_FILTERS_ID#]</i></font>
	    </cfdocumentitem>
	    <cfdocumentitem type="footer">
	        <font size="-3">Page #cfdocument.currentpagenumber#</font>
	    </cfdocumentitem>
		
	<cfinclude template="/program_Wizard/filter/filterSummaryHeader.cfm" />	
		
	<!---**********	START MP	************************************--->
	<div class="txt">
       	<!---<hr style="height:1;">--->
		<br>&nbsp;
	   	<table width="500" border="0" cellspacing=0 cellpadding=2>
	   		<!---<tr>
				<td colspan="2" class="txt" width="475">
					<a name="MPList">Market Price List</a>
				</td>
			</tr>--->
			<cfloop array="#TemplateFilter.arrMarketPrice#" index="mp">
		    <tr>
		        <td class="SubRowHead" width=200>
		        	Market Price List Start
		        </td>
		        <td class="SubRowHead" width=300>
		        	Count
		        </td>
		    </tr>
			<tr>
		        <td class="txt">
		        	#DateFormat(mp.Start_Date,"medium")# :: #mp.Status#
		        </td>
		        <td class="txt">
		        	#ArrayLen(mp.arrProdRate)#
		        </td>
		    </tr>
			 <tr>
			 	<td></td>
		        <td width=300 class="txt">
		        	<table width="100%" border="0" cellspacing=0 cellpadding=2>
		        		<tr>
					        <td class="rowHead">
					        	item
					        </td>
					        <td class="rowHead">
					        	rate
					        </td>
					    </tr>
						<cfset idx = 0/>
						<cfset trClass = ""/>
						<cfloop array="#mp.arrProdRate#" index="prodrate">
						<cfif (idx MOD 2) EQ 0><cfset trClass ="txtRowWh"/><cfelse><cfset trClass ="txtRowGr"/></cfif>
						<cfset idx++ />
					    <tr>
					        <td class="#trClass#">
					        	#prodrate.itemNumber#
					        </td>
					        <td class="#trClass#">
					        	#prodrate.rate#
					        </td>
					    </tr>
						</cfloop>
					</table>
		        </td>
		    </tr>
			</cfloop>
		</table>
	</div>
   <!--- </cfdocumentsection>--->

	

</cfoutput>
</cfdocument>
