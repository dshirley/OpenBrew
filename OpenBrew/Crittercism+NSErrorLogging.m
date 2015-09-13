//
//  Crittercism+NSErrorLogging.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/6/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "Crittercism+NSErrorLogging.h"


@implementation Crittercism (NSErrorLogging)

+ (void)logError:(NSError *)error
         forFile:(char *)fileName
   andLineNumber:(int)lineNumber
{
  if (!error) {
    return;
  }

  NSString *name = [NSString stringWithFormat:@"%@ - %@", error.domain, @(error.code)];
  NSString *reason = [NSString stringWithFormat:@"%s[%d]", fileName, lineNumber];
  NSDictionary *userInfo = [error userInfo];

  NSException *ex = [[NSException alloc] initWithName:name
                                               reason:reason
                                             userInfo:userInfo];

  NSLog(@"ERROR: %@ %@", name, reason);
  [userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
    NSString *breadcrumb = [NSString stringWithFormat:@"%@ => %@", key, value];
    [Crittercism leaveBreadcrumb:breadcrumb];
    NSLog(@"%@ => %@", key, value);
  }];

  [Crittercism logHandledException:ex];

  NSCAssert(NO, @"error: %@", error);
}

@end
