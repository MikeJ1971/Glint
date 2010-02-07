//
//  AddEndPointDelegate.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 01/02/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol AddEndPointDelegate

- (void)addEndPointToArrayList:(EndPoint *)endPoint;

- (void)replaceEndpointInArrayWith:(EndPoint *)endPoint atIndex:(NSInteger)index;

@end
