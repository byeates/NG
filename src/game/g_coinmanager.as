package game
{
	import com.globals;

	/** g_coin */
	public class g_coinmanager {
		/*===============
		PRIVATE
		===============*/
		static private var sm_instance:g_coinmanager;
		
		/*===============
		PROTECTED
		===============*/
		protected var m_coins:Vector.<g_coin>;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		
		public function g_coinmanager( pvt:privateclass ) {
			m_coins = new Vector.<g_coin>;
		}
		
		public function AddCoin( x:Number, y:Number ):void {
			var coin:g_coin = new g_coin( globals.midground, "coin" );
			coin.SetPosition(x,y);
			coin.Draw();
			
			m_coins.push( coin );
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		static public function get instance():g_coinmanager { return sm_instance = sm_instance ? sm_instance : new g_coinmanager( new privateclass() ); }
	}
}

class privateclass {}