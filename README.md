CFML Security Utilities
===================

This repository contains some security utilities for CFML (ColdFusion) developers.

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

### ScrubHTML

The `scrubHTML` function has accepts a struct of tag names of which to allow. If for example you 
pass in an empty struct it would strip all tags. When a stray `<` or `>` is encountered it is converted
into a HTML entity, for example: `&lt;`

Here's a simple set of tag rules which will allow certain tags but will ensure that they do not have any attributes:

```cfm
<cfset tagRules = {div={},ul={},li={}}>
```

So for example an input like this:
```cfm
<div id="foo"><ul><li>One</li></div>
```

When passed to this code:

```cfm
securityUtil.scrubHTML(form.html, {div={},ul={},li={}})
```

Will output:

```cfm
<div><ul><li>One</li></div>
```



 