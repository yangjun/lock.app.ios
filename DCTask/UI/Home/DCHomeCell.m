//
//  DCHomeCell.m
//  DCTask
//
//  Created by 青秀斌 on 16/9/4.
//  Copyright © 2016年 kylincc. All rights reserved.
//

#import "DCHomeCell.h"

@interface DCHomeCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *senderIcon;
@property (nonatomic, strong) UILabel *senderLabel;
@property (nonatomic, strong) UIImageView *timeIcon;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *lineView;
@end

@implementation DCHomeCell

- (void)initView {
    [super initView];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (self.titleLabel == nil) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(10);
            make.right.lessThanOrEqualTo(self.contentView).offset(-10);
        }];
    }
    
    if (self.senderLabel == nil) {
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.font = [UIFont systemFontOfSize:10];
        self.senderLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.senderLabel];
        [self.senderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.right.lessThanOrEqualTo(self.contentView).offset(-8);
        }];
        
        self.senderIcon = [[UIImageView alloc] init];
        self.senderIcon.contentMode = UIViewContentModeCenter;
        self.senderIcon.image = [UIImage imageNamed:@"home_icon_sender"];
        [self.contentView addSubview:self.senderIcon];
        [self.senderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.senderLabel.mas_left).offset(-4);
            make.centerY.equalTo(self.senderLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
    }
    
    if (self.timeLabel == nil) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        self.timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.senderLabel.mas_bottom).offset(4);
            make.right.lessThanOrEqualTo(self.contentView).offset(-8);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-10);
        }];
        
        self.timeIcon = [[UIImageView alloc] init];
        self.timeIcon.contentMode = UIViewContentModeCenter;
        self.timeIcon.image = [UIImage imageNamed:@"home_icon_time"];
        [self.contentView addSubview:self.timeIcon];
        [self.timeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.right.equalTo(self.timeLabel.mas_left).offset(-4);
            make.centerY.equalTo(self.timeLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
    }
    
    if (self.lineView == nil) {
        UIImage *image = [UIImage imageWithColor:[UIColor lightGrayColor]];
        self.lineView = [[UIImageView alloc] initWithImage:image highlightedImage:image];
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.equalTo(@0.5f);
        }];
    }
}

- (void)configWithPlan:(Plan *)plan index:(NSInteger)index{
    
    self.titleLabel.text = [NSString stringWithFormat:@"%ld.%@", index, plan.plan_name];
    self.senderLabel.text = [NSString stringWithFormat:@"派发人：%@", plan.dispatch_man];
    self.timeLabel.text = [plan.plan_date stringWithFormat:@"要求完成时间：yyyy-MM-dd"];
}

@end