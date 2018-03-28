//
//  HHLiveCell.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHLiveCell.h"
#import "HHLiveItem.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ALinExtension.h"

// 颜色相关
#define Color(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define KeyColor Color(216, 41, 116)

@interface HHLiveCell ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *liveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigPicView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@end

@implementation HHLiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headImageView.layer.cornerRadius = 5;
    _headImageView.layer.masksToBounds = YES;
    
    _liveLabel.layer.cornerRadius = 5;
    _liveLabel.layer.masksToBounds = YES;
}

- (void)setLiveItem:(HHLiveItem *)liveItem{
    
    _liveItem = liveItem;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:liveItem.smallpic] placeholderImage:[UIImage imageNamed:@"placeholder_head"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        image = [UIImage  circleImage:image borderColor:[UIColor redColor] borderWidth:1];
        self.headImageView.image = image;
    }];
    
    self.nameLabel.text = liveItem.myname;
    
    // 如果没有地址, 给个默认的地址
    if (!liveItem.gps.length) {
        liveItem.gps = @"喵星";
    }
    self.addressLabel.text = liveItem.gps;
    
    [self.bigPicView sd_setImageWithURL:[NSURL URLWithString:liveItem.bigpic] placeholderImage:[UIImage imageNamed:@"profile_user_414x414"]];
    
    // 设置当前观众数量
    NSString *fullChaoyang = [NSString stringWithFormat:@"%ld人在看", liveItem.allnum];
    NSRange range = [fullChaoyang rangeOfString:[NSString stringWithFormat:@"%ld", liveItem.allnum]];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:fullChaoyang];
    [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range: range];
    [attr addAttribute:NSForegroundColorAttributeName value:KeyColor range:range];
    self.countLabel.attributedText = attr;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
