CFML Security Tools
===================

This repository will contain some security tools / utilities for CFML (ColdFusion) developers.

## Example Usage

Copy the `securityutil.cfc` file into your project and then:

```cfm
<cfset securityUtil = CreateObject("component", "securityutil").init()>
<cfoutput>
	Hello #securityUtil.encodeHTML(url.name)# <br /> <!--- ESAPI encodeForHTML --->
	Hello #securityUtil.scrub(url.name)# <!--- remove all but a-z0-9 --->
	Hello #securityUtil.scrub(url.name, ".,")# <!--- remove all but a-z0-9 and  ., --->
	
	<!--- experimental --->
	#securityUtil.scrubHTML(form.html)# <!--- only allow a strict set of tags, attributes and attribute values --->
	
	#securityUtil.scrubHTML(form.html, {div={class="alnum"}})# <!--- only allow div tags with class="[a-z0-9]" --->
	
</cfoutput>
```