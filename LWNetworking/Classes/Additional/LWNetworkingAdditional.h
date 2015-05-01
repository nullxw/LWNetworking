//
//  LWNetworkingAdditional.h
//  LWNetworking
//
//  Created by 李巍 on 15/4/15.
//  Copyright (c) 2015年 李巍. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWNetworkingAdditional : NSObject

/*!
 *  @brief  服务器Code管理对象单例
 *
 *  @return 服务器Code管理对象TFServerCodeManager实例
 */
+ (instancetype)sharedInstance;

/*!
 *  @author 李巍, 2015-05-01
 *
 *  @brief  code
 */
@property (strong, nonatomic) NSString *jsonCodeParam;

/*!
 *  @author 李巍, 2015-05-01
 *
 *  @brief  success code value
 */
@property (strong, nonatomic) NSString *jsonCodeSuccessValue;

/*!
 *  @author 李巍, 2015-05-01
 *
 *  @brief  data
 */
@property (strong, nonatomic) NSString *jsonDataParam;

/*!
 *  @author 李巍, 2015-05-01
 *
 *  @brief  msg
 */
@property (strong, nonatomic) NSString *jsonErrorMessageParam;


/*!
 *  @author Megatron, 2015-04-15
 *
 *  @brief  设置服务器地址
 *
 *  @param domain 地址
 */
- (void)setupWithServerDomain:(NSString *)domain;

/*!
 *  @brief  GET,POST,Upload请求结果处理方法
 *
 *  @param result 处理完毕返回Block
 */
- (id (^)(id task, id responseObject))validSuccess:(id)result;

///*!
// *  @brief  Download请求结果处理方法
// *
// *  @param success 处理完毕返回Block
// */
//- (void (^)(id responseObject, NSURL *filePath))validSuccessDownloadBlock:(void (^)(id downloadTask, id responseObject, NSURL *filePath))result;

@end





#pragma mark -


@interface LWUploadFileModel : NSObject

/*!
 *  @author Megatron, 2015-01-21
 *
 *  @brief  文件名
 */
@property (nonatomic, strong) NSString *name;

/*!
 *  @author Megatron, 2015-01-21
 *
 *  @brief  文件本地路径
 */
@property (nonatomic, strong) NSString *path;

/*!
 *  @author Megatron, 2015-01-21
 *
 *  @brief  上传文件时文件数据流的上传参数
 */
@property (nonatomic, strong) NSString *paramName;

/*!
 *  @author Megatron, 2015-01-21
 *
 *  @brief  文件MIMEType
 */
@property (nonatomic, strong) NSString *mimeType;

@end