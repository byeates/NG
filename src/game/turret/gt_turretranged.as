package game.turret
{
	import com.math;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import dragonBones.Bone;
	import dragonBones.events.AnimationEvent;
	
	import game.g_entity;
	import game.enemy.ge_enemymanager;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	import game.g_projectile;
	
	public class gt_turretranged extends gt_turret
	{
		/*===============
		PROTECTED			
		===============*/
		/** only 1 shot at a time initially */
		protected var m_shots				:int;
		
		/** area of detection before shooting */
		protected var m_shotRadius			:int;
		
		/** broad phase list of enemies */
		protected var m_enemies				:Vector.<g_entity>;
		
		/** current state for firing projectiles */
		protected var m_fireState			:String;
		
		/** current target for projectile */
		protected var m_activeTarget		:g_entity;
		
		/** list of projectiles created */
		protected var m_projectiles			:Vector.<g_projectile>;
		protected var m_disabledProjectiles :Vector.<g_projectile>;
		
		protected var m_fireTime			:Number;
		
		/*===============
		PRIVATE			
		===============*/
		private var m_debugRadiusTexture	:Texture;
		private var m_skull					:Bone;
		private var m_floatIndex			:Number;
		private var m_rotating 				:Boolean;
		
		/*===============
		CONSTANTS			
		===============*/
		private const FIRED					:String = "fired";
		private const READY					:String = "ready";
		private const FLOAT_HEIGHT			:Number = 0.5;
		private const FIRE_DELAY			:int = 2000;
		
		static protected var FLOAT_OFFSETS	:Dictionary;
		
		public function gt_turretranged(parent:DisplayObjectContainer, asset:String, x:Number=0, y:Number=0) {
			super(parent, asset, false, 0, true);
			this.x = x;
			this.y = y;
		}
		
		/** @inheritDoc */
		override public function SetDefaults():void {
			if ( !FLOAT_OFFSETS ) { GenerateFloatOffsets(); }
			
			m_fireTime				= FIRE_DELAY;
			m_floatIndex			= 0;
			m_shots 				= 1;
			m_shotRadius 			= 150;
			m_fireState 			= READY;
			m_projectiles			= new Vector.<g_projectile>;
			m_disabledProjectiles 	= new Vector.<g_projectile>;
			
			CenterOrigin();
			super.SetDefaults();
			
			m_armature.animation.gotoAndPlay( "idle" );
			m_skull = m_armature.getBone("skull");
			
			DEBUG::enabled {
				DebugShotRadius();
			}
		}
		
		override public function Update( elapsedTime:Number=NaN ):void {
			var i:int;
			var area:Number = m_shotRadius * m_shotRadius;
			var enemy:Rectangle;
			var dx:Number, dy:Number;
			var targetSelected:Boolean;
			var bound:Rectangle = bounds;
			m_fireTime += elapsedTime;
			
			for ( ; i < m_enemies.length; ++i ) {
				enemy = m_enemies[ i ].bounds;
				if ( !enemy ) { continue; }
				
				dx = (enemy.x + enemy.width * .5) - (bound.x + bound.width * .5);
				dy = (enemy.y + enemy.height * .5) - (bound.y + bound.height * .5);
				//in range
				if ( dx * dx + dy * dy <= m_shotRadius * m_shotRadius ) {
					m_activeTarget = m_enemies[ i ];
					targetSelected = true;
					if ( m_fireState == READY && m_fireTime >= FIRE_DELAY ) {
						FireProjectile();
					}
				}
			}
			if ( m_activeTarget ) {
				var rotation:Number = Math.atan2( y - m_activeTarget.y, x - m_activeTarget.x );
				m_skull.node.rotation = rotation - math.pi;
				
				if ( !m_rotating ) {
					m_armature.animation.gotoAndPlay( "idle" );
					m_rotating = true;
					
					this.m_armature.addEventListener(AnimationEvent.COMPLETE, function run():void { 
						m_armature.removeEventListener(AnimationEvent.COMPLETE, run);
						animation.gotoAndPlay("idle");
						m_rotating = false;
					});
				}
			}
			//if we did not find a target in range, set the active target to null
			if ( !targetSelected ) {
				m_activeTarget = null;
				m_skull.node.rotation = 0;
			}
			m_floatIndex = m_floatIndex >= math.pi_2pi ? 0.1 : m_floatIndex + 0.1;
			this.y += FLOAT_OFFSETS[ m_floatIndex ];
		}
		
		private function FireProjectile():void {
			var projectile:g_projectile
			if ( m_disabledProjectiles.length > 0 ) {
				projectile = m_disabledProjectiles.shift();
				m_projectiles.push( projectile );
			} 
			else {
				projectile = new g_projectile( m_parent, "ranged_projectile", true, 36 );
				projectile.onCollisionCallback = DisableProjectile;
			}
			projectile.x = x;
			projectile.y = y;
			projectile.SetTarget( m_activeTarget );
			projectile.enabled = true;
			m_fireState = FIRED;
			m_armature.animation.gotoAndPlay( "shoot" );
			m_fireTime = 0;
		}
		
		private function DisableProjectile( projectile:g_projectile ):void {
			m_disabledProjectiles.push( projectile );
			m_projectiles.splice( m_projectiles.indexOf( projectile ), 1 )
			projectile.enabled = false;
			m_fireState = m_disabledProjectiles.length == m_shots ? READY : FIRED;
		}
		
		/** Shows the area for targetting, only visible when debug compiler constant is set to true */
		private function DebugShotRadius():void {
			var debugRadius:Sprite = new Sprite();
			debugRadius.graphics.lineStyle( 2, 0x00FF00 );
			debugRadius.graphics.beginFill( 0x00FF00, 0.3 );
			debugRadius.graphics.drawCircle(0,0,m_shotRadius);
			
			var bmd:BitmapData = new BitmapData( debugRadius.width*2, debugRadius.height*2, true, 0 );
			var matrix:Matrix = new Matrix();
			//set drawing origin to top left instead of center
			matrix.translate( debugRadius.width * .5, debugRadius.height * .5 );
			bmd.draw( debugRadius, matrix );
			//then move the matrix back
			
			m_debugRadiusTexture = Texture.fromBitmapData( bmd, false, false );
			var image:Image = new Image( m_debugRadiusTexture );
			image.x -= matrix.tx;
			image.y -= matrix.ty;
			addChild( image );
		}
		
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
		
		override public function HandleHit( damage:int=1 ):void {
			m_health -= damage;
			trace( "RANGED TURRET HIT!: " + m_health );
			if ( m_health <= 0 ) {
				gt_turretmanager.instance.RemoveTurret( this );
				Death();
			}
		}
		
		public function Repair():void {
			m_health = m_health < START_HEALTH ? ++m_health : m_health;
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		public function set enemies( list:Vector.<g_entity> ):void { m_enemies = list; }
	}
}