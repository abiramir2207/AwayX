in qury call 
<cfif URL.qryCall EQ "1">
<cfquery name="qGetDropDownRows" datasource="#application.datasource#">
 
DECLARE @Date datetime = '01/01/2021'

IF OBJECT_ID ('tempdb..##Double_dip_option_drop_down') IS NOT NULL
       DROP TABLE tempdb..#Double_dip_option_drop_down
CREATE TABLE tempdb..#Double_dip_option_drop_down
       (
       Dropdown_value VARCHAR(50)
       )

IF(    SELECT COUNT(*)  
       FROM   BB_upload_Log 
       WHERE  deleted = 0 
       AND          Upload_Type = 3 
       AND          Source_code = 'SYSCO' 
       AND          Upload_Date >= @Date) > 0 
BEGIN 
       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
       VALUES ('SYSCO')
END  

IF(    SELECT COUNT(*)  
       FROM   BB_upload_Log 
       WHERE  deleted = 0 
       AND          Upload_Type = 3 
       AND          Source_code = 'USFS' 
       AND          Upload_Date >= @Date) >0
BEGIN
       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
       VALUES ('USFS')
END  

IF( SELECT    COUNT(*)  
       FROM   BB_upload_Log 
       WHERE  deleted = 0 
       AND          Upload_Type = 3 
       AND          ISNULL(Source_code ,'')= ''
       AND          Upload_Date >= @Date )>0
BEGIN 
       INSERT INTO tempdb..##Double_dip_option_drop_down(Dropdown_value) 
       VALUES ('3rd Party')
END  

SELECT * 
FROM   ##Double_dip_option_drop_down

</cfquery>

</cfif> 