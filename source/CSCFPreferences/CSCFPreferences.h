//
//  CSCFPreferences.h
//
//  Created by CreatureSurvive on 9/2/18.
//  Copyright (c) 2018 Dana Buehre. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSCFPreferences : NSObject

// Initialization

- (instancetype)initWithBundleID:(NSString *)bundleID;
- (instancetype)initWithBundleID:(NSString *)bundleID autoSyncronize:(BOOL)synchronize;

// Syncronization

- (BOOL)synchronize;

// Convenience
- (id)objectForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;

- (void)setObject:(id)object forKey:(NSString *)key;

@end
