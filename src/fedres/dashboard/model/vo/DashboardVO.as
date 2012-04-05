package   fedres.dashboard.model.vo
{
	public class DashboardVO  
	{
		public var id : String = ''; 
		[Bindable] public var name : String = ''; 
		[Bindable] public var description : String = ''; 
		[Bindable] public var author : String = '';
		
		public var series : Array = []; 
		 
	}
}