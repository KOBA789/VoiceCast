var VoiceCast = require('./voice_cast');

window.onload = function () {
  var voiceCast = new VoiceCast();
  voiceCast.on('ready', function () {
    voiceCast.connect('rtmfp://p2p.rtmfp.net/d50e06cd29e27d62167444cd-b7f858253166/', 'test_group');
  });

  voiceCast.on('NetConnection.Connect.Success', function () {
    
  });
};