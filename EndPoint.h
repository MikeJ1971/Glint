//
//  EndPoint.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 29/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EndPoint : NSObject <NSCoding> {

    NSString *endPointURL;
    NSString *queryParamName;
    NSString *httpMethod;
}

@property(retain,nonatomic) NSString *endPointURL;
@property(retain,nonatomic) NSString *queryParamName;
@property(retain,nonatomic) NSString *httpMethod;

@end
