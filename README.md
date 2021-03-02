钙数据分析作图工具包，分为数据收集CollectData和作图DrawFigure两个子包。
# CollectData
该包负责将数据文件读入内存，整理成便于引用计算分析的格式。
## Rdc3_Atr
将Rdc3格式文件收集为Atr格式内存数据
### Rdc3格式
fps(1,1)double，采样率

raw_tag(1,:,:)double，原始标。第2维是时间，第3维是Block

base_block(1,:)double，指示哪些Block无需拆分

nrd_c(:,:)cell，拆分、标准化后的数据。第1维是Block，第2维是细胞。元胞内是(:,:)double，第1维是Trial，第2维是时间

Name(:,1)cell，每个Block的名称。元胞内是(1,:)char。

TagCode(:,2)double，每个Block的编码，与Name对应

raw_data(:,:,:)double，原始数据。第1维是时间，第2维是细胞，第3维是Block
### Atr格式
(:,:)cell，第1维对应TagCode第1列，第2维对应TagCode第2列。元胞内是(1,:)cell，第2维是细胞。元胞内是(:,:)double，第1维是Trial，第2维是时间。
### 输入参数
FilePath(1,1)string，Rdc2格式文件
### 返回值
atr(:,:)cell，Atr格式内存数据
# DrawFigure
该包负责作图，只接受最接近直接作图的处理后数据，不负责数据处理
## OverallHeatmap
显示每个细胞不同天的全Trial平均Trace
```MATLAB
DrawFigure.OverallHeatmap(rand(300,300,3),"HideYAxis","ShowColorbar","ImagescStyle",{"XData",[0 3]},"SubTitles",["1" "2" "3"],"CBLabel","我是颜色棒");
```
[查看示例图](+DrawFigure\示例\OverallHeatmap.svg)，因为生成的是随机数据，图线位置可能不同，但样式应当一致。
### 位置参数
Data(:,:,:)，必需，作图数据。第1维是不同的细胞，将作图为不同行；第2维是Trial内的时间轴，将作图到同一行；第3维是不同的天，将水平展开为不同的泳道
### 重复参数
Flags(1,1)string，可以设置以下旗帜：
- HideXAxis，隐藏X轴
- HideYAxis，隐藏Y轴
- ShowColorbar，显示颜色棒
### 名称-值对组参数
Colormap(:,3)double，可选，颜色映射。如不指定，将由MATLAB自动设置。

ImagescStyle(1,:)cell，本函数调用imagesc绘图，此处指定要传递给imagesc的其它参数。默认行为是，如果Data有正有负，则设为{[-AbsMax,AbsMax]}，其中AbsMax=max(abs(Data),[],"all")；否则为{}。建议至少设置XData和YData参数，保证XY坐标尺度正确。

SubTitles(1,:)string，每个泳道的小标题。如不指定，将不显示小标题。

CBLabel(1,1)string，颜色棒的标签。如不指定，将不显示标签。

TLStyle(1,:)cell={'TileSpacing','none','Padding','compact'}，本函数调用tiledlayout布局泳道，此处指定要传递给tiledlayout的其它参数。
## ShadowedLine
将平均值±误差曲线，通过中间一条均线、两边误差边界阴影的形式作图出来。
```MATLAB
tiledlayout("flow");
%% 基本用法
nexttile;
%生成一些随机数据
Data=rand(10,10);
%求平均值
Mean=mean(Data,1);
%求误差（此处使用SEM）
Error=std(Data,0,1)/sqrt(10);
%作图
DrawFigure.ShadowedLine(Mean,Error);
%% 自定义样式
nexttile;
%横轴在0~1之间
Xs=linspace(0,1,10);
%阴影区为半透明红色
FillStyle={"r","FaceAlpha",0.1,"LineStyle","none"};
%图线为虚线
PlotStyle={"--"};
DrawFigure.ShadowedLine(Mean,Error,Xs,"ShadowStyle",FillStyle,"LineStyle",PlotStyle);
```
[查看示例图](+DrawFigure\示例\ShadowedLine.svg)，因为生成的是随机数据，图线位置可能不同，但样式应当一致。
### 必需参数
LineYs(1,:)，平均值折线Y值，将用plot函数作出

ShadowHeights(1,:)，误差范围阴影高度，将用fill函数作出
### 可选参数
Xs(1,:)=1:numel(LineYs)，X轴对应数值向量
### 名称-值对组参数
LineStyle(1,:)cell={'k'}，均值折线的样式，将传递给plot函数实现

ShadowStyle(1,:)cell={"k","FaceAlpha",0.2,"LineStyle","none"}，误差阴影的样式，将传递给fill函数实现
### 参数互限
LineYs ShadowHeights Xs，这三个向量应当具有相同的长度
### 返回值
Line(1,1)matlab.graphics.chart.primitive.Line，平均线，plot函数返回的图线对象

Shadow(1,1)matlab.graphics.primitive.Patch，误差阴影，fill函数返回的填充对象
## TrialwiseTrace
作单Trial追踪图，图上有多条相互断开的折线在X轴上排布，每条线可具有误差阴影和刺激范围
```MATLAB
tiledlayout("flow");
%% 基本用法
nexttile;
%生成一些随机数据
Data=rand(5,10,10);
%求平均值
Mean=mean(Data,3);
%求误差（此处使用SEM）
Error=std(Data,0,3)/sqrt(10);
%作图
[Lines,Shadows]=DrawFigure.TrialwiseTrace(Mean,Error);
%% 自定义样式
nexttile;
%横轴在0~1之间
Xs=linspace(0,1,10);
%阴影区为半透明红色
FillStyle={"r","FaceAlpha",0.1,"LineStyle","none"};
%图线为虚线
PlotStyle={"--"};
%绘制刺激范围
StimuRange=[0.3 0.4];
%Y轴范围
YLimit=[0 2];
%每条线间隔X为0.1
XSpacing=0.2;
[Lines,Shadows,Stimuli]=DrawFigure.TrialwiseTrace(Mean,Error,XSpacing,"StimuRange",StimuRange,"ShadowStyle",FillStyle,"LineStyle",PlotStyle,"Xs",Xs,"YLimit",YLimit);
```
[查看示例图](+DrawFigure\示例\TrialwiseTrace.svg)，因为生成的是随机数据，图线位置可能不同，但样式应当一致。
### 必需参数
MeanLines(:,:)，每一行是一条平均线上的不同时点数值，不同行是不同的平均线

ErrorShadows(:,:)，每一行是一条平均线不同时点的误差，不同行是不同线的误差
### 可选参数
XSpacing(1,1){mustBeNonnegative}=1，每条线之间的X距离
### 名称-值对组参数
StimuRange(1,2)，刺激所在的时间范围。如不指定，则不绘制刺激范围，不输出返回值Stimuli。

Xs(1,:)=1:width(MeanLines)，各时点的X值

YLimit(1,2)，Y轴数值范围。如不指定，则由MATLAB自动设置。

LineStyle(1,:)cell={'b'}，均值折线的样式，将传递给plot函数实现

ShadowStyle(1,:)cell={"b","FaceAlpha",0.2,"LineStyle","none"}，误差阴影的样式，将传递给fill函数实现

StimuStyle(1,:)cell={"r","FaceAlpha",0.2,"LineStyle","none"}，刺激范围的样式，将传递给fill函数实现。如果StimuRange未指定，将忽略该参数。
### 参数互限
MeanLines和ErrorShadows应当具有完全相同的尺寸，且与Xs具有相同的宽度
### 返回值
Lines(:,1)matlab.graphics.chart.primitive.Line，平均线，plot函数返回的图线对象

Shadows(:,1)matlab.graphics.primitive.Patch，误差阴影，fill函数返回的填充对象

Stimuli(:,1)matlab.graphics.primitive.Patch，刺激范围，fill函数返回的填充对象。如果StimuRange未指定，将不返回该参数，尝试取得该返回值将导致错误。
# Transcode
本包包含数据转码函数，将CollectData收集到的数据转化为适合于DrawFigure作图的格式。
## Atrs_TrialwiseTrace
将Atr格式数据转码为适合于TrialwiseTrace作图的格式
### Atr格式
(:,:)cell，第1维对应TagCode第1列，第2维对应TagCode第2列。元胞内是(1,:)cell，第2维是细胞。元胞内是(:,:)double，第1维是Trial，第2维是时间。
### 必需参数
Atrs(:,1)cell，每个元胞内是一个Atr数据单元

TagCodes(:,2)uint8{mustBePositive}，根据所需实验条件设置的Atr元胞索引

TimeIndices(1,:)uint16{mustBePositive}，要取出的时间索引（采样帧，不是真实时间）。例如1:500可取出前500帧。

### 名称-值对组参数
TrialsFromStart(1,:)uint8{mustBePositive}=[]，从开头计算，要取出哪些Trial。例如1:5取出前5个Trial

TrialsFromEnd(1,:)uint8{mustBePositive}=[]，从末尾倒数，要取出哪些Trial。例如5:-1:1取出后5个Trial，并正序排列；1:5同样取出后5个Trial，但倒序排列。

### 返回值（TrialwiseTrace作图数据）
MeanLines(:,:)double，第1维是不同的平均线，第2维是一条平均线上的不同时点数值。

ErrorShadows(:,:)double，第1维对应每条平均线的误差，第2维是一条平均线不同时点的误差