<!-----------------------------------------------------------------------------

FILE NAME:		popupExcludeMarginDetails.cfm
DESCRIPTION:	This page will popup when the user clicks on the link on the 
              excluded item in the Template details tab
CREATED BY:		Anand Rao/11-Aug-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	11-Aug-2010	Created

------------------------------------------------------------------------------> 

<cfif (isDefined("URL.MarginExclusionID") AND URL.MarginExclusionID NEQ "")>
<cfset MarginExclusionID = URL.MarginExclusionID />
<cfelse>
  <br>
  <br>
  <font color="red"><strong>INVALID CAL TO THE PAGE</strong></font> 
  <cfabort>
</cfif>
<cfset maxCols = 4 />
<cfset tdWidth = 100/maxCols />
<cfscript>
	ExcludeItemsManager = CreateObject("component","components.settings.ExcludeItemsManager");
</cfscript>

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />

<cfset ProductManager = CreateObject("component", "components.products.ProductManager") />

<cfset qGetItemExclusionProducts  = ExcludeItemsManager.getItemExclusionProducts(MarginExclusionID) />
<cfset qGetItemExclusionGroups    = ExcludeItemsManager.getItemExclusionGroups(MarginExclusionID) />
<cfset qGetItemExclusionTemplates = ExcludeItemsManager.getItemExclusionTemplates(MarginExclusionID) />


<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(qGetItemExclusionGroups.Product_Group_ID)>		
<cfset qProductList = ProductManager.getproducts(valuelist(qGetItemExclusionProducts.Product_Group_ID)) />

<cfset GroupLevelDesc = "" />
<cfloop query="qGetTopLevelGroups">
  <cfif qGetTopLevelGroups.Product_Group_Level_ID EQ qGetItemExclusionGroups.Product_Group_Level_ID>
  <cfset GroupLevelDesc = qGetTopLevelGroups.Group_Level_Desc />
  </cfif>
</cfloop>

<html>
<head>
	<title>Items to Exclude - Details</title>
</head>

<body>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Planning Group Information</LEGEND>
  <br>
  <strong>Product Group in the List:</strong>
  <cfif (isDefined("qGetApprovalGroups") AND	qGetApprovalGroups.RecordCount GTE 1)>
    <table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
      <tr>
        <td width="90" rowspan="1">
      	  <b>Item # </b> 
      	</td>
      	<td width="80" rowspan="1">
      	  <b>
            LEVEL/GROUP
          </b>
        </td>
      	<td width="80" rowspan="1">
      	  <b>DESCRIPTION</b>&nbsp;
      	</td>
      </tr>
      <cfloop query="qGetApprovalGroups">
        <tr>
          <cfoutput>
  				  <td bgcolor="eeeeee">Group Product</td>
            <td bgcolor="eeeeee">Level 1/#GroupLevelDesc#  </td>
            <td bgcolor="eeeeee">#Group_Name#</td> 
          </cfoutput>    
        </tr>
      </cfloop>
    </table>
    <cfelse>
      <b>No Product Group in this Exclusion</b> 
      <br>
      
  </cfif>
  
  <br>
    
  <strong>Products in the List:</strong>         
      <cfif isDefined("qProductList") AND qProductList.RecordCount GT 0>     
      <table cellpadding="2" cellspacing="1" width="100%" border="1" bordercolor="##979797">
          <tr>
       		<td width="90" rowspan="1">
      		  <b>Item # </b> 
      		</td>
      		<td width="80" rowspan="1">
      		  <b>
              LEVEL/GROUP
            </b>
      		</td>
      		<td width="80" rowspan="1">
      			<b>DESCRIPTION</b>&nbsp;
      		</td>
         </tr>           
        <cfloop query="qProductList">
          <tr>
          <cfoutput>
  				  <td bgcolor="eeeeee">#qProductList.Item#</td>
            <td bgcolor="eeeeee">Level 2/Product</td>
  				  <td bgcolor="eeeeee">#qProductList.Description#</td>
          </cfoutput>  
          </tr>
        </cfloop>
        </table>
    <cfelse>
      <b>No Products in this Exclusion</b> 
      <br>
      
      </cfif> 
    <br>
  
  <strong>Templates in the List:</strong>
    <cfif (isDefined("qGetItemExclusionTemplates") AND	qGetItemExclusionTemplates.RecordCount GTE 1)>      
      <cfset qComponents = CreateObject("component","components.programs.template.TemplateManager").getAllTemplates() />
        <table cellpadding="2" cellspacing="0" width="100%" border="0" align="center">			
	        <cfif qComponents.recordCount GTE 1>
            <cfset bTemplate = 0 />
          	<cfoutput query="qComponents" group="Generic_Type">
              <cfset bTemplate = 0 />
            	<cfset colsCount = 0 />
            	<tr bgcolor="FFCE8" style="height:20px">
              	<td width="100%" style="border-bottom:1px solid ##93BEE2;">&nbsp;&nbsp;<strong>#Generic_Type# templates</strong>
              	<span id="Err_Component">&nbsp;</span>			
              	</td>
      	        <td nowrap style="border-bottom:1px solid ##93BEE2;">
                  &nbsp;
  	            </td>
	            </tr>
	            <tr>
	              <td colspan="100%" style="border-left:1px solid ##93BEE2;border-right:1px solid ##93BEE2;border-bottom:1px solid ##93BEE2;">
		              <table cellpadding="1" cellspacing="1" width="100%" border="1" bordercolor="##979797">
		                <tr>
		                <cfoutput>
                      <cfloop index = "index_ID"  list ="#valueList(qGetItemExclusionTemplates.Program_Template_ID)#">
                        <cfif (index_ID EQ FIRST_PARENT_ID)><td width="#tdWidth#%"> #Created_Type#</td> 
                          <cfset colsCount = colsCount + 1 />
                          <cfset bTemplate = 1/>
                        </cfif>
                      </cfloop>
      		            <cfif colsCount GTE maxCols>
                  		  </tr><tr>
			                  <cfset colsCount = 0 />
                  		</cfif>
                		</cfoutput>
<!---                 		<cfloop from="#colsCount#" to="#maxCols#" index="i" >
                			<td width="#tdWidth#%">&nbsp;</td>
                		</cfloop> --->
                     <cfif bTemplate EQ 0>
                        <td width="100%" colspan="100%"><strong>[NONE]</strong></td>
                      </tr>
                     </cfif>
 		          </tr>
		    </table>			
      </td>
	  </tr>
	</cfoutput>
 	<cfelse>
		<tr><td>No template found</td></tr>
	</cfif>
	  <tr>
  	  <td colspan="100%">&nbsp;</td>
	  </tr>
  </table>  
    <cfelse>
      <b>No templates in this Exclusion</b>
</cfif>  
<div align="center">
  <input type="button" value="Close Window" onClick="javascript:window.close();">
</div>
</FIELDSET>
</body>
</html>

