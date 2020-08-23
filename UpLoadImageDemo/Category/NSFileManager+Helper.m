//
//  NSFileManager+Helper.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/20.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "NSFileManager+Helper.h"



@implementation NSFileManager (Helper)

- (NSString *)temporaryDirectoryWithTemplateString:(NSString *)templateString {

    NSString *mkdTemplate =
        [NSTemporaryDirectory() stringByAppendingPathComponent:templateString];

    const char *templateCString = [mkdTemplate fileSystemRepresentation];
    char *buffer = (char *)malloc(strlen(templateCString) + 1);
    strcpy(buffer, templateCString);

    NSString *directoryPath = nil;

    char *result = mkdtemp(buffer);
    if (result) {
        directoryPath = [self stringWithFileSystemRepresentation:buffer
                                                          length:strlen(result)];
    }
    free(buffer);
    return directoryPath;
}

@end
