package game.enemy
{
	import com.globals;
	import com.math;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import dragonBones.events.AnimationEvent;
	
	import game.g_entity;
	import game.g_level;
	import game.g_projectile;
	import game.turret.gt_turretbomb;
	import game.turret.gt_turretmanager;
	import game.turret.gt_turretranged;
	
	import starling.display.DisplayObjectContainer;
	
	/** ge_enemyflying */
	public class ge_enemyflying extends ge_enemy {
		/*===============
		PRIVATE
		===============*/
		/** total elapsed time, used for determing when to detect new targets */
		private var m_runTime					:int;
		private var m_floatIndex				:Number;
		private const FLOAT_HEIGHT				:Number = 0.5;
		
		/*===============
		PROTECTED
		===============*/
		protected var m_activeTarget			:g_entity;
		protected var m_previousTarget			:g_entity;
		protected var m_moveAngle				:Number;
		protected var m_animState				:String;
		protected var m_distToTarget			:Number;
		protected var m_fireTime				:int;
		protected var m_projectiles				:Vector.<g_projectile>;
		protected var m_disabledProjectiles		:Vector.<g_projectile>;
		
		static protected var FLOAT_OFFSETS		:Dictionary;
		
		/*===============
		PUBLIC
		===============*/
		
		/*===============
		CONSTANTS
		===============*/
		protected const SPEED					:int 	= 3;
		protected const ACCEL					:Number = 1.5;
		protected const MAX_SPEED				:int 	= 150;
		protected const MIN_SPEED				:int 	= 3;
		protected const NEW_TARGET_DELAY		:uint 	= 1500;
		protected const FIRE_RANGE				:int 	= 250;
		protected const FIRE_DELAY				:int	= 3000;
		
		//edge room is the area the padding from the edges of level that the flying enemies cannot go past
		protected const EDGE_ROOM				:uint 	= 100;
		
		protected const IDLE					:String = "idle";
		protected const FLY						:String = "fly";
		protected const ATTACK					:String = "attack";
		
		public function ge_enemyflying(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false)
		{
			super(parent, asset, isSpriteSheet, defaultFrames, isArmature);
			if ( !FLOAT_OFFSETS ) { GenerateFloatOffsets(); }
			m_floatIndex 			= m_distToTarget = 0;
			m_projectiles 			= new Vector.<g_projectile>;
			m_disabledProjectiles 	= new Vector.<g_projectile>;
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			m_isDestroyed = false;
			isLoaded = true;
			addChild( m_asset );
			Init();
			m_hitDamage = 1;
			
			if ( m_animState != FLY ) {
				m_animState = FLY;
				animation.gotoAndPlay( FLY );
			}
		}
		
		/** @inheritDoc */
		override public function Init():void {
			super.Init();
			m_health = 3;
		}
		
		/**
		 * Searches for the cloests target, with the bottom line being the player
		 */
		protected function AssignTarget():void {
			var activeTurrets:Vector.<g_entity> = gt_turretmanager.instance.turrets;
			var dist:Number, dx:Number;
			var i:int;
			var pos:Vector2D = new Vector2D( x, y );
			for ( ; i < activeTurrets.length; ++i ) {
				dx = Point.distance( pos.toPoint(), new Point( activeTurrets[i].x, activeTurrets[i].y ) );
				if ( dx < dist || isNaN( dist ) ) {
					dist = dx;
					m_activeTarget = activeTurrets[i];
				}
			}
			if ( activeTurrets.length == 0 || m_activeTarget is gt_turretbomb ) {
				m_activeTarget = globals.player;
			} else {
				dx = Point.distance( pos.toPoint(), new Point( globals.player.asset.x, globals.player.asset.y ) );
				if ( dx < dist || isNaN( dist ) ) {
					m_activeTarget = globals.player;
				}
			}
			if ( !m_activeTarget ) { return; }
			m_moveAngle = Math.atan2( m_activeTarget.y - y, m_activeTarget.x - x );
		}
		
		override public function Update(elapsedTime:Number=NaN):void {
			super.Update(elapsedTime);
			m_runTime += elapsedTime;
			m_fireTime += elapsedTime;
			if ( m_runTime == 0 || m_runTime >= NEW_TARGET_DELAY ) {
				AssignTarget();
				m_runTime = 1;
			}
			if ( isLoaded ) {
				Move();
			}
		}
		
		public function Move():void {
			m_floatIndex = m_floatIndex >= math.pi_2pi ? 0.1 : m_floatIndex + 0.1;
			y += FLOAT_OFFSETS[ m_floatIndex ];
			
			if ( m_activeTarget ) {
				
				m_distToTarget = Point.distance( new Point( x, y ), new Point( m_activeTarget.x, m_activeTarget.y ) );
				if ( m_distToTarget <= FIRE_RANGE ) {
					Fire();
					return;
				}
				
				if ( m_previousTarget != m_activeTarget ) {
					Decelerate();
				}
				else {
					Accelerate();
				}
				
				//bounds check to stop velocity
				if ( (x < EDGE_ROOM && m_velocity.x < 0) || (x > g_level.instance.levelWidth - EDGE_ROOM && m_velocity.x > 0 ) ) { m_velocity.x = 0; }
				if ( (y < EDGE_ROOM && m_velocity.y < 0) || (y > g_level.instance.levelHeight - EDGE_ROOM && m_velocity.y > 0 ) ) { m_velocity.y = 0; }
				
				x += m_velocity.x * (elapsedTime*.001);
				y += m_velocity.y * (elapsedTime*.001);
				
				//direction check
				scaleX = m_velocity.x >= 0 ? 1 : -1;
			} 
			else {
				m_velocity.x = m_velocity.y = 0;
			}
		}
		
		public function Fire():void {
			if ( m_fireTime == 0 || m_fireTime >= FIRE_DELAY ) {
				m_fireTime = 0;
				
				var projectile:g_projectile
				if ( m_disabledProjectiles.length > 0 ) {
					projectile = m_disabledProjectiles.shift();
					m_projectiles.push( projectile );
				} 
				else {
					projectile = new g_projectile( m_parent, "enemy_projectile", true, 36 );
					projectile.onCollisionCallback = DisableProjectile;
				}
				projectile.x = x;
				projectile.y = y;
				projectile.SetTarget( m_activeTarget, false );
				projectile.enabled = true;
				
				m_armature.animation.gotoAndPlay( ATTACK );
				m_armature.addEventListener(AnimationEvent.COMPLETE, function play_idle():void {
					m_armature.removeEventListener( AnimationEvent.COMPLETE, play_idle );
					m_armature.animation.gotoAndPlay( FLY );
				});
			}
		}
		
		private function DisableProjectile( projectile:g_projectile ):void {
			m_disabledProjectiles.push( projectile );
			m_projectiles.splice( m_projectiles.indexOf( projectile ), 1 )
			projectile.enabled = false;
		}
		
		public function Decelerate():void {
			if ( Math.abs(m_velocity.magnitude) > MIN_SPEED ) {
				m_velocity.x -= 0.1;
				m_velocity.y -= 0.1;
			} else {
				m_previousTarget = m_activeTarget;
			}
		}
		
		public function Accelerate():void {
			if ( Math.abs(m_velocity.x) < MAX_SPEED ) {
				m_velocity.x += SPEED * Math.cos(m_moveAngle);
			}
			else {
				m_velocity.x = MAX_SPEED * Math.cos(m_moveAngle);
			}
			if ( Math.abs(m_velocity.y) < MAX_SPEED ) {
				m_velocity.y += SPEED * Math.sin(m_moveAngle);
			}
			else {
				m_velocity.y = MAX_SPEED * Math.sin(m_moveAngle);
			}
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		
		/** Generates the table of positional values to save calculations during run time */
		private function GenerateFloatOffsets():void {
			FLOAT_OFFSETS = new Dictionary();
			var float:Number = 0;
			var inc:Number = 0.1;
			while( float <= math.pi_2pi ) {
				float += inc;
				FLOAT_OFFSETS[ float ] = FLOAT_HEIGHT * Math.cos( float );
			}
		}
		
	}
}