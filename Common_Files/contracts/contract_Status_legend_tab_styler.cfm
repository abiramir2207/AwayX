<cfsilent>
		<CFIF CSL_there EQ 1>
			<CFSET TD_Class ="foreground">
			<CFSET TD_BGcolor ="FFFFFF">
			<CFSET HREF_Class ="tablink_fore">
		<CFELSE>
			<CFSET TD_Class ="background">
			<CFSET TD_BGcolor ="##B9DCFF">
			<CFSET HREF_Class ="tablink_back">
		</CFIF>
		
		<CFPARAM NAME="CSL_data" DEFAULT="1">
		<CFIF CSL_data EQ 1>
			<CFSET IMG_SRC = "/images/programs/ball_green.gif">
		<CFELSE>
			<CFSET IMG_SRC = "/images/programs/ball_red.gif">		
		</CFIF>
</cfsilent>