HypFacebook
=============================
A Facebook native extension for NME
-----------------------------

This NME native extension allows you to integrate Facebook into your NME application.

It integrates the [Facebook iOS SDK 3.2.1](https://github.com/facebook/facebook-ios-sdk)
and the [Facebook Android SDK 3.0.1](https://github.com/facebook/facebook-android-sdk)

These are under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

Installation
------------
There is an [include.nmml]() file and [ndll]() are compiled for:
* ios armv6
* ios armv7
* ios simulator
* android armv6

Usage
-----

    var fb = new HypFacebook( "<your appid>" );
    fb.addEventListener( HypFacebookEvent.OPENED, _onFbOpened );
    fb.connect( );

    function _onFbOpened( _ ) {
		fb.call( GRAPH_REQUEST("/me") );
    }

Once HypFacebook is opened, you pass a FacebookRequest enum value to the call function:

    DIALOG        	( sAction   	: String, ?params : Hash<String> );
    FEED_DIALOG   	( params    	: Hash<String> );
    REQUEST_DIALOG	( params    	: Hash<String> );
    GRAPH_REQUEST 	( sGraphPath	: String, ?params : Hash<String>, ?sMethod : HTTP_METHOD );

And listen to the result event:

    class HypFacebookEvent extends Event{

		public var sFacebook_token	: String;
		public var sError         	: String;

		public static inline var OPENED              	: String = 'OPENED';
		public static inline var CLOSED_LOGIN_FAILED 	: String = 'CLOSED_LOGIN_FAILED';
		public static inline var OPENED_TOKEN_UPDATED	: String = 'OPENED_TOKEN_UPDATED';
    }

    class HypFacebookDialogEvent extends HypFacebookEvent{

		public static inline var DIALOG_CANCELED	= "DIALOG_CANCELED";
		public static inline var DIALOG_ERROR   	= "DIALOG_ERROR";
		public static inline var DIALOG_SENT    	= "DIALOG_SENT";

		public var sPostID	: String;
    }

When you make a graph request, you get the raw String result from Facebook in a HypFacebookRequestEvent:

    class HypFacebookRequestEvent extends HypFacebookEvent{

		public static inline var GRAPH_REQUEST_ERROR  	= "GRAPH_REQUEST_ERROR";
		public static inline var GRAPH_REQUEST_RESULTS	= "GRAPH_REQUEST_RESULTS";

		public var sResult   	: String;
		public var sGraphPath	: String;
	}

Quick reference
---------------

Present a request dialog:

    var h = new Hash<String>( );
    h.set( "message" , "Test Request");
    h.set( "to" , "<fb user id>");
    fb.call( REQUEST_DIALOG( h ) );

Present a feed dialog:

    var h = new Hash<String>( );
    h.set("name","Facebook extension for NME");
    h.set("caption","Build great social apps and get more installs with Haxe/NME.");
    h.set("description","The Facebook extension for NME makes it easier and faster to develop Facebook integrated apps build with Haxe");
    h.set("link","http://www.nme.io");
    h.set("picture","https://raw.github.com/fbsamples/ios-3.x-howtos/master/Images/iossdk_logo.png");
    fb.call( FEED_DIALOG( h ) );

Make a request to the Facebook Graph API:

    var h = new Hash<String>( );
    h.set( "score", "42" );
    fb.call( GRAPH_REQUEST("/<fb user id>/scores", h ,POST) );

You can also present any [facebook dialog](https://developers.facebook.com/docs/reference/dialogs/) with:

    fb.call( DIALOG( "<dialog name>", <hash of parameters> ) );

Made at Hyperfiction
--------------------
[hyperfiction.fr](http://hyperfiction.fr)

License
-------
This work is under BSD simplified License.