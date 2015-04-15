//
//  LWNetworking.h
//  LWNetworking
//
//  Created by 李巍 on 15/4/15.
//  Copyright (c) 2015年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LWUploadFileModel;

@interface LWNetworking : NSObject

/*!
 *  @brief  网络管理对象单例
 *
 *  @return 网络请求对象TFNetworking实例
 */
+ (instancetype)sharedInstance;

/*!
 *  @author Megatron, 2015-04-15
 *
 *  @brief  设置服务器地址
 *
 *  @param domain 地址
 */
- (void)setupWithServerDomain:(NSString *)domain;

/*!
 *  @brief  GET方式请求接口
 *
 *  @param URLString  接口拼接地址
 *  @param parameters GET参数
 *  @param success    请求成功
 *  @param failure    请求失败
 */
- (void)GET:(NSString *)URLString parameters:(id)parameters
	success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
	failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/*!
 *  @brief  POST方式请求接口
 *
 *  @param URLString  接口拼接地址
 *  @param parameters POST参数
 *  @param success    请求成功
 *  @param failure    请求失败
 */
- (void)POST:(NSString *)URLString parameters:(id)parameters
	 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
	 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


/*!
 *  @author Megatron, 2015-01-20
 *
 *  @brief  单个文件上传接口
 *
 *  @param urlString  上传地址
 *  @param fileModel  单个文件数据模型(TFUploadFileModel)
 *  @param parameters 附加参数
 *  @param progress   进度条对象
 *  @param success    上传成功操作块
 *  @param failure    上传失败操作块
 */
- (void)uploadWithURL:(NSString *)urlString
		withFileModel:(LWUploadFileModel *)fileModel
		   parameters:(id)parameters
			 progress:(NSProgress * __autoreleasing *)progress
			  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/*!
 *  @author Megatron, 2015-01-20
 *
 *  @brief  多个文件上传接口
 *
 *  @param urlString  上传地址
 *  @param fileArray  多个文件数据模型(TFUploadFileModel)
 *  @param parameters 附加参数
 *  @param progress   进度条对象
 *  @param success    上传成功操作块
 *  @param failure    上传失败操作块
 */
- (void)uploadWithURL:(NSString *)urlString
	   withFileModels:(NSArray *)fileArray
		   parameters:(id)parameters
			 progress:(NSProgress * __autoreleasing *)progress
			  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
			  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/*!
 *  @brief  下载文件接口
 *
 *  @param urlString         下载地址
 *  @param progress          进度条对象
 *  @param path              下载后存储路径
 *  @param completionHandler 下载后操作
 */
- (void)downloadWithURL:(NSString *)urlString
			   progress:(NSProgress * __autoreleasing *)progress
			destination:(NSString *)path
				success:(void (^)(NSURLSessionDownloadTask *task, NSURLResponse *response, NSURL *filePath))success
				failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;



- (void)DOWNLOADWithURL:(NSString *)urlString
			   progress:(NSProgress *__autoreleasing *)progress
			destination:(NSURL *)URLPath
				success:(void (^)(NSURLSessionDownloadTask *, NSURLResponse *, NSURL *))success
				failure:(void (^)(NSURLSessionDownloadTask *, NSError *))failure;


/*!
 *  @brief  取消当前所有网络请求任务
 */
- (void)cleanRequestTasks;

@end
