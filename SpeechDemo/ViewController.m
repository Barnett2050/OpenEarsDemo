//
//  ViewController.m
//  SpeechDemo
//
//  Created by mac02 on 16/7/6.
//  Copyright © 2016年 mac02. All rights reserved.
//

#import "ViewController.h"

#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

#import <OpenEars/OEPocketsphinxController.h>

#define ChineseModel @"LanguageModelFilesOfChinese"
#define EnglishModel @"LanguageModelFilesOfEnglish"

@interface ViewController ()<OEEventsObserverDelegate>

@property (strong, nonatomic) UILabel *speechLabel;
@property (strong, nonatomic) UIButton *start;
@property (strong, nonatomic) UIButton *stop;
@property (strong, nonatomic) UIButton *changeLanguage;
@property (strong, nonatomic) UILabel *languageEnvironment;

@property (nonatomic, assign) BOOL languageSlected;

@property (nonatomic, strong) NSString *englishLmPath;
@property (nonatomic, strong) NSString *englishDicPath;
@property (nonatomic, strong) NSString *chineseLmPath;
@property (nonatomic, strong) NSString *chineseDicPath;
@property (nonatomic, strong) NSError *errString;

@property (nonatomic, strong) NSArray *englishWords;
@property (nonatomic, strong) NSArray *chineseWords;

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;// 观察者
@property (strong, nonatomic) OELanguageModelGenerator *lmGenerator;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinx;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.languageSlected = YES;
    self.englishLmPath = [[NSString alloc] init];
    self.englishDicPath = [[NSString alloc] init];
    self.chineseLmPath = [[NSString alloc] init];
    self.chineseDicPath = [[NSString alloc] init];
    self.errString = nil;
    
    CGFloat width = self.view.bounds.size.width;
    
    self.speechLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, width, 50)];
    self.speechLabel.backgroundColor = [UIColor yellowColor];
    self.speechLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.speechLabel];
    
    self.start = [UIButton buttonWithType:UIButtonTypeSystem];
    self.start.backgroundColor = [UIColor cyanColor];
    self.start.frame = CGRectMake(0, 120, width, 50);
    [self.start setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:self.start];
    [self.start addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.stop = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stop.backgroundColor = [UIColor redColor];
    self.stop.frame = CGRectMake(0, 190, width, 50);
    [self.stop setTitle:@"停止" forState:UIControlStateNormal];
    [self.view addSubview:self.stop];
    [self.stop addTarget:self action:@selector(stopAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.changeLanguage = [UIButton buttonWithType:UIButtonTypeSystem];
    self.changeLanguage.backgroundColor = [UIColor redColor];
    self.changeLanguage.frame = CGRectMake(0, 260, width, 50);
    [self.changeLanguage setTitle:@"切换语言" forState:UIControlStateNormal];
    [self.view addSubview:self.changeLanguage];
    [self.changeLanguage addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.languageEnvironment = [[UILabel alloc] initWithFrame:CGRectMake(0, 330, width, 50)];
    self.languageEnvironment.backgroundColor = [UIColor whiteColor];
    self.languageEnvironment.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.languageEnvironment];
    if (self.languageSlected) {
        self.languageEnvironment.text = @"现在环境为英文";
    }else
    {
        self.languageEnvironment.text = @"现在环境为中文";
    }
    
    self.pocketsphinx = [OEPocketsphinxController sharedInstance];
    
    self.englishWords = [NSArray arrayWithObjects:@"LEFT", @"TOP", @"BOTTOM", @"RIGHT",@"FLY",@"DOWN", nil];
    self.chineseWords = [NSArray arrayWithObjects:@"左边", @"上边", @"下边", @"右边", nil];
    
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
}
- (void)startAction:(id)sender {
    
    [self setupWithLanguageModel];
    
    [self.start setTitle:@"监听中..." forState:UIControlStateNormal];
    
    [self.pocketsphinx setActive:TRUE error:nil];
    
    if (self.languageSlected) {
        [self.pocketsphinx startListeningWithLanguageModelAtPath:self.englishLmPath dictionaryAtPath:self.englishDicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }else
    {
        [self.pocketsphinx startListeningWithLanguageModelAtPath:self.chineseLmPath dictionaryAtPath:self.chineseDicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelChinese"] languageModelIsJSGF:NO];
    }
    
}
- (void)stopAction:(id)sender {
    [self.start setTitle:@"开始" forState:UIControlStateNormal];
    [self.pocketsphinx stopListening];
}
- (void)changeAction:(id)sender {
    
    self.languageSlected = !self.languageSlected;
    if (self.languageSlected) {
        self.languageEnvironment.text = @"现在环境为英文";
    }else
    {
        self.languageEnvironment.text = @"现在环境为中文";
    }

    [self.pocketsphinx stopListening];
    [self setupWithLanguageModel];
    if (self.languageSlected) {
        
        [self.pocketsphinx startListeningWithLanguageModelAtPath:self.englishLmPath dictionaryAtPath:self.englishDicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    }else
    {
        [self.pocketsphinx startListeningWithLanguageModelAtPath:self.chineseLmPath dictionaryAtPath:self.chineseDicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelChinese"] languageModelIsJSGF:NO];
    }
}

- (void)setupWithLanguageModel
{
    
    self.lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    [self judgeLanguageModel];

}

- (void)judgeLanguageModel
{
    if (self.languageSlected) {
        
        self.errString = [self.lmGenerator generateLanguageModelFromArray:self.englishWords withFilesNamed:EnglishModel forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    }else
    {
        self.errString = [self.lmGenerator generateLanguageModelFromArray:self.chineseWords withFilesNamed:ChineseModel forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelChinese"]];
    }
    
    if(self.errString == nil) {
        
        if (self.languageSlected) {
            
            self.englishLmPath = [self.lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:EnglishModel];
            self.englishDicPath = [self.lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:EnglishModel];
        }else
        {
            self.chineseLmPath = [self.lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:ChineseModel];
            self.chineseDicPath = [self.lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:ChineseModel];
        }
        
    } else {
        NSLog(@"Error: %@",[self.errString localizedDescription]);
    }
}


- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"接收到的语音是 %@ 分数为 %@ ID为 %@", hypothesis, recognitionScore, utteranceID);
    self.speechLabel.text = hypothesis;
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx 已经开始收听.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx 已经发现语音.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinxc一段时间没监听到声音。");
}

- (void) pocketsphinxDidStopListening {

    NSLog(@"Pocketsphinx 已经停止监听.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx 已经暂停识别.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx 已经恢复识别.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx现在使用以下语言模型: \n%@ 和下面的字典: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
    if (self.languageSlected) {
        self.languageEnvironment.text = @"现在环境为英文";
    }else
    {
        self.languageEnvironment.text = @"现在环境为中文";
    }
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"监听设置不成功,返回失败的原因: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"监听关闭不成功,返回失败原因: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"完成一个测试文件的提交和识别.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
