function TagValue = MtReadTags(MtPath)
TagStruct=load(MtPath).Tags;
TagValue=DimensionFun(@(Name)TagStruct.(Name)',string(fieldnames(TagStruct)),CatMode="Linear");