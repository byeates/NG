package game
{
	import com.bs_internal;
	import com.globals;
	
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	use namespace bs_internal;
	/*========================================================================================
	g_state handles g_main state changes in from events
	========================================================================================*/
	public class g_state implements g_istatemachine
	{	
		/*===============
		PRIVATE			
		===============*/
		/** singleton */
		static private var m_instance	:g_state;
		private var m_state				:String;
		
		/*===============
		PUBLIC			
		===============*/
		/** Start function to call when we are ready to start the game (after the menu is done) */
		public var Start				:Function;
		public var elapsedTime			:Number;
		
		public function g_state( pvt:privateclass ) { m_state = globals.MENU; }
		
		/** Initializer */
		public function Init():void {}
		
		/** Handle a touch event state based on our current game state */
		public function StateHandler( input:* ):void {
			
			//Touch event? (we just pass the relative touch, and discard the event object
			if ( input.hasOwnProperty( "phase" ) && m_state == globals.MENU ) {
				g_dispatcher.instance.DispatchTouch( input );
			}
			
			//KeyboardEvent?
			else if ( input is KeyboardEvent ) {
				g_dispatcher.instance.DispatchKeyboard( input );
			}
		}
		
		/** Dispatch all the frame event functions */
		public function UpdateHandler( elapsedTime:Number ):void {
			this.elapsedTime = elapsedTime;
			g_dispatcher.instance.DispatchFrame( elapsedTime );
		}
		
		public function SetState( state:String ):void {
			m_state = state;
			globals.echo( "state set to: " + m_state );
		}
		
		public function get state():String { return m_state; }
		
		static public function get instance():g_state { return m_instance = m_instance ? m_instance : new g_state( new privateclass() ); }
	}
}

class privateclass {}