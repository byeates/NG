package com
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import starling.text.BitmapFont;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/*========================================================================================
	ASSETS EMBED HERE
	========================================================================================*/
	public class assets
	{
		/*========================================================================================
		PLAYER
		========================================================================================*/
		[Embed(source="../../assets/player.png", 							//should be const
				mimeType = "application/octet-stream")] 					static public var player									:Class;
		
		/*========================================================================================
		ENEMIES
		========================================================================================*/
		[Embed(source="../../assets/enemy_fast.png",  						//should be const
				mimeType = "application/octet-stream")] 					static public var enemy_fast								:Class;
		
		[Embed(source="../../assets/enemy_flying.png",  					//should be const
				mimeType = "application/octet-stream")] 					static public var enemy_flying								:Class;
		
		/*========================================================================================
		TURRETS
		========================================================================================*/
		[Embed(source="../../assets/spritesheet_turret.png")]				static public var spritesheet_turret						:Class;
		[Embed(source="../../assets/data_turret.xml",  						//should be const
						mimeType="application/octet-stream")] 				static public var data_turret								:Class;
		//selected turret
		[Embed(source="../../assets/spritesheet_selected_turret.png")]		static public var spritesheet_selected_turret				:Class;
		[Embed(source="../../assets/data_selected_turret.xml",  			//should be const
						mimeType="application/octet-stream")] 				static public var data_selected_turret						:Class;
		
		[Embed(source="../../assets/turret_ranged.png",  					//should be const
				mimeType = "application/octet-stream")] 					static public var turret_ranged								:Class;
		
		[Embed(source="../../assets/spritesheet_ranged_projectile.png")]	static public var spritesheet_ranged_projectile				:Class;
		[Embed(source="../../assets/data_ranged_projectile.xml",  			//should be const
						mimeType="application/octet-stream")] 				static public var data_ranged_projectile					:Class;
		
		[Embed(source="../../assets/spritesheet_enemy_projectile.png")]		static public var spritesheet_enemy_projectile				:Class;
		[Embed(source="../../assets/data_enemy_projectile.xml",  			//should be const
						mimeType="application/octet-stream")] 				static public var data_enemy_projectile						:Class;
		
		[Embed(source="../../assets/spritesheet_turret_bomb.png")]			static public var spritesheet_turret_bomb					:Class;
		[Embed(source="../../assets/data_turret_bomb.xml",  				//should be const
						mimeType="application/octet-stream")] 				static public var data_turret_bomb							:Class;
		
		[Embed(source="../../assets/turret_melee.png",  					//should be const
				mimeType = "application/octet-stream")] 					static public var turret_melee								:Class;
		
		[Embed(source="../../assets/spritesheet_coin.png")]					static public var spritesheet_coin							:Class;
		[Embed(source="../../assets/data_coin.xml",  						//should be const
						mimeType="application/octet-stream")] 				static public var data_coin									:Class;
		
		/*========================================================================================
		MISC
		========================================================================================*/
		[Embed(source="../../assets/chatbubble_pointer.png")]				static public var chatbubble_pointer						:Class;
		[Embed(source="../../assets/ui/button_play.png")]					static public var button_play								:Class;
		
		//spawn particles
		[Embed(source="../../assets/particles/texture.png")] 				static private var particle									:Class;
		[Embed(source="../../assets/particles/particle.pex",  
			   mimeType="application/octet-stream")]						static private var particleConfig							:Class;
		
		
		
		/*========================================================================================
		FONTS
		========================================================================================*/
		[Embed(source="../../assets/consolas.fnt", 
			   mimeType="application/octet-stream")]						static private var consolas_config							:Class;												
		[Embed(source="../../assets/consolas.png")]							static private var consolas									:Class;
		
		//list of assets
		static private const assetsToLoad:Array = [ 
			"player.png", 
			"enemy_fast.png", 
			"enemy_flying.png", 
			"spritesheet_turret.png", 
			"turret_ranged.png",
			"spritesheet_ranged_projectile.png",
			"spritesheet_enemy_projectile.png",
			"spritesheet_turret_bomb.png",
			"spritesheet_coin.png",
			"melee_turret.png",
			"chatbubble_pointer.png",
			"ui/button_play.png",
			"particles/texture.png"];
		
		//dictionaries corresponding to the assetsToLoad
		static private const assetStorage:Array = [
			AddToReferences, 
			AddToReferences, 
			AddToReferences, 
			AddToAtlases, 
			AddToReferences, 
			AddToAtlases,
			AddToAtlases,
			AddToAtlases,
			AddToAtlases,
			AddToTextures,
			AddToReferences,
			AddToTextures, 
			AddToTextures,
			AddToTextures ];
		
		//tables storing loaded/created assets
		static private var m_textures			:Dictionary = new Dictionary();
		static private var m_atlases			:Dictionary = new Dictionary();
		static private var m_references			:Dictionary = new Dictionary();
		static private var m_configs			:Dictionary = new Dictionary();
		static private var m_bitmapFonts		:Dictionary = new Dictionary();
		
		/** Set to function to call when dynamic loading has finished */
		static private var m_onLoadCallback		:Function;
		/** Set to the number of loaders, currently there are 2, one for dragon bones and one for textures/atlases */
		static private var m_numLoaders			:int;
		
		/** Returns the sprite sheet with the parameter name
		 * @param name - name of the spritesheet to load
		 */
		static public function GetSpriteSheet( name:String ):TextureAtlas {
			if ( !m_atlases[ name ] ) {
				var xml:XML 			= XML( new assets[ "data_"+name ]() );
				var texture:Texture 	= GetTexture( "spritesheet_"+name );
				assets[ name ] 			= new TextureAtlas( texture, xml );
				m_atlases[ name ] 		= assets[ name ];
			}
			return m_atlases[ name ];
		}
		
		/** Returns the texture with the parameter name
		 * @param name - name of the texture to load
		 */
		static public function GetTexture( name:String ):Texture {
			if ( !m_textures[ name ] ) {
				var bitmap:Bitmap 	= new assets[ name ]();
				m_textures[ name ] 	= Texture.fromBitmap( bitmap, false, true );
			}
			return m_textures[ name ];
		}
		
		/** Returns data instance (byteArray) with the parameter name
		 * @param name - name of the dragon bones asset to load
		 */
		static public function GetNewInstance( name:String ):* {
			if ( !m_references[ name ] ) {
				m_references[ name ] = new assets[ name ];
			}
			return m_references[ name ];
		}
		
		/** Returns the config with the parameter name
		 * @param name - name of the font config load
		 */
		static public function GetConfig( name:String ):XML {
			if ( !m_configs[ name ] ) {
				var config:XML = XML( new assets[ name + "Config" ] );
				m_configs[ name ] = config;
			}
			return m_configs[ name ];
		}
		
		/** Returns the bitmap texture for the font with the parameter name
		 * @param name - name of the font config load
		 */
		static public function RegisterBitmapFont( name:String ):BitmapFont {
			if ( !m_bitmapFonts[ name ] ) {
				var fontConfig:XML 	= XML( new assets[ name+"_config" ]() );
				var fontTex:Texture	= GetTexture( name );
				m_bitmapFonts[ name ]	= new BitmapFont( fontTex, fontConfig );
			}
			return m_bitmapFonts[ name ];
		}
		
		/** Dynamically loads all the assets from the assets list with their respective loaders 
		 * @param onCompleteCallback - function to call once loading has finished
		 * */
		static public function LoadAll( onCompleteCallback:Function ):void {
			m_numLoaders = 2;
			var i:int;
			for ( ; i < assetsToLoad.length; ++i ) {
				//it's a dragon bones asset
				if ( assetStorage[i] == AddToReferences ) {
					dragonbonesloader.instance.AddAssetToLoad( assetsToLoad[i], assetStorage[i] );
				}
				else {
					textureloader.instance.AddAssetToLoad( assetsToLoad[i], assetStorage[i] );
				}
			}
			m_onLoadCallback = onCompleteCallback;
			textureloader.instance.loadCompleteCallback = LoaderFinished;
			dragonbonesloader.instance.loadCompleteCallback = LoaderFinished;
			
			dragonbonesloader.instance.LoadAll();
			textureloader.instance.LoadAll();
		}
		
		/** Internal use to add dynamically loaded atlases to the respective dictionary */
		static private function AddToAtlases( c:*, name:String ):void 		{ 
			name = name.replace(".png", ""); 
			name = name.replace("spritesheet_", "");
			
			var xml:XML 			= XML( new assets[ "data_"+name ]() );
			var texture:Texture 	= Texture.fromBitmap(c,false,true);
			assets[ name ] 			= new TextureAtlas( texture, xml );
			m_atlases[ name ] 		= assets[ name ];
		}
		
		/** Internal use to add dynamically loaded textures to the respective dictionary */
		static private function AddToTextures( c:*, name:String ):void 		{ 
			name = name.replace(".png", ""); 
			m_textures[ name ] = c; 
		}
		
		/** Internal use to add dynamically loaded data to the respective dictionary */
		static private function AddToReferences( c:*, name:String ):void 	{ 
			name = name.replace(".png", ""); 
			m_references[ name ] 	= c; 
		}
		
		/** Internal use to check when all loaders have finished */
		static private function LoaderFinished():void {
			--m_numLoaders;
			if ( m_numLoaders <= 0 ) {
				m_onLoadCallback();
			}
		}
	}
}