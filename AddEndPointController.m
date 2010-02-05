//
//  AddEndPointController.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 01/02/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import "AddEndPointController.h"
#import "EndPoint.h"

@implementation AddEndPointController

@synthesize sparqlEndPointField;
@synthesize queryParameter;
@synthesize httpMethodField;
@synthesize connectionTimeOutField;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize delegate;

- (id)init {

    if (![super initWithWindowNibName:@"AddEndPoint"]) {
        return nil;
    }
    
    return self;
}

- (IBAction)done:(id)sender {

    EndPoint *endPoint = [[EndPoint alloc] init];
    endPoint.endPointURL = [sparqlEndPointField stringValue];
    endPoint.httpMethod = [httpMethodField titleOfSelectedItem];
    endPoint.queryParamName = [queryParameter stringValue];
    endPoint.connectionTimeOut = [connectionTimeOutField stringValue];
    
    NSLog(@"%@", [sparqlEndPointField stringValue]);
    NSLog(@"Time out here : %@", [connectionTimeOutField stringValue]);
    NSLog(@"Time out here : %@", endPoint.connectionTimeOut);
    

    [delegate addEndPointToArrayList:endPoint];

    [self close];
}

- (IBAction)cancel:(id)sender {

    [self close];
}

- (void)dealloc {

    [super dealloc];
}

@end
