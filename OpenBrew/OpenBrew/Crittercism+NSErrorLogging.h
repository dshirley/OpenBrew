//
//  Crittercism+NSErrorLogging.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/6/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "Crittercism.h"

// Macro makes it less copy/pastish by pushing in lines and file names
#define CRITTERCISM_LOG_ERROR(err) \
do { \
  [Crittercism logError:(err) \
                forFile:__FILE__ \
          andLineNumber:__LINE__]; \
} while(0);

@interface Crittercism (NSErrorLogging)

+ (void)logError:(NSError *)error
         forFile:(char *)fileName
   andLineNumber:(int)lineNumber;

@end
