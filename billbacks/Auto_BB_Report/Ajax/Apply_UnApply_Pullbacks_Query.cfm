<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR PRODUCT PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

 <cfsilent>

    <cfparam name="url.iDisplayStart"   	default="0">
    <cfparam name="url.iDisplayLength"  default="20">
    <cfparam name="url.sEcho"           		default="10">
	<cfparam name="url.iSortCol_0"			default="1">
	<cfparam name="url.sSortDir_0"			default="ASC">
	<cfparam name="url.sSearch"				default="">
	
	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 20>
	<cfif start EQ 0>
		<cfset start = 1>
	<cfelse>
		<cfset start = url.iDisplaystart + 1>
	</cfif>

		  <cfscript>
		      tmp   = structnew();
		      reply = structnew();
		      tmp.page_size   = val(url.iDisplayLength);
		      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
	          tmp.columnArray = ["Checkbox", "Operator_Name", "pullback_amount", "product_BB_volume_CS", "bb_start_date", "bb_end_date", "Contract_Title", "name", "bb_code"];    
	   </cfscript>

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
			
<!--- Get all the Opr and Local Dis BB that are already applied to this current Dis Corp BB --->
<cfset GetBillbackstoApply = PullbackManager.GetBillbackstoApplyPullback(Dis_BB_Id=url.BB_ID,appliedpullbacks=url.type,sSearch=url.sSearch,sSortDir=url.sSortDir_0,iSortCol=tmp.columnArray[url.iSortCol_0 + 1])>

<!--- Check if any Growth pullback amount is applied to this current BB --->
<cfset checkifBBhasGrowth = PullbackManager.checkifBBhasGrowth(url.BB_Id,url.type)>

	<cfif checkifBBhasGrowth.recordcount GT 0>
			<cfloop query="checkifBBhasGrowth">
					<cfset temp = QueryAddRow(GetBillbackstoApply)>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_billback_id", checkifBBhasGrowth.pullback_billback_id )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_amount", checkifBBhasGrowth.pullback_amount)>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "Product_BB_Volume_CS", checkifBBhasGrowth.volume_CS)>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_start_date", checkifBBhasGrowth.bb_start_date)>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_end_date",checkifBBhasGrowth.bb_end_date )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "contract_number",checkifBBhasGrowth.contract_number )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "Contract_Title",checkifBBhasGrowth.Contract_Title )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "Contract_Main_ID",checkifBBhasGrowth.contract_main_id )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "Name",checkifBBhasGrowth.name )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "shr_ship_to",checkifBBhasGrowth.shr_ship_to )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_code",checkifBBhasGrowth.bb_code )>
					<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_reference",checkifBBhasGrowth.bb_reference )>					
			</cfloop>
	</cfif>	

<!--- CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

<cfset tmp.GetBillbackstoApply = QueryNew("Checkbox, Operator_Name, pullback_amount, product_BB_volume_CS, bb_start_date, bb_end_date, Contract_Title, name, bb_code","varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />

<cfset filename = "Pullbacks_"&#replace(request.AccessStructure.user_id,'-','_','ALL')#&".txt">
<cfset filepath = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayPullbacks\#filename#">

<cfif FileExists(filepath)>
		<cffile action="read" file="#filepath#"	variable="selectedlist">
</cfif>

<cfquery name="totalsum" dbtype="query">
	SELECT SUM(pullback_amount) AS TA
	FROM GetBillbackstoApply
</cfquery>

<cfloop query="GetBillbackstoApply"  startrow="#start#" endrow="#end#">

	<cfset  CheckboxValue="#pullback_billback_id#|#customer_id#|#contract_number#">	
		<cfif isdefined("selectedlist") AND findnocase(CheckboxValue, selectedlist)>
				<cfset checked = "checked">
		<cfelse>
				<cfset checked = "">
		</cfif>

	<cfoutput>
			<cfset checkbox = "<"&"input type='checkbox' name='pullback_billback_growth_ids' value='#CheckboxValue#' onclick=selectpullback('#CheckboxValue#',this,0);applyamount(#GetBillbackstoApply.pullback_amount#,this,0); " &"#checked#"&" >" />
	</cfoutput>
		<cfset QueryAddRow(tmp.GetBillbackstoApply) />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "Checkbox", "#Checkbox#") />

		<cfif Operator_Is_Group OR Operator_Count GT 1>
				<cfset OperatorName = '#Operator_Name#&nbsp;&nbsp;<a style="cursor:pointer" onclick="PopupOperators('& '''#GetBillbackstoApply.CMID#''' &');"><img src="\images\info.png" border="0"></a>'>		
		<cfelse>
				<cfset OperatorName = GetBillbackstoApply.Operator_Name>
		</cfif>	
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "Operator_Name", "#OperatorName#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "pullback_amount", "#trim(DollarFormat(GetBillbackstoApply.pullback_amount))#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "product_BB_volume_CS", "#trim(NumberFormat(GetBillbackstoApply.product_BB_volume_CS,'____.__'))#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "bb_start_date", "#DateFormat(GetBillbackstoApply.bb_start_date,'MM/DD/YYYY')#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "bb_end_date", "#DateFormat(GetBillbackstoApply.bb_end_date,'MM/DD/YYYY')#") />

		<CF_CRYP STRING="#CMID#" TYPE="EN" KEY="#REQUEST.KEY#">
		<CFSET Encrypted_Contract_Main_ID = cryp.value>
		<cfset Program 	= '<a style="cursor:pointer" onclick="PopupProgram('& '''#Encrypted_Contract_Main_ID#''' &');">#GetBillbackstoApply.contract_number#</a>' />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "Contract_Title", "#lcase(GetBillbackstoApply.Contract_Title)#<br>#Program#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "name", "#GetBillbackstoApply.name#<br>#GetBillbackstoApply.shr_ship_to#") />
		<cfset QuerySetCell(tmp.GetBillbackstoApply, "bb_code", "#GetBillbackstoApply.bb_code#<br>#GetBillbackstoApply.bb_reference#") />
		
</cfloop>

    <cfset reply.iTotalRecords        = #GetBillbackstoApply.recordcount#>
    <cfset reply.iTotalDisplayRecords = #GetBillbackstoApply.recordcount#>
	
    <!--- Generate JSON from Query --->
    <cfset tmp.dArray = ArrayNew(1) >
	
<cfloop query="tmp.GetBillbackstoApply">
      	<cfset dArrayTmp = arraynew(1)>
      <cfloop array="#tmp.columnArray#" index="tmp.columnName">
        	<cfset ArrayAppend(dArrayTmp, (tmp.GetBillbackstoApply[tmp.columnName][tmp.GetBillbackstoApply.currentRow]))>
      </cfloop>
      		<cfset ArrayAppend(tmp.dArray, dArrayTmp) >
</cfloop>

    <cfset reply.aaData = tmp.dArray>
    <cfset reply.sEcho  = javacast('int', url.sEcho)>
	<cfset reply.sTotal  = NumberFormat(totalsum.ta,'____.__')>
	<cfif totalsum.ta LT 0>
		<cfset reply.sTotalType = 1>
	<cfelse>
		<cfset reply.sTotalType = 0>
	</cfif>
    <cfset tmp.sOut = SerializeJSON( reply )>
    <!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
    <cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords')>
    <cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData')>
</cfsilent>

  <!---send JSON data back to client--->
  <cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>
 