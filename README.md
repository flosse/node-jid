# JID

Parse and handle [XMPP](http://xmpp.org)/Jabber Identifiers.

[![Build Status](https://secure.travis-ci.org/flosse/node-jid.svg?branch=master)](http://travis-ci.org/flosse/node-jid)
[![Dependency Status](https://gemnasium.com/flosse/node-jid.svg)](https://gemnasium.com/flosse/node-jid)

## Usage

```javascript
var JID = require("jid");

var myJID = new JID("foo@bar.baz.tld/bla");

myJID.local     // "foo"
myJID.domain    // "bar.baz.tld"
myJID.resource  // "bla"

myJID.toString()        // "foo@bar.baz.tld/bla"
myJID.bare().toString() // "foo@bar.baz.tld"

```

## Install

```
npm i --save jid
```

## Test

```
npm t
```

## Build

```
npm run compile
```

## Pack for browser usage

```
npm run pack
```
