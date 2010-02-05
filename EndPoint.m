//
//  EndPoint.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 29/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import "EndPoint.h"


@implementation EndPoint

@synthesize endPointURL;
@synthesize queryParamName;
@synthesize httpMethod;
@synthesize connectionTimeOut;

- (id)initWithCoder:(NSCoder *)coder {
    self.endPointURL = [coder decodeObjectForKey:@"endPointURL"];
    self.queryParamName = [coder decodeObjectForKey:@"queryParamName"];
    self.httpMethod = [coder decodeObjectForKey:@"httpMethod"];
    self.connectionTimeOut = [coder decodeObjectForKey:@"connectionTimeOut"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:endPointURL forKey:@"endPointURL"];
    [coder encodeObject:queryParamName forKey:@"queryParamName"];
    [coder encodeObject:httpMethod forKey:@"httpMethod"];
    [coder encodeObject:connectionTimeOut forKey:@"connectionTimeOut"];
}

@end
