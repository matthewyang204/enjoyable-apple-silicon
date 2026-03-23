//
//  NJInputPathElement.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#include "NJInputPathElement.h"

@implementation NJInputPathElement {
    NSString *_eid;
}

- (id)initWithName:(NSString *)name
               eid:(NSString *)eid
            parent:(NJInputPathElement *)parent {
    self = [super init];
    if (self) {
        self.name = name;
        self.parent = parent;
        _eid = eid;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJInputPathElement.class]
        && [[object uid] isEqualToString:self.uid];
}

- (NSUInteger)hash {
    return self.uid.hash;
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@~%@", _parent.uid, _eid];
}

- (NSArray *)uidAliases {
    if (!_parent || !_eid.length) {
        return self.uid ? @[self.uid] : @[];
    }

    NSMutableOrderedSet *uids = [[NSMutableOrderedSet alloc] init];
    for (NSString *parentUID in _parent.uidAliases) {
        if (parentUID.length) {
            [uids addObject:[NSString stringWithFormat:@"%@~%@", parentUID, _eid]];
        }
    }
    return uids.array;
}

- (NJInputPathElement *)elementForUID:(NSString *)uid {
    BOOL canContainUID = NO;
    for (NSString *candidate in self.uidAliases) {
        if ([uid isEqualToString:candidate]) {
            return self;
        }
        if ([uid hasPrefix:[candidate stringByAppendingString:@"~"]]) {
            canContainUID = YES;
        }
    }

    if (!canContainUID) {
        return nil;
    }

    for (NJInputPathElement *elem in self.children) {
        NJInputPathElement *ret = [elem elementForUID:uid];
        if (ret) {
            return ret;
            }
    }
    return nil;
}

@end
