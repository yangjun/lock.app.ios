//
//  DCHomeVC.m
//  DCTask
//
//  Created by 青秀斌 on 16/9/3.
//  Copyright © 2016年 kylincc. All rights reserved.
//

#import "DCHomeVC.h"
#import "DCPopView.h"
#import "DCHomeCell.h"
#import "DCCheckVC.h"
#import "DCLoginVC.h"
#import "DCSettingVC.h"
#import "DCOpenDoorVC.h"
#import "DCHumitureVC.h"
#import "BSNavigationController.h"

static NSString *cellIdentifier = @"DCHomeCell";

@interface DCHomeVC ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *syncStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *openDoorButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton1;
@property (weak, nonatomic) IBOutlet UIButton *selectButton2;
@property (weak, nonatomic) IBOutlet UIButton *selectButton3;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView3;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController2;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController3;
@end

@implementation DCHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Plan MR_performFetch:self.fetchedResultsController1];
    [self controllerDidChangeContent:self.fetchedResultsController1];
    
    [Plan MR_performFetch:self.fetchedResultsController2];
    [self controllerDidChangeContent:self.fetchedResultsController2];
    
    [Plan MR_performFetch:self.fetchedResultsController3];
    [self controllerDidChangeContent:self.fetchedResultsController3];
    
    //监听同步
    @weakify(self)
    [RACObserve(APPENGINE.dataManager, isSyncing) subscribeNext:^(NSNumber * isSyncing) {
        @strongify(self)
        self.syncStatusLabel.hidden = !isSyncing.boolValue;
    }];
    
    //登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutAction)
                                                 name:DCUserLogoutNotification
                                               object:nil];
    
    //下线通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(offlineAction)
                                                 name:DCUserOfflineNotification
                                               object:nil];
    
    //同步数据
    [APPENGINE.dataManager syncData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowCheckVC1"]) {
        DCCheckVC *vc = (DCCheckVC *)segue.destinationViewController;
        vc.plan = sender;
        vc.editable = YES;
    } else if ([segue.identifier isEqualToString:@"ShowCheckVC2"]) {
        DCCheckVC *vc = (DCCheckVC *)segue.destinationViewController;
        vc.plan = sender;
        vc.editable = NO;
    }
}

/**********************************************************************/
#pragma mark - Private
/**********************************************************************/

- (NSFetchedResultsController *)fetchedResultsController1 {
    if (_fetchedResultsController1 != nil) {
        return _fetchedResultsController1;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user=%@ AND type=0", APPENGINE.userManager.user];
    _fetchedResultsController1 = [Plan MR_fetchAllSortedBy:@"createDate"
                                                 ascending:NO
                                             withPredicate:predicate
                                                   groupBy:nil
                                                  delegate:self];
    return _fetchedResultsController1;
}

- (NSFetchedResultsController *)fetchedResultsController2 {
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user=%@ AND type=1", APPENGINE.userManager.user];
    _fetchedResultsController2 = [Plan MR_fetchAllSortedBy:@"decideDate"
                                                 ascending:NO
                                             withPredicate:predicate
                                                   groupBy:nil
                                                  delegate:self];
    return _fetchedResultsController2;
}

- (NSFetchedResultsController *)fetchedResultsController3 {
    if (_fetchedResultsController3 != nil) {
        return _fetchedResultsController3;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user=%@ AND type=3", APPENGINE.userManager.user];
    _fetchedResultsController3 = [Plan MR_fetchAllSortedBy:@"submitDate"
                                                 ascending:NO
                                             withPredicate:predicate
                                                   groupBy:nil
                                                  delegate:self];
    return _fetchedResultsController3;
}

/**********************************************************************/
#pragma mark - Action
/**********************************************************************/

- (void)openDoorAction:(id)sener {
    DCOpenDoorVC *vc = [[DCOpenDoorVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)settingAction:(id)sender {
    DCPopView *popView = [[DCPopView alloc] init];
    popView.items = @[@{@"icon":@"home_btn_humiture", @"title":@"机房温湿度"},
                      @{@"icon":@"home_btn_setting", @"title":@"设置"}];
    @weakify(self)
    [popView setDidSelectedIndex:^(DCPopView *popView, NSInteger index) {
        @strongify(self)
        switch (index) {
            case 0:{
                [self performSegueWithIdentifier:@"PushHumiture" sender:sender];
            }break;
            case 1:{
                [self performSegueWithIdentifier:@"PushSetting" sender:sender];
            }break;
        }
    }];
    [popView showFromView:sender];
}

- (IBAction)selectAction:(UIButton *)sender {
    if (sender == self.selectedButton) {
        return;
    }
    
    CGRect frame = self.scrollView.bounds;
    frame.origin.x = sender.frame.origin.x*3;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)logoutAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [SVProgressHUD showInfoWithStatus:@"登出成功！"];
}

- (void)offlineAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线通知"
                                                        message:@"您的账号已在其他设备登录！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}

/**********************************************************************/
#pragma mark - UIScrollViewDelegate
/**********************************************************************/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        CGFloat offsetX = scrollView.contentOffset.x + scrollView.width * 0.5f;
        if (offsetX/scrollView.width < 1) {
            if (self.selectedButton != self.selectButton1) {
                self.selectedButton.selected = NO;
                self.selectedButton = self.selectButton1;
                self.selectedButton.selected = YES;
            }
        } else if (scrollView.contentOffset.x/scrollView.width + 0.5f < 2) {
            if (self.selectedButton != self.selectButton2) {
                self.selectedButton.selected = NO;
                self.selectedButton = self.selectButton2;
                self.selectedButton.selected = YES;
            }
        } else {
            if (self.selectedButton != self.selectButton3) {
                self.selectedButton.selected = NO;
                self.selectedButton = self.selectButton3;
                self.selectedButton.selected = YES;
            }
        }
        
        [self.selectImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.selectView.mas_left).offset(offsetX/3.0f);
        }];
    }
}

/**********************************************************************/
#pragma mark - UITableViewDataSource && UITableViewDelegate
/**********************************************************************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView1) {
        return [[self.fetchedResultsController1 sections] count];
    } else if (tableView == self.tableView2) {
        return [[self.fetchedResultsController2 sections] count];
    } else if (tableView == self.tableView3) {
        return [[self.fetchedResultsController3 sections] count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView1) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController1 sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else if (tableView == self.tableView2) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController2 sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else if (tableView == self.tableView3) {
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController3 sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByIndexPath:indexPath configuration:^(DCHomeCell *cell) {
        Plan *plan = nil;
        if (tableView == self.tableView1) {
            plan = [self.fetchedResultsController1 objectAtIndexPath:indexPath];
        } else if (tableView == self.tableView2) {
            plan = [self.fetchedResultsController2 objectAtIndexPath:indexPath];
        } else if (tableView == self.tableView3) {
            plan = [self.fetchedResultsController3 objectAtIndexPath:indexPath];
        }
        [cell configWithPlan:plan index:indexPath.row+1];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Plan *plan = nil;
    if (tableView == self.tableView1) {
        plan = [self.fetchedResultsController1 objectAtIndexPath:indexPath];
    } else if (tableView == self.tableView2) {
        plan = [self.fetchedResultsController2 objectAtIndexPath:indexPath];
    } else if (tableView == self.tableView3) {
        plan = [self.fetchedResultsController3 objectAtIndexPath:indexPath];
    }
    [cell configWithPlan:plan index:indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Plan *plan = nil;
    if (tableView == self.tableView1) {
        plan = [self.fetchedResultsController1 objectAtIndexPath:indexPath];
        
        AlertView *alertView = [AlertView alertControllerWithTitle:@"请选择你的操作" message:nil];
        [alertView addButtonWithTitle:@"接收任务" action:^(AlertView * _Nonnull alertView) {
            [alertView dismiss];
            [plan accept];
        }];
        [alertView addButtonWithTitle:@"拒绝任务" action:^(AlertView * _Nonnull alertView) {
            [alertView dismiss];
            
            alertView = [AlertView alertControllerWithTitle:@"拒绝任务" message:nil];
            [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入拒绝理由";
            }];
            [alertView addButtonWithTitle:@"确定" action:^(AlertView * _Nonnull alertView) {
                [alertView dismiss];
                [plan refuse:alertView.textFields.firstObject.text];
            }];
            [alertView addButtonWithTitle:@"取消" action:nil];
            [alertView show];
        }];
        [alertView addButtonWithTitle:@"取消" action:nil];
        [alertView show];
    } else if (tableView == self.tableView2) {
        plan = [self.fetchedResultsController2 objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"ShowCheckVC1" sender:plan];
    } else if (tableView == self.tableView3) {
        plan = [self.fetchedResultsController3 objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"ShowCheckVC2" sender:plan];
    }
}

/**********************************************************************/
#pragma mark - NSFetchedResultsControllerDelegate
/**********************************************************************/

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = nil;
    if (controller == self.fetchedResultsController1) {
        tableView = self.tableView1;
    } else if (controller == self.fetchedResultsController2) {
        tableView = self.tableView2;
    } else if (controller == self.fetchedResultsController3) {
        tableView = self.tableView3;
    }
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = nil;
    if (controller == self.fetchedResultsController1) {
        tableView = self.tableView1;
    } else if (controller == self.fetchedResultsController2) {
        tableView = self.tableView2;
    } else if (controller == self.fetchedResultsController3) {
        tableView = self.tableView3;
    }
    switch(type) {
        case NSFetchedResultsChangeInsert:{
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
        }break;
        case NSFetchedResultsChangeDelete:{
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            
        }break;
        case NSFetchedResultsChangeUpdate:{
            DCHomeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            Plan *plan = [controller objectAtIndexPath:indexPath];
            [cell configWithPlan:plan index:indexPath.row+1];
        }break;
        case NSFetchedResultsChangeMove:{
            [tableView reloadData];
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
        }break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSUInteger count = [controller fetchedObjects].count;
    
    UITableView *tableView = nil;
    if (controller == self.fetchedResultsController1) {
        tableView = self.tableView1;;
        [self.selectButton1 setTitle:[@"待处理" stringByAppendingFormat:@"(%lu)", count] forState:UIControlStateNormal];
    } else if (controller == self.fetchedResultsController2) {
        tableView = self.tableView2;
        [self.selectButton2 setTitle:[@"处理中" stringByAppendingFormat:@"(%lu)", count] forState:UIControlStateNormal];
    } else if (controller == self.fetchedResultsController3) {
        tableView = self.tableView3;
        [self.selectButton3 setTitle:[@"未提交" stringByAppendingFormat:@"(%lu)", count] forState:UIControlStateNormal];
    }
    [tableView endUpdates];
    
    if (count>0) {
        [tableView dismissBlank];
    } else {
        [tableView showBlankWithImage:[UIImage imageNamed:@"home_blank"] title:nil message:nil action:nil offsetY:-100];
    }
}

@end
