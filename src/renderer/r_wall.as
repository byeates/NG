package renderer
{
	import com.globals;
	
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;

	/*========================================================================================
	WALL COLLISION CLASS
	========================================================================================*/
	public class r_wall extends r_collidable
	{
		public function r_wall( type:String="wall" ) {
			super( type );
		}
		
		override protected function CreateBody():void {
			super.CreateBody();
			m_body.allowMovement = true;
		}
	}
}