function Overall = BlockySubMedian(Overall,SamplePoints)
for b=1:numel(Overall)
	Overall{b}=median(Overall{b}(:,SamplePoints,:),3);
end
Overall=cat(3,Overall{:});