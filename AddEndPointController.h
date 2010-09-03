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

#import <Cocoa/Cocoa.h>
#import "EndPoint.h"
#import "AddEndPointDelegate.h"


@interface AddEndPointController : NSWindowController {

    IBOutlet NSTextField *sparqlEndPointField;
    IBOutlet NSTextField *queryParameter;
    IBOutlet NSPopUpButton *httpMethodField;
    IBOutlet NSTextField *connectionTimeOutField;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *doneButton;
    
    NSObject <AddEndPointDelegate> *delegate;
    
    EndPoint *endPoint;
    NSInteger index;
}

@property(retain,nonatomic) IBOutlet NSTextField *sparqlEndPointField;
@property(retain,nonatomic) IBOutlet NSTextField *queryParameter;
@property(retain,nonatomic) IBOutlet NSPopUpButton *httpMethodField;
@property(retain,nonatomic) IBOutlet NSTextField *connectionTimeOutField;
@property(retain,nonatomic) IBOutlet NSButton *cancelButton;
@property(retain,nonatomic) IBOutlet NSButton *doneButton;
@property(retain,nonatomic) NSObject *delegate;
@property(retain,nonatomic) EndPoint *endPoint;
@property(assign) NSInteger index;

//- (void)updateForm;
//- (void)cleanUp;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

