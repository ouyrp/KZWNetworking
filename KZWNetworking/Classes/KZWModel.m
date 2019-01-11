//
//  KZWModel.m
//  LPDCrowdsource
//
//  Created by sq on 15/11/6.
//  Copyright © 2015年 elm. All rights reserved.
//

#import "KZWModel.h"
#import <KZWUtils/KZWUtils.h>

@implementation KZWModel
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dic = [[[self new] propertyToproperty] mutableCopy];
    for (NSString *key in [self mapKey].allKeys) {
        if ([dic.allKeys containsObject:key]) {
            dic[key] = [self mapKey][key];
        }
    }
    for (NSString *key in [self filter]) {
        [dic setValue:nil forKey:key];
    }
    return [dic copy];
}

+ (NSDictionary *)mapKey {
    return nil;
}

+ (NSArray *)filter {
    return nil;
}

- (void)setNilValueForKey:(NSString *)key {
#ifdef DEBUG
    NSLog(@"%@ is nil", key);
#endif
}

@end
