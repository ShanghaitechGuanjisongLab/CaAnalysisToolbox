function TagValue = MtReadTags(MtPath)
TagStruct=load(MtPath).Tags;
TagValue=EbolaChan.FunctionHelpers.DimensionFun(@(Name)TagStruct.(Name)',string(fieldnames(TagStruct)),CatMode="Linear");