<CFSET PAGE_TITLE="Search Contracts...">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/top_header.cfm">

<CFPARAM NAME="FORM.ES_ExternalSearch_Flag" DEFAULT="0">
	<CF_Next_Previous_FormBased_FormOutput
		maxrows=10
		ParentFileName="#templatename#"
		addparams = "FORM.ES_ExternalSearch_Flag,FORM.ES_group,FORM.ES_finaldestination,FORM.ES_multipleselections,FORM.ES_itemid,FORM.ES_tabgroup,FORM.ES_urlinterfacestring,contract_number,QTY_Compare,QTY_Value,contract_title,Broker,Operator,Distributor,Type_Group_Desc,Type_Code_Desc,Q_Brand_Desc,Brand,contract_status,template,uom"
	>
<!--- diaplay the right set of tabs --->
<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
	<CFSWITCH EXPRESSION="#FORM.ES_group#">
		<CFCASE VALUE="payables">
			<CF_CRYP type="de" string="#FORM.ES_itemid#" key="#request.key#">
			<CFSET temp = cryp.value>
			<CFSET PSL_Payable_ID = temp>
			<CFSET PSL_CallingPageCode = "ct"> 
			<CFINCLUDE TEMPLATE="../payables2/payable_status_legend.cfm">
		</CFCASE>
	</CFSWITCH>
</CFIF>




<!--- diaplay the right set of minimal info --->
<CFIF FORM.ES_ExternalSearch_Flag EQ 1>
	<CFSWITCH EXPRESSION="#FORM.ES_group#">
		<CFCASE VALUE="payables">
			<CFSET helpfilenumber=5>
			<CFSET MPI_Payable_ID = temp>
			<cfinclude template="../payables2/minimal_payable_info.cfm">
		</CFCASE>
	</CFSWITCH>
</CFIF>



<BLOCKQUOTE><BLOCKQUOTE>

<SPAN CLASS="title2">Supplied Contract Search Criteria:</SPAN>
<HR COLOR="Orange">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the description of the contractstatus codes												 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfswitch expression = #contract_status#>
  <cfcase value = "0">
	  <CFSET status_description="All Contract Status">
  </cfcase>
  <cfcase value = "1">
	  <CFSET status_description="Work in Progress">
  </cfcase>
  <cfcase value = "2">
	  <CFSET status_description="Preactive Contracts">
  </cfcase>
  <cfcase value = "3">
	  <CFSET status_description="Active Contracts">
  </cfcase>
  <cfcase value = "4">
	  <CFSET status_description="Archived/Expired">
  </cfcase>
  <cfcase value = "5">
	  <CFSET status_description="Expiring in 8 weeks or less">
  </cfcase>
</cfswitch>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the types of contracts retrieved										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfswitch expression = #TEMPLATE#>
  <cfcase value = "0">
	  <CFSET contract_type="<FONT COLOR=""Gray"">Contracts Only</FONT>">
  </cfcase>
  <cfcase value = "1">
	  <CFSET contract_type="<FONT COLOR=""Red""><B>Templates only</B></FONT>">
  </cfcase>
  <cfcase value = "2">
	  <CFSET contract_type="<FONT COLOR=""Red""><B>Contracts & Templates</B></FONT>">
  </cfcase>
</cfswitch>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all of the UOM descriptions																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF uom NEQ "All">
	<CFQUERY NAME="Get_UOM" datasource="#application.datasource#">
	Select	*
	From	Units_of_Measure
	Where	Unit_of_Measure_ID	=	#uom#
	</CFQUERY>
<CFELSE>
	<CFSET Get_UOM = QueryNew("Unit_of_Measure_Desc")>
	<CFSET temp = QueryAddRow(Get_UOM)>
	<CFSET temp = QuerySetCell(Get_UOM, "Unit_of_Measure_Desc", "Any U.O.M.")>
</CFIF>





<CFOUTPUT>
	<TABLE border="0" cellspacing="0" CELLPADDING="1" WIDTH="800">
		<TR>
			<TD NOWRAP><B>Contract Number:</B></TD>
			<TD NOWRAP><CFIF contract_number EQ ""><FONT COLOR="Gray">Any Contract Number</FONT><CFELSE><FONT COLOR="Red"><B>#contract_number#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Quantity & U.O.M.:</B></TD>
			<TD NOWRAP><CFIF QTY_Compare EQ "All"><FONT COLOR="Gray">Any Quantity</FONT><CFELSE><FONT COLOR="Red"><B>#QTY_Compare# #numberformat(QTY_Value, '_,___,___,___,___')#</B></FONT></CFIF>									<FONT COLOR="Gray"> / </FONT>			<CFIF uom EQ "All"><FONT COLOR="Gray">Any UOM</FONT><CFELSE><FONT COLOR="Red"><B>#Get_UOM.Unit_of_Measure_Desc#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Title:</B></TD>
			<TD NOWRAP><CFIF contract_title EQ ""><FONT COLOR="Gray">Any Title</FONT><CFELSE><FONT COLOR="Red"><B>#contract_title#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Broker:</B></TD>
			<TD NOWRAP><CFIF Broker EQ ""><FONT COLOR="Gray">All Brokers</FONT><CFELSE><FONT COLOR="Red"><B>#Broker#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>#application.returned_customer_setting.operator_label_singular#:</B></TD>
			<TD NOWRAP><CFIF Operator EQ ""><FONT COLOR="Gray">All #application.returned_customer_setting.operator_label_plural#</FONT><CFELSE><FONT COLOR="Red"><B>#Operator#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>:</B></TD>
			<TD NOWRAP><CFIF Distributor EQ ""><FONT COLOR="Gray">All #application.returned_customer_setting.distributor_label_plural#</FONT><CFELSE><FONT COLOR="Red"><B>#Distributor#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Type Group Descriptions:</B></TD>
			<TD NOWRAP><CFIF Type_Group_Desc EQ "All"><FONT COLOR="Gray">All Type Groups</FONT><CFELSE><FONT COLOR="Red"><B><cf_changecase string="#Type_Group_Desc#" result="Desc">#Desc#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Type Code Descriptions:</B></TD>
			<TD NOWRAP><CFIF Type_Code_Desc EQ "All"><FONT COLOR="Gray">All Type Codes</FONT><CFELSE><FONT COLOR="Red"><B><cf_changecase string="#Type_Code_Desc#" result="Desc">#Desc#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Q Brand Descriptions:</B></TD>
			<TD NOWRAP><CFIF Q_Brand_Desc EQ "All"><FONT COLOR="Gray">All Q Brands</FONT><CFELSE><FONT COLOR="Red"><B><cf_changecase string="#Q_Brand_Desc#" result="Desc">#Desc#</B></FONT></CFIF></TD>
		</TR>
		<TR>
			<TD NOWRAP><B>Brands:</B></TD>
			<TD NOWRAP><CFIF Brand EQ "All"><FONT COLOR="Gray">All Brands</FONT><CFELSE><FONT COLOR="Red"><B><cf_changecase string="#Brand#" result="Desc">#Desc#</B></FONT></CFIF></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><B>Contract Status:</B></TD>
			<TD NOWRAP><FONT COLOR="Red"><B>#status_description#</B></FONT></TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP>Contract Type:</TD>
			<TD NOWRAP>#contract_type#</TD>
		</TR>

		<TR>
			<TD COLSPAN="8"><BR></TD>
		</TR>


		<TR>
			<TD><B>Status codes:</B></TD>
			<TD NOWRAP><IMG SRC="/Images/expiring.gif" ALIGN="middle"> Expiring in < 8 weeks</TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><IMG SRC="/Images/active.gif" ALIGN="middle"> Active</TD>
			<TD NOWRAP><IMG SRC="/Images/preactive.gif" ALIGN="middle"> Pre-Active</TD>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
			<TD NOWRAP><IMG SRC="/Images/wip.gif" ALIGN="middle"> Work in progress</TD>
			<TD NOWRAP><IMG SRC="/Images/expired.gif" ALIGN="middle"> Expired contracts</TD>
			<TD NOWRAP></TD>
		</TR>



	</TABLE>
</CFOUTPUT>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the brokers in this contract											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Is there a request for broker match? --->
<CFSET brokerflag=0>
<CFSET brokerlist="">
<CFIF trim(Broker) NEQ "">
	<!--- get the id's of the brokers that have this string in their name --->
	<CFQUERY NAME="Get_Broker_Data" datasource="#application.datasource#">
	Select			BSA_Foodservice_Brokers_ID as list
	From			BSA_Foodservice_Brokers
	Where			(
					Broker_Name LIKE '#Broker#%'	or
					Broker_Name LIKE '%#Broker#'	or
					Broker_Name LIKE '%#Broker#%'	or
					Broker_Name LIKE '#Broker#'
					)
					and
					deleted = 0
	</CFQUERY>
	<CFSET Brokerflag=1>
	<CFIF Get_Broker_Data.recordcount GT 0>
		<CFSET Brokerlist=valuelist(Get_Broker_Data.list)>
	<CFELSE>
		<CFSET Brokerlist="99999999999999999">
	</CFIF>
</CFIF>

<!--- 
<CFELSE>
	<CFSET Brokerflag=0>
 --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the operators in this contract										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Is there a request for operator match? --->
<CFSET Operatorflag=0>
<CFSET Operatorlist="">
<CFIF trim(Operator) NEQ "">
	<!--- get the id's of the operators that have this string in their name --->
	<CFQUERY NAME="Get_Operator_Data" datasource="#application.datasource#">
	Select			BSA_Operator_ID as list
	From			BSA_Operator
	Where			(
					operator_name LIKE '#Operator#%'	or
					operator_name LIKE '%#Operator#'	or
					operator_name LIKE '%#Operator#%'	or
					operator_name LIKE '#Operator#'
					)
					and
					deleted = 0
	</CFQUERY>
	<CFSET Operatorflag=1>
	<CFIF Get_Operator_Data.recordcount GT 0>
		<CFSET Operatorlist=valuelist(Get_Operator_Data.list)>
	<CFELSE>
		<CFSET Operatorlist="99999999999999999">
	</CFIF>
</CFIF>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the descriptions of the distributors in this contract										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Is there a request for distributors match? --->
<CFSET distributorflag=0>
<CFSET distributorlist="">
<CFIF trim(distributor) NEQ "">
	<!--- get the id's of the distributor that have this string in their name --->
	<CFQUERY NAME="Get_distributor_Data" datasource="#application.datasource#">
	Select			BSA_Foodservice_Customers_ID as list
	From			BSA_Foodservice_Customers
	Where			(
					Name LIKE '#distributor#%'	or
					Name LIKE '%#distributor#'	or
					Name LIKE '%#distributor#%'	or
					Name LIKE '#distributor#'
					)
					and
					deleted = 0
	</CFQUERY>
	<CFSET distributorflag=1>
	<CFIF Get_distributor_Data.recordcount GT 0>
		<CFSET distributorlist=valuelist(Get_distributor_Data.list)>
	<CFELSE>
		<CFSET distributorlist="99999999999999999">
	</CFIF>
</CFIF>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the Type_Group_Desc selected something besides ALL											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Type_Group_Desc_Flag=0>
<CFSET contractsidslist="">
<CFIF Type_Group_Desc NEQ "All">

	<!--- Get all the products that match Type_Group_Desc...											 --->
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	Select		UPC
	From		BSA_Foodservice_Items_Master
	Where		rtrim(Type_Group_Desc)	= '#Type_Group_Desc#'
	</CFQUERY>
	
	<!--- ...and now get the record ids of the contracts that have these products						 --->
	<CFQUERY NAME="Get_Contract_IDs" datasource="#application.datasource#">
	Select		distinct Contract_Main_ID
	From		Contract_Products
 	Where		(
				<cfset conj = "">
					<cfloop list="#valuelist(Get_Products.UPC)#" index="K" delimiters = ",">
						#conj# Product_UPC	= '#K#'
					<cfset conj="or">
				</cfloop>
				)
	</CFQUERY>
	
	<CFSET Type_Group_Desc_Flag=1>
	<CFIF Get_Contract_IDs.recordcount GT 0>
		<CFSET contractsidslist=valuelist(Get_Contract_IDs.Contract_Main_ID)>
	<CFELSE>
		<CFSET contractsidslist="999999999">
	</CFIF>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the Type_Code_Desc selected something besides ALL											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Type_Code_Desc_Flag=0>
<CFSET contractsidslist2="">
<CFIF Type_Code_Desc NEQ "All">

	<!--- Get all the products that match Type_Code_Desc...												 --->
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	Select		UPC
	From		BSA_Foodservice_Items_Master
	Where		rtrim(Type_Code_Desc) = '#Type_Code_Desc#'
	</CFQUERY>
	
	<!--- ...and now get the record ids of the contracts that have these products						 --->
	<CFQUERY NAME="Get_Contract_IDs" datasource="#application.datasource#">
	Select		distinct Contract_Main_ID
	From		Contract_Products
 	Where		(
				<cfset conj = "">
					<cfloop list="#valuelist(Get_Products.UPC)#" index="K" delimiters = ",">
						#conj# Product_UPC	= '#K#'
					<cfset conj="or">
				</cfloop>
				)
	</CFQUERY>
	
	<CFSET Type_Code_Desc_Flag=1>
	<CFIF Get_Contract_IDs.recordcount GT 0>
		<CFSET contractsidslist2=valuelist(Get_Contract_IDs.Contract_Main_ID)>
	<CFELSE>
		<CFSET contractsidslist2="999999999">
	</CFIF>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the Q_Brand_Desc selected something besides ALL											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Q_Brand_Desc_Flag=0>
<CFSET contractsidslist3="">
<CFIF Q_Brand_Desc NEQ "All">

	<!--- Get all the products that match Q_Brand_Desc...											 --->
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	Select		UPC
	From		BSA_Foodservice_Items_Master
	Where		rtrim(Q_Brand_Desc)	= '#Q_Brand_Desc#'
	</CFQUERY>
	
	<!--- ...and now get the record ids of the contracts that have these products						 --->
	<CFQUERY NAME="Get_Contract_IDs" datasource="#application.datasource#">
	Select		distinct Contract_Main_ID
	From		Contract_Products
 	Where		(
				<cfset conj = "">
					<cfloop list="#valuelist(Get_Products.UPC)#" index="K" delimiters = ",">
						#conj# Product_UPC	= '#K#'
					<cfset conj="or">
				</cfloop>
				)
	</CFQUERY>
	
	<CFSET Q_Brand_Desc_Flag=1>
	<CFIF Get_Contract_IDs.recordcount GT 0>
		<CFSET contractsidslist3=valuelist(Get_Contract_IDs.Contract_Main_ID)>
	<CFELSE>
		<CFSET contractsidslist3="999999999">
	</CFIF>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- If the Brand selected something besides ALL													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Brand_Flag=0>
<CFSET contractsidslist4="">
<CFIF Brand NEQ "All">

	<!--- Get all the products that match Q_Brand_Desc...											 --->
	<CFQUERY NAME="Get_Products" datasource="#application.datasource#">
	Select		UPC
	From		BSA_Foodservice_Items_Master
	Where		rtrim(Brand)	= '#Brand#'
	</CFQUERY>

	<!--- ...and now get the record ids of the contracts that have these products						 --->
	<CFQUERY NAME="Get_Contract_IDs" datasource="#application.datasource#">
	Select		distinct Contract_Main_ID
	From		Contract_Products
 	Where		(
				<cfset conj = "">
					<cfloop list="#valuelist(Get_Products.UPC)#" index="K" delimiters = ",">
						#conj# Product_UPC	= '#K#'
					<cfset conj="or">
				</cfloop>
				)
	</CFQUERY>
	
	<CFSET Brand_Flag=1>
	<CFIF Get_Contract_IDs.recordcount GT 0>
		<CFSET contractsidslist4=valuelist(Get_Contract_IDs.Contract_Main_ID)>
	<CFELSE>
		<CFSET contractsidslist4="999999999">
	</CFIF>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main query to Get contract data																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Contracts" datasource="#application.datasource#">
Select		Contract_Main.*,
			Units_of_Measure.*

From		Contract_Main,
			Units_of_Measure

Where		Contract_Main.Contract_Quantity_uom_IDX	=	Units_of_Measure.Unit_of_Measure_ID
			
			<!--- Look for contract number --->
			<CFIF trim(contract_number) NEQ "">
					and
					Contract_Number =  '#trim(contract_number)#'
			</CFIF>
			<!--- End of Look for contract number --->

			<!--- Look for qty --->
			<CFIF trim(QTY_Value) NEQ "" AND QTY_Compare NEQ "All">
				<CFIF #QTY_Compare# EQ "Greater than">
					and
					Contract_Quantity >  #trim(QTY_Value)#
				<CFELSEIF #QTY_Compare# EQ "Equal to">
					and
					Contract_Quantity =  #trim(QTY_Value)#
				<CFELSE>
					and
					Contract_Quantity <  #trim(QTY_Value)#
				</CFIF>
			</CFIF>
			<!--- End of Look for qty --->

			<!--- Look for string in contract title --->
			<CFIF trim(contract_title) NEQ "">
					and
					(
					Contract_Title LIKE '#contract_title#%'		or
					Contract_Title LIKE '%#contract_title#'		or
					Contract_Title LIKE '%#contract_title#%'	or
					Contract_Title LIKE '#contract_title#'		
					)
			</CFIF>
			<!--- End of Look for string in contract title --->

			<!--- Look for a match in the broker field --->
			<CFIF brokerflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#brokerlist#" index="i" delimiters = ",">
						#conj# ',' + broker_ids + ',' LIKE '%,#i#,%'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for broker --->

			<!--- Look for a match in the operator field --->
			<CFIF operatorflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#Operatorlist#" index="j" delimiters = ",">
						#conj# ',' + operator_id + ',' LIKE '%,#j#,%'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for operator --->

			<!--- Look for a match in the distributor field --->
			<CFIF distributorflag GT 0>
					and
					(
					<cfset conj = "">
					<cfloop list="#distributorlist#" index="k" delimiters = ",">
						#conj# ',' + distributor_ids + ',' LIKE '%,#k#,%'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look for distributor --->


			
			<!--- Look at the contract status if it's About to EXPIRE --->
			<CFIF contract_status EQ 5>
					and
					DATEDIFF(day, getdate(), Contract_End_Date) < 56
					and
					Approval_Date IS NOT NULL
			</CFIF>
			<!--- End of Look at the contract status if it's About ot EXPIRE --->

			
			
			
			


			<!--- Look at the contract status if it's WIP --->
			<CFIF contract_status EQ 1>
					and
					Approval_Date IS NULL
			</CFIF>
			<!--- End of Look at the contract status if it's WIP --->

			
			
			
			
			
			<!--- Look at the contract status if it's Pre-Active --->
			<CFIF contract_status EQ 2>
					and
					Contract_Start_Date > #createodbcdatetime(now())#
					and
					Approval_Date IS NOT NULL
			</CFIF>
			<!--- End of Look at the contract status if it's Pre-Active --->

			
			
			<!--- Look at the contract status if it's Active --->
			<CFIF contract_status EQ 3>
					and
					Contract_Start_Date <= #createodbcdatetime(now())#
					and
					Contract_End_Date >= #createodbcdatetime(now())#
					and 
					Approval_Date IS NOT NULL
			</CFIF>
			<!--- End of Look at the contract status if it's Active --->
			
			
			
			
			
			
			
			
			<!--- Look at the contract status if it's Expired --->
			<CFIF contract_status EQ 4>
					and
					(
					contract_status_type_IDX = 4 or DATEDIFF(day, getdate(), Contract_End_Date) < 0
					)
			</CFIF>
			<!--- End of Look at the contract status if it's Expired --->

			<!--- Look if the Type_Group_Desc has been selected --->
			<CFIF Type_Group_Desc_Flag EQ 1>
					and
					(
					<cfset conj = "">
					<cfloop list="#contractsidslist#" index="x" delimiters = ",">
						#conj# Contract_Main_ID = '#x#'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look if the Type_Group_Desc has been selected --->

			<!--- Look if the Type_Code_Desc has been selected --->
			<CFIF Type_Code_Desc_Flag EQ 1>
					and
					(
					<cfset conj = "">
					<cfloop list="#contractsidslist2#" index="i" delimiters = ",">
						#conj# Contract_Main_ID = '#i#'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look if the Type_Group_Desc has been selected --->

			<!--- Look if the Q_Brand_Desc has been selected --->
			<CFIF Q_Brand_Desc_Flag EQ 1>
					and
					(
					<cfset conj = "">
					<cfloop list="#contractsidslist3#" index="J" delimiters = ",">
						#conj# Contract_Main_ID = '#J#'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look if the Q_Brand_Desc has been selected --->

			<!--- Look if the Brand has been selected --->
			<CFIF Brand_Flag EQ 1>
					and
					(
					<cfset conj = "">
					<cfloop list="#contractsidslist4#" index="K" delimiters = ",">
						#conj# Contract_Main_ID = '#K#'
						<cfset conj="or">
					</cfloop>
					)
			</CFIF>
			<!--- End of Look if the Brand has been selected --->

			<!--- Get only contracts, only templates or both --->
					<cfswitch expression = #TEMPLATE#>
					  <cfcase value = "0">
						  and
						  template	=	#template#
					  </cfcase>
					  <cfcase value = "1">
						  and
						  template	=	#template#
					  </cfcase>
					  <cfcase value = "2">
						  and
						  0=0
					  </cfcase>
					</cfswitch>
			<!--- End of Get only contracts, only templates or both --->

			<!--- Get only the UOM that match the search --->
			<CFIF UOM NEQ "All">
					and
					Contract_Quantity_uom_IDX	=	#uom#
			</CFIF>
			<!--- End of Get only the UOM that match the search --->
			
			
			<!--- Get contracts for this company only --->
			and
			Owner_Company_ID	=	'#request.AccessStructure.Company_Main_ID#'
			
			<!--- Get only the contracts that have not been "deleted" --->
			and
			Deleted = 0

Order by	Contract_Created_Date desc
</CFQUERY>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- End of Main query to Get contract data														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->







<BR>
<FORM>
<SPAN CLASS="title2"><CFOUTPUT>There are<CFIF Get_Contracts.Recordcount EQ 0> no <CFELSE> #Get_Contracts.Recordcount# </CFIF>contracts that match the above criteria</CFOUTPUT></SPAN>

<TABLE CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0">

<CFIF Get_Contracts.Recordcount NEQ 0>
<TR BGCOLOR="#FFCE84" VALIGN="bottom">
	<CFIF FORM.ES_ExternalSearch_Flag EQ 1><TD ID="header">&nbsp;</TD></CFIF>
	<TD ID="header" ALIGN="center"><B>Status</B></TD>
	<TD ID="header"><B>Contract #</B></TD>
	<TD ID="header"><B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</B></TD>
	<TD ID="header"><B>Contract Title</B></TD>
	<TD ID="header"><B>Start Date</B></TD>
	<TD ID="header"><B>End Date</B></TD>
	<TD ID="header"><B>Quantity</B></TD>
	<TD ID="header"><B>UOM</B></TD>
</TR>
<TR>
	<TD BGCOLOR="Orange" COLSPAN="10"></TD>
</TR>
</CFIF>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows="10">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="Get_Contracts"  startrow="#StartRow#" maxrows="#MaxRows#">


<!--- <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decide which status bullet to show															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFIF DATEDIFF("d", now(), Contract_End_Date) LTE 0 or contract_status_type_IDX EQ 4><!--- Expired --->
	<CFSET status_bullet="<IMG SRC=""/images/expired.gif"" TITLE=""Contract has expired."">">

<CFELSEIF contract_status_type_IDX EQ 3 and DATEDIFF("d", now(), Contract_End_Date) LT 56><!--- About to Expire --->
	<CFSET diff=DATEDIFF("d", now(), Contract_End_Date)>
	<CFSET status_bullet="<IMG SRC=""/images/expiring.gif"" TITLE=""Contract expires in #diff# days."">">

<CFELSEIF contract_status_type_IDX EQ 1><!--- WIP --->
	<CFSET status_bullet="<IMG SRC=""/images/wip.gif"" TITLE=""Work in progress."">">

<CFELSEIF contract_status_type_IDX EQ 2><!--- Preactive --->
	<CFSET status_bullet="<IMG SRC=""/images/preactive.gif"" TITLE=""Contract in pre-active state."">">

<CFELSEIF contract_status_type_IDX EQ 3><!--- Active --->
	<CFSET status_bullet="<IMG SRC=""/images/active.gif"" TITLE=""Contract currently active."">">
	<CFELSE>
</CFIF>
 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the contract status indication								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	

<!--- Determine The Status Of The Contract  --->
<!--- Query: "Get_Contracts" this query comes from "contract_status_legend.cfm"--->

<!--- PreActive --->
<CFIF dateformat(Get_Contracts.Contract_Start_Date, 'm/d/yyyy') GT dateformat(now(), 'm/d/yyyy') AND len(Get_Contracts.Approval_Date) GT 0>
	<CFSET status_bullet="<IMG SRC=""/images/preactive.gif"" TITLE=""Contract in pre-active state."">">
</CFIF>
<!--- Active --->
<CFIF dateformat(Get_Contracts.Contract_Start_Date, 'm/d/yyyy') LTE dateformat(now(), 'm/d/yyyy') AND dateformat(Get_Contracts.Contract_End_Date, 'm/d/yyyy') GTE dateformat(now(), 'm/d/yyyy') AND len(Get_Contracts.Approval_Date) GT 0>
		<CFSET status_bullet="<IMG SRC=""/images/active.gif"" TITLE=""Contract currently active."">">
</CFIF>
<!--- Expiring --->
<CFIF datediff('d', now(), Get_Contracts.Contract_End_Date) LTE 56 AND len(Get_Contracts.Approval_Date) GT 0>
	<CFSET diff=DATEDIFF("d", dateformat(now(), 'm/d/yyyy'), dateformat(Contract_End_Date, 'm/d/yyyy'))>
	<CFSET status_bullet="<IMG SRC=""/images/expiring.gif"" TITLE=""Contract expires in #diff# days."">">
</CFIF>
<!--- Expired --->
<CFIF dateformat(Get_Contracts.Contract_End_Date, 'm/d/yyyy') LT dateformat(now(), 'm/d/yyyy')AND len(Get_Contracts.Approval_Date) GT 0>
	<CFSET status_bullet="<IMG SRC=""/images/expired.gif"" TITLE=""Contract has expired."">">
</CFIF>
<!--- WIP --->
<CFIF len(Get_Contracts.Approval_Date) EQ 0>
	<CFSET status_bullet="<IMG SRC=""/images/wip.gif"" TITLE=""Work in progress."">">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decide what to show: operator name or a generic Multiple										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF isnumeric(Get_Contracts.Operator_ID)>
		<CFQUERY NAME="Get_Operator_Name" datasource="#application.datasource#">
			Select		BSA_Operator.operator_name
			From		BSA_Operator
			Where		BSA_Operator_ID	=	'#Get_Contracts.Operator_ID#'
		</CFQUERY>
		<CFSET operatorname=Get_Operator_Name.operator_name>
	<CFELSE>
		<CFSET operatorname="Multiple">
</CFIF>

<!--- Encrypt the CID (Contract record ID) --->
<cf_cryp type="en" string="#contract_main_id#" key="#request.key#">
<CFSET CID = cryp.value>


<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
	<CFIF FORM.ES_ExternalSearch_Flag EQ 1><TD ID="header" ALIGN="center"><INPUT NAME="Payable_Contract_List" <CFIF FORM.ES_multipleselections EQ "YES">TYPE="checkbox" <CFIF listfind(GetPayableInfo.Contract_Main_ID, Contract_Main_ID) GT 0>checked</CFIF><CFELSE>TYPE="radio" <CFIF listfind(GetPayableInfo.Contract_Main_ID, Contract_Main_ID) GT 0>checked</CFIF></CFIF> VALUE="#Contract_Main_ID#"></TD></CFIF>
	<TD NOWRAP ALIGN="center">#status_bullet#</TD>
	<TD NOWRAP>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
		
		<!--- <A HREF="/common_files/contracts/contract_view_master.cfm?CID=#CID#" STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A> --->
		<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A>
		<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
	</TD>
	<TD>#operatorname#&nbsp;</TD>
	<TD>#Contract_Title#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')#&nbsp;</TD>
	<TD NOWRAP>#Unit_of_Measure_Desc#&nbsp;</TD>
</TR>
</CFOUTPUT>
<TR>
	<TD BGCOLOR="Orange" COLSPAN="10"></TD>
</TR>
<TR>
	<TD COLSPAN="10">
<!---  		<CF_Next_Previous_FormBased_FormOutput
			maxrows=10
			ParentFileName="#templatename#"
			addparams = "FORM.ES_ExternalSearch_Flag,FORM.ES_group,FORM.ES_finaldestination,FORM.ES_multipleselections,FORM.ES_itemid,FORM.ES_tabgroup,FORM.ES_urlinterfacestring,contract_number,QTY_Compare,QTY_Value,contract_title,Broker,Operator,Distributor,Type_Group_Desc,Type_Code_Desc,Q_Brand_Desc,Brand,contract_status,template,uom"
		>
 --->
		<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">

		<cf_Next_Previous_FormBased
			maxpages		=	"5"
			query			=	"Get_Contracts"										
			previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			addparams		=	"contract_number,QTY_Compare,QTY_Value,contract_title,Broker,Operator,Distributor,Type_Group_Desc,Type_Code_Desc,Q_Brand_Desc,Brand,contract_status,template,uom">
		</DIV>
	</TD>
</TR>
</TABLE>

<BR>
<CFIF NOT isdefined("FORM.ES_ExternalSearch_Flag")>
	<CF_button
		button_name		=	""
		button_caption	=	"refine your search"
		button_action	=	"contract_search_form.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	"Click here to search the contracts database"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
<CFELSE>

<SCRIPT>
	function checkforacontractselection() {
		var atleastoneselected = 0
		for(var x = 0; x<document.all.Payable_Contract_List.length; x++){
			
			if(document.all.Payable_Contract_List[x].checked) {
				document.all.Contract_List.value = document.all.Payable_Contract_List[x].value
				var atleastoneselected = 1
			}
		}
		if(atleastoneselected == 0) {
			alert("Please Select A Contract")
		}
		else {
			document.all.FromA.submit()
		}
		
	}
</SCRIPT>

	<CF_button
		button_name		=	""
		button_caption	=	"save contract"
		button_action	=	"javascript: checkforacontractselection()"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">

</CFIF>



</BLOCKQUOTE>


<CFINCLUDE TEMPLATE="/includes/footer.cfm">



</BODY>
</HTML>

