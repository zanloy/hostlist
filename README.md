## Description

hostlist is a small script that keeps a text list of hosts with tags and allows you to search that list. The purpose of this script is to facilitate other scripts. For example, if you have a script that needs the hostnames of only production weblogic servers, you would query hostlist first and then loop through the output.

## Configuration

All FQDNs are entered into the configuration file. This file is in YAML format and uses brace expansion very similar to how BASH does brace expansion. A list of values would be comma separated (eg: proxy{1,2} expands to proxy1, proxy2). A range is represented with two periods (eg: proxy{1..3} expands to proxy1, proxy2, proxy3).

The default location for the configuration file is /etc/hostlist.yaml

```yaml
'extpxy00{1..4}.example.com':
  tags: [ 'prd', 'pxy', 'extpxy']
'extpxy00{1,2}.pre.example.com':
  tags: [ 'pre', 'pxy', 'extpxy']
'intpxy00{1,2}.example.com':
  tags: [ 'prd', 'pxy', 'intpxy']
```

## Listing Hosts

You can list hosts by running hostlist with a list of tags you want to filter with. You can use any number of tags separated by a space. Using the above sample configuration, running "hostlist prd extpxy" would yield:

```
extpxy001.example.com
extpxy002.example.com
extpxy003.example.com
extpxy004.example.com
```

## Showing Tags

If you want to see a list of all the tags in the cached database, you can run "hostlist show". This list is not sorted in any way.
