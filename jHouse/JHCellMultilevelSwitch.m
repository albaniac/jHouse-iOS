//
//  JHCellMultilevelSwitch.m
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHCellMultilevelSwitch.h"

@implementation JHCellMultilevelSwitch

@synthesize label = _label;
@synthesize slider = _slider;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)sliderChanged:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(cellForMultilevelSwitchChange:)])
    {
        [self.delegate cellForMultilevelSwitchChange:self];
    }    
}
@end
