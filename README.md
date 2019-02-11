# lists-gists

## Overview:

  This is a Ruby script to find public GitHub gists for a specified username.
  Each time it is run, it will notify to the console the URLs of 'new' gists.
  For the purposes of this test, any change to a gist is considered as rendering
  it 'new', i.e. it will notify upon updates and deletions of gists, as well as
  previously unseen gists.

## Requirements:

  Ruby >= 2.0, which includes ALL currently supported versions.
  The script has been deliberately written to use ruby built-ins only; no extra
  gems are required.

  Tested successfully against specific versions:
 * 2.0.0-p648
 * 2.1.10
 * 2.2.10
 * 2.3.8
 * 2.4.5
 * 2.5.3
 * 2.6.1


## Example usage:

  __$ ruby lists_gists.rb  -h__

  Show help text

```
 Usage: lists_gists.rb [options]
    -h, --help                       Show this help message
    -v, --verbose                    Run verbosely
    -u, --username=NAME              username to poll for public gists
```

  __$ ruby lists_gists.rb__

  Returns public gists for GitHub founder defunkt


  __$ ruby lists_gists.rb -u chrisjomaron__

  Returns public gists for given user


  __$ ruby lists_gists.rb -u chrisjomaron -v__

  Returns public gists for given user, shows debug output



## Change history

  v0.1.3 - Tested with all rubies >= 2.0. Added frozen frozen_string_literal directive

  v0.1.2 - use full gist URL instead of just hash. Address rubocop violations.

  v0.1.1 - add command line switch for specifying users

  v0.0.1 - initial version.


## TODO

  Modularise the Ruby script into a more OO codebase

  Implement Test::Unit or rpsec tests against the above refactor
