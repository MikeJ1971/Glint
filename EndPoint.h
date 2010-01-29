//
//  EndPoint.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 29/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EndPoint : NSObject {

    NSString *endPointURL;
}

@property(copy,nonatomic) NSString *endPointURL;

@end
