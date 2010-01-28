//
//  AppController.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
    
    IBOutlet NSTextField *sparqlEndPointField;
    IBOutlet NSButton *runQueryButton;
    IBOutlet NSTextView *queryTextView;
    IBOutlet NSTextView *resultsTextView;

}

@property(retain,nonatomic) IBOutlet NSTextField *sparqlEndPointField;
@property(retain,nonatomic) IBOutlet NSButton *runQueryButton;
@property(retain,nonatomic) IBOutlet NSTextView *queryTextView;
@property(retain,nonatomic) IBOutlet NSTextView *resultsTextView;

- (IBAction)runquery:(id)sender;

@end
