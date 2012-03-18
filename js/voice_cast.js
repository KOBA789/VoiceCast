var util = require("util");
var EventEmitter = require('events').EventEmitter;

window.VoiceCastHandler = function (eventName, arg) {
  console.log(eventName);
  if (window.VoiceCastInstance) {
    window.VoiceCastInstance.emit(eventName, arg);
  }
};

var VoiceCast = (function () {
  function VoiceCast (elementId, width, height, swfFile) {
    if (typeof width === 'string') {
      swfFile = width;
      width = undefined;
    }
    if (elementId === undefined) { elementId = 'voice-cast'; }
    if (width     === undefined) { width     = 215; }
    if (height    === undefined) { height    = 138; }
    if (swfFile   === undefined) { swfFile   = 'voice_cast.swf'; }

    var params = {
      wmode: "transparent",
      allowscriptaccess: "sameDomain"
    };

    swfobject.embedSWF(
      swfFile, elementId, width.toString(), height.toString(),
      '10.1', 'expressInstall.swf', null, params);
    this.swf = swfobject.getObjectById(elementId);
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
})();

module.exports = VoiceCast;