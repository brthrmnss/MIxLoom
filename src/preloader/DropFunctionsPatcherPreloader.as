package preloader {
import org.mixingloom.managers.IPatchManager;
import org.mixingloom.patcher.MigrateFunctionsPatcher_Final;
import org.mixingloom.preloader.AbstractPreloader;

	public class DropFunctionsPatcherPreloader extends AbstractPreloader {

		override protected function setupPatchers(manager:IPatchManager):void {
			super.setupPatchers(manager);
			manager.registerPatcher( new MigrateFunctionsPatcher_Final( LoadSwc.reload_DirsInclude ) );
			/*manager.registerPatcher( new MigrateFunctionsPatcher_Final(['blah.Food', '5views.', 
				'views']) );*/
			
		}

	}
}