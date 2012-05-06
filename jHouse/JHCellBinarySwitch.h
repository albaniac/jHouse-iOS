//
//  JHCellBinarySwitch.h
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JHCellBinarySwitch;

@protocol JHCellBinarySwitchDelegate <NSObject>
- (void)cellForBinarySwitchChange:(JHCellBinarySwitch *)sender;
@end

@interface JHCellBinarySwitch : UITableViewCell

- (IBAction)switchChanged:(UISwitch *)sender;

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UISwitch *binarySwitch;
@property (weak, nonatomic) id <JHCellBinarySwitchDelegate> delegate;

@end
