function [TagName,TagValue] = MtReadTags(MtPath,SizeT,TagThreshold)
TagStruct=load(MtPath).Tags;
TagName=string(fieldnames(TagStruct)');
TagValue=arrayfun(@(Name)TagStruct.(Name)(1:SizeT)>TagThreshold,TagName,"UniformOutput",false);