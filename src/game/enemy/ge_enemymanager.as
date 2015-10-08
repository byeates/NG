package game.enemy
{
	import com.bs_internal;
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import game.g_entity;
	import game.turret.gt_turretmanager;
	
	import starling.display.DisplayObjectContainer;

	use namespace bs_internal;
	/*========================================================================================
	Factory and manager for enemies
	========================================================================================*/
	public class ge_enemymanager
	{
		/*===============
		PROTECTED
		===============*/
		/** list of created enemies */
		protected var m_activeEnemies:Vector.<g_entity>;
		
		/** list of removed enemies */
		protected var m_disabledEnemies:Dictionary;
		
		/*===============
		PRIVATE
		===============*/
		/** singleton instance */
		private static var m_instance:ge_enemymanager;
		
		public function ge_enemymanager( pvt:privateclass ) {
			m_activeEnemies = new Vector.<g_entity>;
			m_disabledEnemies = new Dictionary;
		}
		
		/** kill everything! */
		public function Destroy():void {
			var i:int;
			for ( ; i < m_activeEnemies.length; ++i ) {
				m_activeEnemies[i].Death();
			}
			for ( var key:* in m_disabledEnemies ) {
				for ( i=0; i < m_disabledEnemies[key].length; ++i ) {
					m_disabledEnemies[key][i].Destroy();
				}
			}
			m_activeEnemies.length = 0; 
			m_disabledEnemies = new Dictionary;;
		}
		
		/** Create any type of enemy from the type list
		 * @param parent - parent container for the enemy
		 * @param type - type of enemy (eg. "fast")
		 * @param args - any fields to be applied to the enemy (eg. {x: 100, y:100} )
		 * */
		public function CreateEnemy( parent:DisplayObjectContainer, type:String, args:Object=null ):g_entity {
			var enemy:g_entity;
			//check to see if we have a disabled enemiy ready to go, if we do spawn it otherwise create a new one
			if ( !m_disabledEnemies[ type ] || m_disabledEnemies[ type ] && m_disabledEnemies[ type ].length <= 0 ) {
				var classRef:Class = getDefinitionByName( "game.enemy::ge_enemy" + type ) as Class;
				switch( type ) {
					case "fast": enemy = new classRef( parent, "enemy_" + type, false, 0, true );
						break;
					
					case "flying": enemy = new classRef( parent, "enemy_" + type, false, 0, true );
						break;
				}
				enemy[ "onDestroyedCallback" ] = RemoveEnemy;
				if ( args ) { enemy[ "StoreProperties" ]( args ); }
			} 
			else {
				enemy = m_disabledEnemies[ type ].shift();
				enemy[ "Reset" ]();
			}
			
			enemy.Draw();
			m_activeEnemies.push( enemy );
			gt_turretmanager.instance.UpdateEnemyLists();
			return enemy;
		}
		
		/** Remove the enemy from the active list, disable it, and add to the disabled list to be re-used if needed */
		public function RemoveEnemy( enemy:g_entity ):void {
			m_activeEnemies.splice( m_activeEnemies.indexOf( enemy ), 1 );
			if ( !m_disabledEnemies[ enemy["type"] ] ) {
				m_disabledEnemies[ enemy[ "type" ] ] = [];
			}
			m_disabledEnemies[ enemy[ "type" ] ].push(enemy);
			gt_turretmanager.instance.UpdateEnemyLists();
		}
		
		public function get activeEnemies():Vector.<g_entity> { return m_activeEnemies; }
		
		/** returns the singleton instance */
		static public function get instance():ge_enemymanager { return m_instance = m_instance ? m_instance : new ge_enemymanager( new privateclass() ); }
	}
}

class privateclass {}