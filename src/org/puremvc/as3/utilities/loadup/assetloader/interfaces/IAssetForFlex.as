/*
	PureMVC Utility - Loadup
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/

package org.puremvc.as3.utilities.loadup.assetloader.interfaces
{
	import mx.core.UIComponent;

    /**
     *  The data property of AssetProxy.
     */
	public interface IAssetForFlex extends IAsset {

		function get uiComponent() :UIComponent;

	}
}
