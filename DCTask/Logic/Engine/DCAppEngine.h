//
//  DCAppEngine.h
//  DCTask
//
//  Created by 青秀斌 on 16/9/11.
//  Copyright © 2016年 kylincc. All rights reserved.
//

#import "AppEngine.h"
#import "DCSyncManager.h"

@interface DCAppEngine : AppEngine
@property (nonatomic, readonly) DCSyncManager *syncManager;

+ (instancetype)shareEngine;

@end