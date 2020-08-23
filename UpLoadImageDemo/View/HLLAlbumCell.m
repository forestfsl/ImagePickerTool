//
//  HLLAlbumCell.m
//  UpLoadImageDemo
//
//  Created by fengsl on 2020/8/14.
//  Copyright © 2020 com.forest. All rights reserved.
//

#import "HLLAlbumCell.h"
#import "UIView+Helper.h"
#import "HLLAssetModel.h"
#import "HLLImageManager.h"

@interface HLLAlbumCell()

@property (nonatomic, strong) UIImageView *posterImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end


@implementation HLLAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setupSubView];
    return self;
}


- (void)setupSubView{
    self.backgroundColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.contentView addSubview:self.posterImageView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)setModel:(HLLAlbumModel *)model{
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc]initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    
    self.titleLabel.attributedText = nameString;
    //获取封面
    [[HLLImageManager manager] fetchPostImagewithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
        [self setNeedsLayout];
    }];
    if (model.selectedCount) {
        self.selectedCountBtn.hidden = NO;
        [self.selectedCountBtn setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    }else{
        self.selectedCountBtn.hidden = YES;
    }
    if (self.albumCellDidSetModelBlock) {
        self.albumCellDidSetModelBlock(self, _posterImageView, _titleLabel);
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _selectedCountBtn.frame = CGRectMake(self.contentView.al_width - 24, 23, 24, 24);
    NSInteger titleHeight = ceil(self.titleLabel.font.lineHeight);
    self.titleLabel.frame = CGRectMake(80, (self.al_height - titleHeight) / 2, self.al_width - 80 - 50, titleHeight);
    self.posterImageView.frame = CGRectMake(0, 0, 70, 70);
    if (self.albumCellDidLayoutSubViewsBlock) {
        self.albumCellDidLayoutSubViewsBlock(self, _posterImageView, _titleLabel);
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
}

- (UIImageView *)posterImageView{
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc]init];
        _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        _posterImageView.clipsToBounds = YES;
        
    }
    return _posterImageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIButton *)selectedCountBtn{
    if (!_selectedCountBtn) {
        _selectedCountBtn =  [[UIButton alloc] init];
        _selectedCountBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        _selectedCountBtn.layer.cornerRadius = 12;
        _selectedCountBtn.clipsToBounds = YES;
        _selectedCountBtn.backgroundColor = [UIColor redColor];
        [_selectedCountBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectedCountBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _selectedCountBtn;
}

@end
