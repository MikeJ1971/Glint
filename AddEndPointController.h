//
//  AddEndPointController.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 01/02/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EndPoint.h"
#import "AddEndPointDelegate.h"


@interface AddEndPointController : NSWindowController {

    IBOutlet NSTextField *sparqlEndPointField;
    IBOutlet NSTextField *queryParameter;
    IBOutlet NSPopUpButton *httpMethodField;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSButton *doneButton;
    
    NSObject <AddEndPointDelegate> *delegate;
}

@property(retain,nonatomic) IBOutlet NSTextField *sparqlEndPointField;
@property(retain,nonatomic) IBOutlet NSTextField *queryParameter;
@property(retain,nonatomic) IBOutlet NSPopUpButton *httpMethodField;
@property(retain,nonatomic) IBOutlet NSButton *cancelButton;
@property(retain,nonatomic) IBOutlet NSButton *doneButton;
@property(retain,nonatomic) NSObject *delegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

