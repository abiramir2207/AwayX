
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
	qryPrograms = TemplateFilter.getProgramList();
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
		<!---<div class="txt">
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
		</div>--->
	
	<!---**********	START position Filter	************************************--->
	<div class="txt">
		<br>&nbsp;
       <!---	<hr style="height:1;">--->
	   	<table width=500 border="0" cellspacing=0 cellpadding=2>
	   		<tr>
				<td width=500 colspan="2" width="100%" class="SubRowHead">
					<a name="PosFilterList">User Position Filter</a>
				</td>
			</tr>
			<tr>			
				 <td colspan="2" class="txt">
		        	#ArrayLen(TemplateFilter.arrPositionFilter)# Allowed Positions
		        </td>
			</tr>
			 <tr>
			 	<td width=200>&nbsp;</td>
		        <td  width=300 class="txt">
		        	<table width="100%" border="0" cellspacing=0 cellpadding=2>
		        		<tr>
					        <td class="rowHead">
					        	Position
					        </td>
					    </tr>
						<cfset idx = 0/>
						<cfset trClass = ""/>
						<cfloop array="#TemplateFilter.arrPositionFilter#" index="pf">
						<cfif (idx MOD 2) EQ 0><cfset trClass ="txtRowWh"/><cfelse><cfset trClass ="txtRowGr"/></cfif>
						<cfset idx++ />
					    <tr>
					        <td class="#trClass#">
					        	#pf.positionLabel#
					        </td>
					    </tr>
						</cfloop>
					</table>
		        </td>
		    </tr>
		</table>
	</div>
	
	<!---**********	START Program List	************************************--->

	<div class="txt">
		<br>&nbsp;
       <!---	<hr style="height:1;">--->
	   	<table width=500 border="0" cellspacing=0 cellpadding=2>
	   		<tr>
				<td width=500 colspan="2" width="100%" class="SubRowHead">
					<a name="PosFilterList">Programs</a>
				</td>
			</tr>
			<tr>			
				 <td colspan="2" class="txt">
		        	#qryPrograms.recordcount# Active Programs
		        </td>
			</tr>
			 <tr>
			 	<td width=200>&nbsp;</td>
		        <td  width=300 class="txt">
		        	<table width="100%" border="0" cellspacing=0 cellpadding=2>
		        		<tr>
					        <td class="rowHead">
					        	Number
					        </td>
							<td class="rowHead">
					        	Title
					        </td>
					    </tr>
						<cfset idx = 0/>
						<cfset trClass = ""/>
						<cfloop query="qryPrograms">
						<cfif (idx MOD 2) EQ 0><cfset trClass ="txtRowWh"/><cfelse><cfset trClass ="txtRowGr"/></cfif>
						<cfset idx++ />
					    <tr>
					        <td class="#trClass#">
					        	#qryPrograms.Number#
					        </td>
							<td class="#trClass#">
					        	#qryPrograms.title#
					        </td>
					    </tr>
						</cfloop>
					</table>
		        </td>
		    </tr>
		</table>
	</div>
	
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
		        	Updated
		        </td>
		        <td class="SubRowHead" width=300>
		        	Count
		        </td>
		    </tr>
			<tr>
		        <td class="txt">
		        	#DateFormat(mp.Start_Date,"medium")#<br/>#mp.Status#
		        </td>
				<td class="txt">
			        <cfif trim(mp.UpdatedUserName) NEQ ''> 
						#mp.UpdatedUserName#<br/>&nbsp;#dateFormat(mp.UpdatedDate,'medium')#&nbsp;#timeFormat(mp.UpdatedDate,'short')#
					</cfif>
		        </td>
		        <td class="txt">
		        	#ArrayLen(mp.arrProdRate)#
		        </td>
		    </tr>
			 <tr>
			 	<td>&nbsp;</td>
		        <td colspan=2 width=300 class="txt">
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
					        	#dollarformat(prodrate.rate)#
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
	<!---<cfdocumentsection name="Position Filter">
        <!--- Insert some HTML content here. --->
		position Filter
    </cfdocumentsection>
	
	<cfdocumentsection name="Item Filter">
        <!--- Insert some HTML content here. --->
		Item Filter
    </cfdocumentsection>
	
	<cfdocumentsection name="Customer Filter">
        <!--- Insert some HTML content here. --->
		Customer Filter
    </cfdocumentsection>--->
</cfoutput>
</cfdocument>
