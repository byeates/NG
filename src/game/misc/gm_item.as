package game.misc
{
	import com.globals;
	
	import game.g_entity;
	
	import starling.display.DisplayObjectContainer;
	
	/** gm_item, for right now this is really just the turret pickups */
	public class gm_item extends g_entity {
		/*===============
		PRIVATE
		===============*/
		
		/*===============
		PROTECTED
		===============*/
		
		/*===============
		PUBLIC
		===============*/
		/** function to be called once a collision has occured with the item object */
		public var onPickup:Function;
		public var type:String;
		
		/*===============
		CONSTANTS
		===============*/
		
		public function gm_item(parent:DisplayObjectContainer, asset:String, isSpriteSheet:Boolean=false, defaultFrames:int=120, isArmature:Boolean=false) {
			super(parent, asset, false, 0, true);
		}
		
		override public function Init():void {
			super.Init();
			
		}
		
		override public function Update(elapsedTime:Number=NaN):void {
			if ( this.bounds.intersects( globals.player.bounds ) ) {
				Pickup();
				Destroy();
			}
		}
		
		public function Pickup():void {
			if ( onPickup != null ) { onPickup; }
		}
		
		/*========================================================================================
		ANCILLARY
		========================================================================================*/
		
	}
}