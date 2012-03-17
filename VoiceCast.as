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

	public class VoiceCast extends Sprite {
		private var netConnection:NetConnection;
		private var groupSpec:GroupSpecifier;
		private var netGroup:NetGroup;
		private var publishStream:NetStream;
		private var receiveStream:NetStream;
    private var mic:Microphone;

    private var rtmfpServerUri:String = 'rtmfp://p2p.rtmfp.net/d50e06cd29e27d62167444cd-b7f858253166/';
    private var groupName:String = 'test_cast';
    private var streamName:String = 'voice_cast';

    public function VoiceCast () {
      Security.allowDomain('*');
      //log('OK1');
      ExternalInterface.addCallback('connect', connect);
      ExternalInterface.addCallback('startPublish', startPublish);
      //connect();
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
      
      netGroup = new NetGroup(
        netConnection, groupSpec.toString());
      netGroup.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);
    }

    private function startPublish ():void {
      publishStream = new NetStream(
        netConnection, groupSpec.toString());
      publishStream.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);      
      mic = Microphone.getMicrophone();
      //mic.codec = SoundCodec.PCMU;
      publishStream.attachAudio(Microphone.getMicrophone());
      publishStream.publish(streamName);
    }

    private function onNetGroupConnect (group:Object):void {
      receiveStream = new NetStream(
        netConnection, groupSpec.toString());
      receiveStream.addEventListener(
        NetStatusEvent.NET_STATUS, netStatusHandler);
      receiveStream.play(streamName);
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
      }
    }
	}
}