// Generated by CoffeeScript 1.8.0
(function() {
  var JID, StringPrep, toUnicode, _ref;

  _ref = require('node-stringprep'), StringPrep = _ref.StringPrep, toUnicode = _ref.toUnicode;


  /**
   * JID implements
   * - Xmpp addresses according to RFC6122
   * - XEP-0106: JID Escaping
   *
   * @see http://tools.ietf.org/html/rfc6122#section-2
   * @see http://xmpp.org/extensions/xep-0106.html
   */

  JID = (function() {
    function JID(a, b, c) {
      this.local = this.domain = this.resource = null;
      if (a && !(b || c)) {
        this.parseJID(a);
      } else if (b) {
        this.setLocal(a);
        this.setDomain(b);
        this.setResource(c);
      } else {
        throw new Error('Argument error');
      }
    }

    JID.prototype.parseJID = function(s) {
      if (s.indexOf('@') >= 0) {
        this.setLocal(s.substr(0, s.indexOf('@')));
        s = s.substr(s.indexOf('@') + 1);
      }
      if (s.indexOf('/') >= 0) {
        this.setResource(s.substr(s.indexOf('/') + 1));
        s = s.substr(0, s.indexOf('/'));
      }
      return this.setDomain(s);
    };

    JID.prototype.toString = function(unescape) {
      var s;
      s = this.domain;
      if (this.local) {
        s = this.getLocal(unescape) + '@' + s;
      }
      if (this.resource) {
        s = s + '/' + this.resource;
      }
      return s;
    };


    /**
     * Convenience method to distinguish users
     */

    JID.prototype.bare = function() {
      if (this.resource) {
        return new JID(this.local, this.domain, null);
      } else {
        return this;
      }
    };


    /**
     * Comparison function
     */

    JID.prototype.equals = function(other) {
      return (this.local === other.local) && (this.domain === other.domain) && (this.resource === other.resource);
    };


    /* Deprecated, use setLocal() [see RFC6122] */

    JID.prototype.setUser = function(user) {
      return this.setLocal(user);
    };


    /**
     * Setters that do stringprep normalization.
     */

    JID.prototype.setLocal = function(local, escape) {
      escape = escape || this.detectEscape(local);
      if (escape) {
        local = this.escapeLocal(local);
      }
      this.local = this.user = local && this.prep('nodeprep', local);
      return this;
    };


    /**
     * http://xmpp.org/rfcs/rfc6122.html#addressing-domain
     */

    JID.prototype.setDomain = function(domain) {
      this.domain = domain && this.prep('nameprep', domain.split('.').map(toUnicode).join('.'));
      return this;
    };

    JID.prototype.setResource = function(resource) {
      this.resource = resource && this.prep('resourceprep', resource);
      return this;
    };

    JID.prototype.getLocal = function(unescape) {
      unescape = unescape || false;
      if (unescape) {
        return this.unescapeLocal(this.local);
      } else {
        return this.local;
      }
    };

    JID.prototype.prep = function(operation, value) {
      return (new StringPrep(operation)).prepare(value);
    };


    /* Deprecated, use getLocal() [see RFC6122] */

    JID.prototype.getUser = function() {
      return this.getLocal();
    };

    JID.prototype.getDomain = function() {
      return this.domain;
    };

    JID.prototype.getResource = function() {
      return this.resource;
    };

    JID.prototype.detectEscape = function(local) {
      var search, tmp;
      if (!local) {
        return false;
      }
      tmp = local.replace(/\\20/g, '').replace(/\\22/g, '').replace(/\\26/g, '').replace(/\\27/g, '').replace(/\\2f/g, '').replace(/\\3a/g, '').replace(/\\3c/g, '').replace(/\\3e/g, '').replace(/\\40/g, '').replace(/\\5c/g, '');

      /* detect if we have unescaped sequences */
      search = tmp.search(/\\| |\"|\&|\'|\/|:|<|>|@/g);
      if (search === -1) {
        return false;
      } else {
        return true;
      }
    };


    /**
     * Escape the local part of a JID.
     *
     * @see http://xmpp.org/extensions/xep-0106.html
     * @param String local local part of a jid
     * @return An escaped local part
     */

    JID.prototype.escapeLocal = function(local) {
      if (local === null) {
        return null;
      }

      /* jshint -W044 */
      return local.replace(/^\s+|\s+$/g, '').replace(/\\/g, '\\5c').replace(/\s/g, '\\20').replace(/\"/g, '\\22').replace(/\&/g, '\\26').replace(/\'/g, '\\27').replace(/\//g, '\\2f').replace(/:/g, '\\3a').replace(/</g, '\\3c').replace(/>/g, '\\3e').replace(/@/g, '\\40').replace(/\3a/g, '\\5c3a');
    };


    /**
     * Unescape a local part of a JID.
     *
     * @see http://xmpp.org/extensions/xep-0106.html
     * @param String local local part of a jid
     * @return unescaped local part
     */

    JID.prototype.unescapeLocal = function(local) {
      if (local === null) {
        return null;
      }
      return local.replace(/\\20/g, ' ').replace(/\\22/g, '\"').replace(/\\26/g, '&').replace(/\\27/g, '\'').replace(/\\2f/g, '/').replace(/\\3a/g, ':').replace(/\\3c/g, '<').replace(/\\3e/g, '>').replace(/\\40/g, '@').replace(/\\5c/g, '\\');
    };

    return JID;

  })();

  if (typeof exports !== "undefined" && exports !== null) {
    module.exports = JID;
  } else if (typeof window !== "undefined" && window !== null) {
    window.JID = JID;
  }

}).call(this);
