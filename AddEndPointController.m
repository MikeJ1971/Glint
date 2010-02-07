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
@synthesize endPoint;
@synthesize index;

- (id)init {

    if (![super initWithWindowNibName:@"AddEndPoint"]) {
        return nil;
    }
    
    self.index = -1; 
    
    return self;
}

- (IBAction)showWindow:(id)sender {
    [super showWindow:sender];

    if (endPoint == nil) {
        self.endPoint = [[EndPoint alloc] init];
    }
    
    [sparqlEndPointField setStringValue:endPoint.endPointURL];
    [queryParameter setStringValue:endPoint.queryParamName];
    [httpMethodField setStringValue:endPoint.httpMethod];
    [connectionTimeOutField setStringValue:endPoint.connectionTimeOut];
}

- (IBAction)done:(id)sender {

    endPoint.endPointURL = [sparqlEndPointField stringValue];
    endPoint.httpMethod = [httpMethodField titleOfSelectedItem];
    endPoint.queryParamName = [queryParameter stringValue];
    endPoint.connectionTimeOut = [connectionTimeOutField stringValue];

    if (self.index >= 0 ) { // update an existing endpoint
        [delegate replaceEndpointInArrayWith:self.endPoint atIndex:index];
    } else {
        [delegate addEndPointToArrayList:endPoint]; // add a new endpoint
    }

    [self close];
}

- (IBAction)cancel:(id)sender {
    
    [self close];
}

- (void)close {
    [super close];
    [endPoint release];
    endPoint = nil;
    index = -1;
}
/**
- (void)cleanUp {
    [endPoint release];
    endPoint = nil;
    index = -1;
    [self close];
}
**/
- (void)dealloc {
    [super dealloc];
}

@end
