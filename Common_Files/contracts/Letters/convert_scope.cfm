<cfsilent>
<!--- 
FILE: 				Convert Scope.cfm
FILENAME:   	convert_scope.cfm
CREATED: 			01/31/2008 - RBL
EDITED:				03/12/2008 - RBL

FUNCTIONALITY:
- 	This CF8 custom tag simply includes a normal CT include to convert thisTag to variables scope for further use in same page.

IMPORTANT TECH NOTE: I initially placed ALL deal letter V2 files in one folder for the deal letter project, confining my new code so as to not allow a conflict being new.
Now, I would prefer to MOVE NOT COPY the 5 deal letter CT's to the CT directory, the 1 (incomplete) cfc to the component directory, and the images to the images directory,
but as i understand, we do NOT delete within our CVS repository.
I anticipate this duplicity WILL cause a problem with the CT's since I recall they look in the current directory first, THEN CT directories, unless I stand corrected this behavior can not be changed. I would always prefer and suggest to delete deprecated code consistently as it is deprecated to clean house. If there is a problem, it will surface in stage. This is a great example of why. RBL 2/1/2008
--->

<!--- ||| These parameters [in alpha] are required for this template to process correctly --->
<cfparam name="attributes.file_to_include" 			type="string" 	default="">
<cfparam name="attributes.return_name" 					type="string" 	default="">
<cfparam name="attributes.stPDFBodyInfo" 				type="struct" 	default="#structNew()#">

<!--- ||| Overwrite the default values with incoming... --->
<cfset structAppend(thisTag, attributes, true)>

<!--- Note: a call to this CT >>MUST<< Follow the include of inc_all_vars module... --->
<cfset thisTag.qGetTemplateSettings 					= caller.gettemplatesettings>
<cfset thisTag.qGetFixedPriceProducts 				= caller.getfixedpriceproducts>
<!--- <cfset thisTag.qGetFixedPricePaidToProducts 	= caller.getfixedpricepaidtoproducts> --->
<cfset thisTag.qGetRebateProducts 						= caller.getrebateproducts>
<cfset thisTag.qGetBidRequestProducts 				= caller.getbidrequestproducts>
<!--- <cfset thisTag.qGetBidRequestPaidToProducts 	= caller.getbidrequestpaidtoproducts> --->

</cfsilent>

<!--- HTML [begin] --->
<cfoutput>
	<cfinclude template="#thisTag.file_to_include#">
	<cfset structInsert(request,"#thisTag.return_name#",thisTag["#thisTag.return_name#"],true)>
</cfoutput>
<!--- HTML [end] --->