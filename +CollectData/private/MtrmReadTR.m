function [TagName,TagValue,Raw] = MtrmReadTR(MTPath,RMPath,SizeT,TagThreshold)
TagStruct=load(MTPath).Tags;
TagName=string(fieldnames(TagStruct)');
TagValue=cell2mat(arrayfun(@(Name)TagStruct.(Name)(1:SizeT),TagName,"UniformOutput",false))>TagThreshold;
Raw=load(RMPath).Measurements(1:SizeT,:);