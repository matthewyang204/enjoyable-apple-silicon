//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "Config.h"

#import "JSAction.h"

@implementation Config

- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        self.name = name;
        _entries = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (Target *)objectForKeyedSubscript:(JSAction *)action {
    return action ? _entries[action.uid] : nil;
}

- (void)setObject:(Target *)target forKeyedSubscript:(JSAction *)action {
    if (action) {
        if (target)
            _entries[action.uid] = target;
        else
            [_entries removeObjectForKey:action.uid];
    }
}

@end
