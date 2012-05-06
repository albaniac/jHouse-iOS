//
//  JHCellBinarySwitch.m
//  jHouse
//
//  Created by Greg on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JHCellBinarySwitch.h"

@implementation JHCellBinarySwitch

@synthesize label = _label;
@synthesize binarySwitch = _binarySwitch;
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

- (IBAction)switchChanged:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(cellForBinarySwitchChange:)])
    {
        [self.delegate cellForBinarySwitchChange:self];
    }    
}

@end
