# Cleaner of PII for Page URL by MeasureMinds

Delete PII from the URL and keep only whitelisted parameters. The template also provides utilities to lowercase parts of the URL, delete duplicate parameters, and control the maximum length of the URL.

Recommended default query parameters for the template whitelist:

- utm_id
- utm_source
- utm_medium
- utm_campaign
- utm_term
- utm_content
- utm_campaign_id
- utm_source_platform
- gclid
- dclid
- gbraid
- wbraid
- gclsrc
- \_gl
- \_gac
- ds_rl

If you are using Serverside GTM and Facebook CAPI then you will need to add fbclid to the whitelist above and edit GA4 retract params settings to replace fbclid=(retracted) on landing pages:
[documentation link](https://support.google.com/analytics/answer/13544947?hl=en-GB&utm_id=ad#:~:text=redact%20URL%20query%20parameters)

If you have any questions or need support for GA or GTM setup, feel free to reach out to [MeasureMinds Group](https://measuremindsgroup.com/).
