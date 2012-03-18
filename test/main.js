window.onload = function () {
  // 'rtmfp://p2p.rtmfp.net/d50e06cd29e27d62167444cd-b7f858253166/';
};

var params = {
  wmode: "transparent",
  allowscriptaccess: "sameDomain"
};

swfobject.embedSWF("VoiceCast.swf",
                   "voice-cast",
                   "215", "138", "10.1.0",
                   "expressInstall.swf", params);
