function [TagName,TagValue] = MtReadTags(MtPath,SizeT,TagThreshold)
TagStruct=load(MtPath).Tags;
TagName=string(fieldnames(TagStruct)');
TagValue=cell2mat(arrayfun(@(Name)TagStruct.(Name)(1:SizeT),TagName,"UniformOutput",false))>TagThreshold;