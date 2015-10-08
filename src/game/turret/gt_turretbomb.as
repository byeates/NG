package game.turret
{
	import com.globals;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import game.g_entity;
	
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class gt_turretbomb extends gt_turret
	{
		/*===============
		PRIVATE
		===============*/
		private var m_debugRadiusTexture	:Texture;
		
		/*===============
		PROTECTED
		===============*/
		/** current state of the turret */
		protected var m_state:String;
		
		protected var m_explosionRadius:int;
		
		/** total time elapsed */
		protected var m_totalElapsed:int;
		
		/** broad phase list of enemies */
		protected var m_enemies:Vector.<g_entity>;
		protected var m_removals:Vector.<g_entity>;
		
		/*===============
		PUBLIC
		===============*/
		/** amount of damage the bomb turret will do, default is 3 */
		static public var damage:int;
		
		/*===============
		CONSTANTS
		===============*/
		// this is subject to change when the shop is added
		static protected const DETONATION_TIME			:int = 3;
		static protected const ARMED					:String = "armed";
		static protected const DETONATED				:String = "detonated";
		
		public function gt_turretbomb(parent:DisplayObjectContainer, asset:String, x:Number=0, y:Number=0)
		{
			super(parent, asset, true, 43);
			this.x = x - globals.player.halfWidth;
			this.y = y + globals.player.halfHeight;
		}
		
		override public function SetDefaults():void {
			super.SetDefaults();
			damage = 3;
			m_explosionRadius = 100;
			m_removals = new Vector.<g_entity>;
			
			DEBUG::enabled {
				DebugExplosionRadius();
			}
		}
		
		override public function Destroy():void {
			asset.remove();
			super.Destroy();
			m_state = globals.NONE;
		}
		
		override public function Update(elapsedTime:Number=NaN):void {
			super.Update(elapsedTime);
			m_totalElapsed += elapsedTime;
			if ( m_state == ARMED && m_totalElapsed / 1000 >= DETONATION_TIME ) {
				m_totalElapsed = 0;
				asset.gotoAndPlay(23,43,Destroy);
				m_state = DETONATED;
			}
			
			if ( m_state == DETONATED ) {
				CheckCollisions();
			}
		}
		
		protected function CheckCollisions():void {
			var i:int;
			var bound:Rectangle = this.bounds;
			for ( ; i < m_enemies.length; ++i ) {
				if ( Point.distance( new Point( bound.x, bound.y ), new Point( m_enemies[i].x, m_enemies[i].y ) ) < m_explosionRadius ) {
					m_enemies[i][ "HandleBombCollision" ]();
					m_removals.push( m_enemies[i] );
					trace( "HIT ENEMY!" );
				}
			}
			ClearRemovals();
		}
		
		protected function ClearRemovals():void {
			var i:int;
			for ( ; i < m_removals.length; ++i ) {
				m_enemies.splice( m_enemies.indexOf( m_removals[i] ), 1 );
			}
			m_removals.length = 0;
		}
		
		override public function Draw():void {
			super.Draw();
			asset.gotoAndPlay(1, 22);
			m_state = ARMED;
		}
		
		/** Shows the area for targetting, only visible when debug compiler constant is set to true */
		private function DebugExplosionRadius():void {
			var debugRadius:Sprite = new Sprite();
			debugRadius.graphics.lineStyle( 2, 0x00FF00 );
			debugRadius.graphics.beginFill( 0x00FF00, 0.3 );
			debugRadius.graphics.drawCircle(0,0,m_explosionRadius);
			
			var bmd:BitmapData = new BitmapData( debugRadius.width*2, debugRadius.height*2, true, 0 );
			var matrix:Matrix = new Matrix();
			//set drawing origin to top left instead of center
			matrix.translate( debugRadius.width * .5, debugRadius.height * .5 );
			bmd.draw( debugRadius, matrix );
			//then move the matrix back
			
			m_debugRadiusTexture = Texture.fromBitmapData( bmd, false, false );
			var image:Image = new Image( m_debugRadiusTexture );
			image.x -= matrix.tx/2;
			image.y -= matrix.ty/2;
			addChild( image );
		}
		
		public function set enemies( list:Vector.<g_entity> ):void { m_enemies = list; }
	}
}