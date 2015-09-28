<cfparam name="form.t" default="0">
<cfparam name="form.h" default="">
<cfparam name="form.args" default="">
<cfif form.h IS HMac(form.t & form.args, application.token, "HMACSHA512") AND Len(form.h)>
	<cfset form.args = deserializeJSON(form.args)>
	<cfset form.args.fileField = "file">
	<cfset form.args.destination = getTempDirectory() & "secureupload_tests_" & Hash(application.token)>
	<cfif NOT DirectoryExists(form.args.destination)>
		<cfset directoryCreate(form.args.destination)>
	</cfif>
	<cfset sup = new secureupload.secureupload()>
	<cftry>
		<cfset result = sup.upload(argumentCollection=form.args)>
		<cfcatch>
			<cfset result = {success=false, exception=cfcatch}>
		</cfcatch>
	</cftry>
	<!--- delete the file --->
	<cfif result.success AND fileExists(result.filePath) AND NOT StructKeyExists(form.args, "keepUploadedFile")>
		<cfset fileDelete(result.filePath)>
		<cfset result.deletedUploadedFile = true>
	<cfelse>
		<cfset result.deletedUploadedFile = false>
	</cfif>
	<cfcontent reset="true" type="application/json"><cfoutput>#SerializeJSON(result)#</cfoutput>
<cfelse>
	<cfcontent reset="true" type="application/json">{"success"=false, "exception"={"message"="Sorry Invalid Access Token."}
</cfif>