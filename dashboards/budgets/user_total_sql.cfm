<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
    SELECT *

    FROM   dashboards_budget_weekly_summary

    WHERE  user_id = '#request.AccessStructure.User_ID#'

</cfquery>

<!--- ----------------------------------------------------------------------------------------- --->




<!--- 

49FB11F4-AAF5-4AC5-15994D128A934A0A	Angela Letourneau
4A027CD6-B323-1E5E-690959375A110CC9	Brenda Grubbs
4A2D0B73-0895-028A-ACD0CCA7BC9E5B5A	Denny Ruff
4A0D0002-D8E8-0F2E-0E28CD2B44EECB54	Gene Coats
49EFA4C2-0B66-3A32-8F1D49AC1847ECEF	Heather Irimi
4A153540-9A7A-5C8D-3742F689831CE00C	Jim Holacka
4A4FF190-E0C0-5B43-1B324D3EEC7A912E	Jim Smith
4A33310D-DA78-5CFC-00DE0EA26564F613	John Reilly
4A70BBC1-07C8-B7C7-0A3BF0C3F8EDFC2F	Leon Lyon
4A7AAC6D-B135-BA24-A0FB45101EC75C3C	Nancy Muller
4A40A790-9253-EEA3-D7E6C19C129E659A	Randy Baker
49E65BD8-B90A-480A-CF18BCEE52B8DB01	Robert Romano
4A1BBEF2-BF58-E087-FE5CAE374E20212B	Shawn Rener
4A56CE74-9A67-8702-1D922DC6A44E5972	Tom Gonzalez
4A5D5196-F754-B0DB-6582B91119B4E451	Tom Johns
4A254451-BDAD-83AD-AEE41055564B3322	Vic Nwachukwu

----------------------------------------------------------------------------------------- --->

