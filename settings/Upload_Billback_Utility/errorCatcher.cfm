 <!-----------------------------------------------------------------------------

FILE NAME:		errorCatcher.cfm
DESCRIPTION:
CREATED BY:		13-Oct-2014
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

      			Anand Rao	  13-Oct-2014	Created the file
------------------------------------------------------------------------------>

<!---
	Type:    Exception type, as specified in cfcatch. 
	Message:    The exception's diagnostic message, if one was provided. If no diagnostic message is available, this is an empty string. 
	Detail:    A detailed message from the CFML interpreter. This message, which contains HTML formatting, can help determine which tag threw the exception. 
	TagContext:    The tag stack: the name and position of each tag in the tag stack, and the full pathnames of the files that contain the tags in the tag stack. See the note that follows this list for more information. 
	NativeErrorCode:    type = "database" only. The native error code associated with this exception. Database drivers typically provide error codes to assist diagnosis of failing database operations. If no error code was provided, the value of NativeErrorCode is -1. 
	SQLSTATE:    type = "database" only. The SQLState associated with this exception. Database drivers typically provide error codes to assist diagnosis of failing database operations. If no SQLState value was provided, the value of SQLSTATE is -1. 
	ErrNumber:    type = "expression" only. Internal expression error number. 
	MissingFileName:    type = "missingInclude" only. Name of the file that could not be included. 
	LockName:    type = "lock" only. The name of the affected lock (if the lock was unnamed, set to anonymous). 
	LockOperation:    type = "lock" only. The operation that failed (set to Timeout, Create Mutex, or Unknown). 
	ErrorCode:    type = "custom" only. A string error code. 
	ExtendedInfo:    type = "application" and custom only. A custom error message. 
--->
<br><br>
<cfoutput>
	<b>Type:</b> #cfcatch.Type# <br><br>
	<b>Message:</b> #cfcatch.Message# <br><br>
	<cfif cfcatch.Detail NEQ "">
		<b>Detail:</b> #cfcatch.Detail# <br><br>
	</cfif>
<!--- 	<strong>TagContext:</strong> #cfcatch.TagContext# <br><br> --->
</cfoutput>