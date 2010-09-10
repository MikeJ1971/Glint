/*
 Copyright (c) 2010, Mike Jones http://fairlypositive.com
 Copyright (c) 2010, University of Bristol http://www.bristol.ac.uk
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1) Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2) Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 3) Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

// Author: Mike Jones (mike.a.jones@bristol.ac.uk)

#import "AddEndPointController.h"
#import "EndPoint.h"

@implementation AddEndPointController

@synthesize sparqlEndPointName;
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
        NSLog(@"The endpoint is nil");
        self.endPoint = [[EndPoint alloc] init];
    }
    
    if (endPoint.name != nil) {
        [sparqlEndPointName setStringValue:endPoint.name];
    } else {
        [sparqlEndPointName setStringValue:@""];
    }
    
    [sparqlEndPointField setStringValue:endPoint.endPointURL];
    [queryParameter setStringValue:endPoint.queryParamName];
    [httpMethodField setStringValue:endPoint.httpMethod];
    [connectionTimeOutField setStringValue:endPoint.connectionTimeOut];
}

- (IBAction)done:(id)sender {

    endPoint.name = [sparqlEndPointName stringValue];
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

- (void)dealloc {
    [super dealloc];
}

@end
