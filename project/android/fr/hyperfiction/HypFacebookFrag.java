/*
Copyright (c) 2013, Hyperfiction
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package fr.hyperfiction;

import ::APP_PACKAGE::.R;

import com.facebook.*;
import com.facebook.model.GraphObject;
import com.facebook.model.GraphPlace;
import com.facebook.model.GraphUser;
import com.facebook.widget.*;
import com.facebook.LoggingBehavior;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.Settings;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.List;
import java.util.Arrays;

import org.haxe.nme.GameActivity;

/**
 * ...
 * @author shoe[box]
 */

public class HypFacebookFrag extends Fragment{

	private UiLifecycleHelper uiHelper;
	private List<String> _aPermissions;
	private String _sAppID;
	private Session _session;

	private static String TAG		= "trace";//HypFacebook";
	private static String APP_ID	= "APP_ID";
	private static String APP_PERMS	= "APP_PERMS";

	// -------o constructor


	// -------o public

		public static final HypFacebookFrag build( String sAppID , String sPerms ){
			trace("constructor");
		    Bundle 	b = new Bundle(2);
		    		b.putString( APP_ID , sAppID );
		   			b.putString( APP_PERMS , sPerms );

		    HypFacebookFrag f = new HypFacebookFrag();
		    				f.setArguments(b);
		    return f;
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void onCreate(Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			_sAppID			= getArguments().getString( APP_ID );
			_aPermissions	= Arrays.asList( getArguments().getString( APP_PERMS ).split("&"));

			trace("onCreate");


        	//_authorize( );



	        uiHelper = new UiLifecycleHelper(getActivity( ), callback);
        	uiHelper.onCreate(savedInstanceState);

        	_session = Session.getActiveSession();
	        if (!_session.isOpened() && !_session.isClosed() ) {
	            _session.openForRead( new Session.OpenRequest(this).setCallback( callback ) );
	        } else {
	            Session.openActiveSession( getActivity( ), this , true , callback );
	        }
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@Override
	    public void onStart() {
	    	trace("onStart");
	        super.onStart( );
	      	Session.getActiveSession().addCallback( callback );
	    }

	    /**
	    *
	    *
	    * @public
	    * @return	void
	    */
	    @Override
	    public void onStop( ){
	    	super.onStop( );
	    	Session.getActiveSession().removeCallback( callback );
	    }

		/**
		*
		*
		* @public
		* @return	void
		*/
		@Override
	    public void onPause() {
	    	trace("onPause");
	        super.onPause();
	        uiHelper.onPause();
	    }

	    /**
		*
		*
		* @public
		* @return	void
		*/
	    @Override
	    public void onDestroy() {
	    	trace("onDestroy");
	        super.onDestroy();
	        uiHelper.onDestroy();
   		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		public void authorize( ){
			trace("authorize");
			Session session = Session.getActiveSession();
	        if (!session.isOpened() && !session.isClosed() ) {
	            session.openForRead( new Session.OpenRequest(this).setCallback( callback ) );
	        } else {
	            Session.openActiveSession( getActivity( ), this , true , callback );
	        }

		}

		@Override
    	public void onActivityResult(int requestCode, int resultCode, Intent data) {
    		trace("onActivityResult");
    		super.onActivityResult(requestCode, resultCode, data);
    		Session.getActiveSession().onActivityResult( getActivity( ) , requestCode , resultCode , data );
    	}

    	/**
    	*
    	*
    	* @public
    	* @return	void
    	*/
    	public WebDialog openFeed_dialog( Bundle params ){
    		return new WebDialog.FeedDialogBuilder( getActivity( ) , Session.getActiveSession() , params ).build( );
    	}

    	static public native void onFBEvent( String jsEvName , String javaArg1 , String javaArg2 );
		static{
			System.loadLibrary( "HypFacebook" );
		}

	// -------o protected

		private Session.StatusCallback callback = new Session.StatusCallback() {
	        @Override
	        public void call(Session session, SessionState state, Exception exception) {
	        	trace("call ::: "+session);
	        	trace("instance ::: "+ HypFacebook.getInstance( ));
	            //sHypFacebook.getInstance( ).call(session, state, exception);
	            final String s = session.getState( ).toString( );
	            trace( " : "+s );
				if( s == "OPENED" )
					HypFacebook.onFBEvent( s , session.getAccessToken( ) , "" );
				else
	        		HypFacebook.onFBEvent( s , "" , "" );

	            /*
		        getActivity( ).runOnUiThread(new Runnable() {
				    public void run() {
				    	onFBEvent( s , "" , "" );
				    }
				});
		        */

		 	}
	    };

	    /**
	    *
	    *
	    * @private
	    * @return	void
	    */
	    private void onSessionStateChange(Session session, SessionState state, Exception exception) {
	    	trace("onSessionStateChange");
	    }

	    /**
	    *
	    *
	    * @private
	    * @return	void
	    */
	    private void _authorize( ){
	    	trace("_authorize");

	    	final Session.OpenRequest 	req = new Session.OpenRequest( this );
										req.setPermissions( _aPermissions );
			Session.getActiveSession( ).openForRead( req );
	    }

	// -------o misc

		/**
		*
		*
		* @private
		* @return	void
		*/
		public static void trace( String s ){
			Log.w( TAG, "HypFacebookFrag ::: "+s );
		}


}
