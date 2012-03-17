package {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetGroupReceiveMode;
	import flash.net.NetGroupReplicationStrategy;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.utils.getTimer;
  import flash.media.Microphone;    
  import flash.media.SoundCodec;
  import flash.utils.*;

	public class VoiceCast extends Sprite {
		private var netConnection:NetConnection;
		private var groupSpec:GroupSpecifier;
		private var netGroup:NetGroup;
		private var publishStream:NetStream;
		private var receiveStream:NetStream;
    private var mic:Microphone;

    private var rtmfpServerUri:String = 'rtmfp://p2p.rtmfp.net/d50e06cd29e27d62167444cd-b7f858253166/';
    private var groupName:String = 'test_cast';
    private var myStreamName:String = '';

    private var receivers:Object = new Object();

    public function VoiceCast () {
      Security.allowDomain('*');
      ExternalInterface.addCallback('connect', connect);
      ExternalInterface.addCallback('startPublish', startPublish);
      connect();
    }

    public function connect ():void {
      if (netConnection) {
        netConnection.close();
        netConnection = null;
      }

      netConnection = new NetConnection();
      netConnection.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);
      netConnection.connect(rtmfpServerUri);
    }

    private function onNetConnectionConnect ():void {
      groupSpec = new GroupSpecifier(groupName);
      groupSpec.multicastEnabled = true;
      groupSpec.serverChannelEnabled = true;
      groupSpec.objectReplicationEnabled = true;
      groupSpec.postingEnabled = true;

      netGroup = new NetGroup(
        netConnection, groupSpec.toString());
      netGroup.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);
    }

    private function startPublish ():void {
      myStreamName = (new Date).toString();
      log(myStreamName);
      
      publishStream = new NetStream(
        netConnection, groupSpec.toString());
      publishStream.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);      
      mic = Microphone.getMicrophone();
      mic.codec = SoundCodec.SPEEX;
      mic.framesPerPacket = 1;
      mic.encodeQuality = 7;
      mic.setSilenceLevel(0);
      //publishStream.audioReliable = true;
      publishStream.attachAudio(Microphone.getMicrophone());
      publishStream.publish(myStreamName);

      netGroup.post(myStreamName);
      setInterval(function ():void {
          netGroup.post(myStreamName);
        }, 30000);
    }

    private function onNetGroupConnect (group:Object):void {
      setTimeout(function ():void {
          log('request');
          netGroup.post('tell me who are casting!' + (new Date).toString());
        }, 1000);
    }

    private function onCastersChange (streamName:String):void {
      if (!(streamName in receivers)) {
        receivers[streamName] = new NetStream(
          netConnection, groupSpec.toString());
        receivers[streamName].addEventListener(
          NetStatusEvent.NET_STATUS, netStatusHandler);
        receivers[streamName].play(streamName);
      }
    }

    private function onMessage (message:String):void {
      log(message);
      if (message.indexOf('tell') >= 0) {
        if (myStreamName.length > 0) {
          log('told');
          netGroup.post(myStreamName);
        }
      } else {
        onCastersChange(message);
      }
    }

    private function netStatusHandler (event:NetStatusEvent):void {
      log(event.info.code);
      switch (event.info.code) {
        case "NetConnection.Connect.Success":
        onNetConnectionConnect();
        break;

				case "NetConnection.Connect.Rejected":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.IdleTimeout":
				case "NetConnection.Connect.Rejected":
        // TODO: disconnected
        break;
        
        case "NetGroup.Connect.Success":
        onNetGroupConnect(event.info.group);
				break;
				
				case "NetGroup.Connect.Failed":
				case "NetGroup.Connect.Rejected":
        // TODO: disconnected
				break;

        case "NetStream.Publish.Start":        
        break;

        case "NetGroup.Posting.Notify":
        onMessage(event.info.message);
        break;
      }
    }
	}
}