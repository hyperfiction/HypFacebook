/*
Copyright (c) 2013, Hyperfiction
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package fr.hyperfiction;

import com.facebook.*;
import com.facebook.Session.StatusCallback;
import com.facebook.model.*;
import com.facebook.widget.*;
import com.facebook.internal.SessionAuthorizationType;
import com.facebook.internal.SessionTracker;
import com.facebook.internal.Utility;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.app.Activity;
import android.content.SharedPreferences.Editor;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import android.widget.FrameLayout;
import android.text.TextUtils;
import android.opengl.GLSurfaceView;

import fr.hyperfiction.Base64;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;
import java.util.List;

import org.haxe.nme.GameActivity;
import org.haxe.nme.HaxeObject;
import org.haxe.nme.NME;

import ::APP_PACKAGE::.R;

/**
 * ...
 * @author shoe[box]
 */
public class HypFacebook {

	static public native void onFBEvent( String jsEvName , String javaArg1 , String javaArg2 );
	static{
		System.loadLibrary( "HypFacebook" );
	}

	private String _sAppID;
	private HypFacebookFrag _oFrag;
	private List<String> _aPermissions;

	private static HypFacebook __instance      	= null;
	private static String ARGS_SEPARATOR       	= "-";
	private static String GRAPH_REQUEST_ERROR  	= "GRAPH_REQUEST_ERROR";
	private static String GRAPH_REQUEST_RESULTS	= "GRAPH_REQUEST_RESULTS";
	private static String OPENED               	= "OPENED";
	private static String DIALOG_CANCELED      	= "DIALOG_CANCELED";
	private static String DIALOG_ERROR         	= "DIALOG_ERROR";
	private static String DIALOG_SENT          	= "DIALOG_SENT";
	private static String TAG                  	= "trace";//HypFacebook";

	private static final int REAUTH_ACTIVITY_CODE = 100;

	private static GLSurfaceView _mSurface;

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		public HypFacebook( String sAppID ){
			trace("constructor ::: "+sAppID);
			_sAppID = sAppID;
			_mSurface = (GLSurfaceView) GameActivity.getInstance().getCurrentFocus();
	}

	// -------o public

		/**
		*
		*
		* @public
		* @return	void
		*/
		public static HypFacebook getInstance( ){
			return __instance;
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public boolean connect( boolean allowUI ){
			Session session = _createSession( );
			Session.OpenRequest req = _createOpenRequest( session );
			if ( SessionState.CREATED_TOKEN_LOADED.equals(session.getState()) || allowUI ) {
				Session.setActiveSession( session );
				session.openForRead( req );
				return session.isOpened( );
			} else {
				return false;
			}
		}

		public boolean connectForPublish( boolean allowUI, String sPerms )  {
			Session session = _createSession( );
			Session.OpenRequest req = _createOpenRequest( session );
			req.setPermissions( _createPermissionsFromString( sPerms ) );
			if ( SessionState.CREATED_TOKEN_LOADED.equals(session.getState()) || allowUI ) {
				Session.setActiveSession( session );
				session.openForPublish( req );
				return session.isOpened( );
			} else {
				return false;
			}
		}

		public boolean connectForRead( boolean allowUI, String sPerms ) {
			Session session = _createSession( );
			Session.OpenRequest req = _createOpenRequest( session );
			req.setPermissions( _createPermissionsFromString( sPerms ) );
			if ( SessionState.CREATED_TOKEN_LOADED.equals(session.getState()) || allowUI ) {
				Session.setActiveSession( session );
				session.openForRead( req );
				return session.isOpened( );
			} else {
				return false;
			}
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void disconnect( ){
	        Session session = Session.getActiveSession();
		    if (session != null) {
				session.closeAndClearTokenInformation( );
			}
		}

		//Dialog listeners

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void show_dialog( final String sAction , String sKeys , String sVals ){
			trace("sKeys ::: "+sKeys);
			trace("sVals ::: "+sVals);

			String[] aKeys = sKeys.split("&");
			String[] aVals = sVals.split("&");

			//Parameters bundle
				final Bundle params = new Bundle( );

				for( int i = 0 ; i < aKeys.length ; i++ ){
					trace("---"+i);
					params.putString( aKeys[ i ] , aVals[ i ] );
				}

			//
				GameActivity.getInstance( ).runOnUiThread(
					new Runnable( ) {
						public void run() {
							WebDialog dialog = new WebDialog.Builder( GameActivity.getInstance( ), Session.getActiveSession(), sAction, params ).build( );
							dialog.setOnCompleteListener( listener_dialog );
							dialog.show( );
						}
					}
				);

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void graph_request( String sGraphRequest , String sKeys , String sVals , String sMethod ){
			trace("graph_request ::: "+sMethod);
			Bundle params = stringTo_bundle( sKeys , sVals );

			final Request req	 = new Request( Session.getActiveSession( ) , sGraphRequest , params , HttpMethod.valueOf( sMethod ) , listener_request );
			_mSurface.queueEvent(new Runnable() {
				@Override
				public void run() {
					trace( "sync request...");
					req.executeAndWait();
				}
			});
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		private Bundle stringTo_bundle( String sKeys , String sVals ){
			trace("stringTo_bundle");

			//
				String[] aKeys = sKeys.split("&");
				String[] aVals = sVals.split("&");

			//Parameters bundle
				Bundle params = new Bundle( );

				for( int i = 0 ; i < aKeys.length ; i++ ){
					trace("---"+i);
					trace( aKeys[ i ]+" = "+aVals[ i ] );
					params.putString( aKeys[ i ] , aVals[ i ] );
				}

			return params;
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void requestNew_publish_permissions( String sPerms ){
			Session.NewPermissionsRequest req = _createRequestFromString( sPerms );
			if( req != null ) {
				Session session = Session.getActiveSession( );
				if (session != null) {
					session.requestNewPublishPermissions( req );
				}
			}
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void requestNew_read_permissions( String sPerms ){
			Session.NewPermissionsRequest req = _createRequestFromString( sPerms );
			if( req != null ) {
				Session session = Session.getActiveSession( );
				if (session != null) {
					session.requestNewReadPermissions( req );
				}
			}
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public String getPermissions( ){

			List<String> lPerms = Session.getActiveSession( ).getPermissions( );
			String[] a = new String[ lPerms.size() ];

			lPerms.toArray(a);
			return TextUtils.join( "&" , a );
		}


	// -------o protected

		private Session _createSession( ) {
			Session session;
			session = new Session.Builder( GameActivity.getInstance( ) ).setApplicationId(_sAppID).build();
			return session;
		}

		private Session.OpenRequest _createOpenRequest( Session session ) {
			Session.OpenRequest req = new Session.OpenRequest( GameActivity.getInstance( ) );
			req.setCallback( new Session.StatusCallback( ){
			    @Override
			    public void call( final Session session, final SessionState state, final Exception exception) {
					if( state.equals( SessionState.CLOSED_LOGIN_FAILED )
						|| state.equals( SessionState.CLOSED ) ) {
						session.closeAndClearTokenInformation();
					}
					onFBEventWrapper( state.toString(), session.getAccessToken( ), "" );
			    }
			});
			return req;
		}

		private Session.NewPermissionsRequest _createRequestFromString( String sPerms ) {
			List<String> permissions = _createPermissionsFromString( sPerms );
			Session.NewPermissionsRequest req = new Session.NewPermissionsRequest( GameActivity.getInstance( ) , permissions );
			return req;
		}

		private List<String> _createPermissionsFromString( String sPerms ) {
			String[] aPerms = sPerms.split("&");
			List<String> permissions = Arrays.asList( aPerms );
			return permissions;
		}

	// -------o misc

		/**
		*
		*
		* @private
		* @return	void
		*/
		public static void trace( String s ){
			Log.w( TAG, s );
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		public static HypFacebook create( String sAppId ){
			Log.i( TAG, "HypFacebook :: create ::: "+sAppId );
			return __instance = new HypFacebook( sAppId );
		}

	// -------o misc

		public static void trace_hash( ){
			trace("trace_hash");


		Log.i("trace", "nme_key_hash : +::APP_PACKAGE:: ");
		try {
			   PackageInfo info = GameActivity.getInstance( ).getPackageManager( ).getPackageInfo( "::APP_PACKAGE::" , PackageManager.GET_SIGNATURES );
			   for (Signature signature : info.signatures) {
			        MessageDigest	md = MessageDigest.getInstance("SHA");
			                     					md.update(signature.toByteArray());
			        Log.i("trace", "PXR : "+Base64.encodeBytes(md.digest()));
			   }
			}
			catch (NameNotFoundException e) {
				Log.i("trace","NameNotFoundException : "+e);
			}
			catch (NoSuchAlgorithmException e) {
				Log.i("trace","NoSuchAlgorithmException : "+e);
			}

	    }


		private WebDialog.OnCompleteListener listener_dialog = new WebDialog.OnCompleteListener( ){

						@Override
			public void onComplete(Bundle values, FacebookException error) {
				trace("onComplete");
				if( error != null ){
					onFBEventWrapper( DIALOG_ERROR , error.toString( ) , "" );
				}else{
					final String postId = values.getString("post_id");
					if ( postId != null )
						onFBEventWrapper( DIALOG_SENT , postId , "" );
					else
						onFBEventWrapper( DIALOG_CANCELED , "" , "" );
				}
			}
		};

		private Request.Callback listener_request = new Request.Callback( ){

			@Override
		    public void onCompleted(Response response) {

			String sGraphPath = response.getRequest( ).getGraphPath( );

				FacebookRequestError error = response.getError( );
				if( error != null ){
					trace( "error : "+error );
					onFBEventWrapper(GRAPH_REQUEST_ERROR , sGraphPath , error.toString( ) );
				}else{
					onFBEventWrapper( GRAPH_REQUEST_RESULTS , sGraphPath , response.getGraphObject( ).getInnerJSONObject().toString() );
				}

			}

		};

		private void onFBEventWrapper( final String arg0, final String arg1, final String arg2 ) {
			_mSurface.queueEvent(new Runnable() {
				@Override
				public void run() {
					onFBEvent( arg0, arg1, arg2 );
				}
			});
		}
}