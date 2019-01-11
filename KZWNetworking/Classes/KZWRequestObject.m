//
//  LPDRequestObject.m
//  LPDCrowdsource
//
//  Created by sq on 15/11/4.
//  Copyright © 2015年 elm. All rights reserved.
//

#import "KZWRequestObject.h"
#import "NSError+KZWNetworking.h"
#import <KZWUtils/KZWUtils.h>
#import <Mantle/MTLJSONAdapter.h>

@interface KZWRequestObject ()
@property (nonatomic, copy) KZWRequestComplete complete;
@end

@implementation KZWRequestObject

- (void)startRequestComplete:(KZWRequestComplete)complete
                    progress:(nullable void (^)(NSProgress *_Nonnull uploadProgress))progress {
    self.complete = complete;
    switch (self.method) {
        case KZWHTTPMethodGet: {
            _task = [KZWHttpManager GET:self.path
                             parameters:self.params
                      completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                          [self handleInMainThread:task responseObject:responseObject error:error];
                      }];
        } break;
        case KZWHTTPMethodPut: {
            _task = [KZWHttpManager PUT:self.path
                             parameters:self.params
                      completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                          [self handleInMainThread:task responseObject:responseObject error:error];
                      }];
        } break;
        case KZWHTTPMethodPost: {
            _task = [KZWHttpManager POST:self.path parameters:self.params completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                [self handleInMainThread:task responseObject:responseObject error:error];
            }];
        } break;
        case KZWHTTPMethodDelete: {
            _task = [KZWHttpManager DELETE:self.path
                                parameters:self.params
                         completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                             [self handleInMainThread:task responseObject:responseObject error:error];
                         }];
        } break;
        case KZWHTTPMethodImage: {
            if (self.images) {
                _task = [KZWHttpManager POST:self.path
                    parameters:self.params
                    images:self.images
                    completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                        [self handleInMainThread:task responseObject:responseObject error:error];
                    }
                    progress:^(NSProgress *_Nonnull uploadProgress) {
                        if (progress) {
                            progress(uploadProgress);
                        }
                    }];
            } else if (self.image) {
                _task = [KZWHttpManager POST:self.path parameters:self.params image:self.image imageName:self.imageName completionHandler:^(NSURLSessionDataTask *_Nonnull task, id _Nonnull responseObject, NSError *_Nonnull error) {
                    [self handleInMainThread:task responseObject:responseObject error:error];
                } progress:^(NSProgress *_Nonnull uploadProgress) {
                    if (progress) {
                        progress(uploadProgress);
                    }
                }];
            }

        } break;
        default:
            break;
    }
}

- (void)startRequestComplete:(KZWRequestComplete)complete {
    [self startRequestComplete:complete progress:nil];
}

- (void)cancel {
    [_task cancel];
}

- (NSDictionary *)params {
    NSMutableDictionary *propertyParams = [NSMutableDictionary dictionaryWithDictionary:[self propertyDictionary]];
    if ([self mapKey].allKeys.count != 0) {
        for (NSString *key in [self mapKey].allKeys) {
            if (propertyParams[key]) {
                [propertyParams setObject:propertyParams[key] forKey:[self mapKey][key]];
                [propertyParams removeObjectForKey:key];
            }
        }
    }

    return propertyParams.count == 0 ? nil : [propertyParams copy];
}

- (NSDictionary *)mapKey {
    return nil;
}

- (NSString *)className {
    return _className;
}

- (NSDictionary *)paramDic {
    return [self params];
}

- (void)handleInMainThread:(NSURLSessionDataTask *)task responseObject:(id)responseObject error:(NSError *)error {
    if ([[NSThread currentThread] isMainThread]) {
        [self handleRespondse:task responseObject:responseObject error:error];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self handleRespondse:task responseObject:responseObject error:error];
        });
    }
}

- (void)handleRespondse:(NSURLSessionDataTask *)response responseObject:(id)responseObject error:(NSError *)error {
#if DEBUG
    [KZWDebugService setCurrentDebug:responseObject];
    [KZWDebugService saveDebug];
#endif
    if (self.complete) {
        if (error) {
            self.complete(nil, error);
            return;
        }
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            id code = ((NSDictionary *)responseObject)[@"code"];
            if ([code isKindOfClass:[NSString class]]) {
                if ([code integerValue] == 0) {
                    NSError *parseError = nil;
                    if (!self.className) {
                        self.complete(responseObject[@"data"], nil);
                        return;
                    }

                    if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {

                        if (!self.className) {
                            self.complete(responseObject, nil);
                            return;
                        }

                        NSError *parseError = nil;
                        NSArray *object = [MTLJSONAdapter modelsOfClass:NSClassFromString(self.className)
                                                          fromJSONArray:responseObject[@"data"]
                                                                  error:&parseError];
                        if (parseError) {
                            self.complete(nil, [NSError errorWithDomain:KZWNetworkErrorDomain
                                                                   code:KZWNeteworkBusinessError
                                                               userInfo:@{
                                                                   KZWNetworkUserMessage : @"数据格式不正确"
                                                               }]);
                            return;
                        }
                        self.complete(object, nil);
                        return;
                    }

                    id object = [MTLJSONAdapter modelOfClass:NSClassFromString(self.className)
                                          fromJSONDictionary:responseObject[@"data"]
                                                       error:&parseError];
                    if (parseError) {
                        self.complete(nil, [NSError errorWithDomain:KZWNetworkErrorDomain
                                                               code:KZWNeteworkBusinessError
                                                           userInfo:@{
                                                               KZWNetworkUserMessage : @"数据格式不正确"
                                                           }]);
                        ;
                        return;
                    }
                    self.complete(object, nil);
                    return;
                }

                NSString *message = ((NSDictionary *)responseObject)[@"message"] ? ((NSDictionary *)responseObject)[@"message"] : @"未知错误";

                NSError *logicError = [NSError errorWithDomain:KZWNetworkErrorDomain
                                                          code:KZWNeteworkBusinessError
                                                      userInfo:@{
                                                          KZWNetworkUserMessage : message,
                                                          KZWNetworkBusinessErrorCode : code ? code : @"unknow"
                                                      }];
                self.complete(nil, logicError);
                return;
            }
            NSError *dataError = [NSError errorWithDomain:KZWNetworkErrorDomain
                                                     code:KZWNeteworkBusinessError
                                                 userInfo:@{
                                                     KZWNetworkUserMessage : @"数据格式不正确"
                                                 }];
            self.complete(nil, dataError);
            return;
        } else if ([responseObject isKindOfClass:[NSArray class]]) {
            if (!self.className) {
                self.complete(responseObject, nil);
                return;
            }
            NSError *parseError = nil;
            NSArray *object =
                [MTLJSONAdapter modelsOfClass:NSClassFromString(self.className) fromJSONArray:responseObject[@"data"] error:&parseError];
            if (parseError) {
                self.complete(nil, [NSError errorWithDomain:KZWNetworkErrorDomain
                                                       code:KZWNeteworkBusinessError
                                                   userInfo:@{
                                                       KZWNetworkUserMessage : @"数据格式不正确"
                                                   }]);
                return;
            }
            self.complete(object, nil);
        }
    }
}

@end
