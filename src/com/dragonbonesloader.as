package com
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	public class dragonbonesloader extends URLLoader
	{
		private var m_loadedAssets:Dictionary;
		private var m_assetPath:String;
		private var m_callback:Function;
		private var m_loadState:String;
		private var m_loadQue:Vector.<Object>;
		private var m_currentAssetName:String;
		private var m_assetsLoaded:int;
		private var m_loadAmount:int;
		private var m_onLoadCompleteCallback:Function;
		
		private static var _instance:dragonbonesloader;
		
		public function dragonbonesloader( pvt:privateclass ) {
			m_loadedAssets = new Dictionary();
			m_loadQue = new Vector.<Object>();
			m_assetPath = "../assets/";
			m_loadState = "ready";
			this.addEventListener( Event.COMPLETE, OnComplete );
			this.addEventListener( IOErrorEvent.IO_ERROR, OnError );
			dataFormat = URLLoaderDataFormat.BINARY;
			Security.allowDomain("*");
		}
		
		private function OnError( e:Event ):void { 
			throw new Error( e );
		}
		
		private function LoadAsset( path:String ):void {
			m_loadState = "loading";
			load( new URLRequest( path ) );
		}
		
		/**	Asset finished loading, store asset into loaded array and do callback
		 *	Continue through loadQue while it contains assets to be loaded*/
		private function OnComplete( e:Event ):void {
			var asset:* = e.target.data;
			m_loadedAssets[m_currentAssetName] = asset;
			m_loadState = "ready";
			
			++m_assetsLoaded;
			m_callback( asset, m_currentAssetName );
			
			m_loadQue.splice( 0, 1 );
			if ( m_loadQue.length > 0 ) {
				GetAsset( m_loadQue[ 0 ].name, m_loadQue[0].callback );
			} else {
				m_onLoadCompleteCallback();
			}
		}
		
		private function GetAsset( name:String, callback:Function=null ):* {
			if ( m_loadState != "loading" ) { 
				m_callback = callback;
				m_currentAssetName = name;
				LoadAsset( m_assetPath+name );
			}
		}
		
		/** Add assets to be loaded */
		public function AddAssetToLoad( name:String, callback:Function=null ):void { m_loadQue.push( { name:name, callback:callback } ); }
		/** Load all the assets in the queue */
		public function LoadAll():void { GetAsset( m_loadQue[ 0 ].name, m_loadQue[ 0 ].callback ); }
		
		
		/*=============================================================================
		Accessors and Mutators
		=============================================================================*/
		/**	Set path to load asset from, default is /assets/ folder */
		public function set assetPath( path:String ):void { m_assetPath = path; }
		public function get assetPath():String { return m_assetPath; }
		public function get remaining():int { return m_loadQue.length; }
		public function set loadAmount(val:int):void { m_loadAmount = val; }
		public function set loadCompleteCallback( f:Function ):void { m_onLoadCompleteCallback = f; }
		
		//singleton instance
		public static function get instance():dragonbonesloader { return _instance ? _instance : _instance = new dragonbonesloader( new privateclass() ); }
	}
}

class privateclass{}