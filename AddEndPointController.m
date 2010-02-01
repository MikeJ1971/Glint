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
@synthesize cancelButton;
@synthesize doneButton;
@synthesize delegate;

- (id)init {
    
    NSLog(@"Initcalled!");
    
    if (![super initWithWindowNibName:@"AddEndPoint"]) {
        NSLog(@"It has all gone wrong");
        return nil;
    }
    
    return self;
}

- (void)windowDidLoad {
    NSLog(@"Add Endpont window loaded");
}

- (IBAction)done:(id)sender {

    EndPoint *endPoint = [[EndPoint alloc] init];
    endPoint.endPointURL = [sparqlEndPointField stringValue];
    endPoint.httpMethod = [httpMethodField titleOfSelectedItem];
    endPoint.queryParamName = [queryParameter stringValue];
    
    NSLog(@"%@ %@ %@", endPoint.endPointURL, endPoint.httpMethod, endPoint.queryParamName);
    
    [delegate addEndPoint:endPoint];
    
    NSLog(@"Done ... closing window");

    [self close];
}

- (IBAction)cancel:(id)sender {
    
    NSLog(@"Cancel ... closing window");
    [self close];
}

- (void)dealloc {
    NSLog(@"Dealloc called on AddEndPointController");
    [super dealloc];
}

@end
