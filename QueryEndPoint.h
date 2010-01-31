//
//  QueryEndPoint.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 31/01/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EndPoint.h"

@interface QueryEndPoint : NSObject {

}

- (NSString *)queryEndPoint:(EndPoint *)endPoint withSparql:(NSString *)sparql
               resultsFormat:(NSString *)format;


@end
