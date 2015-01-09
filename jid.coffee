{ StringPrep, toUnicode }  = require 'node-stringprep'

###*
# JID implements
# - Xmpp addresses according to RFC6122
# - XEP-0106: JID Escaping
#
# @see http://tools.ietf.org/html/rfc6122#section-2
# @see http://xmpp.org/extensions/xep-0106.html
###

JID = (a, b, c) ->
  @local = @domain = @resource = null

  if a and (not b) and (not c)
    @parseJID a
  else if b
    @setLocal a
    @setDomain b
    @setResource c
  else
    throw new Error 'Argument error'

JID::parseJID = (s) ->

  if s.indexOf('@') >= 0
    @setLocal s.substr 0, s.indexOf '@'
    s = s.substr s.indexOf('@') + 1

  if s.indexOf('/') >= 0
    @setResource s.substr s.indexOf('/') + 1
    s = s.substr 0, s.indexOf '/'
  @setDomain s

JID::toString = (unescape) ->
  s = @domain
  if @local    then s = @getLocal(unescape) + '@' + s
  if @resource then s = s + '/' + @resource
  s

###*
# Convenience method to distinguish users
###
JID::bare = ->
  if @resource
    new JID @local, @domain, null
  else
    @

###*
# Comparison function
###
JID::equals = (other) ->
  (@local     is other.local    ) and
  (@domain    is other.domain   ) and
  (@resource  is other.resource )

### Deprecated, use setLocal() [see RFC6122] ###
JID::setUser = (user) -> @setLocal user

###*
# Setters that do stringprep normalization.
###
JID::setLocal = (local, escape) ->
  escape = escape or @detectEscape local

  if escape
    local = @escapeLocal local

  @local = @user = local and @prep 'nodeprep', local
  @

###*
# http://xmpp.org/rfcs/rfc6122.html#addressing-domain
###
JID::setDomain = (domain) ->
  @domain =
    domain and @prep 'nameprep', domain.split('.').map(toUnicode).join '.'
  @

JID::setResource = (resource) ->
  @resource = resource and @prep('resourceprep', resource)
  @

JID::getLocal = (unescape) ->
  unescape = unescape or false

  if unescape
    @unescapeLocal(@local)
  else
    @local

JID::prep = (operation, value) -> (new StringPrep operation).prepare value

### Deprecated, use getLocal() [see RFC6122] ###
JID::getUser = -> @getLocal()

JID::getDomain = -> @domain

JID::getResource = -> @resource

JID::detectEscape = (local) ->

  return false unless local

  # remove all escaped secquences
  tmp = local.replace /\\20/g, ''
    .replace /\\22/g, ''
    .replace /\\26/g, ''
    .replace /\\27/g, ''
    .replace /\\2f/g, ''
    .replace /\\3a/g, ''
    .replace /\\3c/g, ''
    .replace /\\3e/g, ''
    .replace /\\40/g, ''
    .replace /\\5c/g, ''

  ### detect if we have unescaped sequences ###
  search = tmp.search /\\| |\"|\&|\'|\/|:|<|>|@/g
  if search is -1
    false
  else
    true

###*
# Escape the local part of a JID.
#
# @see http://xmpp.org/extensions/xep-0106.html
# @param String local local part of a jid
# @return An escaped local part
###
JID::escapeLocal = (local) ->

  return null if local is null

  ### jshint -W044 ###
  local.replace /^\s+|\s+$/g, ''
    .replace /\\/g, '\\5c'
    .replace /\s/g, '\\20'
    .replace /\"/g, '\\22'
    .replace /\&/g, '\\26'
    .replace /\'/g, '\\27'
    .replace /\//g, '\\2f'
    .replace /:/g,  '\\3a'
    .replace /</g,  '\\3c'
    .replace />/g,  '\\3e'
    .replace /@/g,  '\\40'
    .replace /\3a/g,'\\5c3a'

###*
# Unescape a local part of a JID.
#
# @see http://xmpp.org/extensions/xep-0106.html
# @param String local local part of a jid
# @return unescaped local part
###
JID::unescapeLocal = (local) ->

  return null if local is null

  local.replace /\\20/g, ' '
    .replace /\\22/g, '\"'
    .replace /\\26/g, '&'
    .replace /\\27/g, '\''
    .replace /\\2f/g, '/'
    .replace /\\3a/g, ':'
    .replace /\\3c/g, '<'
    .replace /\\3e/g, '>'
    .replace /\\40/g, '@'
    .replace /\\5c/g, '\\'

if exports?     then  module.exports = JID
else if window? then  window.JID = JID
