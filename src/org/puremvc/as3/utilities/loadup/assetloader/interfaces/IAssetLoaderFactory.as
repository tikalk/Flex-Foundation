/*
	PureMVC Utility - Loadup
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/

package org.puremvc.as3.utilities.loadup.assetloader.interfaces
{
    import org.puremvc.as3.utilities.loadup.assetloader.model.AssetProxy;

	public interface IAssetLoaderFactory {

		function getAssetLoader( assetType :String, respondTo :AssetProxy ) :IAssetLoader;

	}
}
