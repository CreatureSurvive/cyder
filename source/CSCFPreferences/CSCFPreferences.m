//
//  CSCFPreferences.m
//
//  Created by CreatureSurvive on 9/2/18.
//  Copyright (c) 2018 Dana Buehre. All rights reserved.
//

#import "CSCFPreferences.h"

@interface CSCFPreferences ()

@property(nonatomic, copy) NSString *bundleID;
@property(nonatomic, assign) BOOL autoSync;

@end

@implementation CSCFPreferences

#pragma mark - Initialization

- (instancetype)initWithBundleID:(NSString *)bundleID {

    if ((self = [super init])) {
        self.bundleID = bundleID;
    }

    return self;
}

- (instancetype)initWithBundleID:(NSString *)bundleID autoSyncronize:(BOOL)synchronize {

    if ((self = [[CSCFPreferences alloc] initWithBundleID:bundleID])) {
        self.autoSync = synchronize;
    }

    return self;
}

#pragma mark - Synchronization

- (BOOL)synchronize {
    return CFPreferencesSynchronize( (__bridge CFStringRef)self.bundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}

#pragma mark - Convenience

- (id)objectForKey:(NSString *)key {
    if (self.autoSync) {

        [self synchronize];
    }

    CFPropertyListRef value = CFPreferencesCopyValue( (__bridge CFStringRef)key, (__bridge CFStringRef)self.bundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

    id object = nil;

    if (value != NULL) {
        object = (__bridge id)value;
        CFRelease(value);
    }

    return object;
}

- (NSString *)stringForKey:(NSString *)key {

    return [self objectForKey:key];
}

- (BOOL)boolForKey:(NSString *)key {

    id value = [self objectForKey:key] ? : @(NO);
    return [value boolValue];
}

- (float)floatForKey:(NSString *)key {

    id value = [self objectForKey:key] ? : @(0.0f);
    return [value floatValue];
}

- (double)doubleForKey:(NSString *)key {

    id value = [self objectForKey:key] ? : @(0.0);
    return [value doubleValue];
}

- (int)intForKey:(NSString *)key {

    id value = [self objectForKey:key] ? : @(0);
    return [value intValue];
}

- (void)setObject:(id)object forKey:(NSString *)key {
    
    CFPreferencesSetValue((__bridge CFStringRef)key, (__bridge CFPropertyListRef)object, (__bridge CFStringRef)self.bundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (self.autoSync) {

        [self synchronize];
    }
}

@end
