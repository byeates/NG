package game.enemy
{
	import com.globals;
	
	import flash.utils.getTimer;
	
	import dragonBones.events.AnimationEvent;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	
	import starling.display.DisplayObjectContainer;
	
	public class ge_enemyfast extends ge_enemy
	{
		/*===============
		PROTECTED
		===============*/
		/** time between hits */
		protected var m_hitTime:uint;
		
		/*===============
		CONSTANTS
		===============*/
		protected const CB_FASTENEMY				:CbType = new CbType();
		static protected const HIT_DELAY			:int = 2000;
		
		//we set the width and height of the collision boxes more custom for the fast enemies.
		static protected const SHAPE_HEIGHT			:int = 72;
		static protected const SHAPE_WIDTH			:int = 72;
		static protected const ENEMY_TYPE			:String = "fast";
		
		public function ge_enemyfast(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false) {
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			m_type = ENEMY_TYPE;
			m_collisionGroup = globals.GROUP_ENEMY_FAST;
			if ( !m_body ) {
				CreateBody();
			}
			super.SetDefaults();
		}
		
		/** Create a collision body for the enemy */
		override protected function CreateBody():void {
			m_body 					= new Body( BodyType.DYNAMIC );
			
			m_body.shapes.add( new Polygon( Polygon.rect(x,y,SHAPE_WIDTH,SHAPE_HEIGHT ) ) );
			m_body.allowRotation 	= false;
			m_body.space			= globals.space;
			m_body.mass				= MASS;
			m_body.shapes.at(0).filter.collisionGroup = m_collisionGroup;
			m_body.cbTypes.add( globals.CB_ENEMY );
			
			m_moveState = globals.READY;
			
			AddBodyListeners();
		}
		
		protected function AddBodyListeners():void {
			//FLOOR LISTENER
			m_floorListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_FLOOR, 																
				CB_FASTENEMY, 																
				HandleFloorCollision );
			
			//WALL LISTENER
			m_wallListener = new InteractionListener( 
				CbEvent.BEGIN, 																			
				InteractionType.COLLISION, 																			
				globals.CB_WALL, 																
				CB_FASTENEMY, 																
				HandleWallCollision );
			
			//player collision
			m_playerListener = new InteractionListener( 
				CbEvent.ONGOING, 																			
				InteractionType.COLLISION, 																			
				globals.CB_PLAYER, 																
				CB_FASTENEMY, 																
				HandlePlayerCollision );
			
			//player end collision
			m_playerEndListener = new InteractionListener( 
				CbEvent.END, 																			
				InteractionType.COLLISION, 																			
				globals.CB_PLAYER, 																
				CB_FASTENEMY, 																
				HandlePlayerEndCollision );
			
			//filter collisions with other fast enemies
			m_body.shapes.at(0).filter.collisionMask = ~m_collisionGroup;
			
			m_body.cbTypes.add( CB_FASTENEMY );	
			globals.space.listeners.add( m_floorListener );
			globals.space.listeners.add( m_wallListener );
		}
		
		override public function Init():void {
			super.Init();
			
			m_speed = 25;
			m_health = 3;		
			m_moveState = globals.READY;
			
			//ONLY ADD THE PLAYER LISTENERS WHEN Init IS CALLED!
			globals.space.listeners.add( m_playerListener );
			globals.space.listeners.add( m_playerEndListener );
		}
		
		override public function Destroy():void {
			//ONLY REMOVE THE PLAYER LISTENERS WHEN Destroy IS CALLED!
			globals.space.listeners.remove( m_playerListener );
			globals.space.listeners.remove( m_playerEndListener );
			super.Destroy();
		}
		
		override public function Remove():void {
			globals.space.listeners.remove( m_playerListener );
			globals.space.listeners.remove( m_playerEndListener );
			super.Remove();
		}
		
		override public function Update(elapsedTime:Number=NaN):void {
			super.Update(elapsedTime);
			if (m_body) {
				if ( m_moveState == globals.READY ) {
					x = m_direction.x < 0 ? m_body.position.x + SHAPE_WIDTH *.25: m_body.position.x + m_body.bounds.width - SHAPE_WIDTH*.25;
					y = m_body.position.y + m_body.bounds.height - SHAPE_HEIGHT*.25;
					Move();
				}
			}
		}
		
		public function Move():void {
			if ( m_moveState == globals.READY ) { 
				m_body.velocity.x = m_direction.x * m_speed * elapsedTime; 
			}
		}
		
		/*=============================================================================
		EVENT HANDLING
		=============================================================================*/
		protected function HandleFloorCollision( collision:InteractionCallback ):void {
			if ( m_moveState == globals.NONE ) { return; }
			m_moveState = globals.READY;
			animation.gotoAndPlay( "run" );
		}
		
		protected function HandlePlayerCollision( collision:InteractionCallback ):void {
			m_speed = 0;
			m_body.velocity.x = 0;
			
			if ( m_moveState == globals.NONE || m_hitTime > 0 && getTimer() - m_hitTime < HIT_DELAY ) { return; }
			m_moveState = globals.COLLIDED;
			animation.gotoAndPlay( "hit" );
			m_hitTime = getTimer();
			
			this.m_armature.addEventListener(AnimationEvent.COMPLETE, function run():void { 
				m_armature.removeEventListener(AnimationEvent.COMPLETE, run);
				animation.gotoAndPlay("idle");
			});
		}
		
		protected function HandlePlayerEndCollision( collision:InteractionCallback ):void {
			if ( m_moveState == globals.NONE ) { return; }
			m_moveState = globals.READY;
			m_speed = 25;
			animation.gotoAndPlay( "run" );
		}
		
		protected function HandleWallCollision( collision:InteractionCallback ):void {
			if ( m_moveState == globals.NONE ) { return; }
			m_body.velocity.x = m_direction.x > 0 ? -m_speed : m_speed;
			scaleX = -m_direction.x;
		}
	}
}