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

The result is a struct with the following keys...

##### success

A boolean that will only be `true` if the file uploaded and moved to the `destination` directory successfully.

##### validExtension

A boolean that will only be `true` if the uploaded file is in the `extensions` list.

##### filePath

The full file path including the directory and full file name.

##### fileName

The file name including the extension.

##### cfFileResult

This is the internal result of the `cffile` tag, the `serverFile`, `serverDirectory`, `serverFileName` keys
will be relative to the `tempDirectory` argument.
