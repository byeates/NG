package renderer
{
	import com.globals;
	
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	import game.g_dispatcher;
	import game.g_level;
	import game.g_scriptparser;
	import game.enemy.ge_enemymanager;
	import game.enemy.ge_enemyspawner;
	import game.misc.gm_item;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	/*=============================================================================
	WORLD
		- involved with loading and drawing all the necessary tiles for the level
	=============================================================================*/
	public class r_world extends Sprite
	{
		/*===============
		PRIVATE			
		===============*/
		/** layers are used for parallax, and the name is deceiving as they are all added to background */
		private var m_backgroundLayer	:r_layer;
		private var m_midgroundTileLayer:r_layer;
		private var m_midgroundLayer	:r_layer;
		private var m_foregroundLayer	:r_layer;
		private var m_layers			:Vector.<r_layer>;
		private var m_space				:Space;
		private var m_camera			:r_camera;
		
		//debugging only
		private var m_debug				:BitmapDebug;
		
		/** current loaded level */
		private var m_currentLevel		:Object;
		/** this gets called after the level is finished loading and setup */
		private var m_onLoadedCallback	:Function;
		
		/** test bitmap text field to demonstrate use */
		private var m_testTextField		:TextField;
		
		public function r_world( onLoadedCallback:Function ) {
			m_layers = new Vector.<r_layer>;
			m_onLoadedCallback = onLoadedCallback;
			addEventListener( Event.ADDED_TO_STAGE, OnAdded );
		}
		
		public function Destroy():void {
			ge_enemymanager.instance.Destroy();
			g_level.instance.Destroy();
		}
		
		protected function OnAdded( e:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, OnAdded );
			
			m_backgroundLayer 	= new r_layer( 0.5, this );
			m_midgroundTileLayer= new r_layer( 0.75, this );
			m_midgroundLayer 	= new r_layer( 0.75, this );
			m_foregroundLayer 	= new r_layer( 1, this );
			
			m_backgroundLayer.flatten();
			m_midgroundTileLayer.flatten();
			
			m_layers.push( m_backgroundLayer );
			m_layers.push( m_midgroundTileLayer );
			m_layers.push( m_midgroundLayer );
			m_layers.push( m_foregroundLayer );
			
			globals.background = m_backgroundLayer;
			globals.midgroundTiles = m_midgroundTileLayer;
			globals.midground = m_midgroundLayer;
			globals.foreground = m_foregroundLayer;
			
			LoadLevel();
		}
		
		protected function LoadLevel():void {
			//TODO: pull from shared object, determine what world the player is on
			/*r_loader.instance.GetFile( "TutorialLevel", ".rmf", function():void { 
				r_loader.instance.filePath = r_loader.instance.filePath + "scripts/";
				r_loader.instance.GetFile( "TutorialLevel", ".script", function():void { 
					g_scriptparser.instance.SetScript( r_loader.instance.GetFile( "TutorialLevel", ".script" ) );
					OnLevelLoaded( r_loader.instance.GetFile( "TutorialLevel", ".rmf" ) ); 
				});
			});*/
			r_loader.instance.GetFile( "TutorialLevel", ".rmf", OnLevelLoaded );
		}
		
		protected function OnLevelLoaded( levelData:Object ):void {
			//TODO: I think it will be easier to read the m_currentLevel if it's a class with tiles, baseLevel, collisions, and spawners properties
			m_currentLevel = {};
			m_currentLevel.tiles = [];
			m_currentLevel.baseLevel = levelData;
			r_tileloader.instance.loadAmount = levelData.tiles.length;	
			
			globals.echo( "loading level assets..." );
			
			var i:int;
			var loadedTiles:Array = [];
			for ( ; i < levelData.tiles.length; ++i ) {
				loadedTiles.push( levelData.tiles[ i ].tile );
				r_tileloader.instance.AddAssetToLoad( levelData.tiles[ i ].tile, OnTileLoaded );
			}
			if ( levelData.tiles.length == 0 ) {
				r_tileloader.instance.loadedCallback = OnTileLoaded;
			}
			r_tileloader.instance.LoadAll();
		}
		
		protected function OnTileLoaded( asset:Bitmap, isComplete:Boolean ):void {
			if ( asset != null ) {
				m_currentLevel.tiles.push( asset );
			}
			if ( isComplete ) { GenerateLevel(); }
		}
		
		/** Parse through all the tile objects, add them to the correct container, and apply the correct transformations */
		private function GenerateLevel():void {
			//create the world physics
			globals.echo( "assets finished loading..." );
			g_level.instance.Clear();
			CreateWorldPhysics();
			
			var i:int;
			var element:Object;
			for ( ; i < m_currentLevel.tiles.length; ++i ) {
				element = m_currentLevel.baseLevel.tiles[ i ];
				var tileContainer:r_tile = new r_tile();
				var tile:Image = new Image( Texture.fromBitmap( m_currentLevel.tiles[ i ] ) );
				tileContainer.x = element.position.x;
				tileContainer.y = element.position.y;
				tileContainer.addChild( tile );
				
				ApplyTileProperties( tileContainer, tile, element );
				tileContainer.Init();
				g_level.instance.AddToTiles( tileContainer );
				if ( element.layer == 2 ) {
					m_layers[ 3 ].addChild( tileContainer );
				}
				else {
					m_layers[ element.layer ].addChild( tileContainer );
				}
			}
			var classRef:*;
			for ( i=0; i < m_currentLevel.baseLevel.collisions.length; ++i ) {
				element = m_currentLevel.baseLevel.collisions[ i ];
				element.type = element.type == "default" ? "collidable" : element.type;
				classRef = getDefinitionByName( "renderer::r_"+element.type );
				var collision:r_collidable = new classRef( element.type );
				collision.x = element.position.x;
				collision.y = element.position.y;
				collision.width = element.box.width;
				collision.height = Math.max(element.box.height, 16);
				collision.Init();
				g_level.instance.AddToCollisions( collision );
			}
			for ( i=0; i < m_currentLevel.baseLevel.spawners.length; ++i ) {
				element = m_currentLevel.baseLevel.spawners[i];
				
				//check to see if this spawner is for the player
				if ( element.hasOwnProperty( "isPlayerSpawn" ) && element.isPlayerSpawn ) {
					g_level.instance.SetPlayerStart( element.position.x, element.position.y );
					continue;
				}
				
				classRef = getDefinitionByName( "game.enemy::ge_enemyspawner" );
				var spawner:ge_enemyspawner = new classRef( element.position.x, element.position.y );
				spawner.enemiesPerMinute = element.enemiesPerMinute;
				spawner.enemyTypes = element.enemyTypes;
				spawner.spawnDirection = element.spawnDirection;
				g_level.instance.AddToSpawners( spawner );
			}
			for ( i=0; i < m_currentLevel.baseLevel.items.length; ++i ) {
				element = m_currentLevel.baseLevel.items[i];
				
				classRef = getDefinitionByName( "game.misc::gm_item" );
				var item:gm_item = new classRef( element.position.x, element.position.y );
				item.type = element.type;
			}
			g_level.instance.levelHeight = m_currentLevel.baseLevel.levelHeight;
			g_level.instance.levelWidth = m_currentLevel.baseLevel.levelWidth;
			m_onLoadedCallback();
			globals.echo( "LEVEL READY!" );
		}
		
		/** Apply correct properties of the tile */
		public function ApplyTileProperties( container:Sprite, tile:Image, properties:Object ):void {
			var prevW:Number 	= container.width;
			var prevH:Number 	= container.height;
			var prevScale:Point = new Point( container.scaleX, container.scaleY );
			container.scaleX 	= properties.scale.x;
			container.scaleY 	= properties.scale.y;
			
			//rotate the tile only
			var matrix:Matrix = new Matrix();
			matrix.translate( -container.width/2, -container.height/2 );
			matrix.rotate( properties.rotation * Math.PI / 180 );
			matrix.translate( container.width/2, container.height/2 );
			tile.transformationMatrix = matrix;
		}
		
		/** One time call to start the world phyiscs */
		protected function CreateWorldPhysics():void {
			//AddTextField();
			//debugging only - replace with compiler tags later
			m_debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, 0, true);
			Starling.current.nativeOverlay.addChild( m_debug.display );
			
			m_space = new Space( new Vec2(0, globals.gravity ) );
			
			globals.space = m_space;
			m_camera = new r_camera( this );
		}
		
		/** Initialize all the layer drawing */
		public function Init():void {
			g_level.instance.Init();
			m_backgroundLayer.Draw();
			m_midgroundTileLayer.Draw();
			m_midgroundLayer.Draw();
			m_foregroundLayer.Draw();
			
			g_dispatcher.instance.AddToDispatch( OnTouch, null, "touch", TouchPhase.BEGAN );
			g_dispatcher.instance.AddToDispatch( Update );
		}
		
		protected function Update( elapsedTime:Number ):void {
			m_space.step(1/60);
			
			//debugging only
			DEBUG::enabled {
				m_debug.clear();
				m_debug.draw(m_space);
				m_debug.flush();
			}
			m_camera.Update();
		}
		
		protected function AddTextField():void {
			// This technically only needs to get called once ever
			// Doing the register in some global init file would probably be wise
			// Note the name, having the exact same name as a system font breaks flash
			//assets.RegisterBitmapFont( "consolass" );
			//m_testTextField		= new TextField(400, 100, "This is a test text field, remove me!", "Consolass", 20, 0xFFFFFF);
			//addChild(m_testTextField);
		}
		
		/*=============================================================================
		EVENT HANDLING
		=============================================================================*/
		/** Touch event handler */
		protected function OnTouch( touch:Touch ):void {}
		
		/*=============================================================================
		ANCILLARY
		=============================================================================*/
		/** Set the world x coordinate*/
		override public function set x(value:Number):void {
			super.x = value;
			m_debug.transform.tx = value;
			
		}
		
		/** Set the world y coordinate*/
		override public function set y(value:Number):void {
			super.y = value;
			m_debug.transform.ty = value;
		}
	}
}