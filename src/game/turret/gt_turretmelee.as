package game.turret
{
	import com.globals;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import game.g_entity;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.AABB;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import starling.display.DisplayObjectContainer;
	
	public class gt_turretmelee extends gt_turret
	{
		/*===============
		PROTECTED
		===============*/
		//collision listeners
		protected var m_floorListener:InteractionListener;
		protected var m_enemyListener:InteractionListener;
		protected var m_wallListener:InteractionListener;
		
		/** broad phase list of enemies */
		protected var m_enemies:Vector.<g_entity>;
		
		/** patrol bounds, area to roam for the melee turret */
		protected var m_patrolBounds:Rectangle;
		
		/** the current movement state of the turret */
		protected var m_moveState:String;
		
		/** delay between hits for enemies */
		static protected var m_hitDelay:int;
		static protected var m_hitTime:int;
		
		/*===============
		PUBLIC
		===============*/
		/** amount of damage the bomb turret will do, default is 3 */
		static public var damage:int;
		
		/*===============
		CONSTANTS
		===============*/
		protected const CB_MELEE:CbType = new CbType();
		
		public function gt_turretmelee(parent:DisplayObjectContainer, asset:String, x:Number=0, y:Number=0)
		{
			super(parent, asset, false, 0, true);
		}
		
		override public function SetDefaults():void {
			super.SetDefaults();
			
			m_hitDelay = 2000;
			damage = 1;
			m_speed = 10;
			m_collisionGroup = globals.GROUP_MELEE;
			CenterOrigin();
			
			this.y = globals.player.body.position.y;
			this.x = globals.player.body.position.x;
			CreateBody();
		}
		
		override protected function CreateBody():void {
			m_body 					= new Body( BodyType.DYNAMIC, new Vec2( x,y ) );
			
			m_body.shapes.add( new Polygon(Polygon.rect(0,0,m_asset.width,m_asset.height) ) );
			m_body.allowRotation 	= false;
			m_body.space			= globals.space;
			m_body.mass				= 5;
			m_body.shapes.at(0).filter.collisionGroup = m_collisionGroup;
			m_body.cbTypes.add( CB_MELEE );
			SetPosition( x, y );
			
			m_body.shapes.at(0).filter.collisionMask = ~globals.player.collisionGroup;
		}
		
		override public function Init():void {
			super.Init();
			//FLOOR LISTENER
			m_floorListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_FLOOR, 																
				CB_MELEE, 																
				HandleFloorCollision );
			
			//WALL LISTENER
			m_wallListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_WALL, 																
				CB_MELEE, 																
				HandleWallCollision );
			
			m_enemyListener = new InteractionListener( 
				CbEvent.ONGOING, 																			
				InteractionType.COLLISION, 																			
				globals.CB_ENEMY, 																
				CB_MELEE,													
				HandleEnemyCollision );
			
			globals.space.listeners.add( m_floorListener );
			globals.space.listeners.add( m_enemyListener );
			globals.space.listeners.add( m_wallListener );
			
			animation.gotoAndPlay("run");
		}
		
		override public function Update(elapsedTime:Number=NaN):void {
			if ( m_body ) {
				this.x = m_body.position.x + m_assetHalfWidth;
				this.y = m_body.position.y + m_body.bounds.height - m_assetHalfHeight;
				Move();
			}
		}
		
		protected function Move():void {
			if ( m_moveState == globals.READY ) {
				if ( m_direction.x > 0 && m_body.position.x + m_body.bounds.width >= m_patrolBounds.right ) {
					m_direction.x = -1;
					scaleX = m_direction.x;
				} 
				else if ( m_direction.x < 0 && m_body.position.x <= m_patrolBounds.left ) {
					m_direction.x = 1;
					scaleX = m_direction.x;
				}
				m_body.velocity.x = m_direction.x * m_speed * elapsedTime;
			}
		}
		
		/*=============================================================================
		EVENT HANDLING
		=============================================================================*/
		protected function HandleFloorCollision( collision:InteractionCallback ):void {
			var aabb:AABB;
			if ( collision.int1 != m_body ) {
				aabb = collision.int1[ "bounds" ];
				m_patrolBounds = new Rectangle( aabb.x, aabb.y, aabb.width, aabb.height );
			} else {
				aabb = collision.int2[ "bounds" ];
				m_patrolBounds = new Rectangle( aabb.x, aabb.y, aabb.width, aabb.height );
			}
			m_direction.x = 1;
			m_moveState = globals.READY;
		}
		
		protected function HandleEnemyCollision( collision:InteractionCallback ):void {
			var i:int;
			for ( ; i < m_enemies.length; ++i ) {
				if ( m_enemies[i].body == collision.int1.castBody ) {
					if ( m_hitTime == 0 || getTimer() - m_hitTime >= m_hitDelay ) {
						m_enemies[i][ "HandleHit" ]( damage );
						m_hitTime = getTimer();
						animation.gotoAndPlay("attack");
					}
				}
			}
		}
		
		protected function HandleWallCollision( collision:InteractionCallback ):void {
			if ( m_moveState == globals.NONE ) { return; }
			m_body.velocity.x = m_direction.x > 0 ? -m_speed : m_speed;
			scaleX = -m_direction.x;
		}
		
		override public function HandleHit( damage:int=1 ):void {
			
		}
		
		/*=============================================================================
		ANCILLARY
		=============================================================================*/
		/** @inheritDoc */
		override public function SetPosition(x:Number, y:Number):void {
			if ( m_body ) {
				m_body.position.x = x;
				m_body.position.y = y;
			}
		}
		
		public function set enemies( list:Vector.<g_entity> ):void { m_enemies = list; }
	}
}