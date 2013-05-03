/*
Copyright (c) 2013, Hyperfiction
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef IPHONE
#define IMPLEMENT_API
#endif

#include <hx/CFFI.h>
#include <stdio.h>
#include <hxcpp.h>
#include "HypFacebook.h"

#ifdef ANDROID
#include <jni.h>
#endif
using namespace hypfacebook;

#ifdef ANDROID
	extern JNIEnv *GetEnv();
	enum JNIType{
	   jniUnknown,
	   jniVoid,
	   jniObjectString,
	   jniObjectArray,
	   jniObject,
	   jniBoolean,
	   jniByte,
	   jniChar,
	   jniShort,
	   jniInt,
	   jniLong,
	   jniFloat,
	   jniDouble,
	};
	#define  LOG_TAG    "trace"
	#define  ALOG(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)

#endif

AutoGCRoot *eval_onConnect = 0;
AutoGCRoot *eval_onEvent = 0;

extern "C"{

	int HypFacebook_register_prims(){
		printf("HypFacebook : register_prims()\n");
		return 0;
	}

	void hypfb_dispatch_event( const char *sType , const char *sArg1 , const char *sArg2 ){
		#ifdef ANDROID
		ALOG("hypfb_dispatch_event" );
		#endif
		val_call3(
					eval_onEvent->get( ) ,
					alloc_string( sType ) ,
					alloc_string( sArg1 ) ,
					alloc_string( sArg2 )
				);
	}

	#ifdef IPHONE

		void hypfb_callback( const char* cbType , const char* data ){
			val_call2( eval_onConnect->get( ), alloc_string( cbType ) , alloc_string( data ) );
		}


	#endif

// Common ------------------------------------------------------------------------------------------------------



// Android ----------------------------------------------------------------------------------------------------------

	#ifdef ANDROID

		JNIEXPORT void JNICALL Java_fr_hyperfiction_HypFacebook_onFBEvent(
																			JNIEnv * env ,
																			jobject obj ,
																			jstring jsEvName ,
																			jstring javaArg1 ,
																			jstring javaArg2
																		){
			ALOG("Java_fr_hyperfiction_HypFacebook_onFBEvent" );

			const char *sEvName	= env->GetStringUTFChars( jsEvName , 0 );
			const char *sArg1  	= env->GetStringUTFChars( javaArg1 , 0 );
			const char *sArg2  	= env->GetStringUTFChars( javaArg2 , 0 );

			hypfb_dispatch_event( sEvName , sArg1 , sArg2 );

			env->ReleaseStringUTFChars( jsEvName	, sEvName );
			env->ReleaseStringUTFChars( javaArg1 	, sArg1 );
			env->ReleaseStringUTFChars( javaArg2 	, sArg2 );

		}

		JNIEXPORT void JNICALL Java_fr_hyperfiction_HypFacebookFrag_onFBEvent(
																			JNIEnv * env ,
																			jobject obj ,
																			jstring jsEvName ,
																			jstring javaArg1 ,
																			jstring javaArg2
																		){
			ALOG("Java_fr_hyperfiction_HypFacebookFrag_onFBEvent" );

			const char *sEvName	= env->GetStringUTFChars( jsEvName , 0 );
			const char *sArg1  	= env->GetStringUTFChars( javaArg1 , 0 );
			const char *sArg2  	= env->GetStringUTFChars( javaArg2 , 0 );

			hypfb_dispatch_event( sEvName , sArg1 , sArg2 );

			env->ReleaseStringUTFChars( jsEvName	, sEvName );
			env->ReleaseStringUTFChars( javaArg1 	, sArg1 );
			env->ReleaseStringUTFChars( javaArg2 	, sArg2 );

		}

	#endif
}

// Callbacks ------------------------------------------------------------------------------------------------------

	static value HypFB_set_event_callback( value onCall ){
		#ifdef ANDROID
		ALOG("HypFB_set_event_callbacks" );
		#endif
		eval_onEvent = new AutoGCRoot( onCall );
		return alloc_bool( true );
	}
	DEFINE_PRIM( HypFB_set_event_callback , 1 );

// iPhone ---------------------------------------------------------------------------------------------------------

#ifdef IPHONE

	value CPP_FB_Connect( value app_id, value allow_ui ){
		return alloc_bool(connect( val_string( app_id ), val_bool( allow_ui ) ));
	}
	DEFINE_PRIM( CPP_FB_Connect , 2 );

	value CPP_FB_ConnectFor_publish( value app_id, value allow_ui, value permissions ){
		return alloc_bool(connectFor_publish( val_string( app_id ), val_bool( allow_ui ), val_string( permissions ) ));
	}
	DEFINE_PRIM( CPP_FB_ConnectFor_publish , 3 );

	value CPP_FB_ConnectFor_read( value app_id, value allow_ui, value permissions ){
		return alloc_bool(connectFor_read( val_string( app_id ), val_bool( allow_ui ), val_string( permissions ) ));
	}
	DEFINE_PRIM( CPP_FB_ConnectFor_read , 3 );

	value CPP_FB_Disconnect( ){
		disconnect( );
		return alloc_null( );
	}
	DEFINE_PRIM( CPP_FB_Disconnect , 0 );

	value CPP_FB_request( value sGraphRequest, value sParamsName, value sParamsVals, value sHttpMethod ){
		request(
		    val_string( sGraphRequest ),
		    val_string( sParamsName ),
		    val_string( sParamsVals ),
		    val_string( sHttpMethod )
		);
		return alloc_null( );
	}
	DEFINE_PRIM( CPP_FB_request , 4 );

	value CPP_FB_dialog( value sAction , value sParamsName , value sParamsValues ){
		dialog(
			val_string( sAction ) ,
			val_string( sParamsName ) ,
			val_string( sParamsValues )
		);
		return alloc_null( );
	}
	DEFINE_PRIM( CPP_FB_dialog , 3 );

	value CPP_FB_requestNew_publish_perm( value sPerms ){
		requestNew_publish_perm( val_string( sPerms ) );
		return alloc_null( );
	}
	DEFINE_PRIM( CPP_FB_requestNew_publish_perm , 1 );

	value CPP_FB_requestNew_read_perm( value sPerms ){
		requestNew_read_perm( val_string( sPerms ) );
		return alloc_null( );
	}
	DEFINE_PRIM( CPP_FB_requestNew_read_perm , 1 );

	value CPP_FB_get_permissions( ) {
		return alloc_string( getPermissions( ) );
	}
	DEFINE_PRIM( CPP_FB_get_permissions , 0 );

#endif

