<cfparam name="opdisbro.CID" default="">
<!--- delete operator/distributor/broker section --->
<script>
	function deleteOther(ID,type) {
		senetenceNoun = "";
		switch(type){
			case 1: <!--- operator --->
				senetenceNoun = "operator";
			break;

			case 2: <!--- distributor --->
				senetenceNoun = "distributor";
			break;

			case 3: <!--- broker --->
				senetenceNoun = "broker";
			break;
			
			default:
				senetenceNoun = "item";
			break;
		}
		
		if(confirm("Press OK to delete this " + senetenceNoun + ".")) {
			event.cancelBubble = true;

			document.all.deleteOtherForm.other_id.value = ID;
			document.all.deleteOtherForm.type_id.value = type;
			document.all.currentfinalitemlist.value = document.all.FinalItemList.value
			document.all.deleteOtherForm.submit();
		}
		else {
			event.cancelBubble = true;
			return false;
		}
	}
</script>

<form action="delete_op_dis_bro_action.cfm" method="post" name="deleteOtherForm" id="deleteOtherForm">
	<input type="Hidden" name="other_id" 				value="">
	<input type="Hidden" name="type_id" 				value="">
	<input type="Hidden" name="currentfinalitemlist" 	value="">
	<input type="hidden" name="CID" 	 				value="<cfoutput>#opdisbro.CID#</cfoutput>">
	
	<cfif isdefined("form.fieldnames")>
		<cfset exclusionlist = "other_id,type_id,currentfinalitemlist,cid,fieldnames">
		<cfset listofpagefieldnames = "">
		<cfoutput>
		<cfloop index="x" list="#form.fieldnames#" delimiters=",">
			<cfif listfind(lcase(exclusionlist), lcase(x), ",") EQ 0>
				<input type="hidden" name="#x#" value="#evaluate("form.#x#")#">
				<cfset listofpagefieldnames = listappend(listofpagefieldnames, lcase(x))>
			</cfif>
		</cfloop>
		<input type="hidden" name="listofpagefieldnames" 	 value="#listofpagefieldnames#">
		</cfoutput>
	</cfif>
</form>
<!--- delete operator/distributor/broker section --->