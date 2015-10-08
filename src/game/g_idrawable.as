package game
{
	/*========================================================================================
	DRAWABLES WILL CONTAIN PROPERTIES
		- reference g_abstractentity for an implementation
	========================================================================================*/
	public interface g_idrawable {
		
		function Init():void;
		
		/** Add asset to instance */
		function Draw():void;
		
		/** Remove instance from parent */
		function Destroy():void;
		
	}
}