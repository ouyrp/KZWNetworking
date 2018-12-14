//
//  NSError+KZWNetworking.m
//  AFNetworking
//
//  Created by yang ou on 2018/12/14.
//

#import "NSError+KZWNetworking.h"

@implementation NSError (KZWNetworking)

- (NSString *)message {
    NSDictionary *userInfo = self.userInfo;
    return userInfo[KZWNetworkUserMessage] ? userInfo[KZWNetworkUserMessage] : @"服务异常";
}

- (NSString *)businessMessage {
    if (self.code == KZWNeteworkBusinessError) {
        NSDictionary *userInfo = self.userInfo;
        return userInfo[KZWNetworkUserMessage];
    }
    return nil;
}

- (NSString *)businessMessage:(NSString *)defaultMessage {
    if (self.code == KZWNeteworkBusinessError) {
        NSDictionary *userInfo = self.userInfo;
        return userInfo[KZWNetworkUserMessage];
    }
    return defaultMessage;
}

- (NSString *)businessErrorCode {
    if (self.code == KZWNeteworkBusinessError) {
        NSDictionary *userInfo = self.userInfo;
        return userInfo[KZWNetworkBusinessErrorCode];
    }
    return nil;
}

@end
