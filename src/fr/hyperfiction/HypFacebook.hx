/*
Copyright (c) 2013, Hyperfiction
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package fr.hyperfiction;

import nme.events.Event;
import nme.events.EventDispatcher;

/**
 * ...
 * @author shoe[box]
 */
@:build(org.shoebox.utils.NativeMirror.build( )) class HypFacebook extends EventDispatcher{

	private var _sApp_id : String;

	#if android
	private var _JNI_instance : Dynamic;
	#end

	private static inline var OPENED               	: String = "OPENED";
	private static inline var OPENING              	: String = "OPENING";
	private static inline var GRAPH_REQUEST_ERROR  	: String = "GRAPH_REQUEST_ERROR";
	private static inline var GRAPH_REQUEST_RESULTS	: String = "GRAPH_REQUEST_RESULTS";
	private static inline var DIALOG_CANCELED      	: String = "DIALOG_CANCELED";
	private static inline var DIALOG_ERROR         	: String = "DIALOG_ERROR";
	private static inline var DIALOG_SENT          	: String = "DIALOG_SENT";

	// -------o constructor

		/**
		 *
		 * @param  sAppId the Facebook App Id
		 * @return
		 */
		public function new( sAppId : String ) {
			trace("constructor ::: "+sAppId );
			super( );
			_sApp_id = sAppId;
			_init( );
		}

	// -------o public

		/**
		 * connect to facebook. If there's a cached token,
		 * it uses it, otherwise show the LoginUI with basic perms.
		 * @return true if the session is opened
		 */
		public function connect( allowUI : Bool ) : Bool {
			trace("connect");

			var bSessionValid = false;

			#if android
			bSessionValid = jni_connect( _JNI_instance, allowUI );
			#end

			#if ios
			bSessionValid = CPP_FB_Connect( _sApp_id, allowUI );
			#end

			trace('bSessionValid ::: '+bSessionValid);
			return bSessionValid;
		}

		/**
		 * logout from facebook. Clear the cached token.
		 * @return Void
		 */
		public function logout( ) : Void {

			#if android
			jni_disconnect( _JNI_instance );
			#end

			#if ios
			CPP_FB_Disconnect( );
			#end
		}

		/**
		 * Make a call to facebook. Either Dialog or
		 * graph request.
		 * @param  req : a FacebookRequest object
		 * @return Void
		 */
		public function call( req : FacebookRequest ) : Void {
			trace("call ::: "+req);

			switch( req ){

				case DIALOG ( sAction , params ):
					_dialog( sAction , params );

				case FEED_DIALOG ( params ):
					_dialog( "feed" , params );

				case REQUEST_DIALOG	( params ):
					_dialog( "apprequests" , params );

				case GRAPH_REQUEST( sGraphPath , params , sMethod ):
					graph_request( sGraphPath , params , sMethod );

			}

		}

		/**
		 * Make a graph request to facebook
		 * @param  sRequest : the request, ex: "/me"
		 * @param  h : a hash of params and values
		 * @param  ?bPost   : true if its a POST request. GET otherwise
		 * @return Void
		 */
		public function graph_request( sRequest : String , ?h : Hash<String> , ?sMethod : HTTP_METHOD ) : Void {

			if( sMethod == null ) {
				sMethod = GET;
			}

			#if android
			jni_graph_request( _JNI_instance , sRequest , _serializeHash( h , true ) ,_serializeHash( h , false ) , Type.enumConstructor( sMethod ) );
			#end

			#if ios
			CPP_FB_request( sRequest, _serializeHash( h , true ) ,_serializeHash( h , false ) , Type.enumConstructor( sMethod ) );
			#end

		}

		/**
		 * requestNew_publish_permissions
		 * @param  a : an array of permissions
		 * @return Void
		 */
		public function requestNew_publish_permissions( a : Array<String> ) : Void {

			#if android
			jni_requestNew_publish_permissions( _JNI_instance , a.join("&"));
			#end

			#if ios
			CPP_FB_requestNew_publish_perm( a.join("|") );
			#end

		}

		/**
		 * requestNew_read_permissions
		 * @param  a : an array of permissions
		 * @return Void
		 */
		public function requestNew_read_permissions( a : Array<String> ) : Void {

			#if android
			jni_requestNew_read_permissions( _JNI_instance , a.join("&"));
			#end

			#if ios
			CPP_FB_requestNew_read_perm( a.join("|") );
			#end

		}

		/**
		 * getSession_permissions return the current permissions
		 * @return an array of permissions
		 */
		public function getSession_permissions( ) : Array<String> {

			#if android
				var perms = getPermissions( _JNI_instance );
				trace( "perms ::: "+perms );
				return perms.split("&");
			#end

			#if ios
				return CPP_FB_get_permissions( ).split( "|" );
			#end

			return new Array<String>( );
		}


	// -------o protected

		/**
		*
		*
		* @private
		* @return	void
		*/
		private function _dialog( sAction : String , params : Hash<String> ) : Void{
			trace("_dialog ::: "+sAction+" - "+params );

			#if android
				jni_dialog( _JNI_instance, sAction, _serializeHash( params , true ) , _serializeHash( params , false ) );
			#end

			#if ios
				CPP_FB_dialog( sAction , _serializeHash( params , true ) , _serializeHash( params , false ) );
			#end

		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		private function _init( ) : Void{

			#if android

				HypFB_set_event_callback( _onEvent );

				#if debug
				trace_hash( );
				#end

				_JNI_instance = create( _sApp_id );

			#end

			#if ios
				HypFB_set_event_callback( _onEvent );
			#end
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		private function _onEvent( sEventType : String , sArg1 : String , sArg2 : String ) : Void{
			trace('_onEvent ::: '+sEventType+' - '+sArg1+' - '+sArg2);


			var ev : HypFacebookEvent = null;
			switch( sEventType ){

				case HypFacebookEvent.OPENED:
					ev = new HypFacebookEvent( sEventType );
					ev.sFacebook_token = sArg1;

				case HypFacebookEvent.CLOSED_LOGIN_FAILED:
					ev = new HypFacebookEvent( sEventType );

				case HypFacebookEvent.OPENED_TOKEN_UPDATED:
					ev = new HypFacebookEvent( sEventType );

				case DIALOG_CANCELED:
					ev = _dispatch_dialog_event( sEventType , sArg2 , sArg1 );

				case DIALOG_ERROR:
					ev = _dispatch_dialog_event( sEventType );

				case DIALOG_SENT:
					ev = _dispatch_dialog_event( sEventType );

				case GRAPH_REQUEST_ERROR:
					ev = _dispatch_request_event( sEventType , sArg1 , null , sArg2 );

				case GRAPH_REQUEST_RESULTS:
					ev = _dispatch_request_event( sEventType , sArg2 , sArg1 );

				default:
					trace('pas connu');

			}

			if( ev != null )
				dispatchEvent( ev );
			else
				trace( sEventType +'??' );

		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		private function _dispatch_dialog_event(
														sType  	: String ,
														sPostID	: String = null ,
														sError 	: String = null
													) : HypFacebookEvent{

			trace('_dispatch_dialog_event ::: '+sType);
			var ev = new HypFacebookDialogEvent( sType );
				ev.sPostID	= sPostID;
				ev.sError 	= sError;
			return ev;
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		private function _dispatch_request_event(
													sType     		: String ,
													sResult   		: String,
													sGraphPath	: String,
													sError    		: String = null
												 ) : HypFacebookRequestEvent{

			var ev = new HypFacebookRequestEvent( sType );
				ev.sResult   		= sResult;
				ev.sGraphPath	= sGraphPath;
				ev.sError    		= sError;

			return ev;
		}

		/**
		*
		*
		* @private
		* @return	void
		*/
		inline private function _serializeHash( h : Hash<String> , bKey : Bool = true ) : String{

			var sRes = "";
			if( h != null ) {
				var iter = h.keys( );
				for( k in iter )
					sRes += ( bKey ? k : h.get( k ) ) + ( iter.hasNext( ) ? #if ios "|" #else "&" #end : "" );
			}

			return sRes;
		}


	// -------o misc


	// -------o CPP

		#if cpp

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function HypFB_set_event_callback( fCallBack : Dynamic) : Void {

		}

		#end

		#if ios

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_Connect( sAppID : , allowUI : Bool ) : Bool {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_Disconnect( ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_request( sGraphRequest : String, sParamsName : String, sParamsValues : String, sHTTPMethod : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_dialog( sAction : String , sParamsName : String , sParamsValues : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_requestNew_publish_perm( sPerms : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_requestNew_read_perm( sPerms : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@CPP("HypFacebook")
		public function CPP_FB_get_permissions( ) : String {

		}

		#end



	// -------o JNI

		#if android

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI
		static public function create( sAppId : String ) : HypFacebook {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI
		static public function trace_hash( ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI("fr.hyperfiction.HypFacebook","connect")
		public function jni_connect( instance : Dynamic, allowUI : Bool ) : Bool {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI("fr.hyperfiction.HypFacebook","disconnect")
		public function jni_disconnect( instance : Dynamic ) : Void {

		}

		@JNI("fr.hyperfiction.HypFacebook","show_dialog")
		public function jni_dialog( instance : Dynamic, sAction : String, sKeys : String , sVals : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI("fr.hyperfiction.HypFacebook","graph_request")
		public function jni_graph_request(  instance : Dynamic , sGraphPath : String , sKeys : String , sVals : String , sMethod : String ) : Void{

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI("fr.hyperfiction.HypFacebook","requestNew_publish_permissions")
		public function jni_requestNew_publish_permissions( instance : Dynamic , sPerms : String ) : Void {

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI("fr.hyperfiction.HypFacebook","requestNew_read_permissions")
		public function jni_requestNew_read_permissions( instance : Dynamic , sPerms : String ) : Void{

		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		@JNI
		public function getPermissions( instance : Dynamic ) : String {

		}

		#end

}

enum FacebookRequest{
	/*
	DIALOG( h : Hash<String> , sAction : String );
	FEED_DIALOG( h : Hash<String> );
	REQUEST_DIALOG( h : Hash<String> );

	GRAPH_REQUEST( sRequest : String , h : Hash<String> , ?bPost : Bool );
	*/

	DIALOG			( sAction : String , ?params : Hash<String> );
	FEED_DIALOG		( params : Hash<String> );
	REQUEST_DIALOG	( params : Hash<String> );

	GRAPH_REQUEST( sGraphPath : String , ?params : Hash<String> , ?sMethod : HTTP_METHOD );
}

enum HTTP_METHOD {
	GET;
	POST;
	DELETE;
}

/**
 * ...
 * @author shoe[box]
 */

class HypFacebookEvent extends Event{


	public var sFacebook_token	: String;
	public var sError			: String;

	public static inline var OPENED					: String = 'OPENED';
	public static inline var CLOSED_LOGIN_FAILED	: String = 'CLOSED_LOGIN_FAILED';
	public static inline var OPENED_TOKEN_UPDATED	: String = 'OPENED_TOKEN_UPDATED';

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		public function new( s : String ) {
			super( s );
		}

	// -------o public

	// -------o protected

	// -------o misc

}

/**
 * ...
 * @author shoe[box]
 */

class HypFacebookDialogEvent extends HypFacebookEvent{

	public static inline var DIALOG_CANCELED	= "DIALOG_CANCELED";
	public static inline var DIALOG_ERROR   	= "DIALOG_ERROR";
	public static inline var DIALOG_SENT    	= "DIALOG_SENT";

	public var sPostID	: String;

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		public function new( sType : String ) {
			super( sType );
		}

	// -------o public

	// -------o protected

	// -------o misc

}

/**
 * ...
 * @author shoe[box]
 */

class HypFacebookRequestEvent extends HypFacebookEvent{

	public static inline var GRAPH_REQUEST_ERROR  	= "GRAPH_REQUEST_ERROR";
	public static inline var GRAPH_REQUEST_RESULTS	= "GRAPH_REQUEST_RESULTS";

	public var sResult : String;
	public var sGraphPath : String;

	// -------o constructor

		/**
		* constructor
		*
		* @param
		* @return	void
		*/
		public function new( sType : String ) {
			super( sType );
		}

	// -------o public


	// -------o protected


	// -------o misc

}
