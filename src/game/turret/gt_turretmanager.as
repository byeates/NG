package game.turret
{
	import flash.utils.getDefinitionByName;
	
	import game.g_dispatcher;
	import game.g_entity;
	import game.enemy.ge_enemymanager;
	
	import starling.display.DisplayObjectContainer;

	public class gt_turretmanager
	{
		/*===============
		PROTECTED
		===============*/
		/** active turret index */
		protected var m_activeTurret		:int;
		
		/** all of the created active turrets */
		protected var m_turrets				:Vector.<g_entity>;
		
		/** the number of available turrets to choose from */
		protected var m_availableTurrets	:Vector.<String>;
		
		/** singleton */
		static protected var m_instance 	:gt_turretmanager;
		
		/*===============
		CONSTANTS
		===============*/
		public const TURRET_TYPES			:Array 	= [ "turret_ranged", "turret_melee", "turret_bomb" ];
		
		/** total number of unique turret types */
		public const NUM_TURRETS			:int 	= TURRET_TYPES.length;
		
		public function gt_turretmanager( pvt:privateclass ) {
			m_turrets = new Vector.<g_entity>;
			m_availableTurrets = new Vector.<String>;
		}
		
		private function Update( elapsedTime:Number ):void {
			//broad phase spatially partioned, set the enemies vector for all active turrets accordingly
			
			//next update all turrets
			var i:int;
			for ( ; i < m_turrets.length; ++i ) {
				//don't update the turret if it's not loaded
				if ( m_turrets[i].isLoaded ) {
					m_turrets[i].Update( elapsedTime );
				}
			}
		}
		
		/** returns the current selected turret type (set from activeTurret) */
		public function GetSelectedTurretType():String { return TURRET_TYPES[ m_activeTurret ]; }
		
		public function AddTurret( parent:DisplayObjectContainer, x:Number, y:Number ):g_entity {
			var type:String = GetSelectedTurretType();
			var classRef:Class = getDefinitionByName( "game.turret::gt_" + type.replace("_", "") ) as Class;
			var turret:g_entity = new classRef( parent, type, x, y );
			m_turrets.push( turret );
			
			//Start updates if we just added our first turret
			if ( m_turrets.length == 1 ) {
				g_dispatcher.instance.AddToDispatch( Update );
			}
			if ( turret.hasOwnProperty( "enemies" ) ) {
				turret[ "enemies" ] = ge_enemymanager.instance.activeEnemies;
			}
			if ( turret.hasOwnProperty( "health" ) ) {
				turret[ "health" ] = 3; //TODO: change this based on user upgraded value
			}
			return turret;
		}
		
		public function OnTurretPickup(type:String):void {
			if ( m_availableTurrets.indexOf( type ) == -1 ) {
				m_availableTurrets.push( type );
			}
		}
		
		public function RemoveTurret( turret:g_entity ):void {
			if ( m_turrets.indexOf( turret ) != -1 ) {
				m_turrets.splice( m_turrets.indexOf( turret ), 1 );
			}
		}
		
		public function UpdateEnemyLists():void {
			var i:int;
			for ( ; i < m_turrets.length; ++i ) {
				m_turrets[i][ "enemies" ] = ge_enemymanager.instance.activeEnemies;
			}
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		public function get activeTurret():int { return m_activeTurret; }
		public function set activeTurret( val:int ):void { m_activeTurret = val; }
		public function get availableTurrets():Vector.<String> { return m_availableTurrets; }
		
		public function get turrets():Vector.<g_entity> { return m_turrets; }
		
		static public function get instance():gt_turretmanager { return m_instance ? m_instance : m_instance = new gt_turretmanager( new privateclass ); }		
	}
}

class privateclass {}