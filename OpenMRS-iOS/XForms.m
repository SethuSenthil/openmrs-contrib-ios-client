//
//  XForm.m
//  OpenMRS-iOS
//
//  Created by Yousef Hamza on 7/19/15.
//  Copyright (c) 2015 Erway Software. All rights reserved.
//

#import "XForms.h"
#import "Constants.h"
#import "XFormsParser.h"

@implementation XForms

- (instancetype)initFormFromFile:(NSString *)fileName andURL:(NSURL *)url {
    self = [super init];
    if (self) {
        NSString *form = [fileName stringByDeletingPathExtension];
        
        /* format: [formname]~[formID].xml */
        NSArray *formInfo = [form componentsSeparatedByString:@"~"];
        self.name = formInfo[0];
        self.XFormsID = formInfo[1];
        
        NSString *path = [url.absoluteString stringByAppendingPathComponent:fileName];
        NSError* error = nil;
        NSData *fileData = [NSData dataWithContentsOfFile:path options: 0 error: &error];
        NSLog(@"Reading errror: %@", error);
        error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:fileData encoding:NSUTF8StringEncoding error:&error];
        self = [XFormsParser parseXFormsXML:doc withID:self.XFormsID andName:self.name];
    }
    return self;
}

- (NSData *)getModelFromDocument {
    GDataXMLElement *model = [self.doc.rootElement elementsForName:@"xf:model"][0];
    GDataXMLElement *instance = [model elementsForName:@"xf:instance"][0];
    
    GDataXMLElement *form = [instance children][0];
    NSDictionary *attributesStrings = @{@"xmlns:xf": @"http://www.w3.org/2002/xforms",
                                        @"xmlns:jr": @"http://openrosa.org/javarosa",
                                        @"xmlns:xs": @"http://www.w3.org/2001/XMLSchema",
                                        @"xmlns:xsi": @"http://www.w3.org/2001/XMLSchema-instance"
                                        };
    for (NSString *attributesKey in attributesStrings) {
        GDataXMLNode *node = [GDataXMLNode attributeWithName:attributesKey stringValue:attributesStrings[attributesKey]];
        [form addAttribute:node];
    }
    
    NSString *ModelString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>%@", form.XMLString];
    return [ModelString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
