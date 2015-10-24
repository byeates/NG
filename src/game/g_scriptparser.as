package game
{
	import com.globals;
	
	import starling.display.DisplayObject;

	/** g_scriptparser */
	public class g_scriptparser {
		/*===============
		PRIVATE
		===============*/
		private var m_script:String;
		private var m_commands:Array;
		private var m_currentCommand:String;
		static private var sm_instance:g_scriptparser;
		
		/*===============
		PROTECTED
		===============*/
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		
		public function g_scriptparser( pvt:privateclass ) {
			m_commands = [];
		}
		
		public function SetScript( script:String ):void {
			m_script = script;
			m_commands = m_script.split( "\r" );
		}
		
		public function Init():void {
			parseNextCommand();
		}
		
		public function parseNextCommand():void {
			if ( m_commands.length > 0 ) {
				parseCommand( m_commands.shift() );
			}

		}
		
		public function parseCommand( fullCommand:String ):void {
			if ( fullCommand.indexOf( "//" ) != -1 ) { parseNextCommand(); return; }
			fullCommand = fullCommand.replace( "\n", "" );
			m_currentCommand = fullCommand;
			
			var comp:Array = fullCommand.split( " " );
			var compmand:String = comp[ 0 ];
			var performOp:Boolean = true;
			
			if ( performOp ) {
				var asset:DisplayObject = comp[0].split( "." )[0] == "player" ? globals.player : null;
			}
			//if we are manipulating an assets property
			if ( asset && performOp ) {
				var property:String = comp[0].split( "." )[1];
				if ( property.search( /[xy]/g ) != -1 ) {
					position( asset, property, comp[1] == "-" ? -comp[2] : comp[2] );
					return;
				}
				switch( comp[1] ) {
					case "+":	
						break;
					
					case "-":	asset[ property ] -= comp[2];
						break;
					
					case "/":	asset[ property ] /= comp[2];
						break;
					
					case "*":	asset[ property ] *= comp[2];
						break;
				}
			}
			else if ( asset ) {
				
			}
			//if we are calling a function
			else if ( !performOp ) {
				var func:String = comp[0].substring( 0, comp[0].indexOf("(") );
				switch( func ) {
					case "pause":
						//g_dispatcher.instance.Stop();
						break;
				}
			}
			parseNextCommand();
		}
		
		public function position( asset:DisplayObject, property:String, amount:Number ):void {
			if ( asset is g_entity ) {
				switch( property ) {
					case "x":
						asset[ "SetPosition" ]( asset[ property ] + amount, asset.y );
					break;
					
					case "y":
						asset[ "SetPosition" ]( asset.x, asset[ property ] + amount );
						break;
				}
			}
			parseNextCommand();
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		public function get currentCommand():String { return m_currentCommand; }
		static public function get instance():g_scriptparser { return sm_instance = sm_instance ? sm_instance : new g_scriptparser( new privateclass() ); }
	}
}

class privateclass {}