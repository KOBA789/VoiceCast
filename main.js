window.onload = function () {

};

var params = {
  wmode: "transparent",
  allowscriptaccess: "sameDomain"
};

swfobject.embedSWF("VoiceCast.swf",
                   "voice-cast",
                   "300", "300", "10.1.0",
                   "expressInstall.swf", params);
