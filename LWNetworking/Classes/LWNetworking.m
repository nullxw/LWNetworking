//
//  LWNetworking.m
//  LWNetworking
//
//  Created by 李巍 on 15/4/15.
//  Copyright (c) 2015年 李巍. All rights reserved.
//

#import "LWNetworking.h"
#import "LWNetworkingAdditional.h"

#import <AFNetworking/AFNetworking.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define NETWORK_NOT_REACHABLITY_PROMPT @"网络不给力"

@interface LWNetworking ()

@property (nonatomic, assign) NSTimeInterval timeout;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

#pragma mark -

@implementation LWNetworking

static NSString * const AFNetworkingSingletonIdentifier = @"LWNetworkingSingleton";

+ (instancetype)sharedInstance {
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init];
	});
	return _sharedObject;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		
	}
	return self;
}

- (void)setupWithServerDomain:(NSString *)domain {
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	if ([NSURLSessionConfiguration resolveClassMethod:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
		sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LWNetworkingSingleton"];
	}
	self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:domain] sessionConfiguration:sessionConfig];
	self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
	[self.sessionManager.reachabilityManager startMonitoring];
	
	[self.sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		switch (status) {
			case AFNetworkReachabilityStatusNotReachable:{
				DDLogError(@"网络不通");
				break;
			}
			case AFNetworkReachabilityStatusReachableViaWiFi:{
				DDLogDebug(@"网络通过WIFI连接");
				break;
			}
				
			case AFNetworkReachabilityStatusReachableViaWWAN:{
				DDLogDebug(@"网络通过无线连接");
				break;
			}
			default:
				break;
		}		
	}];
	
	[[LWNetworkingAdditional sharedInstance] setupWithServerDomain:domain];
}

#pragma mark -

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	[self.sessionManager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		
		id (^resultBlock)(NSURLSessionDataTask *resultTask, id resultObject) = [[LWNetworkingAdditional sharedInstance] validSuccess:responseObject];
		
		if ([resultBlock(task, responseObject) isKindOfClass:[NSError class]]) {
			NSError *error = resultBlock(task, responseObject);
			failure(task, error);
		}else {
			success(task, resultBlock(task, responseObject));
		}
	} failure:failure];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters
	 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
	 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	[self.sessionManager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
		id (^resultBlock)(NSURLSessionDataTask *resultTask, id resultObject) = [[LWNetworkingAdditional sharedInstance] validSuccess:responseObject];
		
		if ([resultBlock(task, responseObject) isKindOfClass:[NSError class]]) {
			NSError *error = resultBlock(task, responseObject);
			failure(task, error);
		}else {
			success(task, resultBlock(task, responseObject));
		}
	} failure:failure];
}

#pragma mark -

- (void)cleanRequestTasks {
	[self.sessionManager.operationQueue cancelAllOperations];
	for (NSURLSessionTask *task in self.sessionManager.tasks) {
		[task cancel];
	}
}

- (void)setCheckReachability:(BOOL)checkReachability {
	_checkReachability = checkReachability;
}

- (BOOL)checkReachability:(void (^)(id task, NSError *error))failure  {
	if (![self.sessionManager.reachabilityManager isReachable]) {
		NSError *error = [NSError errorWithDomain:[[self.sessionManager baseURL] absoluteString] code:NSURLErrorCannotConnectToHost userInfo:@{[LWNetworkingAdditional sharedInstance].jsonErrorMessageParam:NETWORK_NOT_REACHABLITY_PROMPT}];
		if (failure) {
			failure(nil, error);
		}
		return NO;
	}
	return YES;
}

#pragma mark - upload

#pragma mark -

- (void)uploadWithURL:(NSString *)urlString
		withFileModel:(LWUploadFileModel *)fileModel
		   parameters:(id)parameters
			 progress:(NSProgress * __autoreleasing *)progress
			  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	
	//	[self.sessionManager uploadTaskWithRequest:<#(NSURLRequest *)#> fromFile:fileModel.path progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
	//
	//	}];
	
	//	//test//
	//	NSURLRequest *uploadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString relativeToURL:self.sessionManager.baseURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
	//	[self.sessionManager uploadTaskWithRequest:uploadRequest fromFile:[NSURL fileURLWithPath:fileModel.path] progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
	//		if (error) {
	//			if (failure) {
	//				failure(task, error);
	//			}
	//		} else {
	//			if (success) {
	//				[[TFServerCodeManager sharedInstance] validSuccessDownloadBlock:success](task, response, filePath);
	//			}
	//		}
	//	}];
	//	// // //
	
	[self.sessionManager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		[formData appendPartWithFileData:[NSData dataWithContentsOfFile:fileModel.path] name:fileModel.paramName fileName:fileModel.name mimeType:fileModel.mimeType];
	} success:^(NSURLSessionDataTask *task, id responseObject) {
		id (^resultBlock)(NSURLSessionDataTask *resultTask, id resultObject) = [[LWNetworkingAdditional sharedInstance] validSuccess:responseObject];
		if ([resultBlock(task, responseObject) isKindOfClass:[NSError class]]) {
			NSError *error = resultBlock(task, responseObject);
			failure(task, error);
		}else {
			success(task, resultBlock(task, responseObject));
		}
	} failure:failure];
}

- (void)uploadWithURL:(NSString *)urlString
	   withFileModels:(NSArray *)fileArray
		   parameters:(id)parameters
			 progress:(NSProgress * __autoreleasing *)progress
			  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	[self.sessionManager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
		for (LWUploadFileModel *fileModel in fileArray) {
			[formData appendPartWithFileData:[NSData dataWithContentsOfFile:fileModel.path] name:fileModel.paramName fileName:fileModel.name mimeType:fileModel.mimeType];
		}
	} success:^(NSURLSessionDataTask *task, id responseObject) {
		id (^resultBlock)(NSURLSessionDataTask *resultTask, id resultObject) = [[LWNetworkingAdditional sharedInstance] validSuccess:responseObject];
		if ([resultBlock(task, responseObject) isKindOfClass:[NSError class]]) {
			NSError *error = resultBlock(task, responseObject);
			failure(task, error);
		}else {
			success(task, resultBlock(task, responseObject));
		}
	} failure:failure];
}


#pragma mark - download

- (void)downloadWithURL:(NSString *)urlString
			   progress:(NSProgress * __autoreleasing *)progress
			destination:(NSString *)path
				success:(void (^)(NSURLSessionDownloadTask *task, NSURLResponse *response, NSURL *filePath))success
				failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure {
	
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		// 指定下载文件保存的路径
		//        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
		// 将下载文件保存在缓存路径中
		NSURL *url = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"tmp"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:[url absoluteString]]) {
			NSError *error = nil;
			[[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
			if (error) {
				NSLog(@"创建文件夹失败= %@", error);
			}
		}
		return [url URLByAppendingPathComponent:response.suggestedFilename];
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		//        NSLog(@"%@ %@", filePath, error);
		if (error) {
			if (failure) {
				failure(nil,error);
			}
		}else{
			if (success) {
				success(nil,response,filePath);
			}
		}
	}];
	[task resume];
}
- (void)DOWNLOADWithURL:(NSString *)urlString progress:(NSProgress *__autoreleasing *)progress destination:(NSURL *)URLPath success:(void (^)(NSURLSessionDownloadTask *, NSURLResponse *, NSURL *))success failure:(void (^)(NSURLSessionDownloadTask *, NSError *))failure{
	
	if (![self checkReachability:failure] && _checkReachability) {
		return;
	}
	
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		return  [URLPath URLByAppendingPathComponent:response.suggestedFilename];
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		//        NSLog(@"%@ %@", filePath, error);
		if (error) {
			if (failure) {
				failure(nil,error);
			}
		}else{
			if (success) {
				success(nil,response,filePath);
			}
		}
	}];
	
	
	//   NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
	//       NSString *fileName = [[urlString componentsSeparatedByString:@"/"] lastObject];
	//        return [NSURL fileURLWithPath:[path stringByAppendingString:fileName]];
	//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
	//        if (error) {
	//            if (failure) {
	//                failure(nil,error);
	//            }
	//        }else{
	//            if (success) {
	//                success(nil,response,filePath);
	//            }
	//        }
	//
	//    }];
	[task resume];
}
- (void)sessionDownload
{
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
	AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
	
	NSString *urlString = @"";
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		// 指定下载文件保存的路径
		//        NSLog(@"%@ %@", targetPath, response.suggestedFilename);
		// 将下载文件保存在缓存路径中
		NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
		NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
		
		// URLWithString返回的是网络的URL,如果使用本地URL,需要注意
		NSURL *fileURL1 = [NSURL URLWithString:path];
		NSURL *fileURL = [NSURL fileURLWithPath:path];
		
		NSLog(@"== %@ |||| %@", fileURL1, fileURL);
		
		return fileURL;
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		NSLog(@"%@ %@", filePath, error);
	}];
	
	[task resume];
}

@end
