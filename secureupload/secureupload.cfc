<cfcomponent output="false">
	<cfset variables.supportsCallStackGet = structKeyExists(getFunctionList(), "callStackGet")>
	<cfset variables.supportsFileGetMimeType = structKeyExists(getFunctionList(), "fileGetMIMEType")>

	<cffunction name="upload" returntype="struct" access="public">
		<cfargument name="fileField" required="true" hint="The name of the form field.">
		<cfargument name="destination" required="true" hint="The file path to store the file.">
		<cfargument name="extensions" default="jpg,png,gif,jpeg">
		<cfargument name="type" default="auto" hint="Specify image,pdf,auto (looks at file ext of uploaded file and runs a type check), or a list of mime types.">
		<cfargument name="nameconflict" default="random" hint="One of: makeunique, overwrite, random, error. Random will always generate a random file name even if there is no conflict.">
		<cfargument name="onFailure" default="throw" hint="Specify: throw (log, throw exception delete file) or log (delete file, log exception/failure)">
		<cfargument name="tempDirectory" default="#getDefaultTempDirectory()#" hint="A directory that is not under the web root. File is uploaded here first, then moved to the destination if validation passes.">
		<cfargument name="defaultExtension" default="" hint="If no file extension is supplied by the client, use this. If this value is empty and the client does not supply an extension an exception will be thrown.">
		<cfargument name="destinationFileName" default="" hint="Specify the name of the file. If you omit the file extension the uploaded file extension will be used (must be in extensions argument list).">

		<cfset var result = {success=false, validExtension=false, validType=false, cfFileResult="", fileName="", filePath="", mimeType="", message="", ext=""}>
		<cfset var tempNameConflict = "makeunique">
		<cftry>
			<cfset validateFilePath(arguments.tempDirectory)>
			<cfset validateFilePath(arguments.destination)>

			<!--- make sure destination has a trailing slash --->
			<cfif Right(arguments.destination, 1) IS NOT "/" AND Right(arguments.destination, 1) IS NOT "\">
				<!--- append forward slash to end (works on both win/unix) --->
				<cfset arguments.destination = arguments.destination & "/">
			</cfif>

			<cfif NOT Len(arguments.extensions)>
				<cfthrow message="You must specify a list of file extensions to whitelist. eg, extensions=jpg,png">
			</cfif>

			<cfif arguments.nameconflict IS "overwrite">
				<cfset tempNameConflict = "overwrite">
			</cfif>

			<!--- upload the file --->
			<cffile action="upload" fileField="#arguments.fileField#" destination="#arguments.tempDirectory#" nameconflict="#tempNameConflict#" result="result.cfFileResult">
			
			<!--- handle case if no file extension --->
			<cfif NOT Len(result.cfFileResult.serverFileExt)>
				<cfif NOT Len(arguments.defaultExtension)>
					<cfthrow message="Client did not supply a file extension, and the defaultExtension was not defined.">
				<cfelse>
					<cfset result.ext = arguments.defaultExtension>
				</cfif>
			<cfelse>
				<cfset result.ext = result.cfFileResult.serverFileExt>
			</cfif>
			<!--- check the file extension list --->
			<cfset result.validExtension = ListFindNoCase(arguments.extensions, result.ext) NEQ 0>
			<cfif NOT result.validExtension>
				<cfthrow message="Attempt to upload file with Extension #xmlFormat(result.ext)#" detail="Client File: #result.cfFileResult.clientFile# Server File: #result.cfFileResult.serverFile#">
			</cfif>

			<!--- check file type --->
			<cfif variables.supportsFileGetMimeType>
				<cfset result.mimeType = fileGetMimeType(getServerFilePath(result.cfFileResult))>
			<cfelse>
				<!--- from client/browser --->
				<cfset result.mimeType = result.cfFileResult.contentType & "/" & result.cfFileResult.contentSubType>
			</cfif>

			<cfset result.validType = validateFileType(filePath=getServerFilePath(result.cfFileResult), fileExt=result.ext, type=arguments.type)>
			<cfif NOT result.validType>
				<cfthrow message="Attempt to upload file with Extension #xmlFormat(result.ext)# type check failed." detail="Mime Type: #result.mimeType#">
			</cfif>

			<cfif Len(arguments.destinationFileName)>
				<cfif find(".", arguments.destinationFileName)>
					<cfset result.fileName = arguments.destinationFileName>
				<cfelse>
					<cfset result.fileName = arguments.destinationFileName & "." & result.ext>
				</cfif>
			<cfelse>
				<cfif arguments.nameconflict IS "random">
					<cfset result.fileName = generateRandomFileName() & "." & result.ext>
				<cfelse>
					<cfset result.fileName = result.cfFileResult.serverFile>
				</cfif>
			</cfif>

			<cfset result.filePath = arguments.destination & result.fileName>
			<!--- using a cflock to avoid overwriting files on concurrent uploads --->
			<cflock name="#Hash(arguments.destination)#" type="exclusive" throwontimeout="true" timeout="30">
				<cfif arguments.nameconflict IS NOT "overwrite" AND FileExists(result.filePath)>
					<cfif arguments.nameconflict IS "error">
						<cfthrow message="The resulting file already exists, and nameconflict is error." detail="#result.filePath#">
					<cfelse>
						<cfset local.i = 0>
						<cfloop condition="#FileExists(result.filePath)#">
							<cfset result.fileName = generateRandomFileName() & "." & result.ext>
							<cfset result.filePath = arguments.destination & result.fileName>
							<cfset local.i = local.i + 1>
							<cfif local.i GT 100>
								<cfthrow message="Could not generate unique file name after 100 attempts." detail="Last attempt: #result.filePath#">
							</cfif>
						</cfloop>
					</cfif>
				</cfif>
			</cflock>
			<!--- finally after validation is complete, move file to destination --->
			<cfset fileMove(getServerFilePath(result.cfFileResult), result.filePath)>

			<cfset logger(message="Uploaded File Successfully: #result.filePath#", type="information")>
			<cfset result.success = true>
			<cfcatch>
				<cftry>
					<cfset logger(exception=cfcatch, type="fatal")>
					<cfset result.message = cfcatch.message>
					
					<!--- attempt to delete the file --->
					<cfif NOT isSimpleValue(result.cfFileResult)>
						<cfset deleteServerFile(result.cfFileResult)>
					</cfif>
					<cfif arguments.onFailure IS "throw">
						<cfrethrow>
					</cfif>
					
					<cfcatch>
						<!--- if catch block is throwing an exception
							the file might not get deleted, so log and rethrow --->
						<cftry>
							<cfset logger(message="Exception in Catch block ",exception=cfcatch, type="fatal")>
							<cfcatch>
								<!--- in this case logger is throwing the exception, rethrow --->
							</cfcatch>
						</cftry>
						<cfrethrow>
					</cfcatch>
				</cftry>
			</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="logger" output="false">
		<cfargument name="message" default="">
		<cfargument name="type" default="information">
		<cfargument name="exception" default="">
		<cfif NOT isSimpleValue(arguments.exception)>
			<cfset arguments.message = arguments.message & "[Upload Exception] " & arguments.exception.message & " " & arguments.exception.detail>
		</cfif>
		<cfif variables.supportsCallStackGet>
			<cfset arguments.message = arguments.message & " CallStack: [" & arrayToList(callStackReFormat(callStackGet())) & "]">
		</cfif>
		<cflog type="#arguments.type#" text="#arguments.message# -- #cgi.remote_addr# #cgi.user_agent# #cgi.script_name#" file="uploads">
	</cffunction>

	<cffunction name="callStackReFormat">
		<cfargument name="callStack" default="#callStackGet()#">
		<cfset var newCallStack = []>
		<cfset var s = "">
		<cfloop array="#arguments.callStack#" index="s">
			<cfif LCase(s.function) IS "logger">
				<cfcontinue>
			</cfif>
			<cfset arrayAppend(newCallStack, Trim(s.function & " (" & s.Template & ":" & s.LineNumber & ")"))>
		</cfloop>
		<cfreturn newCallStack>
	</cffunction>

	<cffunction name="getServerFilePath" hint="Returns the file path including directory and file name when you pass the cffile struct.">
		<cfargument name="cfFileResult">
		<cfreturn arguments.cfFileResult.serverDirectory & "/" & arguments.cfFileResult.serverFile>
	</cffunction>

	<cffunction name="deleteServerFile" hint="Deletes the serverFile if it exists" returntype="boolean">
		<cfargument name="cfFileResult">
		<cfset var serverFilePath = getServerFilePath(arguments.cfFileResult)>
		<cfif fileExists(serverFilePath)>
			<cfset fileDelete(serverFilePath)>
			<cfreturn true>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="validateFilePath" hint="Makes sure there is nothing funky with the file path, such as .. or null bytes. Throws exceptions">
		<cfargument name="filePath">
		<cfif arguments.filePath contains "..">
			<cfthrow message="File path contained .. possible path traversal." detail="#arguments.filePath#">
		</cfif>
		<cfif LCase(Left(arguments.filePath,3)) IS "s3:">
			<cfif arguments.filePath contains "@">
				<cfif NOT ReFindNoCase("^s3://[a-zA-Z0-9]+:[a-zA-Z0-9]+@.*", arguments.filePath)>
					<cfthrow message="Invalid s3 File Path" detail="#arguments.filePath#">
				</cfif>
				<!--- already validated first part of path so trim it off --->
				<cfset arguments.filePath = ReReplaceNoCase(arguments.filePath, "^s3://[a-zA-Z0-9]+:[a-zA-Z0-9]+@", "")>
			<cfelse>
				<cfset arguments.filePath = ReReplaceNoCase(arguments.filePath, "^s3:", "")>
			</cfif>
		<cfelseif LCase(Left(arguments.filePath, 4)) IS "ram:">
			<cfset arguments.filePath = ReReplaceNoCase(arguments.filePath, "^ram:", "")>
		</cfif>
		<cfif ReFind("[^a-zA-Z0-9:_ ./\\-]", arguments.filePath)>
			<cfthrow message="File path contained a character other than: a-zA-Z0-9:_ ./\-" detail="#arguments.filePath#">
		<cfelseif Len(arguments.filePath) GT 2 AND Find(":", arguments.filePath, 3)>
			<cfthrow message="File path had a colin after position 2." detail="#arguments.filePath#">
		</cfif>
		<cfreturn true>
	</cffunction>

	<cffunction name="validateFileType" hint="Checks file type">
		<cfargument name="filePath">
		<cfargument name="fileExt" default="#listLast(arguments.filePath, ".")#">
		<cfargument name="type" default="auto" hint="image, pdf, html, spreadsheet, auto">

		<cfif arguments.type IS "auto">
			<cfswitch expression="#LCase(arguments.fileExt)#">
				<cfcase value="jpg,png,gif,jpeg">
					<cfset arguments.type = "image">
				</cfcase>
				<cfcase value="pdf">
					<cfset arguments.type = "pdf">
				</cfcase>
				<cfcase value="html,htm">
					<cfset arguments.type = "html">
				</cfcase>
				<cfdefaultcase>
					<!--- type not handled by auto --->
					<cfreturn true>
				</cfdefaultcase>
			</cfswitch>
		</cfif>

		<cfswitch expression="#arguments.type#">
			<cfcase value="image">
				<cfif NOT isImageFile(arguments.filePath)>
					<cfreturn false>
				</cfif>
			</cfcase>
			<cfcase value="pdf">
				<cfif NOT isPDFFile(arguments.filePath)>
					<cfreturn false>
				</cfif>
			</cfcase>
			<cfcase value="html">
				<cfif NOT isSafeHTML(fileRead(arguments.filePath))>
					<cfreturn false>
				</cfif>
			</cfcase>
		</cfswitch>
		<cfreturn true>
	</cffunction>

	<cffunction name="getDefaultTempDirectory" returntype="string" output="false" hint="Returns getTempDirectory() by default, you can extend the CFC to change.">
		<cfreturn getTempDirectory()>
	</cffunction>

	<cffunction name="generateRandomFileName" returntype="string" output="false">
		<cfargument name="length" default="16">
		<cfset var name = "">
		<cfloop from="1" to="#arguments.length#" index="local.i">
			<cfset name = name & Chr(RandRange(97,122, "SHA1PRNG"))>
		</cfloop>
		<cfreturn name>
	</cffunction>	

</cfcomponent>
