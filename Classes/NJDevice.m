//
//  NJDevice.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "NJDevice.h"

#import "NJInput.h"
#import "NJInputAnalog.h"
#import "NJInputHat.h"
#import "NJInputButton.h"
#import <IOKit/IOKitLib.h>

static NSString *IdentifierComponent(id value) {
    NSString *string = nil;
    if ([value isKindOfClass:NSString.class]) {
        string = value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        string = [(NSNumber *)value stringValue];
    }

    if (!string.length) {
        return @"";
    }

    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    string = [string stringByReplacingOccurrencesOfString:@"~" withString:@"_"];
    return string;
}

static NSArray *InputsForElement(IOHIDDeviceRef device, id parent) {
    CFArrayRef elements = IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:CFArrayGetCount(elements)];
    
    int buttons = 0;
    int axes = 0;
    int hats = 0;
    
    for (CFIndex i = 0; i < CFArrayGetCount(elements); i++) {
        IOHIDElementRef element = (IOHIDElementRef)CFArrayGetValueAtIndex(elements, i);
        IOHIDElementType type = IOHIDElementGetType(element);
        uint32_t usage = IOHIDElementGetUsage(element);
        uint32_t usagePage = IOHIDElementGetUsagePage(element);
        CFIndex max = IOHIDElementGetPhysicalMax(element);
        CFIndex min = IOHIDElementGetPhysicalMin(element);
        
        NJInput *input = nil;
        
        if (!(type == kIOHIDElementTypeInput_Misc
              || type == kIOHIDElementTypeInput_Axis
              || type == kIOHIDElementTypeInput_Button)) {
            continue;
        }
        
        if (max - min == 1
            || usagePage == kHIDPage_Button
            || type == kIOHIDElementTypeInput_Button) {
            input = [[NJInputButton alloc] initWithElement:element
                                                     index:++buttons
                                                    parent:parent];
        } else if (usage == kHIDUsage_GD_Hatswitch) {
            input = [[NJInputHat alloc] initWithElement:element
                                                  index:++hats
                                                 parent:parent];
        } else if (usage >= kHIDUsage_GD_X && usage <= kHIDUsage_GD_Rz) {
            input = [[NJInputAnalog alloc] initWithElement:element
                                                     index:++axes
                                                    parent:parent];
        } else if (usage >= kHIDUsage_GD_DPadUp && usage <= kHIDUsage_GD_DPadLeft) {
            input = [[NJInputButton alloc] initWithElement:element
                                                     index:++buttons
                                                    parent:parent];
        } else {
            NSLog(@"un-handled input %d", usage);
            continue;
        }
        
        [children addObject:input];
    }

    CFRelease(elements);
    return children;
}

@implementation NJDevice {
    int _vendorId;
    int _productId;
    NSString *_identifierPrefix;
    NSString *_legacyIdentifierPrefix;
}

- (id)initWithDevice:(IOHIDDeviceRef)dev {
    NSString *name = (__bridge NSString *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductKey));
    self = [super initWithName:name eid:nil parent:nil];
    if (self) {
        self.device = dev;
        _vendorId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDVendorIDKey)) intValue];
        _productId = [(__bridge NSNumber *)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDProductIDKey)) intValue];
        NSString *transport = IdentifierComponent((__bridge id)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDTransportKey)));
        NSString *manufacturer = IdentifierComponent((__bridge id)IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDManufacturerKey)));
        NSString *product = IdentifierComponent(name);
        _identifierPrefix = [[NSString alloc] initWithFormat:@"%d:%d:%@:%@:%@",
                             _vendorId, _productId, transport, manufacturer, product];
        _legacyIdentifierPrefix = [[NSString alloc] initWithFormat:@"%d:%d", _vendorId, _productId];
        self.children = InputsForElement(dev, self);
        self.index = 1;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:NJDevice.class]
        && [[(NJDevice *)object name] isEqualToString:self.name];
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ #%d", super.name, _index];
}

- (NSString *)uid {
    return [NSString stringWithFormat:@"%@:%d", _identifierPrefix, _index];
}

- (NSArray *)uidAliases {
    NSString *uid = self.uid;
    NSString *legacyUID = [NSString stringWithFormat:@"%@:%d", _legacyIdentifierPrefix, _index];
    if ([uid isEqualToString:legacyUID]) {
        return uid ? @[uid] : @[];
    }
    return uid ? @[uid, legacyUID] : @[legacyUID];
}

- (NJInput *)findInputByCookie:(IOHIDElementCookie)cookie {
    for (NJInput *child in self.children) {
        if (child.cookie == cookie) {
            return child;
        }
    }
    return nil;
}

- (NJInput *)handlerForEvent:(IOHIDValueRef)value {
    NJInput *mainInput = [self inputForEvent:value];
    return [mainInput findSubInputForValue:value];
}

- (NJInput *)inputForEvent:(IOHIDValueRef)value {
    IOHIDElementRef elt = IOHIDValueGetElement(value);
    IOHIDElementCookie cookie = IOHIDElementGetCookie(elt);
    return [self findInputByCookie:cookie];
}

@end
