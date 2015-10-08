package renderer
{
	import com.globals;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	/*========================================================================================
	OEL file loader for puzzle levels
	========================================================================================*/
	public class r_loader extends URLLoader
	{
		private var m_filePath			:String;
		private var m_loadState			:String;
		private var m_callback			:Function;
		private var m_loadQue			:Vector.<Object>;
		private var m_loadedFiles		:Dictionary;
		private var m_currentFileName	:String;
		
		/** singleton */
		static private var sm_instance	:r_loader;
		
		public function r_loader( pvt:privateclass ) {
			m_loadedFiles 	= new Dictionary();
			m_loadQue 		= new Vector.<Object>();
			m_filePath		= "../levels/";
			m_loadState 	= globals.READY;
			this.addEventListener( Event.COMPLETE, OnComplete );
		}
		
		private function LoadLevel( path:String ):void {
			globals.echo( "loading level: " + path );
			m_loadState = globals.LOADING;
			load( new URLRequest( path ) );
		}
		
		private function OnComplete( e:Event ):void {
			var extension:String
			if ( this.dataFormat == URLLoaderDataFormat.BINARY ) {
				var loader:URLLoader = e.target as URLLoader;
				var data:ByteArray = loader.data as ByteArray;
				var levelObject:Object = data.readObject();
				extension = ".rmf";
				m_loadedFiles[ m_currentFileName+extension ] = levelObject;
			}
			else {
				extension =  ".script";
				var script:String = e.target.data;
				m_loadedFiles[ m_currentFileName+extension ] = script;
			}
			m_callback( levelObject );
			
			//set the state ready to load
			m_loadState = globals.READY;
			
			if ( m_loadQue.length > 0 ) {
				GetFile( m_loadQue[ 0 ].name, m_loadQue[ 0 ].extension, m_loadQue[0].callback );
				m_loadQue.splice( 0, 1 );
			}
		}
		
		/** Load a level file or a script file
		 * @param name - name of the level file or script file
		 * @param extension - set this to .rmf or .script respectively
		 * @param callback - method to call once the level file has finished loading
		 * */
		public function GetFile( name:String, extension:String=".rmf", callback:Function=null ):* {
			if ( m_loadedFiles[name+extension] ) { 
				return m_loadedFiles[name+extension];
			}
			if ( m_loadState != globals.LOADING ) { 
				m_callback = callback;
				m_currentFileName = name;
				this.dataFormat = extension == ".rmf" ? URLLoaderDataFormat.BINARY : URLLoaderDataFormat.TEXT;
				LoadLevel( m_filePath+name+extension );
			} 
			else if ( m_loadQue.indexOf( name ) == -1 ) {
				m_loadQue.push( { name:name, extension: extension, callback:callback } );
			}
		}
		
		
		/*=============================================================================
		Accessors and Mutators
		=============================================================================*/
		public function set filePath( path:String ):void { m_filePath = path; }
		public function get filePath():String { return m_filePath; }
		
		public static function get instance():r_loader { return sm_instance ? sm_instance : sm_instance = new r_loader( new privateclass() ); }
	}
}

class privateclass{}