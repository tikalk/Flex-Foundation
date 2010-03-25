/*
	PureMVC Utility - Loadup
	Copyright (c) 2008 Philip Sexton <philip.sexton@puremvc.org>
	Your reuse is governed by the Creative Commons Attribution 3.0 License
*/

package org.puremvc.as3.utilities.loadup.assetloader.interfaces
{
	public interface IAssetFactory {

		function getAsset( url :String, type :String = null ) :IAsset;

	}
}
