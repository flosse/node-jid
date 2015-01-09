{ StringPrep, toUnicode }  = require 'node-stringprep'

###*
# JID implements
# - Xmpp addresses according to RFC6122
# - XEP-0106: JID Escaping
#
# @see http://tools.ietf.org/html/rfc6122#section-2
# @see http://xmpp.org/extensions/xep-0106.html
###

class JID

  constructor: (a, b, c) ->
    @local = @domain = @resource = null

    if a and (not b) and (not c)
      @parseJID a
    else if b
      @setLocal a
      @setDomain b
      @setResource c
    else
      throw new Error 'Argument error'

  parseJID: (s) ->

    if s.indexOf('@') >= 0
      @setLocal s.substr 0, s.indexOf '@'
      s = s.substr s.indexOf('@') + 1

    if s.indexOf('/') >= 0
      @setResource s.substr s.indexOf('/') + 1
      s = s.substr 0, s.indexOf '/'
    @setDomain s

  toString: (unescape) ->
    s = @domain
    if @local    then s = @getLocal(unescape) + '@' + s
    if @resource then s = s + '/' + @resource
    s

  ###*
  # Convenience method to distinguish users
  ###
  bare: ->
    if @resource
      new JID @local, @domain, null
    else
      @

  ###*
  # Comparison function
  ###
  equals: (other) ->
    (@local     is other.local    ) and
    (@domain    is other.domain   ) and
    (@resource  is other.resource )

  ### Deprecated, use setLocal() [see RFC6122] ###
  setUser: (user) -> @setLocal user

  ###*
  # Setters that do stringprep normalization.
  ###
  setLocal: (local, escape) ->
    escape = escape or @detectEscape local

    if escape
      local = @escapeLocal local

    @local = @user = local and @prep 'nodeprep', local
    @

  ###*
  # http://xmpp.org/rfcs/rfc6122.html#addressing-domain
  ###
  setDomain: (domain) ->
    @domain =
      domain and @prep 'nameprep', domain.split('.').map(toUnicode).join '.'
    @

  setResource: (resource) ->
    @resource = resource and @prep('resourceprep', resource)
    @

  getLocal: (unescape) ->
    unescape = unescape or false

    if unescape
      @unescapeLocal(@local)
    else
      @local

  prep: (operation, value) -> (new StringPrep operation).prepare value

  ### Deprecated, use getLocal() [see RFC6122] ###
  getUser: -> @getLocal()

  getDomain: -> @domain

  getResource: -> @resource

  detectEscape: (local) ->

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
  escapeLocal: (local) ->

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
  unescapeLocal: (local) ->

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
