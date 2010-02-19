/*
 Copyright (c) 2010, University of Bristol
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1) Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2) Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 3) Neither the name of the University of Bristol nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
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


#import "SyntaxHighlighting.h"


@implementation SyntaxHighlighting

@synthesize queryType;

- (id)init {
    
    if (![super init]) {
        return nil;
    }
    
    // default query type
    queryType = @"SELECT";
    
    // SPARQL keywords - these are query types
    queryTypeKeywords = [[NSArray alloc] initWithObjects: @"SELECT", @"CONSTRUCT", @"DESCRIBE",
                         @"ASK", nil];
    
    // SPARQL Keywords - case insensitive
    caseInsensitiveKeywords = [[NSArray alloc] initWithObjects: @"BASE", @"ORDER", @"BY", @"FROM",
                               @"GRAPH", @"STR", @"isURI", @"PREFIX", @"LIMIT", @"FROM NAMED",
                               @"OPTIONAL", @"LANG", @"isIRI", @"OFFSET", @"WHERE", @"UNION",
                               @"LANGMATCHES", @"isLITERAL", @"DISTINCT", @"FILTER", @"DATATYPE",
                               @"REGEX", @"REDUCED", @"BOUND", @"true", @"sameTERM",
                               @"false", nil];
    
    // SPARQL Keywords - case sensitive
    caseSensitiveKeywords = [[NSArray alloc] initWithObjects: @"a", nil];
    
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    [queryTypeKeywords release];
    [caseInsensitiveKeywords release];
    [caseSensitiveKeywords release];
    [whitespaceSet release];
}

#pragma mark text storage delegate methods
// just an initial attempt heavily borrowed from
// http://www.cocoadev.com/index.pl?ImplementSyntaxHighlighting
- (void)textStorageDidProcessEditing:(NSNotification *)notification {
    
    NSTextStorage *textStorage = [notification object];
    NSString *string = [textStorage string];
    NSRange area = [textStorage editedRange];
    unsigned int length = [string length];
    NSRange start, end;
    NSCharacterSet *whiteSpaceSet;
    unsigned int areamax = NSMaxRange(area);
    NSRange found;
    NSColor *blue = [NSColor blueColor];
    NSString *word;
    
    // extend our range along word boundaries.
    whiteSpaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    start = [string rangeOfCharacterFromSet:whiteSpaceSet
                                    options:NSBackwardsSearch
                                      range:NSMakeRange(0, area.location)];
    if (start.location == NSNotFound) {
        start.location = 0;
    }  else {
        start.location = NSMaxRange(start);
    }
    end = [string rangeOfCharacterFromSet:whiteSpaceSet
                                  options:0
                                    range:NSMakeRange(areamax, length - areamax)];
    if (end.location == NSNotFound)
        end.location = length;
    area = NSMakeRange(start.location, end.location - start.location);
    if (area.length == 0) return; // bail early
    
    // remove the old colors
    [textStorage removeAttribute:NSForegroundColorAttributeName range:area];
    
    // add new colors
    while (area.length) {
        // find the next word
        end = [string rangeOfCharacterFromSet:whiteSpaceSet
                                      options:0
                                        range:area];
        if (end.location == NSNotFound) {
            end = found = area;
        } else {
            found.length = end.location - area.location;
            found.location = area.location;
        }
        word = [string substringWithRange:found];
        

        BOOL checkMatch = FALSE;
        
        while (!checkMatch) {
        
            // check for query type keywords
            for (NSString *key in queryTypeKeywords) {
                if ([word compare:key options:NSCaseInsensitiveSearch] == 0) {
                    [textStorage addAttribute:NSForegroundColorAttributeName value:blue range:found];
                    checkMatch = TRUE;
                    NSLog(@"Match!>: %@", word);
                    
                    if (![key isEqual:queryType]) {
                        NSLog(@"Changing query type");
                        //queryType = nil;
                        [self setValue:key forKey:@"queryType"];
                        //queryType = key;
                    }
                    
                    break;
                }
            }
        
            // check for other case insenstive keywords
            for (NSString *key in caseInsensitiveKeywords) {
                if ([word compare:key options:NSCaseInsensitiveSearch] == 0) {
                    [textStorage addAttribute:NSForegroundColorAttributeName value:blue range:found];
                    checkMatch = TRUE;
                    NSLog(@"Match!: %@", word);
                    break;
                }
            }

            // check for other case senstive keywords
            for (NSString *key in caseSensitiveKeywords) {
                if ([word compare:key] == 0) {
                    [textStorage addAttribute:NSForegroundColorAttributeName value:blue range:found];
                    checkMatch = TRUE;
                    NSLog(@"Match!: %@", word);
                    break;
                }
            }
            
            checkMatch = TRUE;
        }
        // adjust our area
        areamax = NSMaxRange(end);
        area.length -= areamax - area.location;
        area.location = areamax;
    }
}

@end
