钙数据分析作图工具包，分为数据收集CollectData、数据转码Transcode和作图DrawFigure，3个子包。依赖[埃博拉酱的MATLAB工具包](https://github.com/Silver-Fang/EbolaChanMatlabToolbox)和[GuanLab杂项](https://github.com/ShanghaitechGuanjisongLab/Miscellany)
# 数据格式规范
本节描述了多个函数中用到的数据格式规范。
## Rdc3格式
本格式存储了一天内一只鼠一个细胞群体多个不同刺激Block的钙和标数据，包含处理前全长连续数据和经过ΔF/F₀处理、分Trial的数据。

fps(1,1)double，采样率

raw_tag(1,:,:)double，原始标。第2维是时间，第3维是Block

base_block(1,:)double，指示哪些Block无需拆分

nrd_c(:,:)cell，拆分、标准化后的数据。第1维是Block，第2维是细胞。元胞内是(:,:)double，第1维是Trial，第2维是时间

Name(:,1)cell，每个Block的名称。元胞内是(1,:)char。

TagCode(:,2)double，每个Block的编码，与Name对应。对应关系见[翻译表](+CollectData/TranslateTable.mat)

raw_data(:,:,:)double，原始数据。第1维是时间，第2维是细胞，第3维是Block
## MECgRawsTags格式
本格式存储了多天、多只鼠、多个不同实验、多个Trial、多个细胞群体的分Trial的细胞测量数据。以下字段在某些函数中并不全都需要。

Mice(:,1)string，参与实验的鼠名

Experiments(:,1)string，实验名

CellGroups(:,1)string，细胞群体名

MECgRaws(:,:,:)cell，钙信号测量值。第1维是不同实验，第2维是不同鼠，第3维是不同细胞类群。元胞里是(:,:,:)single，第1维是细胞，第2维是时间，第3维是Trial。

METags(:,:)cell，标通道逻辑值，表明某一时刻是否有标。第1维是不同实验，第2维是不同鼠。元胞内是(:,:)table，第1维是Trial，第2维是标通道。表格内是(:,1)logical，第1维是时间，通过一定阈值得到此刻是否有标的逻辑值。
# CollectData
该包负责将数据文件读入内存，整理成便于引用计算分析的格式。
## Rdc3_Atr
将[Rdc3格式](#Rdc3格式)文件收集为Atr格式内存数据
### Atr格式
(:,:)cell，第1维对应TagCode第1列，第2维对应TagCode第2列。元胞内是(1,:)cell，第2维是细胞。元胞内是(:,:)double，第1维是Trial，第2维是时间。
### 输入参数
FilePath(1,1)string，Rdc2格式文件
### 返回值
atr(:,:)cell，Atr格式内存数据
## Rdc3s_MECgBCalcium
将一系列[Rdc3格式](#Rdc3格式)文件读入为MECgBCalcium内存格式
### 输入参数
Rdc3Paths(:,1)string，要读入的Rdc3文件路径

SelectedBlocks，如果是(:,1)string，每个元素必须是MECgBCalcium标准Block名；如果是(:,2)，每一行必须是MECgBCalcium标准TagCode。每个标准Block名对应一个TagCode(1,2)，TagCode作为行列坐标，对应块名记录在TranslateTable中。
### 返回值（MECgBCalcium格式）
Mice(:,1)string，鼠名

Experiments(:,1)string，实验名

CellGroups(:,1)string，细胞群名

Blocks(:,1)string，标准Block名。

Calcium(:,:,:,:)cell，ΔF/F₀处理后的钙信号测量值。第1维Block，第2维细胞群，第3维实验，第4维小鼠。元胞内(:,:,:)double，第1维Trial，第2维时间，第3维细胞。
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
## SortBeforeOH
在做总览热图OverallHeatmap之前对细胞进行分群排序。

将每个细胞按照它在哪天平均信号最强，归入那一群，然后将每一群聚拢排序以后展开在泳道上。

输入参数：Data(:,:,:)，第1维是泳道内不同的行，第2维是泳道内不同的列，第3维是不同的泳道

返回值：Data(:,:,:)，维度同输入，但经过了聚类和排序。
# DrawFigure
该包负责作图，只接受最接近直接作图的处理后数据，不负责数据处理
## ConsistentMultiPlot
作一横排尺度、样式一致的多线图。
### 位置参数
Data(:,:,:)，必需，第1维是一块图内不同的折线，第2维是折线上不同的时间，第3维是不同的图块

Xs(1,:)=1:width(Data)，可选，横轴时间点值
### 名称-值对组参数
Legends(:,1)string，每条线对应一个图例。默认不显示图例。

LegendStyle(1,:)cell，图例的样式，作为参数传递给legend。

CommonOneLegend(1,1)logical=true，是否只在最后额外添加一个图块显示一个共用的图例，否则每个图块都有自己的图例

PlotStyle(:,1)cell，每个元胞对应一条线，元胞里又是一个元胞数组，规定该条线的样式，作为参数传递给plot。

TLStyle(1,:)cell={'Padding','none','TileSpacing','none'}，图块布局样式，作为参数传递给tiledlayout。
### 返回值
Layout(1,1)matlab.graphics.layout.TiledChartLayout，使用tiledlayout生成的作图的布局。
## OverallHeatmap
显示每个细胞不同天的全Trial平均Trace
```MATLAB
DrawFigure.OverallHeatmap(rand(300,300,3),"HideYAxis","ShowColorbar","ImagescStyle",{"XData",[0 3]},"SubTitles",["1" "2" "3"],"CBLabel","我是颜色棒");
```
![](+DrawFigure/示例/OverallHeatmap.svg)

因为生成的是随机数据，图线位置可能不同，但样式应当一致。
### 位置参数
Data(:,:,:)，必需，作图数据。第1维是不同的细胞，将作图为不同行；第2维是Trial内的时间轴，将作图到同一行；第3维是不同的天，将水平展开为不同的泳道

Colormap(:,3)double，可选，颜色映射。如不指定，将由MATLAB自动设置。
### 名称-值对组参数
ImagescStyle(1,:)cell，本函数调用imagesc绘图，此处指定要传递给imagesc的其它参数。默认行为是，如果Data有正有负，则设为{[-AbsMax,AbsMax]}，其中AbsMax=max(abs(Data),[],"all")；否则为{}。建议至少设置XData和YData参数，保证XY坐标尺度正确。

SubTitles(1,:)string，每个泳道的小标题。如不指定，将不显示小标题。

CBLabel(1,1)string，颜色棒的标签。如不指定，将不显示标签。

TLStyle(1,:)cell={'TileSpacing','none','Padding','compact'}，本函数调用tiledlayout布局泳道，此处指定要传递给tiledlayout的其它参数。

Flags(1,:)string，可以设置以下旗帜：
- HideXAxis，隐藏X轴
- HideYAxis，隐藏Y轴
- ShowColorbar，显示颜色棒
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
![](+DrawFigure/示例/TrialwiseTrace.svg)

因为生成的是随机数据，图线位置可能不同，但样式应当一致。
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