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
