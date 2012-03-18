var util = require("util");
var EventEmitter = require('events').EventEmitter;

window.VoiceCastHandler = function (eventName, arg) {
  if (window.VoiceCastInstance) {
    window.VoiceCastInstance.emit(eventName, arg);
  }
};

var VoiceCast = (function () {
  function VoiceCast (elementId, width, height, swf) {
    if (typeof width === 'string') {
      swf = width;
      width = null;
    }
    if (elementId === null) { elementId = 'voice-cast'; }
    if (width     === null) { width     = 215; }
    if (height    === null) { height    = 138; }
    if (swf       === null) { swf       = 'voice_cast.swf'; }

    var params = {
      wmode: "transparent",
      allowscriptaccess: "sameDomain"
    };

    this.swf = swfobject.embedSWF(
      swf, elementId, width.toString(), height.toString(),
      'expressInstall.swf', params);
    window.VoiceCastInstance = this;
  }

  util.inherits(VoiceCast, EventEmitter);

  VoiceCast.prototype.connect = function (uri, groupName) {
    this.swf.connect(uri, groupName);
  };

  VoiceCast.prototype.close = function () {
    this.swf.close();
  };

  VoiceCast.prototype.startPublish = function () {
    this.swf.startPublish();
  };

  VoiceCast.prototype.stopPublish = function () {
    this.swf.stopPublish();
  };

  return VoiceCast;
});