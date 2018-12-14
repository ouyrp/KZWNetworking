//
//  NSError+KZWNetworking.h
//  AFNetworking
//
//  Created by yang ou on 2018/12/14.
//

#import <Foundation/Foundation.h>

static NSString *KZWNetworkErrorDomain = @"KZWNetworkErrorDomain";

static NSString *KZWNetworkUserMessage = @"userErrorMessage";

static NSString *KZWNetworkBusinessErrorCode = @"businessErrorCode";

typedef NS_ENUM(NSUInteger, KZWNeteworkErrorCode) {
    KZWNeteworkResponseDataError = 1000,
    KZWNeteworkBusinessError = 10001,
    KZWNeteworkError = 10002
};

NS_ASSUME_NONNULL_BEGIN

@interface NSError (KZWNetworking)

/**
 *  用户错误提示信息
 *
 *
 */
- (NSString *)message;

/**
 *  用户业务逻辑错误信息
 *
 *
 */
- (NSString *)businessMessage;

/**
 *  用户业务逻辑错误信息
 *
 *  @param defaultMessage 当用户业务逻辑错误信息 是空的时候，返回默认值
 *
 *
 */
- (NSString *)businessMessage:(NSString *)defaultMessage;


/**
 *  用户业务逻辑错误code
 *
 *
 */
- (NSString *)businessErrorCode;

@end

NS_ASSUME_NONNULL_END
