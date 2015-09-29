# CFML SecureUpload CFC

This CFC is designed to help you write more secure file upload CFML code.

## Example Usage

Copy the `secureupload.cfc` file into your project and then:

```cfm
<cfset sup = new secureupload()>
<cfset result = sup.upload(fileField="photo",
  destination="/some/path",
  extensions="jpg,png,gif",
  onFailure="log"
)>
<cfif result.success>
  You just uploaded #result.filePath#
<cfelse>
  Sorry didn't upload your file: #encodeForHTML(result.message)#
</cfif>
```

## Result

The result / return value of the `upload()` function is a struct with the following keys...

##### success

A boolean that will only be `true` if the file uploaded and moved to the `destination` directory successfully.

##### validExtension

A boolean that will only be `true` if the uploaded file is in the `extensions` list.

##### validType

A boolean that will be `false` if the uploaded file fails the type check. It will return `true` if there is no type check for a given file type, for example if you have `extensions="mov,png,jpg", type="auto"` and the user uploads a `.mov` file then `validType=true` beacuse there is currently no type check for `mov` files.  

##### filePath

The full file path including the directory and full file name.

##### fileName

The file name including the extension.

##### ext

The extension (not including a dot) of the file, eg "png"

##### cfFileResult

This is the internal result of the `cffile` tag, the `serverFile`, `serverDirectory`, `serverFileName` keys
will be relative to the `tempDirectory` argument.

## Upload() Arguments

The following arguments can be passed into the `upload()` function.

##### fileField

The name of the form field containing the file to upload.

##### destination

The file path to the final destination directory of the uploaded file. The file will
not be placed in this directory unless all validation steps have passed first.

##### extensions

A list of file extensions, eg: jpg,png,gif,jpeg you must specify this list.

##### type

Specify image,pdf,auto (looks at file ext of uploaded file and runs a type check), or a list of mime types.

##### nameconflict

One of: makeunique, overwrite, random, error. Random will always generate a random file name even if there is no conflict.

##### onFailure

Specify: `throw` (log, throw exception delete file), `log` (delete file, log exception/failure), `throwAndKeepTempFile` (log, throw exception do not attempt to delete file in tempDirectory)

##### tempDirectory

A directory that is not under the web root. File is uploaded here first, then moved to the destination if validation passes.

##### defaultExtension

If no file extension is supplied by the client, use this. If this value is empty and the client does not supply an extension an exception will be thrown.

##### destinationFileName

Specify the name of the file. If you omit the file extension the uploaded file extension will be used (must be in extensions argument list).


## Custom Type Checking

If you want to add a `type` check that is not currently supported, you can make the change directly to the CFC and submit a pull request (so this repository can be updated), or extend the `secureupload` CFC and implement the `validateFileType(filePath, fileExt, type)` function.

For Example:

```cfm
<cfcomponent extends="secureupload">
	<cffunction name="validateFileType" hint="Checks file type">
			<cfargument name="filePath">
			<cfargument name="fileExt" default="#listLast(arguments.filePath, ".")#">
			<cfargument name="type" default="auto" hint="image, pdf, html, spreadsheet, auto">
			<cfif arguments.fileExt IS "mov" OR arguments.type IS "movie"> 
				<!--- my code to validate it --->
			<cfelse>
				<cfreturn super.validateFileType(arguments.filePath, arguments.fileExt, arguments.type)>
			</cfif>
	</cffunction>
</cfcomponent> 
```
