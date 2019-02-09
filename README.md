# lists-gists

v0.1.1 - find public gists for a user, save them to a state file, and determine if new gists have arrived upon next invocation

Example usage:

  __$ ruby lists_gists.rb -h__
  
  Show help text

  __$ ruby lists_gists.rb__ 
  
  Returns public gists for GitHub founder defunkt

  __$ ruby lists_gists.rb -u chrisjomaron__ 

  Returns public gists for given user

  __$ ruby lists_gists.rb -u chrisjomaron -v__
  
  Returns public gists for given user, shows debug output
