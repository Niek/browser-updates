# browser-updates

This is an auto-updating repo (using GitHub actions) that contains a [browsers.json](browsers.json) file that lists the latest Chrome, Edge and Firefox browser versions of the stable and unstable channels.

You can set up a cron job to download the latest version of browsers.json with [this link](https://browser-updates.pages.dev/).

To use this in your TypeScript of JavaScript code:
```javascript
// TypeScript or ES6:
import browsers from ('./browsers.json')

// Or in ES5:
// const browsers = require('./browsers.json')

// Example: find the latest stable Chrome version
const version = browsers.chrome.stable.slice(-1).pop().version
```
