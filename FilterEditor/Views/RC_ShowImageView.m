//
//  RC_ShowImageView.m
//  FilterEditor
//
//  Created by gaoluyangrc on 15-1-14.
//  Copyright (c) 2015年 rcplatform. All rights reserved.
//

#import "RC_ShowImageView.h"
#import "EditViewController.h"
#import "PRJ_Global.h"

#define ALLCount 63  //所有的滤镜效果

@interface RC_ShowImageView()
{
    NSUInteger _w;
    NSUInteger _h;
    NSInteger groupType;
    UIImage *filter_result_image;
    NSMutableArray *_filterTypeArrays;
    NSArray *list_Array;
    CGPoint beginPoint;
    CGPoint endPoint;
}
@end

@implementation RC_ShowImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        
        _w = CGRectGetWidth(frame);
        _h = CGRectGetHeight(frame);
        
        list_Array = @[@[@74,@130,@131,@134,@135,@137,@142,@156],
                       @[@338,@336,@332,@323,@326,@328,@329,@334],
                       @[@108,@109,@111,@112,@115,@120,@121,@123],
                       @[@105,@107,@116,@117,@122,@143,@145,@146],
                       @[@23,@26,@40,@50,@63,@83,@86,@92],
                       @[@202,@242,@243,@251,@252,@253,@254,@255],
                       @[@42,@99,@100,@101,@102,@103,@110,@114],
                       @[@22,@78,@80,@94,@95,@96,@97,@98]];
        _filterTypeArrays = [[NSMutableArray alloc] init];
        [list_Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]])
            {
                NSArray *array = (NSArray *)obj;
                [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [_filterTypeArrays addObject:obj];
                }];
            }
        }];

        //侦听滤镜结果图
        [EditViewController receiveFilterResult:^(UIImage *filterImage) {
            filter_result_image = filterImage;
        }];
        //侦听点击分组名字
        [[PRJ_Global shareStance] changeFilterGroup:^(NSInteger number) {
            groupType = number;
            [PRJ_Global shareStance].draggingIndex = 0;
            if (number == 0)
            {
                [_filterTypeArrays removeAllObjects];
                [list_Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        NSArray *array = (NSArray *)obj;
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [_filterTypeArrays addObject:obj];
                        }];
                    }
                }];
            }
            else
            {
                _filterTypeArrays = nil;
                _filterTypeArrays = [[NSMutableArray alloc] initWithArray:list_Array[number - 1]];
                _randomNumber([_filterTypeArrays[[PRJ_Global shareStance].draggingIndex] integerValue]);
            }
        }];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    endPoint = [touch locationInView:self];
    
    if (endPoint.x - beginPoint.x < -20)
    {
        [PRJ_Global shareStance].draggingIndex++;
        if ([PRJ_Global shareStance].draggingIndex == _filterTypeArrays.count)
        {
            [PRJ_Global shareStance].draggingIndex = 0;
        }
        
        self.image = filter_result_image;
        id number;
        //最外层的随机滤镜
        if (groupType == 0)
        {
            number = _filterTypeArrays[random()%_filterTypeArrays.count];
        }
        else //单一组内的顺序滤镜
        {
            number = _filterTypeArrays[[PRJ_Global shareStance].draggingIndex];
            //分类每次滑动结束发送回调
            [PRJ_Global shareStance].isDragging = YES;
            [PRJ_Global shareStance].selectedFilterID([PRJ_Global shareStance].draggingIndex);
        }
        NSInteger filterType = [number integerValue];
        _randomNumber(filterType);
        
        //数据清除完再重新加载数据
        if (groupType == 0)
        {
            [_filterTypeArrays removeObject:number];
            if (_filterTypeArrays.count == 0)
            {
                _filterTypeArrays = nil;
                _filterTypeArrays = [[NSMutableArray alloc] init];
                [list_Array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        NSArray *array = (NSArray *)obj;
                        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [_filterTypeArrays addObject:obj];
                        }];
                    }
                }];
            }
        }
    }
}

- (void)receiveRandomNumber:(RandomNumber)numberValue;
{
    _randomNumber = numberValue;
}

@end