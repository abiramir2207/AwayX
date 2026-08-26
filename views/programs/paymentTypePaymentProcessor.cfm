<!---accountingSpecialist.cfm--->
<script>
	
	function openPopup(url) 
	{
		
		var w = 640/3, h = 480/3, cw = w/2, ch = h/2;

		if (window.screen) 
		{
			w = Math.floor(screen.availWidth/3);
    		h = Math.floor(screen.availHeight/3);
    		cw = Math.floor((screen.availWidth-w)/2);
    		ch = Math.floor((screen.availHeight-h)/2);
		}
		
		myPopup = window.open(url,'popupWindow','resizable=yes,width=200,height=210,top='+ch+',left='+cw);
    	if (!myPopup.opener)
        	myPopup.opener = self; 
	}
	
</script>

<cfset accountingSpecialists = CreateObject("component","components.settings.AccountingSpecialists.AccountingSpecialists") />
<cfset lProfileAccess = accountingSpecialists.getProfileAccessList() />

<cfset qGetName = accountingSpecialists.getByPaymentType(request.parameters.paymentTypeId) />

<!---if we don't have a record count then set the name display to be add or N/A depending on the handler--->
<cfif not qGetName.RecordCount>

	<cfset this.name = "( Unassigned )" />
	<cfset this.id = "" />
	
<cfelse>
	
	<cfset this.name = qGetName.Name />
	<cfset this.id = qGetName.User_ID />
	
</cfif>

<cfoutput>
	<div title="Payment Processor">
		<!---allow control for accounting specialist based on the handler--->
		<cfif request.parameters.handler eq "edit" and ListFindNoCase(lProfileAccess, request.parameters.profileId)>
			<a onClick="openPopup('../../views/programs/accountingSpecialistPopup.cfm?User_ID=#qGetName.User_ID#&Payment_Type_ID=#request.parameters.paymentTypeId#');" STYLE="cursor: pointer;">
				#this.name#
			</a>
		<cfelse>
			#this.name#
		</cfif>
	</div>
</cfoutput>
