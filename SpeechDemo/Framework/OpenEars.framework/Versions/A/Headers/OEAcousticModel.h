//
//  OEAcousticModel.h
//  OpenEars
//
//  Created by Halle on 8/14/13.
//  Copyright (c) 2013 Politepix. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class  OEAcousticModel
 @brief  Convenience class for accessing the acoustic model bundles. All this does is allow you to reference your chosen model by including this header in your class and then letting you call [OEAcousticModel pathToModel:@"AcousticModelEnglish"] or [OEAcousticModel pathToModel:@"AcousticModelSpanish"] (or other names, replacing the name of the model with the name of the model you are using, minus its ".bundle" suffix) in any of the methods which ask for a path to an acoustic model.
 */

@interface OEAcousticModel : NSObject


/** Reference the path to any acoustic model bundle you've dragged into your project (such as AcousticModelSpanish.bundle or AcousticModelEnglish.bundle) by calling this class method like [OEAcousticModel pathToModel:@"AcousticModelEnglish"] after importing this class. */
+ (NSString *) pathToModel:(NSString *) acousticModelBundleName;

@end
