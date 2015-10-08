package game
{
	import game.enemy.ge_enemyspawner;
	import game.misc.gm_item;
	
	import renderer.r_collidable;
	import renderer.r_tile;

	/*=============================================================================
	g_level
	- only responsible for holding level relevant data, like world collisions (floors, walls), spawners, etc
	=============================================================================*/
	public class g_level
	{
		/*===============
		PROTECTED			
		===============*/
		//containers for level elements
		protected var m_spawners		:Vector.<ge_enemyspawner>;
		protected var m_collisions		:Vector.<r_collidable>;
		protected var m_tiles			:Vector.<r_tile>;
		protected var m_items			:Vector.<gm_item>;
		protected var m_playerStart		:Vector2D;
		
		/*===============
		PUBLIC			
		===============*/
		public var levelWidth			:Number;
		public var levelHeight			:Number;
		
		/*===============
		STATIC			
		===============*/
		static private var sm_instance	:g_level;
		
		public function g_level( pvt:privateclass ) {
			m_spawners 		= new Vector.<ge_enemyspawner>;
			m_tiles 		= new Vector.<r_tile>;
			m_collisions 	= new Vector.<r_collidable>;
			m_items			= new Vector.<gm_item>;
			m_playerStart	= new Vector2D;
		}
		
		public function Destroy():void {
			var i:int;
			for ( ; i < m_spawners.length ; ++i ) {
				m_spawners[i].Destroy();
			}
			for ( i=0; i < m_collisions.length ; ++i ) {
				m_collisions[i].Destroy();
			}
			Clear();
		}
		
		/** Clear all the stored collisions, spawners, and relevant level storage */
		public function Clear():void {
			m_spawners.length = 0;
			m_collisions.length = 0;
		}
		
		public function Init():void {
			var i:int;
			for ( ; i < m_spawners.length; ++i ) {
				m_spawners[i].Init();
			}
		}
		
		public function AddToCollisions( collision:r_collidable ):void {
			if ( m_collisions.indexOf( collision ) == -1 ) {
				m_collisions.push( collision );
			}
		}
		
		public function RemoveFromCollisions( collision:r_collidable ):void {
			if ( m_collisions.indexOf( collision ) != -1 ) {
				m_collisions.splice( m_collisions.indexOf( collision ), 1 );
			}
		}
		
		public function AddToSpawners( spawner:ge_enemyspawner ):void {
			if ( m_spawners.indexOf( spawner ) == -1 ) {
				m_spawners.push( spawner );
			}
		}
		
		public function RemoveFromSpawners( spawner:ge_enemyspawner ):void {
			if ( m_spawners.indexOf( spawner ) != -1 ) {
				m_spawners.splice( m_spawners.indexOf( spawner ), 1 );
			}
		}
		
		public function AddToTiles( tile:r_tile ):void {
			if ( m_tiles.indexOf( tile ) == -1 ) {
				m_tiles.push( tile );
			}
		}
		
		public function AddToItems( item:gm_item ):void {
			if ( m_items.indexOf( item ) == -1 ) {
				m_items.push( item );
			}
		}
		
		public function RemoveFromTiles( tile:r_tile ):void {
			if ( m_tiles.indexOf( tile ) != -1 ) {
				m_tiles.splice( m_tiles.indexOf( tile ), 1 );
			}
		}
		
		public function RemoveFromItems( item:gm_item ):void {
			if ( m_items.indexOf( item ) != -1 ) {
				m_items.splice( m_items.indexOf( item ), 1 );
			}
		}
		
		public function SetPlayerStart( x:Number, y:Number ):void {
			m_playerStart.x = x; m_playerStart.y = y;
		}
		
		public function GetPlayerStart():Vector2D { return m_playerStart; }
	
		static public function get instance():g_level { return sm_instance = sm_instance ? sm_instance : new g_level( new privateclass() ); }
		
	}
}

class privateclass{}