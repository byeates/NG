package com
{
	import flash.display.BitmapData;
	
	import game.g_entity;
	import game.enemy.ge_enemyfast;
	import game.enemy.ge_enemyflying;
	import game.turret.gt_turretbomb;
	import game.turret.gt_turretmelee;
	import game.turret.gt_turretranged;
	
	import nape.callbacks.CbType;
	import nape.space.Space;
	
	import renderer.r_collidable;
	import renderer.r_floor;
	import renderer.r_wall;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.textures.Texture;

	public class globals
	{
		/*===============
		PRIVATE
		===============*/
		static private var m_stageWidth				:int;
		static private var m_stageHeight			:int;
		static private var m_instance				:globals;
		static private var m_fade					:Image;
		static private var m_references				:Vector.<Class>;
		
		/*===============
		PUBLIC
		===============*/
		static public var stageHalfWidth			:Number;
		static public var stageHalfHeight			:Number;
		//layers
		static public var background				:Sprite;
		static public var midground					:Sprite;
		static public var midgroundTiles			:Sprite;
		static public var foreground				:Sprite;
		static public var overlay					:Sprite;
		//active player reference
		static public var player					:g_entity;
		static public var tilesize					:int = 64;
		static public var space						:Space;
		static public var gravity					:int = 2000;
		
		/*===============
		CONSTANTS
		===============*/
		static public const MENU					:String = "menu";
		static public const GAME					:String = "game";
		static public const RESET					:String = "reset";
		static public const GAME_OVER				:String = "over";
		static public const GAME_RUNNING			:String = "running";
		static public const READY					:String = "ready";
		static public const DESTROYED				:String = "destroyed";
		static public const LOADING					:String = "loading";
		static public const NONE					:String	= "none";
		static public const OPEN					:String = "open";
		static public const CLOSED					:String = "closed";
		static public const COLLIDED				:String = "collided";
		
		//collision cb types for bodies
		static public const CB_PLAYER				:CbType = new CbType();
		static public const CB_ENEMY				:CbType = new CbType();
		static public const CB_ENTITY				:CbType = new CbType();
		static public const CB_WALL					:CbType	= new CbType();
		static public const CB_FLOOR				:CbType = new CbType();		
		static public const CB_COLLIDABLE			:CbType = new CbType();
		
		//collision groups, set to powers of 2 required by nape
		static public const GROUP_COLLISION			:int = 2;
		static public const GROUP_PLAYER			:int = 4;
		static public const GROUP_MELEE				:int = 8;
		static public const GROUP_ENEMY_FAST		:int = 16;
		static public const GROUP_COIN				:int = 32;
		
		public function globals():void {
			if ( m_instance ) { echo( "!!Warning!! --> There can only be one globals instance. It's created from Retention." ); return; }
			m_instance = this;
			
			//References
			m_references = new <Class>[ r_wall, 
										r_floor, 
										r_collidable,
										gt_turretranged,
										gt_turretmelee,
										gt_turretbomb,
										ge_enemyflying,
										ge_enemyfast];
		}
		
		/** Creates the sprites used for layering
		 * creates: background, midground, foreground, and overlay */
		static public function CreateOverlay( stage:Stage ):void {
			overlay 	= new Sprite(); overlay.name 	= "overlay";
			stage.addChild( overlay );
		}
		
		/** Create the fade texture */
		static private function CreateFade():void {
			var bmd:BitmapData = new BitmapData( stageWidth, stageHeight );
			bmd.fillRect( bmd.rect, 0xFF000000 );
			
			var t:Texture = Texture.fromBitmapData( bmd );
			m_fade = new Image( t );
			//turn off visability and prep for fading
			m_fade.visible = false;
			m_fade.alpha = 0;
			overlay.addChild( m_fade );
		}
		
		/** Debugging, trace statements with class information */
		static public function echo( ...args ):void {
			var val:String = args.join();
			var stack:Error = new Error();
			var log:String = stack.getStackTrace().split( "\n" )[2];
			var c:String = log.replace(/.*\\([a-zA-z0-9_]+).as.*/g, "$1");
			trace( c+" --> " + val ); 
		}
		
		static public function FadeOut( time:int=3 ):void {
			m_fade.alpha = 0;
			m_fade.visible = true;
			var tween:Tween = new Tween( m_fade, time );
			tween.animate( "alpha", 1 );
			Starling.juggler.add( tween );
		}
		
		static public function FadeIn( time:int=3 ):void {
			m_fade.alpha = 1;
			m_fade.visible = true;
			Starling.juggler.tween( m_fade, time, {
				alpha:0,
				onComplete: function():void { m_fade.visible = false; }
			});
		}
		
		/*=============================================================================
		Accessors and Mutators
		=============================================================================*/
		static public function set stageWidth( val:int ):void { m_stageWidth = val; stageHalfWidth = val * 0.5; }
		static public function set stageHeight( val:int ):void { m_stageHeight = val; stageHalfHeight = val * 0.5; }
		
		static public function get stageWidth():int { return m_stageWidth; }
		static public function get stageHeight():int { return m_stageHeight; }
	}
}