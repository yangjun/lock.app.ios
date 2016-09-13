//
//  Picture+CoreDataProperties.h
//  
//
//  Created by 青秀斌 on 16/9/13.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Picture.h"

NS_ASSUME_NONNULL_BEGIN

@interface Picture (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *data;
@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) PlanItem *planItem;

@end

NS_ASSUME_NONNULL_END
