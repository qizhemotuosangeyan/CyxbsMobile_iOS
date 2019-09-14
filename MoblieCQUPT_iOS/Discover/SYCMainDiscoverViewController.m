//
//  SYCFinderViewController.m
//  MoblieCQUPT_iOS
//
//  Created by 施昱丞 on 2018/9/26.
//  Copyright © 2018 Orange-W. All rights reserved.
//
#define SCREEN_MARGIN 10

#import "SYCMainDiscoverViewController.h"
#import "SYCPictureDisplayView.h"
#import "SYCToolsCell.h"
#import "SYCCustomToolsControlView.h"
#import "SYCCustomLayoutModel.h"
#import "LZCarouselModel.h"
#import "SYCToolModel.h"
#import "ExamTotalViewController.h"
#import "WebViewController.h"
#import "BeforeClassViewController.h"
#import "EmptyClassViewController.h"
#import "LZNoCourseViewController.h"
#import "CalendarViewController.h"
#import "QueryLoginViewController.h"
#import "MapViewController.h"
#import "LoginViewController.h"
#import "QuerLoginViewController.h"
#import "HttpClient.h"
#import "MBProgressHUD.h"
#import <Masonry.h>

@interface SYCMainDiscoverViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray<LZCarouselModel *> *carouselDataArray;
@property (nonatomic, strong) SYCPictureDisplayView *pictureDisplay;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *inusedTools;
@property (nonatomic, strong) UICollectionView *toolsView;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) UIView *toolBackgroudView;
@property (nonatomic) double rows;

@end


@implementation SYCMainDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getNetworkData];
    _carouselDataArray = [[NSMutableArray alloc] init];
    self.inusedTools = [SYCCustomLayoutModel sharedInstance].inuseTools;

    [self setUpUI];
    
}


- (void)setUpUI{
    self.view.backgroundColor = BACK_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showChannel)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBARHEIGHT - TABBARHEIGHT - NVGBARHEIGHT)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];



    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //CollectionViewn中内边距大约为10，每行3个按钮中间2个内边距2 * 10 = 20
    CGFloat itemWidth = ((SCREEN_WIDTH - 2 * SCREEN_MARGIN - 30) / 3);
    CGFloat itemHeight = itemWidth * 1.2;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.toolsView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.toolsView.backgroundColor = [UIColor clearColor];
    self.toolsView.scrollEnabled = NO;
    self.toolsView.delegate = self;
    self.toolsView.dataSource = self;
    [self.toolsView registerClass:[SYCToolsCell class] forCellWithReuseIdentifier:@"SYCToolsCell"];
    [self.scrollView addSubview:self.toolsView];
    self.toolsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).with.offset(270);
        make.left.equalTo(self.view.mas_left).with.offset(SCREEN_MARGIN);
        make.right.equalTo(self.view.mas_right).with.offset(-SCREEN_MARGIN);
        make.height.equalTo(@(self.rows * itemHeight + (self.rows - 1) * 10));
    }];
    
    _toolBackgroudView = [[UIView alloc] init];
    _toolBackgroudView.backgroundColor = [UIColor whiteColor];
    _toolBackgroudView.layer.cornerRadius = 10.f;
    [self.scrollView addSubview:_toolBackgroudView];
    [self.scrollView sendSubviewToBack:_toolBackgroudView];
    self.toolsView.translatesAutoresizingMaskIntoConstraints = NO;
    [_toolBackgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.height.width.equalTo(self.toolsView);
    }];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 30 + SCREEN_WIDTH * 0.55 + 50 + (self.rows * itemHeight + (self.rows - 1) * 10));
}

-(void)showChannel{
    [[SYCCustomToolsControlView shareInstance] showChannelViewWithInUseTitles:self.inusedTools unUseTitles:[SYCCustomLayoutModel sharedInstance].unuseTools finish:^(NSArray *inUseTitles, NSArray *unUseTitles) {
        self.inusedTools = inUseTitles;
        [SYCCustomLayoutModel sharedInstance].inuseTools = [inUseTitles copy];
        [SYCCustomLayoutModel sharedInstance].unuseTools = [unUseTitles copy];
        [[SYCCustomLayoutModel sharedInstance] save];
        [self reloadView];
    }];
}

- (void)reloadView{
    CGFloat itemWidth = ((SCREEN_WIDTH - 2 * SCREEN_MARGIN - 30) / 3);
    CGFloat itemHeight = itemWidth * 1.2;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 30 + SCREEN_WIDTH * 0.55 + 50 + (self.rows * itemHeight + (self.rows - 1) * 10));
    [self.toolsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(self.rows * itemHeight + (self.rows - 1) * 10));
    }];
    [self.view layoutIfNeeded];
    [self.toolsView reloadData];
    [_toolBackgroudView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.height.width.equalTo(self.toolsView);
    }];
}

- (double)rows{
    return ceilf(self.inusedTools.count / 3.0);
}

#pragma -UICollectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.inusedTools.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SYCToolsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SYCToolsCell" forIndexPath:indexPath];
    SYCToolModel *tool = self.inusedTools[[indexPath row]];
    cell.image = [UIImage imageNamed:tool.imageName];
    cell.title = tool.title;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SYCToolModel *tool = self.inusedTools[[indexPath row]];
    UIViewController *viewController =  (UIViewController *)[[NSClassFromString(tool.className) alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.title = tool.title;
    [self.navigationController pushViewController:viewController animated:YES];
}


//轮播器获取网络图片
- (void)getNetworkData{
    HttpClient *client = [HttpClient defaultClient];
    [client requestWithPath:@"https://cyxbsmobile.redrock.team/app/api/pictureCarousel.php" method:HttpRequestPost parameters:@{@"pic_num":@3} prepareExecute:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.carouselDataArray = [@[] mutableCopy];
        NSArray *dataArray = [responseObject objectForKey:@"data"];
        for (NSDictionary *picData in dataArray) {
            LZCarouselModel *model = [[LZCarouselModel alloc] init];
            model.picture_url = [picData objectForKey:@"picture_url"];
            model.picture_goto_url = [picData objectForKey:@"picture_goto_url"];
            model.keyword = [picData objectForKey:@"keyword"];
            [self.carouselDataArray addObject:model];
        }
        self.pictureDisplay = [[SYCPictureDisplayView alloc] initWithData:self.carouselDataArray];
        [self.scrollView addSubview:self.pictureDisplay];
        [self.pictureDisplay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.scrollView).with.offset(20);
            make.left.and.right.equalTo(self.view);
            make.height.equalTo(@(SCREEN_WIDTH * 0.55));
        }];
        [self.pictureDisplay layoutIfNeeded];
        [self.pictureDisplay buildUI];
    } failure:^(NSURLSessionDataTask *task, NSError *error){
        NSLog(@"获取轮播图图片失败");
    }];

}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

@end
