//
//  JHCellMultilevelSwitch.h
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JHCellMultilevelSwitch;

@protocol JHCellMultilevelSwitchDelegate <NSObject>
- (void)cellForMultilevelSwitchChange:(JHCellMultilevelSwitch *)sender;
@end

@interface JHCellMultilevelSwitch : UITableViewCell

- (IBAction)sliderChanged:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) id <JHCellMultilevelSwitchDelegate> delegate;

@end
