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

#import "ResultsTableDelegate.h"

#define HEAD_ELEMENT            @"head"
#define VARIABLE_ELEMENT        @"variable"
#define RESULTS_ELEMENT         @"results"
#define RESULT_ELEMENT          @"result"

#define NAME_ATTRIBUTE          @"name"

#define URI_TYPE                @"uri"
#define LITERAL_TYPE            @"literal"
#define BNODE_TYPE              @"bnode"

@implementation ResultsTableDelegate

- (id)init {
    
    if (![super init]) {
        return nil;
    }
    
    columns = [[[NSMutableArray alloc] init] retain];
    results = [[[NSMutableArray alloc] init] retain];
    
    return self;
}

- (void)dealloc {

    [super dealloc];
    [columns release];
    [results release];
}

- (void)updateColumns:(NSTableView *)aTableView {
    
    // we iterate over the columns to get the identifies and add them to a tempory array;
    // we can then iterate over this temporary array to find the identifiers of columns 
    // that we want to remove from the table - removing columns while iterating over the 
    // columns array causes issues about mutability
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];  // will hold the identifiers
    
    for (NSTableColumn *col in [aTableView tableColumns]) {
        [temp addObject:[col identifier]];
    }    

    // remove columns based on the identifiers
    for (NSString *identifier in temp) {
        [aTableView removeTableColumn:[aTableView tableColumnWithIdentifier:identifier]];
    } 
    
    // add the new columns
    for (NSString *identifier in columns) {
        NSTableColumn* tc = [[NSTableColumn alloc] initWithIdentifier:identifier];
        [[tc headerCell] setStringValue:identifier];
        [tc setWidth:400];
        [aTableView addTableColumn:tc];
        [tc release];
    }
    
    [temp release];
}


#pragma mark XML SAX delegate calls

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {

    // ---------- dealing with the head
    
    // clear the columns when we hit the "head" element
    if ([elementName isEqualToString:HEAD_ELEMENT]) {
        [columns removeAllObjects];
    }

    // get the variable values
    if ([elementName isEqualToString:VARIABLE_ELEMENT]) {
        [columns addObject:[attributeDict objectForKey:NAME_ATTRIBUTE]];
    }
    
    // ---------- dealing with the results
    
    // clear the results when we hit the "results" element
    if ([elementName isEqualToString:RESULTS_ELEMENT]) {
        NSLog(@"Clearing results array");
        [results removeAllObjects];
    }    
    
    // we have entered a result - create a dictionary to hold it
    if ([elementName isEqualToString:@"result"]) {
        row = [[NSMutableDictionary alloc] init];
    }

    // keep track of the binding - we'll use it as a key in the row dictionary
    if ([elementName isEqualToString:@"binding"]) {
        bindingInProgress = [[[NSString alloc]
                              initWithString:[attributeDict objectForKey:NAME_ATTRIBUTE]] retain];
    }

    // value we are interested in - initiated the String to hold the text
    if ([elementName isEqualToString:URI_TYPE] || [elementName isEqualToString:LITERAL_TYPE] ||
        [elementName isEqualToString:BNODE_TYPE]) {
        
        textInProgress = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // end of the value, so add collected data to the row dictionary
    if ([elementName isEqualToString:URI_TYPE] || [elementName isEqualToString:LITERAL_TYPE] ||
        [elementName isEqualToString:BNODE_TYPE]) {
        
        [row setObject:textInProgress forKey:bindingInProgress];

        [textInProgress release];
        textInProgress = nil;
        
        [bindingInProgress release];
        bindingInProgress = nil;
    }
    
    // end of a results, so add the row dictionary to the results array
    if ([elementName isEqualToString:RESULT_ELEMENT]) {
        [results addObject:row];
        [row release];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [textInProgress appendString:string];
}


#pragma mark TableView

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {

    return [[results objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    return [results count];
}

- (NSString *)results {
    
    unsigned i,j,k;
    NSMutableString *csv = [NSMutableString string];
    
    for (i = 0; i < [columns count]; i++) {
        NSLog(@"In the loop");
        [csv appendFormat:@"\"%@\"", [columns objectAtIndex:i]];
        if (i != [columns count] -1) {
            [csv appendString:@","];
        }
    }
    
    [csv appendString:@"\n"];
    
    for (j = 0; j < [results count]; j++) {
        NSMutableDictionary *r = [results objectAtIndex:j];
        for (k = 0; k < [columns count]; k++) {
            [csv appendFormat:@"\"%@\"", [r objectForKey:[columns objectAtIndex:k]]];
            if (k != [columns count] -1) {
                [csv appendString:@","];
            }
        }
        [csv appendString:@"\n"];
    }
    
    return csv;
}
    
    


@end
