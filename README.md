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

Now if you want to allow the `id` you can do something like this:

```cfm
securityUtil.scrubHTML(form.html, {div={id="alnum"},ul={type="match:(disc|square|circle)"},li={}})
```

There are a few different attribute value matchers defined, here are some examples of how you might use them:

```cfm
{ tagName = { attributeName="*" } } //allows <tagName attributeName="anything in here">
{ tagName = { attributeName="match:[a-zA-Z@.-]+" } } //regex allow, if no match attribute is skipped
{ tagName = { attributeName="remove:[^a-zA-Z0-9]" } } //removes any characters that match the regex
{ tagName = { attributeName="alnum" } } //same as "match:[a-zA-Z0-9]+"
{ tagName = { attributeName="uri" } } //matches a relative or absolute uri but does not allow :
{ tagName = { attributeName="uri" } } //matches a URL http or https 
```
 