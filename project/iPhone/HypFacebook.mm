/*
Copyright (c) 2013, Hyperfiction
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import <UIKit/UIKit.h>
#include <HypFacebook.h>
#import <FacebookSDK.h>

//Externs
	typedef void( *FunctionType)( );
	extern "C"{
		void hypfb_dispatch_event( const char *sType , const char *sArg1 , const char *sArg2 );
	}


//interface

	@interface HypFacebook : NSObject
		+ (HypFacebook *)instance;
	@end

	@interface LimeAppDelegate : NSObject <UIApplicationDelegate>
	@end


//implementation

	@implementation LimeAppDelegate (HypFacebook)
		- (BOOL)application:(UIApplication *) application
							openURL:(NSURL *)url
							sourceApplication:(NSString *)sourceApplication
							annotation:(id)annotation {
			BOOL wasHandled = [FBAppCall handleOpenURL:url
                             sourceApplication:sourceApplication];
			return wasHandled;
		}
	@end

	@implementation HypFacebook

		- (void)dealloc
		{
			[[NSNotificationCenter defaultCenter]
				removeObserver:self	name:UIApplicationWillTerminateNotification object:nil];
			[[NSNotificationCenter defaultCenter]
				removeObserver:self	name:UIApplicationDidBecomeActiveNotification object:nil];
		}

		+ (HypFacebook *)instance{
			static HypFacebook *instance;

			@synchronized(self){
			if (!instance)
				instance = [[HypFacebook alloc] init];

			return instance;
			}
		}

		- (id)init {
		    self = [super init];
		    if (self) {
				[[NSNotificationCenter defaultCenter]
					addObserver:self
					selector:@selector(willTerminate:)
					name:UIApplicationWillTerminateNotification
					object:nil
				];
				[[NSNotificationCenter defaultCenter]
					addObserver:self
					selector:@selector(didBecomeActive:)
					name:UIApplicationDidBecomeActiveNotification
					object:nil
				];
		    }
			return self;
		}

		- (void)willTerminate: (NSNotification *) notification {
			[FBSession.activeSession close];
		}

		- (void)didBecomeActive: (NSNotification *) notification {
			[FBSession.activeSession handleDidBecomeActive];
		}

		/**
		 * A function for parsing URL parameters.
		 */
		- (NSDictionary*)parseURLParams:(NSString *)query {
		    NSArray *pairs = [query componentsSeparatedByString:@"&"];
		    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		    for (NSString *pair in pairs) {
		        NSArray *kv = [pair componentsSeparatedByString:@"="];
		        NSString *val =
		        [[kv objectAtIndex:1]
		         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

		        [params setObject:val forKey:[kv objectAtIndex:0]];
		    }
		    return params;
		}


		/**
		*
		*
		* @public
		* @return	void
		*/
		-(bool) connect:(NSString*)NSappID withUI:(BOOL)withUI{
			NSLog(@"connect with id: %@",NSappID);
			[FBSettings setDefaultAppID:NSappID];
			[FBSession openActiveSessionWithReadPermissions:nil
				allowLoginUI:withUI
				completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
					[self sessionStateChanged:session state:state error:error];
				}
			];
			return [FBSession.activeSession isOpen];
		}

		-(bool) connectForRead:(NSString*)NSappID withUI:(BOOL)withUI withReadPerms:(NSArray *)NSAPerms {
			NSLog(@"connect with id: %@, with perms: %@",NSappID,NSAPerms);
			[FBSettings setDefaultAppID:NSappID];
			[FBSession openActiveSessionWithReadPermissions:NSAPerms
				allowLoginUI:withUI
				completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
					[self sessionStateChanged:session state:state error:error];
				}
			];
			return [FBSession.activeSession isOpen];
		}

		-(bool) connectForPublish:(NSString*)NSappID withUI:(BOOL)withUI withPublishPerms:(NSArray *)NSAPerms {
			NSLog(@"connect with id: %@, with perms: %@",NSappID,NSAPerms);
			[FBSettings setDefaultAppID:NSappID];
			[FBSession openActiveSessionWithPublishPermissions:NSAPerms
				defaultAudience:FBSessionDefaultAudienceFriends
				allowLoginUI:withUI
				completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
					[self sessionStateChanged:session state:state error:error];
				}
			];
			return [FBSession.activeSession isOpen];
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		-(void) disconnect{
			[FBSession.activeSession closeAndClearTokenInformation];
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		-(void) authorizeRead:(NSArray*)NSAPerms{
			[FBSession.activeSession requestNewReadPermissions:NSAPerms
				completionHandler:^(FBSession *session, NSError *error){
					if ( error ) {
						[self handleRequestPermissionError: error];
					}
				}
			];
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		-(void) authorizePublish:(NSArray*)NSAPerms{
			[FBSession.activeSession requestNewPublishPermissions:NSAPerms
				defaultAudience:FBSessionDefaultAudienceEveryone
				completionHandler:^(FBSession *session, NSError *error){
					if ( error ) {
						[self handleRequestPermissionError: error];
					}
				}
			];
		}

		-(void) presentDialog:(NSString *)dialog withParameters:(NSDictionary *)params {
			NSLog(@" dialog ::: %@ and params ::: %@ ",dialog,params);
			[FBWebDialogs presentDialogModallyWithSession:nil
							dialog:dialog
							parameters:params
							handler:
				^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
					if (error) {
						// Error launching the dialog or publishing story.
						NSLog(@"Error ::: %@ publishing story ::: %@",resultURL, error);
						hypfb_dispatch_event("DIALOG_ERROR" , "", "");
					} else {
						if (result == FBWebDialogResultDialogNotCompleted) {
							// User canceled
							NSLog(@"User canceled story publishing with x icon.");
							hypfb_dispatch_event("DIALOG_CANCELED" , "", "");
						} else {
							NSLog(@"resultURL: %@",resultURL);
							NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
							if ([urlParams valueForKey:@"post_id"]) {
								// User clicked the Share button
								NSString *postID = [urlParams valueForKey:@"post_id"];
								NSLog(@"Posted story, id: %@", postID);
								hypfb_dispatch_event("DIALOG_SENT" , [postID UTF8String], "");
							} else if ([urlParams valueForKey:@"request"]) {
								// User clicked the Send button
								NSString *requestID = [urlParams valueForKey:@"request"];
								NSLog(@"Request sent, id: %@", requestID);
								hypfb_dispatch_event("DIALOG_SENT" , [requestID UTF8String], "");
							} else {
								// User clicked the Cancel button
								hypfb_dispatch_event("DIALOG_CANCELED", "", "" );
							}
						}
					}
			} ];
		}

		/**
		*
		*
		* @public
		* @return	void
		*/
		-(void) fbRequest:(NSString*)NSGraphRequest
                HTTPMethod:(NSString*)HTTPMethod
				parameters:(NSDictionary*)parameters {
					NSLog(@" graph request ::: %@, method ::: %@, params ::: %@",NSGraphRequest,HTTPMethod,parameters);
			[FBRequestConnection startWithGraphPath:NSGraphRequest
				parameters:parameters
				HTTPMethod:HTTPMethod
				completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
					if ( error ) {
						hypfb_dispatch_event(
								"GRAPH_REQUEST_ERROR" ,
								[(NSString*) NSGraphRequest UTF8String],
								[[error localizedDescription] UTF8String]
							);
					} else {
						hypfb_dispatch_event(
								"GRAPH_REQUEST_RESULTS" ,
								[(NSString*) NSGraphRequest UTF8String] ,
								[[NSString stringWithFormat:@"%@", result] UTF8String]
							);
					}
				}
			];
		}

		/**
		 * Helper method to handle errors during permissions request
		 * @param error
		 */
		- (void)handleRequestPermissionError:(NSError *)error {
            NSLog(@"error ::: %@",error);
		    if (error.fberrorShouldNotifyUser) {
		        // If the SDK has a message for the user, surface it.
	            NSLog(@"error with message %@",error.fberrorUserMessage);
		        hypfb_dispatch_event("PERMISSION_ERROR" , [error.fberrorUserMessage UTF8String], "");
		    } else {
		        if (error.fberrorCategory == FBErrorCategoryUserCancelled){
		            // The user has cancelled the request. You can inspect the value and
		            // inner error for more context. Here we simply ignore it.
		            NSLog(@"User cancelled post permissions.");
			        hypfb_dispatch_event("PERMISSION_ERROR" , "", "");
		        } else {
		            NSLog(@"Unexpected error requesting permissions:%@", error);
			        hypfb_dispatch_event("PERMISSION_ERROR" , "", "");
		        }
		    }
		}

		/**
		 * Callback for session state changed
		 * @param session the session
		 * @param state   the new state
		 * @param error   if an error occured
		 */
		- (void)sessionStateChanged:(FBSession *)session
		                      state:(FBSessionState) state
		                      error:(NSError *)error {
		    switch (state) {
		        case FBSessionStateOpen:
		            if (!error) {
		                // We have a valid session
		                NSLog(@"User session found");
		                hypfb_dispatch_event("OPENED" , [[[session accessTokenData] accessToken] UTF8String], "");
		            }
		            break;
		        case FBSessionStateClosed:
		        case FBSessionStateClosedLoginFailed:
		            [FBSession.activeSession closeAndClearTokenInformation];
		            break;
		        default:
		            break;
		    }

		    if (error) {
				hypfb_dispatch_event("ERROR", [error.localizedDescription UTF8String], "" );
		    }
		}

	@end

//
namespace hypfacebook{

	NSArray* _getArrayFromPipeUTF8String( const char *pipe_string );
	NSDictionary* _getDictFromStrings( const char *sParamsNAme, const char *sParamsVal );

	bool connectFrom_cache( const char *sAppID ){
		NSString *NSAppID = [ [NSString alloc] initWithUTF8String:sAppID ];
		NSLog(@"connect from cache %@",NSAppID);
		return [[HypFacebook instance] connect:NSAppID withUI:NO];
	}

	/**
	*
	*
	* @public
	* @return	void
	*/
	bool connect( const char *sAppID, bool allow_ui ){
		NSString *NSAppID = [ [NSString alloc] initWithUTF8String:sAppID ];
		NSLog(@"connect %@",NSAppID);
		BOOL ui = allow_ui ? YES : NO;
		return [[HypFacebook instance] connect:NSAppID withUI:ui];
	}

	bool connectFor_read( const char *sAppID, bool allow_ui, const char *sPerms ) {
		NSString *NSAppID = [ [NSString alloc] initWithUTF8String:sAppID ];
		NSLog(@"connect %@",NSAppID);
		BOOL ui = allow_ui ? YES : NO;
		return [[HypFacebook instance]
					connectForRead:NSAppID
					withUI:ui
					withReadPerms:_getArrayFromPipeUTF8String( sPerms)
					];
	}

	bool connectFor_publish( const char *sAppID, bool allow_ui, const char *sPerms ) {
		NSString *NSAppID = [ [NSString alloc] initWithUTF8String:sAppID ];
		NSLog(@"connect %@",NSAppID);
		BOOL ui = allow_ui ? YES : NO;
		return [[HypFacebook instance]
					connectForPublish:NSAppID
					withUI:ui
					withPublishPerms:_getArrayFromPipeUTF8String( sPerms )
					];
	}

	/**
	*
	*
	* @public
	* @return	void
	*/
	void disconnect( ){
		[[HypFacebook instance] disconnect];
	}

	/**
	*
	*
	* @public
	* @return	void
	*/
	void request( const char *sGraphRequest, const char *sParamsName, const char *sParamsVal, const char *sHttpMethod ){
		NSString *NSReq = [ [NSString alloc] initWithUTF8String:sGraphRequest];
		[[HypFacebook instance]
			fbRequest:NSReq
			HTTPMethod:[ [NSString alloc] initWithUTF8String:sHttpMethod]
			parameters:_getDictFromStrings( sParamsName, sParamsVal )];
	}

	void dialog( const char *sDialog, const char *sParamsName , const char *sParamsVal ) {
		[[HypFacebook instance] presentDialog:[ [NSString alloc] initWithUTF8String:sDialog]
								withParameters:_getDictFromStrings(sParamsName, sParamsVal)];
	}

	void requestNew_publish_perm( const char *sPerms ){
		[[HypFacebook instance] authorizePublish:_getArrayFromPipeUTF8String(sPerms)];
	}

	void requestNew_read_perm( const char *sPerms ){
		[[HypFacebook instance] authorizeRead:_getArrayFromPipeUTF8String(sPerms)];
	}

	const char* getPermissions( ){
		NSString *perms = [[FBSession.activeSession permissions] componentsJoinedByString:@"|"];
		return [perms UTF8String];
	}

	NSArray* _getArrayFromPipeUTF8String( const char *pipe_string ) {
		NSString *ns_pipe_string = [ [NSString alloc] initWithUTF8String:pipe_string];
		return [ns_pipe_string componentsSeparatedByString:@"|"];
	}

	NSDictionary* _getDictFromStrings( const char *sParamsName, const char *sParamsVal ) {
		return [NSDictionary dictionaryWithObjects:_getArrayFromPipeUTF8String(sParamsVal)
			        forKeys:_getArrayFromPipeUTF8String(sParamsName) ];
	}
}