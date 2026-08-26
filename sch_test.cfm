<CFQUERY NAME="sch_Test" datasource="#application.datasource#">
INSERT INTO sch_Test
(insert_time_stamp)
VALUES
(#createodbcdatetime(Now())#)
</CFQUERY>