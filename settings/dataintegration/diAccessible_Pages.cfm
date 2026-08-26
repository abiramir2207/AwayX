<!------diAccessible_Pages.cfm----->

<CFSET DI_Page_List="">

<CFSWITCH EXPRESSION="#LCase(application.returned_customer_setting.customer_keyword)#">
	<CFCASE VALUE="conagra">
		<CFSET DI_Page_List="dataIntegrationBasicInfo.cfm,dataIntegration.cfm,diLog.cfm">		
	</CFCASE>
	<CFCASE VALUE="resers">
		<CFSET DI_Page_List="diLog.cfm,di_Weekly_Log.cfm">
	</CFCASE>
</CFSWITCH>