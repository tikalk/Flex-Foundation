/*
	PureMVC Utility - Loadup
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/
package org.puremvc.as3.utilities.loadup.assetloader.model.assets
{
	import mx.core.UIComponent;
	import mx.controls.SWFLoader;

    import org.puremvc.as3.utilities.loadup.Loadup;
    import org.puremvc.as3.utilities.loadup.assetloader.interfaces.IAssetForFlex;
    import org.puremvc.as3.utilities.loadup.assetloader.model.AssetGroupProxy;

	public class AssetOfTypeSwf extends AssetBase implements IAssetForFlex
	{
        private var _uiComponent :UIComponent;

		public function AssetOfTypeSwf( url :String ) {
		    super( url );
		}
		public function get type() :String {
		    return Loadup.SWF_ASSET_TYPE;
		}
		public function get uiComponent() :UIComponent {
		    if ( ! data )
		        return null;
		    if ( ! _uiComponent ) {
		        var swf :SWFLoader = new SWFLoader();
		        swf.load( data );
		        _uiComponent = swf;
		    }
		    return _uiComponent;
		}

	}
}