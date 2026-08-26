
<CFPARAM NAME="URL.CMID" 	DEFAULT="">
<CFPARAM NAME="URL.user_id" 	DEFAULT="">
<CFIF len(URL.CMID) EQ 0>
<CFSET temp = 0>
<CFELSE>
<CFSEt temp = URL.CMID>
</CFIF>

<cfinclude template="/common_files/contracts/letters/generate_opr_dis_letters.cfm"> 


