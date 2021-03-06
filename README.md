钙数据分析作图工具包，分为数据收集CollectData、数据转码Transcode和作图DrawFigure，3个子包。依赖[埃博拉酱的MATLAB工具包](https://github.com/Silver-Fang/EbolaChanMatlabToolbox)和[GuanLab杂项](https://github.com/ShanghaitechGuanjisongLab/Miscellany)
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
## MTRMs_METRaw
将多个MTRM文件存储格式读入为METRaw内存格式
### 输入参数
RMPaths(:,1)string，必需，RM文件路径

SizeT(1,1)uint16，必需，每个文件要截取的时间帧数，应当短于所有文件中的时间帧数，否则会出错。

MTPaths(:,1)string，可选，MT文件路径。如果不指定，将根据MTRM文件命名规范自动查找MT文件。如果找不到，则对应位置的Tags元胞将为空。

TagThreshold(1,1)uint16=550，名称-值对组参数，将Tag值逻辑化时的阈值
### 返回值（METRaw）
Mice(:,1)string，小鼠名称

Experiments(1,:)string，实验名称

Tags(:,:)cell，第1维是不同鼠，第2维是不同实验。元胞里是结构体标量，每个字段是电流检测设备名称，值是逻辑化的标：
- CD1(:,1)logical
- CD2(:,1)logical
- ……

Raws(:,:)cell，第1维是不同鼠，第2维是不同实验。元胞里是(:,:,:)single，第1维是时间，第2维是细胞，第3维是Trial
### MTRM文件存储格式
MTRM格式将每个Trial的钙数据存储在单独的文件中，且未经ΔF/F₀处理。直接存储。一个Trial存储单元还分为两个文件，称为MT文件和RM文件。其中MT文件存储元数据和Tag，RM文件存储钙测量值。
#### MT文件
MT文件的标准文件名格式是：
```
<鼠名>.<日期时间>.<光电参数>.<实验名>_<Trial号>.MetaTags.mat
```
包含两个字段：

MetaData(1,1)struct
- ScannerType(1,1)string，扫描器类型，可以是"Resonant"或"Galvano"
- DeviceNames(:,1)string，采集设备名，如"RNDD4G"、"CD1"等。每行对应一个图像通道。
- Fps(1,1)double，采样帧率
- SizeX(1,1)double，图像宽度
- SizeY(1,1)double，图像高度
- SizeZ(1,1)double，图像深度
- SizeC(1,1)double，图像通道数
- SizeT(1,1)double，时间周期数
- DimensionOrder(1,1)string，维度顺序，通常是"XYCZT"
- OmeXml(1,1)string，OME元数据XML
- ChannelColors(:,4)table，包含Red, Green, Blue, Alpha四列，都是(1,1)uint8，每个通道一行，对应一个图像通道的颜色。
- Tags(1,1)struct

每个字段是一个CD通道设备名，值是(:,1)double，每个元素为一帧的全像素平均值。
#### RM文件
RM文件的标准文件名格式是：
```
<鼠名>.<日期时间>.<光电参数>.<实验名>_<Trial号>.Registered.Measurements.mat
```
其中只有一个字段Measurements(:,:)single，第1维是时间，第2维是细胞。
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
# DrawFigure
该包负责作图，只接受最接近直接作图的处理后数据，不负责数据处理
## OverallHeatmap
显示每个细胞不同天的全Trial平均Trace
```MATLAB
DrawFigure.OverallHeatmap(rand(300,300,3),"HideYAxis","ShowColorbar","ImagescStyle",{"XData",[0 3]},"SubTitles",["1" "2" "3"],"CBLabel","我是颜色棒");
```
[查看示例图](+DrawFigure/示例/OverallHeatmap.svg)，因为生成的是随机数据，图线位置可能不同，但样式应当一致。
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
[查看示例图](+DrawFigure/示例/TrialwiseTrace.svg)，因为生成的是随机数据，图线位置可能不同，但样式应当一致。
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