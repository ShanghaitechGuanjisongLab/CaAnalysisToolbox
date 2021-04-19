function [TagName,TagValue] = MtReadTagsStTt(MtPath,SizeT,TagThreshold)
TagStruct=load(MtPath).Tags;
TagName=string(fieldnames(TagStruct)');
if SizeT<65535
	TagValue=arrayfun(@(Name)TagStruct.(Name)(1:SizeT)>TagThreshold,TagName,"UniformOutput",false);
else
	TagValue=arrayfun(@(Name)TagStruct.(Name)>TagThreshold,TagName,"UniformOutput",false);
end