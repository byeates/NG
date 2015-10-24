package game.enemy
{
	import com.assets;
	import com.globals;
	
	import flash.geom.Point;
	
	import game.g_dispatcher;
	import game.g_entity;
	
	import starling.core.Starling;
	//import starling.extensions.PDParticleSystem;
	//import starling.extensions.ParticleSystem;

	/*=============================================================================
	ge_enemyspawner
	- controls the spawn rate, location, and type of enemies
	=============================================================================*/
	public class ge_enemyspawner
	{
		/*===============
		PROTECTED			
		===============*/
		/** position to spawn enemies */
		protected var m_x:Number;
		protected var m_y:Number;
		
		/** if spawn delay is 0, there will only be 1 enemy spawned at a time */
		protected var m_spawnDelay:Number;
		
		/** current type of enemy to spawn */
		protected var m_currentType:String;
		
		/** current running time */
		protected var m_currentTime:Number;
		
		/** this flag is only used when m_spawnDelay is set to 0, 
		 * it toggles when the spawned enemy is destroyed */
		protected var m_spawnReady:Boolean;
		
		/** particle system is the effect created at spawner's location */
		//private var m_particleSystem:ParticleSystem;
		
		/** this is set to the last spawned enemy */
		protected var m_currentEnemy:g_entity;
		protected var m_spawnDirection:String;
		protected var m_direction:Vector2D;
		
		/*===============
		PUBLIC			
		===============*/
		/** number of enemies to spawn per minute */
		public var enemiesPerMinute:int;
		
		/** types of enemies: random (any), fast, etc. */
		public var enemyTypes:Array;
		
		/*===============
		CONSTANTS			
		===============*/
		static protected const RANDOM		:String = "random";
		static protected const LEFT			:String = "left";
		static protected const RIGHT		:String = "right";
		static protected const UP			:String = "up";
		static protected const DOWN			:String = "down";
		
		public function ge_enemyspawner( x:Number, y:Number ) {
			m_x = x;
			m_y = y;
			m_spawnReady = true;
		}
		
		public function Init():void {
			m_spawnDelay = enemiesPerMinute > 0 ? 60000 / enemiesPerMinute : 0;
			g_dispatcher.instance.AddToDispatch( Update );
			AddParticleEffect();
		}
		
		public function Destroy():void {
			g_dispatcher.instance.RemoveFromDispatch( Update );
		}
		
		protected function Update( elapsedTime:Number ):void {
			if ( m_spawnDelay > 0 ) {
				m_currentTime += elapsedTime;
				if ( m_currentTime > m_spawnDelay ) {
					SpawnEnemy();
					m_currentTime = 0;
				}
			}
			else if ( m_spawnReady ) {
				SpawnEnemy();
				m_spawnReady = false;
			}
			else if ( m_currentEnemy.isDestroyed ) {
				m_spawnReady = true;
			}
		}
		
		protected function SpawnEnemy():void {
			if ( m_currentType == RANDOM ) {
				m_currentType = ge_enemy.TYPES[ Math.floor( Math.random() * ge_enemy.TYPES.length ) ];
			} 
			else {
				m_currentType = enemyTypes.length > 0 ? enemyTypes[ Math.floor( Math.random() * enemyTypes.length ) ] : enemyTypes[0];
			}
			m_currentEnemy = ge_enemymanager.instance.CreateEnemy( globals.midground, m_currentType, {x: m_x, y:m_y, direction: m_direction } );
		}
		
		public function set spawnDirection( value:String ):void { 
			m_spawnDirection = value; 
			m_direction = new Vector2D();
			switch( m_spawnDirection ) {
				case RIGHT:	m_direction.x = 1;
					break;
				
				case LEFT:	m_direction.x = -1;
					break;
				
				case UP:	m_direction.y = -1;
					break;
				
				case DOWN:	m_direction.y = 1;
					break;
			}
		}
		
		/** Particle effect, update emitterX and emitterY to player position.
		 * 	The particle.pex file can be update to change values as well, (pex is an xml)
		 */
		protected function AddParticleEffect():void {
			/*m_particleSystem = new PDParticleSystem( assets.GetConfig( "particle" ), assets.GetTexture( "particle" ) );
			m_particleSystem.emitterX = m_x;
			m_particleSystem.emitterY = m_y;
			m_particleSystem.start();
			
			globals.foreground.addChild( m_particleSystem );
			Starling.juggler.add( m_particleSystem );*/
		}
	}
}