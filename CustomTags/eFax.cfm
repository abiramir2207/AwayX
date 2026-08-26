<CFSETTING ENABLECFOUTPUTONLY="Yes">
<!--- CF_eFax.cfm --->
<!--- Written by: Scott F. Knaub - scott@web-mgt.com --->
<!--- Formats a message to be sent via eFax.com.

WARNING: I did not include any error trapping on this tag. Please check the required fields to make sure you are sending in the right information or add some error trapping.

For more infomration about using e-mail to send faxes check out the eFax Web Toolkit
documentation at: http://www.efax.com/toolkit/

Prerequisites for using this custom tag:
Make sure your SMTP gateway is set up in ColdFusion administrator or add your mail server name to the CFMAIL tag below.
An eFax Plus account is required to allow you to use eFax to send faxes.

No special software is required on the Web server or Web browser since the message
is sent to eFax via e-mail.

eFax allows for including an attachment to be faxed, but that feature has not been
implemented in this custom tag. It should be as easy as adding the MIMEATTACH
attribute to the CFMAIL tag and specifying a document path. 
eFax has a list of acceptable document types on their Web site.

Browse the accompanying file "test_eFax.cfm" for a brief demonstration.
(You need an eFax Plus account to use the demonstration template)

Further Use: This custom tag can be used in combination with a query on a customer database
to send bulk faxes to an entire list of fax numbers.

Enjoy! 

Input Parameters:
Recipient - Name of person receiving fax
Company - Name of organization receiving fax
FaxNumber - (REQUIRED) The complete fax number including country code, area code and phone number
Subject - The subject line presented on the cover page
Message - (REQUIRED) The body of the message
ReferenceNumber - Number assigned for your internal use. eFax records this number whenit sends your fax.
CoverPage - (Yes or No); Default="Yes"; Set this to "No" to tell eFax to not send a cover page
Resolution -  Default="Fine"; Set this to "Standard" to have eFax send your fax in a lower resolution
SentFrom - (REQUIRED) The sender's name and e-mail address. This should match your eFax Plus account information.

Output Parameters:
None

Supporting files:
None

Development Log:
Date					Name						E-mail						Action
8/23/2000			Scott F. Knaub			scott@web-mgt.com			Original development of custom tag
--->
		  
<!--- Initialize parameters --->
<CFPARAM NAME="Attributes.Recipient" DEFAULT="">
<CFPARAM NAME="Attributes.Company" DEFAULT="">
<CFPARAM NAME="Attributes.FaxNumber" DEFAULT="">
<CFPARAM NAME="Attributes.Subject" DEFAULT="">
<CFPARAM NAME="Attributes.Message" DEFAULT="">
<CFPARAM NAME="Attributes.ReferenceNumber" DEFAULT="">
<CFPARAM NAME="Attributes.CoverPage" DEFAULT="Yes">
<CFPARAM NAME="Attributes.Resolution" DEFAULT="Fine">
<CFPARAM NAME="Attributes.SentFrom" DEFAULT="Your eFax Plus Account Name <Your eFax Plus Account E-mail Address>">

<!--- Assign values to variables that will be used to send the e-mail --->
<CFSET Variables.FaxTo = "'#Attributes.Recipient# (#Attributes.Company#) via eFax Send' <#Attributes.FaxNumber#@efaxsend.com>">

<CFIF Len(Trim(Attributes.ReferenceNumber))>
	<CFSET Variables.IncludeReference = "{ref###Attributes.ReferenceNumber#}">
<CFELSE>
	<CFSET Variables.IncludeReference = "">
</CFIF>

<CFIF NOT Attributes.CoverPage>
	<CFSET Variables.NoCoverPage = "{nocoverpage}">
<CFELSE>
	<CFSET Variables.NoCoverPage = "">
</CFIF>

<CFIF UCase(Attributes.Resolution) EQ "STANDARD">
	<CFSET Variables.StandardResolution = "{standard}">
<CFELSE>
	<CFSET Variables.StandardResolution = "">
</CFIF>

<!--- Send e-mail message to eFax --->
<CFMAIL TO="#Variables.FaxTo#" FROM="#Attributes.SentFrom#" SUBJECT="#Attributes.Subject#">
#Variables.IncludeReference#
#Variables.NoCoverPage#
#Variables.StandardResolution#
#Attributes.Message#
</CFMAIL>
<CFSETTING ENABLECFOUTPUTONLY="No">