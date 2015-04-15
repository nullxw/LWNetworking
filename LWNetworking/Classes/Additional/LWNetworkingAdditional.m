//
//  LWNetworkingAdditional.m
//  LWNetworking
//
//  Created by 李巍 on 15/4/15.
//  Copyright (c) 2015年 李巍. All rights reserved.
//

#import "LWNetworkingAdditional.h"

@implementation LWNetworkingAdditional
{
	NSString *serverDomain;
}

+ (instancetype)sharedInstance {
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init];
	});
	return _sharedObject;
}

- (void)setupWithServerDomain:(NSString *)domain {
	serverDomain = [domain copy];
}

#pragma mark - Networking

- (id (^)(id task, id responseObject))validSuccess:(id)result {
	NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:[self formatJSONRespone:result]];
	id (^resultBlock)(id task, id responseObject)  = ^(id task, id responseObject) {
		if ([resultDic[@"code"] isEqualToString:@"200"]) {
			//			return result[@"data"];
			return result;
		}else {
			return (id)[NSError errorWithDomain:serverDomain code:[result[@"code"] integerValue] userInfo:@{@"msg":result[@"msg"]}];
		}
	};
	return resultBlock;
}

//- (void (^)(id responseObject, NSURL *filePath))validSuccessDownloadBlock:(void (^)(id downloadTask, id responseObject, NSURL *filePath))result {
//	void (^resultBlock)(id, NSURL *) = ^(id responseObject, NSURL *filePath) {
//		NSMutableDictionary *resultJson = [NSMutableDictionary dictionaryWithDictionary:[self formatJSONRespone:responseObject]];
//		if ([resultJson[@"code"] isEqualToString:@"200"]) {
//			return resultBlock(resultJson[@"data"], filePath);
//		}else {
//			return resultBlock(resultJson[@"msg"], filePath);
//		}
//	};
//	
//	
////	void (^resultBlock)(id responseObject, NSURL *filePath)  = ^(id responseObject, NSURL *filePath) {
////		NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self formatJSONRespone:responseObject]];
////		if ([result[@"code"] isEqualToString:@"200"]) {
////			return resultBlock(result[@"data"], filePath);
////		}else {
////			return resultBlock(result[@"msg"], filePath);
////		}
////	};
//	return resultBlock;
//}

- (NSDictionary *)formatJSONRespone:(id)responseObject {
	if (![responseObject isKindOfClass:[NSDictionary class]]) {
		Class class = [responseObject class];
		NSLog(@"network response class === %@", class);
		//处理非json类型返回数据
		if (class == [NSData class]) {
			NSError *error = nil;
			NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
			if (!error) {
				return responseDic;
			}else {
				NSLog(@"format json error === %@", [error localizedDescription]);
				return nil;
			}
		}else {
			NSLog(@"un support response data type");
			return nil;
		}
	}
	return responseObject;
}

@end


#pragma mark -


@implementation LWUploadFileModel

@synthesize name;
@synthesize path;
@synthesize paramName;
@synthesize mimeType;

@end
