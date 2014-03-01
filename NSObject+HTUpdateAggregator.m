//
//  NSObject(HTUpdateAggregator)                                                                                             
//  HotelTonight
//
//  Created by Jonathan Sibley on 2/28/13.
//  Copyright (c) 2013 HotelTonight
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSObject+HTUpdateAggregator.h"
#import "FBKVOController.h"
#import <objc/runtime.h>

static char const *kUpdateNeededKey;
static char const *kKVOControllerKey;

@interface NSObject (HTUpdateAggregatorPrivate)

@end

@implementation NSObject (HTUpdateAggregator)

- (void)startObservingForUpdates
{
    if ([self conformsToProtocol:@protocol(HTUpdatable)])
    {
        if ([[self class] respondsToSelector:@selector(keyPathsToTriggerUpdate)])
        {
            __weak NSObject *wSelf = self;
            id<HTUpdatable> updatableClass = (id<HTUpdatable>)[self class];

            for (NSString *keyPath in [updatableClass keyPathsToTriggerUpdate]) {
                [self.htUpdateAggregatorKvoController observe:self keyPath:keyPath options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
                    [wSelf setNeedsUpdate];
                }];
            }
        }
    }
}

- (void)setNeedsUpdate
{
    [self performSelector:@selector(updateContentInternal)
               withObject:nil
               afterDelay:0];
    objc_setAssociatedObject(self, &kUpdateNeededKey, (id)kCFBooleanTrue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateContentInternal
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(updateContentInternal)
                                               object:nil];
    if ([self respondsToSelector:@selector(updateContent)])
    {
        [(id<HTUpdatable>)self updateContent];
    }
    objc_setAssociatedObject(self, &kUpdateNeededKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateContentIfNeeded
{
    if ([objc_getAssociatedObject(self, &kUpdateNeededKey) boolValue])
    {
        [self updateContentInternal];
    }
}

- (FBKVOController *)htUpdateAggregatorKvoController {
    FBKVOController *kvoController = objc_getAssociatedObject(self, kKVOControllerKey);
    if (!kvoController) {
        kvoController = [FBKVOController controllerWithObserver:self];
        objc_setAssociatedObject(self, kKVOControllerKey, kvoController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return kvoController;
}

@end
