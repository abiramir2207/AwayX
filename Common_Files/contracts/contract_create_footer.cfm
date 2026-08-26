
<DIV ALIGN="right">


<FONT COLOR="Red"><B>|</B></FONT>

<CFIF request.TemplateName EQ "contract_create_1_form.cfm">
	<FONT COLOR="Gray">basic information</FONT>
<CFELSE>

<A STYLE="cursor: pointer;" ONCLICK="MyForm.action='contract_create_1_form.cfm'; MyForm.submit();" CLASS="bold">basic information</A>

</CFIF>
<FONT COLOR="Red"><B>|</B></FONT>
<CFIF request.TemplateName EQ "contract_create_2_form.cfm">
	<FONT COLOR="Gray">product information</FONT>
<CFELSE>
<A HREF="javascript:MyForm.submit();" CLASS="bold">product information</A>
</CFIF>

<FONT COLOR="Red"><B>|</B></FONT>

<CFIF request.TemplateName EQ "contract_create_3_form.cfm">
	<FONT COLOR="Gray"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> information</FONT>
<CFELSE>
<A HREF="javascript:MyForm.submit();" CLASS="bold"><cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)# </cfoutput>information</A>
</CFIF>

<FONT COLOR="Red"><B>|</B></FONT>


</DIV>