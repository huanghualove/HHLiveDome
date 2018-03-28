//
//  HHBroadListViewController.m
//  HHLiveDome
//
//  Created by 黄华 on 2018/3/28.
//  Copyright © 2018年 huanghua. All rights reserved.
//

#import "HHBroadListViewController.h"
#import "HHLiveCell.h"
#import "HHLiveItem.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>
#import "HHLiveCollectionViewController.h"

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height


static NSString *const cellID = @"cellid";

@interface HHBroadListViewController ()<UITableViewDataSource,UITableViewDelegate>
/** 直播 */
@property(nonatomic, strong) NSMutableArray *datas;
@property(nonatomic, strong) UITableView *tableView;

@end

@implementation HHBroadListViewController

- (NSMutableArray *)datas{
    if(!_datas){
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"直播列表";
    
    [self loadDatas];
    
    [self _initTableview];
}


- (void)loadDatas{
    
    // 数据url
    NSString *urlStr = @"http://live.9158.com/Fans/GetHotLive?page=1";
    
    // 请求数据
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    
    [mgr GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        
        self.datas = [HHLiveItem mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"list"]];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
    }];
}


- (void)_initTableview{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //nib
    [self.tableView registerNib:[UINib nibWithNibName:@"HHLiveCell" bundle:nil] forCellReuseIdentifier:cellID];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HHLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.liveItem = _datas[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 430;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HHLiveCollectionViewController *liveVc = [[HHLiveCollectionViewController alloc] init];
    liveVc.lives = _datas;
    liveVc.currentIndex = indexPath.row;
    [self presentViewController:liveVc animated:YES completion:nil];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
